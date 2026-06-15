#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <QTimer>

class DashboardCanSource : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString interfaceName READ interfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)

public:
    explicit DashboardCanSource(QObject *parent = nullptr);
    ~DashboardCanSource() override;

    QString interfaceName() const;
    bool connected() const;

signals:
    void interfaceNameChanged();
    void connectedChanged();
    void torqueRequestPercentReceived(double percent);
    void rpmReceived(double rpm);
    void currentAmpsReceived(double amps);
    void temperatureCReceived(double temperatureC);

private slots:
    void attemptConnect();
    void readFrames();

private:
    void closeSocket();
    void setConnected(bool connected);
    QString resolveInterfaceName() const;

    int m_socketFd = -1;
    QSocketNotifier *m_notifier = nullptr;
    QTimer m_pollTimer;
    QTimer m_reconnectTimer;
    QString m_interfaceName;
    QString m_lastError;
    bool m_connected = false;
};
