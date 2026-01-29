import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import wavey.style

Item {
    id: root

    property int defaultSpacing: 34
    property int defaultWidth: parent.width - 2 * defaultSpacing

    required property var citiesList
    required property var weather

    signal editButtonClicked

    function fixSpacingInList()
    {
        var amount = list.count
        if(amount > 5)
        {
            list.spacing = defaultSpacing
            return
        }

        var tileWidth = list.count > 0 ? list.itemAtIndex(0).width : 0

        if(amount <= 5)
        {
            var spacingNeed = amount + 1

            var spacingValue = (root.width - tileWidth*amount)/spacingNeed;
            list.width = root.width - spacingValue*2;
            list.spacing = spacingValue
        }
    }



    Component.onCompleted:
    {
        height = parent.height
        width = parent.width
    }

    Label {
        id: weatherLabel
        color: WaveyStyle.accentColor
        text: "Weather"

        font {
            family: WaveyFonts.text_3.family
            pixelSize: 38
            weight: WaveyFonts.text_3.weight
        }
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 40
        }
    }

    ListView {
        id: list
        height: 218
        orientation: ListView.Horizontal
        snapMode: ListView.SnapToItem
        spacing: defaultSpacing
        width: parent.width - 68

        model: citiesList
        delegate: WeatherDisplayTile {
            id: dummy
            cityName: modelData.city
            countryName: modelData.country
            temperature: modelData.temperature
            weatherIcon: modelData.icon
            bgImg.opacity: (weather.detailedWeather.country === modelData.country && weather.detailedWeather.city === modelData.city) ? 1 : 0

            onTileClicked:{
                weather.setMainCity(index)
            }
        }

        onCountChanged: {
            fixSpacingInList();
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: weatherLabel.bottom
            topMargin: 70
        }
    }

    Label {
        color: WaveyStyle.accentColor
        height: parent.height
        text: "Edit"

        font {
            family: WaveyFonts.text_3.family
            pixelSize: 38
        }
        anchors {
            right: parent.right
            rightMargin: 30
            top: list.bottom
            topMargin: 40
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                editButtonClicked();
            }
        }
    }
}
