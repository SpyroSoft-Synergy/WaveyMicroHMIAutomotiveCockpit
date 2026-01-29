import QtQuick
import QtQml
import com.spyro_soft.wavey.radioplayer_iface

import wavey.gestures
import wavey.viewmodels

ApplicationRootViewModel {
    id: root

    readonly property var stations: d.stations

    readonly property bool isPlaying: radioPlayer.playbackInfo.isPlaying
    readonly property int currentStation: radioPlayer.playbackInfo.currentStationNumber
    readonly property string currentStationCover: d.currentStation ? d.currentStation.coverUrl : ""
    readonly property real currentStationFrequency: d.currentStation ? d.currentStation.frequency : 0
    readonly property string currentStationName: d.currentStation ? d.currentStation.name : ""

    property int currentViewIndex: 0

    readonly property QtObject d: QtObject {
        id: d

        readonly property var stations: radioPlayer.stations
        readonly property var currentStation: stations.length > 0 && radioPlayer.playbackInfo.currentStationNumber >= 0 ? stations[radioPlayer.playbackInfo.currentStationNumber] : null

        readonly property RadioPlayer radioPlayer: RadioPlayer {
            id: radioPlayer
        }
    }

    function togglePlayback() {
        radioPlayer.togglePlayback()
    }

    function nextStation() {
        radioPlayer.nextStation()
    }

    function setStation(index) {
        radioPlayer.setStation(index);
    }

    function prevStation() {
        radioPlayer.prevStation()
    }
}
