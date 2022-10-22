@echo off

REM - TODO: set ARCH, BUILD_TYPE, etc
set ARCH=x64
set BUILD_TYPE=Release


set LIBJPEG_PATH=%USERPROFILE%\Documents\jpeg_turbo

set LIBJPEG_SRC_PATH=%LIBJPEG_PATH%\libjpeg-turbo-2.1.1
set BUILD_PATH=%LIBJPEG_PATH%\build
set INSTALL_PATH=%LIBJPEG_PATH%\install



echo Build path: %BUILD_PATH%
if not exist %BUILD_PATH% (
    mkdir %BUILD_PATH%
)
cd %BUILD_PATH%


REM - TODO: get from input argument
set PATH=%USERPROFILE%\Documents\jpeg_turbo\nasm-2.15.05;%PATH%

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
 "%LIBJPEG_SRC_PATH%"

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b