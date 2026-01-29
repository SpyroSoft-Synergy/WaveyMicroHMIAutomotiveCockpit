set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)


find_package(Qt6 REQUIRED COMPONENTS Core RemoteObjects IfRemoteObjectsHelperPrivate HttpServer)
qt_add_library(MediaPlayerServer
    mediaplayerserver.cpp mediaplayerserver.h
    mediaplayerimpl.cpp mediaplayerimpl.h
)

qt_ifcodegen_extend_target(MediaPlayerServer
    IDL_FILES ../mediaplayer.qface
    TEMPLATE server_qtro)

file(GLOB_RECURSE PLAYLIST_DATA "playlistdata/*")

qt_add_resources(MediaPlayerServer playlistdata FILES ${PLAYLIST_DATA} PREFIX "/" BASE ${CMAKE_CURRENT_LIST_DIR})

set_target_properties(MediaPlayerServer PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})


target_compile_definitions(MediaPlayerServer PUBLIC
    QT_DEPRECATED_WARNINGS
)

target_link_libraries(MediaPlayerServer PUBLIC
     Qt6::RemoteObjects
     Qt6::IfRemoteObjectsHelperPrivate
     Qt6::HttpServer
     Qt6::Core
     MediaPlayerFrontend
)

target_include_directories(MediaPlayerServer PUBLIC
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          )
