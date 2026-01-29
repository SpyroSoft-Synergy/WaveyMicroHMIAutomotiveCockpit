import QtQuick
import wavey.style

Rectangle {
    anchors.fill: parent
    color: WaveyStyle.backgroundColor

    Image {
        anchors.verticalCenter: parent.verticalCenter
        height: 30
        source: "../assets/icons/sundown.png"
        width: parent.width
    }
}
