import QtQuick 2.15

Item {
    id: root

    property bool active: false
    property int splashFrameIndex: -1
    property real splashOverlayOpacity: 1
    property int frameSize: 520
    readonly property var frames: [
        Qt.resolvedUrl("../assets/images/splash_frames/frame1.png"),
        Qt.resolvedUrl("../assets/images/splash_frames/frame2.png"),
        Qt.resolvedUrl("../assets/images/splash_frames/frame3.png"),
        Qt.resolvedUrl("../assets/images/splash_frames/frame4.png"),
        Qt.resolvedUrl("../assets/images/splash_frames/frame5.png")
    ]

    signal finished()

    z: 1000
    visible: opacity > 0
    opacity: root.active ? root.splashOverlayOpacity : 0

    function start() {
        root.splashFrameIndex = 0
        root.splashOverlayOpacity = 1
        root.active = true
        splashSequence.restart()
        splashFallback.restart()
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 420
            easing.type: Easing.OutCubic
        }
    }

    Repeater {
        model: root.frames

        Image {
            anchors.centerIn: parent
            width: root.frameSize
            height: root.frameSize
            source: modelData
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            asynchronous: false
            opacity: root.splashFrameIndex >= index ? 1 : 0
            scale: root.splashFrameIndex >= index ? 1 : 1.015

            onStatusChanged: {
                if (status === Image.Error)
                    console.warn("Splash frame failed to load:", source)
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: index === root.frames.length - 1 ? 700 : 420
                    easing.type: Easing.InOutSine
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 420
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    SequentialAnimation {
        id: splashSequence
        running: false

        PauseAnimation { duration: 520 }
        ScriptAction { script: root.splashFrameIndex = 1 }
        PauseAnimation { duration: 500 }
        ScriptAction { script: root.splashFrameIndex = 2 }
        PauseAnimation { duration: 520 }
        ScriptAction { script: root.splashFrameIndex = 3 }
        PauseAnimation { duration: 560 }
        ScriptAction { script: root.splashFrameIndex = 4 }
        PauseAnimation { duration: 950 }
        ScriptAction { script: root.splashOverlayOpacity = 0 }
        PauseAnimation { duration: 420 }
        ScriptAction { script: root.finishSplash() }
    }

    Timer {
        id: splashFallback
        interval: 10000
        repeat: false
        onTriggered: root.finishSplash()
    }

    function finishSplash() {
        if (!root.active)
            return
        splashFallback.stop()
        root.active = false
        root.finished()
    }
}
