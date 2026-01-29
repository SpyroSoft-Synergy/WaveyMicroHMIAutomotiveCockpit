import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 2.14
import wavey.style
import weather.viewmodels



Item {
    id: rootComponent
    signal returnButtonPressed
    signal cityAdded

    required property var weather
    property bool bShowRecent: true

    anchors.horizontalCenter: parent.horizontalCenter
    height: parent.height
    width: parent.width * 0.9

    Image {
        id: activeHundleBottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: sourceSize.height
        source: "../assets/background/ActiveHundleBottom.png"
        width: sourceSize.width
        y: 33
    }
    Item {
        id: returnButton
        Image {
            id: returnImage
            source: "../assets/icons/arrow_back.png"
        }
        MouseArea {
            anchors.fill: returnImage

            onClicked: {
                returnButtonPressed();
            }
        }
        anchors {
            right: parent.right
            rightMargin: 50
            top: parent.top
            topMargin: 20
        }
    }
    Item {
        id: searchBar
        anchors.top: returnButton.bottom
        height: 55
        width: rootComponent.width

        anchors {
            horizontalCenter: parent.horizontalCenter
            topMargin: 40
        }
        Item {
            height: parent.height
            width: parent.width

            Image {
                id: searchIcon
                fillMode: Image.PreserveAspectFit
                source: "../assets/CitiesSearch/search.png"

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            TextField {
                id: searchTextField
                color: WaveyStyle.secondaryColor
                height: parent.height + 10
                width: parent.width - searchIcon.width

                background: Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                }

                onFocusChanged: {
                    if (focus) {
                        Qt.inputMethod.show();
                    }
                }
                onTextChanged: {
                    text = text.charAt(0).toUpperCase() + text.slice(1);
                    closeImage.visible = text.length > 0 ? true : false;
                    weather.updateSearchInput(text)
                    if (text.length >= 4) {
                        weather.requestSearchAutofill(text)
                        recentLabel.text = "Results";
                        recentLabelAmount.visible = true;
                        bShowRecent = false

                    }
                    else {
                        recentLabel.text = "Recent";
                        recentLabelAmount.visible = false;
                        bShowRecent = true
                    }
                }

                font {
                    family: WaveyFonts.text_3.family
                    pixelSize: 40
                    weight: 500
                }
                anchors {
                    left: searchIcon.right
                    topMargin: 20
                    verticalCenter: parent.verticalCenter
                }
            }
            Image {
                id: closeImage
                source: "../assets/CitiesSearch/close.png"
                visible: false

                anchors {
                    right: searchTextField.right
                    verticalCenter: parent.verticalCenter
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        searchTextField.text = "";
                    }
                }
            }
        }
    }
    RowLayout {
        id: searchResultLabel
        anchors {
            left: searchBar.left
            top: searchBar.bottom
            topMargin: 20
        }
        Label {
            id: recentLabel
            color: WaveyStyle.secondaryColor
            opacity: 0.6
            text: "Recent"

            font {
                family: WaveyFonts.rotary_counter.family
                pixelSize: 32
                weight: WaveyFonts.rotary_counter.weight
            }
        }
        Label {
            id: recentLabelAmount
            color: WaveyStyle.secondaryColor
            opacity: 0.6
            visible: false

            font {
                family: WaveyFonts.text_3.family
                pixelSize: 32
                weight: WaveyFonts.text_3.weight
            }
        }
    }

    ListView {
        id: list
        height: 230
        model: bShowRecent ? weather.recentSearch : weather.searchAutofill
        spacing: 60
        width: rootComponent.width
        snapMode: ListView.SnapToItem

        onCountChanged:
        {
            recentLabelAmount.text = `${list.count} found`
        }

        delegate: CitySearchResult {
            cityName: modelData.city
            regionName: modelData.region
            countryName: modelData.country
            searchInput: modelData.searchinput
            bSaved: modelData.bSaved
            bIsRecent: bShowRecent

            onSaveClicked:
            {
                weather.requestBriefWeather(cityName)
                weather.makeRecent(index)
            }
            MouseArea{
                anchors.fill: bShowRecent? parent : undefined
                onClicked:{
                        var str = `${cityName}, `

                        if(regionName !== "")
                            str += `${regionName}, `
                        str += ` ${countryName}`

                        searchTextField.text = str;

                }
            }
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: searchResultLabel.bottom
            topMargin: 40
        }
    }
}
