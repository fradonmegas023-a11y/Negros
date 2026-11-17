@echo off
setlocal
set VERSION=8.13
if "%GRADLE_USER_HOME%"=="" set GRADLE_USER_HOME=%USERPROFILE%\.gradle
set BASE=%GRADLE_USER_HOME%\negros-gradle
set DIST=%BASE%\gradle-%VERSION%
set BIN=%DIST%\bin\gradle.bat
if not exist "%BIN%" (
  if not exist "%BASE%" mkdir "%BASE%"
  echo Downloading Gradle %VERSION% (first run only)...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-%VERSION%-bin.zip' -OutFile '%BASE%\gradle-%VERSION%-bin.zip'; Expand-Archive -Path '%BASE%\gradle-%VERSION%-bin.zip' -DestinationPath '%BASE%' -Force"
)
call "%BIN%" %*
endlocal
