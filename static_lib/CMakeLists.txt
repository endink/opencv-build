cmake_minimum_required(VERSION 3.26)
project(opencv_static_lib)


option(USE_MSVC_STATIC_RUNTIME "Use static crt or not" OFF)
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
set(WITH_WIN32UI OFF)
set(WITH_QT OFF)
set(WITH_GTK OFF)
set(WITH_FFMPEG OFF)
set(WITH_VTK OFF)
SET(BUILD_ZLIB OFF)
set(WITH_ONNX OFF)
set(WITH_DNN OFF)
# Suppress C++23 deprecation warnings
add_compile_definitions(_SILENCE_ALL_CXX23_DEPRECATION_WARNINGS)

# Add source
add_subdirectory(${OPENCV_SOURCE_DIR} opencv)

# Bundle the static library
include(bundle_static_library.cmake)
bundle_static_library(${PROJECT_NAME} opencv_world)


# Install the static library
install(
    FILES $<TARGET_PROPERTY:opencv_world,OPENCV_INCLUDE_INSTALL_PATH>
    TYPE INCLUDE
)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${PROJECT_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}
    RENAME ${CMAKE_STATIC_LIBRARY_PREFIX}opencv_world${CMAKE_STATIC_LIBRARY_SUFFIX}
    TYPE LIB
)