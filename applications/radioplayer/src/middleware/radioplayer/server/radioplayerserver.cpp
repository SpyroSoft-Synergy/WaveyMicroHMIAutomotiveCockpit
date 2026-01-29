#include "radioplayerserver.h"
#include "radioplayerimpl.h"
#include "core.h"

RadioPlayerServer::RadioPlayerServer(QObject *parent)
    : QObject(parent)
{

}

void RadioPlayerServer::start()
{
     using namespace com::spyro_soft::wavey::radioplayer_iface;
     auto service = new RadioPlayerImpl(this);
     Core::instance()->host()->enableRemoting(service, QStringLiteral("com.spyro_soft.wavey.radioplayer_iface.RadioPlayer"));
}
