@echo off

set BUILD_TYPE=Release
set ARCH=x64
set BUILD_SHARED_LIBS=OFF

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=libwebp-1.2.1
set LIB_PATH=%cd%

set DEPS_PATH=%LIB_PATH:\=/%/deps
set ZLIB_PATH=%DEPS_PATH%/zlib
set PNG_PATH=%DEPS_PATH%/png
set JPEG_PATH=%DEPS_PATH%/jpegturbo
set TIFF_PATH=%DEPS_PATH%/tiff
set GIF_PATH=%DEPS_PATH%/gif
set GLUT_PATH=%DEPS_PATH%/glut
REM - TODO: ADD SDL!
REM set SDL_PATH=%DEPS_PATH%/sdl


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

if "%BUILD_SHARED_LIBS%" == "" (
    set BUILD_SHARED_LIBS=ON
)
set BUILD_OPTIONS=%BUILD_OPTIONS% -DBUILD_SHARED_LIBS=%BUILD_SHARED_LIBS%


:: ZLIB
REM - TODO: rewrite
set BUILD_OPTIONS=%BUILD_OPTIONS% -DZLIB_INCLUDE_DIR="%ZLIB_PATH%/%ARCH%/%BUILD_TYPE%/include"
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

:: PNG
:: ! - PNG uses a special "PNG_PNG_INCLUDE_DIR" variable
set BUILD_OPTIONS=%BUILD_OPTIONS% -DPNG_PNG_INCLUDE_DIR="%PNG_PATH%/%ARCH%/%BUILD_TYPE%/include"
if "%BUILD_SHARED_LIBS%" == "ON" (
    if "%BUILD_TYPE%" == "Release" (
        set PNG_LIB=libpng16.lib
    ) else (
        set PNG_LIB=libpng16d.lib
    )
) else (
    if "%BUILD_TYPE%" == "Release" (
        set PNG_LIB=libpng16_static.lib
    ) else (
        set PNG_LIB=libpng16_staticd.lib
    )
)
set BUILD_OPTIONS=%BUILD_OPTIONS% -DPNG_LIBRARY="%PNG_PATH%/%ARCH%/%BUILD_TYPE%/lib/%PNG_LIB%"

:: JPEG
set BUILD_OPTIONS=%BUILD_OPTIONS% -DJPEG_INCLUDE_DIR="%JPEG_PATH%/%ARCH%/%BUILD_TYPE%/include"
if "%BUILD_SHARED_LIBS%" == "ON" (
    set JPEG_LIB=jpeg.lib
) else (
    set JPEG_LIB=jpeg-static.lib
)
set BUILD_OPTIONS=%BUILD_OPTIONS% -DJPEG_LIBRARY="%JPEG_PATH%/%ARCH%/%BUILD_TYPE%/lib/%JPEG_LIB%"

:: TIFF
set BUILD_OPTIONS=%BUILD_OPTIONS% -DTIFF_INCLUDE_DIR="%TIFF_PATH%/%ARCH%/%BUILD_TYPE%/include"
REM - TODO: ADD STATIC LIBS!?
if "%BUILD_SHARED_LIBS%" == "ON" (
    if "%BUILD_TYPE%" == "Release" (
        set TIFF_LIB=tiff.lib
    ) else (
        set TIFF_LIB=tiffd.lib
    )
) else (
    if "%BUILD_TYPE%" == "Release" (
        set TIFF_LIB=tiff.lib
    ) else (
        set TIFF_LIB=tiffd.lib
    )
)
set BUILD_OPTIONS=%BUILD_OPTIONS% -DTIFF_LIBRARY="%TIFF_PATH%/%ARCH%/%BUILD_TYPE%/lib/%TIFF_LIB%"

:: GIF
set BUILD_OPTIONS=%BUILD_OPTIONS% -DGIF_INCLUDE_DIR="%GIF_PATH%/%ARCH%/%BUILD_TYPE%/include"
REM - TODO: ADD STATIC LIBS!?
REM if "%BUILD_SHARED_LIBS%" == "ON" (
    REM set GIF_LIB=giflib.lib
REM ) else (
    REM set GIF_LIB=giflib.lib
REM )
set GIF_LIB=giflib.lib
set BUILD_OPTIONS=%BUILD_OPTIONS% -DGIF_LIBRARY="%GIF_PATH%/%ARCH%/%BUILD_TYPE%/lib/%GIF_LIB%"

:: GLUT
set BUILD_OPTIONS=%BUILD_OPTIONS% -DGLUT_INCLUDE_DIR="%GLUT_PATH%/%ARCH%/%BUILD_TYPE%/include"
REM - TODO: ADD STATIC LIBS!?
if "%BUILD_SHARED_LIBS%" == "ON" (
    if "%BUILD_TYPE%" == "Release" (
        set GLUT_LIB=freeglut.lib
    ) else (
        set GLUT_LIB=freeglutd.lib
    )
) else (
    if "%BUILD_TYPE%" == "Release" (
        set GLUT_LIB=freeglut_static.lib
    ) else (
        set GLUT_LIB=freeglut_staticd.lib
    )
)
:: ! - "OPENGL_LIBRARY_DIR" ùust be defined else the process will complain about "GLUT_glut_LIBRARY" not found (even if explicitely specified)
REM set BUILD_OPTIONS=%BUILD_OPTIONS% -DGLUT_LIBRARY="%GLUT_PATH%/%ARCH%/%BUILD_TYPE%/lib/%GLUT_LIB%"
set BUILD_OPTIONS=%BUILD_OPTIONS% -DOPENGL_LIBRARY_DIR="%GLUT_PATH%/%ARCH%/%BUILD_TYPE%/lib"

set BUILD_OPTIONS=%BUILD_OPTIONS% -DGLUT_glut_LIBRARY="%GLUT_PATH%/%ARCH%/%BUILD_TYPE%/lib/%GLUT_LIB%"


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