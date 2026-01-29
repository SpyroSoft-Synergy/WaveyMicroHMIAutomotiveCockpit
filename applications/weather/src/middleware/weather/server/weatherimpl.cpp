#include "weatherimpl.h"

#include <QUrl>
#include <QJsonDocument>
#include <QFile>
#include <QTimer>
#include <algorithm>

#include "utility/iconcodes.h"
#include "data/dummydata.h"
#include <QDebug>

namespace {
const unsigned int REFRESH_WEATHER_INTERVAL = 600000; //5mins
const unsigned int CONNECTION_CHECK_INTERVAL = 30000;//180000; //3mins
const unsigned int CONNECTION_RETRY_INTERVAL = 30000; //3sec
const QString API_URL = "https://api.weatherapi.com/";
const QString BASE_URL = "https://api.weatherapi.com/v1";
const QString API_KEY = "34feb046c3e342739b194923231307";
}

WeatherImpl::WeatherImpl(QObject *parent)
    : WeatherSource{ parent },
    m_manager{ new QNetworkAccessManager{ this } },
    m_connectionCheckTimer{ new QTimer{ this } },
    m_refreshWeatherTimer{ new QTimer{ this } }
{
    Q_ASSERT(m_manager);
    connect(m_manager, &QNetworkAccessManager::finished, this, &WeatherImpl::requestReply);
    m_manager->setTransferTimeout(::CONNECTION_RETRY_INTERVAL);
    initialiseDummyData();

    Q_ASSERT(m_connectionCheckTimer);
    connect(m_connectionCheckTimer, &QTimer::timeout, this, &WeatherImpl::checkConnection);
    m_connectionCheckTimer->start(::CONNECTION_CHECK_INTERVAL);

    Q_ASSERT(m_refreshWeatherTimer);
    connect(m_refreshWeatherTimer, &QTimer::timeout, this, &WeatherImpl::refreshWeatherData);

    m_refreshWeatherTimer->start(::REFRESH_WEATHER_INTERVAL);
}

WeatherImpl::~WeatherImpl(){
    delete m_manager;
    delete m_connectionCheckTimer;
    delete m_refreshWeatherTimer;
}

QVariant WeatherImpl::requestBriefWeather(const QString& city) {
    const QUrl url{ QString{ "%1/current.json?key=%2&q=%3" }.arg(::BASE_URL).arg(::API_KEY).arg(city) };
    m_manager->get(QNetworkRequest{ url });

    return QVariant{};
}

QVariant WeatherImpl::requestDetailedWeather(const QString& city) {
    const QUrl url{ QString{ "%1/forecast.json?key=%2&q=%3&days=2" }.arg(::BASE_URL).arg(::API_KEY).arg(city != "" ? city: m_detailedWeather.city()) };
    m_manager->get(QNetworkRequest{ url });
    return QVariant{};
}

QVariant WeatherImpl::requestSearchAutofill(const QString& query) {
    const QUrl url{ QString{ "%1/search.json?key=%2&q=%3" }.arg(::BASE_URL).arg(::API_KEY).arg(query) };
    m_manager->get(QNetworkRequest{ url });

    return QVariant{};
}

QVariantList WeatherImpl::briefWeather() const {
    return m_briefWeather;
}

DetailedWeather WeatherImpl::detailedWeather() const {
    return m_detailedWeather;
}

QVariantList WeatherImpl::searchAutofill() const {
    return m_searchAutofill;
}

QVariantList WeatherImpl::recentSearch() const {
    return m_recentSearch;
}

ClusterWeather WeatherImpl::clusterWeather() const {
    return m_clusterWeather;
}

ServerData WeatherImpl::serverData() const
{
    return m_serverData;
}

QVariant WeatherImpl::removeCity(int index) {
    m_briefWeather.removeAt(index);

    seeCity();
    emit briefWeatherChanged(m_briefWeather);
    return true;
}

QVariant WeatherImpl::setMainCity(int index)
{
    if(index<0)
        return false;

    const auto& city = m_briefWeather.at(index);
    City cityData = city.value<City>();

    requestDetailedWeather(cityData.city());
    requestBriefWeather(cityData.city());

    return true;
}

QVariant WeatherImpl::moveCity(int from, int to, bool bemitchanged) {
    short direction = from > to ? -1 : 1;
    const auto& cityMoving = m_briefWeather.at(from);

    for(int i=from; i != to; i += direction){
        m_briefWeather.swapItemsAt(i, i+direction);
    }

    if(from == 0 || to == 0) seeCity();
    else   emit briefWeatherChanged(m_briefWeather);

    return true;
}

