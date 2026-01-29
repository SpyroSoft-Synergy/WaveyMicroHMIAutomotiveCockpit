#ifndef WEATHERSERVER_H
#define WEATHERSERVER_H

#include <QObject>

class WeatherServer : public QObject
{
    Q_OBJECT
public:
    WeatherServer(QObject* parent = nullptr);

public slots:
    void start();
};
#endif // WEATHERSERVER_H
