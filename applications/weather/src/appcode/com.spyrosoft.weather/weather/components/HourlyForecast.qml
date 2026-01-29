import QtQuick
import QtQuick.Controls
import wavey.style

ListView {
    id: hourlyForecast

    property ScrollBar scrollBar: ScrollBar {
        policy: ScrollBar.AlwaysOn

        background: Rectangle {
            color: "#193D58" // I think opacity is not working so just this, equivalent to WaveyStyle.primaryColor > opacity 0.25
            height: 5
            // opacity: 0.25
            radius: 5
            width: hourlyForecast.width
            y: 2
        }

        contentItem: Rectangle {
            color: WaveyStyle.primaryColor
            implicitHeight: 5
            implicitWidth: hourlyForecast.width
            radius: 5
        }

        anchors {
            bottom: hourlyForecast.bottom
            left: hourlyForecast.left
            right: hourlyForecast.right
        }
    }

    ScrollBar.horizontal: scrollBar
    model: modelData
    orientation: ListView.Horizontal
    spacing: 20

    delegate: Column {
        id: barColumn

        property int barHeight: 120

        height: 312
        spacing: 15
        width: 67

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            text: `${modelData.temperature} °C`

            font {
                family: WaveyFonts.text_3.family
                pixelSize: WaveyFonts.text_3.pixelSize
                weight: WaveyFonts.text_3.weight
            }
        }

        Loader {
            property int humidity: modelData.humidity

            height: barColumn.barHeight
            source: modelData.isSun ? "../components/SunMove.qml" : "../components/TemperatureBar.qml"
            width: barColumn.width
        }

        Rectangle {
            color: WaveyStyle.backgroundColor
            height: 16
            width: parent.width

            anchors {
                left: parent.left
                right: parent.right
            }

            Image {
                id: droplet
                height: width
                source: "../assets/icons/droplet.png"
                visible: modelData.humidity !== 0
                width: 16
                x: 10
            }

            Text {
                color: "#2480EB"
                text: modelData.humidity !== 0 ? `${modelData.humidity}%` : ""
                x: droplet.x + droplet.width

                font {
                    family: WaveyFonts.numbers.family
                    pixelSize: WaveyFonts.numbers.pixelSize
                    weight: WaveyFonts.numbers.weight
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            text: modelData.hour

            font {
                family: WaveyFonts.subtitle_3.family
                pixelSize: WaveyFonts.subtitle_3.pixelSize
                weight: WaveyFonts.subtitle_3.weight
            }
        }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            height: 30
            source: `../assets/icons/${modelData.icon}.png`
            width: 30
        }
    }

    Component.onCompleted: root.viewModel.scrollBar = scrollBar
}
