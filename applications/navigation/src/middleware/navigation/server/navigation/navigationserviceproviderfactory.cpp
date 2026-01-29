#include "navigationserviceproviderfactory.h"

#include "fakenavigationserviceprovider.h"
#include "osmnavigationserviceprovider.h"

NavigationServiceProviderFactory::NavigationServiceProviderFactory() {}

std::unique_ptr<INavigationServiceProvider>
NavigationServiceProviderFactory::getNavigationServiceProvider(const Type type) const
{
    switch (type) {
    case Type::Simulator:
        return std::make_unique<FakeNavigationServiceProvider>();
    case Type::Osm:
        return std::make_unique<OsmNavigationServiceProvider>();
    }

    Q_UNREACHABLE();
}
