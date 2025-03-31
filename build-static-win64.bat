@echo off
if "%OPENCV_VERSION%"=="" (
    set "OPENCV_VERSION=4.11.0"
)

set "WIN_SDK_VERSION=10.0.22621.0"

pushd %~dp0
set SCRIPT_DIR=%cd%
echo Work Dir: %SCRIPT_DIR%

@rem cmake env
set "OUTPUT_DIR=%SCRIPT_DIR%/output"
set "ARCHIVE_DIR=%OUTPUT_DIR%/archive"
set "ARCHIVE_NAME=opencv-win64-%ONNXRUNTIME_VERSION%"

set "SOURCE_DIR=%SCRIPT_DIR%/static_lib"
set "BUILD_DIR=build/static_lib"
set "OUTPUT_DIR=output/static_lib"
set "OPENCV_SOURCE_DIR=%SCRIPT_DIR%/opencv"

SET "CMAKE_OPTIONS=^
    -DBUILD_opencv_python3=OFF ^
    -DBUILD_opencv_python2=OFF ^
    -DBUILD_opencv_python_bindings_generator=OFF ^
    -DBUILD_java_bindings_gen=OFF ^
    -DBUILD_gapi=OFF ^
    -DWITH_PROTOBUF=OFF ^
    -DWITH_CUDA=OFF ^
    -DBUILD_opencv_face=OFF ^
    -DBUILD_opencv_js=OFF ^
    -DBUILD_opencv_objdetect=OFF "
@rem set "CMAKE_OPTIONS=-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL -DONNX_USE_MSVC_STATIC_RUNTIME=OFF -Dprotobuf_MSVC_STATIC_RUNTIME=OFF -Dgtest_force_shared_crt=ON -Donnxruntime_BUILD_UNIT_TESTS=OFF "

if not exist "%OPENCV_SOURCE_DIR%" (

    @echo "Clone opencv (%OPENCV_VERSION%) ..."

    git clone -b %OPENCV_VERSION% --depth=1 --recursive https://github.com/opencv/opencv.git || goto failed

)

@echo on
cmake -S %SOURCE_DIR% ^
    -G "Visual Studio 17 2022" ^
    -A x64 ^
    -B %BUILD_DIR% ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_CONFIGURATION_TYPES=Release ^
    -D CMAKE_INSTALL_PREFIX=%OUTPUT_DIR% ^
    -D OPENCV_SOURCE_DIR=%OPENCV_SOURCE_DIR% ^
    -D CMAKE_SYSTEM_VERSION=%WIN_SDK_VERSION% ^
    --compile-no-warning-as-error ^
    %CMAKE_OPTIONS%

cmake --build %BUILD_DIR% ^
    --config Release ^
    --parallel 8 ^
    %CMAKE_BUILD_OPTIONS%

cmake --install %BUILD_DIR% --config Release

pause
exit


:rm_rebuild_dir
if "%~1"=="" (
echo build folder is null !!
) else (
del /f /s /q "%~1\*.*"  >nul 2>&1
rd /s /q  "%~1" >nul 2>&1
)
goto:eof

:failed
echo Error !!!
exit
goto:eof

