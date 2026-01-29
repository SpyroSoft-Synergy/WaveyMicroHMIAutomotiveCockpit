import QtQuick
import QtQuick.Controls
import wavey.style
import wavey.gestures
import wavey.windows as WaveyWindows
import wavey.components as WaveyComponents
import QtApplicationManager.Application

import radioplayer.viewmodels
import radioplayer.screens

WaveyWindows.MainScreenWindow {
    id: root

    property MainScreenViewModel viewModel: MainScreenViewModel {
        active: root.isActive
    }

    visible: true
    title: qsTr("RadioPlayer")

    WaveyComponents.ScreenSwitcher {
        id: applicationView
        anchors.fill: parent
        currentScreenIndex: 0
        appScreens: [
            StationPlaybackScreen {
                width: applicationView.width
                height: applicationView.height
                viewModel: root.viewModel
                StackView.visible: true
            },
            StationListScreen {
                width: applicationView.width
                height: applicationView.height
                viewModel: root.viewModel
                StackView.visible: true
            }
        ]
        initialItem: applicationView.appScreens[applicationView.currentScreenIndex]
        popExit: Transition {
            YAnimator {
                from: 0
                to: applicationView.height
                duration: applicationView.animationDuration
                easing.type: Easing.InQuad
            }
        }
        pushEnter: Transition {
            YAnimator {
                from: applicationView.height
                to: 0
                duration: applicationView.animationDuration
                easing.type: Easing.InQuad
            }
        }
    }

    MouseArea {
        anchors.fill: parent; acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
                       console.log("------------------", applicationView.width, applicationView.appScreens[1].state)
                      applicationView.switchScreen(1)
                   }
    }

    Connections {
        target: viewModel
        function onCurrentViewIndexChanged() {
            applicationView.switchScreen(viewModel.currentViewIndex)
        }
    }
}
