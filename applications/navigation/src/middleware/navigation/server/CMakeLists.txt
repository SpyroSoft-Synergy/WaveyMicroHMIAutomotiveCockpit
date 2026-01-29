set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)


find_package(Qt6 REQUIRED COMPONENTS Core RemoteObjects IfRemoteObjectsHelperPrivate Location)
qt_add_library(NavigationServer
    navigationserver.cpp navigationserver.h
    navigationimpl.cpp navigationimpl.h

    navigation/navigationserviceproviderfactory.h navigation/navigationserviceproviderfactory.cpp
    navigation/inavigationserviceprovider.h
    navigation/osmnavigationserviceprovider.h navigation/osmnavigationserviceprovider.cpp
    navigation/fakenavigationserviceprovider.h navigation/fakenavigationserviceprovider.cpp

    helpers/geocodinghelper.h helpers/geocodinghelper.cpp
    helpers/navigationcache.h helpers/navigationcache.cpp
)

qt_ifcodegen_extend_target(NavigationServer
    IDL_FILES ../navigation.qface
    TEMPLATE server_qtro)

set_target_properties(NavigationServer PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

file(GLOB_RECURSE ROUTES_DATA "routes/*")
qt_add_resources(NavigationServer routes FILES ${ROUTES_DATA} PREFIX "/" BASE ${CMAKE_CURRENT_LIST_DIR})

target_compile_definitions(NavigationServer PUBLIC
    QT_DEPRECATED_WARNINGS
)

target_link_libraries(NavigationServer PUBLIC
     Qt6::RemoteObjects
     Qt6::IfRemoteObjectsHelperPrivate
     Qt6::Core
     Qt6::Location
     NavigationFrontend
)

target_include_directories(NavigationServer PUBLIC
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          )
