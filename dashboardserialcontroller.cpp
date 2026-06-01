#include "dashboardserialcontroller.h"

#include <QDebug>
#include <QFileInfo>
#include <QRegularExpression>
#include <QSerialPortInfo>

#include <algorithm>

namespace {
constexpr int kReconnectIntervalMs = 2000;
constexpr int kDefaultBaudRate = 115200;
constexpr double kMaxTorquePercent = 100.0;
constexpr double kMaxRpm = 8000.0;
constexpr double kMaxSpeedKph = 220.0;
constexpr double kMaxCurrentAmps = 420.0;
constexpr double kAmbientTemperatureC = 24.0;
constexpr double kMaxTemperatureC = 88.0;
constexpr double kIdleRpm = 850.0;
}

DashboardSerialController::DashboardSerialController(QObject *parent)
    : QObject(parent)
{
    connect(&m_serialPort, &QSerialPort::readyRead,
            this, &DashboardSerialController::handleReadyRead);
    connect(&m_serialPort, &QSerialPort::errorOccurred,
            this, &DashboardSerialController::handleSerialError);

    m_reconnectTimer.setInterval(kReconnectIntervalMs);
    connect(&m_reconnectTimer, &QTimer::timeout,
            this, &DashboardSerialController::ensurePortOpen);
    m_reconnectTimer.start();

    QMetaObject::invokeMethod(this, &DashboardSerialController::ensurePortOpen,
                              Qt::QueuedConnection);
}

void DashboardSerialController::setKeyboardTorqueRequestActive(bool active)
{
    const double nextKeyboardTorqueRequestPercent = active ? kMaxTorquePercent : 0.0;
    if (qFuzzyCompare(m_keyboardTorqueRequestPercent + 1.0, nextKeyboardTorqueRequestPercent + 1.0))
        return;

    m_keyboardTorqueRequestPercent = nextKeyboardTorqueRequestPercent;
    updateEffectiveTorqueRequest();
}

double DashboardSerialController::torqueRequestPercent() const
{
    return m_torqueRequestPercent;
}

double DashboardSerialController::rpm() const
{
    return m_rpm;
}

double DashboardSerialController::speedKph() const
{
    return m_speedKph;
}

double DashboardSerialController::currentAmps() const
{
    return m_currentAmps;
}

double DashboardSerialController::temperatureC() const
{
    return m_temperatureC;
}

QString DashboardSerialController::serialPortName() const
{
    return m_serialPortName;
}

bool DashboardSerialController::serialConnected() const
{
    return m_serialConnected;
}

void DashboardSerialController::ensurePortOpen()
{
    if (m_serialPort.isOpen())
        return;

    const QString portName = resolvePortName();
    if (portName.isEmpty()) {
        if (!m_serialPortName.isEmpty()) {
            m_serialPortName.clear();
            emit serialPortNameChanged();
        }
        if (m_serialConnected) {
            m_serialConnected = false;
            emit serialConnectedChanged();
        }
        return;
    }

    if (m_serialPortName != portName) {
        m_serialPortName = portName;
        emit serialPortNameChanged();
    }

    m_serialPort.setPortName(portName);
    m_serialPort.setBaudRate(resolveBaudRate());
    m_serialPort.setDataBits(QSerialPort::Data8);
    m_serialPort.setParity(QSerialPort::NoParity);
    m_serialPort.setStopBits(QSerialPort::OneStop);
    m_serialPort.setFlowControl(QSerialPort::NoFlowControl);

    if (!m_serialPort.open(QIODevice::ReadOnly)) {
        const QString errorText = m_serialPort.errorString();
        if (m_lastError != errorText) {
            qWarning().noquote() << "Failed to open torque UART" << portName << ':' << errorText;
            m_lastError = errorText;
        }
        return;
    }

    m_lastError.clear();
    m_readBuffer.clear();

    if (!m_serialConnected) {
        m_serialConnected = true;
        emit serialConnectedChanged();
    }

    qInfo().noquote() << "Listening for torque request on" << portName
                      << "at" << m_serialPort.baudRate() << "baud";
}