void WeatherImpl::seeCity() {
    if(m_briefWeather.size() < 1)
        return;

    const auto& firstCity = m_briefWeather.at(0);
    City data = firstCity.value<City>();
    requestDetailedWeather(data.city());
    requestBriefWeather(data.city());
}

QVariant WeatherImpl::makeRecent(int index) {
    const SearchCity& city = m_searchAutofill.at(index).value<SearchCity>();
    int foundIndex = -1; // Initialize with an invalid index

    for (size_t i = 0; i < m_recentSearch.size(); i++)
    {
        const SearchCity& searchCity = m_recentSearch.at(i).value<SearchCity>();
        if (searchCity.city() == city.city() && searchCity.country() == city.country() && searchCity.region() == city.region())
        {
            foundIndex = i;
            break;
        }
    }

    if (foundIndex != -1)
    {
        qDebug() << m_recentSearch.at(foundIndex).value<SearchCity>().city();
        m_recentSearch.push_front(m_recentSearch.takeAt(foundIndex));
    }
    else
    {
        if (m_recentSearch.size() > 9)
            m_recentSearch.pop_back();

        m_recentSearch.push_front(m_searchAutofill[index]);
    }

    qDebug() << m_recentSearch.size();
    emit recentSearchChanged(m_recentSearch);
    return true;
}

QVariant WeatherImpl::clearSearch() {
    m_searchAutofill.clear();

    emit searchAutofillChanged(m_searchAutofill);
    return true;
}

QVariant WeatherImpl::refreshWeatherData()
{
    if(!m_serverData.bhasconnection()) return false;

    for(auto& city : m_briefWeather){
        City data = city.value<City>();
        requestBriefWeather(data.city());
    }

    emit briefWeatherChanged(m_briefWeather);
    emit detailedWeatherChanged(m_detailedWeather);

    return true;
}

QVariant WeatherImpl::updateSearchInput(const QString& NewInput) 
{
    searchInput = NewInput;
    return true;
}

bool WeatherImpl::getCitySaved(const QString& cityName, const QString& countryName)
{
    for(const auto& city : m_briefWeather)
    {
        City data = city.value<City>();

        if(data.city() == cityName  && data.country() == countryName)
            return true;
    }

    return false;
}

void WeatherImpl::requestReply(QNetworkReply* reply) {
    bool oldConnectionBool = m_serverData.bhasconnection();

    if(reply->error() == QNetworkReply::NoError){
        m_serverData.setBhasconnection(true);

        const QJsonDocument json{ QJsonDocument::fromJson(reply->readAll()) };

        if (json.isArray()) {
            searchAutofillReply(json.array());
        }
        else if (json.isObject()) {
            const QJsonObject& object = json.object();

            if (object.contains("forecast")) {
                detailedWeatherReply(object);
            }
            else {
                briefWeatherReply(object);
            }
        }
    }
    else{
        m_serverData.setBhasconnection(false);
    }

    if (oldConnectionBool != m_serverData.bhasconnection()) {
        m_connectionCheckTimer->stop();

        if(m_serverData.bhasconnection()) {
            m_connectionCheckTimer->start(::CONNECTION_CHECK_INTERVAL);
        }
        else{
            m_connectionCheckTimer->start(::CONNECTION_RETRY_INTERVAL);
        }

        emit serverDataChanged(m_serverData);
    }
}

void WeatherImpl::briefWeatherReply(const QJsonObject& reply) {
    const QVariantMap data = reply.toVariantMap();

    const auto& location = data["location"].toMap();
    const auto& current = data["current"].toMap();
    const auto city = location["name"].toString();

    City cityToUpdate;

    if (std::find_if(m_briefWeather.begin(), m_briefWeather.end(), [&city, &cityToUpdate](const QVariant& item) {
            City cityItem = item.value<City>();
            cityToUpdate = cityItem;
            return cityItem.city() == city;
        }) == m_briefWeather.end()) {
        const auto country = location["country"].toString();
        const auto icon = IconCode::toString(current["condition"].toMap()["code"].toInt());
        const auto temperature = current["temp_c"].toInt();

        City item{ icon, city, country, temperature };
        m_briefWeather.push_front(QVariant::fromValue(item));
        seeCity();
    }
    else
    {
        for(int i = 0; i < m_briefWeather.size(); i++)
        {
            City data = m_briefWeather[i].value<City>();
            if(data.city() == cityToUpdate.city())
            {
                const auto icon = IconCode::toString(current["condition"].toMap()["code"].toInt());
                const auto temperature = current["temp_c"].toInt();

                cityToUpdate.setTemperature(temperature);
                cityToUpdate.setIcon(icon);
                m_briefWeather.replace(i, QVariant::fromValue(cityToUpdate));
                break;
            }
        }
    }

    emit briefWeatherChanged(m_briefWeather);
}

