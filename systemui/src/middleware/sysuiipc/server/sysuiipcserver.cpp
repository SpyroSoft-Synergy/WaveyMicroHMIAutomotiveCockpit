#include "sysuiipcserver.h"

#include "appslotsimpl.h"
#include "appstyleimpl.h"
#include "core.h"
#include "gesturedetectorimpl.h"

SysUIIPCServer::SysUIIPCServer(QObject *parent) : QObject(parent) {}

void SysUIIPCServer::start()
{
    using namespace com::spyro_soft::wavey::sysuiipc;
    auto appStyleService = new AppStyleImpl(this);
    auto gesturesService = new GestureDetectorImpl(this);
    auto appSlotsService = new AppSlotsImpl(this);
    auto appSlotsModelService = appSlotsService->appSlotsModel();
    Core::instance()->host()->enableRemoting(gesturesService,
                                             QStringLiteral("com.spyro_soft.wavey.sysuiipc.GestureDetector"));
    Core::instance()->host()->enableRemoting(appSlotsService, QStringLiteral("com.spyro_soft.wavey.sysuiipc.AppSlots"));
    Core::instance()->host()->enableRemoting(appSlotsModelService,
                                             QStringLiteral("com.spyro_soft.wavey.sysuiipc.AppSlots.appSlots"));
    Core::instance()->host()->enableRemoting(appStyleService, QStringLiteral("com.spyro_soft.wavey.sysuiipc.AppStyle"));
}
