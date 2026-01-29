# Applications - Wavey built-in applications
#
# Each application provides:
# - Middleware (Qt Interface Framework based IPC)
# - AppCode (QML application bundle for Qt Application Manager)
# - Testbed (optional standalone test application)

option(BUILD_TESTBED "Build testbed applications for standalone testing" OFF)
option(BUILD_MEDIAPLAYER "Build MediaPlayer application" ON)
option(BUILD_NAVIGATION "Build Navigation application" ON)
option(BUILD_WEATHER "Build Weather application" ON)
option(BUILD_WATCH "Build Watch application" ON)
option(BUILD_RADIOPLAYER "Build RadioPlayer application" ON)

if(BUILD_MEDIAPLAYER)
    add_subdirectory(mediaplayer)
endif()

if(BUILD_NAVIGATION)
    add_subdirectory(navigation)
endif()

if(BUILD_WEATHER)
    add_subdirectory(weather)
endif()

if(BUILD_WATCH)
    add_subdirectory(watch)
endif()

if(BUILD_RADIOPLAYER)
    add_subdirectory(radioplayer)
endif()
