set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)


find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)
find_package(Qt6 REQUIRED COMPONENTS InterfaceFramework)

qt_add_library(SysUIIPCFrontend)

qt_ifcodegen_extend_target(SysUIIPCFrontend
    IDL_FILES ../sysuiipc.qface
    TEMPLATE frontendex
    EXTRA_TEMPLATE_SEARCH_PATH ${CMAKE_CURRENT_LIST_DIR}
)

set_target_properties(SysUIIPCFrontend PROPERTIES RUNTIME_OUTPUT_DIRECTORY ../../../wavey-ivi)

if(ANDROID)
    add_android_dependency(SysUIIPCFrontend)
endif()

