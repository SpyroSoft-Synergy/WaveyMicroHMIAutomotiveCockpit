import QtQuick
import wavey.style
import radioplayer.viewmodels

Item {
    id: root

    property RadioPlayerViewModelBase viewModel

    width: 670
    height: 70

    readonly property QtObject d: QtObject {
        id: d

        readonly property real startFrequency: 75
        readonly property real endFrequency: 115

        function frequencyIndicatorMargin(value) {
            return (value - d.startFrequency) / (d.endFrequency - d.startFrequency) * frequencyLine.width
        }
    }

    Image {
        id: frequencyLine
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width
        height: 26
        source: "../assets/playback_screen/line.png"
    }

    Repeater {
        anchors {
            top: frequencyLine.top
            left: frequencyLine.left
        }
        model: root.viewModel.stations
        delegate: Rectangle {
            id: stationFrequencyIndicator
            required property var model
            anchors {
                top: parent.top
                topMargin: 1
                left: parent.left
                leftMargin: d.frequencyIndicatorMargin(stationFrequencyIndicator.model.modelData.frequency)
            }
            width: currentStationFrequencyIndicator.width
            height: frequencyLine.paintedHeight * 0.97
            color: WaveyStyle.primaryColor
            radius: 1.5
            opacity: 0.4
        }
    }

    Rectangle {
        id: currentStationFrequencyIndicator

        anchors {
            verticalCenter: frequencyLine.verticalCenter
            verticalCenterOffset: 1
            left: frequencyLine.left
            leftMargin: d.frequencyIndicatorMargin(root.viewModel.currentStationFrequency)
        }

        height: 40
        width: 10
        radius: 5
        color: WaveyStyle.primaryColor
    }

    Row {
        id: frequencyValuesRow
        anchors {
            top: frequencyLine.bottom
            topMargin: 15
            left: frequencyLine.left
            leftMargin: frequencyValuesRow.spacing + 22
        }
        spacing: frequencyLine.width / (frquencyValuesRepeater.count + 2) - 25

        Repeater {
            id: frquencyValuesRepeater
            model: [80, 85, 90, 95, 100, 105, 110]
            delegate: Text {
                id: frequencyValueComponent
                width: 40
                required property var model
                horizontalAlignment: Text.AlignHCenter
                text: frequencyValueComponent.model.modelData
                color: WaveyStyle.primaryColor
                font: WaveyFonts.subtitle_3
            }
        }
    }
}
