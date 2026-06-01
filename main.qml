import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.5

Window {
    id: root
    width: 1024
    height: 600
    visible: true
    color: "#0b1128"
    title: qsTr("DashBoard")
    minimumWidth: 1024
    minimumHeight: 600
    maximumWidth: 1024
    maximumHeight: 600

    property alias fontLoader: dashboardFontLoader
    readonly property bool designStudioPreview: (Qt.application.name || "").toLowerCase().indexOf("qml2puppet") !== -1
    readonly property var serialDataSource: typeof serialController !== "undefined" ? serialController : null
    property bool dashboardContentVisible: designStudioPreview

    FontLoader {
        id: dashboardFontLoader
        source: "fontawesome.otf"
    }

    Component.onCompleted: {
        if (!designStudioPreview)
            splashScreen.start()
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
        id: keyboardInputProxy
        anchors.fill: parent
        focus: true

        Component.onCompleted: forceActiveFocus()

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                if (root.serialDataSource && root.serialDataSource.setKeyboardTorqueRequestActive)
                    root.serialDataSource.setKeyboardTorqueRequestActive(true)
                event.accepted = true
            }
        }

        Keys.onReleased: function(event) {
            if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                if (root.serialDataSource && root.serialDataSource.setKeyboardTorqueRequestActive)
                    root.serialDataSource.setKeyboardTorqueRequestActive(false)
                event.accepted = true
            }
        }
    }

    DashboardContent {
        id: dashboardContent
        anchors.fill: parent
        contentVisible: root.dashboardContentVisible
        torqueRequestPercent: root.serialDataSource ? root.serialDataSource.torqueRequestPercent : 42
        rpm: root.serialDataSource ? root.serialDataSource.rpm : 3200
        speedKph: root.serialDataSource ? root.serialDataSource.speedKph : 72
        currentAmps: root.serialDataSource ? root.serialDataSource.currentAmps : 180
        temperatureC: root.serialDataSource ? root.serialDataSource.temperatureC : 41
        iconFontFamily: dashboardFontLoader.name
    }

    SplashScreen {
        id: splashScreen
        anchors.fill: parent
        onFinished: root.dashboardContentVisible = true
    }
}
