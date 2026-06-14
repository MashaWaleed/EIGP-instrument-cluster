# Raspberry Pi 5 Boot2Qt Image

This document describes the Boot2Qt Linux image and cross-compilation toolchain used to build and deploy the EIGP instrument cluster on Raspberry Pi 5.

## Image location (development host)

The Boot2Qt BSP for Raspberry Pi (64-bit) is installed at:

```text
/home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/
```

| Path | Purpose |
|------|---------|
| `images/b2qt-embedded-qt6-image-raspberrypi-armv8.rootfs.wic.xz` | Flashable SD card image |
| `images/b2qt-embedded-qt6-image-raspberrypi-armv8.rootfs.info` | Image build metadata |
| `toolchain/environment-setup-cortexa53-poky-linux` | Cross-compilation environment |
| `toolchain/configure-qtcreator.sh` | Registers the Qt Creator kit |
| `toolchain/sysroots/` | Target and SDK sysroots |

## Image details

| Property | Value |
|----------|-------|
| Qt version | 6.10.3 |
| Boot2Qt distro | 5.2.4 (walnascar) |
| Target machine | `raspberrypi-armv8` (Cortex-A53, 64-bit) |
| Deploy profile | Raspberry Pi Development Boards (64bit) |

Official setup guide: [Boot to Qt installation](https://doc.qt.io/Boot2Qt/b2qt-qbsp-installation-guide.html)

## Flash the SD card

1. Decompress the image:

   ```bash
   xz -dk /home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/images/b2qt-embedded-qt6-image-raspberrypi-armv8.rootfs.wic.xz
   ```

2. Write the `.wic` file to an SD card (replace `/dev/sdX` with your device):

   ```bash
   sudo dd if=b2qt-embedded-qt6-image-raspberrypi-armv8.rootfs.wic of=/dev/sdX bs=4M status=progress conv=fsync
   ```

3. Boot the Raspberry Pi 5 from the SD card and connect it to the same network as the development machine.

## Configure Qt Creator

Register the cross-compilation kit once:

```bash
/home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/toolchain/configure-qtcreator.sh
```

This creates a kit named **Custom Qt 6.10.3 raspberrypi-armv8** with the correct compiler, sysroot, CMake toolchain file, and Boot2Qt device type.

In Qt Creator:

1. Open this repository as a CMake project.
2. Select the Boot2Qt kit for the build configuration.
3. Add a Boot2Qt device under **Preferences → Devices** if one is not already configured.
4. Build and deploy with the **Build → Deploy** or **Run** workflow.

## Build from the command line

Source the toolchain environment, then configure and build:

```bash
source /home/masha/Qt/6.10.3/Boot2Qt/raspberrypi-armv8/toolchain/environment-setup-cortexa53-poky-linux

cmake -S /home/masha/Projects/EIGP-instrument-cluster \
      -B /home/masha/Projects/EIGP-instrument-cluster/build/raspberrypi-armv8-Debug \
      -DCMAKE_BUILD_TYPE=Debug

cmake --build /home/masha/Projects/EIGP-instrument-cluster/build/raspberrypi-armv8-Debug \
      --target eigp-instrument-cluster install
```

The installed binary lands under the CMake install prefix configured for your kit (default deployment target in Qt Design Studio: `/opt/Dashboard`).

## Runtime notes

- The application targets EGLFS full-screen rendering on Boot2Qt.
- Physical display dimensions are configured in `main.cpp` via `QT_QPA_EGLFS_PHYSICAL_WIDTH` and `QT_QPA_EGLFS_PHYSICAL_HEIGHT`.
- UART input for torque requests is read by `DashboardSerialController`. Override the port and baud rate with environment variables:
  - `DASHBOARD_SERIAL_PORT`
  - `DASHBOARD_SERIAL_BAUD`
- USB OTG device mode is supported on Raspberry Pi 4 only; use network deployment for Pi 5.

## Updating the image

When upgrading Qt or Boot2Qt, install the new BSP through the Qt Maintenance Tool, then update the paths in this document and re-run `configure-qtcreator.sh`.
