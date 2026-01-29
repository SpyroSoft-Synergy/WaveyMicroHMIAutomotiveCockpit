#ifndef FAKENAVIGATIONSERVICEPROVIDER_H
#define FAKENAVIGATIONSERVICEPROVIDER_H

#include "inavigationserviceprovider.h"

class FakeNavigationServiceProvider : public QObject, public INavigationServiceProvider
{
    Q_OBJECT

public:
    FakeNavigationServiceProvider();

    void calculateRoute(const QGeoCoordinate &destination, const std::function<void(QGeoRoute)> callback) override;
    void reverseGeocode(const QGeoCoordinate &position, const std::function<void(QGeoLocation)> callback) override;
    QGeoCoordinate getPosition() const override;
    qreal getRotation() const override;

Q_SIGNALS:
    void positionChanged() override;

protected:
    void timerEvent(QTimerEvent *event) override;

private:
    void readRoutes();
    void readRoute(const QString &routeName);
    QGeoCoordinate parseCoordinate(const QString &coordinateString) const;

    static bool compareCoords(const QGeoCoordinate &lhs, const QGeoCoordinate &rhs);

    QGeoCoordinate m_currentPosition;
    QGeoCoordinate m_targetPosition;
    QGeoRoute m_currentRoute;
    std::map<QGeoCoordinate, QString, decltype(&compareCoords)> m_existingRoutes;
};

#endif  // FAKENAVIGATIONSERVICEPROVIDER_H
