import QtQuick
import QtQuick.Controls
import wavey.style
import wavey.windows as WaveyWindows
import QtApplicationManager.Application
import watch.viewmodels
import watch.screens

WaveyWindows.GestureScreenWindow {
    id: root

    property GestureScreenViewModel viewModel: GestureScreenViewModel {}

    visible: true
    title: qsTr("Gesture screen")

    GestureScreen {
        anchors.fill: parent
        selectedClock: root.viewModel.d.watch.currentClock
        onAnalogClicked: root.viewModel.setClock(0)
        onDigitalClicked: root.viewModel.setClock(1)
    }
}
