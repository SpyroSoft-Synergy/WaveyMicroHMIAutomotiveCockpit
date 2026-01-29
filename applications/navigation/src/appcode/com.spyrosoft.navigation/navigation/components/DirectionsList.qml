import QtQuick
import com.spyro_soft.wavey.navigation_iface
import wavey.style

Item {
    id: root

    property alias directions: listView.model
    readonly property real delegateHeight: 75

    height: Math.min(listView.count, 2) * delegateHeight

    ListView {
        id: listView

        anchors.fill: root
        clip: true

        delegate: Item {
            id: delegateRoot

            width: root.width
            height: delegateHeight

            Rectangle {
                color: WaveyStyle.overlayColor
                opacity: index > 1 ? 0 : (0.6 / (index + 1))
                anchors.fill: delegateRoot
                radius: 6
            }

            Image {
                id: icon

                width: height
                rotation: {
                    switch (modelData.direction) {
                    case Navigation_iface.Down:
                        return 180;
                    case Navigation_iface.Left:
                        return -90;
                    case Navigation_iface.Right:
                        return 90;
                    default:
                        return 0;
                    }
                }
                fillMode: Image.PreserveAspectFit
                source: Qt.resolvedUrl("./../assets/direction_arrow.png")

                anchors {
                    top: delegateRoot.top
                    bottom: delegateRoot.bottom
                    left: delegateRoot.left
                    margins: 16
                }

            }

            Text {
                id: distanceValue

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: WaveyStyle.secondaryColor
                font: WaveyFonts.h6
                text: modelData.distance.toFixed(0) + " m"

                anchors {
                    top: delegateRoot.top
                    left: icon.right
                    margins: 16
                }

            }

            Text {
                id: streetNameText

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: WaveyStyle.secondaryColor
                font: WaveyFonts.subtitle_3
                text: modelData.streetName

                anchors {
                    top: distanceValue.bottom
                    left: icon.right
                    leftMargin: 16
                }

            }

        }

    }

}
