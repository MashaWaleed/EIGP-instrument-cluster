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
        id: tRIP
        x: 290
        y: 70
        width: 436
        height: 394
        source: "images/TRIP.png"
        fillMode: Image.PreserveAspectFit
    }
}
