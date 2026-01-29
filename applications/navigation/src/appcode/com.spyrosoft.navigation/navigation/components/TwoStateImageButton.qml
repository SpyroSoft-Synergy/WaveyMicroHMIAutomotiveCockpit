import QtQuick

Item {
    id: root

    property bool isActive: false
    property alias normalSource: normalImage.source
    property alias activeSource: activeImage.source

    width: normalImage.width
    height: normalImage.height

    default property alias content: contentArea.children

    Image {
        id: normalImage
    }

    Image {
        id: activeImage
    }

    Item {
        id: contentArea

        anchors.fill: parent
    }

    states: [
        State {
            when: root.isActive

            PropertyChanges {
                target: normalImage
                opacity: 0
            }

            PropertyChanges {
                target: activeImage
                opacity: 1
            }

        },
        State {
            when: !root.isActive

            PropertyChanges {
                target: normalImage
                opacity: 1
            }

            PropertyChanges {
                target: activeImage
                opacity: 0
            }

        }
    ]

    transitions: Transition {
        PropertyAnimation {
            properties: "opacity"
        }

    }

}
