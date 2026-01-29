import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import wavey.style
import wavey.components as WaveyComponents
import weather.viewmodels

Item {
    id: root
    scale: 0.7

    property var clusterWeather
    property var briefWeather

    anchors.fill: parent
    Item{
        id: content
        anchors.fill: parent
        Item {
            id: clusterImageItem
            height: 200
            width: height
            anchors.horizontalCenter: parent.horizontalCenter
            y: 100

            Image {
                id: clusterImage
                anchors.fill: parent
                source: `../assets/icons/${clusterWeather.icon}.png`
            }
        }
        RowLayout {
            anchors.top: clusterImageItem.bottom
            width: clusterImageItem.width
            id: firstRow

            Item {
                height: 50
                width: 250

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        color: WaveyStyle.secondaryColor
                        font: WaveyFonts.text_3
                        text: "Cloudiness"
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        color: WaveyStyle.secondaryColor
                        font: WaveyFonts.text_6
                        text: clusterWeather.cloudiness
                    }
                }
            }
            Item {
                height: 50
                width: 250

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        color: WaveyStyle.secondaryColor
                        font: WaveyFonts.text_3
                        text: "Wind"
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        color: WaveyStyle.secondaryColor
                        font: WaveyFonts.text_6
                        text: clusterWeather.windstrength
                    }
                }
            }
        }

        RowLayout {
            anchors
            {
                top: firstRow.bottom
                topMargin: 35
            }

            width: clusterImageItem.width

            Item {
                height: 50
                width: 250

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: WaveyStyle.secondaryColor
                        font: WaveyFonts.text_3
                        text: "Humidity"
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        color: WaveyStyle.secondaryColor
                        font: WaveyFonts.text_6
                        text: `${clusterWeather.humidity} %`
                    }
                }
            }
            Item {
                height: 50
                width: 250

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: WaveyStyle.secondaryColor
                        font: WaveyFonts.text_3
                        text: "Visibility"
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        color: WaveyStyle.secondaryColor
                        font: WaveyFonts.text_6
                        text: `${clusterWeather.visiblekm} km`
                    }
                }
            }
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
        if(briefWeather.length == 0){
            noContentBlur.visible = true
            noContentLabel.visible = true
        }
        else{
            noContentBlur.visible = false
            noContentLabel.visible = false
        }
    }
}
