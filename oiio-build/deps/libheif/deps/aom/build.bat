@echo off

set BUILD_TYPE=Release
set ARCH=x64

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=aom-v3.1.2
set LIB_PATH=%cd%

set NASM_PATH=%LIB_PATH%/nasm-2.15.05
set PERL_PATH=%USERPROFILE%/Documents/perl/perl

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
 -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%" ^
 -DPERL_EXECUTABLE="%PERL_PATH%/bin/perl.exe" ^
 -DENABLE_TESTS=0 ^
 "%LIB_SRC_PATH%"

REM - TODO: add check for error

 REM -DNASM_EXECUTABLE="%NASM_PATH%/nasm.exe" ^

echo.
echo Build
REM cmake --build . --target install --config %BUILD_TYPE%
cmake --build . --config %BUILD_TYPE%

REM - TODO: copy "%BUILD_TYPE%" directory to "install"


pause
exit /b