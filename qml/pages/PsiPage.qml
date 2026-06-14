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
        id: pSI
        x: 265
        y: 60
        width: 496
        height: 465
        source: "../../assets/images/PSI.png"
        fillMode: Image.PreserveAspectFit
    }
}
