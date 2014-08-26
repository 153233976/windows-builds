@echo off
echo ------ gdal -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download gdal-%GDAL_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST gdal (
  echo found extracted sources
)

if NOT EXIST gdal (
  echo extracting
  CALL bsdtar xfz gdal-%GDAL_VERSION%.tar.gz
  rename gdal-%GDAL_VERSION% gdal
  IF ERRORLEVEL 1 GOTO ERROR
)

cd gdal
IF ERRORLEVEL 1 GOTO ERROR

echo When compiling 64bit download libexpat dev packages from http://www.gtk.org/download/win64.php
::echo Also un-comment WIN64=YES in nmake.opt -> can be passed as argument, see below
echo.
echo If there is an error about missing 'expat.h' change
echo <include expat.h> to
echo #include "C:\Expat2.1.0\Source\lib\expat.h"
echo gdal/gdal/ogr/ogr_expat.h
echo.

::https://trac.osgeo.org/gdal/wiki/BuildingOnWindows
::see basic options

::MSVC_VER compiler version
::http://stackoverflow.com/a/2676904
::VS2010 MSC_VER=1600
::VS2012 MSC_VER=1700
::VS2013 MSC_VER=1800


:: !!! BUILD FIRST and then do 'devinstall'!!!
SET EXPAT_DIR="%PKGDIR%\expat"

IF %BUILDPLATFORM% EQU x64 (
    ECHO cleaning .....
    CALL nmake /F makefile.vc clean WIN64=YES
    IF ERRORLEVEL 1 GOTO ERROR
    ECHO building ....
    CALL nmake /A /F makefile.vc MSVC_VER=1800 WIN64=YES
    IF ERRORLEVEL 1 GOTO ERROR
    :: nmake /F makefile.vc devinstall WIN64=YES MSVC_VER=1800 GDAL_HOME=C:\dev2\mapnik-dependencies\64_gdal
) ELSE (
    ECHO cleaning .....
    CALL nmake /F makefile.vc clean
    IF ERRORLEVEL 1 GOTO ERROR
    ECHO building ....
    CALL nmake /A /F makefile.vc MSVC_VER=1800
    IF ERRORLEVEL 1 GOTO ERROR
    :: nmake /F makefile.vc devinstall MSVC_VER=1800 GDAL_HOME=C:\dev2\mapnik-dependencies\32_gdal
)


::ECHO upgrading solution
::CALL devenv.exe /upgrade makegdal10.sln
::IF ERRORLEVEL 1 GOTO ERROR

::ECHO building ...
::CALL msbuild makegdal10.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=Win32
::IF ERRORLEVEL 1 GOTO ERROR


GOTO DONE

:ERROR
echo ----------ERROR gdal --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%