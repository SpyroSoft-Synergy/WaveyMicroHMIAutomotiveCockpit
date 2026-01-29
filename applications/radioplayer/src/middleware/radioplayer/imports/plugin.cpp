#ifndef COM_SPYRO_SOFT_WAVEY_RADIOPLAYERQMLPLUGIN_H_
#define COM_SPYRO_SOFT_WAVEY_RADIOPLAYERQMLPLUGIN_H_

#include <QtQml/qqmlextensionplugin.h>
#include <qqml.h>

#include "radioplayer_ifacefactory.h"
#include "radioplayerserver.h"



class RadioPlayerQmlPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.spyro_soft.wavey.radioplayer_iface"));
        Q_UNUSED(uri);
        using namespace com::spyro_soft::wavey::radioplayer_iface;
        Radioplayer_ifaceFactory::registerQmlTypes();

        qmlRegisterType<RadioPlayerServer>("com.spyro_soft.wavey.radioplayer_iface",1,0,"RadioPlayerServer");
    }
};



#include "plugin.moc"

#endif // COM_SPYRO_SOFT_WAVEY_RADIOPLAYERQMLPLUGIN_H_

