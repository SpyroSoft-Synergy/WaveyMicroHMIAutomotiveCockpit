import QtApplicationManager.Application
import QtQuick
import wavey.style
import wavey.windows as WaveyWindows
import watch.viewmodels
import watch.screens

WaveyWindows.ClusterWindow {
    id: root

    property WatchViewModelBase viewModel: WatchViewModelBase {
    }

    title: qsTr("ClusterScreen")
    visible: true

    ClusterScreen {
        anchors.fill: parent
    }
}
