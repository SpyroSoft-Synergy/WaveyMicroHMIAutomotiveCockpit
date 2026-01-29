import QtQuick

Item {
    id: root

    property url source: ""
    property int animationDuration: 150
    property alias imageWidth: image1.width
    property alias imageHeight: image1.height

    implicitHeight: image1.sourceSize.height
    implicitWidth: image1.sourceSize.width

    onSourceChanged: {
        if (image1.source === Qt.url("")) {
            image1.source = root.source
        } else {
            image2.source = root.source
            swapAnimation.start()
        }
    }

    Image {
        id: image1
        anchors.centerIn: root
    }

    Image {
        id: image2
        width: imageWidth
        height: imageHeight
        anchors.centerIn: root
        opacity: 0.0
    }

    SequentialAnimation {
        id: swapAnimation

        ParallelAnimation {
            PropertyAnimation {
                target: image1
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: root.animationDuration
            }

            PropertyAnimation {
                target: image2
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: root.animationDuration
            }
        }

        ScriptAction {
            script: {
                image1.source = root.source
                image2.source = ""
                image1.opacity = 1.0
                image2.opacity = 0.0
            }
        }
    }
}
