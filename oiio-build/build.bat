@echo off
setlocal enabledelayedexpansion

REM - TO REMOVE
set OIIO_PATH=%cd%


REM - TODO: set ARCH, BUILD_TYPE, etc.
set BUILD_TYPE=Release
set ARCH=x64

set STOP_ON_WARNING=OFF

set BUILD_TOOLS=ON
REM set PYTHON=OFF


set DEPS_PATH=%OIIO_PATH:\=/%/deps

:: Third party libraries paths.
:: ! - Each one needs to be set independently!
REM - TODO: get from input arguments and set defaults if not set
REM set BOOST_PATH=%USERPROFILE:\=/%/Documents/boost/boost_src
:: Boost (required)
set BOOST_PATH=e:/boost/boost_src
:: Zlib (required)
set ZLIB_PATH=%DEPS_PATH%/zlib/%ARCH%/%BUILD_TYPE%
:: TIFF (required)
REM set TIFF_VERSION=4.3.0
set TIFF_PATH=%DEPS_PATH%/tiff/%ARCH%/%BUILD_TYPE%
:: Imath (required if not using IlmBase? - TODO: check!)
set IMATH_PATH=%DEPS_PATH%/imath/%ARCH%
:: IlmBase (required if not using Imath? - TODO: check!)
REM - TODO: check with IlmBase instead of Imath (+impact on OCIO)
:: OpenEXR (required)
set OPENEXR_PATH=%DEPS_PATH%/openexr/%ARCH%/%BUILD_TYPE%
:: JPEG (required)
set JPEG_PATH=%DEPS_PATH%/jpegturbo/%ARCH%/%BUILD_TYPE%
:: PNG (optional)
set PNG_PATH=%DEPS_PATH%/png/%ARCH%/%BUILD_TYPE%
:: BZip2 (optional)
set BZIP2_PATH=%DEPS_PATH%/bzip2/%ARCH%/%BUILD_TYPE%
:: FreeType (optional)
set FREETYPE_PATH=%DEPS_PATH%/freetype/%ARCH%/%BUILD_TYPE%
:: HDF5
REM - ! - No build type for HDF5 (only release with debug info...)
REM set HDF5_PATH=%DEPS_PATH%/hdf5/%ARCH%
:: OpenColorIO (OCIO) (optional)
set OCIO_PATH=%DEPS_PATH%/ocio/%ARCH%/%BUILD_TYPE%
:: OpenCV (optional)
set OPENCV_PATH=%DEPS_PATH%/opencv/%ARCH%/%BUILD_TYPE%
:: TBB (optional)
set TBB_PATH=%DEPS_PATH%/tbb/%ARCH%/%BUILD_TYPE%
:: DCMTK (optional)
REM set DCMTK_PATH=""
:: ffmpeg
REM - TODO: only release build => Should build debug
set FFMPEG_PATH=%DEPS_PATH%/ffmpeg/%ARCH%
:: Field3D
REM - TODO: currently not supported
REM set FIELD3D_PATH=%DEPS_PATH%/field3d/%ARCH%/%BUILD_TYPE%
:: Gif
set GIF_PATH=%DEPS_PATH%/gif/%ARCH%/%BUILD_TYPE%
:: libheif
set LIBHEIF_PATH=%DEPS_PATH%/libheif/%ARCH%/%BUILD_TYPE%
:: libRaw
set LIBRAW_PATH=%DEPS_PATH%/libraw/%ARCH%/%BUILD_TYPE%
:: OpenJPEG
set OPENJPEG_PATH=%DEPS_PATH%/openjpeg/%ARCH%/%BUILD_TYPE%
:: OpenVDB
set OPENVDB_PATH=%DEPS_PATH%/openvdb/%ARCH%/%BUILD_TYPE%
:: Ptex
set PTEX_PATH=%DEPS_PATH%/ptex/%ARCH%/%BUILD_TYPE%
:: WebP
set WEBP_PATH=%DEPS_PATH%/webp/%ARCH%/%BUILD_TYPE%
:: R3DSDK (need account?)
REM set R3DSDK_ROOT=...
:: Nuke
REM - TODO: what library/plugin is expected?
REM set Nuke_ROOT=...
:: Qt
REM set QT_PATH=%DEPS_PATH%/qt/%ARCH%/%BUILD_TYPE%
set QT_PATH=E:/qt/install/%ARCH%
:: libsquish
set LIBSQUISH_PATH=%DEPS_PATH%/libsquish/%ARCH%/%BUILD_TYPE%

