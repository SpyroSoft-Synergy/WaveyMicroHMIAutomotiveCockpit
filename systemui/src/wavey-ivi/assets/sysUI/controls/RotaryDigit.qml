import QtQuick

Text {
    id: root

    property var model: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    property real value: 0

    clip: true
    text: " "
    width: column.width

    Behavior on value {
        SmoothedAnimation {
            duration: 600
            velocity: -1
        }
    }

    readonly property QtObject internal: QtObject {
        id: internal

        property real mod: ((root.value % root.model.length) + root.model.length) % root.model.length
    }

    Column {
        id: column

        y: -internal.mod * root.height

        Repeater {
            id: repeater

            model: root.model.concat(root.model[0])

            Text {
                color: root.color // qmllint disable
                font: root.font // qmllint disable
                text: modelData // qmllint disable
            }
        }
    }
}
