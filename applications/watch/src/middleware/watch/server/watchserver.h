#ifndef WATCHSERVER_H
#define WATCHSERVER_H

#include <QObject>

class WatchServer : public QObject
{
    Q_OBJECT
public:
    WatchServer(QObject* parent = nullptr);

public slots:
    void start();
};
#endif // WATCHSERVER_H