QPair<QString, QString> getSunTimes(int currentHour, const QVariantList& forecast) {
    static const auto convertTime = [](const QVariantList& forecast, int day, const QString& what) -> QString {
        return QTime::fromString(forecast[day].toMap()["astro"].toMap()[what].toString(), "hh:mm ap").toString("hh:mm");
    };

    const auto sunset1 = convertTime(forecast, 0, "sunset");
    const auto sunrise1 = convertTime(forecast, 0, "sunrise");
    const auto sunset2 = convertTime(forecast, 1, "sunset");
    const auto sunrise2 = convertTime(forecast, 1, "sunrise");

    using type = QPair<QString, QString>;

    if (sunset1.left(2).toInt() >= currentHour && sunrise1.left(2).toInt() >= currentHour) {
        return type{ sunset1, sunrise1 };
    }
    else if (sunset1.left(2).toInt() >= currentHour) {
        return type{ sunset1, sunrise2 };
    }
    else if(sunrise1.left(2).toInt() >= currentHour) {
        return type{ sunset2, sunrise1 };
    }
    else {
        return type{ sunset2, sunrise2 };
    }
}

void WeatherImpl::detailedWeatherReply(const QJsonObject& reply) {
    const QVariantMap data = reply.toVariantMap();

    const auto& location = data["location"].toMap();
    const auto& current = data["current"].toMap();
    const auto& forecastday = data["forecast"].toMap()["forecastday"].toList();

    const auto& cityName = location["name"].toString();
    const auto& countryName = location["country"].toString();

    clusterWeatherReply(current);

    m_detailedWeather.setCity(cityName);
    m_detailedWeather.setCountry(countryName);
    m_detailedWeather.setTemperature(current["temp_c"].toInt());
    m_detailedWeather.setFeelslike(current["feelslike_c"].toInt());
    m_detailedWeather.setIcon(IconCode::toString(current["condition"].toMap()["code"].toInt()));

    const auto currentHour = location["localtime"].toString().right(5).left(2).toInt();
    const auto sunTimes = getSunTimes(currentHour, forecastday);
    m_detailedWeather.setSunset(sunTimes.first);
    m_detailedWeather.setSunrise(sunTimes.second);

    static const auto hours = [](const QVariantList& days, int day) -> QVariantList {
        return days[day].toMap()["hour"].toList();
    };

    setForecast(currentHour, hours(forecastday, 0), hours(forecastday, 1), sunTimes.first, sunTimes.second);

    static const auto temperature = [](const QVariantList& days, int day, const QString& what) -> int {
        return days[day].toMap()["day"].toMap()[what].toInt();
    };
    const auto maxTemp1 = temperature(forecastday, 0, "maxtemp_c");
    const auto maxTemp2 = temperature(forecastday, 1, "maxtemp_c");
    const auto minTemp1 = temperature(forecastday, 0, "mintemp_c");
    const auto minTemp2 = temperature(forecastday, 1, "mintemp_c");
    m_detailedWeather.setMaxTemp(std::max(maxTemp1, maxTemp2));
    m_detailedWeather.setMinTemp(std::max(minTemp1, minTemp2));

    emit detailedWeatherChanged(m_detailedWeather);
}

void WeatherImpl::clusterWeatherReply(const QMap<QString, QVariant> &reply)
{
    static const auto getWindStrength = [](float windKph) -> const QString&
    {
        static QMap<QPair<float, float>, QString> windStrengths =
        {
            {{0.f, 5.f}, "Calm"},
            {{5.f, 11.f}, "Light breeze"},
            {{11.f, 28.f}, "Gentle breeze"},
            {{28.f, 50.f}, "Strong breeze"},
            {{50.f, 89.f}, "Gale"},
            {{89.f, 250.f}, "Storm"},
            {{500.f, 500.f}, "Unknown"}
        };

        for (const auto& entry : windStrengths.toStdMap())
        {
            const auto& range = entry.first;
            if (windKph >= range.first && windKph <= range.second)
            {
                return entry.second;
            }
        }

        return windStrengths[{500, 500}];
    };


    static const auto getCloudiness = [](int cloudPercentage) -> const QString&
    {
        static QMap<QPair<int, int>, QString> clouds =
        {
            {{0, 5}, "Clear sky"},
            {{5, 25}, "Mostly clear"},
            {{25, 50}, "Partly cloudy"},
            {{50, 75}, "Mostly cloudy"},
            {{75, 100}, "Overcast"},
            {{500, 500}, "Unknown"}
        };

        for (const auto& entry : clouds.toStdMap())
        {
            const auto& range = entry.first;
            if (cloudPercentage >= range.first && cloudPercentage <= range.second)
            {
                return entry.second;
            }
        }

        return clouds[{500, 500}];
    };

    m_clusterWeather.setIcon(IconCode::toString(reply["condition"].toMap()["code"].toInt()));
    m_clusterWeather.setHumidity(reply["humidity"].toInt());
    m_clusterWeather.setWindstrength(getWindStrength(reply["wind_kph"].toFloat()));
    m_clusterWeather.setVisiblekm(reply["vis_km"].toInt());
    m_clusterWeather.setCloudiness(getCloudiness(reply["cloud"].toInt()));

    emit clusterWeatherChanged(m_clusterWeather);
}

