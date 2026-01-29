# WaveyInstall.cmake - install rules for monorepo runtime

include(GNUInstallDirs)

set(WAVEY_INSTALL_DATA_DIR "${CMAKE_INSTALL_DATADIR}/wavey")
set(WAVEY_INSTALL_QML_DIR "${WAVEY_INSTALL_DATA_DIR}/qml-plugins")


# ---------------------------------------------------------------------------
# Executable + qt.conf
# ---------------------------------------------------------------------------
if(TARGET WaveySystemUI)
    install(TARGETS WaveySystemUI
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endif()

install(FILES "${CMAKE_SOURCE_DIR}/systemui/src/wavey-ivi/qt.conf"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# ---------------------------------------------------------------------------
# Shared libraries used by QML plugins / servers
# ---------------------------------------------------------------------------
set(WAVEY_RUNTIME_LIBS
    MediaPlayerServer
    MediaPlayerFrontend
    NavigationServer
    NavigationFrontend
    WeatherServer
    WeatherFrontend
    WatchServer
    WatchFrontend
    RadioPlayerServer
    RadioPlayerFrontend
    SysUIIPCServer
    SysUIIPCFrontend
    WaveyStyle
)

foreach(lib_target IN LISTS WAVEY_RUNTIME_LIBS)
    if(TARGET ${lib_target})
        install(TARGETS ${lib_target}
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        )
    endif()
endforeach()

# ---------------------------------------------------------------------------
# InterfaceFramework backends (Qt plugins)
# ---------------------------------------------------------------------------
set(WAVEY_IF_BACKENDS
    MediaPlayerBackend
    NavigationBackend
    WeatherBackend
    WatchBackend
    RadioPlayerBackend
    SysUIIPCBackend
)

foreach(plugin_target IN LISTS WAVEY_IF_BACKENDS)
    if(TARGET ${plugin_target})
        install(TARGETS ${plugin_target}
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/plugins/interfaceframework
        )
    endif()
endforeach()


# ---------------------------------------------------------------------------
# QML modules and middleware imports
# ---------------------------------------------------------------------------
install(DIRECTORY "${CMAKE_BINARY_DIR}/qml/wavey"
    DESTINATION ${WAVEY_INSTALL_QML_DIR}
)

install(DIRECTORY "${CMAKE_BINARY_DIR}/imports/com"
    DESTINATION ${WAVEY_INSTALL_QML_DIR}
)

if(TARGET SysUIIPCImports)
    install(DIRECTORY "${CMAKE_BINARY_DIR}/src/wavey-ivi/qml-plugins/com"
        DESTINATION ${WAVEY_INSTALL_QML_DIR}
    )
endif()

install(DIRECTORY "${CMAKE_BINARY_DIR}/systemui/src/wavey-ivi/qml-plugins/com"
    DESTINATION ${WAVEY_INSTALL_QML_DIR}
)

if(BUILD_TESTBED)
    install(DIRECTORY "${CMAKE_BINARY_DIR}/qml/QtApplicationManager"
        DESTINATION ${WAVEY_INSTALL_QML_DIR}
        OPTIONAL
    )
endif()

# ---------------------------------------------------------------------------
# SystemUI assets + configs
# ---------------------------------------------------------------------------
install(DIRECTORY "${CMAKE_SOURCE_DIR}/systemui/src/wavey-ivi/assets/sysUI"
    DESTINATION ${WAVEY_INSTALL_DATA_DIR}
)

install(FILES
    "${CMAKE_SOURCE_DIR}/systemui/src/wavey-ivi/assets/wavey-common-config.yaml"
    "${CMAKE_SOURCE_DIR}/systemui/src/wavey-ivi/assets/wavey-gesture-config-android.yaml"
    "${CMAKE_SOURCE_DIR}/systemui/src/wavey-ivi/assets/wavey-gesture-config-desktop.yaml"
    "${CMAKE_SOURCE_DIR}/systemui/src/wavey-ivi/assets/wavey-main-config-android.yaml"
    "${CMAKE_SOURCE_DIR}/systemui/src/wavey-ivi/assets/wavey-main-config-desktop.yaml"
    DESTINATION ${WAVEY_INSTALL_DATA_DIR}
)

# ---------------------------------------------------------------------------
# Built-in application bundles (AppMan packages)
# ---------------------------------------------------------------------------
set(WAVEY_BUILTIN_APPS mediaplayer navigation weather watch radioplayer)
foreach(app IN LISTS WAVEY_BUILTIN_APPS)
    install(DIRECTORY
        "${CMAKE_SOURCE_DIR}/applications/${app}/src/appcode/com.spyrosoft.${app}"
        DESTINATION "${WAVEY_INSTALL_DATA_DIR}/builtinApps"
    )
endforeach()
