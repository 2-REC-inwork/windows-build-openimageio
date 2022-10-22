@echo off

set BUILD_TYPE=Release
set ARCH=x64

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=openvdb-8.1.0
set LIB_PATH=%cd%

set DEPS_PATH=%LIB_PATH%\deps
set DEPS_PATH=%DEPS_PATH:\=/%

set BOOST_PATH=%USERPROFILE:\=/%/Documents/boost/boost_src
REM - TODO: directory structure: tbb/include + tbb/lib, with mixed dbg+rel libraries (could/should be separated using ARCH+BUILD_TYPE)
set TBB_PATH=%DEPS_PATH%/tbb
set BLOSC_PATH=%DEPS_PATH%/blosc/%ARCH%/%BUILD_TYPE%
set ZLIB_PATH=%DEPS_PATH%/zlib/%ARCH%/%BUILD_TYPE%

set LIB_SRC_PATH=%LIB_PATH%\%LIB_DIR%
set BUILD_PATH=%LIB_PATH%\build
set INSTALL_PATH=%LIB_PATH%\install\%BUILD_TYPE%


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
 -DBOOST_ROOT="%BOOST_PATH%" ^
 -DBlosc_ROOT="%BLOSC_PATH%" ^
 -DZLIB_ROOT="%ZLIB_PATH%" ^
 -DTBB_ROOT="%TBB_PATH%" ^
 "%LIB_SRC_PATH%"

REM - TODO: add check for error

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b