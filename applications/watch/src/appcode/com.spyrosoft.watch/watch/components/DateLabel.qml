import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import wavey.style

Item {
    id: root

    required property string city
    required property int day
    required property string month
    required property int year
    required property string dayOfTheWeek
    required property int cityLabelSize
    required property int dateLabelSize
    property bool horizontal: false

    Loader {
        anchors.centerIn: parent
        Component {
            id: vertical
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Label {
                    id: cityLabel
                    text: root.city
                    color: WaveyStyle.secondaryColor
                    Layout.alignment: Qt.AlignHCenter

                    font {
                        family: WaveyFonts.h4.family
                        pixelSize: root.cityLabelSize
                        weight: 500
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter

                    Label {
                        id: dateLabel
                        text: `${root.day} ${root.month} ${root.year}`
                        color: WaveyStyle.secondaryColor

                        font {
                            family: WaveyFonts.text_3.family
                            pixelSize: root.dateLabelSize
                            weight: WaveyFonts.text_3.weight
                        }
                    }
                    Label {
                        id: dayOfTheWeekLabel
                        text: ` ${root.dayOfTheWeek}`
                        color: WaveyStyle.primaryColor

                        font {
                            family: WaveyFonts.h1.family
                            pixelSize: root.dateLabelSize
                            weight: 200
                        }
                    }
                }
            }
        }
        Component {
            id: horizontal
            RowLayout {
                Label {
                    id: cityLabel
                    text: root.city
                    color: WaveyStyle.secondaryColor
                    Layout.alignment: Qt.AlignBaseline
                    Layout.rightMargin: 10

                    font {
                        family: WaveyFonts.h4.family
                        pixelSize: root.cityLabelSize
                        weight: 500
                    }
                }
                Label {
                    id: dateLabel
                    text: `${root.day} ${root.month} ${root.year}`
                    color: WaveyStyle.secondaryColor
                    Layout.alignment: Qt.AlignBaseline

                    font {
                        family: WaveyFonts.text_3.family
                        pixelSize: root.dateLabelSize
                        weight: WaveyFonts.text_3.weight
                    }
                }
                Label {
                    id: dayOfTheWeekLabel
                    text: ` ${root.dayOfTheWeek}`
                    color: WaveyStyle.primaryColor
                    Layout.alignment: Qt.AlignBaseline

                    font {
                        family: WaveyFonts.h1.family
                        pixelSize: root.dateLabelSize
                        weight: 200
                    }
                }
            }
        }
        sourceComponent: root.horizontal ? horizontal : vertical
    }
}
