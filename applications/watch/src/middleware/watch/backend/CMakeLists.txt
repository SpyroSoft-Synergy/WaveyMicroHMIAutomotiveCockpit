set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui InterfaceFramework)

qt_add_plugin(WatchBackend PLUGIN_TYPE interfaceframework)
if(NOT ANDROID)
set_target_properties(WatchBackend PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/interfaceframework)
endif()

qt_ifcodegen_extend_target(WatchBackend
    IDL_FILES ../watch.qface
    TEMPLATE backend_qtro
)

target_link_libraries(WatchBackend PUBLIC
    WatchFrontend
)
