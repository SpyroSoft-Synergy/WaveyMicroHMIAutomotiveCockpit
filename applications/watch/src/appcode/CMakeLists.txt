FILE(GLOB_RECURSE APP_SOURCES "${CMAKE_CURRENT_LIST_DIR}/${CMAKE_PROJECT_NAME}/*")
add_custom_target(watch_appcode SOURCES ${APP_SOURCES})
set_target_properties(watch_appcode PROPERTIES EXCLUDE_FROM_ALL 1 EXCLUDE_FROM_DEFAULT_BUILD 1)

list(APPEND QML_IMPORT_PATH ${CMAKE_CURRENT_LIST_DIR}/${CMAKE_PROJECT_NAME})
set(QML_IMPORT_PATH ${QML_IMPORT_PATH}
    CACHE STRING "Append paths to the qml modules so that Qt Creator won't display any kind of errors"
    FORCE
)


if (BUILD_TESTBED)
    add_custom_target(watch_copy_appcode
                  COMMAND ${CMAKE_COMMAND} -E copy_directory
                  ${CMAKE_CURRENT_LIST_DIR}/${CMAKE_PROJECT_NAME} ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME})
endif()
