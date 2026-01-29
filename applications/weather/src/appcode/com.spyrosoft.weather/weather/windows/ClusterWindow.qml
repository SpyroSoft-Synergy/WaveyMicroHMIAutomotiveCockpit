import QtApplicationManager.Application
import QtQuick
import wavey.windows as WaveyWindows
import weather.viewmodels
import weather.screens

WaveyWindows.ClusterWindow {
    id: root

    property MainScreenViewModel viewModel: MainScreenViewModel {
    }

    title: qsTr("ClusterScreen")
    visible: true

    ClusterScreen {
        clusterWeather: root.viewModel.d.weather.clusterWeather
        briefWeather: root.viewModel.d.weather.briefWeather
    }
}
