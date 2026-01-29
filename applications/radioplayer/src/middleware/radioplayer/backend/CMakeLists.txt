set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui InterfaceFramework)

qt_add_plugin(RadioPlayerBackend PLUGIN_TYPE interfaceframework)
if(NOT ANDROID)
set_target_properties(RadioPlayerBackend PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/interfaceframework)
endif()

qt_ifcodegen_extend_target(RadioPlayerBackend
    IDL_FILES ../radioplayer.qface
    TEMPLATE backend_qtro
)

target_link_libraries(RadioPlayerBackend PUBLIC
    RadioPlayerFrontend
)
