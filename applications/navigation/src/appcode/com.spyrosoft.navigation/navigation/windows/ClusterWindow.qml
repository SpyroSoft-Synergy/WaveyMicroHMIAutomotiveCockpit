import QtApplicationManager.Application
import QtQuick
import navigation.components
import navigation.viewmodels
import wavey.style
import wavey.windows as WaveyWindows

WaveyWindows.ClusterWindow {
    id: root

    property NavigationViewModelBase viewModel

    viewModel: NavigationViewModelBase {
    }

    readonly property real travelledDistance: viewModel.currentRoute.distanceTravelled <= 0 ? 0 : (viewModel.currentRoute.distanceTravelled / viewModel.currentRoute.distance)

    title: qsTr("ClusterScreen")
    Item {
        id: content

        clip: true
        anchors.fill: parent

        Rectangle {
            id: routeRect

            readonly property real maxWidth: content.width - anchors.margins * 2

            height: 5
            radius: 4
            color: WaveyStyle.primaryColor

            anchors {
                left: content.left
                leftMargin: root.travelledDistance * maxWidth + anchors.margins + 5
                right: content.right
                verticalCenter: content.verticalCenter
                margins: content.width * 0.075
            }

        }

        Rectangle {
            id: routeTravelled

            width: root.travelledDistance * routeRect.maxWidth
            radius: routeRect.radius
            color: Qt.darker(WaveyStyle.primaryColor)

            anchors {
                left: content.left
                leftMargin: routeRect.anchors.margins
                top: routeRect.top
                bottom: routeRect.bottom
            }

        }

        Image {
            id: positionChevron

            source: "../assets/location.png"
            height: 40
            width: 40

            anchors {
                right: routeTravelled.right
                rightMargin: -5
                verticalCenter: routeTravelled.verticalCenter
            }

            Behavior on x {
                NumberAnimation {
                    duration: 250
                }

            }

        }

        Row {
            id: propertiesRow

            property var startDate: new Date()
            property var endDate: new Date()

            width: routeRect.maxWidth
            height: 25

            Connections {
                function onNewRouteStarted() {
                    propertiesRow.startDate = new Date();
                    let destinationDate = new Date();
                    destinationDate.setSeconds(destinationDate.getSeconds() + viewModel.currentRoute.travelTime);
                    propertiesRow.endDate = destinationDate;
                }

                target: root.viewModel
            }

            anchors {
                top: positionChevron.bottom
                horizontalCenter: content.horizontalCenter
            }

            RouteProperty {
                width: propertiesRow.width / 3
                height: propertiesRow.height
                iconSource: "../assets/time.png"
                text: {
                    const travelledTime = (new Date() - propertiesRow.startDate) / 1000;
                    const travelTime = Math.max(0, viewModel.currentRoute.travelTime - travelledTime);
                    if (travelTime > 3600)
                        return (travelTime / 3600).toFixed(1) + " h";
                    else if (travelTime > 60)
                        return (travelTime / 60).toFixed(0) + " min";
                    else
                        return travelTime.toFixed(0) + " s";
                }
            }

            RouteProperty {
                width: propertiesRow.width / 3
                height: propertiesRow.height
                iconSource: "../assets/distance.png"
                text: {
                    const travelLength = Math.max(0, viewModel.currentRoute.distance - viewModel.currentRoute.distanceTravelled);
                    if (travelLength > 1000)
                        return (travelLength / 1000).toFixed(1) + " km";
                    else
                        return travelLength.toFixed(0) + " m";
                }
            }

            RouteProperty {
                width: propertiesRow.width / 3
                height: propertiesRow.height
                iconSource: "../assets/finish.png"
                text: Qt.formatTime(propertiesRow.endDate, "hh:mm")
            }

        }

    }

}
