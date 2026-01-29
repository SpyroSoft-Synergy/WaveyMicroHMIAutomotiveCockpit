set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)


find_package(Qt6 REQUIRED COMPONENTS Core RemoteObjects IfRemoteObjectsHelperPrivate HttpServer)
qt_add_library(WeatherServer
    weatherserver.cpp weatherserver.h
    weatherimpl.cpp weatherimpl.h
    utility/iconcodes.cpp utility/iconcodes.h
    data/dummydata.cpp data/dummydata.h
)

qt_ifcodegen_extend_target(WeatherServer
    IDL_FILES ../weather.qface
    TEMPLATE server_qtro)

set_target_properties(WeatherServer PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})


target_compile_definitions(WeatherServer PUBLIC
    QT_DEPRECATED_WARNINGS
)

target_link_libraries(WeatherServer PUBLIC
     Qt6::RemoteObjects
     Qt6::IfRemoteObjectsHelperPrivate
     Qt6::HttpServer
     Qt6::Core
     WeatherFrontend
)

target_include_directories(WeatherServer PUBLIC
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          )
