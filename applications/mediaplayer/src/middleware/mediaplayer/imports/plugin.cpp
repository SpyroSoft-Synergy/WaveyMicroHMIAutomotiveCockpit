#ifndef COM_SPYRO_SOFT_WAVEY_MEDIAPLAYERQMLPLUGIN_H_
#define COM_SPYRO_SOFT_WAVEY_MEDIAPLAYERQMLPLUGIN_H_

#include <QtQml/qqmlextensionplugin.h>
#include <qqml.h>

#include "mediafactory.h"
#include "mediaplayerserver.h"



class MediaplayerQmlPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.spyro_soft.wavey.media"));
        Q_UNUSED(uri);
        using namespace com::spyro_soft::wavey::media;
        MediaFactory::registerQmlTypes();        

        qmlRegisterType<MediaPlayerServer>("com.spyro_soft.wavey.media",1,0,"MediaPlayerServer");
    }
};



#include "plugin.moc"

#endif // COM_SPYRO_SOFT_WAVEY_MEDIAPLAYERQMLPLUGIN_H_

