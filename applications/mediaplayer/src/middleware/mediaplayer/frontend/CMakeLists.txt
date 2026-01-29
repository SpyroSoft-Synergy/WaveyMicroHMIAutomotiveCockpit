set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)


find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)
find_package(Qt6 REQUIRED COMPONENTS InterfaceFramework)

qt_add_library(MediaPlayerFrontend)

qt_ifcodegen_extend_target(MediaPlayerFrontend
    IDL_FILES ../mediaplayer.qface
    TEMPLATE frontendex
    EXTRA_TEMPLATE_SEARCH_PATH ${CMAKE_CURRENT_LIST_DIR}
)

set_target_properties(MediaPlayerFrontend PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
