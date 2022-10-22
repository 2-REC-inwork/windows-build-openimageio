
THIS SCRIPT DOESN'T WORK
+ missing some arguments


@echo off

set BOOST_ROOT=%cd%\boost_1_73_0

cd %BOOST_ROOT%

start /wait /b cmd /c bootstrap.bat vc142

start /wait /b b2.exe link=shared address-model=64 threading=multi

pause
exit /b