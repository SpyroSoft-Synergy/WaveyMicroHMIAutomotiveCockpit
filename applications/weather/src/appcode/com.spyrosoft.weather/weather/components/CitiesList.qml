import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import Qt5Compat.GraphicalEffects
import wavey.style
import weather.viewmodels

Item {
    id: root
    signal addCityClicked
    signal returnButtonPressed

    required property var weather
    readonly property bool hasConnection : weather.serverData.bhasconnection

    anchors.horizontalCenter: parent.horizontalCenter
    height: parent.height
    width: parent.width

    Item {

        Image {
            id: returnImage
            height: sourceSize.width
            source: "../assets/icons/arrow_back.png"
            width: sourceSize.height
        }

        MouseArea {
            anchors.fill: returnImage

            onClicked: {
                returnButtonPressed();
            }
        }

        anchors {
            left: citiesPanel.left
            leftMargin: 50
            top: parent.top
            topMargin: 27
        }
    }

    CitiesPanel {
        id: citiesPanel
        height: parent.height - y
        weather: root.weather

        anchors {
            top: addCityButton.bottom
            topMargin: 40
        }
    }

    Item {
        id: addCityButton
        height: 30
        width: 135
        y: 35

        anchors {
            right: parent.right
        }

        RowLayout {
            spacing: 7

            anchors {
                right: parent.right
                rightMargin: 40
                verticalCenter: parent.verticalCenter
            }

            ColorImage {
                id: addImg
                source: "../assets/CitiesList/other/Add.png"
                color: WaveyStyle.secondaryColor
                opacity: 0.6
            }

            Label {
                id: addLabel

                text: "Add a city"
                renderType: Text.NativeRendering
                color: WaveyStyle.secondaryColor
                opacity: 0.6

                font {
                    family: WaveyFonts.rotary_counter.family
                    pixelSize: 38
                    weight: WaveyFonts.rotary_counter.weight
                }
            }
        }

        MouseArea {
            width: 200
            height: parent.height
            enabled: hasConnection
            anchors
            {
                right: addCityButton.right
                rightMargin: 40
            }

            onClicked: {
                addCityClicked();
            }
        }
    }

    Image {
        id: activeHundleBottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: sourceSize.height
        source: "../assets/background/ActiveHundleBottom.png"
        width: sourceSize.width
        y: 33
    }

    ParallelAnimation{
        id: disableAnimation

        NumberAnimation {
            targets: [addImg, addLabel]
            property: "opacity"
            duration: 1000
            from: !hasConnection ? 0.6 : 1
            to: !hasConnection ? 1 : 0.6
        }

        ColorAnimation {
            targets: [addImg, addLabel]
            property: "color"
            from: !hasConnection ? WaveyStyle.secondaryColor : WaveyStyle.accentColor
            to: !hasConnection ? WaveyStyle.accentColor : WaveyStyle.secondaryColor
            duration: 1000
        }
    }

    onHasConnectionChanged:
    {
        if(root.visible === false)
            if(!hasConnection)
                returnButtonPressed()
        disableAnimation.running = true
    }
}
