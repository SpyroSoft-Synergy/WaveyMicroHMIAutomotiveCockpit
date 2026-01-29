import QtApplicationManager.Application
import QtQuick
import QtQuick.Controls
import navigation.components
import navigation.viewmodels
import wavey.style
import wavey.windows as WaveyWindows

WaveyWindows.GestureScreenWindow {
    id: root

    property GestureScreenViewModel viewModel

    viewModel: GestureScreenViewModel {
    }

    title: qsTr("GestureScreen")
    Item {
        id: content

        clip: true
        anchors.fill: parent

        SearchButton {
            id: search

            anchors.left: parent.left
            anchors.leftMargin: 17
            anchors.top: parent.top
            anchors.topMargin: 28
        }

        Text {
            id: currentAppName

            text: "Navigation"
            color: WaveyStyle.accentColor
            // TODO: Add new WaveyFont
            font.family: WaveyFonts.h1.family
            font.weight: WaveyFonts.h1.weight
            font.pixelSize: 38
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 80
        }

        ListView {
            id: destinationList

            width: 1034
            height: 200
            anchors.top: parent.top
            anchors.topMargin: 190
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30
            orientation: Qt.Horizontal

            model: NavigationModel {
            }

            delegate: NavigationBlock {
                iconSource: model.icon
                name: model.name
                address: model.address
                onClicked: (index) => {
                    destinationList.currentIndex = index;
                    if (model.location !== undefined) {
                        let location = model.location();
                        viewModel.setDestinationLatLong(location.x, location.y);
                    }
                }
            }

        }

    }

}
