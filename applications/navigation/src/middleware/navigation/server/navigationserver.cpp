#include "navigationserver.h"

#include "core.h"
#include "navigationimpl.h"

NavigationServer::NavigationServer(QObject *parent) : QObject(parent) {}

void NavigationServer::start()
{
    using namespace com::spyro_soft::wavey::navigation_iface;
    auto service = new NavigationImpl(this);
    Core::instance()->host()->enableRemoting(service,
                                             QStringLiteral("com.spyro_soft.wavey.navigation_iface.Navigation"));
}
