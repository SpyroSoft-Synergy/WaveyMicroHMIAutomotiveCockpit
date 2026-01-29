# AppModules - Shared QML modules for Wavey applications

add_subdirectory(CommonAppModules)
if(BUILD_TESTBED)
    add_subdirectory(TestbedModules)
endif()
