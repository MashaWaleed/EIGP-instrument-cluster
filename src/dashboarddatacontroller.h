#pragma once

#include <QObject>

class DashboardCanSource;

class DashboardDataController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double torqueRequestPercent READ torqueRequestPercent NOTIFY torqueRequestPercentChanged)
    Q_PROPERTY(double rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(double speedKph READ speedKph NOTIFY speedKphChanged)
    Q_PROPERTY(double currentAmps READ currentAmps NOTIFY currentAmpsChanged)
    Q_PROPERTY(double temperatureC READ temperatureC NOTIFY temperatureCChanged)
    Q_PROPERTY(QString dataSource READ dataSource CONSTANT)
    Q_PROPERTY(QString canInterfaceName READ canInterfaceName NOTIFY canInterfaceNameChanged)
    Q_PROPERTY(bool canConnected READ canConnected NOTIFY canConnectedChanged)

public:
    explicit DashboardDataController(QObject *parent = nullptr);

    Q_INVOKABLE void setKeyboardTorqueRequestActive(bool active);

    double torqueRequestPercent() const;
    double rpm() const;
    double speedKph() const;
    double currentAmps() const;
    double temperatureC() const;
    QString dataSource() const;
    QString canInterfaceName() const;
    bool canConnected() const;

signals:
    void torqueRequestPercentChanged();
    void rpmChanged();
    void speedKphChanged();
    void currentAmpsChanged();
    void temperatureCChanged();
    void canInterfaceNameChanged();
    void canConnectedChanged();

private:
    void applyDemoTorqueRequest(double percent);
    void setTorqueRequestPercent(double percent);
    void setRpm(double rpm);
    void setSpeedKph(double speedKph);
    void setCurrentAmps(double currentAmps);
    void setTemperatureC(double temperatureC);

#ifndef EIGP_DEMO_FIRMWARE
    DashboardCanSource *m_canSource = nullptr;
#endif

    double m_torqueRequestPercent = 0.0;
    double m_rpm = 0.0;
    double m_speedKph = 0.0;
    double m_currentAmps = 0.0;
    double m_temperatureC = 24.0;
};
