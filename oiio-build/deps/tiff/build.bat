@echo off
setlocal EnableDelayedExpansion

REM - TODO: add more arguments

set ARCH=x64
set BUILD_TYPE=Release


set TIFF_PATH=%USERPROFILE%\Documents\tiff

set TIFF_SRC_PATH=%TIFF_PATH%\tiff-4.3.0
set BUILD_PATH=%TIFF_PATH%\build
set INSTALL_PATH=%TIFF_PATH%\install

set LIBS_PATH=C:\Users\2-REC\Documents\tiff\deps

set ZLIB_PATH=%LIBS_PATH%\zlib
set JPEG_PATH=%LIBS_PATH%\jpeg
set GLUT_PATH=%LIBS_PATH%\glut


if not exist "%ZLIB_PATH%" (
    echo Zlib not found at '%ZLIB_PATH%'
    set "ZLIB_PATH="
) else (
    echo Found Zlib
)
if not exist "%JPEG_PATH%" (
    echo JPEG not found at '%JPEG_PATH%'
    set "JPEG_PATH="
) else (
    echo Found JPEG
)
if not exist "%GLUT_PATH%" (
    echo GLUT not found at '%GLUT_PATH%'
    set "GLUT_PATH="
) else (
	REM - TODO: check that have 'glut.h'!
    echo Found GLUT
)
echo.


set "BUILD_OPTIONS="
if not "%ZLIB_PATH%" == "" (
    if "%BUILD_TYPE%" == "Release" (
        set BUILD_OPTIONS=!BUILD_OPTIONS! -DZLIB_LIBRARY="%ZLIB_PATH%\%ARCH%\%BUILD_TYPE%\lib\zlib.lib"
    ) else (
        set BUILD_OPTIONS=!BUILD_OPTIONS! -DZLIB_LIBRARY="%ZLIB_PATH%\%ARCH%\%BUILD_TYPE%\lib\zlibd.lib"
    )
    set BUILD_OPTIONS=!BUILD_OPTIONS! -DZLIB_INCLUDE_DIR="%ZLIB_PATH%\%ARCH%\%BUILD_TYPE%\include"
)
if not "%JPEG_PATH%" == "" (
    set BUILD_OPTIONS=!BUILD_OPTIONS! -DJPEG_LIBRARY="%JPEG_PATH%\%BUILD_TYPE%\lib\jpeg.lib"
    set BUILD_OPTIONS=!BUILD_OPTIONS! -DJPEG_INCLUDE_DIR="%JPEG_PATH%\%BUILD_TYPE%\include"
)
if not "%GLUT_PATH%" == "" (
    REM - TODO: should restructure...
    REM set BUILD_OPTIONS=!BUILD_OPTIONS! -DOPENGL_LIBRARY_DIR="%GLUT_PATH%\lib\x64"
    REM set BUILD_OPTIONS=!BUILD_OPTIONS! -DGLUT_glut_LIBRARY="%GLUT_PATH%\lib\x64\freeglut.lib"
    REM set BUILD_OPTIONS=!BUILD_OPTIONS! -DGLUT_INCLUDE_DIR="%GLUT_PATH%\include"

    set BUILD_OPTIONS=!BUILD_OPTIONS! -DOPENGL_LIBRARY_DIR="%GLUT_PATH%\lib\%BUILD_TYPE%\%ARCH%"
    REM set BUILD_OPTIONS=!BUILD_OPTIONS! -DGLUT_glut_LIBRARY="%GLUT_PATH%\lib\%BUILD_TYPE%\%ARCH%\freeglut.lib"
    set BUILD_OPTIONS=!BUILD_OPTIONS! -DGLUT_INCLUDE_DIR="%GLUT_PATH%\include"
)



echo Build path: %BUILD_PATH%
if not exist %BUILD_PATH% (
    mkdir %BUILD_PATH%
)
cd %BUILD_PATH%


call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
echo.


REM echo cmake -S "%TIFF_SRC_PATH%" -B "%BUILD_PATH%" %BUILD_OPTIONS%
REM cmake -S "%TIFF_SRC_PATH%" -B "%BUILD_PATH%" %BUILD_OPTIONS%

echo.
echo Configure
cmake -G "Visual Studio 16 2019" -A %ARCH% ^
 -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%" ^
 %BUILD_OPTIONS% ^
 "%TIFF_SRC_PATH%"

REM - TODO: add check for error

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b