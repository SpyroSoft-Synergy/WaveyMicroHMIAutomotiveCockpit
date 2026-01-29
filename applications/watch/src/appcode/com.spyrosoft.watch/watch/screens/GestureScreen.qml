import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import watch.components
import wavey.style

Item {
    id: root

    anchors.fill: parent

    signal analogClicked
    signal digitalClicked

    property int selectedClock

    ColumnLayout {
        spacing: 56
        anchors.centerIn: parent

        Label {
            id: watchLabel
            text: "Time"
            color: WaveyStyle.accentColor
            Layout.alignment: Qt.AlignHCenter
            font {
                family: WaveyFonts.h1.family
                pixelSize: 38
                weight: WaveyFonts.h1.weight
            }
        }

        WatchSwitch {
            height: 93
            width: 488
            radius: 67
            Layout.alignment: Qt.AlignHCenter
            leftText: "Analog"
            rightText: "Digital"
            onLeftClicked: root.analogClicked()
            onRightClicked: root.digitalClicked()
        }
    }
}
