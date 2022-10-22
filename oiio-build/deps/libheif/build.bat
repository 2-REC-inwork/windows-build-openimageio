@echo off

set BUILD_TYPE=Release
set ARCH=x64

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=libheif-1.12.0
set LIB_PATH=%cd%

set LIBDE265_PATH=%LIB_PATH:\=/%/deps/libde265/%ARCH%/%BUILD_TYPE%
set X265_PATH=%LIB_PATH:\=/%/deps/x265/%ARCH%/%BUILD_TYPE%
set AOM_PATH=%LIB_PATH:\=/%/deps/aom/%ARCH%/%BUILD_TYPE%
set JPEG_PATH=%LIB_PATH:\=/%/deps/jpegturbo/%ARCH%/%BUILD_TYPE%


set LIB_SRC_PATH=%LIB_PATH%\%LIB_DIR%
set BUILD_PATH=%LIB_PATH%\build
set INSTALL_PATH=%LIB_PATH%\install


if "%LIB_DIR%" == "" (
    echo 'LIB_DIR' is not set!
    pause
    exit /b
)


echo Build path: %BUILD_PATH%
if not exist %BUILD_PATH% (
    mkdir %BUILD_PATH%
)
cd %BUILD_PATH%


:: Set default build configuration Release|64 (if not set)
if not "%ARCH%" == "Win32" (
    set ARCH=x64
)
if not "%BUILD_TYPE%" == "Debug" (
    set BUILD_TYPE=Release
)


REM - TODO: get path from input argument
if "%VCVARS_PATH%" == "" (
    set VCVARS_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build"
)
:: ~Hack to remove quotes (will be added later)
set VCVARS_PATH=%VCVARS_PATH:"=%

if "%ARCH%" == "x64" (
    set VCVARS=vcvars64.bat
) else (
    set VCVARS=vcvars32.bat
)


:: Initialise VC environment
call "%VCVARS_PATH%\%VCVARS%"


echo.
echo Configure
cmake -G "Visual Studio 16 2019" -A %ARCH% ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%" ^
 -DLIBDE265_INCLUDE_DIR="%LIBDE265_PATH%/include" ^
 -DLIBDE265_LIBRARY="%LIBDE265_PATH%/lib/libde265.lib" ^
 -DX265_INCLUDE_DIR="%X265_PATH%/include" ^
 -DX265_LIBRARY="%X265_PATH%/lib/libx265.lib" ^
 -DAOM_INCLUDE_DIR="%AOM_PATH%/include" ^
 -DAOM_LIBRARY="%AOM_PATH%/lib/aom.lib" ^
 -DJPEG_INCLUDE_DIR="%JPEG_PATH%/include" ^
 -DJPEG_LIBRARY="%JPEG_PATH%/lib/turbojpeg-static.lib" ^
 "%LIB_SRC_PATH%"

REM - TODO: add check for error


echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b