#ifndef RADIOPLAYERIMPL_H
#define RADIOPLAYERIMPL_H

#include "rep_radioplayer_source.h"

#include <QHttpServer>

using namespace com::spyro_soft::wavey::radioplayer_iface;

class RadioPlayerImpl : public RadioPlayerSource
{
public:
    explicit RadioPlayerImpl(QObject *parent = nullptr);

public Q_SLOTS:
    QVariant togglePlayback() override;
    QVariant nextStation() override;
    QVariant setStation(int index) override;
    QVariant prevStation() override;

public:
    QVariantList stations() const override;
    PlaybackInfo playbackInfo() const override;

protected:
    void initializeStations();

private:
    QVariantList m_stations;
    PlaybackInfo m_playbackInfo;
    QHttpServer m_httpServer;
    quint16 m_serverPort;
};

#endif // RADIOPLAYERIMPL_H
