import QtQuick
import wavey.style
import wavey.components as WaveyComponents
import radioplayer.viewmodels
import radioplayer.components

Rectangle {
    id: root

    property RadioPlayerViewModelBase viewModel

    width: 1840
    height: 660

    color: WaveyStyle.backgroundColor
    radius: WaveyStyle.backgroundRadius

    QtObject {
       id: d

       property int activeCoverWidth
       property int coverRightMargin
       property int stationListLeftMargin
       property int delegateWidth
       property real coverOpacity
       property real scale
    }

    Image {
        source: "../assets/list_screen/ellipse.png"
        width: root.width
        height: 277
        anchors.top: root.top
        anchors.topMargin: -140
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 95
        }
        color: WaveyStyle.accentColor
        font {
            family: WaveyFonts.text_3.family
            weight: WaveyFonts.text_3.weight
            pixelSize: 40
        }

        text: "Radio stations"
    }

    WaveyComponents.PlaylistScroll {
        id: playlistScroll
        anchors {
            left: root.left
            leftMargin: 45
        }
        listHeight: stationList.height
        contentHeight: stationList.contentHeight
        contentY: stationList.contentY
        anchorParent: stationList
    }

    ListView {
        id: stationList
        anchors {
            left: playlistScroll.left
            leftMargin: d.stationListLeftMargin
            bottom: parent.bottom
            bottomMargin: 58
        }
        width: 1000
        height: 392
        spacing: 18
        clip: true
        highlightMoveDuration: 300
        currentIndex: root.viewModel.currentStation
        model: root.viewModel.stations
        delegate: Item {
            width: d.delegateWidth
            height: 64

            Text {
                id: number
                anchors.top: dataColumn.top
                color: WaveyStyle.primaryColor
                font: WaveyFonts.numbers
                text: {
                    const value = index + 1
                    return value < 10 ? '0' + value : value
                }
            }

            Column {
                id: dataColumn
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 28
                spacing: 6
                Text {
                    color: WaveyStyle.secondaryColor
                    font: WaveyFonts.h7
                    text: modelData.name
                }

                Row {
                    spacing: 18
                    Text {
                        color: WaveyStyle.primaryColor
                        font: WaveyFonts.subtitle_3
                        text: "Information"
                    }

                    Text {
                        color: WaveyStyle.primaryColor
                        font: WaveyFonts.subtitle_3
                        text: "News"
                    }

                    Text {
                        color: WaveyStyle.primaryColor
                        font: WaveyFonts.subtitle_3
                        text: String("%1 FM").arg(modelData.frequency)
                    }
                }
            }
        }

        highlight: WaveyComponents.ActiveDelegateMarker {
            width: d.delegateWidth
            isActive: root.viewModel.isPlaying
            markerSource: Qt.resolvedUrl("../assets/list_screen/active_marker.png")
        }
    }

    CoverBlur {
        anchors.centerIn: roundedCoverImage
        imageSource: root.viewModel.currentStationCover
        isPlaying: root.viewModel.isPlaying
        opacity: d.coverOpacity
        scale: d.scale
    }

    RoundedItem {
        id: roundedCoverImage
        anchors {
            verticalCenter: stationList.verticalCenter
            right: parent.right
            rightMargin: d.coverRightMargin
        }
        width: d.activeCoverWidth
        height: width
        radius: 6
        opacity: d.coverOpacity
        Image {
            anchors.fill: parent
            source: root.viewModel.currentStationCover
        }
    }

    DesaturationEffect {
        id: currentCoverDesaturationEffect
        anchors.fill: roundedCoverImage
        source: roundedCoverImage
        opacity: root.viewModel.isPlaying ? 0 : d.coverOpacity

        Behavior on opacity {
            NumberAnimation {}
        }
    }

    states: [
        State {
            name: "1840"
            when: root.width >= 1840
            PropertyChanges {
                target: d
                activeCoverWidth: 392
                coverRightMargin: 205
                stationListLeftMargin: 122
                delegateWidth: 700
                coverOpacity: 1
                scale: 1
            }
        },
        State {
            name: "1220"
            when: root.width < 1840 && root.width >= 1220
            PropertyChanges {
                target: d
                activeCoverWidth: 290
                coverRightMargin: 92
                stationListLeftMargin: 62
                delegateWidth: 560
                coverOpacity: 1
                scale: 0.85
            }
        },
        State {
            name: "910"
            when: root.width < 1220 && root.width >= 910
            PropertyChanges {
                target: d
                activeCoverWidth: 240
                coverRightMargin: 39
                stationListLeftMargin: 16
                delegateWidth: 448
                coverOpacity: 1
                scale: 0.85
            }
        },
        State {
            name: "600"
            when: root.width < 910
            PropertyChanges {
                target: d
                activeCoverWidth: 240
                coverRightMargin: 39
                stationListLeftMargin: 16
                delegateWidth: 491
                coverOpacity: 0
                scale: 0.85
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            target: d
            duration: 200
            properties: "activeCoverWidth, coverBottomMargin, coverRightMargin, stationListLeftMargin,
                         scale, delegateWidth, coverOpacity"
        }
    }
}
