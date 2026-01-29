import QtQuick
import mediaplayer.shaderEffects

RoundedItem {
    id: root
    property bool isCurrentlyPlaying

    radius: 30
    width: 700
    height: 64

    Image {
        id: marker
        source: "../assets/lists_screen/active_marker.png"

        DesaturationEffect {
            id: markerDesaturation
            source: marker
            anchors.fill: marker
            opacity: root.isCurrentlyPlaying ? 0.0 : 1.0

            Behavior on opacity {
                NumberAnimation {}
            }
        }
    }
}
