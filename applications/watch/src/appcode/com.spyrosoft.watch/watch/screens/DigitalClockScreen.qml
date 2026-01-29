import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import watch.components

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

    signal registerScrollBar(ScrollBar scrollBar)

    QtObject {
        id: d

        property int clockTopMargin
        property int clockWidth
        property int clockHeight
        property int cityListWidth
        property int blueGlowTopMargin
        property int blueGlowWidth
        property bool reversedCityList
    }

    Image {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: d.blueGlowTopMargin
        width: d.blueGlowWidth
        height: 260
        source: "./../assets/BlueGlow.png"
    }

    ColumnLayout {
        anchors.fill: parent

        FlipClock {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: d.clockTopMargin
            Layout.preferredWidth: d.clockWidth
            Layout.preferredHeight: d.clockHeight
            hour: root.hour + 1
            minutes: root.minutes
        }

        DateLabel {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.preferredWidth: 210
            Layout.preferredHeight: 92
            Layout.bottomMargin: 50
            city: root.city
            day: root.day
            month: root.month
            year: root.year
            dayOfTheWeek: root.dayOfTheWeek
            cityLabelSize: 52
            dateLabelSize: 20
        }

        CityListHorizontal {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.bottomMargin: 40
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            listWidth: d.cityListWidth
            hour: root.hour
            minutes: root.minutes
            onRegisterScrollBar: scrollBar => root.registerScrollBar(scrollBar)
            reversed: d.reversedCityList
        }
    }

    states: [
        State {
            name: "1840"
            when: root.width >= 1840
            PropertyChanges {
                target: d
                clockTopMargin: 60
                clockWidth: 650
                clockHeight: 290
                cityListWidth: 830
                blueGlowTopMargin: 245
                blueGlowWidth: 1440
                reversedCityList: false
            }
        },
        State {
            name: "1220"
            when: root.width < 1840 && root.width >= 1220
            PropertyChanges {
                target: d
                clockTopMargin: 60
                clockWidth: 650
                clockHeight: 290
                cityListWidth: 830
                blueGlowTopMargin: 245
                blueGlowWidth: 1220
                reversedCityList: false
            }
        },
        State {
            name: "910"
            when: root.width < 1220 && root.width >= 910
            PropertyChanges {
                target: d
                clockTopMargin: 60
                clockWidth: 650
                clockHeight: 290
                cityListWidth: 830
                blueGlowTopMargin: 245
                blueGlowWidth: 910
                reversedCityList: false
            }
        },
        State {
            name: "600"
            when: root.width < 910
            PropertyChanges {
                target: d
                clockTopMargin: 90
                clockWidth: 510
                clockHeight: 228
                cityListWidth: 510
                blueGlowTopMargin: 185
                blueGlowWidth: 600
                reversedCityList: true
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            target: d
            duration: 200
            properties: "clockTopMargin, clockWidth, clockHeight, cityListWidth, blueGlowTopMargin, blueGlowWidth, reversedCityList"
        }
    }
}
