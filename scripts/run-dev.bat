@echo off
setlocal enabledelayedexpansion
:: =============================================================================
:: run-dev.bat: Start backend and frontend dev servers on Windows
:: =============================================================================
:: Usage:
::   scripts\run-dev.bat
::
:: This script initializes the environment and then calls run-dev.ps1.
:: Press Ctrl+C in the terminal to stop both servers.
:: =============================================================================

call "%~dp0init-windows-env.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

powershell -ExecutionPolicy Bypass -File "%~dp0run-dev.ps1"

endlocal
