#include "watchserver.h"
#include "watchimpl.h"
#include "core.h"

WatchServer::WatchServer(QObject *parent)
    : QObject(parent)
{

}

void WatchServer::start()
{
     using namespace com::spyro_soft::wavey::watch_iface;
     auto service = new WatchImpl(this);
     Core::instance()->host()->enableRemoting(service, QStringLiteral("com.spyro_soft.wavey.watch_iface.Watch"));
}
