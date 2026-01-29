import QtQuick 2.14
import QtQuick.Controls 2.14

Item {
    id: rootComponent
    height: parent.height
    width: parent.width

    required property var weather
    property var fromId: undefined
    property var toId: undefined

    ListView {
        id: list
        height: parent.height
        snapMode: ListView.SnapToItem
        width: parent.width
        clip: true
        spacing: 1

        displaced: Transition {
            NumberAnimation {
                easing.type: Easing.OutQuad
                properties: "y"
            }
        }

        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            active: true
            visible: false
            stepSize: 0.01
        }

        model: DelegateModel {
            id: visualModel

            property int modelIndex

            model: weather.briefWeather

            DropArea {
                id: dropArea
                height: cityLabel.height+20
                width: cityLabel.width
                z: 2

                Component.onCompleted: {
                    anchors.horizontalCenter = parent.horizontalCenter;
                }
                onDropped: function (drag) {
                    var from = visualModel.modelIndex;
                    var to = (drag.source as CityLabel).visualIndex;
                    toId = to

                    if(fromId != toId ){
                        weather.moveCity(from, to, true)
                        fromId = undefined
                        toId = undefined
                    }
                }
                onEntered: function (drag) {
                    var from = (drag.source as CityLabel).visualIndex;
                    var to = cityLabel.visualIndex;

                    visualModel.items.move(from, to);

                    if (fromId == undefined) fromId = from
                }

                CityLabel {
                    z: 1
                    id: cityLabel
                    cityName: modelData.city
                    countryName: modelData.country
                    dragParent: rootComponent
                    labelIndex: index
                    temperature: modelData.temperature
                    visualIndex: DelegateModel.itemsIndex
                    weatherIcon: modelData.icon

                    onPressed: function () {
                        visualModel.modelIndex = DelegateModel.itemsIndex;
                    }

                    onDeleteButtonPressed: function (deleteIndex) {
                        weather.removeCity(deleteIndex)
                    }

                    onYChanged:
                    {
                        if(y >= 270)
                        {
                            scrollTimer.bDecrease = false
                            scrollTimer.running = true;
                        }
                        else if(y <= 1 && y > 0)
                        {
                            scrollTimer.bDecrease = true
                            scrollTimer.running = true;
                        }
                        else
                            scrollTimer.running = false;
                    }
                }
            }
        }

        Timer
        {
            id: scrollTimer
            property bool bDecrease
            interval: 10
            repeat: true
            running: false
            onTriggered:
            {
                if(scrollTimer.bDecrease)
                {
                    scrollBar.decrease()
                }
                else
                {
                    scrollBar.increase()
                }
            }
        }
    }
}
