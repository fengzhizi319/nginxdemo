@echo off
:: =============================================================================
:: setup-windows.bat: Wrapper for setup-windows.ps1
:: =============================================================================
:: Usage:
::   scripts\setup-windows.bat
::
:: This batch file calls the PowerShell script that downloads and extracts
:: portable JDK, Maven and Nginx into the tools/ directory.
:: =============================================================================

setlocal enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"
set "FORCE_FLAG=%~1"

powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%setup-windows.ps1" %FORCE_FLAG%

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Dependency installation failed. Please check the logs above.
    exit /b %ERRORLEVEL%
)

echo.
echo [DONE] Dependency installation completed.
endlocal
