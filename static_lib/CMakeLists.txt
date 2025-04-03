cmake_minimum_required(VERSION 3.26)
project(opencv_static_lib)


option(USE_MSVC_STATIC_RUNTIME "Use static crt or not" OFF)
option(BUILD_BUNDLE "bundle static libs" ON)

set(BUILD_SHARED_LIBS OFF)
set(BUILD_TESTS OFF)
set(BUILD_PERF_TESTS OFF)
set(BUILD_EXAMPLES OFF)
set(BUILD_PACKAGE OFF)
if(MSVC)
    set(BUILD_WITH_STATIC_CRT ${USE_MSVC_STATIC_RUNTIME})
endif()
set(BUILD_JAVA OFF)
set(BUILD_KOTLIN_EXTENSIONS OFF)
set(BUILD_opencv_world ON)
set(BUILD_opencv_dnn OFF)
set(BUILD_opencv_highgui OFF)
set(BUILD_opencv_java_bindings_generator OFF)
set(BUILD_opencv_python_bindings_generator OFF)
set(BUILD_java_bindings_gen OFF)
set(BUILD_opencv_photo OFF)
set(BUILD_opencv_stitching OFF)
set(BUILD_opencv_ts OFF)
set(BUILD_opencv_ml OFF)
set(BUILD_opencv_videostab OFF)
set(BUILD_opencv_video OFF)
#set(BUILD_gapi OFF)
set(BUILD_opencv_python3 OFF)
set(BUILD_opencv_python2 OFF)
set(BUILD_opencv_face OFF)
set(BUILD_opencv_js OFF)
set(BUILD_opencv_objdetect OFF)
set(WITH_WIN32UI OFF)
set(WITH_QT OFF)
set(WITH_GTK OFF)
set(WITH_FFMPEG OFF)
set(WITH_VTK OFF)
SET(BUILD_ZLIB OFF)
set(WITH_ONNX OFF)
set(WITH_DNN OFF)
set(WITH_GSTREAMER OFF)
set(WITH_ITT OFF)
set(WITH_PROTOBUF OFF)
set(WITH_CUDA OFF)


set(OPENCV_INCLUDE_INSTALL_PATH "${CMAKE_INSTALL_PREFIX}/include")
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


# Bundle the static library
include(bundle_static_library.cmake)
bundle_static_library(${PROJECT_NAME} opencv_world)


# Install the static library
#install(
#    FILES $<TARGET_PROPERTY:opencv_world,OPENCV_INCLUDE_INSTALL_PATH>
#    TYPE INCLUDE
#)
if(BUILD_BUNDLE)
    install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${PROJECT_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}
        RENAME ${CMAKE_STATIC_LIBRARY_PREFIX}opencv_bundled${CMAKE_STATIC_LIBRARY_SUFFIX}
        TYPE LIB
    )
endif