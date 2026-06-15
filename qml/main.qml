import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.5

Window {
    id: root

    readonly property bool designStudioPreview: (Qt.application.name || "").toLowerCase().indexOf("qml2puppet") !== -1
    readonly property bool embeddedDisplay: Qt.platform.os === "linux"
                                          && !designStudioPreview
                                          && Screen.width > 0
                                          && Screen.height > 0
    readonly property int designViewportWidth: 1024
    readonly property int designViewportHeight: 600
    readonly property int panelHeight: typeof physicalPanelHeight !== "undefined" ? physicalPanelHeight : 0

    width: embeddedDisplay ? Screen.width : designViewportWidth
    height: embeddedDisplay ? Screen.height : designViewportHeight
    visibility: embeddedDisplay ? Window.FullScreen : Window.Windowed
    visible: true
    color: "#0b1128"
    title: qsTr("DashBoard")

    property alias fontLoader: dashboardFontLoader
    readonly property var dataSource: typeof dashboardController !== "undefined" ? dashboardController : null
    property bool dashboardContentVisible: designStudioPreview

    FontLoader {
        id: dashboardFontLoader
        source: "../assets/fonts/fontawesome.otf"
    }

    Component.onCompleted: {
        if (embeddedDisplay) {
            console.log("Display size:", Screen.width, "x", Screen.height,
                        "panel height:", panelHeight,
                        "x scale:", displayRoot.contentScaleX,
                        "y scale:", displayRoot.contentScaleY)
        }
        if (root.dataSource) {
            dashboardContent.torqueRequestPercent = root.dataSource.torqueRequestPercent
            dashboardContent.rpm = root.dataSource.rpm
            dashboardContent.speedKph = root.dataSource.speedKph
            dashboardContent.currentAmps = root.dataSource.currentAmps
            dashboardContent.temperatureC = root.dataSource.temperatureC
        }
        if (!designStudioPreview)
            Qt.callLater(splashScreen.start)
    }

    Shortcut {
        sequence: "Ctrl+E"
        onActivated: keyboardInputProxy.forceActiveFocus()
    }

    Shortcut {
        sequence: "Esc"
        onActivated: root.close()
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: root.close()
    }

    Item {
        id: displayRoot
        anchors.fill: parent

        readonly property real uniformScale: embeddedDisplay
            ? Math.min(width / root.designViewportWidth, height / root.designViewportHeight)
            : 1.0
        readonly property real panelSquishCompensation: {
            if (!embeddedDisplay)
                return 1.0
            var referenceHeight = root.panelHeight > 0
                ? root.panelHeight
                : root.designViewportHeight
            if (height <= referenceHeight)
                return 1.0
            return height / referenceHeight
        }
        readonly property real contentScaleX: uniformScale
        readonly property real contentScaleY: uniformScale * panelSquishCompensation

        Item {
            id: keyboardInputProxy
            anchors.fill: parent
            focus: true

            Component.onCompleted: forceActiveFocus()

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                    if (root.dataSource && root.dataSource.setKeyboardTorqueRequestActive)
                        root.dataSource.setKeyboardTorqueRequestActive(true)
                    event.accepted = true
                }
            }

            Keys.onReleased: function(event) {
                if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                    if (root.dataSource && root.dataSource.setKeyboardTorqueRequestActive)
                        root.dataSource.setKeyboardTorqueRequestActive(false)
                    event.accepted = true
                }
            }
        }

        Item {
            id: contentLayer
            width: root.designViewportWidth
            height: root.designViewportHeight
            anchors.centerIn: parent

            transform: Scale {
                xScale: displayRoot.contentScaleX
                yScale: displayRoot.contentScaleY
                origin.x: contentLayer.width / 2
                origin.y: contentLayer.height / 2
            }

            DashboardContent {
                id: dashboardContent
                anchors.fill: parent
                contentVisible: root.dashboardContentVisible
                iconFontFamily: dashboardFontLoader.name
            }

            SplashScreen {
                id: splashScreen
                anchors.fill: parent
                onFinished: root.dashboardContentVisible = true
            }
        }
    }

    Connections {
        target: root.dataSource
        enabled: root.dataSource !== null

        function onTorqueRequestPercentChanged() {
            dashboardContent.torqueRequestPercent = root.dataSource.torqueRequestPercent
        }

        function onRpmChanged() {
            dashboardContent.rpm = root.dataSource.rpm
        }

        function onSpeedKphChanged() {
            dashboardContent.speedKph = root.dataSource.speedKph
        }

        function onCurrentAmpsChanged() {
            dashboardContent.currentAmps = root.dataSource.currentAmps
        }

        function onTemperatureCChanged() {
            dashboardContent.temperatureC = root.dataSource.temperatureC
        }
    }
}
