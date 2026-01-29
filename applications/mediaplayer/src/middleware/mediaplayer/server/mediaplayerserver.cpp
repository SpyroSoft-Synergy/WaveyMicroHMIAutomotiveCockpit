#include "mediaplayerserver.h"
#include "mediaplayerimpl.h"
#include "core.h"

MediaPlayerServer::MediaPlayerServer(QObject *parent)
    : QObject(parent)
{

}

void MediaPlayerServer::start()
{
     using namespace com::spyro_soft::wavey::media;
     auto service = new MediaPlayerImpl(this);
     Core::instance()->host()->enableRemoting(service, QStringLiteral("com.spyro_soft.wavey.media.MediaPlayer"));
}
