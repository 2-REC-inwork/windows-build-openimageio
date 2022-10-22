@echo off

set BUILD_TYPE=Release
set ARCH=x64

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=hdf5
set LIB_PATH=%cd%

:: Tools
set BUILD_TOOLS=OFF
:: Examples
set BUILD_EXAMPLES=OFF
:: High Level API
REM - TODO: want High level API? (default 'ON')
REM BUILD_HL_LIB=ON
:: Fortran
REM - TODO: want Frotran? (default 'OFF')
REM set BUILD_FORTRAN=OFF
:: C++ (default 'ON')
REM set BUILD_CPP_LIB=ON
:: (Java in later versions, not in 1.8.x)


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

set BUILD_OPTIONS=%BUILD_OPTIONS% -DHDF5_BUILD_TOOLS=%BUILD_TOOLS%
set BUILD_OPTIONS=%BUILD_OPTIONS% -DHDF5_BUILD_EXAMPLES=%BUILD_EXAMPLES%
REM set BUILD_OPTIONS=%BUILD_OPTIONS% -DHDF5_BUILD_HL_LIB=%BUILD_HL_LIB%
REM set BUILD_OPTIONS=%BUILD_OPTIONS% -DHDF5_BUILD_FORTRAN=%BUILD_FORTRAN%
REM set BUILD_OPTIONS=%BUILD_OPTIONS% -DHDF5_BUILD_CPP_LIB=%BUILD_CPP_LIB%


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