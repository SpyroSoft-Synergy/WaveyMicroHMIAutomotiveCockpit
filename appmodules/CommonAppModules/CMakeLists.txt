# CommonAppModules - Shared QML components for Wavey applications
#
# These modules are pure QML and were previously packaged via Conan by copying
# the source directories into an "imports/wavey" folder. We keep the same
# layout here to avoid QRC-only imports and match the original runtime behavior.

if(NOT QT_QML_OUTPUT_DIRECTORY)
    set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
endif()

set(WAVEY_QML_IMPORT_ROOT "${QT_QML_OUTPUT_DIRECTORY}/wavey")

function(copy_wavey_module TARGET_NAME SOURCE_SUBDIR DEST_SUBDIR)
    add_custom_target(${TARGET_NAME}
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_CURRENT_LIST_DIR}/src/${SOURCE_SUBDIR}
            ${WAVEY_QML_IMPORT_ROOT}/${DEST_SUBDIR}
        COMMENT "Deploying wavey.${DEST_SUBDIR} QML module"
    )
endfunction()

copy_wavey_module(WaveyComponents components components)
copy_wavey_module(WaveyGestures gestures gestures)
copy_wavey_module(WaveyViewmodels viewmodels viewmodels)
copy_wavey_module(WaveyWindows windows windows)
