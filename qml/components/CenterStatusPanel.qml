import QtQuick 2.15

Item {
    id: root

    property real currentAmps: 0
    property real temperatureC: 24
    property string fontFamily: ""
    property color valueColor: "#FFFFFF"
    property color dividerColor: "#d1ffffff"
    property int iconSize: 64
    property int dividerThickness: 4

    width: 340
    height: 220

    Image {
        id: flashIcon
        width: root.iconSize
        height: root.iconSize
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 8
        anchors.topMargin: 23
        source: "../../assets/icons/flash.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Image {
        id: tempIcon
        y: 134
        width: root.iconSize
        height: root.iconSize
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 8
        anchors.bottomMargin: 22
        source: "../../assets/icons/temp.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Rectangle {
        id: verticalDivider
        width: root.dividerThickness
        height: parent.height - 20
        anchors.left: flashIcon.right
        anchors.leftMargin: 26
        anchors.verticalCenter: parent.verticalCenter
        radius: width / 2
        color: root.dividerColor
    }

    Rectangle {
        id: horizontalDivider
        width: 220
        height: root.dividerThickness
        anchors.left: verticalDivider.horizontalCenter
        anchors.leftMargin: -width * 0.08
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color: root.dividerColor
        opacity: 0.9
    }

    Text {
        id: currentValueLabel
        y: 40
        anchors.left: verticalDivider.right
        anchors.leftMargin: 68
        anchors.bottom: horizontalDivider.top
        anchors.bottomMargin: 38
        color: root.valueColor
        font.pixelSize: 24
        font.weight: Font.Normal
        font.family: root.fontFamily
        font.bold: true
        text: Math.round(root.currentAmps) + " A"
    }

    Text {
        id: temperatureValueLabel
        anchors.left: verticalDivider.right
        anchors.leftMargin: 54
        anchors.top: horizontalDivider.bottom
        anchors.topMargin: 39
        color: root.valueColor
        font.pixelSize: 24
        font.weight: Font.Normal
        font.family: root.fontFamily
        font.bold: true
        text: Math.round(root.temperatureC) + " °C"
    }
}
