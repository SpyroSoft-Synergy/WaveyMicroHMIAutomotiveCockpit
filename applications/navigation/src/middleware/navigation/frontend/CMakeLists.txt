set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)


find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick Location)
find_package(Qt6 REQUIRED COMPONENTS InterfaceFramework)

qt_add_library(NavigationFrontend
    routeadapter.h routeadapter.cpp)

qt6_add_qml_module(NavigationFrontend
    URI com.spyro_soft.wavey.navigation_iface
    VERSION 1.0
)


qt_ifcodegen_extend_target(NavigationFrontend
    IDL_FILES ../navigation.qface
    TEMPLATE frontendex
    EXTRA_TEMPLATE_SEARCH_PATH ${CMAKE_CURRENT_LIST_DIR}
)

target_link_libraries(NavigationFrontend PUBLIC
     Qt6::Location
)

set_target_properties(NavigationFrontend PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
