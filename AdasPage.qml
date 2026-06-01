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
        id: aDAS
        x: 330
        y: 29
        width: 351
        height: 553
        source: "images/ADAS.png"
        fillMode: Image.PreserveAspectFit
    }
}
