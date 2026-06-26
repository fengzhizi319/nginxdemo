@echo off
setlocal enabledelayedexpansion
:: =============================================================================
:: start-local.bat: Start Nginx and Tomcat on Windows
:: =============================================================================
:: Usage:
::   scripts\start-local.bat
::
:: This script:
::   1. Checks that backend.war and frontend/dist exist.
::   2. Starts Nginx with nginx/nginx-win.conf.
::   3. Starts Tomcat from tomcat/apache-tomcat-10.1.56.
:: =============================================================================

call "%~dp0init-windows-env.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

set "TOMCAT_HOME=%PROJECT_DIR%\tomcat\apache-tomcat-10.1.56"
set "TOMCAT_BASE=%PROJECT_DIR%\tomcat"
set "BACKEND_WAR=%PROJECT_DIR%\tomcat\webapps\backend.war"
set "FRONTEND_DIST=%PROJECT_DIR%\frontend\dist"

:: ---------------------------------------------------------------------------
:: 1. Check required files
:: ---------------------------------------------------------------------------
echo.
echo [1/4] Checking required files...

if not exist "%TOMCAT_HOME%" (
    echo [ERROR] Tomcat home not found: %TOMCAT_HOME%
    exit /b 1
)

if not exist "%BACKEND_WAR%" (
    echo [ERROR] Backend WAR not found: %BACKEND_WAR%
    echo Please run scripts\build.bat first.
    exit /b 1
)

if not exist "%FRONTEND_DIST%" (
    echo [ERROR] Frontend dist not found: %FRONTEND_DIST%
    echo Please run scripts\build.bat first.
    exit /b 1
)

echo Check passed.

:: ---------------------------------------------------------------------------
:: 2. Validate Nginx config
:: ---------------------------------------------------------------------------
echo.
echo [2/4] Validating Nginx configuration...
nginx.exe -p "%NGINX_HOME%" -t -c "%PROJECT_DIR:/=\%\nginx\nginx-win.conf"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Nginx configuration test failed.
    exit /b %ERRORLEVEL%
)

:: ---------------------------------------------------------------------------
:: 3. Start Nginx
:: ---------------------------------------------------------------------------
echo.
echo [3/4] Starting Nginx...
start /b "" nginx.exe -p "%NGINX_HOME%" -c "%PROJECT_DIR:/=\%\nginx\nginx-win.conf"
powershell -Command "Start-Sleep -Seconds 2"

:: Check if Nginx is listening on 8088
netstat -an | findstr ":8090 " | findstr "LISTENING" >nul
if %ERRORLEVEL% equ 0 (
    echo Nginx started successfully, listening on port 8090.
) else (
    echo [WARNING] Nginx may not have started yet. Check nginx/logs/error.log
)

:: ---------------------------------------------------------------------------
:: 4. Start Tomcat
:: ---------------------------------------------------------------------------
echo.
echo [4/4] Starting Tomcat...
set "CATALINA_HOME=%TOMCAT_HOME%"
set "CATALINA_BASE=%TOMCAT_BASE%"
cd /d "%TOMCAT_HOME%\bin"
call catalina.bat start
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to start Tomcat.
    exit /b %ERRORLEVEL%
)

powershell -Command "Start-Sleep -Seconds 3"
netstat -an | findstr ":8080 " | findstr "LISTENING" >nul
if %ERRORLEVEL% equ 0 (
    echo Tomcat started successfully, listening on port 8080.
) else (
    echo [WARNING] Tomcat may not have finished starting. Check tomcat/logs/catalina.out
)

:: ---------------------------------------------------------------------------
:: 5. Access URLs
:: ---------------------------------------------------------------------------
echo.
echo ============================================================
echo Services started!
echo ============================================================
echo   - Frontend: http://127.0.0.1:8090
echo   - API via Nginx: http://127.0.0.1:8090/api/users
echo   - Backend direct: http://127.0.0.1:8080/backend/api/users
echo.
echo To stop: scripts\stop-local.bat
echo   Tomcat log: %TOMCAT_BASE%\logs\catalina.out
echo   Nginx log:  %PROJECT_DIR%\nginx\logs\error.log

endlocal
