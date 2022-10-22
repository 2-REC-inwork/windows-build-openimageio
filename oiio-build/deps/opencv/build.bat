@echo off

:: INTERNET ACCESS IS REQUIRED DURING THE EXECUTINO OF THE SCRIPT

set BUILD_TYPE=Release
set ARCH=x64

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
REM - Can use 'opencv-master' if want latest source (but might not be stable)
set LIB_DIR=opencv-4.5.3


set PYTHON3_PATH=%USERPROFILE%\AppData\Local\Programs\Python\Python37
set PYTHON2_PATH=%USERPROFILE%\AppData\Local\Programs\Python\Python27


set LIB_PATH=%cd%

set LIB_SRC_PATH=%LIB_PATH%\%LIB_DIR%
set CONTRIB_PATH=%LIB_PATH%\%LIB_DIR:opencv=opencv_contrib%


set BUILD_PATH=%LIB_PATH%\build
set INSTALL_PATH=%LIB_PATH%\install




REM - TODO: REWRITE!
REM - TODO: get from input arguments
REM set CMAKE_OPTIONS=(-DBUILD_PERF_TESTS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DBUILD_DOCS:BOOL=OFF  -DWITH_CUDA:BOOL=OFF -DBUILD_EXAMPLES:BOOL=OFF -DINSTALL_CREATE_DISTRIB=ON)
REM set CMAKE_OPTIONS=-DBUILD_PERF_TESTS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DBUILD_DOCS:BOOL=OFF  -DWITH_CUDA:BOOL=OFF -DBUILD_EXAMPLES:BOOL=OFF -DINSTALL_CREATE_DISTRIB=ON

set CMAKE_OPTIONS=-DBUILD_PERF_TESTS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DBUILD_DOCS:BOOL=OFF -DWITH_CUDA:BOOL=OFF -DBUILD_EXAMPLES:BOOL=OFF -DINSTALL_CREATE_DISTRIB=ON

REM - TODO: add both Python versions?
set CMAKE_OPTIONS=%CMAKE_OPTIONS% -DPYTHON3_EXECUTABLE="%PYTHON3_PATH%\python.exe"
set CMAKE_OPTIONS=%CMAKE_OPTIONS% -DPYTHON2_EXECUTABLE="%PYTHON2_PATH%\python.exe"



if "%LIB_DIR%" == "" (
    echo 'LIB_DIR' is not set!
    pause
    exit /b
)



REM - TODO: add automated download...
REM - REM - TODO: should not clone from 'master' (?)
REM - if not exist "%LIB_SRC_PATH%" (
REM -     echo "Cloning OpenCV"
REM -     REM git clone https://github.com/opencv/opencv.git %LIB_SRC_PATH%
REM - ) else (
REM -     echo "OpenCV found"
REM -     cd %LIB_SRC_PATH%
REM -     REM git pull --rebase
REM - )
REM - if not exist "%CONTRIB_PATH%" (
REM -     echo "Cloning OpenCV Contrib"
REM -     REM git clone https://github.com/opencv/opencv_contrib.git %CONTRIB_PATH%
REM - ) else (
REM -     echo "OpenCV Contrib found"
REM -     cd %CONTRIB_PATH%
REM -     REM git pull --rebase
REM - )



REM - TODO: add compiler as input argument
set CMAKE_GENERATOR_OPTIONS=-G "Visual Studio 16 2019" -A %ARCH%



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
cmake %CMAKE_GENERATOR_OPTIONS% ^
 %CMAKE_OPTIONS% ^
 -DBUILD_opencv_world=OFF ^
 -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%" ^
 -DOPENCV_EXTRA_MODULES_PATH="%CONTRIB_PATH%/modules" ^
 "%LIB_SRC_PATH%"

REM - TODO: add check for error

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b