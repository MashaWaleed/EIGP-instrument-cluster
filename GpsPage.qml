import QtQuick 2.15

Item {
    id: root

    anchors.fill: parent

    Item {
        id: contentArea
        width: Math.min(parent.width * 0.48, 540)
        height: Math.min(parent.height * 0.34, 230)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 72
    }

    Image {
        id: gPS
        x: 377
        y: 92
        width: 300
        height: 440
        source: "images/GPS.png"
        fillMode: Image.PreserveAspectFit
    }
}
