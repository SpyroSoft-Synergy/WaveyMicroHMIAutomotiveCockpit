#ifndef COM_SPYRO_SOFT_WAVEY_NAVIGATIONQMLPLUGIN_H_
#define COM_SPYRO_SOFT_WAVEY_NAVIGATIONQMLPLUGIN_H_

#include "navigation_ifacefactory.h"
#include "navigationserver.h"

#include <QtQml/qqmlextensionplugin.h>
#include <qqml.h>

class NavigationQmlPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.spyro_soft.wavey.navigation_iface"));
        Q_UNUSED(uri);
        using namespace com::spyro_soft::wavey::navigation_iface;
        Navigation_ifaceFactory::registerQmlTypes();

        qmlRegisterType<NavigationServer>("com.spyro_soft.wavey.navigation_iface", 1, 0, "NavigationServer");
    }
};

#include "plugin.moc"

#endif  // COM_SPYRO_SOFT_WAVEY_NAVIGATIONQMLPLUGIN_H_
