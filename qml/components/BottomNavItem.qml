import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property bool checked: false
    property string glyph: ""
    property string fontFamily: ""
    property url iconSource: ""
    property color activeColor: "#FFFFFF"
    property color inactiveColor: "#75C9F7"
    property real baseSize: 34
    property real activeSize: 46

    signal clicked()

    implicitWidth: 84
    implicitHeight: 76
    width: implicitWidth
    height: implicitHeight
    scale: root.checked ? 1.08 : 1.0
    opacity: root.checked ? 1.0 : 0.62

    Behavior on scale {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Glow {
        anchors.fill: symbolLayer
        source: symbolLayer
        radius: root.checked ? 20 : 0
        samples: 33
        spread: 0.2
        color: "#64D8FF"
        opacity: root.checked ? 0.95 : 0.0
        visible: opacity > 0

        Behavior on radius {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }

    Item {
        id: symbolLayer
        anchors.fill: parent

        Text {
            id: glyphLabel
            visible: root.glyph.length > 0
            anchors.centerIn: parent
            text: root.glyph
            font.family: root.fontFamily
            font.pixelSize: root.baseSize
            font.weight: Font.DemiBold
            color: root.checked ? root.activeColor : root.inactiveColor
            opacity: root.checked ? 1.0 : 0.88
            scale: root.checked ? root.activeSize / root.baseSize : 1.0
            renderType: Text.NativeRendering
            antialiasing: true

            Behavior on scale {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }

        Image {
            id: iconImage
            anchors.centerIn: parent
            width: root.baseSize
            height: root.baseSize
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            opacity: 0.0
        }

        ColorOverlay {
            id: tintedIcon
            visible: root.iconSource.toString().length > 0
            anchors.centerIn: parent
            width: iconImage.width
            height: iconImage.height
            source: iconImage
            color: root.checked ? root.activeColor : root.inactiveColor
            opacity: root.checked ? 1.0 : 0.88
            scale: root.checked ? root.activeSize / root.baseSize : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}