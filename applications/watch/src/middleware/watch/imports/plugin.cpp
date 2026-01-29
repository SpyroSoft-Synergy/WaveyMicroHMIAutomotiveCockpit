#ifndef COM_SPYRO_SOFT_WAVEY_WATCHQMLPLUGIN_H_
#define COM_SPYRO_SOFT_WAVEY_WATCHQMLPLUGIN_H_

#include <QtQml/qqmlextensionplugin.h>
#include <qqml.h>

#include "watch_ifacefactory.h"
#include "watchserver.h"



class WatchQmlPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.spyro_soft.wavey.watch_iface"));
        Q_UNUSED(uri);
        using namespace com::spyro_soft::wavey::watch_iface;
        Watch_ifaceFactory::registerQmlTypes();

        qmlRegisterType<WatchServer>("com.spyro_soft.wavey.watch_iface",1,0,"WatchServer");
    }
};



#include "plugin.moc"

#endif // COM_SPYRO_SOFT_WAVEY_WATCHQMLPLUGIN_H_

