import QtQuick 2.15

Item {
    id: gauge

    property real value: 0
    property real minimumValue: 0
    property real maximumValue: 100
    property bool shadowVisible: true
    property bool passedFillVisible: true
    property real startAngle: -210
    property real sweepAngle: 240
    property string trackColor: "rgba(255, 255, 255, 0.08)"
    property string passedFillColor: "rgba(232, 239, 248, 0.28)"
    property color needleColor: "#F7FAFF"
    property color needleAccentColor: Qt.rgba(202 / 255, 217 / 255, 232 / 255, 0.42)
    property color hubColor: "#2D6BFF"

    readonly property real trackWidth: Math.max(4, width * 0.028)
    readonly property real passedFillWidth: Math.max(8, width * 0.052)
    readonly property real arcRadius: Math.min(width, height) / 2 - passedFillWidth * 1.55
    function degreesToRadians(degrees) {
        return degrees * (Math.PI / 180)
    }

    function clampedProgress() {
        if (maximumValue <= minimumValue)
            return 0
        var clamped = Math.max(minimumValue, Math.min(maximumValue, value))
        return (clamped - minimumValue) / (maximumValue - minimumValue)
    }

    function valueAngleDegrees() {
        return startAngle + (sweepAngle * clampedProgress())
    }

    onValueChanged: gaugeCanvas.requestPaint()
    onMinimumValueChanged: gaugeCanvas.requestPaint()
    onMaximumValueChanged: gaugeCanvas.requestPaint()
    onWidthChanged: gaugeCanvas.requestPaint()
    onHeightChanged: gaugeCanvas.requestPaint()
    onShadowVisibleChanged: gaugeCanvas.requestPaint()
    onPassedFillVisibleChanged: gaugeCanvas.requestPaint()

    Canvas {
        id: gaugeCanvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var cx = gauge.width / 2
            var cy = gauge.height / 2
            var progress = gauge.clampedProgress()

            ctx.lineCap = "round"

            if (gauge.shadowVisible) {
                ctx.beginPath()
                ctx.lineWidth = gauge.trackWidth
                ctx.strokeStyle = gauge.trackColor
                ctx.arc(cx,
                        cy,
                        gauge.arcRadius,
                        gauge.degreesToRadians(gauge.startAngle),
                        gauge.degreesToRadians(gauge.startAngle + gauge.sweepAngle))
                ctx.stroke()
            }

            if (gauge.passedFillVisible && progress > 0.001) {
                ctx.beginPath()
                ctx.lineWidth = gauge.passedFillWidth
                ctx.strokeStyle = gauge.passedFillColor
                ctx.arc(cx,
                        cy,
                        gauge.arcRadius,
                        gauge.degreesToRadians(gauge.startAngle),
                        gauge.degreesToRadians(gauge.startAngle + gauge.sweepAngle * progress))
                ctx.stroke()
            }
        }
    }

    Item {
        id: needleLayer
        anchors.fill: parent
        rotation: gauge.valueAngleDegrees() + 90
        transformOrigin: Item.Center
        z: 1

        Rectangle {
            id: needleBody
            width: Math.max(4, gauge.width * 0.0105)
            height: gauge.height * 0.39
            radius: width / 2
            color: gauge.needleColor
            border.width: 1
            border.color: Qt.rgba(220 / 255, 231 / 255, 243 / 255, 0.28)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            anchors.bottomMargin: gauge.height * 0.015
        }

        Rectangle {
            width: needleBody.width * 0.34
            height: needleBody.height * 0.86
            radius: width / 2
            color: gauge.needleAccentColor
            anchors.horizontalCenter: needleBody.horizontalCenter
            anchors.top: needleBody.top
            anchors.topMargin: needleBody.width * 0.55
        }

        Item {
            width: needleBody.width * 1.9
            height: gauge.height * 0.085
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: gauge.height * 0.018

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: parent.width
                height: parent.height
                radius: height / 2
                color: Qt.rgba(212 / 255, 223 / 255, 237 / 255, 0.38)
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: parent.width * 0.45
                height: parent.height
                radius: height / 2
                color: gauge.needleColor
                opacity: 0.65
            }
        }

        Rectangle {
            width: needleBody.width * 1.45
            height: needleBody.width * 1.45
            radius: width / 2
            color: Qt.rgba(1, 1, 1, 0.14)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: gauge.height * 0.008
        }
    }

    Rectangle {
        id: hubOuter
        z: 2
        width: Math.max(16, gauge.width * 0.082)
        height: width
        radius: width / 2
        color: gauge.hubColor
        border.width: 1
        border.color: Qt.rgba(247 / 255, 250 / 255, 255 / 255, 0.18)
        anchors.centerIn: parent
    }

    Rectangle {
        z: 3
        width: hubOuter.width * 0.34
        height: width
        radius: width / 2
        color: "#F7FAFF"
        anchors.centerIn: hubOuter
    }
}
