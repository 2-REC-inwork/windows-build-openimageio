@echo off
setlocal EnableDelayedExpansion

:: Initialisation
set VERSION=1.2.11
set BUILD_TYPE=Release
set ARCH=x64
REM set INSTALL_PATH=%cd%\install

:: Initialise VC environment
if not defined ARCH (
    set ARCH=x64
)
if "%ARCH%" == "x64" (
    set VCVARS=vcvars64.bat
) else (
    set VCVARS=vcvars32.bat
)
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\%VCVARS%"


set ORIGIN=%cd%

:: Configuration
set VER=%VERSION:.=%
set URL=https://zlib.net/zlib%VER%.zip
set CMAKE_VS_PLATFORM_NAME=x64
REM set TMPDIR=%HOMEDRIVE%%HOMEPATH%\zlib_tmp
set TMPDIR=%ORIGIN%\build
set SRC_DIR=%TMPDIR%\zlib-%VERSION%
set ZIPFILE=zlib%VER%.zip
set ABS_ZIPFILE=%ORIGIN%\%ZIPFILE%
set KEEP_ZIP=1
if not exist "%ABS_ZIPFILE%" (
    set ABS_ZIPFILE=%TMPDIR%\%ZIPFILE%
	set KEEP_ZIP=0
)
set BUILD_DIR=%SRC_DIR%\build
if "%INSTALL_PATH%" == "" (
    set INSTALL_PATH=%ORIGIN%\install
)
set LOGFILE=%TMPDIR%\zlib_install.log

echo [0/6] Library(zlib==%VERSION%)

if not exist %TMPDIR% (mkdir %TMPDIR% && cd /d %TMPDIR% || exit /B 1)
call :cleanup_src
call :cleanup_log
copy /y nul %LOGFILE% >nul 2>&1
call :log_sysinfo >>%LOGFILE% 2>&1

set GENERATOR=-DCMAKE_GENERATOR_PLATFORM=%ARCH%
if not "%INSTALL_PATH%" == "" (
    set INSTALL_PATH_64="%INSTALL_PATH%\x64"
    set INSTALL_PATH_32="%INSTALL_PATH%\x86"
) else (
    set INSTALL_PATH_64="%PROGRAMFILES%\zlib"
    set INSTALL_PATH_32="%PROGRAMFILES(X86)%\zlib"
)
REM - ~Hack to remove possible quotes (added later)
set INSTALL_PATH_64=%INSTALL_PATH_64:"=%
set INSTALL_PATH_32=%INSTALL_PATH_32:"=%
if "%ARCH%" == "x64" (
    set PREFIX=-DCMAKE_INSTALL_PREFIX="%INSTALL_PATH_64%"
) else (
    set PREFIX=-DCMAKE_INSTALL_PREFIX="%INSTALL_PATH_32%"
)

echo|set /p="[1/6] Checking cmake... "
call :setup_cmake_path >>%LOGFILE% 2>&1
if not defined CMAKE (
    call :failed
    echo[
    echo Please, install CMAKE: https://cmake.org/download/
    exit /B 1
) else (echo done.)

if not exist "%ABS_ZIPFILE%" (
    echo|set /p="[2/6] Downloading... "
    echo Fetching %URL% >>%LOGFILE% 2>&1
    cd /d %TMPDIR% && call :winget "%URL%" >>%LOGFILE% 2>&1
    if not exist "%ABS_ZIPFILE%" (
        call :failed && exit /B 1
    )
    if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)
) else (
    echo [2/6] Found archive '%ABS_ZIPFILE%'.
)

echo|set /p="[3/6] Extracting... "
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('%ABS_ZIPFILE%', '%TMPDIR%'); }" >>%LOGFILE% 2>&1
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)

echo|set /p="[4/6] Fixing CMakeLists.txt... "
set OLDSTR=RUNTIME DESTINATION ""\${INSTALL_BIN_DIR}\""
set NEWSTR=RUNTIME DESTINATION ""bin\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1)

set OLDSTR=ARCHIVE DESTINATION ""\${INSTALL_LIB_DIR}\""
set NEWSTR=ARCHIVE DESTINATION ""lib\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1)

set OLDSTR=LIBRARY DESTINATION ""\${INSTALL_LIB_DIR}\""
set NEWSTR=LIBRARY DESTINATION ""lib\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1)

