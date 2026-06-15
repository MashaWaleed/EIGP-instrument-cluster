#pragma once

#include <QtGlobal>

namespace CanProtocol {

constexpr quint32 kTorqueRequestId = 0x100;
constexpr quint32 kRpmId = 0x101;
constexpr quint32 kCurrentId = 0x102;
constexpr quint32 kTemperatureId = 0x103;

constexpr int kDefaultBitrate = 125000;

} // namespace CanProtocol
