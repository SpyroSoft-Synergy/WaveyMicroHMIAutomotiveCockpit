import QtQuick
import wavey.style

TwoStateImageButton {
    id: root

    property string iconSource
    property string name
    property string address

    signal clicked(int index)

    isActive: ListView.isCurrentItem
    normalSource: "../assets/block.png"
    activeSource: "../assets/block_active.png"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked(model.index);
        }
    }

    Image {
        id: icon

        source: root.isActive ? root.iconSource + "_active.png" : root.iconSource + ".png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 32
    }

    Text {
        id: nameText

        text: root.name
        // TODO: Add to WaveyFonts
        font.family: WaveyFonts.h1.family
        font.pixelSize: 32
        font.weight: Font.Medium
        color: root.isActive ? WaveyStyle.primaryColor : WaveyStyle.accentColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: addressText.top
    }

    Text {
        id: addressText

        text: root.address
        // TODO: Add to WaveyFonts
        font.family: WaveyFonts.h1.family
        font.pixelSize: 26
        font.weight: Font.Light
        color: WaveyStyle.primaryColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48
    }

}
