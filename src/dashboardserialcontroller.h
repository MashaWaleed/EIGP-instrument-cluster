#pragma once

#include <QByteArray>
#include <QObject>
#include <QSerialPort>
#include <QTimer>

#include <optional>

class DashboardSerialController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double torqueRequestPercent READ torqueRequestPercent NOTIFY torqueRequestPercentChanged)
    Q_PROPERTY(double rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(double speedKph READ speedKph NOTIFY speedKphChanged)
    Q_PROPERTY(double currentAmps READ currentAmps NOTIFY currentAmpsChanged)
    Q_PROPERTY(double temperatureC READ temperatureC NOTIFY temperatureCChanged)
    Q_PROPERTY(QString serialPortName READ serialPortName NOTIFY serialPortNameChanged)
    Q_PROPERTY(bool serialConnected READ serialConnected NOTIFY serialConnectedChanged)

public:
    explicit DashboardSerialController(QObject *parent = nullptr);

    Q_INVOKABLE void setKeyboardTorqueRequestActive(bool active);

    double torqueRequestPercent() const;
    double rpm() const;
    double speedKph() const;
    double currentAmps() const;
    double temperatureC() const;
    QString serialPortName() const;
    bool serialConnected() const;

signals:
    void torqueRequestPercentChanged();
    void rpmChanged();
    void speedKphChanged();
    void currentAmpsChanged();
    void temperatureCChanged();
    void serialPortNameChanged();
    void serialConnectedChanged();

private slots:
    void ensurePortOpen();
    void handleReadyRead();
    void handleSerialError(QSerialPort::SerialPortError error);

private:
    void processLine(const QString &line);
    void applyTorqueRequest(double percent);
    void setSerialTorqueRequestPercent(double percent);
    void updateEffectiveTorqueRequest();
    QString resolvePortName() const;
    int resolveBaudRate() const;
    std::optional<double> parseTorqueRequest(const QString &line) const;

    QSerialPort m_serialPort;
    QTimer m_reconnectTimer;
    QByteArray m_readBuffer;
    QString m_serialPortName;
    QString m_lastError;
    double m_serialTorqueRequestPercent = 0.0;
    double m_keyboardTorqueRequestPercent = 0.0;
    double m_torqueRequestPercent = 0.0;
    double m_rpm = 0.0;
    double m_speedKph = 0.0;
    double m_currentAmps = 0.0;
    double m_temperatureC = 24.0;
    bool m_serialConnected = false;
};