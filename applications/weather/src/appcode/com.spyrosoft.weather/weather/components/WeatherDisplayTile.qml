import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import wavey.style

Item {
    property string cityName
    property string countryName
    property string temperature
    property string weatherIcon
    property alias weatherIconScale: weatherImageElement.scale
    property var citiesModel
    property alias bgImg: bgImg

    signal tileClicked()

    width: 175

    Component.onCompleted: {
        height = parent.height;

        const maxVal = 14

        const countryLenght = countryLabel.text.length
        if(countryLenght > maxVal)
        {
            var overflow = countryLenght - maxVal
            countryLabel.text = countryLabel.text.slice(0, -overflow) + "...";
        }

        const cityLenght = cityLabel.text.length
        if(cityLabel.text.length > maxVal)
        {
            overflow = maxVal - countryLenght
            cityLabel.text = cityLabel.text.slice(0, -overflow) + "...";
        }
    }


    Image{
        id: bgImg
        source: "../assets/background/WeatherDisplayTileBackground.png"
        width: parent.width
        height: parent.height
        opacity: 0

        Behavior on opacity {
            PropertyAnimation { duration: 150 }
        }
    }

    ColumnLayout {

        Item {
            height: 163
            width: parent.parent.width

            Item {
                id: weatherImageItem
                height: width
                width: 80

                anchors {
                    bottomMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }

                Image {
                    id: weatherImageElement
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: `../assets/icons/${weatherIcon}.png`
                }
            }

            Label {
                id: cityLabel
                anchors.top: weatherImageItem.bottom
                color: WaveyStyle.secondaryColor
                height: 42
                horizontalAlignment: Text.AlignHCenter
                text: cityName
                verticalAlignment: Text.AlignVCenter
                width: parent.width

                font {
                    family: WaveyFonts.text_3.family
                    pixelSize: 36
                    weight: WaveyFonts.text_3.weight
                }
            }

            Label {
                id: countryLabel
                anchors.top: cityLabel.bottom
                color: WaveyStyle.secondaryColor
                height: 33
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.7
                text: countryName
                verticalAlignment: Text.AlignVCenter
                width: parent.width
                elide: Text.ElideRight

                font {
                    family: WaveyFonts.text_6.family
                    pixelSize: 28
                    weight: WaveyFonts.text_6.weight
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            height: 45
            width: parent.width

            Label {
                id: temperatureLabel
                anchors.centerIn: parent
                color: WaveyStyle.secondaryColor
                renderType: Text.NativeRendering
                text: `${temperature} °C`

                font {
                    family: WaveyFonts.text_3.family
                    pixelSize: 38
                    weight: 500
                }
            }
        }
    }

    MouseArea{
        anchors.fill: parent

        onClicked:{
            tileClicked()
        }

    }
}
