#ifndef RADIOPLAYERSERVER_H
#define RADIOPLAYERSERVER_H

#include <QObject>

class RadioPlayerServer : public QObject
{
    Q_OBJECT
public:
    RadioPlayerServer(QObject* parent = nullptr);

public slots:
    void start();
};
#endif // RADIOPLAYERSERVER_H
