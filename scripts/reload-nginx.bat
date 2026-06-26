@echo off
setlocal enabledelayedexpansion
:: =============================================================================
:: reload-nginx.bat: Reload Nginx configuration on Windows
:: =============================================================================
:: Usage:
::   scripts\reload-nginx.bat
::
:: Run this after modifying nginx/nginx-win.conf.template or
:: nginx/conf.d/default-win.conf.template.
:: =============================================================================

call "%~dp0init-windows-env.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

set "NGINX_CONF=%PROJECT_DIR:\=/%/nginx/nginx-win.conf"

echo Testing Nginx configuration...
nginx.exe -p "%NGINX_HOME%" -t -c "%NGINX_CONF:/=\%"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Nginx configuration test failed.
    exit /b %ERRORLEVEL%
)

echo Reloading Nginx...
nginx.exe -p "%NGINX_HOME%" -s reload -c "%NGINX_CONF:/=\%"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to reload Nginx.
    exit /b %ERRORLEVEL%
)

echo Nginx configuration reloaded.

endlocal
