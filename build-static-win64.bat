@echo off

setlocal enabledelayedexpansion

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
set "ARCHIVE_NAME=opencv-win64-%OPENCV_VERSION%"

set "SOURCE_DIR=%SCRIPT_DIR:\=/%/static_lib"
set "BUILD_DIR=%SCRIPT_DIR:\=/%/build"
set "OUTPUT_DIR=%SCRIPT_DIR:\=/%/output/win64"
set "OPENCV_SOURCE_DIR=%SCRIPT_DIR%/opencv"

if not exist "%OPENCV_SOURCE_DIR%" (

    @echo "Clone opencv (%OPENCV_VERSION%) ..."

    git clone -b %OPENCV_VERSION% --depth=1 --recursive https://github.com/opencv/opencv.git || goto failed

)

if "%CMAKE_OPTIONS%"=="" (
set "CMAKE_OPTIONS=-DBUNDLE_LIB=ON"
)

call:get_core_num

if "%core_num%" == "" (
set core_num=8
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
    --parallel %core_num% ^
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

:get_core_num
set line=0
for /f  %%a in ('wmic cpu get numberofcores') do (
set /a line+=1
if !line!==2 set A=%%a
)
set core_num=%A%
goto:eof

:failed
echo Error !!!
exit
goto:eof

