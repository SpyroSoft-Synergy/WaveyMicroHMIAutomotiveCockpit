import QtLocation
import QtPositioning
import QtQuick
import navigation.viewmodels

QtObject {
    id: root

    required property Map map
    required property NavigationViewModelBase viewModel
    readonly property alias zoomLevel: p.zoomLevel
    readonly property alias tilt: p.tilt
    readonly property alias rotation: p.rotation
    readonly property var position: QtPositioning.coordinate(p.positionLat, p.positionLong)
    readonly property alias center: p.cameraPosition
    readonly property alias bearing: p.bearing
    readonly property QtObject
    p: QtObject {
        id: p

        readonly property real zoomTiltTreshold: 15
        property real zoomLevel: Math.max(Math.min(viewModel.zoomLevel, Math.floor(map.maximumZoomLevel)), Math.ceil(map.minimumZoomLevel))
        property real tilt: zoomLevel > p.zoomTiltTreshold ? Math.log(zoomLevel - p.zoomTiltTreshold + 1) * 30 : 0
        property real positionLat: viewModel.position.latitude
        property real positionLong: viewModel.position.longitude
        property real rotation: viewModel.rotation
        readonly property real cameraForwardDistanceMeters: zoomLevel > 0 ? 250 / zoomLevel : 0
        readonly property var cameraPosition: root.position.atDistanceAndAzimuth(cameraForwardDistanceMeters, bearing)
        property real bearing: zoomLevel > p.zoomTiltTreshold ? rotation : 0

        Behavior on positionLat {
            NumberAnimation {
                duration: 250
            }

        }

        Behavior on positionLong {
            NumberAnimation {
                duration: 250
            }

        }

        Behavior on rotation {
            NumberAnimation {
                duration: 250
            }

        }

    }

}
