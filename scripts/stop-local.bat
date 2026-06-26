@echo off
setlocal enabledelayedexpansion
:: =============================================================================
:: stop-local.bat: Stop Nginx and Tomcat on Windows
:: =============================================================================
:: Usage:
::   scripts\stop-local.bat
:: =============================================================================

call "%~dp0init-windows-env.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

set "TOMCAT_HOME=%PROJECT_DIR%\tomcat\apache-tomcat-10.1.56"
set "TOMCAT_BASE=%PROJECT_DIR%\tomcat"
set "NGINX_CONF=%PROJECT_DIR:\=/%/nginx/nginx-win.conf"

:: ---------------------------------------------------------------------------
:: 1. Stop Nginx
:: ---------------------------------------------------------------------------
echo.
echo [1/2] Stopping Nginx...
nginx.exe -p "%NGINX_HOME%" -s stop -c "%NGINX_CONF:/=\%" 2>nul
if %ERRORLEVEL% equ 0 (
    echo Nginx stopped.
) else (
    echo Nginx was not running or failed to stop gracefully. Trying taskkill...
    taskkill /f /im nginx.exe >nul 2>&1
    echo Nginx processes terminated.
)

:: ---------------------------------------------------------------------------
:: 2. Stop Tomcat
:: ---------------------------------------------------------------------------
echo.
echo [2/2] Stopping Tomcat...
set "CATALINA_HOME=%TOMCAT_HOME%"
set "CATALINA_BASE=%TOMCAT_BASE%"
cd /d "%TOMCAT_HOME%\bin"
call shutdown.bat 2>nul
if %ERRORLEVEL% equ 0 (
    echo Tomcat stopped.
) else (
    echo Tomcat shutdown script failed or was not running. Trying taskkill...
    taskkill /f /im java.exe >nul 2>&1
    echo Java processes terminated.
)

:: Wait a moment for ports to be released
powershell -Command "Start-Sleep -Seconds 2"

echo.
echo All services stopped.

endlocal
