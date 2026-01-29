import QtQuick
import mainScreen.views
import viewmodels
import wavey.style

Window {
    id: root

    property MainScreenViewModel viewModel: MainScreenViewModel {
    }

    color: WaveyStyle.backgroundColor // qmllint disable
    height: root.viewModel.screenHeight
    title: "Wavey Main Screen"
    visible: true
    width: root.viewModel.screenWidth

    Item {
        id: content

        height: 1080
        scale: Math.min(root.width / content.width, root.height / content.height)
        transformOrigin: Item.TopLeft
        width: 3840
        y: 43

        Image {
            id: background

            source: String("mainScreenUI/%1/background.png").arg(WaveyStyle.currentThemeName.toLowerCase())
        }

        ClusterView {
            height: 720
            viewModel: root.viewModel
            width: 1200
        }

        UserGuideView {
            viewModel: root.viewModel
            width: 400

            anchors {
                bottom: appSlots.bottom
                right: appSlots.left
                top: appSlots.top
            }
        }

        ApplicationsView {
            id: appSlots

            height: 720
            viewModel: root.viewModel
            x: 1400
        }

        Text {
            id: lastGesture

            anchors.bottom: background.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: background.horizontalCenter
            color: WaveyStyle.theme === WaveyStyle.Light ? "black" : "white"
            font.pixelSize: 15
            text: root.viewModel.lastGesture
            visible: false
        }
    }
}
