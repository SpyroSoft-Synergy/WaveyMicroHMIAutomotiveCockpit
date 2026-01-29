import QtQuick
import QtQuick.Controls
import wavey.style
import wavey.gestures
import wavey.windows as WaveyWindows
import QtApplicationManager.Application

import watch.viewmodels
import watch.screens

WaveyWindows.MainScreenWindow {
    id: root

    property MainScreenViewModel viewModel: MainScreenViewModel {
        active: root.isActive
    }

    visible: true
    title: qsTr("Main watch screen")

    MainScreen {
        width: root.width
        height: root.height
        viewModel: root.viewModel
    }
}