:: Pybind (required if using Python)
REM - TODO: debug|release are identical (check)
REM set PYBIND_PATH=%DEPS_PATH%/pybind11/%ARCH%/%BUILD_TYPE%
set PYBIND_PATH=%DEPS_PATH%/pybind11/%ARCH%



REM - Set default paths (if not set)

if "%OIIO_PATH%" == "" (
    set OIIO_PATH=%USERPROFILE%\Documents\OIIO
)
if "%OIIO_OUTPUT_PATH%" == "" (
    set OIIO_OUTPUT_PATH=%OIIO_PATH%
)


if "%OIIO_SOURCE_PATH%" == "" (
    set OIIO_SOURCE_PATH=%OIIO_PATH%\oiio
)


REM if "%GLUT_PATH%" == "" (
    REM set GLUT_PATH=%OCIO_PATH%\deps\freeglut
REM )
REM if "%GLEW_PATH%" == "" (
    REM set GLEW_PATH=%OCIO_PATH%\deps\glew
REM )


REM !!!!
REM REM - RENAME 'LIB_PATH' VARIABLE
REM set LIB_PATH=%OCIO_PATH%\deps


if "%PYTHON_PATH%" == "" (
    set PYTHON_PATH=%USERPROFILE%\AppData\Local\Programs\Python\Python37
)
REM - TODO: check that Python is installed... (should detect install location)
REM - Safety to make sure another version is not detected/used
set PATH=%PYTHON_PATH%;%PATH%


REM - Set default build type (if not set)

if "%BUILD_TYPE%" == "" (
    set BUILD_TYPE=Release
)
if not "%BUILD_TYPE%" == "Release" (
    if not "%BUILD_TYPE%" == "Debug" (
        echo Invalid build type '%BUILD_TYPE%' - Setting it to 'Release'.
        set BUILD_TYPE=Release
    )
)

if "%VC_VARS_BAT%" == "" (
    set VC_VARS_BAT="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
)
REM - ~Hack to remove quotes (will be added later)
set VC_VARS_BAT=%VC_VARS_BAT:"=%



REM - Check input paths

if not exist "%OIIO_SOURCE_PATH%" (
    echo ERROR: %OIIO_SOURCE_PATH% does not exist!
    echo Make sure 'OIIO_SOURCE_PATH' is set correctly to OpenImageIO source directory.
    exit /b
)


REM if not exist "%GLUT_PATH%" (
    REM echo ERROR: %GLUT_PATH% does not exist
    REM echo Make sure 'GLUT_PATH' is set correctly to FreeGLUT library path.
    REM exit /b
REM )
REM if not exist "%GLEW_PATH%" (
    REM echo ERROR: %GLEW_PATH% does not exist
    REM echo Make sure 'GLEW_PATH' is set correctly to GLEW library path.
    REM exit /b
REM )



REM - Build Python bindings by default
REM - TODO: rename variable?
if "%PYTHON%" == "" (
    set PYTHON=ON
)


REM REM set PATH=%GLEW_PATH%\bin;%GLUT_PATH%\bin;D:\Tools\cygwin64\bin;%CMAKE_PATH%\bin;%PATH%
REM set PATH=%GLEW_PATH%\bin;%GLUT_PATH%\bin;%PATH%


set BUILD_PATH=%OIIO_OUTPUT_PATH%\build\%BUILD_TYPE%


echo Build path: %BUILD_PATH%
if not exist %BUILD_PATH% (
    mkdir %BUILD_PATH%
)
cd %BUILD_PATH%



set INSTALL_PATH=%OIIO_OUTPUT_PATH%/install/%ARCH%/%BUILD_TYPE%


REM - Initialise VC environment
call "%VC_VARS_BAT%"



set BUILD_TESTS=OFF


REM - TODO: move declarations to top
REM set BOOST_ROOT=%USERPROFILE%\Documents\boost\boost_1_73_0
rem set BOOST_PATH=%BOOST_ROOT%
rem set BOOST_LIB_PATH=%BOOST_ROOT%\stage\lib

REM set ZLIB_ROOT=%USERPROFILE%\Documents\OIIO\deps\zlib
REM set TIFF_ROOT=%USERPROFILE%\Documents\OIIO\deps\tiff


REM - TODO: not using prefix path => OK?
REM -DCMAKE_PREFIX_PATH="%USD_LIB_PATH%" ^



set "BUILD_OPTIONS="

