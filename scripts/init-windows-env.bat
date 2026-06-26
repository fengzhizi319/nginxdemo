@echo off
setlocal enabledelayedexpansion
:: =============================================================================
:: init-windows-env.bat: Initialize environment variables and Nginx configs for Windows
:: =============================================================================
:: This script is sourced by other .bat scripts. It:
::   1. Detects the project root directory.
::   2. Sets JAVA_HOME, MAVEN_HOME, NGINX_HOME to the portable tools/ directory.
::   3. Updates PATH so java, mvn and nginx are available.
::   4. Generates nginx-win.conf and default-win.conf from templates.
::   5. Creates nginx/logs and nginx/tmp directories.
::
:: Do not run this directly; use build.bat, start-local.bat, etc.
:: =============================================================================

:: --- Project root (parent of scripts directory) ---
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%") do set "PROJECT_DIR=%%~dpI"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "TOOLS_DIR=%PROJECT_DIR%\tools"
set "JAVA_HOME=%TOOLS_DIR%\jdk"
set "MAVEN_HOME=%TOOLS_DIR%\maven"
set "NGINX_HOME=%TOOLS_DIR%\nginx"

:: --- Validate that tools are installed ---
if not exist "%JAVA_HOME%\bin\java.exe" (
    echo [ERROR] JDK not found at %JAVA_HOME%
    echo Please run scripts\setup-windows.bat first.
    exit /b 1
)
if not exist "%MAVEN_HOME%\bin\mvn.cmd" (
    echo [ERROR] Maven not found at %MAVEN_HOME%
    echo Please run scripts\setup-windows.bat first.
    exit /b 1
)
if not exist "%NGINX_HOME%\nginx.exe" (
    echo [ERROR] Nginx not found at %NGINX_HOME%
    echo Please run scripts\setup-windows.bat first.
    exit /b 1
)

:: --- Update PATH ---
set "PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%NGINX_HOME%;%PATH%"

:: --- Path with forward slashes for Nginx config ---
set "NGINX_PROJECT_DIR=%PROJECT_DIR:\=/%"

:: --- Generate Nginx configs from templates ---
if not exist "%PROJECT_DIR%\nginx\nginx-win.conf.template" (
    echo [ERROR] Template not found: %PROJECT_DIR%\nginx\nginx-win.conf.template
    exit /b 1
)
if not exist "%PROJECT_DIR%\nginx\conf.d\default-win.conf.template" (
    echo [ERROR] Template not found: %PROJECT_DIR%\nginx\conf.d\default-win.conf.template
    exit /b 1
)

powershell -NoProfile -Command "[System.IO.File]::WriteAllText('%PROJECT_DIR%\nginx\nginx-win.conf', ((Get-Content '%PROJECT_DIR%\nginx\nginx-win.conf.template') -replace '{{PROJECT_DIR}}', '%NGINX_PROJECT_DIR%' -join [Environment]::NewLine), [System.Text.UTF8Encoding]::new($false))"
powershell -NoProfile -Command "[System.IO.File]::WriteAllText('%PROJECT_DIR%\nginx\conf.d\default-win.conf', ((Get-Content '%PROJECT_DIR%\nginx\conf.d\default-win.conf.template') -replace '{{PROJECT_DIR}}', '%NGINX_PROJECT_DIR%' -join [Environment]::NewLine), [System.Text.UTF8Encoding]::new($false))"

:: --- Create required directories ---
if not exist "%PROJECT_DIR%\nginx\logs" mkdir "%PROJECT_DIR%\nginx\logs"
if not exist "%PROJECT_DIR%\nginx\tmp\client_body" mkdir "%PROJECT_DIR%\nginx\tmp\client_body"
if not exist "%PROJECT_DIR%\nginx\tmp\fastcgi" mkdir "%PROJECT_DIR%\nginx\tmp\fastcgi"
if not exist "%PROJECT_DIR%\nginx\tmp\proxy" mkdir "%PROJECT_DIR%\nginx\tmp\proxy"
if not exist "%PROJECT_DIR%\nginx\tmp\scgi" mkdir "%PROJECT_DIR%\nginx\tmp\scgi"
if not exist "%PROJECT_DIR%\nginx\tmp\uwsgi" mkdir "%PROJECT_DIR%\nginx\tmp\uwsgi"
:: Nginx binary default prefix is tools/nginx; create its default logs dir to avoid startup alert
if not exist "%NGINX_HOME%\logs" mkdir "%NGINX_HOME%\logs"
if not exist "%PROJECT_DIR%\tomcat\logs" mkdir "%PROJECT_DIR%\tomcat\logs"
if not exist "%PROJECT_DIR%\tomcat\temp" mkdir "%PROJECT_DIR%\tomcat\temp"
if not exist "%PROJECT_DIR%\tomcat\webapps" mkdir "%PROJECT_DIR%\tomcat\webapps"

endlocal & (
    set "PROJECT_DIR=%PROJECT_DIR%"
    set "TOOLS_DIR=%TOOLS_DIR%"
    set "JAVA_HOME=%JAVA_HOME%"
    set "MAVEN_HOME=%MAVEN_HOME%"
    set "NGINX_HOME=%NGINX_HOME%"
    set "PATH=%PATH%"
)
