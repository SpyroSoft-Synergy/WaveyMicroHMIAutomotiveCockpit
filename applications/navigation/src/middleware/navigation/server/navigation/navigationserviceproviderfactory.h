#ifndef NAVIGATIONSERVICEPROVIDERFACTORY_H
#define NAVIGATIONSERVICEPROVIDERFACTORY_H

#include "inavigationserviceprovider.h"

class NavigationServiceProviderFactory
{
public:
    enum class Type { Simulator, Osm };

    NavigationServiceProviderFactory();

    std::unique_ptr<INavigationServiceProvider> getNavigationServiceProvider(const Type type) const;
};

#endif  // NAVIGATIONSERVICEPROVIDERFACTORY_H
