set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

cmake_minimum_required(VERSION 3.16)
project(WaveySystemUI LANGUAGES CXX)

set(WAVEY_QT_REQUIRED_COMPONENTS
    Core
    AppManMainPrivate
    Quick
    Gui
    Qml
    RemoteObjects
    IfRemoteObjectsHelperPrivate
    QuickControls2
    QuickTest
    HttpServer
    ShaderTools
    PrintSupport
    QuickWidgets
)
find_package(Qt6 REQUIRED COMPONENTS ${WAVEY_QT_REQUIRED_COMPONENTS})
find_package(X11 COMPONENTS Xi)

list(APPEND QML_IMPORT_PATH "${CMAKE_CURRENT_LIST_DIR}/assets/sysUI")
list(APPEND QML_IMPORT_PATH "${CMAKE_CURRENT_BINARY_DIR}/qml-plugins")
list(APPEND QML_IMPORT_PATH "${QT_QML_OUTPUT_DIRECTORY}")
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

set(QML_IMPORT_PATH ${QML_IMPORT_PATH}
    CACHE STRING "Qt Creator extra qml import paths"
    FORCE
)

add_compile_definitions(AM_COMPILING_APPMAN)
add_compile_definitions(WAVEY_VERSION="${Wavey_VERSION}")

qt_add_big_resources(MAP_DATA mapdata/mapdata.qrc)

qt_add_executable(WaveySystemUI
    impl/main.cpp
    ${MAP_DATA}
)

qt_add_qml_module(
    WaveySystemUI
    URI wavey.ui
    VERSION 1.0
    SOURCES
        impl/presslistener.h
        impl/presslistener.cpp
)

qt_add_shaders(WaveySystemUI
    "wavey_shaders"
    PREFIX "/"
    FILES
        assets/sysUI/shaderEffects/tempSlider.frag
)

# In monorepo build, dependencies come from sibling projects
# No Conan configuration needed - WaveyStyle, applications are already built

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/android/AndroidManifest.xml.in
    ${CMAKE_CURRENT_LIST_DIR}/android/AndroidManifest.xml
    @ONLY
)

set_property(TARGET WaveySystemUI
    APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/android)

if(ANDROID)
  set(assets_dir "${CMAKE_CURRENT_BINARY_DIR}/android-build/assets")
else()
  set(assets_dir "${CMAKE_CURRENT_BINARY_DIR}")
endif()

deploy_appman_assets(WaveySystemUI ${CMAKE_CURRENT_LIST_DIR}/assets ${assets_dir})

if (ANDROID)
    include(${ANDROID_SDK_ROOT}/android_openssl/CMakeLists.txt)
    get_target_property(_QT_ANDROID_EXTRA_LIBS WaveySystemUI QT_ANDROID_EXTRA_LIBS)
    set_target_properties(WaveySystemUI PROPERTIES QT_ANDROID_EXTRA_LIBS
                                               "${ANDROID_EXTRA_LIBS};${_QT_ANDROID_EXTRA_LIBS}")
endif()
if(ANDROID)
# Add path for gestures middleware qml plugin
set_target_properties(
  WaveySystemUI PROPERTIES QT_QML_IMPORT_PATH ${QT_QML_IMPORT_PATH}
  ${CMAKE_BINARY_DIR}/qml-plugins)

# Add other shared libraries to APK
finalize_android_dependencies(WaveySystemUI)
endif()

target_link_libraries(WaveySystemUI PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Gui
    Qt6::Qml
    Qt6::RemoteObjects
    Qt6::AppManMainPrivate
    Qt6::IfRemoteObjectsHelperPrivate
    Qt6::QuickControls2
    Qt6::HttpServer
    Qt6::PrintSupport
    Qt6::QuickWidgets
)

target_link_libraries(WaveySystemUI PUBLIC
    SysUIIPCFrontend
    SysUIIPCServer
)

target_include_directories(WaveySystemUI PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/impl")

# =============================================================================
# Deploy monorepo-built dependencies for desktop
# =============================================================================
if(NOT ANDROID)
    # Create a master deployment target that will run AFTER all backends are built
    add_custom_target(deploy_monorepo_assets ALL
        COMMENT "Deploying monorepo assets for SystemUI"
    )
    
    # Deploy QML modules from monorepo build
    add_custom_command(TARGET deploy_monorepo_assets POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${QT_QML_OUTPUT_DIRECTORY}
            ${assets_dir}/qml-plugins
        COMMENT "Deploying QML plugins from monorepo"
    )
    
    # Deploy interfaceframework backends - must wait for all backends to be built
    add_custom_command(TARGET deploy_monorepo_assets POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_BINARY_DIR}/interfaceframework
            ${assets_dir}/interfaceframework
        COMMENT "Deploying InterfaceFramework backends"
    )
    
    # Deploy middleware imports (for applications)
    add_custom_command(TARGET deploy_monorepo_assets POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_BINARY_DIR}/imports
            ${assets_dir}/qml-plugins
        COMMENT "Deploying middleware imports"
    )
    
    # Deploy built-in applications (AppCode QML bundles)
    # These are the Qt Application Manager application packages
    set(BUILTIN_APPS mediaplayer navigation weather watch radioplayer)
    foreach(app ${BUILTIN_APPS})
        add_custom_command(TARGET deploy_monorepo_assets POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${CMAKE_SOURCE_DIR}/applications/${app}/src/appcode/com.spyrosoft.${app}
                ${assets_dir}/builtinApps/com.spyrosoft.${app}
            COMMENT "Deploying ${app} application bundle"
        )
    endforeach()
    
    # Make deploy_monorepo_assets depend on all the backend targets
    # This ensures files are fully built before copying
    set(MONOREPO_ASSET_DEPS
        WaveySystemUI
        MediaPlayerBackend
        NavigationBackend
        WeatherBackend
        WatchBackend
        RadioPlayerBackend
        MediaPlayerImports
        NavigationImports
        WeatherImports
        WatchImports
        RadioPlayerImports
        SysUIIPCImports
        WaveyStyle
        WaveyComponents
        WaveyGestures
        WaveyViewmodels
        WaveyWindows
    )
    if(TARGET TestBedModule)
        list(APPEND MONOREPO_ASSET_DEPS
            TestBedModule
            TestBedHelpers
            QtAppManagerMock
            QtAppManagerAppMock
        )
    endif()
    add_dependencies(deploy_monorepo_assets ${MONOREPO_ASSET_DEPS})
endif()
