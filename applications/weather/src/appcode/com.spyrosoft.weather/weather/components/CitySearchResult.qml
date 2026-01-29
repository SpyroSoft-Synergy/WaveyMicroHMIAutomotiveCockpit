import QtQuick 2.5
import QtQuick.Layouts 1.3
import wavey.style

Item {
    property string cityName
    property string countryName
    property string regionName
    property string searchInput
    property bool bSaved
    property bool bIsRecent

    signal saveClicked

    height: 38
    width: 1000

    Component.onCompleted:
    {
        const texts = [country, region, city];
        const textSizes = [country.text.length, region.text.length, city.text.length];
        var sum = 0;

        for (const dd of texts)
        {
            sum += dd.text.length;
        }

        if (sum > 43)
        {
            const maxIndex = textSizes.indexOf(Math.max(...textSizes));

            var overflow = sum - 43
            texts[maxIndex].text = texts[maxIndex].text.slice(0, -overflow) + "...";
        }
    }

    Row {
        id: resultRow
        height: 48
        spacing: 10


        anchors.verticalCenter: parent.verticalCenter

        Text {
            color: WaveyStyle.accentColor
            font.pixelSize: 29
            text: index + 1
            anchors.verticalCenter: parent.verticalCenter
        }

        Image {
            source: "../assets/CitiesSearch/pin.png"
        }
    }

    Row
    {
        anchors {
            left: resultRow.right
            leftMargin: 10
            top: resultRow.top
            verticalCenter: parent.verticalCenter
        }

        Text {
            id: city
            color: WaveyStyle.secondaryColor
            text: `${cityName},`

            Component.onCompleted: {
                if(bIsRecent)
                    return;

                if (searchInput.length > 3) {
                    text = text.replace(searchInput, `<font color='${WaveyStyle.accentColor}'>${searchInput}</font>`);
                }
            }

            font {
                family: WaveyFonts.text_3.family
                pixelSize: 38
                weight: 500
            }
        }

        Text {
            id: region
            color: WaveyStyle.secondaryColor
            text: ` ${regionName}`

            Component.onCompleted: {
                text = text.length > 4 ? `${text},` : "";
            }

            font {
                family: WaveyFonts.text_3.family
                pixelSize: 38
                weight: WaveyFonts.text_3.weight
            }
        }

        Text {
            id: country
            color: WaveyStyle.secondaryColor
            text: ` ${countryName}`

            font {
                family: WaveyFonts.text_3.family
                pixelSize: 38
                weight: WaveyFonts.text_3.weight
            }
        }
    }


    MouseArea
    {
        visible: !bIsRecent
        height: parent.height
        width: 142
        enabled: !bSaved
        anchors
        {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }


        onClicked:
        {
            bSaved = true
            saveClicked()
        }


        Row
        {
            spacing: 14

            Image
            {
                anchors.verticalCenter: parent.verticalCenter
                source: bSaved ? "../assets/CitiesSearch/tick.png" : "../assets/CitiesList/other/Add.png"
            }

            Text
            {
                color: bSaved ? WaveyStyle.secondaryAccentColor : WaveyStyle.accentColor
                text: bSaved ? "Saved" : "Save"
                anchors.verticalCenter: parent.verticalCenter

                font {
                    family: WaveyFonts.text_3.family
                    pixelSize: 38
                    weight: WaveyFonts.text_3.weight
                }
            }
        }
    }
}
