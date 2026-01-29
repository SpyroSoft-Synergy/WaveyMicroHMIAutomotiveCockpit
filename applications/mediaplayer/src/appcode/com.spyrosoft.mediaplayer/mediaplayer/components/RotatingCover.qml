import QtQuick
import mediaplayer.shaderEffects

RoundedItem {
    id: root
    property int rotationAngle
    property bool isCoverMirrored: true
    property alias coverSource: currentSongCover.source
    property var animation

    width: 320
    height: width
    radius: 6
    layer.textureMirroring: ShaderEffectSource.MirrorVertically | (isCoverMirrored ?
                            ShaderEffectSource.MirrorHorizontally : ShaderEffectSource.NoMirroring)
    transform: Rotation {
        origin.x: 160
        origin.y: 160
        axis {
            x: 0
            y: 1
            z: 0
        }
        angle: root.rotationAngle
    }

    SwapableImage {
        id: currentSongCover
        anchors.fill: parent
        imageWidth: root.width
        imageHeight: imageWidth
        animationDuration: 300
        onSourceChanged: animation.start()
    }
}
