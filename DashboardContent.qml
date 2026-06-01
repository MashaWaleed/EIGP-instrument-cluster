import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "./Component"

Item {
    id: root

    property bool contentVisible: true
    property real leftSideLevel: 0.28
    property real rightSideLevel: 0.84
    property real torqueRequestPercent: 42
    property real rpm: 3200
    property real speedKph: 72
    property real currentAmps: 180
    property real temperatureC: 41
    readonly property int batteryPercentageValue: Math.round(root.rightSideLevel * 100)
    readonly property int batteryTempValue: Math.round(root.leftSideLevel * 100)
    property string selectedGear: "D"
    property string iconFontFamily: ""

    readonly property int designWidth: 1920
    readonly property int designHeight: 980
    readonly property real dashboardScale: Math.min(width / designWidth, height / designHeight)

    function assetUrl(path) {
        return Qt.resolvedUrl(path)
    }

    Image {
        id: panelImage
        z: 0
        sourceSize: Qt.size(root.width, root.height)
        anchors.centerIn: parent
        source: "Panel.png"
        width: root.designWidth
        height: 1000
        scale: root.dashboardScale
        transformOrigin: Item.Center

        Item {
            id: dashboardVisuals
            anchors.fill: parent
            z: 1
            visible: opacity > 0
            opacity: root.contentVisible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutCubic
                }
            }

            IconButton {
                id: leftIndicator
                x: 409
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-left-checked/icon-park-solid_right-two.svg") : root.assetUrl("icons/icons-left/icon-park-solid_right-two.svg")
                anchors.right: topBar.left
                anchors.rightMargin: -11
                anchors.verticalCenterOffset: 1
                anchors.verticalCenter: topBar.verticalCenter

                SequentialAnimation {
                    running: leftIndicator.checked
                    loops: Animation.Infinite

                    OpacityAnimator {
                        target: leftIndicator.roundIcon ? leftIndicator.roundIconSource : leftIndicator.iconSource
                        from: 0
                        to: 1
                        duration: 500
                    }

                    OpacityAnimator {
                        target: leftIndicator.roundIcon ? leftIndicator.roundIconSource : leftIndicator.iconSource
                        from: 1
                        to: 0
                        duration: 500
                    }
                }
            }

            IconButton {
                id: handbreak
                x: 338
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-left/mdi_car-handbrake.svg") : root.assetUrl("icons/icons-left/mdi_car-handbrake.svg")

                anchors {
                    right: leftIndicator.left
                    rightMargin: 6
                    verticalCenter: leftIndicator.verticalCenter
                    verticalCenterOffset: 42
                }
            }

            IconButton {
                id: battery
                x: 267
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-left-checked/mdi_car-battery.svg") : root.assetUrl("icons/icons-left/mdi_car-battery.svg")

                anchors {
                    right: handbreak.left
                    rightMargin: 6
                    verticalCenter: handbreak.verticalCenter
                    verticalCenterOffset: 50
                }

                SequentialAnimation {
                    running: battery.checked
                    loops: Animation.Infinite

                    OpacityAnimator {
                        target: battery.roundIcon ? battery.roundIconSource : battery.iconSource
                        from: 0
                        to: 1
                        duration: 500
                    }

                    OpacityAnimator {
                        target: battery.roundIcon ? battery.roundIconSource : battery.iconSource
                        from: 1
                        to: 0
                        duration: 500
                    }
                }
            }

            IconButton {
                id: engineBold
                x: 196
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-left-checked/ph_engine-bold.svg") : root.assetUrl("icons/icons-left/ph_engine-bold.svg")

                anchors {
                    right: battery.left
                    rightMargin: 6
                    verticalCenter: battery.verticalCenter
                    verticalCenterOffset: 51
                }

                SequentialAnimation {
                    running: engineBold.checked
                    loops: Animation.Infinite

                    OpacityAnimator {
                        target: engineBold.roundIcon ? engineBold.roundIconSource : engineBold.iconSource
                        from: 0
                        to: 1
                        duration: 500
                    }

                    OpacityAnimator {
                        target: engineBold.roundIcon ? engineBold.roundIconSource : engineBold.iconSource
                        from: 1
                        to: 0
                        duration: 500
                    }
                }
            }

            IconButton {
                id: oil
                x: 125
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-left-checked/mdi_oil.svg") : root.assetUrl("icons/icons-left/mdi_oil.svg")

                anchors {
                    right: engineBold.left
                    rightMargin: 6
                    verticalCenter: engineBold.verticalCenter
                    verticalCenterOffset: 45
                }

                SequentialAnimation {
                    running: oil.checked
                    loops: Animation.Infinite

                    OpacityAnimator {
                        target: oil.roundIcon ? oil.roundIconSource : oil.iconSource
                        from: 0
                        to: 1
                        duration: 500
                    }

                    OpacityAnimator {
                        target: oil.roundIcon ? oil.roundIconSource : oil.iconSource
                        from: 1
                        to: 0
                        duration: 500
                    }
                }
            }

            IconButton {
                id: tireAlert
                x: 65
                width: 65
                height: 65
                anchors.rightMargin: -5
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-left/mdi_car-tire-alert.svg") : root.assetUrl("icons/icons-left/mdi_car-tire-alert.svg")

                anchors {
                    right: oil.left
                    verticalCenter: oil.verticalCenter
                    verticalCenterOffset: 71
                }
            }

            Image {
                id: topBar
                source: "Top Bar.png"
                sourceSize: Qt.size(parent.width * 0.6, 150)
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: 80
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    Image {
                        width: 41
                        height: 20
                        source: "icons/cloud.svg"
                        fillMode: Image.PreserveAspectFit
                        sourceSize: Qt.size(24, 24)
                    }

                    Label {
                        text: qsTr("12 °C")
                        font.pixelSize: 24
                        font.bold: true
                        font.weight: Font.Normal
                        color: "#FFFFFF"
                        font.family: "Venera"
                    }
                }

                Label {
                    id: timeLabel
                    text: new Date().toLocaleTimeString(Qt.locale(), "hh:mm AP")
                    anchors.right: parent.right
                    anchors.rightMargin: 80
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 24
                    font.bold: true
                    font.weight: Font.Normal
                    font.family: "Venera"
                    color: "#FFFFFF"
                }
            }

            CenterStatusPanel {
                id: centerStatusPanel
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 8
                anchors.verticalCenterOffset: 86
                z: 1
                currentAmps: root.currentAmps
                temperatureC: root.temperatureC
                fontFamily: "Venera"
            }

            IconButton {
                id: rightIndicator
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-right-checked/icon-park-solid_right-two.svg") : root.assetUrl("icons/icons-right/icon-park-solid_right-two.svg")
                anchors.left: topBar.right
                anchors.leftMargin: -19
                anchors.verticalCenterOffset: 1
                isGlow: false
                iconBackground: "transparent"
                anchors.verticalCenter: topBar.verticalCenter

                SequentialAnimation {
                    running: rightIndicator.checked
                    loops: Animation.Infinite

                    OpacityAnimator {
                        target: rightIndicator.roundIcon ? rightIndicator.roundIconSource : rightIndicator.iconSource
                        from: 0
                        to: 1
                        duration: 500
                    }

                    OpacityAnimator {
                        target: rightIndicator.roundIcon ? rightIndicator.roundIconSource : rightIndicator.iconSource
                        from: 1
                        to: 0
                        duration: 500
                    }
                }
            }

            IconButton {
                id: seatBreak
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-right/mdi_seatbelt.svg") : root.assetUrl("icons/icons-right/mdi_seatbelt.svg")

                anchors {
                    left: rightIndicator.right
                    leftMargin: 15
                    verticalCenter: rightIndicator.verticalCenter
                    verticalCenterOffset: 42
                }
            }

            IconButton {
                id: breakParking
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-right/mdi_car-brake-parking.svg") : root.assetUrl("icons/icons-right/mdi_car-brake-parking.svg")

                anchors {
                    left: seatBreak.right
                    leftMargin: 12
                    verticalCenter: seatBreak.verticalCenter
                    verticalCenterOffset: 50
                }
            }

            IconButton {
                id: lightDimmed
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-right/mdi_car-light-dimmed.svg") : root.assetUrl("icons/icons-right/mdi_car-light-dimmed.svg")

                anchors {
                    left: breakParking.right
                    leftMargin: 6
                    verticalCenter: breakParking.verticalCenter
                    verticalCenterOffset: 51
                }
            }

            Image {
                id: leftGaugeFrame
                width: 800
                height: 800
                anchors.left: parent.left
                anchors.leftMargin: -18
                anchors.verticalCenterOffset: 100
                anchors.verticalCenter: parent.verticalCenter
                source: "Tacometer.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true

                CircularGaugeMeter {
                    id: leftGaugeMeter
                    width: 585
                    height: 585
                    anchors.centerIn: parent
                    value: root.rpm / 1000.0
                    shadowVisible: false
                    passedFillVisible: false
                    maximumValue: 8

                    Behavior on value {
                        NumberAnimation {
                            duration: 1000
                        }
                    }
                }

                Column {
                    id: leftGaugeReadout
                    y: 373
                    height: 300
                    anchors.horizontalCenterOffset: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 180

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 70
                        font.bold: true
                        font.weight: Font.DemiBold
                        font.family: "Venera"
                        color: "#F8FBFF"
                        text: leftGaugeMeter.value.toFixed(1)
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 30
                        font.bold: true
                        font.weight: Font.Medium
                        font.family: "Venera"
                        color: "#72D6FF"
                        text: "RPM x1000"
                    }
                }
            }

            Image {
                id: rightGaugeFrame
                x: 1144
                width: 800
                height: 800
                anchors.right: parent.right
                anchors.rightMargin: -24
                anchors.verticalCenterOffset: 100
                anchors.verticalCenter: parent.verticalCenter
                source: "Speedometer.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true

                CircularGaugeMeter {
                    id: rightGaugeMeter
                    width: 620
                    height: 620
                    anchors.centerIn: parent
                    value: root.speedKph
                    maximumValue: 220
                    shadowVisible: false
                    passedFillVisible: false

                    Behavior on value {
                        NumberAnimation {
                            duration: 1000
                        }
                    }
                    anchors.verticalCenterOffset: -10
                    anchors.horizontalCenterOffset: 0
                }

                Column {
                    id: rightGaugeReadout
                    y: 352
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 180
                    height: 307
                    anchors.horizontalCenterOffset: 0
                    bottomPadding: 0
                    spacing: 190

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 70
                        font.bold: true
                        font.weight: Font.DemiBold
                        font.family: "Venera"
                        color: "#F8FBFF"
                        text: root.speedKph.toFixed(0)
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 30
                        font.bold: true
                        font.weight: Font.Medium
                        font.family: "Venera"
                        color: "#72D6FF"
                        text: qsTr("KM/H")
                    }
                }
            }

            Image {
                id: leftLevelIcon
                source: "icons/feaul.svg"
                anchors.bottom: leftLevelBar.top
                anchors.left: leftLevelBar.left
                sourceSize: Qt.size(48, 48)
                anchors.bottomMargin: 5

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.leftSideLevel = root.leftSideLevel >= 0.95 ? 0.1 : Math.min(1.0, root.leftSideLevel + 0.15)
                    }
                }
            }

            Item {
                id: leftLevelBar
                y: 549
                anchors.left: leftGaugeFrame.left
                anchors.bottom: leftGaugeFrame.bottom
                anchors.leftMargin: 43
                anchors.bottomMargin: 51
                width: leftTrack.implicitWidth
                height: 400

                function updateLevel(localY) {
                    root.leftSideLevel = Math.max(0.0, Math.min(1.0, 1.0 - (localY / height)))
                }

                Item {
                    id: leftFillClip
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height * root.leftSideLevel
                    clip: true

                    Item {
                        width: leftLevelBar.width
                        height: leftLevelBar.height
                        anchors.bottom: parent.bottom

                        Rectangle {
                            id: leftFillGradient
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#e53935" }
                                GradientStop { position: 0.55; color: "#ffb300" }
                                GradientStop { position: 1.0; color: "#2ecc71" }
                            }
                        }

                        Image {
                            id: leftMaskImage
                            anchors.fill: parent
                            source: "icons/Vector 1.png"
                            visible: false
                        }

                        ShaderEffectSource {
                            id: leftFillSource
                            sourceItem: leftFillGradient
                            hideSource: true
                            live: true
                        }

                        ShaderEffectSource {
                            id: leftMaskSource
                            sourceItem: leftMaskImage
                            hideSource: true
                            live: false
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: leftFillSource
                            maskSource: leftMaskSource
                        }
                    }
                }

                Image {
                    id: leftTrack
                    anchors.fill: parent
                    source: "icons/Vector 1.png"
                    smooth: true
                    opacity: 0.24
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function(mouse) { leftLevelBar.updateLevel(mouse.y) }
                    onPositionChanged: function(mouse) {
                        if (pressed)
                            leftLevelBar.updateLevel(mouse.y)
                    }
                }
            }

            Image {
                id: rightLevelIcon
                source: "icons/desal.svg"
                anchors.bottom: rightLevelBar.top
                anchors.right: rightLevelBar.right
                sourceSize: Qt.size(48, 48)
                anchors.bottomMargin: 5

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.rightSideLevel = root.rightSideLevel >= 0.95 ? 0.1 : Math.min(1.0, root.rightSideLevel + 0.15)
                    }
                }
            }

            Item {
                id: rightLevelBar
                x: 1557
                y: 549
                anchors.right: rightGaugeFrame.right
                anchors.bottomMargin: 51
                anchors.bottom: rightGaugeFrame.bottom
                anchors.rightMargin: 45
                width: rightTrack.implicitWidth
                height: 400

                function updateLevel(localY) {
                    root.rightSideLevel = Math.max(0.0, Math.min(1.0, 1.0 - (localY / height)))
                }

                Item {
                    id: rightFillClip
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height * root.rightSideLevel
                    clip: true

                    Item {
                        width: rightLevelBar.width
                        height: rightLevelBar.height
                        anchors.bottom: parent.bottom

                        Rectangle {
                            id: rightFillGradient
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#2ecc71" }
                                GradientStop { position: 0.55; color: "#ffb300" }
                                GradientStop { position: 1.0; color: "#e53935" }
                            }
                        }

                        Image {
                            id: rightMaskImage
                            anchors.fill: parent
                            source: "icons/Vector 1.png"
                            mirror: true
                            visible: false
                        }

                        ShaderEffectSource {
                            id: rightFillSource
                            sourceItem: rightFillGradient
                            hideSource: true
                            live: true
                        }

                        ShaderEffectSource {
                            id: rightMaskSource
                            sourceItem: rightMaskImage
                            hideSource: true
                            live: false
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: rightFillSource
                            maskSource: rightMaskSource
                        }
                    }
                }

                Image {
                    id: rightTrack
                    anchors.fill: parent
                    source: "icons/Vector 1.png"
                    mirror: true
                    smooth: true
                    asynchronous: true
                    opacity: 0.24
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function(mouse) { rightLevelBar.updateLevel(mouse.y) }
                    onPositionChanged: function(mouse) {
                        if (pressed)
                            rightLevelBar.updateLevel(mouse.y)
                    }
                }
            }

            Image {
                y: 867
                width: 908
                height: 133
                sourceSize: Qt.size(topBar.width, topBar.height)
                source: "icons/bottom.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                RowLayout {
                    spacing: 60
                    anchors.right: middle.left
                    anchors.rightMargin: 60
                    anchors.verticalCenter: middle.verticalCenter

                    IconButton {
                        setIconSize: 32
                        implicitHeight: 45
                        implicitWidth: 45
                        checkable: true
                        iconBackground: "transparent"
                        setIconColor: checked ? "#777781" : "#777781"
                        text: "\uf3c5"
                        font.bold: Font.DemiBold
                        font.weight: Font.Normal
                        font.family: root.iconFontFamily
                        font.pixelSize: 32
                    }

                    IconButton {
                        setIconSize: 32
                        implicitHeight: 45
                        implicitWidth: 45
                        checkable: true
                        iconBackground: "transparent"
                        setIconColor: checked ? "#777781" : "#777781"
                        text: "\uf601"
                        font.bold: Font.DemiBold
                        font.weight: Font.Normal
                        font.pixelSize: 32
                        font.family: root.iconFontFamily
                    }
                }

                Row {
                    id: middle
                    anchors.centerIn: parent
                    spacing: 26

                    Repeater {
                        model: ["P", "R", "N", "D"]

                        delegate: Item {
                            width: 44
                            height: 62

                            Text {
                                id: gearLabel
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.bold: Font.DemiBold
                                font.weight: Font.Normal
                                font.pixelSize: 45
                                color: "#FFFFFF"
                                text: modelData
                                font.family: "Venera"
                                opacity: root.selectedGear === modelData ? 1.0 : 0.32

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 140
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            Rectangle {
                                id: gearIndicatorGlow
                                width: 30
                                height: 12
                                radius: 6
                                color: "#030ba4"
                                opacity: root.selectedGear === modelData ? 0.22 : 0.0
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 140
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            Rectangle {
                                width: 22
                                height: 5
                                radius: 2.5
                                color: "#030ba4"
                                opacity: root.selectedGear === modelData ? 1.0 : 0.0
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: gearIndicatorGlow.verticalCenter

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 140
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.selectedGear = modelData
                            }
                        }
                    }
                }

                RowLayout {
                    spacing: 60
                    anchors.left: middle.right
                    anchors.leftMargin: 60
                    anchors.verticalCenter: middle.verticalCenter

                    IconButton {
                        setIconSize: 32
                        implicitHeight: 45
                        implicitWidth: 45
                        checkable: true
                        iconBackground: "transparent"
                        setIconColor: checked ? "#777781" : "#777781"
                        font.bold: Font.DemiBold
                        font.weight: Font.Normal
                        font.pixelSize: 32
                        font.family: root.iconFontFamily
                        text: "\uf001"
                    }

                    IconButton {
                        setIconSize: 32
                        implicitHeight: 45
                        implicitWidth: 45
                        checkable: true
                        font.bold: Font.DemiBold
                        font.weight: Font.Normal
                        font.pixelSize: 32
                        font.family: root.iconFontFamily
                        iconBackground: "transparent"
                        setIconColor: checked ? "#777781" : "#777781"
                        text: "\uf1de"
                    }
                }
            }

            IconButton {
                id: lightHigh
                width: 65
                height: 65
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-right-checked/mdi_car-light-high.svg") : root.assetUrl("icons/icons-right/mdi_car-light-high.svg")

                anchors {
                    left: lightDimmed.right
                    leftMargin: 6
                    verticalCenter: lightDimmed.verticalCenter
                    verticalCenterOffset: 45
                }
            }

            IconButton {
                id: lightFog
                width: 65
                height: 65
                visible: true
                anchors.leftMargin: -6
                isGlow: false
                clip: false
                roundIcon: true
                iconWidth: 65
                iconHeight: 65
                checkable: true
                setIcon: checked ? root.assetUrl("icons/icons-right/mdi_car-light-fog.svg") : root.assetUrl("icons/icons-right/mdi_car-light-fog.svg")

                anchors {
                    left: lightHigh.right
                    verticalCenter: lightHigh.verticalCenter
                    verticalCenterOffset: 71
                }
            }
        }
    }

    Item {
        id: torqueRequestBar
        x: 345
        y: 111
        width: 334
        height: 50
        visible: opacity > 0
        opacity: root.contentVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }

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
        source: "images/Frame 50.png"
        fillMode: Image.PreserveAspectFit
        visible: opacity > 0
        opacity: root.contentVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }
    }

    Text {
        id: batteryPercentage
        y: 264
        width: 44
        height: 14
        visible: opacity > 0
        opacity: root.contentVisible ? 1 : 0
        color: "#72d6ff"
        text: root.batteryPercentageValue + "%"
        font.pixelSize: 13
        anchors.horizontalCenterOffset: 482
        font.weight: Font.DemiBold
        font.family: "Venera"
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }
    }

    Text {
        id: batteryTemp
        y: 264
        width: 55
        height: 14
        visible: opacity > 0
        opacity: root.contentVisible ? 1 : 0
        color: "#72d6ff"
        text: root.batteryTempValue + "°C"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        font.family: "Venera"
        font.bold: true
        anchors.horizontalCenterOffset: -476
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }
    }
}
