import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import wavey.style

Item {
    id: root
    required property string prevNumber
    required property string currentNumber
    property int numberSize

    Behavior on currentNumber {
        NumberAnimation {
            target: rotation
            property: "angle"
            duration: 500
            running: true
            loops: 1
            from: 0
            to: 180
        }
    }

    SingleFlipClockTopPanel {
        anchors.top: parent.top
        clip: true
        width: root.width
        height: root.height / 2 - 2
        fullHeight: root.height
        numberSize: root.numberSize
        number: root.currentNumber
    }

    SingleFlipClockBottomPanel {
        anchors.bottom: parent.bottom
        clip: true
        width: root.width
        height: root.height / 2 - 2
        fullHeight: root.height
        numberSize: root.numberSize
        number: root.prevNumber
    }

    Flipable {
        id: flipPart
        width: root.width
        height: root.height / 2 - 2
        anchors.top: parent.top

        front: SingleFlipClockTopPanel {
            anchors.top: parent.top
            clip: true
            width: root.width
            height: root.height / 2 - 2
            fullHeight: root.height
            numberSize: root.numberSize
            number: root.prevNumber
        }

        back: SingleFlipClockBottomPanel {
            anchors.bottom: parent.bottom
            clip: true
            width: root.width
            height: root.height / 2 - 2
            fullHeight: root.height
            numberSize: root.numberSize
            number: root.currentNumber
        }

        transform: Rotation {
            id: rotation
            origin.y: root.height / 2
            origin.x: root.width / 2
            axis.x: 1
            axis.y: 0
            axis.z: 0
            angle: 0
        }
    }
}
