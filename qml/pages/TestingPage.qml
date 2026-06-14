import QtQuick 2.15
import QtQuick.Controls 2.5

import "../components"

Item {
    id: root

    property real currentAmps: 0
    property real temperatureC: 24
    property real torqueRequestPercent: 0
    property string fontFamily: "Venera"
    property real pageScale: 1.0

    anchors.fill: parent

    CenterStatusPanel {
        id: centerStatusPanel
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 8 * root.pageScale
        anchors.verticalCenterOffset: 86 * root.pageScale
        scale: root.pageScale
        transformOrigin: Item.Center
        currentAmps: root.currentAmps
        temperatureC: root.temperatureC
        fontFamily: root.fontFamily
    }

    Item {
        id: torqueRequestBar
        x: 345
        y: 111
        width: 334
        height: 50

        readonly property real horizontalPadding: 8
        readonly property real verticalPadding: 7
        readonly property real fillWidth: Math.max(0, width - horizontalPadding * 2)

        Rectangle {
            id: torqueFillClip
            x: torqueRequestBar.horizontalPadding
            y: torqueRequestBar.verticalPadding
            width: torqueRequestBar.fillWidth * (root.torqueRequestPercent / 100)
            height: torqueRequestBar.height - torqueRequestBar.verticalPadding * 2
            radius: height / 2
            color: "transparent"
            clip: true

            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                width: torqueRequestBar.fillWidth
                height: parent.height
                radius: height / 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal

                    GradientStop {
                        position: 0.0
                        color: "#2ecc71"
                    }

                    GradientStop {
                        position: 0.45
                        color: "#a3d64f"
                    }

                    GradientStop {
                        position: 0.75
                        color: "#ff9f1c"
                    }

                    GradientStop {
                        position: 1.0
                        color: "#e53935"
                    }
                }
                opacity: 0.9
            }
        }

        Rectangle {
            x: torqueRequestBar.horizontalPadding
            y: torqueRequestBar.verticalPadding
            width: torqueRequestBar.fillWidth
            height: 36
            opacity: 0.6
            color: "#00005555"
            radius: 16
            border.width: 4
            clip: false
            border.color: "#030ba4"
        }

        Rectangle {
            width: 4
            height: torqueRequestBar.height - 14
            radius: 2
            y: 7
            x: torqueRequestBar.horizontalPadding + (torqueRequestBar.fillWidth * (root.torqueRequestPercent / 100)) - width / 2
            color: "#FFFFFF"
            opacity: 0.95
            visible: false

            Behavior on x {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Image {
        id: frame50
        x: 353
        y: 162
        width: 317
        height: 19
        source: "../../assets/images/Frame 50.png"
        fillMode: Image.PreserveAspectFit
    }
}