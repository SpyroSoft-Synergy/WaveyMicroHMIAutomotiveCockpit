import QtQuick
import mediaplayer.components

Item {
    id: root
    property string imageSource
    property bool isPlaying

    width: 900
    height: width

    ShaderEffectSource {
        id: coverBlurShaderSource
        width: root.width
        height: width

        RoundedItem {
            id: coverBlurRoundedMask
            width: 600
            height: width
            anchors.centerIn: parent
            radius: 180

            SwapableImage {
                id: coverBlurImage
                source: root.imageSource
                anchors.fill: parent
                imageWidth: coverBlurRoundedMask.width
                imageHeight: imageWidth
            }
        }
    }

    BlurEffect {
        id: blurEffect
        source: coverBlurShaderSource
        width: coverBlurShaderSource.width
        height: width
        anchors.centerIn: coverBlurShaderSource
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
