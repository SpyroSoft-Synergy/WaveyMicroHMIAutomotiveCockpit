set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Quick QuickControls2 REQUIRED)

qt_add_executable(weather_testbed main.cpp)

target_link_libraries(weather_testbed PRIVATE 
    Qt6::Quick 
    Qt6::QuickControls2
    WeatherServer
)

# QML import paths - use monorepo's shared QML output directory
list(APPEND QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY})
list(APPEND QML_IMPORT_PATH ${CMAKE_CURRENT_LIST_DIR}/imports)
list(APPEND QML_IMPORT_PATH ${CMAKE_CURRENT_BINARY_DIR}/imports)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

set(QML_IMPORT_PATH ${QML_IMPORT_PATH}
    CACHE STRING "QML import paths for Qt Creator"
    FORCE
)

target_compile_definitions(weather_testbed PRIVATE APPID="${CMAKE_PROJECT_NAME}")
set_target_properties(weather_testbed PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Copy app code for testbed
add_dependencies(weather_testbed weather_copy_appcode)

# Dummy target for imports visibility in IDE
file(GLOB_RECURSE DUMMY_IMPORTS "${CMAKE_CURRENT_LIST_DIR}/imports/*")
add_custom_target(weather_imports SOURCES ${DUMMY_IMPORTS})

# Copy testbed extras if they exist
if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/testbedextras)
    add_custom_target(weather_copy_testbedextras
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_CURRENT_LIST_DIR}/testbedextras 
            ${CMAKE_BINARY_DIR}/imports/testbedextras)
    add_dependencies(weather_testbed weather_copy_testbedextras)
endif()
