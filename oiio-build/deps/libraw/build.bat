@echo off

set BUILD_TYPE=Release
set ARCH=x64
REM set BUILD_SHARED_LIBS=OFF

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=LibRaw-0.20.2
set LIB_PATH=%cd%

REM set ENABLE_OPENMP=ON
REM - TODO: add module (need source)
set ENABLE_LCMS=ON
set ENABLE_EXAMPLES=OFF
REM - TODO: add module (need source)
set ENABLE_RAWSPEED=OFF
REM set RAWSPEED_RPATH=FOLDERNAME
REM set ENABLE_DCRAW_DEBUG=ON



set DEPS_PATH=%LIB_PATH%/deps
set ZLIB_PATH=%DEPS_PATH%/zlib
set JPEG_PATH=%DEPS_PATH%/jpeg


set LIB_SRC_PATH=%LIB_PATH%\%LIB_DIR%
set BUILD_PATH=%LIB_PATH%\build
set INSTALL_PATH=%LIB_PATH%\install\%ARCH%\%BUILD_TYPE%


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


:: Build Options
set "BUILD_OPTIONS="
if not "%ENABLE_RAWSPEED%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DENABLE_OPENMP=%ENABLE_OPENMP%
)
if not "%ENABLE_LCMS%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DENABLE_LCMS=%ENABLE_LCMS%
)
if not "%ENABLE_EXAMPLES%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DENABLE_EXAMPLES=%ENABLE_EXAMPLES%
)
if not "%ENABLE_RAWSPEED%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DENABLE_RAWSPEED=%ENABLE_RAWSPEED%
    if "%ENABLE_RAWSPEED%" == "ON" (
        set BUILD_OPTIONS=%BUILD_OPTIONS% -DRAWSPEED_RPATH=%RAWSPEED_RPATH%
    )
)
if not "%ENABLE_DCRAW_DEBUG%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DENABLE_DCRAW_DEBUG=%ENABLE_DCRAW_DEBUG%
)

if not "%ZLIB_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DZLIB_ROOT="%ZLIB_PATH%/%ARCH%/%BUILD_TYPE%"
)
if not "%JPEG_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DJPEG_ROOT="%JPEG_PATH%/%ARCH%/%BUILD_TYPE%"
)

if not "%BUILD_SHARED_LIBS%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DBUILD_SHARED_LIBS=%BUILD_SHARED_LIBS%
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
 -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%" ^
 %BUILD_OPTIONS% ^
 "%LIB_SRC_PATH%"

REM - TODO: add check for error

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b