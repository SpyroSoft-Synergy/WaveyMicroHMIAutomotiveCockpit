import QtApplicationManager.Application
import QtQuick
import QtQuick.Controls
import navigation.screens
import navigation.viewmodels
import wavey.gestures
import wavey.style
import wavey.windows as WaveyWindows

WaveyWindows.MainScreenWindow {
    id: root

    property MainScreenViewModel viewModel

    viewModel: MainScreenViewModel {
        active: root.isActive
    }

    visible: true
    title: qsTr("Navigation")
    Rectangle {
        id: content

        clip: true
        anchors.fill: parent
        color: "red"

        MapScreen {
            anchors.fill: content
            viewModel: root.viewModel
        }

    }

}