REM - TODO: Add 'else' cases to set libraries to 'OFF'
REM - TODO: ADAPT FOR EACH CASE WITH STATIC/SHARED + DEBUG/RELEASE LIBRARIES!
set BUILD_OPTIONS=%BUILD_OPTIONS% -DBOOST_ROOT="%BOOST_PATH%"
set BUILD_OPTIONS=%BUILD_OPTIONS% -DZLIB_ROOT="%ZLIB_PATH%"
set BUILD_OPTIONS=%BUILD_OPTIONS% -DTIFF_ROOT="%TIFF_PATH%"
set BUILD_OPTIONS=%BUILD_OPTIONS% -DImath_ROOT="%IMATH_PATH%"
set BUILD_OPTIONS=%BUILD_OPTIONS% -DOpenEXR_ROOT="%OPENEXR_PATH%"
set BUILD_OPTIONS=%BUILD_OPTIONS% -DJPEGTurbo_ROOT="%JPEG_PATH%"
if not "%PNG_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DPNG_ROOT="%PNG_PATH%"
)
if not "%BZIP2_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DBZip2_ROOT="%BZIP2_PATH%"
)
if not "%FREETYPE_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DFreetype_ROOT="%FREETYPE_PATH%"
)
if not "%OCIO_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DOpenColorIO_ROOT="%OCIO_PATH%"
)
if not "%OPENCV_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DOpenCV_ROOT="%OPENCV_PATH%"
)
if not "%TBB_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DTBB_ROOT="%TBB_PATH%"
)
if not "%DCMTK_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DDCMTK_PATH="%DCMTK_PATH%"
) else (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DUSE_DCMTK=OFF
)
if not "%FFMPEG_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DFFmpeg_ROOT="%FFMPEG_PATH%"
)
if not "%FIELD3D_PATH%" == "" (
    REM - TODO: Fix Field3d build on Windows
    echo "Field3d currently unsupported in Windows!"
) else (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DUSE_FIELD3D=OFF
)
if not "%GIF_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DGIF_ROOT="%GIF_PATH%"
)
if not "%LIBHEIF_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DLibheif_ROOT="%LIBHEIF_PATH%"
)
if not "%LIBRAW_PATH%" == "" (
    REM set BUILD_OPTIONS=%BUILD_OPTIONS% -DLibRaw_ROOT="%LIBRAW_PATH%"
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DLibRaw_ROOT="%LIBRAW_PATH%"

    REM if "%BUILD_TYPE%" == "Debug" (
        REM set BUILD_OPTIONS=!BUILD_OPTIONS! -DLibRaw_LIBRARY="%LIBRAW_PATH%/lib/rawd.lib"
    REM )
    if "%BUILD_TYPE%" == "Debug" (
        REM set BUILD_OPTIONS=!BUILD_OPTIONS! -DLibRaw_r_LIBRARIES="%LIBRAW_PATH%/lib/raw_rd.lib"
        set BUILD_OPTIONS=!BUILD_OPTIONS! -DLibRaw_LIBRARIES="%LIBRAW_PATH%/lib/rawd.lib"
    ) else (
        REM set BUILD_OPTIONS=!BUILD_OPTIONS! -DLibRaw_r_LIBRARIES="%LIBRAW_PATH%/lib/raw_r.lib"
        set BUILD_OPTIONS=!BUILD_OPTIONS! -DLibRaw_LIBRARIES="%LIBRAW_PATH%/lib/raw.lib"
    )
)
if not "%OPENJPEG_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DOpenJPEG_ROOT="%OPENJPEG_PATH%"
)
if not "%OPENVDB_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DOpenVDB_ROOT="%OPENVDB_PATH%"
)
if not "%PTEX_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DPtex_ROOT="%PTEX_PATH%"
)
if not "%WEBP_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DWebP_ROOT="%WEBP_PATH%"
)
if not "%R3DSDK_PATH%" == "" (
    REM - TODO: Check correct variable/libs
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DR3DSDK_ROOT="%R3DSDK_PATH%"
) else (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DUSE_R3DSDK=OFF
)
if not "%NUKE_PATH%" == "" (
    REM - TODO: Check correct variable/libs
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DNuke_ROOT="%NUKE_PATH%"
) else (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DUSE_NUKE=OFF
)
if not "%QT_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DQt5_ROOT="%QT_PATH%"
)
if not "%LIBSQUISH_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DLibsquish_ROOT="%LIBSQUISH_PATH%"
)

if "%PYTHON%" == "ON" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -Dpybind11_ROOT="%PYBIND_PATH%"
)


