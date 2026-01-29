import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import wavey.style

Item {
    id: root

    required property int hour
    required property int minutes

    property int listWidth
    property bool reversed: false
    property bool useLongLayout: false

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
        id: cityModelShort

        model: CityModel {}

        delegate: ColumnLayout {
            anchors.verticalCenter: parent.verticalCenter
            Label {
                id: cityName
                text: city
                color: WaveyStyle.secondaryColor
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font {
                    family: WaveyFonts.h7.family
                    pixelSize: 20
                    weight: WaveyFonts.h7.weight
                }
            }
            Label {
                id: timeOffset
                text: root.getTimeOffset(utcOffset)
                color: WaveyStyle.primaryColor
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font {
                    family: WaveyFonts.h7.family
                    pixelSize: 16
                    weight: WaveyFonts.h7.weight
                }
            }
            Label {
                id: time
                text: root.getTimeForOffset(utcOffset)
                color: WaveyStyle.secondaryColor
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font {
                    family: WaveyFonts.h7.family
                    pixelSize: 26
                    weight: WaveyFonts.h7.weight
                }
            }
        }
    }

    DelegateModel {
        id: cityModelLong

        model: CityModel {}

        delegate: RowLayout {
            height: 120
            width: 230
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                Label {
                    id: cityNameLong
                    text: city
                    color: WaveyStyle.secondaryColor
                    Layout.alignment: Qt.AlignHCenter
                    font {
                        family: WaveyFonts.h7.family
                        pixelSize: 20
                        weight: WaveyFonts.h7.weight
                    }
                }
                Label {
                    id: timeOffsetLong
                    text: root.getTimeOffset(utcOffset)
                    color: WaveyStyle.primaryColor
                    Layout.alignment: Qt.AlignHCenter
                    font {
                        family: WaveyFonts.h7.family
                        pixelSize: 16
                        weight: WaveyFonts.h7.weight
                    }
                }
            }
            Label {
                id: timeLong
                text: root.getTimeForOffset(utcOffset)
                color: WaveyStyle.secondaryColor
                Layout.alignment: Qt.AlignHCenter
                font {
                    family: WaveyFonts.h7.family
                    pixelSize: 26
                    weight: WaveyFonts.h7.weight
                }
            }
        }
    }

    ListView {
        id: citiesList
        anchors.centerIn: parent
        width: root.listWidth
        height: 120

        clip: true
        spacing: root.useLongLayout ? 50 : 40
        orientation: ListView.Horizontal

        model: root.useLongLayout ? cityModelLong : cityModelShort
        ScrollBar.horizontal: scrollBar
    }

    property ScrollBar horizontalScrollBar: scrollBar

    Item {
        id: scrollBarContainer
        anchors.top: root.reversed ? parent.top : citiesList.bottom
        anchors.bottom: root.reversed ? citiesList.top : parent.bottom
        width: root.width

        ScrollBar {
            id: scrollBar
            policy: ScrollBar.AlwaysOn
            width: parent.width - 80
            anchors.horizontalCenter: parent.horizontalCenter

            background: Rectangle {
                color: "#331AF3FF"
                height: 2
                radius: 2
            }

            contentItem: Rectangle {
                color: WaveyStyle.primaryColor
                implicitWidth: 100
                implicitHeight: 2
                radius: 2
            }
        }
        Component.onCompleted: root.registerScrollBar(horizontalScrollBar)
    }
}
