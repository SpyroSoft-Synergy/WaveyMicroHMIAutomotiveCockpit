#ifndef GESTUREDETECTORSERVER_H
#define GESTUREDETECTORSERVER_H

#include <QObject>

class MediaPlayerServer : public QObject
{
    Q_OBJECT
public:
    MediaPlayerServer(QObject* parent = nullptr);

public slots:
    void start();
};
#endif // GESTUREDETECTORSERVER_H
