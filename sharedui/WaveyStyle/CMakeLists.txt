cmake_minimum_required(VERSION 3.22)
project(WaveyStyle VERSION 1.0 LANGUAGES CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# QT_QML_OUTPUT_DIRECTORY is set by parent CMakeLists.txt for monorepo builds
# Only set it if building standalone (not as subdirectory)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
endif()
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Gui ShaderTools)
qt_add_library(WaveyStyle SHARED)
qt_add_qml_module(
    WaveyStyle
    URI wavey.style
    VERSION 1.0
    SOURCES
        StyleLoader.h
        StyleLoader.cpp
        ThemeValues.h
        WaveyFonts.h
        WaveyFonts.cpp
        WaveyStyle.h
        WaveyStyle.cpp
        QQuickAttachedObject.h
        QQuickAttachedObject.cpp
    QML_FILES
        common_components/PlayStop.qml
        common_components/RoundedItem.qml
        common_components/AppSlotBorderEffect.qml
        common_components/DesaturationEffect.qml
        common_components/BlurHelper.qml
        common_components/BlurEffect.qml
    RESOURCES
        common_shaders/desaturation.frag.qsb
        common_shaders/desaturation.vert.qsb
        common_shaders/blureffect.frag.qsb
        common_shaders/blureffect.vert.qsb
        common_shaders/bluritems.frag.qsb
        common_shaders/bluritems.vert.qsb
        common_assets/music_radio.png
        fonts/Inter-Black.ttf
        fonts/Inter-Bold.ttf
        fonts/Inter-ExtraBold.ttf
        fonts/Inter-ExtraLight.ttf
        fonts/Inter-Light.ttf
        fonts/Inter-Medium.ttf
        fonts/Inter-Regular.ttf
        fonts/Inter-SemiBold.ttf
        fonts/Inter-Thin.ttf
        fonts/Roboto-Black.ttf
        fonts/Roboto-BlackItalic.ttf
        fonts/Roboto-Bold.ttf
        fonts/Roboto-BoldItalic.ttf
        fonts/Roboto-Italic.ttf
        fonts/Roboto-Light.ttf
        fonts/Roboto-LightItalic.ttf
        fonts/Roboto-Medium.ttf
        fonts/Roboto-MediumItalic.ttf
        fonts/Roboto-Regular.ttf
        fonts/Roboto-Thin.ttf
        fonts/Roboto-ThinItalic.ttf
        fonts/AzeretMono-Medium.ttf
        style.conf   
)

qt_add_shaders(WaveyStyle
    "common_shaders"
    PREFIX "/"
    FILES
        common_shaders/roundedItem.frag
        common_shaders/appSlotBorder.frag
)

target_compile_definitions(WaveyStyle PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(
    WaveyStyle
    PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Gui
)

target_include_directories(WaveyStyle PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})


