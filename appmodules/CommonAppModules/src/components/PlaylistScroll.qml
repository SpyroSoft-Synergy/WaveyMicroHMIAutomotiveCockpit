import QtQuick
import QtQuick.Controls
import wavey.style

ScrollIndicator {
    id: root
    property int listHeight
    property int contentHeight
    property double contentY
    property var anchorParent

    active: true
    orientation: Qt.Vertical
    size: listHeight / contentHeight
    position: contentY / contentHeight

    anchors.top: anchorParent.top
    anchors.topMargin: -2
    anchors.bottom: anchorParent.bottom

    contentItem: Rectangle {
        implicitWidth: 2
        implicitHeight: 200
        color: WaveyStyle.primaryColor
        radius: 4
    }

    Rectangle {
        height: 390
        width: 2
        radius: 4
        color: WaveyStyle.primaryColor
        opacity: 0.25
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 2
    }
}
