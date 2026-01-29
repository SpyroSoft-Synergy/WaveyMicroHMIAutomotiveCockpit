set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)


find_package(Qt6 REQUIRED COMPONENTS RemoteObjects IfRemoteObjectsHelperPrivate)
qt_add_library(SysUIIPCServer
    sysuiipcserver.cpp sysuiipcserver.h
    gesturedetectorimpl.cpp gesturedetectorimpl.h
    appslotsimpl.cpp appslotsimpl.h
    appslotsmodelimpl.cpp appslotsmodelimpl.h
    appstyleimpl.cpp appstyleimpl.h
)

qt_ifcodegen_extend_target(SysUIIPCServer
    IDL_FILES ../sysuiipc.qface
    TEMPLATE server_qtro)

set_target_properties(SysUIIPCServer PROPERTIES RUNTIME_OUTPUT_DIRECTORY ../../../wavey-ivi)


target_compile_definitions(SysUIIPCServer PUBLIC
    QT_DEPRECATED_WARNINGS
)

target_link_libraries(SysUIIPCServer PUBLIC
     Qt6::RemoteObjects
     Qt6::IfRemoteObjectsHelperPrivate
     SysUIIPCFrontend
)

target_include_directories(SysUIIPCServer PUBLIC
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          )
