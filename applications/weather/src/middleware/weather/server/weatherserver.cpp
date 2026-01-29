#include "weatherserver.h"
#include "weatherimpl.h"
#include "core.h"

WeatherServer::WeatherServer(QObject *parent)
    : QObject(parent)
{

}

void WeatherServer::start()
{
    using namespace com::spyro_soft::wavey::weather_iface;
    auto service = new WeatherImpl(this);
    Core::instance()->host()->enableRemoting(service, QStringLiteral("com.spyro_soft.wavey.weather_iface.Weather"));
}
