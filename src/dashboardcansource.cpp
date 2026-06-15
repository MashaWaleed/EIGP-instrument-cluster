#include "dashboardcansource.h"

#include "canprotocol.h"

#include <QDebug>

#include <algorithm>
#include <cerrno>
#include <cstring>

#include <fcntl.h>
#include <unistd.h>

#include <linux/can.h>
#include <linux/can/raw.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <unistd.h>

namespace {
constexpr int kReconnectIntervalMs = 2000;
constexpr ssize_t kClassicCanFrameSize = 16;
constexpr double kMaxTorquePercent = 100.0;
constexpr double kMaxRpm = 8000.0;
constexpr double kMaxCurrentAmps = 6553.5;
}

DashboardCanSource::DashboardCanSource(QObject *parent)
    : QObject(parent)
{
    m_reconnectTimer.setInterval(kReconnectIntervalMs);
    connect(&m_reconnectTimer, &QTimer::timeout, this, &DashboardCanSource::attemptConnect);
    m_reconnectTimer.start();

    m_pollTimer.setInterval(10);
    connect(&m_pollTimer, &QTimer::timeout, this, &DashboardCanSource::readFrames);

    QMetaObject::invokeMethod(this, &DashboardCanSource::attemptConnect, Qt::QueuedConnection);
}

DashboardCanSource::~DashboardCanSource()
{
    closeSocket();
}

QString DashboardCanSource::interfaceName() const
{
    return m_interfaceName;
}

bool DashboardCanSource::connected() const
{
    return m_connected;
}

void DashboardCanSource::attemptConnect()
{
    if (m_socketFd >= 0)
        return;

    const QString interfaceName = resolveInterfaceName();
    if (interfaceName.isEmpty()) {
        if (!m_interfaceName.isEmpty()) {
            m_interfaceName.clear();
            emit interfaceNameChanged();
        }
        setConnected(false);
        return;
    }

    if (m_interfaceName != interfaceName) {
        m_interfaceName = interfaceName;
        emit interfaceNameChanged();
    }

    const int socketFd = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (socketFd < 0) {
        const QString errorText = QStringLiteral("socket(PF_CAN) failed");
        if (m_lastError != errorText) {
            qWarning().noquote() << "CAN socket creation failed:" << errorText;
            m_lastError = errorText;
        }
        setConnected(false);
        return;
    }

    ifreq interfaceRequest {};
    const QByteArray interfaceNameBytes = interfaceName.toLocal8Bit();
    const auto nameLength = std::min<qsizetype>(interfaceNameBytes.size(), IF_NAMESIZE - 1);
    std::memcpy(interfaceRequest.ifr_name, interfaceNameBytes.constData(), static_cast<size_t>(nameLength));
    interfaceRequest.ifr_name[nameLength] = '\0';

    if (::ioctl(socketFd, SIOCGIFINDEX, &interfaceRequest) < 0) {
        const QString errorText = QStringLiteral("ioctl(SIOCGIFINDEX) failed for %1").arg(interfaceName);
        if (m_lastError != errorText) {
            qWarning().noquote() << errorText;
            m_lastError = errorText;
        }
        ::close(socketFd);
        setConnected(false);
        return;
    }

    sockaddr_can address {};
    address.can_family = AF_CAN;
    address.can_ifindex = interfaceRequest.ifr_ifindex;

    if (::bind(socketFd, reinterpret_cast<sockaddr *>(&address), sizeof(address)) < 0) {
        const QString errorText = QStringLiteral("bind() failed for %1").arg(interfaceName);
        if (m_lastError != errorText) {
            qWarning().noquote() << errorText;
            m_lastError = errorText;
        }
        ::close(socketFd);
        setConnected(false);
        return;
    }

    const int socketFlags = ::fcntl(socketFd, F_GETFL, 0);
    if (socketFlags >= 0)
        ::fcntl(socketFd, F_SETFL, socketFlags | O_NONBLOCK);

    m_socketFd = socketFd;
    m_lastError.clear();

    m_notifier = new QSocketNotifier(m_socketFd, QSocketNotifier::Read, this);
    connect(m_notifier, &QSocketNotifier::activated, this, &DashboardCanSource::readFrames);
    m_pollTimer.start();

    setConnected(true);
    qInfo().noquote() << "Listening for dashboard CAN frames on" << interfaceName
                      << "at" << CanProtocol::kDefaultBitrate << "bit/s (expected)";
}

void DashboardCanSource::readFrames()
{
    if (m_socketFd < 0)
        return;

    while (true) {
        alignas(can_frame) char buffer[CAN_MTU] {};
        const ssize_t bytesRead = ::read(m_socketFd, buffer, sizeof(buffer));
        if (bytesRead < 0) {
            if (errno == EAGAIN || errno == EWOULDBLOCK)
                break;

            qWarning().noquote() << "CAN read failed, reconnecting";
            closeSocket();
            return;
        }

        if (bytesRead < kClassicCanFrameSize)
            continue;

        canid_t rawId = 0;
        std::memcpy(&rawId, buffer, sizeof(rawId));
        if (rawId & CAN_ERR_FLAG)
            continue;

        const quint8 payloadLength = static_cast<quint8>(buffer[4]);
        const quint8 *payload = reinterpret_cast<const quint8 *>(buffer + 8);
        const quint32 frameId = rawId & CAN_SFF_MASK;

        switch (frameId) {
        case CanProtocol::kTorqueRequestId:
            if (payloadLength >= 1) {
                const double percent = std::clamp(static_cast<double>(payload[0]),
                                                  0.0, kMaxTorquePercent);
                emit torqueRequestPercentReceived(percent);
            }
            break;
        case CanProtocol::kRpmId:
            if (payloadLength >= 2) {
                const quint16 raw = (static_cast<quint16>(payload[0]) << 8)
                    | static_cast<quint16>(payload[1]);
                emit rpmReceived(std::min<double>(raw, kMaxRpm));
            }
            break;
        case CanProtocol::kCurrentId:
            if (payloadLength >= 2) {
                const quint16 raw = (static_cast<quint16>(payload[0]) << 8)
                    | static_cast<quint16>(payload[1]);
                emit currentAmpsReceived(std::min<double>(raw / 10.0, kMaxCurrentAmps));
            }
            break;
        case CanProtocol::kTemperatureId:
            if (payloadLength >= 1) {
                const auto temperature = static_cast<qint8>(payload[0]);
                emit temperatureCReceived(static_cast<double>(temperature));
            }
            break;
        default:
            break;
        }
    }
}

void DashboardCanSource::closeSocket()
{
    m_pollTimer.stop();

    if (m_notifier) {
        m_notifier->setEnabled(false);
        m_notifier->deleteLater();
        m_notifier = nullptr;
    }

    if (m_socketFd >= 0) {
        ::close(m_socketFd);
        m_socketFd = -1;
    }

    setConnected(false);
}

void DashboardCanSource::setConnected(bool connected)
{
    if (m_connected == connected)
        return;

    m_connected = connected;
    emit connectedChanged();
}

QString DashboardCanSource::resolveInterfaceName() const
{
    const QString configuredInterface = qEnvironmentVariable("EIGP_CAN_INTERFACE");
    if (!configuredInterface.isEmpty())
        return configuredInterface;

    return QStringLiteral("can0");
}
