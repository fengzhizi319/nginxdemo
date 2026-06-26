@echo off
setlocal enabledelayedexpansion
:: =============================================================================
:: build.bat: Build backend WAR and frontend dist on Windows
:: =============================================================================
:: Usage:
::   scripts\build.bat
::
:: Environment variables:
::   SET SKIP_TESTS=true   Skip unit tests to speed up the build
:: =============================================================================

call "%~dp0init-windows-env.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo Project directory: %PROJECT_DIR%

:: ---------------------------------------------------------------------------
:: 1. Build backend
:: ---------------------------------------------------------------------------
echo.
echo [1/3] Building backend Spring Boot WAR...
cd /d "%PROJECT_DIR%\backend"

if "%SKIP_TESTS%"=="true" (
    echo SKIP_TESTS=true, skipping Maven tests...
    call mvn.cmd clean package -DskipTests
) else (
    call mvn.cmd clean package
)

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Backend build failed.
    exit /b %ERRORLEVEL%
)

if not exist "%PROJECT_DIR%\tomcat\webapps" mkdir "%PROJECT_DIR%\tomcat\webapps"
copy /Y "%PROJECT_DIR%\backend\target\backend.war" "%PROJECT_DIR%\tomcat\webapps\backend.war" >nul
echo Backend WAR copied to: %PROJECT_DIR%\tomcat\webapps\backend.war

:: ---------------------------------------------------------------------------
:: 2. Build frontend
:: ---------------------------------------------------------------------------
echo.
echo [2/3] Building frontend UmiJS project...
cd /d "%PROJECT_DIR%\frontend"

call pnpm install
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Frontend dependency installation failed.
    exit /b %ERRORLEVEL%
)

call pnpm run build
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Frontend build failed.
    exit /b %ERRORLEVEL%
)

echo Frontend build complete. Output: %PROJECT_DIR%\frontend\dist

:: ---------------------------------------------------------------------------
:: 3. Summary
:: ---------------------------------------------------------------------------
echo.
echo [3/3] Build complete!
echo   - Backend WAR: %PROJECT_DIR%\tomcat\webapps\backend.war
echo   - Frontend dist: %PROJECT_DIR%\frontend\dist
echo.
echo Next step: run scripts\start-local.bat

endlocal
