#!/usr/bin/env bash

set -e
SOURCE_DIR=${SOURCE_DIR:=static_lib}
BUILD_DIR=${BUILD_DIR:=build}
OUTPUT_DIR=${OUTPUT_DIR:=output/static_lib}
OPENCV_SOURCE_DIR=${OPENCV_SOURCE_DIR:=opencv}
OPENCV_VERSION=${OPENCV_VERSION:=4.11.0}
CMAKE_OPTIONS=$CMAKE_OPTIONS
CMAKE_BUILD_OPTIONS=$CMAKE_BUILD_OPTIONS

echo "CMAKE_OPTIONS: $CMAKE_OPTIONS"

case $(uname -s) in
Darwin) CPU_COUNT=$(sysctl -n hw.physicalcpu) ;;
Linux) CPU_COUNT=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}') ;;
*) CPU_COUNT=$NUMBER_OF_PROCESSORS ;;
esac
PARALLEL_JOB_COUNT=${PARALLEL_JOB_COUNT:=$CPU_COUNT}

cd $(dirname $0)

(
    cd $OPENCV_SOURCE_DIR
)

cmake \
    -S $SOURCE_DIR \
    -B $BUILD_DIR \
    -D WITH_IPP=OFF \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CONFIGURATION_TYPES=Release \
    -D CMAKE_INSTALL_PREFIX=$OUTPUT_DIR \
    -D OPENCV_SOURCE_DIR=$(pwd)/$OPENCV_SOURCE_DIR \
    --compile-no-warning-as-error \
    $CMAKE_OPTIONS

cmake \
    --build $BUILD_DIR \
    --config Release \
    --parallel $PARALLEL_JOB_COUNT \
    $CMAKE_BUILD_OPTIONS

cmake --install $BUILD_DIR --config Release

# cmake \
#     -S $SOURCE_DIR/tests \
#     -B $BUILD_DIR/tests \
#     -D ONNXRUNTIME_SOURCE_DIR=$(pwd)/$ONNXRUNTIME_SOURCE_DIR \
#     -D ONNXRUNTIME_INCLUDE_DIR=$(pwd)/$OUTPUT_DIR/include \
#     -D ONNXRUNTIME_LIB_DIR=$(pwd)/$OUTPUT_DIR/lib
# cmake --build $BUILD_DIR/tests
# ctest --test-dir $BUILD_DIR/tests --build-config Debug --verbose --no-tests=error
