import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import wavey.style

Rectangle {
    id: root

    required property string cityName
    required property string countryName
    required property Item dragParent
    required property int labelIndex
    required property string temperature
    required property int visualIndex
    required property string weatherIcon

    signal pressed
    signal deleteButtonPressed(var index)

    Drag.active: dragDropArea.drag.active
    Drag.source: root
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    color: "transparent"
    height: selection.height
    width: selection.width

    states: [
        State {
            when: dragDropArea.drag.active

            ParentChange {
                parent: root.dragParent
                target: root
            }
            AnchorChanges {
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: undefined
                target: root
            }
        }
    ]

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true

        onExited: {
            if (!unHoverAnimation.running)
                unHoverAnimation.start();
        }
        onPressed: {
            if (!hoverAnimation.running)
                hoverAnimation.start();
        }
        onReleased: {
            if (!unHoverAnimation.running)
                unHoverAnimation.start();
        }
    }
    Item {
        id: hover
        opacity: 0

        NumberAnimation {
            id: hoverAnimation
            duration: 200
            from: 0
            properties: "opacity"
            targets: hover
            to: 1.0
        }
        NumberAnimation {
            id: unHoverAnimation
            duration: 200
            from: 1.0
            properties: "opacity"
            targets: hover
            to: 0
        }
        Image {
            id: selection
            source: "../assets/CitiesList/DragAndDrop/Selection.png"
        }
    }
    RowLayout {
        anchors {
            left: parent.left
            margins: 5
            verticalCenter: parent.verticalCenter
        }
        Item {
            height: dragAndDropImg.height
            width: dragAndDropImg.width

            Image {
                id: dragAndDropImg
                source: "../assets/CitiesList/DragAndDrop.png"

                MouseArea {
                    id: dragDropArea
                    anchors.fill: parent
                    drag.axis: Drag.YAxis
                    drag.target: root

                    onPressed: function () {
                        root.pressed();
                        hoverAnimation.start();
                    }
                    onReleased: function () {
                        root.Drag.drop();
                        unHoverAnimation.start();
                    }

                    drag.minimumY: 0.01
                    drag.maximumY: 270
                }
            }
        }
        Item {
            height: 80
            width: height

            Image {
                id: weatherImage
                height: 80
                source: `../assets/icons/${weatherIcon}.png`
                width: height
            }
        }
        ColumnLayout {
            spacing: 3

            Label {
                id: cityNameLabel
                color: WaveyStyle.secondaryColor
                text: root.cityName

                font {
                    family: WaveyFonts.rotary_counter.family
                    pixelSize: 38
                    weight: WaveyFonts.rotary_counter.weight
                }
            }
            Label {
                id: countryLabel
                color: WaveyStyle.secondaryColor
                opacity: 0.7
                text: root.countryName

                font {
                    family: WaveyFonts.text_6.family
                    pixelSize: 32
                    weight: WaveyFonts.text_6.weight
                }
            }
        }
    }
    RowLayout {
        id: rightRow
        anchors {
            margins: 5
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        Label {
            id: temperatureLabel
            color: WaveyStyle.secondaryColor
            text: `${root.temperature} °C`

            font {
                family: WaveyFonts.text_6.family
                pixelSize: 50
                weight: 600
            }
        }
        Item {
            height: width
            width: 48

            Image {
                id: deleteImage
                anchors.centerIn: parent
                source: "../assets/CitiesList/Vector.png"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        deleteButtonPressed(root.labelIndex)
                    }
                }
            }
        }
    }
}