void DashboardSerialController::handleReadyRead()
{
    m_readBuffer.append(m_serialPort.readAll());

    while (true) {
        int separatorIndex = m_readBuffer.indexOf('\n');
        const int carriageReturnIndex = m_readBuffer.indexOf('\r');
        if (separatorIndex < 0 || (carriageReturnIndex >= 0 && carriageReturnIndex < separatorIndex))
            separatorIndex = carriageReturnIndex;

        if (separatorIndex < 0)
            break;

        const QByteArray lineBytes = m_readBuffer.left(separatorIndex);
        m_readBuffer.remove(0, separatorIndex + 1);

        while (!m_readBuffer.isEmpty() && (m_readBuffer.front() == '\n' || m_readBuffer.front() == '\r'))
            m_readBuffer.remove(0, 1);

        processLine(QString::fromUtf8(lineBytes));
    }

    if (m_readBuffer.size() > 512)
        m_readBuffer.clear();
}

void DashboardSerialController::handleSerialError(QSerialPort::SerialPortError error)
{
    if (error == QSerialPort::NoError)
        return;

    if (error == QSerialPort::ResourceError || error == QSerialPort::ReadError) {
        qWarning().noquote() << "Torque UART read failed:" << m_serialPort.errorString();
        m_serialPort.close();
    }

    if (m_serialConnected) {
        m_serialConnected = false;
        emit serialConnectedChanged();
    }
}

void DashboardSerialController::processLine(const QString &line)
{
    const auto torqueValue = parseTorqueRequest(line);
    if (!torqueValue.has_value())
        return;

    setSerialTorqueRequestPercent(*torqueValue);
}

void DashboardSerialController::applyTorqueRequest(double percent)
{
    const double clampedPercent = std::clamp(percent, 0.0, kMaxTorquePercent);
    const double normalized = clampedPercent / kMaxTorquePercent;
    const double nextRpm = clampedPercent <= 0.0 ? 0.0 : (kIdleRpm + normalized * (kMaxRpm - kIdleRpm));
    const double nextSpeed = normalized * kMaxSpeedKph;
    const double nextCurrentAmps = normalized * kMaxCurrentAmps;
    const double nextTemperatureC = kAmbientTemperatureC + normalized * (kMaxTemperatureC - kAmbientTemperatureC);

    if (!qFuzzyCompare(m_torqueRequestPercent + 1.0, clampedPercent + 1.0)) {
        m_torqueRequestPercent = clampedPercent;
        emit torqueRequestPercentChanged();
    }

    if (!qFuzzyCompare(m_rpm + 1.0, nextRpm + 1.0)) {
        m_rpm = nextRpm;
        emit rpmChanged();
    }

    if (!qFuzzyCompare(m_speedKph + 1.0, nextSpeed + 1.0)) {
        m_speedKph = nextSpeed;
        emit speedKphChanged();
    }

    if (!qFuzzyCompare(m_currentAmps + 1.0, nextCurrentAmps + 1.0)) {
        m_currentAmps = nextCurrentAmps;
        emit currentAmpsChanged();
    }

    if (!qFuzzyCompare(m_temperatureC + 1.0, nextTemperatureC + 1.0)) {
        m_temperatureC = nextTemperatureC;
        emit temperatureCChanged();
    }
}

void DashboardSerialController::setSerialTorqueRequestPercent(double percent)
{
    const double clampedPercent = std::clamp(percent, 0.0, kMaxTorquePercent);
    if (qFuzzyCompare(m_serialTorqueRequestPercent + 1.0, clampedPercent + 1.0))
        return;

    m_serialTorqueRequestPercent = clampedPercent;
    updateEffectiveTorqueRequest();
}

void DashboardSerialController::updateEffectiveTorqueRequest()
{
    applyTorqueRequest(std::max(m_serialTorqueRequestPercent, m_keyboardTorqueRequestPercent));
}

