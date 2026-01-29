import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import wavey.style

Item {
    id: root

    required property int hour
    required property int minutes

    signal registerScrollBar(ScrollBar scrollBar)

    function getTimeOffset(offset) {
        let newHour = root.hour + offset
        let timeSuffix = ""
        let dayPrefix = ""

        if (offset < 0) {
            timeSuffix = `${offset}HR`
        } else {
            timeSuffix = `+${offset}HR`
        }

        if (newHour < 0) {
            dayPrefix = " (yesterday)"
        } else if (newHour > 23) {
            dayPrefix = " (tomorrow)"
        } else {
            dayPrefix = " (today)"
        }

        return `${timeSuffix}${dayPrefix}`
    }

    function getTimeForOffset(offset) {
        let newHour = root.hour + offset
        if (newHour < 0)
            newHour += 24
        if (newHour > 23)
            newHour -= 24

        return `${newHour}:${getMinutes()}`
    }

    function getMinutes() {
        return root.minutes.toString().padStart(2, "0")
    }

    DelegateModel {
        id: cityModel

        model: CityModel {}

        delegate: RowLayout {
            width: citiesList.width
            height: 56

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                Label {
                    id: cityName
                    text: city
                    color: WaveyStyle.secondaryColor
                    font {
                        family: WaveyFonts.h7.family
                        pixelSize: 24
                        weight: WaveyFonts.h7.weight
                    }
                }
                Label {
                    id: timeOffset
                    text: root.getTimeOffset(utcOffset)
                    color: WaveyStyle.primaryColor
                    font {
                        family: WaveyFonts.h7.family
                        pixelSize: 16
                        weight: WaveyFonts.h7.weight
                    }
                }
            }
            Label {
                id: time
                text: root.getTimeForOffset(utcOffset)
                color: WaveyStyle.secondaryColor

                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                font {
                    family: WaveyFonts.h7.family
                    pixelSize: 32
                    weight: WaveyFonts.h7.weight
                }
            }
        }
    }

    property ScrollBar verticalScrollBar: scrollBar

    ScrollBar {
        id: scrollBar
        anchors.left: root.left
        anchors.verticalCenter: root.verticalCenter
        height: 560
        active: true

        background: Rectangle {
            color: "#331AF3FF"
            radius: 2
        }

        contentItem: Rectangle {
            radius: 2
            implicitWidth: 2
            color: WaveyStyle.primaryColor
        }
    }

    ListView {
        id: citiesList
        anchors.left: scrollBar.left
        anchors.right: root.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
        anchors.verticalCenter: root.verticalCenter
        height: 560

        spacing: 44
        model: cityModel
        ScrollBar.vertical: scrollBar
    }

    Component.onCompleted: root.registerScrollBar(verticalScrollBar)
}
