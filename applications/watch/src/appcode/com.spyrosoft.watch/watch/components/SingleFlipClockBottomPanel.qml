import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import wavey.style

Item {
    id: root
    required property string number

    property int fullHeight
    property int numberSize

    Rectangle {
        anchors.fill: root
        color: WaveyStyle.backgroundColor
    }

    Image {
        anchors.bottom: root.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.Stretch
        width: root.width
        height: root.fullHeight
        source: "./../assets/FlipCardGlow.png"
    }

    Label {
        text: root.number
        color: WaveyStyle.secondaryColor
        height: root.fullHeight
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: WaveyFonts.h1.family
            pixelSize: root.numberSize
            weight: 700
        }
    }
}
