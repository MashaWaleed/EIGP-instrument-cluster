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
            y: -52
            width: Math.max(4, gauge.width * 0.0105)
            height: 60
            opacity: 0.6
            radius: width / 2
            border.width: 0
            border.color: Qt.rgba(220 / 255, 231 / 255, 243 / 255, 0.28)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            anchors.bottomMargin: 222
            clip: false
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#deffffff"
                }

                GradientStop {
                    position: 0.97865
                    color: "#000000"
                }
                orientation: Gradient.Vertical
            }
            anchors.horizontalCenterOffset: 0
        }
    }

    Rectangle {
        z: 3
        height: width
        radius: width / 2
        color: "#F7FAFF"
    }
}
