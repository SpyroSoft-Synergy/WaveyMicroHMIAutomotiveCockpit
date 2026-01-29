#ifndef WEATHERIMPL_H
#define WEATHERIMPL_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QList>
#include <QString>
#include <QJsonObject>
#include <QJsonArray>

#include "rep_weather_source.h"
#include "city.h"
#include "searchcity.h"
#include "forecasthour.h"

using namespace com::spyro_soft::wavey::weather_iface;

class WeatherImpl : public WeatherSource
{
public:
    WeatherImpl(QObject *parent = nullptr);
    ~WeatherImpl();

public Q_SLOTS:
    QVariant requestBriefWeather(const QString& city) override;
    QVariant requestDetailedWeather(const QString& city) override;
    QVariant requestSearchAutofill(const QString& query) override;

    QVariantList briefWeather() const override;
    DetailedWeather detailedWeather() const override;
    QVariantList searchAutofill() const override;
    QVariantList recentSearch() const override;
    ClusterWeather clusterWeather() const override;
    ServerData serverData() const override;

    QVariant removeCity(int index) override;
    QVariant setMainCity(int index) override;
    QVariant moveCity(int from, int to, bool bemitchanged) override;
    QVariant makeRecent(int index) override;
    QVariant clearSearch() override;
    QVariant refreshWeatherData() override;
    QVariant updateSearchInput(const QString& NewInput) override;

private slots:
    void requestReply(QNetworkReply* reply);

    void briefWeatherReply(const QJsonObject& reply);
    void detailedWeatherReply(const QJsonObject& reply);
    void searchAutofillReply(const QJsonArray& reply);

private:
    void setForecast(int currentHour, const QVariantList& hours1, const QVariantList& hours2, const QString& sunset, const QString& sunrise);
    void initialiseDummyData();
    void checkConnection();

private:
    QNetworkAccessManager* m_manager;
    class QTimer* m_connectionCheckTimer;
    QTimer* m_refreshWeatherTimer;
    bool getCitySaved(const QString& cityName, const QString& countryName);
    void seeCity();
    void clusterWeatherReply(const QMap<QString, QVariant>& reply);
    QString searchInput;

    QVariantList m_briefWeather;
    DetailedWeather m_detailedWeather;
    QVariantList m_searchAutofill;
    QVariantList m_recentSearch;
    ClusterWeather m_clusterWeather;
    ServerData m_serverData;
};

#endif // WEATHERIMPL_H