echo.
echo Configure
cmake -G "Visual Studio 16 2019" -A x64 ^
 -DCMAKE_CXX_STANDARD=17 ^
 -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
 -DCMAKE_INSTALL_PREFIX=%INSTALL_PATH% ^
 -DOIIO_BUILD_TOOLS=%BUILD_TOOLS% ^
 -DOIIO_BUILD_TESTS=%BUILD_TESTS% ^
 -DUSE_PYTHON=%PYTHON% ^
 -DSTOP_ON_WARNING=%STOP_ON_WARNING% ^
 %BUILD_OPTIONS% ^
 "%OIIO_SOURCE_PATH%"


REM - TODO: check for errors

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE% --verbose
REM cmake --build . --config %BUILD_TYPE% --verbose


pause
exit /b


REM - ################################################################################################
REM - TO DELETE

 REM -DWEBP_LIBRARY_PATH="%WEBP_PATH%/lib" ^
 REM -DWEBP_INCLUDE_PATH="%WEBP_PATH%/include" ^



 -DOpenCV_LIBRARY_DIR="%OPENCV_PATH%\x64\vc16\lib" ^
 -DOpenCV_INCLUDE_DIR="%OPENCV_PATH%\include" ^




 -DOPENCOLORIO_INCLUDE_DIR="%OCIO_PATH%\include" ^
 -DOPENCOLORIO_LIBRARIES="%OCIO_PATH%\lib\OpenColorIO_2_0.lib" ^



...-DOPENCOLORIO_INCLUDES= C:/src/vcpkg/installed/x64-windows/include
-DOPENCOLORIO_INCLUDE_DIR=%OCIO_PATH%\include
-DOPENCOLORIO_LIBRARIES=%OCIO_PATH%\lib\OpenColorIO.lib

 REM -DTIFF_INCLUDE_DIR="%TIFF_PATH%\include" ^
 REM -DTIFF_LIBRARY="%TIFF_PATH%\lib\tiff.lib" ^
 REM -DTIFF_VERSION=%TIFF_VERSION% ^


 -DImath_ROOT="%USERPROFILE%\Documents\OIIO\deps\imath" ^
 -DOpenEXR_ROOT="%USERPROFILE%\Documents\OIIO\deps\openexr" ^




 -DTIFF_ROOT="%USERPROFILE%\Documents\OIIO\deps\tiff" ^

 -DTIFF_INCLUDE_DIR="%USERPROFILE%\Documents\OIIO\deps\tiff\include" ^
 -DTIFF_LIBRARY="%USERPROFILE%\Documents\OIIO\deps\tiff\lib\tiff.lib" ^

 

(useless?
	-DBOOST_ROOT="%BOOST_ROOT%" ^
	-DBOOST_LIBRARYDIR="%BOOST_LIB_PATH%" ^
)


 -DOPENEXR_HOME="%OPEN_EXR_PATH%" ^


cmake -G "Visual Studio 16 2019" -A x64 ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%" ^
 -DCMAKE_PREFIX_PATH="%USD_LIB_PATH%" ^
 -DCMAKE_BUILD_TYPE=Release ^
 -DOIIO_BUILD_TOOLS=OFF ^
 -DOIIO_BUILD_TESTS=OFF ^
 -DUSE_PYTHON=OFF ^
 -DSTOP_ON_WARNING=OFF ^
 -DOPENEXR_HOME="%OPEN_EXR_PATH%" ^
 -DBoost_NO_BOOST_CMAKE=On ^
 -DBoost_NO_SYSTEM_PATHS=True ^
 "%OIIO_PATH%"




cmake -G "Visual Studio 16 2019" -A x64 ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%" ^
 -DCMAKE_PREFIX_PATH="%USD_LIB_PATH%" ^
 -DCMAKE_BUILD_TYPE=Release ^
 -DOIIO_BUILD_TOOLS=OFF ^
 -DOIIO_BUILD_TESTS=OFF ^
 -DUSE_PYTHON=ON ^
 -DSTOP_ON_WARNING=ON ^
 -DOPENEXR_HOME="%OPEN_EXR_PATH%" ^
 -DBoost_NO_BOOST_CMAKE=On ^
 -DBoost_NO_SYSTEM_PATHS=True ^
 -DBZip2_ROOT=%LIB_PATH%\bzip2-1.0.5-bin ^
 -DFreetype_ROOT=%LIB_PATH%\freetype-2.3.5-1-bin ^
 -DHDF5_ROOT=%LIB_PATH%\HDF5\1.12.1 ^
 -DOpenColorIO_ROOT=%LIB_PATH%\ocio\2.1 ^
 -DOpenCV_ROOT=%LIB_PATH%\opencv ^
 "%OIIO_PATH%"



 -DUSE_PYTHON=OFF ^
 -DSTOP_ON_WARNING=OFF ^






