import QtQuick
import wavey.style

Item {
    id: root

    property bool isPlaying
    property string imageSource

    width: 900
    height: width

    ShaderEffectSource {
        id: coverBlurShaderSource
        width: root.width
        height: width

        RoundedItem {
            id: coverBlurRoundedMask
            width: root.width / 2
            height: width
            anchors.centerIn: parent
            radius: 180

            Image {
                id: coverBlurImage
                source: root.imageSource
                anchors.fill: parent
            }
        }
    }

    BlurEffect {
        id: blurEffect
        source: coverBlurShaderSource
        anchors.fill: coverBlurShaderSource
        opacity: root.isPlaying ? 0.35 : 0.0

        Behavior on opacity {
            NumberAnimation {}
        }
    }

    Image {
        id: grayedBlur
        source: "../assets/grayed_blur.png"
        anchors.fill: blurEffect
        opacity: root.isPlaying ? 0.0 : 1

        Behavior on opacity {
            NumberAnimation {}
        }
    }
}
