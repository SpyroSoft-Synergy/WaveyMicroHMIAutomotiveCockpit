set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)


find_package(Qt6 REQUIRED COMPONENTS Core RemoteObjects IfRemoteObjectsHelperPrivate HttpServer)
qt_add_library(WatchServer
    watchserver.cpp watchserver.h
    watchimpl.cpp watchimpl.h
)

qt_ifcodegen_extend_target(WatchServer
    IDL_FILES ../watch.qface
    TEMPLATE server_qtro)

set_target_properties(WatchServer PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})


target_compile_definitions(WatchServer PUBLIC
    QT_DEPRECATED_WARNINGS
)

target_link_libraries(WatchServer PUBLIC
     Qt6::RemoteObjects
     Qt6::IfRemoteObjectsHelperPrivate
     Qt6::HttpServer
     Qt6::Core
     WatchFrontend
)

target_include_directories(WatchServer PUBLIC
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          )