pause
exit /b



...

if "%THIRD_PARTY_PATH%" == "" (

    REM - Configure without precompiled third party libraries (=> requires Internet access)
    cmake -G "Visual Studio 16 2019" -A x64 ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DCMAKE_INSTALL_PREFIX=%INSTALL_PATH% ^
        -DOCIO_INSTALL_EXT_PACKAGES=MISSING ^
        -DBUILD_SHARED_LIBS=ON ^
        -DOCIO_BUILD_APPS=ON ^
        -DOCIO_BUILD_TESTS=ON ^
        -DOCIO_BUILD_GPU_TESTS=OFF ^
        -DOCIO_BUILD_DOCS=OFF ^
        -DOCIO_USE_SSE=ON ^
        -DOCIO_WARNING_AS_ERROR=ON ^
        -DOCIO_BUILD_PYTHON=%OCIO_BUILD_PYTHON% ^
        -DPython_LIBRARY="%PYTHON_PATH%\libs\python37.lib" ^
        -DPython_INCLUDE_DIR="%PYTHON_PATH%\include" ^
        -DPython_EXECUTABLE="%PYTHON_PATH%\python.exe" ^
        -DOCIO_BUILD_JAVA=OFF ^
        %OCIO_SOURCE_PATH%

) else (

    REM - Configure with precompiled third party libraries (without OpenImageIO)
    cmake -G "Visual Studio 16 2019" -A x64 ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DCMAKE_INSTALL_PREFIX=%INSTALL_PATH% ^
        -DOCIO_INSTALL_EXT_PACKAGES=MISSING ^
        -Dexpat_LIBRARY=%THIRD_PARTY_PATH%\libexpat\lib\%BUILD_TYPE%\expatMD.lib ^
        -Dexpat_INCLUDE_DIR=%THIRD_PARTY_PATH%\libexpat\include ^
        -Dexpat_STATIC_LIBRARY=ON ^
        -Dyaml-cpp_LIBRARY=%THIRD_PARTY_PATH%\yaml-cpp\lib\%BUILD_TYPE%\libyaml-cppmd.lib ^
        -Dyaml-cpp_INCLUDE_DIR=%THIRD_PARTY_PATH%\yaml-cpp\include ^
        -Dyaml-cpp_STATIC_LIBRARY=ON ^
        -DHalf_LIBRARY=%THIRD_PARTY_PATH%\openexr\Half\lib\%BUILD_TYPE%\Half-2_4.lib ^
        -DHalf_INCLUDE_DIR=%THIRD_PARTY_PATH%\openexr\Half\include ^
        -DHalf_STATIC_LIBRARY=ON ^
        -Dpystring_LIBRARY=%THIRD_PARTY_PATH%\pystring\lib\%BUILD_TYPE%\pystring.lib ^
        -Dpystring_INCLUDE_DIR=%THIRD_PARTY_PATH%\pystring\include ^
        -Dpystring_STATIC_LIBRARY=ON ^
        -Dlcms2_LIBRARY=%THIRD_PARTY_PATH%\Little-CMS\lib\%BUILD_TYPE%\lcms2.lib ^
        -Dlcms2_INCLUDE_DIR=%THIRD_PARTY_PATH%\Little-CMS\include ^
        -Dlcms2_STATIC_LIBRARY=ON ^
        -Dpybind11_INCLUDE_DIR=%THIRD_PARTY_PATH%\pybind11\include ^
        -DBUILD_SHARED_LIBS=ON ^
        -DOCIO_BUILD_APPS=ON ^
        -DOCIO_BUILD_TESTS=ON ^
        -DOCIO_BUILD_GPU_TESTS=OFF ^
        -DOCIO_BUILD_DOCS=OFF ^
        -DOCIO_USE_SSE=ON ^
        -DOCIO_WARNING_AS_ERROR=ON ^
        -DOCIO_BUILD_PYTHON=%OCIO_BUILD_PYTHON% ^
        -DPython_LIBRARY="%PYTHON_PATH%\libs\python37.lib" ^
        -DPython_INCLUDE_DIR="%PYTHON_PATH%\include" ^
        -DPython_EXECUTABLE="%PYTHON_PATH%\python.exe" ^
        -DOCIO_BUILD_JAVA=OFF ^
        %OCIO_SOURCE_PATH%

)

REM - Build the libraries
cmake --build . --config %BUILD_TYPE%
+install target!


pause
exit /b