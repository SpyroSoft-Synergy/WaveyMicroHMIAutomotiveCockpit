import Qt.labs.platform
import QtLocation
import QtPositioning
import QtQuick
import com.spyro_soft.wavey.navigation_iface
import navigation.appmodules.camera
import navigation.components
import navigation.viewmodels
import wavey.style

Item {
    id: root

    property NavigationViewModelBase viewModel

    Plugin {
        id: mapPlugin

        name: "maplibregl"
        Component.onCompleted: {
            console.info("Loaded style from:", styleParameter.value);
            console.info("Map cache location:", cacheParameter.value);
        }

        PluginParameter {
            name: "maplibregl.settings_template"
            value: "mapbox"
        }

        PluginParameter {
            id: cacheParameter

            name: "maplibregl.mapping.cache.directory"
            value: {
                let path = StandardPaths.writableLocation(StandardPaths.CacheLocation).toString();
                path = path.replace(/^(file:\/{2})/, ""); // we need to clean up file:// at the beginning of url
                return path;
            }
        }

        PluginParameter {
            id: styleParameter

            name: "maplibregl.mapping.additional_style_urls"
            value: Qt.resolvedUrl("./../mapstyle/style.json")
        }

    }

    CameraController {
        id: cameraController

        viewModel: root.viewModel
        map: map
    }

    Map {
        id: map

        anchors.fill: root
        plugin: mapPlugin
        gesture.enabled: true
        zoomLevel: cameraController.zoomLevel
        tilt: cameraController.tilt
        center: cameraController.center
        bearing: cameraController.bearing
        onMapReadyChanged: {
            if (mapReady) {
                hideCoverAnimation.start();
            }
        }

        MapQuickItem {
            id: positionArrowMarker

            coordinate: cameraController.position

            anchorPoint {
                x: 35
                y: 35
            }

            sourceItem: Image {
                width: 70
                height: 70
                source: Qt.resolvedUrl("./../assets/arrow.png")
                transform: [
                    Rotation {
                        angle: cameraController.rotation - map.bearing

                        origin {
                            x: 35
                            y: 35
                        }

                    },
                    Scale {
                        yScale: Math.cos(cameraController.tilt * Math.PI / 180)

                        origin {
                            x: 35
                            y: 35
                        }

                    }
                ]
            }

        }

        MapRoute {
            route: RouteAdapter.toGeoRoute(viewModel.currentRoute)
            line.color: WaveyStyle.primaryColor
            line.width: cameraController.zoomLevel * 0.5
            smooth: true
            opacity: 0.8
        }

    }

    DirectionsList {
        id: directionsList

        directions: viewModel.directions
        width: 230

        anchors {
            top: root.top
            left: root.left
            topMargin: 30
            leftMargin: 45
        }

    }

    Image {
        id: speedLimitMock

        width: 67
        height: 67
        source: Qt.resolvedUrl("./../assets/speed_50.png")

        anchors {
            top: directionsList.bottom
            left: root.left
            topMargin: 30
            leftMargin: 45
        }

    }

    Column {
        spacing: 10

        anchors {
            top: root.top
            right: root.right
            rightMargin: 45
            topMargin: 30
        }

        MapInfoBox {
            width: 80
            height: 65
            text: "72 m"
            icon: Qt.resolvedUrl("./../assets/height_icon.png")
        }

        MapInfoBox {
            width: 80
            height: 53
            text: "200 m"
            icon: Qt.resolvedUrl("./../assets/scale_icon.png")
        }

    }

    Loader {
        id: mapCover

        anchors.fill: root
        opacity: 1

        SequentialAnimation {
            id: hideCoverAnimation

            PauseAnimation {
                duration: 500
            }

            ParallelAnimation {
                NumberAnimation {
                    target: mapCover
                    duration: 800
                    property: "scale"
                    from: 1
                    to: 1.5
                    easing.type: Easing.InQuad
                }

                SequentialAnimation {
                    PauseAnimation {
                        duration: 500
                    }

                    NumberAnimation {
                        target: mapCover
                        duration: 300
                        property: "opacity"
                        from: 1
                        to: 0
                    }

                }

            }

            ScriptAction {
                script: mapCover.active = false
            }

        }

        sourceComponent: Image {
            source: Qt.resolvedUrl("./../mapstyle/cover.png")
            fillMode: Image.PreserveAspectCrop
        }

    }

    Image {
        width: root.width
        height: 260
        source: Qt.resolvedUrl("./../assets/glow.png")

        anchors {
            bottom: root.bottom
            bottomMargin: -height / 2
            horizontalCenter: root.horizontalCenter
        }

    }

}
