import QtQuick
import mediaplayer.shaderEffects

Item {
    id: root
    width: 392
    height: width
    property alias model: view.model
    property alias pathView: view
    property bool isPlaying
    property int coversDistance: 100
    property int currentCoverIndex: 0

    Component {
        id: coverDelegate
        RoundedItem {
            width: PathView.imageWidth
            height: PathView.imageWidth
            opacity: PathView.imageOpacity ? PathView.imageOpacity : 0.0
            z: PathView.imageZ ? PathView.imageZ : 0
            radius: 6
            Image {
                id: coverImage
                anchors.fill: parent
                source: modelData.coverUrl
                DesaturationEffect {
                    anchors.fill: coverImage
                    source: coverImage
                    opacity: root.isPlaying ? 0.0 : 1.0
                    Behavior on opacity {
                        NumberAnimation {}
                    }
                }
            }
        }
    }


    PathView {
        id: view
        anchors.centerIn: parent
        highlightMoveDuration: 400
        delegate: coverDelegate
        pathItemCount: 4
        path: Path {
            startX: -root.coversDistance
            PathAttribute {
                name: "imageWidth"
                value: 420
            }
            PathAttribute {
                name: "imageOpacity"
                value: 0.0
            }
            PathAttribute {
                name: "imageZ"
                value: 4
            }


            PathLine {
                relativeX: root.coversDistance
            }
            PathAttribute {
                name: "imageWidth"
                value: 392
            }
            PathAttribute {
                name: "imageOpacity"
                value: 1
            }
            PathAttribute {
                name: "imageZ"
                value: 3
            }

            PathLine {
               relativeX: root.coversDistance
            }
            PathAttribute {
                name: "imageWidth"
                value: 340
            }
            PathAttribute {
                name: "imageOpacity"
                value: 0.6
            }
            PathAttribute {
                name: "imageZ"
                value: 2
            }

            PathLine {
                relativeX: root.coversDistance
            }
            PathAttribute {
                name: "imageWidth"
                value: 280
            }
            PathAttribute {
                name: "imageOpacity"
                value: 0.3
            }
            PathAttribute {
                name: "imageZ"
                value: 1
            }

            PathLine {
                relativeX: root.coversDistance
            }
            PathAttribute {
                name: "imageWidth"
                value: 242
            }
            PathAttribute {
                name: "imageOpacity"
                value: 0.0
            }
            PathAttribute {
                name: "imageZ"
                value: 0
            }
        }
    }
}
