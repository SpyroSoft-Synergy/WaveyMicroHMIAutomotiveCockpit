import QtQuick
import wavey.windows as WaveyWindows
import weather.screens
import weather.viewmodels
import QtApplicationManager.Application

WaveyWindows.GestureScreenWindow {
    id: root

    property GestureScreenViewModel viewModel: GestureScreenViewModel {
    }

    title: qsTr("GestureScreen")
    visible: true

    GestureScreen{
        viewModel: root.viewModel
    }
}
