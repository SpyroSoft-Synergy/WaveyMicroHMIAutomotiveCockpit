import QtQuick
import wavey.style

RoundedItem {
    id: root
    property bool isActive
    property string markerSource

    radius: 30
    width: 700
    height: 64

    Image {
        id: marker
        source: root.markerSource

        DesaturationEffect {
            id: markerDesaturation
            source: marker
            anchors.fill: marker
            opacity: root.isActive ? 0.0 : 1.0

            Behavior on opacity {
                NumberAnimation {}
            }
        }
    }
}
