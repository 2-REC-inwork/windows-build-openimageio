@echo off

set LIB_PATH=hdf5
set HDF5_VERSION=1.12.1


set EXTRACT_PATH=%cd%\%LIB_PATH%
set TEMP_SUB_PATH=%EXTRACT_PATH%\HDF_Group\HDF5\%HDF5_VERSION%

:: Extract the MSI
msiexec /a %cd%\hdf\HDF5-%HDF5_VERSION%-win64.msi /qb TARGETDIR=%EXTRACT_PATH%

:: Move the desired content
mkdir install
move %TEMP_SUB_PATH%\bin install\bin
move %TEMP_SUB_PATH%\include install\include
move %TEMP_SUB_PATH%\lib install\lib
move %TEMP_SUB_PATH%\share install\share

:: Delete remaining files/folders
rmdir /q/s %EXTRACT_PATH%

pause
exit /b