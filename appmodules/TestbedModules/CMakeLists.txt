# TestbedModules - Mock modules for standalone application testing
#
# These modules are pure QML and were previously packaged by copying the
# source directory into "imports/". Keep that layout to match runtime behavior.

if(NOT QT_QML_OUTPUT_DIRECTORY)
    set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
endif()

function(copy_testbed_module TARGET_NAME SOURCE_SUBDIR DEST_SUBDIR)
    add_custom_target(${TARGET_NAME}
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_CURRENT_LIST_DIR}/src/${SOURCE_SUBDIR}
            ${QT_QML_OUTPUT_DIRECTORY}/${DEST_SUBDIR}
        COMMENT "Deploying ${DEST_SUBDIR} QML module"
    )
endfunction()

copy_testbed_module(TestBedModule TestBed TestBed)
copy_testbed_module(TestBedHelpers TestBed/helpers TestBed/helpers)
copy_testbed_module(QtAppManagerMock QtApplicationManager QtApplicationManager)
copy_testbed_module(QtAppManagerAppMock QtApplicationManager/Application QtApplicationManager/Application)
