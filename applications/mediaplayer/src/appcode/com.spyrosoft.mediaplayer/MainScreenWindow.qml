import QtQuick
import QtQuick.Controls
import wavey.style
import wavey.gestures
import wavey.windows as WaveyWindows
import mediaplayer.components
import mediaplayer.screens
import mediaplayer.viewmodels
import QtApplicationManager.Application

WaveyWindows.MainScreenWindow {
    id: root

    property MainScreenViewModel viewModel: MainScreenViewModel{
        active: root.isActive
    }

    visible: true
    title: qsTr("MediaPlayer")

    ScreenSwitcher {
        id: applicationView
        anchors.fill: parent
        currentScreenIndex: 0
        appScreens: [
            SongPlaybackScreen {
                width: applicationView.width
                height: applicationView.height
                viewModel: root.viewModel
                StackView.visible: true
            },
            ListsScreen {
                width: applicationView.width
                height: applicationView.height
                viewModel: root.viewModel
                StackView.visible: true
            }

        ]
        initialItem: applicationView.appScreens[applicationView.currentScreenIndex]
    }

    Connections {
        target: viewModel
        function onCurrentViewIndexChanged() {
            applicationView.switchScreen(viewModel.currentViewIndex)
        }
    }
}
