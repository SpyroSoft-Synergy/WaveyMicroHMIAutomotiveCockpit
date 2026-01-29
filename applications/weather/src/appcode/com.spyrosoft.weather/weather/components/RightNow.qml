import QtQuick
import wavey.style

Item {
    required property string city
    required property int feelsLike
    required property string icon
    required property string sunrise
    required property string sunset
    required property int temperature

    Text {
        color: "#848091"
        text: "Right now"

        font {
            family: WaveyFonts.text_3.family
            pixelSize: WaveyFonts.text_3.pixelSize + 6
            weight: WaveyFonts.text_3.weight
        }
    }

    Item {
        id: currentWeather
        height: 143
        width: 405
        x: 40
        y: 46

        Row {
            spacing: 30

            Image {
                height: 140
                source: `../assets/icons/${icon}.png`
                width: height
            }

            Column {
                spacing: 0

                Text {
                    color: "white"
                    text: city

                    font {
                        family: WaveyFonts.text_3.family
                        pixelSize: WaveyFonts.text_3.pixelSize + 6
                        weight: WaveyFonts.text_3.weight
                    }
                }

                Text {
                    color: "white"
                    text: `${temperature} °C`

                    font {
                        family: WaveyFonts.h7.family
                        pixelSize: 80
                        weight: Font.ExtraBold
                    }
                }
            }
        }
    }

    Item {
        height: 60
        width: 190
        x: currentWeather.width + currentWeather.x + 125
        y: currentWeather.y

        Column {
            spacing: 15

            Text {
                color: WaveyStyle.primaryColor
                text: `feels like ${feelsLike} °C`

                font {
                    family: WaveyFonts.text_6.family
                    pixelSize: WaveyFonts.text_6.pixelSize
                    weight: WaveyFonts.text_6.weight
                }
            }

            Row {
                id: row
                height: 20
                spacing: 25

                SunTime {
                    height: parent.height
                    icon: "sunrise"
                    what: sunrise
                }

                SunTime {
                    height: parent.height
                    icon: "sunset"
                    what: sunset
                }
            }
        }
    }
}
