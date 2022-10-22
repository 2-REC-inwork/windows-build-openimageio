@echo off

set BUILD_TYPE=Release
set ARCH=x64
REM set BUILD_SHARED_LIBS=OFF

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=ptex
set LIB_PATH=%cd%

set PTEX_SHA=1b8bc985a71143317ae9e4969fa08e164da7c2e5
set PTEX_VERSION=v2.3.2

set ZLIB_PATH=%LIB_PATH:\=/%/deps/zlib


set LIB_SRC_PATH=%LIB_PATH%\%LIB_DIR%
set BUILD_PATH=%LIB_PATH%\build
set INSTALL_PATH=%LIB_PATH:\=/%/install


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
if "%BUILD_SHARED_LIBS%" == "" (
    set BUILD_SHARED_LIBS=ON
)


set "BUILD_OPTIONS="

REM - TODO: rewrite
set BUILD_OPTIONS=%BUILD_OPTIONS% -DZLIB_INCLUDE_DIR="%ZLIB_PATH%/%ARCH%/%BUILD_TYPE%/include"
REM - TODO: should link to non-static libs when building shared?
if "%BUILD_SHARED_LIBS%" == "ON" (
    if "%BUILD_TYPE%" == "Release" (
        set ZLIB_LIB=zlib.lib
    ) else (
        set ZLIB_LIB=zlibd.lib
    )
) else (
    if "%BUILD_TYPE%" == "Release" (
        set ZLIB_LIB=zlibstatic.lib
    ) else (
        set ZLIB_LIB=zlibstaticd.lib
    )
)
set BUILD_OPTIONS=%BUILD_OPTIONS% -DZLIB_LIBRARY="%ZLIB_PATH%/%ARCH%/%BUILD_TYPE%/lib/%ZLIB_LIB%"


if "%BUILD_SHARED_LIBS%" == "ON" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DPTEX_BUILD_SHARED_LIBS=ON -DPTEX_BUILD_STATIC_LIBS=OFF
) else (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DPTEX_BUILD_SHARED_LIBS=OFF -DPTEX_BUILD_STATIC_LIBS=ON
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

echo BUILD_OPTIONS: %BUILD_OPTIONS%

echo.
echo Configure
cmake -G "Visual Studio 16 2019" -A %ARCH% ^
 -DCMAKE_CXX_STANDARD=17 ^
 -DPTEX_SHA="%PTEX_SHA%" ^
 -DPTEX_VER="%PTEX_VERSION%" ^
 -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%/%ARCH%/%BUILD_TYPE%" ^
 %BUILD_OPTIONS% ^
 "%LIB_SRC_PATH%"

 
REM - TODO: add check for error

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b