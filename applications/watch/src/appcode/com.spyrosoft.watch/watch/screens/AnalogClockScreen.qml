import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import watch.components
import wavey.style

Item {
    id: root

    property string city: "Szczecin"
    property int hour: 0
    property int minutes: 0
    property int seconds: 0
    property int day: 0
    property string month: ""
    property int year: 0
    property string dayOfTheWeek: ""

    signal registerHorizontalScrollBar(ScrollBar scrollBar)
    signal registerVerticalScrollBar(ScrollBar scrollBar)

    function getMinutes() {
        return root.minutes.toString().padStart(2, "0")
    }

    QtObject {
        id: d

        property int analogClockLayoutWidth
        property int analogClockLayoutHeight
        property int analogClockWidth
        property bool analogClockVertical
        property int cityListWidth
        property int timeLabelFontSize
        property int cityLabelSize
        property int dateLabelSize
        property bool useHorizontalDateLabel
        property int verticalClockSpacing
        property int clockTopMargin
        property int clockBottomMargin
        property bool useVerticalList
    }

    Loader {
        id: loader
        width: d.analogClockLayoutWidth
        height: d.analogClockLayoutHeight

        anchors.topMargin: d.clockTopMargin
        anchors.bottomMargin: d.clockBottomMargin
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        Component {
            id: horizontalAnalogClock

            RowLayout {
                spacing: 80
                height: parent.height

                AnalogClock {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.preferredWidth: d.analogClockWidth
                    Layout.preferredHeight: d.analogClockWidth
                    hour: root.hour + 1
                    minutes: root.minutes
                    seconds: root.seconds
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.preferredWidth: 400
                    Layout.bottomMargin: 50
                    spacing: 60

                    Label {
                        id: timeLabel
                        text: `${root.hour + 1}:${root.getMinutes()}`
                        color: WaveyStyle.secondaryColor
                        Layout.alignment: Qt.AlignHCenter

                        font {
                            family: WaveyFonts.h4.family
                            pixelSize: d.timeLabelFontSize
                            weight: 900
                        }
                    }
                    DateLabel {
                        Layout.alignment: Qt.AlignHCenter
                        city: root.city
                        day: root.day
                        month: root.month
                        year: root.year
                        dayOfTheWeek: root.dayOfTheWeek
                        cityLabelSize: 55
                        dateLabelSize: 28
                    }
                }
            }
        }
        Component {
            id: verticalAnalogClock

            ColumnLayout {
                spacing: d.verticalClockSpacing
                AnalogClock {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    Layout.preferredWidth: d.analogClockWidth
                    Layout.preferredHeight: d.analogClockWidth
                    hour: root.hour + 1
                    minutes: root.minutes
                    seconds: root.seconds
                }
                Label {
                    id: timeLabel
                    text: `${root.hour + 1}:${root.getMinutes()}`
                    color: WaveyStyle.secondaryColor
                    Layout.alignment: Qt.AlignHCenter

                    font {
                        family: WaveyFonts.h4.family
                        pixelSize: d.timeLabelFontSize
                        weight: 900
                    }
                }
                DateLabel {
                    Layout.alignment: Qt.AlignHCenter
                    city: root.city
                    day: root.day
                    month: root.month
                    year: root.year
                    dayOfTheWeek: root.dayOfTheWeek
                    cityLabelSize: d.cityLabelSize
                    dateLabelSize: d.dateLabelSize
                    horizontal: d.useHorizontalDateLabel
                }
            }
        }
        sourceComponent: d.analogClockVertical ? verticalAnalogClock : horizontalAnalogClock
    }

    Loader {
        anchors.top: d.useVerticalList ? parent.top : loader.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: d.useVerticalList ? 0 : 100
        anchors.bottomMargin: d.useVerticalList ? 0 : 10
        width: d.useVerticalList ? d.cityListWidth : root.width

        Component {
            id: horizontalList
            CityListHorizontal {
                anchors.horizontalCenter: parent.horizontalCenter
                width: root.width - 80
                height: 100
                listWidth: root.width - 80
                hour: root.hour
                minutes: root.minutes
                onRegisterScrollBar: scrollBar => root.registerHorizontalScrollBar(scrollBar)
                reversed: true
                useLongLayout: true
            }
        }
        Component {
            id: verticalList
            CityListVertical {
                width: d.cityListWidth
                height: root.height
                hour: root.hour
                minutes: root.minutes
                onRegisterScrollBar: scrollBar => root.registerVerticalScrollBar(scrollBar)
            }
        }
        sourceComponent: d.useVerticalList ? verticalList : horizontalList
    }

    states: [
        State {
            name: "1840"
            when: root.width >= 1840
            PropertyChanges {
                target: d
                analogClockLayoutWidth: root.width * 2 / 3
                analogClockLayoutHeight: root.height
                clockTopMargin: 0
                clockBottomMargin: 0
                analogClockVertical: false
                analogClockWidth: 400
                cityListWidth: root.width * 1 / 3
                timeLabelFontSize: 126
                cityLabelSize: 55
                dateLabelSize: 28
                useHorizontalDateLabel: false
                verticalClockSpacing: 40
                useVerticalList: true
            }
        },
        State {
            name: "1220"
            when: root.width < 1840 && root.width >= 1220
            PropertyChanges {
                target: d
                analogClockLayoutWidth: root.width / 2
                analogClockLayoutHeight: root.height
                clockTopMargin: 50
                clockBottomMargin: 150
                analogClockVertical: true
                analogClockWidth: 290
                cityListWidth: root.width / 2
                timeLabelFontSize: 90
                cityLabelSize: 40
                dateLabelSize: 20
                useHorizontalDateLabel: false
                verticalClockSpacing: 40
                useVerticalList: true
            }
        },
        State {
            name: "910"
            when: root.width < 1220 && root.width >= 910
            PropertyChanges {
                target: d
                analogClockLayoutWidth: root.width / 2
                analogClockLayoutHeight: root.height
                clockTopMargin: 50
                clockBottomMargin: 150
                analogClockVertical: true
                analogClockWidth: 290
                cityListWidth: root.width / 2
                timeLabelFontSize: 90
                cityLabelSize: 40
                dateLabelSize: 20
                useHorizontalDateLabel: false
                verticalClockSpacing: 40
                useVerticalList: true
            }
        },
        State {
            name: "600"
            when: root.width < 910
            PropertyChanges {
                target: d
                analogClockLayoutWidth: root.width
                analogClockLayoutHeight: root.height - 150
                clockTopMargin: 50
                clockBottomMargin: 200
                analogClockVertical: true
                analogClockWidth: 260
                cityListWidth: root.width / 2
                timeLabelFontSize: 80
                cityLabelSize: 40
                dateLabelSize: 20
                useHorizontalDateLabel: true
                verticalClockSpacing: 20
                useVerticalList: false
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            target: d
            duration: 200
            properties: "analogClockLayoutWidth, analogClockLayoutHeight, analogClockWidth, cityListWidth, timeLabelFontSize, cityLabelSize, dateLabelSize, useHorizontalDateLabel, verticalClockSpacing, clockTopMargin, clockBottomMargin, useVerticalList"
        }
    }
}
