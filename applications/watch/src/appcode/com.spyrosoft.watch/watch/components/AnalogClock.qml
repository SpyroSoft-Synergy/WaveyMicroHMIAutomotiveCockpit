import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import wavey.style

Item {
    id: root

    required property int hour
    required property int minutes
    required property int seconds


    QtObject {
        id: d
        property int numberSize
        property int hourMargins
        property int minuteHandHeight
        property int hourHandHeight
        property int handWidth
        property int centerPointSize
    }

    Image {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        source: "./../assets/AnalogClockGlow.png"
    }

    Label {
        id: twelveLabel
        text: "12"
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        font {
            family: WaveyFonts.h1.family
            pixelSize: d.numberSize
            weight: 700
        }
    }

    Label {
        id: threeLabel
        text: "3"
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right

        font {
            family: WaveyFonts.h1.family
            pixelSize: d.numberSize
            weight: 700
        }
    }

    Label {
        id: sixLabel
        text: "6"
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        font {
            family: WaveyFonts.h1.family
            pixelSize: d.numberSize
            weight: 700
        }
    }

    Label {
        id: nineLabel
        text: "9"
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        font {
            family: WaveyFonts.h1.family
            pixelSize: d.numberSize
            weight: 700
        }
    }

    Image {
        id: hourMarks
        anchors.fill: parent
        anchors.margins: d.hourMargins
        source: "./../assets/HourMarks.png"
    }

    Image {
        id: hourHand
        height: d.hourHandHeight
        width: d.handWidth
        x: root.height / 2 - hourHand.width / 2
        y: root.height / 2 - hourHand.height
        source: "./../assets/HourHand.png"
        transform: Rotation {
            origin.x: hourHand.width / 2
            origin.y: hourHand.height
            angle: 30.0 * (root.hour + root.minutes / 60.0)
        }
    }

    Image {
        id: minuteHand
        height: d.minuteHandHeight
        width: d.handWidth
        x: root.height / 2 - minuteHand.width / 2
        y: root.height / 2 - minuteHand.height + minuteHand.height / 13
        source: "./../assets/MinuteHand.png"
        transform: Rotation {
            origin.x: minuteHand.width / 2
            origin.y: minuteHand.height - minuteHand.height / 13
            angle: 6.0 * (root.minutes + root.seconds / 60.0)
        }
    }

    DropShadow {
        anchors.fill: minuteHand
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        color: "#80000000"
        source: minuteHand
        transform: Rotation {
            origin.x: minuteHand.width / 2
            origin.y: minuteHand.height - minuteHand.height / 13
            angle: 6.0 * (root.minutes + root.seconds / 60.0)
        }
    }

    Rectangle {
        id: blackPoint
        width: d.centerPointSize
        height: d.centerPointSize
        radius: d.centerPointSize
        anchors.centerIn: parent
        color: "black"
    }


    states: [
        State {
            name: "big"
            when: root.width >= 400
            PropertyChanges {
                target: d
                numberSize: 48
                hourMargins: 35
                minuteHandHeight: 130
                hourHandHeight: 80
                handWidth: 20
                centerPointSize: 12
            }
        },
        State {
            name: "medium"
            when: root.width >= 290
            PropertyChanges {
                target: d
                numberSize: 35
                hourMargins: 25
                minuteHandHeight: 105
                hourHandHeight: 60
                handWidth: 15
                centerPointSize: 8
            }
        },
        State {
            name: "small"
            when: root.width < 290
            PropertyChanges {
                target: d
                numberSize: 32
                hourMargins: 20
                minuteHandHeight: 85
                hourHandHeight: 58
                handWidth: 12
                centerPointSize: 6
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            target: d
            duration: 200
            properties: "numberSize, hourMargins, minuteHandHeight, hourHandHeight, handWidth"
        }
    }
}