QString DashboardSerialController::resolvePortName() const
{
    const QList<QSerialPortInfo> availablePorts = QSerialPortInfo::availablePorts();
    if (availablePorts.isEmpty())
        return {};

    const auto canonicalPort = [&availablePorts](const QString &candidate) {
        for (const QSerialPortInfo &portInfo : availablePorts) {
            const QString systemLocation = portInfo.systemLocation();
            const QString portName = portInfo.portName();

            if (QString::compare(systemLocation, candidate, Qt::CaseInsensitive) == 0
                || QString::compare(portName, candidate, Qt::CaseInsensitive) == 0) {
                return systemLocation.isEmpty() ? portName : systemLocation;
            }
        }

        return QString {};
    };

    const QString configuredPort = qEnvironmentVariable("DASHBOARD_SERIAL_PORT");
    if (!configuredPort.isEmpty()) {
        const QString canonicalConfiguredPort = canonicalPort(configuredPort);
        return canonicalConfiguredPort.isEmpty() ? configuredPort : canonicalConfiguredPort;
    }

    const QStringList preferredPorts = {
        QStringLiteral("/dev/ttyAMA0"),
        QStringLiteral("/dev/ttyAMA1"),
        QStringLiteral("/dev/ttyAMA2"),
        QStringLiteral("/dev/ttyAMA3"),
        QStringLiteral("/dev/ttyAMA4"),
        QStringLiteral("/dev/ttyS0"),
        QStringLiteral("ttyAMA0"),
        QStringLiteral("ttyAMA1"),
        QStringLiteral("ttyAMA2"),
        QStringLiteral("ttyAMA3"),
        QStringLiteral("ttyAMA4"),
        QStringLiteral("ttyS0"),
        QStringLiteral("ttyUSB0"),
        QStringLiteral("ttyACM0")
    };

    for (const QString &preferredPort : preferredPorts) {
        const QString resolvedPreferredPort = canonicalPort(preferredPort);
        if (!resolvedPreferredPort.isEmpty())
            return resolvedPreferredPort;
    }

    const QFileInfo serial0Info(QStringLiteral("/dev/serial0"));
    if (serial0Info.exists()) {
        const QString serial0Target = serial0Info.isSymLink() ? serial0Info.symLinkTarget() : QString {};
        if (!serial0Target.endsWith(QStringLiteral("/ttyAMA10")))
            return QStringLiteral("/dev/serial0");
    }

    for (const QSerialPortInfo &portInfo : availablePorts) {
        const QString systemLocation = portInfo.systemLocation().isEmpty() ? portInfo.portName() : portInfo.systemLocation();
        if (systemLocation.startsWith(QStringLiteral("/dev/ttyUSB"))
            || systemLocation.startsWith(QStringLiteral("/dev/ttyACM"))) {
            return systemLocation;
        }
    }

    return {};
}

int DashboardSerialController::resolveBaudRate() const
{
    bool ok = false;
    const int configuredBaudRate = qEnvironmentVariableIntValue("DASHBOARD_SERIAL_BAUD", &ok);
    if (ok && configuredBaudRate > 0)
        return configuredBaudRate;

    return kDefaultBaudRate;
}

std::optional<double> DashboardSerialController::parseTorqueRequest(const QString &line) const
{
    const QString trimmedLine = line.trimmed();
    if (trimmedLine.isEmpty())
        return std::nullopt;

    static const QRegularExpression keyedPattern(
        QStringLiteral(R"REGEX("?(?:torque(?:Request|_request)?|trq)"?\s*[:=]\s*(-?\d+(?:\.\d+)?)\s*%?)REGEX"),
        QRegularExpression::CaseInsensitiveOption);
    const QRegularExpressionMatch keyedMatch = keyedPattern.match(trimmedLine);
    if (keyedMatch.hasMatch())
        return keyedMatch.captured(1).toDouble();

    static const QRegularExpression plainNumberPattern(
        QStringLiteral(R"(^\s*(-?\d+(?:\.\d+)?)\s*%?\s*$)"));
    const QRegularExpressionMatch plainNumberMatch = plainNumberPattern.match(trimmedLine);
    if (plainNumberMatch.hasMatch())
        return plainNumberMatch.captured(1).toDouble();

    return std::nullopt;
}