set OLDSTR=DESTINATION ""\${INSTALL_INC_DIR}\""
set NEWSTR=DESTINATION ""include\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)

rd /S /Q %BUILD_DIR% >nul 2>&1
mkdir %BUILD_DIR% && cd /d %BUILD_DIR%

echo|set /p="[5/6] Configuring... "
"%CMAKE%" .. -DCMAKE_BUILD_TYPE=%BUILD_TYPE% %PREFIX% %GENERATOR% >>%LOGFILE% 2>&1
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)

echo [6/6] Compiling and installing...
"%CMAKE%" --build . --config %BUILD_TYPE% --target install
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)

call :cleanup_src
call :goto_origin

echo Details can be found at %LOGFILE%.

pause
@echo on
@goto :eof

:setup_cmake_path
where cmake.exe
cmake.exe /? 2> NUL 1> NUL
if not %ERRORLEVEL%==9009 (echo cmake.exe is accessible by default. && set CMAKE=cmake.exe)
if not defined CMAKE (echo cmake.exe is not accessible by default. Looking into common installation dirs.)
if not defined CMAKE (call :setup_cmake_path_for "%PROGRAMFILES%\CMake\bin")
if not defined CMAKE (call :setup_cmake_path_for "C:\Program Files\CMake\bin")
if not defined CMAKE (call :setup_cmake_path_for "C:\Program Files (x86)\CMake\bin")
@goto :eof

:setup_cmake_path_for
set DIR_PATH=%~1
echo|set /p="Checking !DIR_PATH! ... "
if exist !DIR_PATH!\cmake.exe (
    echo found.
    set CMAKE=!DIR_PATH!\cmake.exe
) else (
    echo not found.
)
@goto :eof

:cleanup_src
if "%KEEP_ZIP%" == "0" (
    del /Q %ABS_ZIPFILE% >nul 2>&1
)
rd /S /Q %SRC_DIR% >nul 2>&1
@goto :eof

:cleanup_log
del /Q %LOGFILE% >nul 2>&1
@goto :eof

:log_sysinfo
echo -- Environment variables
set
echo[

echo -- System info
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
echo[
@goto :eof

:cmakefiles_debug
set FILE=%BUILD_DIR%\CMakeFiles\CMakeError.log
if exist %FILE% (
    echo -- %FILE%
    type %FILE%
    echo[
)
set FILE=%BUILD_DIR%\CMakeFiles\CMakeOutput.log
if exist %FILE% (
    echo -- %FILE%
    type %FILE%
    echo[
)
@goto :eof

:failed
echo FAILED.
call :cmakefiles_debug >>%LOGFILE% 2>&1
echo[
echo ---------------------------------------- log begin ----------------------------------------
type %LOGFILE%
echo ----------------------------------------  log end  ----------------------------------------
echo LOG: %LOGFILE%
call :cleanup_src
call :goto_origin
@goto :eof

:goto_origin
cd /d %ORIGIN% >nul 2>&1
@goto :eof

:search_replace
set OLDSTR=%~1
set NEWSTR=%~2
cd /d %SRC_DIR%
set CMD="(gc CMakeLists.txt) -replace '%OLDSTR%', '%NEWSTR%' | Out-File -encoding ASCII CMakeLists.txt"
powershell -Command %CMD%  >>%LOGFILE% 2>&1
goto :eof

:winget
set URL=%~1
for %%F in (%URL%) do set FILE=%%~nxF

setlocal EnableDelayedExpansion
set multiLine=$security_protcols = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::SystemDefault^

if ([Net.SecurityProtocolType].GetMember('Tls11').Count -gt 0) {^

 $security_protcols = $security_protcols -bor [Net.SecurityProtocolType]::Tls11^

}^

if ([Net.SecurityProtocolType].GetMember('Tls12').Count -gt 0) {^

$security_protcols = $security_protcols -bor [Net.SecurityProtocolType]::Tls12^

}^

[Net.ServicePointManager]::SecurityProtocol = $security_protcols^

Write-Host 'Downloading %URL%... ' -NoNewLine^

(New-Object Net.WebClient).DownloadFile('%URL%', '%FILE%')^

Write-Host 'done.'

powershell -Command !multiLine!
goto:eof
