cmake_minimum_required(VERSION 3.1)
project(QMLTests)

find_package(Qt6 COMPONENTS QuickTest REQUIRED)

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(SOURCE_FILES
    main.cpp
)

set(HEADER_FILES
)

set(QML_TESTCASE_FILES
    testcases/tst_GestureRecognizer.qml
)

if (WIN32)
    set(PATH_SEPARATOR ";")
else()
    set(PATH_SEPARATOR ":")
endif()

add_definitions(-DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/testcases"
                -DIMPORT_PATH="${CMAKE_BINARY_DIR}/src/wavey-ivi/qml-plugins${PATH_SEPARATOR}${CMAKE_BINARY_DIR}/src/wavey-ivi/sysUI")

add_executable(${PROJECT_NAME} ${SOURCE_FILES} ${HEADER_FILES} ${QML_TESTCASE_FILES})
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::QuickTest)
