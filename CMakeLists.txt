cmake_minimum_required(VERSION 3.21)
project(Wavey VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Install layout + RPATH for installed runtime
include(GNUInstallDirs)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_INSTALL_RPATH
    "$ORIGIN/../${CMAKE_INSTALL_LIBDIR}"
    "$ORIGIN/../../${CMAKE_INSTALL_LIBDIR}"
    "$ORIGIN/../../../${CMAKE_INSTALL_LIBDIR}"
    "$ORIGIN/../../../../${CMAKE_INSTALL_LIBDIR}"
    "$ORIGIN/../../../../../${CMAKE_INSTALL_LIBDIR}"
)

# Include utility modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(WaveyUtils)
if(ANDROID)
    include(AndroidAPKHelpers)
endif()

# Shared QML output directory for all modules
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)

# Get platform info
get_wavey_platform_profile(WAVEY_PLATFORM)
message(STATUS "===========================================")
message(STATUS "Wavey Build System")
message(STATUS "Platform: ${WAVEY_PLATFORM}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "QML output: ${QT_QML_OUTPUT_DIRECTORY}")
message(STATUS "===========================================")

# ===========================================================================
# Subprojects - order matters (dependencies first)
# ===========================================================================

# Shared UI components (WaveyStyle)
add_subdirectory(sharedui/WaveyStyle)

# Application modules (shared QML components)
add_subdirectory(appmodules)

# Applications (MediaPlayer, Navigation, etc.)
add_subdirectory(applications)

# SystemUI - Main HMI application (depends on all above)
option(BUILD_SYSTEMUI "Build SystemUI main application" ON)
if(BUILD_SYSTEMUI)
    add_subdirectory(systemui)
endif()

# Install rules (targets, assets, QML, plugins)
include(WaveyInstall)
