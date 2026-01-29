import QtQuick
import QtQuick.Controls
import wavey.style
import wavey.gestures
import wavey.windows as WaveyWindows
import QtApplicationManager.Application
import weather.viewmodels
import weather.screens

WaveyWindows.MainScreenWindow {
    id: root

    property MainScreenViewModel viewModel: MainScreenViewModel {
        active: root.isActive
    }

    title: qsTr("Weather")
    visible: true

    MainScreen {
        anchors.fill: parent
        height: 660
        viewModel: root.viewModel
        width: 900
    }
}
