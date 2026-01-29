#ifndef NAVIGATIONSERVER_H
#define NAVIGATIONSERVER_H

#include <QObject>

class NavigationServer : public QObject
{
    Q_OBJECT

public:
    NavigationServer(QObject *parent = nullptr);

public slots:
    void start();
};
#endif  // NAVIGATIONSERVER_H
