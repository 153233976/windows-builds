@echo off
SETLOCAL
SET EL=0
echo ------ NODE-GDAL %1 %2 -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )

IF "%1"=="" ECHO no parameters && GOTO ERROR

SET NODE_VERSION=%1

cd %PKGDIR%\node-gdal
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST build ddt /Q build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST lib\binding ddt /Q lib\binding
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST node.exe DEL /Q node.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO downloading node.exe %NODE_VERSION% %PLATFORMX%
powershell Invoke-WebRequest "https://mapbox.s3.amazonaws.com/node-cpp11/v$env:NODE_VERSION/$env:PLATFORMX/node.exe" -OutFile $env:PKGDIR\node-gdal\node.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL node -v
CALL node -e "console.log(process.argv,process.execPath)" 
CALL npm --version 

REM CALL npm install https://github.com/naturalatlas/mocha/archive/fix/333.tar.gz
REM IF %ERRORLEVEL% NEQ 0 GOTO ERROR


ECHO.
ECHO ---------------- BUILDING  NODE-GDAL node^: %NODE_VERSION% %PLATFORMX% --------------

CALL node_modules\.bin\node-pre-gyp.cmd ^
--target=%NODE_VERSION% rebuild ^
--build-from-source ^
--msvs_version=2013 ^
--toolset=v140 ^
--target_arch=%PLATFORMX% ^
--dist-url=https://s3.amazonaws.com/mapbox/node-cpp11 ^
--enable-logging=true ^
--loglevel=http
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO.
ECHO ---------------- TESTING  NODE-GDAL node^: %NODE_VERSION% %PLATFORMX% --------------
CALL npm test
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO.
ECHO ---------------- PUBLISHING  NODE-GDAL node^: %NODE_VERSION% %PLATFORMX%--------------
call node_modules\.bin\node-pre-gyp.cmd ^
--target=%NODE_VERSION% package publish ^
--msvs_version=2013 ^
--toolset=v140 ^
--target_arch=%PLATFORMX% ^
--dist-url=https://s3.amazonaws.com/mapbox/node-cpp11 ^
--enable-logging=true ^
--loglevel=http
IF %ERRORLEVEL% EQU 0 GOTO DONE

:: reset ERRORLEVEL to not bail out and continue 
:: with other versions
SET ERRORLEVEL=0
ECHO.
ECHO.
ECHO ============================================
ECHO ============================================
ECHO ============================================
ECHO ============================================
ECHO ============================================
ECHO              PUBLISH FAILED
ECHO ============================================
ECHO ============================================
ECHO ============================================
ECHO ============================================
ECHO ============================================


GOTO DONE


:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE-GDAL %NODE_VERSION% %PLATFORMX% --------------

:DONE
echo ----------DONE NODE-GDAL %NODE_VERSION% %PLATFORMX%--------------


cd %ROOTDIR%
EXIT /b %EL%
