#ifndef SYSUIIPCSERVER_H
#define SYSUIIPCSERVER_H

#include <QObject>

class SysUIIPCServer : public QObject
{
    Q_OBJECT

public:
    SysUIIPCServer(QObject *parent = nullptr);

    void start();
};
#endif  // SYSUIIPCSERVER_H
