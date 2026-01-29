set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)


find_package(Qt6 REQUIRED COMPONENTS Core RemoteObjects IfRemoteObjectsHelperPrivate HttpServer)
qt_add_library(RadioPlayerServer
    radioplayerserver.cpp radioplayerserver.h
    radioplayerimpl.cpp radioplayerimpl.h
)

qt_ifcodegen_extend_target(RadioPlayerServer
    IDL_FILES ../radioplayer.qface
    TEMPLATE server_qtro)

file(GLOB_RECURSE STATION_DATA "stationdata/*")

qt_add_resources(RadioPlayerServer stationdata FILES ${STATION_DATA} PREFIX "/" BASE ${CMAKE_CURRENT_LIST_DIR})

set_target_properties(RadioPlayerServer PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})


target_compile_definitions(RadioPlayerServer PUBLIC
    QT_DEPRECATED_WARNINGS
)

target_link_libraries(RadioPlayerServer PUBLIC
     Qt6::RemoteObjects
     Qt6::IfRemoteObjectsHelperPrivate
     Qt6::HttpServer
     Qt6::Core
     RadioPlayerFrontend
)

target_include_directories(RadioPlayerServer PUBLIC
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          )
