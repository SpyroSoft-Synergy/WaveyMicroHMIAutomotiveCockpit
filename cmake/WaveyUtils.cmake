# WaveyUtils.cmake - CMake utilities for Wavey project
#
# This module provides utility functions for building the Wavey HMI system.
# Replaces the Conan-based build system with native CMake functionality.

# Function that configures Qt Application Manager asset deployment
# Deploys sysUI folder as well as configuration files
function(deploy_appman_assets TARGET ASSETS_SOURCE_DIR ASSETS_DESTINATION_DIR)
  add_custom_target(
    copy_assets_${TARGET}
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${ASSETS_SOURCE_DIR}
            ${ASSETS_DESTINATION_DIR}
    COMMENT "Copying assets for ${TARGET}")

  add_dependencies(${TARGET} copy_assets_${TARGET})

  if(ANDROID)
    deploy_monorepo_assets(${TARGET} ${ASSETS_DESTINATION_DIR})
    set_target_properties(${TARGET} PROPERTIES QT_QML_ROOT_PATH
                                               ${ASSETS_DESTINATION_DIR})
  endif()
endfunction(deploy_appman_assets)

# Function to deploy built applications and QML modules
# Replaces the conan imports functionality
function(deploy_monorepo_assets TARGET ASSETS_DESTINATION_DIR)
  # Deploy QML plugins from the shared QML output directory
  add_custom_target(
    copy_qml_plugins_${TARGET}
    COMMAND
      ${CMAKE_COMMAND} -E copy_directory ${QT_QML_OUTPUT_DIRECTORY}
      ${ASSETS_DESTINATION_DIR}/qml-plugins
    COMMENT "Deploying QML plugins for ${TARGET}")
  
  add_dependencies(copy_assets_${TARGET} copy_qml_plugins_${TARGET})

  # This is workaround for https://bugreports.qt.io/browse/QTBUG-107627
  add_custom_command(
    TARGET copy_assets_${TARGET}
    POST_BUILD
    COMMAND
      "${CMAKE_COMMAND}" -DROOT_DIRECTORY="${ASSETS_DESTINATION_DIR}" -P
      "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/helpers/dummy_files_creator.cmake")
endfunction(deploy_monorepo_assets)

# Function to deploy a single built application to the builtinApps directory
function(deploy_builtin_app APP_NAME SOURCE_DIR DESTINATION_DIR)
  add_custom_command(
    TARGET ${APP_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      ${SOURCE_DIR}
      ${DESTINATION_DIR}/builtinApps/com.spyrosoft.${APP_NAME}
    COMMENT "Deploying ${APP_NAME} to builtinApps"
  )
endfunction(deploy_builtin_app)

# Utility function to get the current platform profile name
# Useful for platform-specific configuration
function(get_wavey_platform_profile OUTPUT_VAR)
  if(ANDROID)
    if(NOT ANDROID_ABI)
      message(FATAL_ERROR "Android ABI not defined!")
    endif()
    set(${OUTPUT_VAR} android_${ANDROID_ABI} PARENT_SCOPE)
  elseif(WIN32)
    set(${OUTPUT_VAR} windows PARENT_SCOPE)
  elseif(UNIX AND NOT APPLE)
    set(${OUTPUT_VAR} linux PARENT_SCOPE)
  elseif(APPLE)
    set(${OUTPUT_VAR} macos PARENT_SCOPE)
  else()
    set(${OUTPUT_VAR} unknown PARENT_SCOPE)
  endif()
endfunction(get_wavey_platform_profile)
