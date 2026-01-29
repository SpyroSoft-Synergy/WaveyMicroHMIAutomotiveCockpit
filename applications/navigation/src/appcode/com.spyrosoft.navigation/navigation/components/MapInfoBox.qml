import QtQuick
import wavey.style

Item {
    id: root

    property alias text: textValue.text
    property alias icon: icon.source

    Rectangle {
        color: WaveyStyle.overlayColor
        radius: 6
        anchors.fill: root
        opacity: 0.3
    }

    Item {
        id: content

        anchors {
            fill: root
            topMargin: 12
            bottomMargin: 12
            leftMargin: 10
            rightMargin: 10
        }

        Text {
            id: textValue

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: WaveyStyle.secondaryColor
            font: WaveyFonts.m

            anchors {
                top: content.top
                horizontalCenter: content.horizontalCenter
            }

        }

        Image {
            id: icon

            width: content.width
            height: content.height - textValue.contentHeight - 5
            fillMode: Image.PreserveAspectFit

            anchors {
                bottom: content.bottom
                horizontalCenter: content.horizontalCenter
            }

        }

    }

}
