import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import wavey.style
import wavey.components as WaveyComponents
import weather.viewmodels
import weather.components as WeatherComponents

Item {
    id: root

    property WeatherViewModelBase viewModel

    anchors.fill: parent

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: WeatherComponents.WeatherDisplay {
            id: mainScreen

            weather: root.viewModel.d.weather
            citiesList: root.viewModel.d.weather.briefWeather

            onEditButtonClicked: {
                visible = false;
                stackView.push(citiesList);
                citiesList.visible = true;
            }
        }

        WeatherComponents.CitiesSearch {
            id: citiesSearch
            visible: false
            weather: root.viewModel.d.weather

            onReturnButtonPressed: {
                citiesSearch.visible = false;
                stackView.pop();
            }
            onCityAdded: {
                stackView.pop();
            }
        }

        WeatherComponents.CitiesList {
            id: citiesList
            visible: false
            weather: root.viewModel.d.weather

            onAddCityClicked: {
                stackView.push(citiesSearch);
                citiesSearch.visible = true;
            }
            onReturnButtonPressed: {
                citiesList.visible = false;
                stackView.pop();
            }
        }
    }
}
