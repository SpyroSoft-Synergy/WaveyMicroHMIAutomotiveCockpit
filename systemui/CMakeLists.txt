# SystemUI - Main Wavey HMI Application
#
# When built as part of monorepo, this inherits project settings from root CMakeLists.txt
# Dependencies (WaveyStyle, applications) are already built by parent project

add_subdirectory("src")

# Tests - only build when requested
option(BUILD_SYSTEMUI_TESTS "Build SystemUI tests" OFF)
if(BUILD_SYSTEMUI_TESTS)
    add_subdirectory("tests")
endif()
