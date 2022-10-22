@echo off

set BUILD_TYPE=Release
set ARCH=x64

set LIB_DIR=bzip2-bzip2-1.0.8
set LIB_PATH=%cd%


set LIB_SRC_PATH=%LIB_PATH%\%LIB_DIR%
set INSTALL_PATH=%LIB_PATH%\install


:: Set default build configuration Release|64 (if not set)
if not "%ARCH%" == "Win32" (
    set ARCH=x64
)
if not "%BUILD_TYPE%" == "Debug" (
    set BUILD_TYPE=Release
)

cd %LIB_SRC_PATH%

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


REM - TODO: see if can configure anything... debug|release? 32|64?


:: Build
echo.
echo Build
REM nmake -f makefile.msc
nmake -f makefile.msc lib

REM - TODO: add check for error


REM - TODO: copy/move generated files to 'INSTALL_PATH'
REM - => modify makefile?


pause
exit /b