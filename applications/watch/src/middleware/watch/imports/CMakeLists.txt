set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 COMPONENTS Core)
find_package(Qt6 COMPONENTS InterfaceFramework)
find_package(Qt6 COMPONENTS Qml)
find_package(Qt6 COMPONENTS Quick)

qt_ifcodegen_import_variables(MIDDLEWARE IDL_FILES ../watch.qface TEMPLATE
                              qmlplugin)

set(QML_PLUGIN_OUTPUT_DIR "${CMAKE_BINARY_DIR}/imports/${MIDDLEWARE_URI_PATH}")

qt_add_qml_module(
  WatchImports
  OUTPUT_DIRECTORY ${QML_PLUGIN_OUTPUT_DIR}
  URI ${MIDDLEWARE_URI}
  VERSION ${MIDDLEWARE_VERSION}
  PLUGIN_TARGET WatchImports
  NO_PLUGIN_OPTIONAL
  NO_GENERATE_PLUGIN_SOURCE
  NO_GENERATE_QMLTYPES
  SOURCES plugin.cpp)

target_link_libraries(WatchImports PUBLIC WatchServer Qt6::Core
                                                Qt6::InterfaceFramework)
add_custom_target(watch_copy_qml_types ${CMAKE_COMMAND} -E copy_if_different
                                 ${MIDDLEWARE_TYPEINFO}
                                 ${QML_PLUGIN_OUTPUT_DIR}/WatchImports.qmltypes)

add_dependencies(WatchImports watch_copy_qml_types)