void WeatherImpl::searchAutofillReply(const QJsonArray& reply) {
    const QVariantList data = reply.toVariantList();

    m_searchAutofill.clear();

    for (const auto& e : data) {
        const auto& city = e.toMap()["name"].toString();
        const auto& region = e.toMap()["region"].toString();
        const auto& country = e.toMap()["country"].toString();
        bool bSaved = getCitySaved(city, country);

        SearchCity item{ city, region, country, bSaved, searchInput };
        m_searchAutofill.push_back(QVariant::fromValue(item));
    }

    emit searchAutofillChanged(m_searchAutofill);
}

void WeatherImpl::setForecast(int currentHour, const QVariantList& hours1, const QVariantList& hours2, const QString& sunset, const QString& sunrise) {
    QVariantList forecast;

    static const auto addHours = [](QVariantList& forecast, int from, int to, const QVariantList& hours) -> void {
        for (auto i = from; i < to; i++) {
            const auto temperature = hours[i].toMap()["temp_c"].toInt();
            const auto humidity = hours[i].toMap()["humidity"].toInt();
            const auto time = hours[i].toMap()["time"].toString().right(5);
            const auto icon = IconCode::toString(hours[i].toMap()["condition"].toMap()["code"].toInt());
            const auto isSun = false;

            ForecastHour hour{ icon, time, humidity, temperature, isSun };
            forecast.push_back(QVariant::fromValue(hour));
        }
    };

    auto size = hours1.size();
    addHours(forecast, currentHour + 1, size, hours1);

    size = currentHour + 1;
    addHours(forecast, 0, size, hours2);

    static const auto calculateSun = [](QVariantList& forecast, int currentHour, const QString& sun) {
        const auto hour = sun.left(2).toInt();
        const auto index = hour > currentHour ? hour - currentHour : 24 - currentHour + hour;
        const auto prevItem = forecast[index - 1].value<ForecastHour>();  //orginal [index] -> unsafe code. When changing to London past 20:30 crashes the app.
        ForecastHour hourItem{ prevItem.icon(), sun, prevItem.humidity(), prevItem.temperature(), true };
        return QPair<int, ForecastHour>{ index, hourItem };
    };

    const auto sunsetHour = calculateSun(forecast, currentHour, sunset);
    const auto sunriseHour = calculateSun(forecast, currentHour, sunrise);
    if (sunsetHour.first > sunriseHour.first) {
        forecast.insert(sunriseHour.first, QVariant::fromValue(sunriseHour.second));
        forecast.insert(sunsetHour.first + 1, QVariant::fromValue(sunsetHour.second));
    }
    else {
        forecast.insert(sunsetHour.first, QVariant::fromValue(sunsetHour.second));
        forecast.insert(sunriseHour.first + 1, QVariant::fromValue(sunriseHour.second));
    }

    m_detailedWeather.setForecast(std::move(forecast));
}

void WeatherImpl::initialiseDummyData() {
    QJsonDocument json{ QJsonDocument::fromJson(Data::detailedWeather()) };
    detailedWeatherReply(json.object());

    json = QJsonDocument::fromJson(Data::searchAutofill());

    const QVariantList data = json.array().toVariantList();

    for (const auto& e : data) {
        const auto& city = e.toMap()["name"].toString();
        const auto& region = e.toMap()["region"].toString();
        const auto& country = e.toMap()["country"].toString();
        bool bSaved = getCitySaved(city, country);

        SearchCity item{ city, region, country, bSaved, searchInput };
        m_recentSearch.push_back(QVariant::fromValue(item));
    }

    json = QJsonDocument::fromJson(Data::briefWeather());
    for (const auto& city : json.array()) {
        briefWeatherReply(city.toObject());
    }
}

void WeatherImpl::checkConnection()
{
    m_manager->get(QNetworkRequest{ ::API_URL });
}
