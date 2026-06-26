@echo off
setlocal enabledelayedexpansion
:: =============================================================================
:: test.bat: Run all unit tests on Windows
:: =============================================================================
:: Usage:
::   scripts\test.bat
::
:: This script runs:
::   1. Backend Maven tests (mvn test).
::   2. Frontend Vitest tests (pnpm run test:run).
:: =============================================================================

call "%~dp0init-windows-env.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

set BACKEND_TEST_FAILED=0
set FRONTEND_TEST_FAILED=0

:: ---------------------------------------------------------------------------
:: 1. Backend tests
:: ---------------------------------------------------------------------------
echo.
echo [1/2] Running backend Maven tests...
cd /d "%PROJECT_DIR%\backend"

call mvn.cmd test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Backend tests failed.
    set BACKEND_TEST_FAILED=1
) else (
    echo Backend tests passed.
)

:: ---------------------------------------------------------------------------
:: 2. Frontend tests
:: ---------------------------------------------------------------------------
echo.
echo [2/2] Running frontend Vitest tests...
cd /d "%PROJECT_DIR%\frontend"

call pnpm install
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Frontend dependency installation failed.
    set FRONTEND_TEST_FAILED=1
    goto :summary
)

call pnpm run test:run
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Frontend tests failed.
    set FRONTEND_TEST_FAILED=1
) else (
    echo Frontend tests passed.
)

:: ---------------------------------------------------------------------------
:: 3. Summary
:: ---------------------------------------------------------------------------
:summary
echo.
echo ============================================================
echo Test Summary
if %BACKEND_TEST_FAILED% equ 0 (
    echo   [PASS] Backend tests
) else (
    echo   [FAIL] Backend tests
)
if %FRONTEND_TEST_FAILED% equ 0 (
    echo   [PASS] Frontend tests
) else (
    echo   [FAIL] Frontend tests
)
echo ============================================================

if %BACKEND_TEST_FAILED% equ 0 if %FRONTEND_TEST_FAILED% equ 0 (
    echo All tests passed!
    exit /b 0
) else (
    echo Some tests failed. Please check the logs above.
    exit /b 1
)

endlocal
