cmake_minimum_required(VERSION 3.26)
project(opencv_static_lib)


option(USE_MSVC_STATIC_RUNTIME "Use static crt or not" OFF)
option(BUNDLE_LIB "bundle static libs" OFF)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "BUILD SHARED LIBS")
set(BUILD_TESTS OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_PERF_TESTS OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_EXAMPLES OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_PACKAGE OFF CACHE BOOL "OPENC OPTIONS")
if(MSVC)
    set(BUILD_WITH_STATIC_CRT ${USE_MSVC_STATIC_RUNTIME})
endif()
set(BUILD_JAVA OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_KOTLIN_EXTENSIONS OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_world ON CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_dnn OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_highgui OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_java_bindings_generator OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_python_bindings_generator OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_java_bindings_gen OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_photo OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_stitching OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_ts OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_ml OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_videostab OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_video OFF CACHE BOOL "OPENC OPTIONS")
#set(BUILD_gapi OFF)
set(BUILD_opencv_python3 OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_python2 OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_face OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_js OFF CACHE BOOL "OPENC OPTIONS")
set(BUILD_opencv_objdetect OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_WIN32UI OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_QT OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_GTK OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_FFMPEG OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_VTK OFF CACHE BOOL "OPENC OPTIONS")
SET(BUILD_ZLIB ON CACHE BOOL "OPENC OPTIONS")
set(WITH_ONNX OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_DNN OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_GSTREAMER OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_ITT OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_PROTOBUF OFF CACHE BOOL "OPENC OPTIONS")
set(WITH_CUDA OFF CACHE BOOL "OPENC OPTIONS")

message(STATUS "BUILD_SHARED_LIBS: ${BUILD_SHARED_LIBS}")
#set(OPENCV_INCLUDE_INSTALL_PATH "${CMAKE_INSTALL_PREFIX}/include")
# Suppress C++23 deprecation warnings
add_compile_definitions(_SILENCE_ALL_CXX23_DEPRECATION_WARNINGS)

if(MSVC)
    if(USE_MSVC_STATIC_RUNTIME)
        message("------------------ Use Static MSVC CRT ------------------")
        set(BUILD_WITH_STATIC_CRT ON)
        set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)

        add_compile_options(
          $<$<CONFIG:>:/MT> #---------|
          $<$<CONFIG:Debug>:/MTd> #---|-- Statically link the runtime libraries
          $<$<CONFIG:Release>:/MT> #--|
          $<$<CONFIG:RelWithDebInfo>:/MT>
          $<$<CONFIG:MinSizeRel>:/MT>
        )
    else()
    message("------------------ Use Dynamic MSVC CRT ------------------")
        set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
        set(BUILD_WITH_STATIC_CRT OFF)
        add_compile_options(
          $<$<CONFIG:>:/MD> #---------|
          $<$<CONFIG:Debug>:/MDd> #---|-- Statically link the runtime libraries
          $<$<CONFIG:Release>:/MD> #--|
          $<$<CONFIG:RelWithDebInfo>:/MD>
          $<$<CONFIG:MinSizeRel>:/MD>
        )
    endif()
endif()

# Add source
add_subdirectory(${OPENCV_SOURCE_DIR} opencv)


get_target_property(alias opencv_world ALIASED_TARGET)

# Install the static library
#install(
#    FILES $<TARGET_PROPERTY:opencv_world,OPENCV_INCLUDE_INSTALL_PATH>
#    TYPE INCLUDE
#)
if(BUNDLE_LIB AND NOT BUILD_SHARED_LIBS)

    # Bundle the static library
    include(bundle_static_library.cmake)
    bundle_static_library(${PROJECT_NAME} opencv_world)

    install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${PROJECT_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}
        RENAME ${CMAKE_STATIC_LIBRARY_PREFIX}opencv_bundled${CMAKE_STATIC_LIBRARY_SUFFIX}
        TYPE LIB
    )
endif()