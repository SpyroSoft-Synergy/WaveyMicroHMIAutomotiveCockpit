import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import wavey.style
import wavey.components as WaveyComponents
import weather.viewmodels
import weather.components


Rectangle{
    id: root

    property var detailedWeather: root.viewModel.d.weather.detailedWeather
    property var briefWeather: root.viewModel.d.weather.briefWeather
    property int margin: 45
    property WeatherViewModelBase viewModel

    anchors.fill: parent
    color: WaveyStyle.backgroundColor
    radius: WaveyStyle.backgroundRadius

    Item {
        id: content
        anchors.fill: parent

        states: [
            State {
                name: "1840"
                when: root.width >= 1840

                PropertyChanges {
                    rightNowWidth: 820
                    target: d
                }
            },
            State {
                name: "1220"
                when: root.width < 1840 && root.width >= 1220

                PropertyChanges {
                    rightNowWidth: 820
                    target: d
                }
            },
            State {
                name: "910"
                when: root.width < 1220 && root.width >= 910

                PropertyChanges {
                    rightNowWidth: 820
                    target: d
                }
            },
            State {
                name: "600"
                when: root.width < 910

                PropertyChanges {
                    rightNowWidth: 510
                    target: d
                }
            }
        ]
        transitions: Transition {
            NumberAnimation {
                duration: 200
                property: "rightNowWidth"
                target: d
            }
        }

        QtObject {
            id: d

            property int rightNowWidth
        }
        RightNow {
            id: rightNow
            city: detailedWeather.city !== "" ? detailedWeather.city : "City"
            feelsLike: detailedWeather.feelslike
            height: 262
            icon: detailedWeather.icon !== "" ? detailedWeather.icon : "sun"
            sunrise: detailedWeather.sunrise !== "" ? detailedWeather.sunrise : "00:00"
            sunset: detailedWeather.sunset !== "" ? detailedWeather.sunset : "00:00"
            temperature: detailedWeather.temperature
            width: d.rightNowWidth
            x: (root.width - width) / 2
            y: 36
        }
        HourlyForecast {
            id: hourlyForecast
            anchors.top: rightNow.bottom
            height: 322
            model: detailedWeather.forecast !== [] ? detailedWeather.forecast : []
            width: root.width - 2 * x
            x: root.margin
        }
    }

    FastBlur{
        id: noContentBlur
        anchors.fill: content
        source: content
        radius:96
    }

    Label{
        id: noContentLabel
        anchors.centerIn: root
        font.pixelSize: 60
        text: "Please add city"
        renderType: Text.NativeRendering
        color: "white"
    }
    onBriefWeatherChanged: {
        if(briefWeather.length === 0){
            noContentBlur.visible = true
            noContentLabel.visible = true
        }
        else{
            noContentBlur.visible = false
            noContentLabel.visible = false
        }
    }
}



