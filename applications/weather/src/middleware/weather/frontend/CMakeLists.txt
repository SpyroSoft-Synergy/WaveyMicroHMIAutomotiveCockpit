set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)


find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)
find_package(Qt6 REQUIRED COMPONENTS InterfaceFramework)

qt_add_library(WeatherFrontend)

qt6_add_qml_module(WeatherFrontend
    URI com.spyro_soft.wavey.weather_iface
    VERSION 1.0
)

qt_ifcodegen_extend_target(WeatherFrontend
    IDL_FILES ../weather.qface
    TEMPLATE frontendex
    EXTRA_TEMPLATE_SEARCH_PATH ${CMAKE_CURRENT_LIST_DIR}
)

set_target_properties(WeatherFrontend PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
