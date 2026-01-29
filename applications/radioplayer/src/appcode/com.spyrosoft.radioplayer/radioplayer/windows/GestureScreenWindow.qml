import QtQuick
import QtQuick.Controls
import wavey.style
import wavey.windows as WaveyWindows
import QtApplicationManager.Application
import radioplayer.viewmodels
import radioplayer.components

WaveyWindows.GestureScreenWindow {
    id: root

    property GestureScreenViewModel viewModel: GestureScreenViewModel{}

    Item {
        id: content
        clip: true
        anchors.fill: parent

        Text {
            anchors {
                top: parent.top
                topMargin: 80
                horizontalCenter: parent.horizontalCenter
            }

            text: "Radio"
            color: WaveyStyle.accentColor
            font {
                weight: WaveyFonts.h1.weight
                family: WaveyFonts.h1.family
                pixelSize: 38
            }
        }

        CoverBlur {
            width: 525
            anchors.centerIn: radioView
            imageSource: root.viewModel.currentStationCover
            isPlaying: root.viewModel.isPlaying
        }

        PathView {
            id: radioView

            readonly property int iconHeight: height
            readonly property int iconWidth: iconHeight

            anchors {
                top: parent.top
                topMargin: 200
                horizontalCenter: parent.horizontalCenter
            }

            width: 860
            height: 140
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            pathItemCount: 6
            model: root.viewModel.stations
            currentIndex: root.viewModel.currentStation

            delegate: RoundedItem {
                id: delegate
                height: radioView.iconHeight
                width: radioView.iconWidth
                radius: 6
                opacity: PathView.imageOpacity ? PathView.imageOpacity : 0.0
                Image {
                    anchors.fill: parent
                    source: modelData.coverUrl
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        opacity: delegate.PathView.isCurrentItem ? 1 : 0
                        border {
                            width: 3
                            color: WaveyStyle.accentColor
                        }
                        Behavior on opacity {
                            NumberAnimation { }
                        }
                    }

                    DesaturationEffect {
                        anchors.fill: parent
                        source: parent
                        opacity: root.viewModel.isPlaying ? 0 : 1

                        Behavior on opacity {
                            NumberAnimation {}
                        }
                    }

                    TapHandler {
                        onTapped: {
                            if (!radioView.moving) {
                                root.viewModel.setStation(index);
                            }
                        }
                    }
                }
            }

            path: Path {
                startX: -radioView.iconWidth * 0.5
                startY: radioView.height * 0.5
                PathAttribute {
                    name: "imageOpacity"
                    value: 0.0
                }
                PathLine {
                    relativeX: radioView.iconWidth
                    relativeY: 0
                }
                PathAttribute {
                    name: "imageOpacity"
                    value: 0.4
                }
                PathLine {
                    relativeX: radioView.iconWidth * 2
                    relativeY: 0
                }
                PathAttribute {
                    name: "imageOpacity"
                    value: 1.0
                }
                PathLine {
                    relativeX: radioView.iconWidth
                    relativeY: 0
                }
                PathAttribute {
                    name: "imageOpacity"
                    value: 1.0
                }
                PathLine {
                    relativeX: radioView.iconWidth * 2
                    relativeY: 0
                }
                PathAttribute {
                    name: "imageOpacity"
                    value: 0.4
                }
                PathLine {
                    relativeX: radioView.iconWidth
                    relativeY: 0
                }
            }
        }
    }
}
