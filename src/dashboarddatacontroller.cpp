#include "dashboarddatacontroller.h"

#include "dashboardcansource.h"

#include <algorithm>

namespace {
#ifdef EIGP_DEMO_FIRMWARE
constexpr double kMaxTorquePercent = 100.0;
constexpr double kMaxRpm = 8000.0;
constexpr double kMaxSpeedKph = 220.0;
constexpr double kMaxCurrentAmps = 420.0;
constexpr double kAmbientTemperatureC = 24.0;
constexpr double kMaxTemperatureC = 88.0;
constexpr double kIdleRpm = 850.0;
#endif
}

DashboardDataController::DashboardDataController(QObject *parent)
    : QObject(parent)
{
#ifndef EIGP_DEMO_FIRMWARE
    m_canSource = new DashboardCanSource(this);

    connect(m_canSource, &DashboardCanSource::torqueRequestPercentReceived,
            this, &DashboardDataController::setTorqueRequestPercent);
    connect(m_canSource, &DashboardCanSource::rpmReceived,
            this, &DashboardDataController::setRpm);
    connect(m_canSource, &DashboardCanSource::currentAmpsReceived,
            this, &DashboardDataController::setCurrentAmps);
    connect(m_canSource, &DashboardCanSource::temperatureCReceived,
            this, &DashboardDataController::setTemperatureC);
    connect(m_canSource, &DashboardCanSource::interfaceNameChanged,
            this, &DashboardDataController::canInterfaceNameChanged);
    connect(m_canSource, &DashboardCanSource::connectedChanged,
            this, &DashboardDataController::canConnectedChanged);
#endif
}

void DashboardDataController::setKeyboardTorqueRequestActive(bool active)
{
#ifdef EIGP_DEMO_FIRMWARE
    applyDemoTorqueRequest(active ? kMaxTorquePercent : 0.0);
#else
    Q_UNUSED(active);
#endif
}

double DashboardDataController::torqueRequestPercent() const
{
    return m_torqueRequestPercent;
}

double DashboardDataController::rpm() const
{
    return m_rpm;
}

double DashboardDataController::speedKph() const
{
    return m_speedKph;
}

double DashboardDataController::currentAmps() const
{
    return m_currentAmps;
}

double DashboardDataController::temperatureC() const
{
    return m_temperatureC;
}

QString DashboardDataController::dataSource() const
{
#ifdef EIGP_DEMO_FIRMWARE
    return QStringLiteral("demo");
#else
    return QStringLiteral("can");
#endif
}

QString DashboardDataController::canInterfaceName() const
{
#ifndef EIGP_DEMO_FIRMWARE
    return m_canSource ? m_canSource->interfaceName() : QString {};
#else
    return {};
#endif
}

bool DashboardDataController::canConnected() const
{
#ifndef EIGP_DEMO_FIRMWARE
    return m_canSource && m_canSource->connected();
#else
    return false;
#endif
}

void DashboardDataController::applyDemoTorqueRequest(double percent)
{
#ifdef EIGP_DEMO_FIRMWARE
    const double clampedPercent = std::clamp(percent, 0.0, kMaxTorquePercent);
    const double normalized = clampedPercent / kMaxTorquePercent;
    const double nextRpm = clampedPercent <= 0.0
        ? 0.0
        : (kIdleRpm + normalized * (kMaxRpm - kIdleRpm));

    setTorqueRequestPercent(clampedPercent);
    setRpm(nextRpm);
    setSpeedKph(normalized * kMaxSpeedKph);
    setCurrentAmps(normalized * kMaxCurrentAmps);
    setTemperatureC(kAmbientTemperatureC + normalized * (kMaxTemperatureC - kAmbientTemperatureC));
#else
    Q_UNUSED(percent);
#endif
}

void DashboardDataController::setTorqueRequestPercent(double percent)
{
    const double clampedPercent = std::clamp(percent, 0.0, 100.0);
    if (qFuzzyCompare(m_torqueRequestPercent + 1.0, clampedPercent + 1.0))
        return;

    m_torqueRequestPercent = clampedPercent;
    emit torqueRequestPercentChanged();
}

void DashboardDataController::setRpm(double rpm)
{
    const double clampedRpm = std::max(0.0, rpm);
    if (qFuzzyCompare(m_rpm + 1.0, clampedRpm + 1.0))
        return;

    m_rpm = clampedRpm;
    emit rpmChanged();
}

void DashboardDataController::setSpeedKph(double speedKph)
{
    const double clampedSpeed = std::max(0.0, speedKph);
    if (qFuzzyCompare(m_speedKph + 1.0, clampedSpeed + 1.0))
        return;

    m_speedKph = clampedSpeed;
    emit speedKphChanged();
}

void DashboardDataController::setCurrentAmps(double currentAmps)
{
    const double clampedCurrent = std::max(0.0, currentAmps);
    if (qFuzzyCompare(m_currentAmps + 1.0, clampedCurrent + 1.0))
        return;

    m_currentAmps = clampedCurrent;
    emit currentAmpsChanged();
}

void DashboardDataController::setTemperatureC(double temperatureC)
{
    if (qFuzzyCompare(m_temperatureC + 1.0, temperatureC + 1.0))
        return;

    m_temperatureC = temperatureC;
    emit temperatureCChanged();
}
