@echo off

set BUILD_TYPE=Release
set ARCH=x64

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=icu
set LIB_PATH=%cd%

set LIB_SRC_PATH=%LIB_PATH%\%LIB_DIR%
REM - TODO: set/use build dir with msbuild (?)
REM set BUILD_PATH=%LIB_PATH%\build
REM - TODO: set/use install dir with msbuild (?)
REM set INSTALL_PATH=%LIB_PATH%\install

set PYTHON_PATH=%USERPROFILE%\AppData\Local\Programs\Python\Python37


if "%LIB_DIR%" == "" (
    echo 'LIB_DIR' is not set!
    pause
    exit /b
)

:: Set default build configuration Release|64 (if not set)
if not "%ARCH%" == "Win32" (
    set ARCH=x64
)
if not "%BUILD_TYPE%" == "Debug" (
    set BUILD_TYPE=Release
)


REM echo Build path: %BUILD_PATH%
REM if not exist %BUILD_PATH% (
    REM mkdir %BUILD_PATH%
REM )
REM cd %BUILD_PATH%

:: Add Python to path
REM - TODO: should check it is not already in PATH
set PATH=%PYTHON_PATH%;%PATH%


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

msbuild %LIB_SRC_PATH%\source\allinone\allinone.sln /p:Configuration=%BUILD_TYPE% /p:Platform=%ARCH% /p:SkipUWP=true

pause
exit /b
