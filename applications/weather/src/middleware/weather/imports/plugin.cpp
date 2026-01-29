#ifndef COM_SPYRO_SOFT_WAVEY_WEATHERQMLPLUGIN_H_
#define COM_SPYRO_SOFT_WAVEY_WEATHERQMLPLUGIN_H_

#include <QtQml/qqmlextensionplugin.h>
#include <qqml.h>

#include "weather_ifacefactory.h"
#include "weatherserver.h"



class WeatherQmlPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.spyro_soft.wavey.weather_iface"));
        Q_UNUSED(uri);
        using namespace com::spyro_soft::wavey::weather_iface;
        Weather_ifaceFactory::registerQmlTypes();

        qmlRegisterType<WeatherServer>("com.spyro_soft.wavey.weather_iface",1,0,"WeatherServer");
    }
};



#include "plugin.moc"

#endif // COM_SPYRO_SOFT_WAVEY_WEATHERQMLPLUGIN_H_

