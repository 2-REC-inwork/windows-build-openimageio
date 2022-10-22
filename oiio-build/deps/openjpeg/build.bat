@echo off
setlocal enabledelayedexpansion

set BUILD_TYPE=Release
set ARCH=x64
REM set BUILD_SHARED_LIBS=OFF

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=openjpeg-2.4.0
set LIB_PATH=%cd%

set DEPS_PATH=%LIB_PATH%/deps
set ZLIB_PATH=%DEPS_PATH%/zlib
set PNG_PATH=%DEPS_PATH%/png
set TIFF_PATH=%DEPS_PATH%/tiff
set LCMS2_PATH=%DEPS_PATH%/lcms2

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
if "%BUILD_SHARED_LIBS%" == "" (
    set BUILD_SHARED_LIBS=ON
)

:: Build Options
set "BUILD_OPTIONS="
if not "%BUILD_SHARED_LIBS%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DBUILD_SHARED_LIBS=%BUILD_SHARED_LIBS%
)

if not "%ZLIB_PATH%" == "" (
    REM set BUILD_OPTIONS=%BUILD_OPTIONS% -DZLIB_ROOT="%ZLIB_PATH%/%ARCH%/%BUILD_TYPE%"
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DZLIB_INCLUDE_DIR="%ZLIB_PATH%/%ARCH%/%BUILD_TYPE%/include"
    if "%BUILD_SHARED_LIBS%" == "ON" (
        if "%BUILD_TYPE%" == "Debug" (
            set ZLIB_LIBRARY=zlibd.lib
        ) else (
            set ZLIB_LIBRARY=zlib.lib
        )
    ) else (
        if "%BUILD_TYPE%" == "Debug" (
            set ZLIB_LIBRARY=zlibstaticd.lib
        ) else (
            set ZLIB_LIBRARY=zlibstatic.lib
        )
    )
    set BUILD_OPTIONS=!BUILD_OPTIONS! -DZLIB_LIBRARY="%ZLIB_PATH%/%ARCH%/%BUILD_TYPE%/lib/!ZLIB_LIBRARY!"
)

if not "%PNG_PATH%" == "" (
    REM set BUILD_OPTIONS=%BUILD_OPTIONS% -DPNG_ROOT="%PNG_PATH%/%ARCH%/%BUILD_TYPE%"
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DPNG_PNG_INCLUDE_DIR="%PNG_PATH%/%ARCH%/%BUILD_TYPE%/include"
    if "%BUILD_SHARED_LIBS%" == "ON" (
        if "%BUILD_TYPE%" == "Debug" (
            set PNG_LIBRARY=libpng16d.lib
        ) else (
            set PNG_LIBRARY=libpng16.lib
        )
    ) else (
        if "%BUILD_TYPE%" == "Debug" (
            set PNG_LIBRARY=libpng16_staticd.lib
        ) else (
            set PNG_LIBRARY=libpng16_static.lib
        )
    )
    set BUILD_OPTIONS=!BUILD_OPTIONS! -DPNG_LIBRARY="%PNG_PATH%/%ARCH%/%BUILD_TYPE%/lib/!PNG_LIBRARY!"
)

REM - TODO: diff lib for static/shared !?
if not "%TIFF_PATH%" == "" (
    REM - TIFF_ROOT seems to be ignored
    REM set BUILD_OPTIONS=%BUILD_OPTIONS% -DTIFF_ROOT="%TIFF_PATH%/%ARCH%/%BUILD_TYPE%"
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DTIFF_INCLUDE_DIR="%TIFF_PATH%/%ARCH%/%BUILD_TYPE%/include"
    if "%BUILD_TYPE%" == "Debug" (
        set TIFF_LIBRARY=tiffd.lib
    ) else (
        set TIFF_LIBRARY=tiff.lib
    )
    set BUILD_OPTIONS=!BUILD_OPTIONS! -DTIFF_LIBRARY="%TIFF_PATH%/%ARCH%/%BUILD_TYPE%/lib/!TIFF_LIBRARY!"
)

REM - TODO: diff lib for static/shared !?
if not "%LCMS2_PATH%" == "" (
    REM set BUILD_OPTIONS=%BUILD_OPTIONS% -DLCMS2_ROOT="%LCMS2_PATH%/%ARCH%/%BUILD_TYPE%"
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DLCMS2_INCLUDE_DIR="%LCMS2_PATH%/%ARCH%/%BUILD_TYPE%/include"
    set BUILD_OPTIONS=!BUILD_OPTIONS! -DLCMS2_LIBRARY="%LCMS2_PATH%/%ARCH%/%BUILD_TYPE%/lib/lcms2.lib"
)

REM set BUILD_OPTIONS=%BUILD_OPTIONS% -Wno-dev


echo BUILD_OPTIONS: %BUILD_OPTIONS%


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