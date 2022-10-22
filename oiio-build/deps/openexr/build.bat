@echo off

set BUILD_TYPE=Release
set ARCH=x64

set OPENEXR_PATH=%USERPROFILE%\Documents\openexr

set OPENEXR_SRC_PATH=%OPENEXR_PATH%\openexr-3.1.1
set BUILD_PATH=%OPENEXR_PATH%\build
set INSTALL_PATH=%OPENEXR_PATH%\install

set OPENEXR_DEST_PATH=C:\Users\2-REC\Documents\openexr\build

set LIBS_PATH=%OPENEXR_PATH%\deps

REM - TODO: could use ARCH+BUILD_TYPE variables before definition... (=> find better way)
set ZLIB_PATH=%LIBS_PATH%\zlib\%ARCH%\%BUILD_TYPE%
set IMATH_PATH=%LIBS_PATH%\imath\%ARCH%


if not exist "%BUILD_PATH%" (
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
 -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%" ^
 -DZLIB_ROOT="%ZLIB_PATH%" ^
 -DImath_ROOT="%IMATH_PATH%" ^
 "%OPENEXR_SRC_PATH%"

REM - TODO: add check for error

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b



 REM -DZLIB_LIBRARY="%ZLIB_PATH%\lib\zlib.lib" ^
 REM -DZLIB_INCLUDE_DIR="%ZLIB_PATH%\include" ^
 REM -DImath_ROOT="%IMATH_PATH%" ^
