
# OpenImageIO Windows Build

Help to build the OpenImageIO library in Windows.

## Description

_"[OpenImageIO (OIIO)](https://sites.google.com/site/openimageio/home) is a library for reading and writing images, and a bunch of related classes, utilities, and applications."_

This repositroy aims at helping build [OpenImageIO](https://github.com/OpenImageIO/oiio) from source in Windows.

Building OIIO can be difficult, as it has many dependencies, most of them required to be built spearately.
Additionally, one of the dependencies is OpenColorIO (OCIO), which itself depends on OpenImageIO, which can make the build process confusing.

This project is not trying to make an automated building process, but rather to compile information on the different steps and modules required to build the OpenImageIO library.
Some information is definitely lacking, but with time will hopefully get better.

Also, there might be some errors and invalid steps or configurations. I hope contributions or notifications will help me correct them.


The build process described here is essentially based on the [OpenImageIO installation instructions](https://github.com/OpenImageIO/oiio/blob/master/INSTALL.md).
While repeating the provided information, additional useful information is added.

Other documents provide valuable information, such as:
* [How to build windows images libraries](http://jesnault.fr/website/how-to-build-windows-images-libraries/)
(TODO: add more links)

The versions of software and library used in the process try to follow the [VFX Reference Platform](https://vfxplatform.com/).
CY2021 will be used as the annual reference.

No version is specified for OpenImageIO, but it should be compatible with the specified OpenColorIO version (2.0.x).
!!!!
TODO: CHECK V2.3.8 is ok with OCIO 2.0.2!
Version 2.3.8.0 is at the time of writing the latest version, and is compatible with OpenColorIO 2.0.x.
!!!!
Later versions might require changes, but the main process should remain the same.


## Alternative Method

A probably easier way to build and install OpenImageIO on Windows is using [vcpkg](https://github.com/Microsoft/vcpkg).

From [this Reddit post](https://www.reddit.com/r/vfx/comments/9jev6b/compiling_openimageio_for_windows/):

_"It (vcpkg) automatically sorts out the dependencies and integrates the new library into Visual Studio's environment variables.
[...] compiling it correctly is just a matter of entering this in a command prompt:
```
vcpkg install openimageio:x64-windows
vcpkg integrate install
```
This will work for OpenEXR, OpenVDB, Alembic and a wide range of other essential libraries."_

Using 'vcpkg' greatly simplifies the build process, and should probably be the method of choice when possible.
I haven't tried this method yet.


# Build Environment

The software used for the build are the following:
* Windows 10 (64 bits)
* Visual Studio 2019 (Community Edition) (MSVC142)
* Windows 10 SDK v10 (10.0.19041)
* CMake 3.20+
* Python 3.7.9
(TODO: check required
* MSYS + MinGW
  => Required to build some libraries. A portable installation can be used if desired.
)

Some third party libraries used by OIIO can be automatically built during the build process, requiring the following:
* Git: ("Git for Windows")[https://git-scm.com/download/win] can be used
* Internet access: in order to allow Git to access the libraries source repositories


----

# Components

OpenImageIO uses many external libraries.
A few of them are required in order to build the [OIIO image plugins](https://openimageio.readthedocs.io/en/latest/builtinplugins.html).


## OpenImageIO

OpenImageIO can be downloaded from its [Github repository](https://github.com/OpenImageIO/oiio).

!!!!
TODO: CHECK OK!
xxx Version [2.2.17.0](https://github.com/OpenImageIO/oiio/releases/tag/v2.2.17.0) is used here.
Version [2.3.8.0](https://github.com/OpenImageIO/oiio/releases/tag/v2.3.8.0) is used here.

Once downloaded, extract the archive to the desired location, and rename the directory to 'OpenImageIO'.
From this point, the location of the extracted archive (the parent directory) will be referred to as 'OCIO_PATH'.

For example, the location can be:
```
%USERPROFILE%\Documents\OIIO
```
Which will contain the 'OpenImageIO' directory.


## Required Dependencies

* OpenEXR/Imath >= 2.0 (recommended: 2.2 or higher; tested through 3.1)
* libTIFF >= 3.9 (recommended: 4.0+; tested through 4.3)
* Boost >= 1.53 (recommended: at least 1.66; tested through 1.76)


## Optional Dependencies

* iv viewer
  * Qt >= 5.6 (5.15)
  * OpenGL
* Python bindings (or testsuite)
  * Python >= 2.7 (3.7.9)
  * pybind11 >= 2.4.2 (2.6.1)
  * NumPy
* camera "RAW" formats support
  * LibRaw
    * Min version 0.15
    * >= 0.18 for ACES support 
    * >= 0.20 if building with C++17 or higher
* video formats support
  * ffmpeg >= 3.0
* jpeg 2000 images
  * OpenJpeg >= 2.0 (tested through 2.4)
* Field3D files
  * Field3D (tested through 1.7.3)
* OpenVDB files:
  * OpenVDB >= 5.0 (tested through 8.0) and Intel TBB >= 2018 (tested through 2021)
  * Note that OpenVDB 8.0+ requires C++14 or higher.
* OpenCV data structures, or for capturing images from a camera
  * OpenCV 3.x, or 4.x (tested through 4.5)
* GIF images
  * giflib >= 4.1 (tested through 5.2; 5.0+ is strongly recommended for stability and thread safety)
* HEIF/HEIC or AVIF images:
  * libheif >= 1.3 (1.7 required for AVIF support, tested through 1.11)
    => libheif must be built with an AV1 encoder/decoder for AVIF support.
* DDS files:
  * libsquish >= 1.13 (tested through 1.15)
    => If not found/provided, an embedded version will be used.
* DICOM medical image files:
  * DCMTK >= 3.6.1 (tested through 3.6.5)
* WebP images:
  * WebP >= 0.6.1 (tested through 1.1.0)
* OpenColorIO color transformations:
  * OpenColorIO 1.1 or 2.0
* Ptex:
  * Ptex >= 2.3.1 (probably works for older; tested through 2.4.0)
* XML parsing
  * PugiXML >= 1.8 should be fine (we have tested through 1.11).
    => If not found/provided, an embedded version will be used.


## Embed Plugins

After building OpenImageIO, if compiled with the EMBEDPLUGINS=0 flag,
if building OpenImageIO with the option 'EMBEDPLUGINS=0', the environment variable OIIO_LIBRARY_PATH must be set to point to the 'lib' directory of the 'OpenImageIO' installation.
If not set, OIIO will not be able to find the plugins.


## Third Party Libraries

(TODO: rephrase)
Information on how to build or find each dependency.
Required ones, but also some optionals, in order to have the most complete OIIO build.


## Python

(TODO: rephrase/detail)
Required to use Python features.

The build process will try to find an installed version of Python by looking in the 'PATH' environment variable.
If more than 1 version is installed on the system, the version to be used by the build process should be the first in 'PATH'.

To add the desired version at the beginning of 'PATH', execute the following command:
```batch
set PATH=%PYTHON_PATH%;%PATH%
```
Where 'PYTHON_PATH' is the Python install location (not to be confused with the 'PYTHONPATH' variable used by Python).

(TODO: other variables as for OCIO?
-DPython_LIBRARY="%PYTHON_PATH%\libs\python37.lib"
-DPython_INCLUDE_DIR="%PYTHON_PATH%\include"
-DPython_EXECUTABLE="%PYTHON_PATH%\python.exe"
)

Version [3.7.9](https://www.python.org/downloads/release/python-379/) is used here.


! - For the debug build of OIIO, the Python Debug symbols and binaries are required!
They can be downloaded+installed when installing Python, or by modifying an existing install.
(TODO: see if problem with OCIO, which has the opposite problem)


OIIO can also be built without Python by setting the configure option:
```batch
-DUSE_PYTHON=OFF
```
The Python features will not be built.


### OpenColorIO

[OpenColorIO](https://opencolorio.org/) (OCIO) is required by OpenImageIO.
However, OpenColorIO itself uses OpenImageIO.

The two projects have a circular dependency which can make the build process difficult and confusing.


From [this post](https://lists.aswf.io/g/ocio-dev/message/1828):
_"OIIO’s dependency on on OCIO is, in my opinion, a necessary thing as it allows OIIO clients to manage color using OCIO.
OCIO’s dependency on OIIO is not essential and should be deprecated.
One of OCIO’s example executables (ociorender?) depends on OIIO for image file IO."_

A way to solve the interdependency between the 2 libraries is to:
1. Build OpenColorIO without OpenImageIO
2. Build OpenImageIO with the built OpenColorIO
3. Rebuild OpenColorIO with the built OpenImageIO
(4. Rebuild OpenImageIO with the rebuilt OpenColorIO)

This seems like unnecessary work, but it will ensure that both libraries are built with support for the other.

Information on how to build OpenColorIO can be found in [opencolorio-build-win](TODO: link!).
Version 2.0.2 of OCIO is used here.

(TODO: ADAPT/CORRECT!!!!
Once the OCIO library has been built, the location of the include files and libraries need to be specified to the configuration process:
```
-DOpenColorIO_ROOT=%OCIO_PATH%
```
where "OCIO_PATH" is the location of the OCIO library and includes.
(TODO: rephrase)

The generated library should be renamed in order to allow OIIO to find it OCIO:
```
OpenColorIO_2_0.lib -> OpenColorIO.lib
```


### Boost

Version 1.73.0.

(TODO: link to "boost" page)

(TODO: worth mentionning? should then do it for every module/library)
The Boost root path can then be added to the OIIO build process:
```batch
set BOOST_ROOT=%USERPROFILE%\Documents\boost\boost_1_73_0
```


### ZLIB

(TODO: link to "zlib" page)


### TIFF

(TODO: link to "tiff" page)


### IMATH

(TODO: link to "imath" page)


(TODO: COPY/MOVE LIB TO DEPS DIRECTORY or refer to original location)
The library location can then be added to the OIIO build process:
```batch
 -DImath_ROOT="%IMATH_PATH%"
```

### ILMBASE

(TODO: check!)
If providing the Imath library, IlmBase is not required.
(TODO: should test without Imath and use IlmBase - could 'solve' OCIO issue with Half?)


(TODO: used by Field3D, but older version
=> make a separate section/page?
for field3d, version 2.0.0 seems to be the good one

(TODO: link to "ilmbase" page)


### OPENEXR

version... (used here?)

(TODO: link to "openexr" page)

(TODO: worth?)
once built:
 -DOpenEXR_ROOT="%USERPROFILE%\Documents\OIIO\deps\openexr"
)


### PNG

...
Version 1.6.37.

(TODO: link to "png" page)


### BZIP2

...
Version 1.0.8.

(TODO: link to "bzip2" page)


### FREETYPE

...

(TODO: link to "freetype" page)


### HDF5

(TODO: seems unused by OIIO!? - why is it here? why did I add it?
=> used by Field3D, so should move it there (?)
Can remove some parts of the build to speed up the process and save some space:
- tools
- examples
- fortran
)

...

(TODO: link to "hdf5" page)


### OPENCV

TODO: needed?

...

(TODO: link to "opencv" page)


OpenImageIO is looking for the following modules (don't build OpenCV "world" as a single monolithic library):
- opencv_core
- opencv_imgproc
- opencv_videoio

The generated libraries contain the version as suffix in their names, and should thus be renamed (TODO: a 'fix' in OIIO is being made, so it will not be necessary anymore).
There is the same problem with the debug libraries: the 'd' suffix should be removed as well.


### TBB

...

(TODO: link to "tbb" page)

When linking the libraries, the following error might appear:
```
-- Could NOT find TBB (missing: TBB_DIR)
```
However, the library is found (the following line mentions the found library) and the error can be ignored.
(TODO: MAKE SURE IT'S NOT AN ISSUE!)


### DCMTK

The build process being quite difficult in Windows, and the library not being mandatory (as well as not free), it will be skipped here.
Set 'DUSE_DCMTK' to 'OFF' to disable module in OpenImageIO.

(TODO: link to "dcmtk" page)


### FFMPEG

...

(TODO: link to "ffmpeg" page)

Copy the files to 'deps' folder.
(TODO: determine which libraries are required by OIIO)


### FIELD3D

[Field3d](https://github.com/imageworks/Field3D) is ignored for now, as [_"field3d does not support Windows currently"_](https://github.com/microsoft/vcpkg/issues/9375#issuecomment-567765653)

To disable use of Field3D.
```
-DUSE_FIELD3D=OFF
```

...
(TODO: link to "dcmtk" page)


### GIF

Version 5.2.1.

...
(TODO: link to "gif" page)



### LIBHEIF

...
(TODO: link to "libheif" page)


### LIBRAW

...
(TODO: link to "libraw" page)


The debug libraries have a 'd' suffix, so when using them in other projects, they should either be explicitly specified or renamed.
For OIIO, the following configuration option can be used:
```
-DLibRaw_LIBRARY="%LIBRAW_PATH%/lib/rawd.lib"
```

OIIO is expecting the shared libraries.
If trying to build OIIO with the "libraw" static libraries, a series of warnings will be raised:
```
LINK : warning LNK4217: symbol 'libraw_strerror' defined in 'rawd.lib(libraw_cxx.obj)'
 is imported by 'rawinput.obj' in function '"private: bool __cdecl OpenImageIO_v2_3::RawInput::process(void)" (?process@RawInput@OpenImageIO_v2_3@@AEAA_NXZ)'
 [...\build\Debug\src\libOpenImageIO\OpenImageIO.vcxproj]
```

(TODO: see how to specify use of static libs with OIIO - if possible
In "oiio\src\raw.imageio"?
)


### OPENJPEG

...
(TODO: link to "openjpeg" page)


(TODO: leave here, or in openjpeg page (and make generic)?)
If trying to build OIIO with the "OpenJPEG" static libraries, a series of errors will be raised:
```
jpeg2000input.obj : error LNK2019: unresolved external symbol __imp_opj_version referenced
 in function "char const * __cdecl OpenImageIO_v2_3::jpeg2000_imageio_library_version(void)" (?jpeg2000_imageio_library_version@OpenImageIO_v2_3@@YAPEBDXZ)
 [...\build\Debug\src\libOpenImageIO\OpenImageIO.vcxproj]
```
(TODO: solve issue.
Looking for "__imp_opj_version", but only "opj_version" in lib symbols.
=> Due to export when DLL and not in static?
)


### OPENVDB

...
(TODO: link to "openvdb" page)


### PTEX

...

Version 2.3.2.

(TODO: link to "ptex" page)


### WEBP

...
(TODO: link to "webp" page)

(TODO: OIIO finds WebP, but doesn't indicate the version. OK?)


### R3DSDK

! - Nedd an account => Skipped for now.

https://www.red.com/download/r3d-sdk


### NUKE

(TODO: what library is expected?)

Skipped for now.


### QT5

...
(TODO: link to "qt" page)


### LIBSQUISH

Version 1.15.

...
(TODO: link to "libsquish" page)


### PYBIND11


(TODO: add more details?)
(got files from OCIO...
=> include + share
)


### FMT

Automatically downloaded+built.
Internet access is required.

The library will be built in the 'ext' directory of OIIO source.


### ROBIN-MAP (?)

Automatically downloaded+built.
Internet access is required.

The library will be built in the 'ext' directory of OIIO source.


----

## TESTS

(TODO: check)
If the sources for the tests are not provided, the tests will not be built/run, but warning messages will be displayed.
The option "OIIO_BUILD_TESTS" is to disable unit tests, but there is no option to disable the build tests.

### Test Images

Sets of [test images](https://github.com/OpenImageIO/oiio/blob/master/INSTALL.md#test-images) are available to validate OIIO built libraries and tools.

For the main sets, if they are not found at the expected location, they will be downloaded (using Git).
These sets are:
* oiio-images
  Downloadable from:
    https://github.com/OpenImageIO/oiio-images.git
  Expected location:
    build/Debug/testsuite/oiio-images
* openexr-images
  Downloadable from:
    https://github.com/AcademySoftwareFoundation/openexr-images.git
  Expected location:
    build/Debug/testsuite/openexr-images

The other sets will not be automatically downloaded.
They can be found at the following locations:
* fits
  Downloadable from:
    http://www.cv.nrao.edu/fits/data/tests/
    There is no direct link to download everything at once. To avoid having to download each file separately, can use [Wget for Windows](https://eternallybored.org/misc/wget/) or other similar tool.
  Expected location:
    build/Debug/testsuite/fits-images
* jpeg2000
  Downloadable from:
    http://www.itu.int/net/ITU-T/sigdb/speimage/ImageForm-s.aspx?val=10100803
  Expected location:
    build/Debug/testsuite/j2kp4files_v1_5
* tiff
  Downloadable from:
    http://www.simplesystems.org/libtiff/images.html
  This set doesn't seem to be used anymore (included in "oiio-images"?).


## BUILD


(TODO: doesn't occur in debug? - check to make sure)
(TODO: should find solution to avoid this warning instead of "hiding" it
=> related to release/debug variants and /MD, /MT, etc.
)

Warning:
```
LINK : warning LNK4098: defaultlib 'LIBCMT' conflicts with use of other libs; use /NODEFAULTLIB:library [C:\Users\2-REC\Documents\OIIO\build\Release\src\libOpenImageIO\OpenImageIO.vcxproj]
```

Can be removed by adding the following in "src\libOpenImageIO\CMakeLists.txt":
```
if( WIN32 )
    set_target_properties(OpenImageIO PROPERTIES LINK_FLAGS "/NODEFAULTLIB:libcmt.lib")
endif()
```




TODO: CONTINUE FROM HERE!

gif.lib(dgif_lib.obj) : error LNK2019: unresolved external symbol openbsd_reallocarray referenced in function DGifGetImageDesc [C:\Users\2-REC\Documents\OIIO\build\Release\src\libOpenImageIO\OpenImageIO.vcxproj]
gif.lib(gifalloc.obj) : error LNK2001: unresolved external symbol openbsd_reallocarray [C:\Users\2-REC\Documents\OIIO\build\Release\src\libOpenImageIO\OpenImageIO.vcxproj]
freetype.lib(sfnt.obj) : error LNK2019: unresolved external symbol BrotliDecoderDecompress referenced in function woff2_open_font [C:\Users\2-REC\Documents\OIIO\build\Release\src\libOpenImageIO\OpenImageIO.vcxproj]
C:\Users\2-REC\Documents\OIIO\build\Release\bin\Release\OpenImageIO.dll : fatal error LNK1120: 3 unresolved externals [C:\Users\2-REC\Documents\OIIO\build\Release\src\libOpenImageIO\OpenImageIO.vcxproj]


=> CHECK GIF LIBRARY (STATIC/SHARED???)





(TODO: also look at pkgconfig stuff in cygwin on VM... => clean/delete)










=======================================

first try with
DOIIO_BUILD_TOOLS=OFF
DOIIO_BUILD_TESTS=OFF
then
DOIIO_BUILD_TOOLS=ON
DOIIO_BUILD_TESTS=ON

----

@echo off

REM set OIIO_PATH=C:\Users\2-REC\Documents\usd\usd_build\src\oiio-Release-2.1.16.0
set OIIO_PATH=C:\Users\2-REC\Documents\oiio
REM - check dir!

REM - need separate paths for DCMAKE_INSTALL_PREFIX and DCMAKE_PREFIX_PATH?
set LIB_PATH=C:\Users\2-REC\Documents\usd\oiio_deps
set USD_LIB_PATH=C:\Users\2-REC\Documents\usd\usd_build

REM - need subdir? (eg: "openexr" or "half")
set OPEN_EXR_PATH=%USD_LIB_PATH%


REM - change?
set INSTALL_PATH=%LIB_PATH%/OpenImageIO


REM set BUILD_PATH=%OIIO_PATH%\build_release
set BUILD_PATH=%OIIO_PATH%\..\oiio_build
echo %BUILD_PATH%
if not exist %BUILD_PATH% (
    mkdir %BUILD_PATH%
)
cd %BUILD_PATH%



"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"



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



