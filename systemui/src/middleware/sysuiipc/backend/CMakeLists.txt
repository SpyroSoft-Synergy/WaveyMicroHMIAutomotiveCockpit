set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui InterfaceFramework)

qt_add_plugin(SysUIIPCBackend PLUGIN_TYPE interfaceframework)
if(NOT ANDROID)
set_target_properties(SysUIIPCBackend PROPERTIES LIBRARY_OUTPUT_DIRECTORY ../../../wavey-ivi/interfaceframework)
endif()

qt_ifcodegen_extend_target(SysUIIPCBackend
    IDL_FILES ../sysuiipc.qface
    TEMPLATE backend_qtro
)

target_link_libraries(SysUIIPCBackend PUBLIC
    SysUIIPCFrontend
)

if(ANDROID)
add_android_dependency(SysUIIPCBackend)
endif()
