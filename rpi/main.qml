import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "./Component"

Window {
    id:root
    width: 1024
    height: 600
    visible: true
    color: "#0B1118"
    title: qsTr("DashBoard")
    minimumWidth: 1024
    minimumHeight: 600
    maximumWidth: 1024
    maximumHeight: 600

    property alias fontLoader: dashboardFontLoader
    property real leftSideLevel: 0.28
    property real rightSideLevel: 0.34
    readonly property int designWidth: 1920
    readonly property int designHeight: 980
    readonly property real dashboardScale: Math.min(width / designWidth, height / designHeight)

    function assetUrl(path) {
        return Qt.resolvedUrl(path)
    }

    FontLoader
    {
        id: dashboardFontLoader
        source: "fontawesome.otf"
    }

    Shortcut{
        sequence:"Ctrl+E"
        onActivated: {
            leftGaugeMeter.forceActiveFocus()
        }
    }

    Image{
        id: panelImage
        //visible: false
        z:0
        sourceSize: Qt.size(width, height)
        anchors.centerIn: parent
        source: "Panel.png"
        readonly property real gaugeReadoutBaselineY: rightGaugeFrame.y + rightGaugeFrame.height * 0.86
        readonly property real gaugeFrameSize: height / 1.5
        readonly property real sideLevelBarHorizontalInset: 10
        readonly property real sideLevelBarBottomInset: 70
        width: root.designWidth
        height: root.designHeight
        scale: root.dashboardScale
        transformOrigin: Item.Center

        //Left Side
        IconButton{
            id:leftIndicator
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-left-checked/icon-park-solid_right-two.svg") : root.assetUrl("icons/icons-left/icon-park-solid_right-two.svg")
            anchors.right: topBar.left
            anchors.rightMargin: 40
            anchors.verticalCenter: topBar.verticalCenter
            SequentialAnimation {
                running: leftIndicator.checked
                loops: Animation.Infinite
                OpacityAnimator {
                    target: leftIndicator.roundIcon ? leftIndicator.roundIconSource : leftIndicator.iconSource
                    from: 0;
                    to: 1;
                    duration: 500
                }
                OpacityAnimator {
                    target: leftIndicator.roundIcon ? leftIndicator.roundIconSource : leftIndicator.iconSource
                    from: 1;
                    to: 0;
                    duration: 500
                }
            }
        }
        IconButton{
            id:handbreak
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-left/mdi_car-handbrake.svg") : root.assetUrl("icons/icons-left/mdi_car-handbrake.svg")
            anchors{
                right: leftIndicator.left
                rightMargin: 15
                verticalCenter: leftIndicator.verticalCenter
                verticalCenterOffset: 30
            }
        }
        IconButton{
            id:battery
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-left-checked/mdi_car-battery.svg") : root.assetUrl("icons/icons-left/mdi_car-battery.svg")
            anchors{
                right: handbreak.left
                rightMargin: 15
                verticalCenter: handbreak.verticalCenter
                verticalCenterOffset: 30
            }
            SequentialAnimation {
                running: battery.checked
                loops: Animation.Infinite
                OpacityAnimator {
                    target: battery.roundIcon ? battery.roundIconSource : battery.iconSource
                    from: 0;
                    to: 1;
                    duration: 500
                }
                OpacityAnimator {
                    target: battery.roundIcon ? battery.roundIconSource : battery.iconSource
                    from: 1;
                    to: 0;
                    duration: 500
                }
            }
        }
        IconButton{
            id:engineBold
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-left-checked/ph_engine-bold.svg") : root.assetUrl("icons/icons-left/ph_engine-bold.svg")
            anchors{
                right: battery.left
                rightMargin: 10
                verticalCenter: battery.verticalCenter
                verticalCenterOffset: 35
            }
            SequentialAnimation {
                running: engineBold.checked
                loops: Animation.Infinite
                OpacityAnimator {
                    target: engineBold.roundIcon ? engineBold.roundIconSource : engineBold.iconSource
                    from: 0;
                    to: 1;
                    duration: 500
                }
                OpacityAnimator {
                    target: engineBold.roundIcon ? engineBold.roundIconSource : engineBold.iconSource
                    from: 1;
                    to: 0;
                    duration: 500
                }
            }
        }
        IconButton{
            id:oil
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-left-checked/mdi_oil.svg") : root.assetUrl("icons/icons-left/mdi_oil.svg")
            anchors{
                right: engineBold.left
                rightMargin: 10
                verticalCenter: engineBold.verticalCenter
                verticalCenterOffset: 40
            }
            SequentialAnimation {
                running: oil.checked
                loops: Animation.Infinite
                OpacityAnimator {
                    target: oil.roundIcon ? oil.roundIconSource : oil.iconSource
                    from: 0;
                    to: 1;
                    duration: 500
                }
                OpacityAnimator {
                    target: oil.roundIcon ? oil.roundIconSource : oil.iconSource
                    from: 1;
                    to: 0;
                    duration: 500
                }
            }
        }
        IconButton{
            id:tireAlert
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-left/mdi_car-tire-alert.svg") : root.assetUrl("icons/icons-left/mdi_car-tire-alert.svg")
            anchors{
                right: oil.left
                verticalCenter: oil.verticalCenter
                verticalCenterOffset: 50
            }
        }

        Image{
            id:topBar
            source: "Top Bar.png"
            sourceSize: Qt.size(parent.width * 0.6,150)
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter


            RowLayout{
                anchors.left: parent.left
                anchors.leftMargin: 80
                anchors.verticalCenter: parent.verticalCenter
                spacing: 7
                Image{
                    source: "icons/cloud.svg"
                    sourceSize: Qt.size(24,24)
                }
                Label{
                    text: qsTr("12 °C")
                    font.pixelSize: 24
                    font.bold: true
                    font.weight: Font.Normal
                    color: "#FFFFFF"
                    font.family: "TacticSans-Med"
                }
            }

            Label{
                id:timeLabel
                text: new Date().toLocaleTimeString(Qt.locale(), "hh:mm AP")
                anchors.right: parent.right
                anchors.rightMargin: 80
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 24
                font.bold: true
                font.weight: Font.Normal
                font.family: "TacticSans-Med"
                color: "#FFFFFF"
            }

        }

        RowLayout {
            id: centerStatusIcons
            anchors.centerIn: parent
            spacing: 24
            z: 1

            Image {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                source: "icons/flash.svg"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Image {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                source: "icons/temp.svg"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }

        //Right Side
        IconButton{
            id:rightIndicator
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-right-checked/icon-park-solid_right-two.svg") : root.assetUrl("icons/icons-right/icon-park-solid_right-two.svg")
            anchors.left: topBar.right
            anchors.leftMargin: 40
            anchors.verticalCenter: topBar.verticalCenter
            SequentialAnimation {
                running: rightIndicator.checked
                loops: Animation.Infinite
                OpacityAnimator {
                    target: rightIndicator.roundIcon ? rightIndicator.roundIconSource : rightIndicator.iconSource
                    from: 0;
                    to: 1;
                    duration: 500
                }
                OpacityAnimator {
                    target: rightIndicator.roundIcon ? rightIndicator.roundIconSource : rightIndicator.iconSource
                    from: 1;
                    to: 0;
                    duration: 500
                }
            }
        }
        IconButton{
            id:seatBreak
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-right/mdi_seatbelt.svg") : root.assetUrl("icons/icons-right/mdi_seatbelt.svg")
            anchors{
                left: rightIndicator.right
                leftMargin: 15
                verticalCenter: rightIndicator.verticalCenter
                verticalCenterOffset: 30
            }
        }
        IconButton{
            id:breakParking
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-right/mdi_car-brake-parking.svg") : root.assetUrl("icons/icons-right/mdi_car-brake-parking.svg")
            anchors{
                left: seatBreak.right
                leftMargin: 15
                verticalCenter: seatBreak.verticalCenter
                verticalCenterOffset: 30
            }
        }
        IconButton{
            id:lightDimmed
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-right/mdi_car-light-dimmed.svg") : root.assetUrl("icons/icons-right/mdi_car-light-dimmed.svg")
            anchors{
                left: breakParking.right
                leftMargin: 10
                verticalCenter: breakParking.verticalCenter
                verticalCenterOffset: 35
            }
        }
        IconButton{
            id:lightHigh
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-right-checked/mdi_car-light-high.svg") : root.assetUrl("icons/icons-right/mdi_car-light-high.svg")
            anchors{
                left: lightDimmed.right
                leftMargin: 10
                verticalCenter: lightDimmed.verticalCenter
                verticalCenterOffset: 40
            }
        }
        IconButton{
            id:lightFog
            roundIcon: true
            iconWidth: 45
            iconHeight: 45
            checkable: true
            setIcon:checked ? root.assetUrl("icons/icons-right/mdi_car-light-fog.svg") : root.assetUrl("icons/icons-right/mdi_car-light-fog.svg")
            anchors{
                left: lightHigh.right
                verticalCenter: lightHigh.verticalCenter
                verticalCenterOffset: 50
            }
        }

        Image{
            id:leftGaugeFrame
            width: panelImage.gaugeFrameSize
            height: panelImage.gaugeFrameSize
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenterOffset: 50
            anchors.verticalCenter: parent.verticalCenter
            source: "Tacometer.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true

            CircularGaugeMeter {
                id:leftGaugeMeter
                property bool accelerating
                anchors.centerIn: parent
                width: parent.width * 0.79
                height: parent.height * 0.79
                value: accelerating ? maximumValue : 0
                shadowVisible: false
                passedFillVisible: false
                maximumValue: 8
                Component.onCompleted: forceActiveFocus()
                Behavior on value { NumberAnimation { duration: 1000 }}
                Keys.onSpacePressed:{
                    accelerating = true
                    rightGaugeMeter.accelerating = true
                }
                Keys.onReleased: function(event) {
                    if (event.key === Qt.Key_Space) {
                        accelerating = false;
                        event.accepted = true;
                        rightGaugeMeter.accelerating = false
                        event.accepted = true;
                    }
                }
            }

            Column {
                id: leftGaugeReadout
                anchors.horizontalCenter: parent.horizontalCenter
                y: panelImage.gaugeReadoutBaselineY - parent.y - height
                spacing: -4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 42
                    font.bold: true
                    font.weight: Font.DemiBold
                    font.family: "TacticSans-Blk"
                    color: "#F8FBFF"
                    text: leftGaugeMeter.value.toFixed(1)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 16
                    font.bold: true
                    font.weight: Font.Medium
                    font.family: "TacticSans-Med"
                    color: "#72D6FF"
                    text: "RPM x1000"
                }
            }
        }

        Image{
            id:rightGaugeFrame
            width: panelImage.gaugeFrameSize
            height: panelImage.gaugeFrameSize
            anchors.right: parent.right
            anchors.rightMargin: 60
            anchors.verticalCenterOffset: 50
            anchors.verticalCenter: parent.verticalCenter
            source: "Speedometer.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true

            CircularGaugeMeter {
                id:rightGaugeMeter
                anchors.centerIn: parent
                property bool accelerating
                width: parent.width * 0.85
                height: parent.height * 0.85
                value: accelerating ? maximumValue : 0
                maximumValue: 220
                shadowVisible: false
                passedFillVisible: false
                Behavior on value { NumberAnimation { duration: 1000 }}
            }
            Column {
                id: rightGaugeReadout
                anchors.horizontalCenter: parent.horizontalCenter
                y: panelImage.gaugeReadoutBaselineY - parent.y - height
                spacing: -4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 42
                    font.bold: true
                    font.weight: Font.DemiBold
                    font.family: "TacticSans-Blk"
                    color: "#F8FBFF"
                    text: rightGaugeMeter.value.toFixed(0)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 16
                    font.bold: true
                    font.weight: Font.Medium
                    font.family: "TacticSans-Med"
                    color: "#72D6FF"
                    text: "KM/H"
                }
            }
        }

        Image{
            id:leftLevelIcon
            source: "icons/feaul.svg"
            anchors.bottom: leftLevelBar.top
            anchors.left: leftLevelBar.left
            sourceSize: Qt.size(48,48)
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
            id:leftLevelBar
            anchors.left: leftGaugeFrame.left
            anchors.bottom: leftGaugeFrame.bottom
            anchors.leftMargin: panelImage.sideLevelBarHorizontalInset
            anchors.bottomMargin: panelImage.sideLevelBarBottomInset
            width: leftTrack.implicitWidth
            height: leftTrack.implicitHeight

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
                            GradientStop { position: 0.0; color: "#F3F6FA" }
                            GradientStop { position: 0.55; color: "#EBF1F6" }
                            GradientStop { position: 1.0; color: "#89C34A" }
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


        Image{
            id:rightLevelIcon
            source: "icons/desal.svg"
            anchors.bottom: rightLevelBar.top
            anchors.right: rightLevelBar.right
            sourceSize: Qt.size(48,48)
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
        Item{
            id:rightLevelBar
            anchors.right: rightGaugeFrame.right
            anchors.rightMargin: panelImage.sideLevelBarHorizontalInset
            anchors.bottom: rightGaugeFrame.bottom
            anchors.bottomMargin: panelImage.sideLevelBarBottomInset
            width: rightTrack.implicitWidth
            height: rightTrack.implicitHeight

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
                            GradientStop { position: 0.0; color: "#F3F6FA" }
                            GradientStop { position: 0.55; color: "#EBF1F6" }
                            GradientStop { position: 1.0; color: "#89C34A" }
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
                source:  "icons/Vector 1.png"
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

        Image{
            sourceSize: Qt.size(topBar.width,topBar.height)
            source: "icons/bottom.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            RowLayout{
                spacing: 60
                anchors.right: middle.left
                anchors.rightMargin: 60
                anchors.verticalCenter: middle.verticalCenter
                IconButton{
                    setIconSize:32
                    implicitHeight: 45
                    implicitWidth: 45
                    checkable: true
                    iconBackground: "transparent"
                    setIconColor :checked ? "#777781" : "#777781"
                    text: "\uf3c5"
                    font.bold: Font.DemiBold
                    font.weight: Font.Normal
                    font.family: dashboardFontLoader.name
                    font.pixelSize: 32
                    onCheckedChanged: {
                        if(checked){

                        }
                    }
                }

                IconButton{
                    setIconSize:32
                    implicitHeight: 45
                    implicitWidth: 45
                    checkable: true
                    iconBackground: "transparent"
                    setIconColor :checked ? "#777781" : "#777781"
                    text: "\uf601"
                    font.bold: Font.DemiBold
                    font.weight: Font.Normal
                    font.pixelSize: 32
                    font.family: dashboardFontLoader.name
                    onCheckedChanged: {
                        if(checked){

                        }
                    }
                }
            }

            RowLayout{
                id:middle
                anchors.centerIn: parent

                Text{
                    font.bold: Font.DemiBold
                    font.weight: Font.Normal
                    font.pixelSize: 45
                    color: "#FFFFFF"
                    font.family: "TacticSans-Med"
                    text: rightGaugeMeter.value.toFixed(0)
                }

                Text{
                    Layout.alignment: Qt.AlignVCenter
                    font.pixelSize: 24
                    color: "#FFFFFF"
                    font.family: "TacticSans-Med"
                    text: "Km/hr"
                }
            }

            RowLayout{
                spacing: 60
                anchors.left: middle.right
                anchors.leftMargin: 60
                anchors.verticalCenter: middle.verticalCenter
                IconButton{
                    setIconSize:32
                    implicitHeight: 45
                    implicitWidth: 45
                    checkable: true
                    iconBackground: "transparent"
                    setIconColor :checked ? "#777781" : "#777781"
                    font.bold: Font.DemiBold
                    font.weight: Font.Normal
                    font.pixelSize: 32
                    font.family: dashboardFontLoader.name
                    text: "\uf001"
                    onCheckedChanged: {
                        if(checked){

                        }
                    }
                }
                IconButton{
                    setIconSize:32
                    implicitHeight: 45
                    implicitWidth: 45
                    checkable: true
                    font.bold: Font.DemiBold
                    font.weight: Font.Normal
                    font.pixelSize: 32
                    font.family: dashboardFontLoader.name
                    iconBackground: "transparent"
                    setIconColor :checked ? "#777781" : "#777781"
                    text: "\uf1de"
                }
            }
        }
    }
}
