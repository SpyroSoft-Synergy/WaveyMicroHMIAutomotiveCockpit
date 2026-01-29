import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import wavey.style

Item {
    id: root

    required property int hour
    required property int minutes

    QtObject {
        id: d
        property int numberSize
        property int rowSpacing
        property int singleWidth
        property int singleHeight
    }

    function getPreviousHour() {
        if (root.hour == 0) {
            return "23"
        } else {
            return root.hour - 1
        }
    }

    function getMinutes() {
        return root.minutes.toString().padStart(2, "0")
    }

    function getPreviousMinutes() {
        if (root.minutes == 0) {
            return "59"
        } else {
            return (root.minutes - 1).toString().padStart(2, "0")
        }
    }

    Image {
        anchors.fill: root
        source: "./../assets/DigitalClockRectangleOuter.png"
    }

    Image {
        anchors.centerIn: root
        width: root.width - 25
        height: root.height - 25
        source: "./../assets/DigitalClockRectangleInner.png"
    }

    Row {
        anchors.centerIn: parent
        spacing: d.rowSpacing

        SingleFlipClock {
            width: d.singleWidth
            height: d.singleHeight
            currentNumber: root.hour
            prevNumber: root.getPreviousHour()
            numberSize: d.numberSize
        }
        SingleFlipClock {
            width: d.singleWidth
            height: d.singleHeight
            currentNumber: root.getMinutes()
            prevNumber: root.getPreviousMinutes()
            numberSize: d.numberSize
        }
    }

    states: [
        State {
            name: "650"
            when: root.width > 510
            PropertyChanges {
                target: d
                numberSize: 147
                rowSpacing: 40
                singleWidth: 240
                singleHeight: 215
            }
        },
        State {
            name: "510"
            when: root.width <= 510
            PropertyChanges {
                target: d
                numberSize: 115
                rowSpacing: 30
                singleWidth: 190
                singleHeight: 170
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            target: d
            duration: 200
            properties: "numberSize, rowSpacing, singleWidth, singleHeight"
        }
    }
}
