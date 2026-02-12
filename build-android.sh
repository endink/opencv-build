#!/bin/bash
# Build Android
#USE AGE: bash ./build_opecv_android.sh <ndk_version:r25b> <opencv source dir> <build dir> <build shared lib>

script_dir=$(cd $(dirname $0);pwd)

ndk_version=${1:-r27d}
build_type=${2:-static}
ndk_api_level=${3:-29}
android_abi=("arm64-v8a")

build_shared_lib=OFF

CMAKE_OPTIONS=$CMAKE_OPTIONS
CMAKE_BUILD_OPTIONS=$CMAKE_BUILD_OPTIONS
source_dir="${script_dir}/static_lib"
build_dir="${script_dir}/build/android_build"


ANDROID_HOME_DIR=${ANDROID_HOME:-/mnt/e/WSL_Data/AndroidSDK}

#ndk r21e
#refer https://github.com/android/ndk/wiki/Unsupported-Downloads
ndk_path=${ANDROID_HOME_DIR}/ndk/android-ndk-${ndk_version}

if [ "${build_type}" == "shared" ];then
    build_shared_lib=ON
fi

output_dir=${OUTPUT_DIR}

if [ -z "${output_dir}" ]; then
    if [ "${build_shared_lib}" == "OFF" ]
    then
        output_dir=/mnt/f/Works/Cpp/opencv-build/output/android-${ndk_api_level}-ndk-${ndk_version}-static
    else
        output_dir=/mnt/f/Works/Cpp/opencv-build/output/android-${ndk_api_level}-ndk-${ndk_version}-shared
    fi
fi


echo "Cmake Options: $CMAKE_OPTIONS"
echo "Build Shared Lib: $build_shared_lib"
echo "NDK Version: $ndk_version"
echo "Output DIR: ${output_dir}"

if [ ! -d "${output_dir}" ];then
    mkdir "${output_dir}"
fi



if [ "$GITHUB_ACTIONS" == "true" ]; then
    echo "Build All ABI for android !"
    android_abi=("armeabi-v7a" "arm64-v8a")
fi



if [ -d "${build_dir}" ]
then
#rm -rf ./build
echo "build folder existed."
else
 mkdir "${build_dir}" 
fi

case $(uname -s) in
    Darwin) CPU_COUNT=$(sysctl -n hw.physicalcpu) ;;
    Linux) CPU_COUNT=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}') ;;
    *) CPU_COUNT=$NUMBER_OF_PROCESSORS ;;
    esac
    PARALLEL_JOB_COUNT=${PARALLEL_JOB_COUNT:=$CPU_COUNT}

for ABI in "${android_abi[@]}"
do
    echo "Build ${ABI} (android-${ndk_api_level})"
    echo "........................................"
    
    cmake \
    -S "${source_dir}" \
    -B "${build_dir}" \
    -DENABLE_CXX11=ON \
    -DOPENCV_SOURCE_DIR="${script_dir}/opencv" \
    -DCMAKE_SHARED_LINKER_FLAGS="-fvisibility=hidden -Wl,--exclude-libs,libc++_static.a -Wl,--exclude-libs,libc++abi.a" \
    \
    -DCMAKE_SKIP_RPATH=TRUE \
    -DCMAKE_SKIP_BUILD_RPATH=TRUE \
    -DCMAKE_SKIP_INSTALL_RPATH=TRUE \
    -DBUILD_gapi=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CONFIGURATION_TYPES=Release \
    -DBUILD_java_bindings_gen=OFF \
    -DBUILD_opencv_python_bindings_generator=OFF \
    -DBUILD_SHARED_LIBS=${build_shared_lib} \
    -DBUILD_FAT_JAVA_LIB=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_JAVA=OFF \
    -DBUILD_ANDROID_EXAMPLES=OFF \
    -DBUILD_opencv_world=ON \
    -DBUILD_opencv_python3=OFF \
    -DBUILD_opencv_python2=OFF \
    -DWITH_PROTOBUF=OFF \
    -DWITH_GSTREAMER=OFF \
    -DWITH_GTK=OFF \
    -DWITH_DNN=OFF \
    -DWITH_ITT=OFF \
    -DBUILD_opencv_ml=OFF \
    -DBUILD_opencv_highgui=OFF \
    -DBUILD_opencv_videostab=OFF \
    -DBUILD_opencv_video=OFF \
    -DBUILD_opencv_photo=OFF \
    -DBUILD_opencv_stitching=OFF \
    -DBUILD_opencv_objdetect=OFF \
    -DCMAKE_CXX_FLAGS_RELEASE=-g0 \
    \
    -DBUILD_opencv_aruco=OFF -DBUILD_opencv_bgsegm=OFF -DBUILD_opencv_bioinspired=OFF \
    -DBUILD_opencv_ccalib=OFF -DBUILD_opencv_datasets=OFF -DBUILD_opencv_dnn=OFF \
    -DBUILD_opencv_dnn_objdetect=OFF -DBUILD_opencv_dpm=OFF -DBUILD_opencv_face=OFF \
    -DBUILD_opencv_fuzzy=OFF -DBUILD_opencv_hfs=OFF -DBUILD_opencv_img_hash=OFF \
    -DBUILD_opencv_js=OFF -DBUILD_opencv_line_descriptor=OFF -DBUILD_opencv_phase_unwrapping=OFF \
    -DBUILD_opencv_plot=OFF -DBUILD_opencv_quality=OFF -DBUILD_opencv_reg=OFF \
    -DBUILD_opencv_rgbd=OFF -DBUILD_opencv_saliency=OFF -DBUILD_opencv_shape=OFF \
    -DBUILD_opencv_structured_light=OFF -DBUILD_opencv_surface_matching=OFF \
    -DBUILD_opencv_xobjdetect=OFF -DBUILD_opencv_xphoto=OFF \
    -DCV_ENABLE_INTRINSICS=ON -DWITH_EIGEN=ON -DWITH_PTHREADS=ON -DWITH_PTHREADS_PF=ON \
    -DWITH_JPEG=ON -DWITH_PNG=ON -DWITH_TIFF=ON \
    \
    -DCMAKE_TOOLCHAIN_FILE=${ndk_path}/build/cmake/android.toolchain.cmake \
    -DANDROID_NDK=${ndk_path} \
    -DANDROID_PLATFORM="android-${ndk_api_level}" \
    -DANDROID_ABI="${ABI}" \
    -DCMAKE_ANDROID_ARCH_ABI="${ABI}" \
    -DCMAKE_ANDROID_STL_TYPE=c++_static \
    -DOPENCV_DISABLE_FILESYSTEM_SUPPORT=ON\
    \
    -DCMAKE_INSTALL_PREFIX=${output_dir} \
    $CMAKE_OPTIONS

    #-DOPENCV_EXTRA_MODULES_PATH=${opencv_contrib_dir}/modules \

    cmake --build "${build_dir}" --config Release --parallel $PARALLEL_JOB_COUNT $CMAKE_BUILD_OPTIONS

    cmake --install "${build_dir}" --config release

    if [ "${build_shared_lib}" == "ON" ];then

        lib_file=${output_dir}/sdk/native/libs/${android_abi}/libopencv_world.so

        if [ -f ${lib_file} ];then
        ${ndk_path}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip ${lib_file}
        readelf -d ${lib_file} | grep "Shared library"
        fi

    fi

done



