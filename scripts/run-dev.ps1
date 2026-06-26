# =============================================================================
# run-dev.ps1: Start backend and frontend dev servers on Windows
# =============================================================================
# This script:
#   1. Starts Spring Boot backend (mvn spring-boot:run) in the background on port 8081.
#   2. Waits for the health endpoint to respond.
#   3. Starts the UmiJS dev server in the foreground on port 8000.
#   4. Stops the backend when the frontend dev server exits.
#
# Run via the wrapper:
#   scripts\run-dev.bat
# =============================================================================

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BackendLog = Join-Path $ProjectRoot "backend\backend-dev.log"
$BackendErrLog = Join-Path $ProjectRoot "backend\backend-dev.err.log"
$HealthUrl = "http://127.0.0.1:8081/backend/api/users/health"

# Cleanup function: stop backend process on exit
$BackendProc = $null
function Stop-Backend {
    if ($BackendProc -and !$BackendProc.HasExited) {
        Write-Host ""
        Write-Host "Stopping backend service..."
        Stop-Process -Id $BackendProc.Id -Force -ErrorAction SilentlyContinue
        Write-Host "Backend stopped (PID: $($BackendProc.Id))."
    }
}

# Ensure cleanup runs even if user presses Ctrl+C
trap { Stop-Backend; break }

# ---------------------------------------------------------------------------
# 1. Start backend
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "[1/3] Starting backend Spring Boot (embedded Tomcat, port 8081)..."

$BackendProc = Start-Process -FilePath "mvn.cmd" `
    -ArgumentList "spring-boot:run" `
    -WorkingDirectory "$ProjectRoot\backend" `
    -RedirectStandardOutput $BackendLog `
    -RedirectStandardError $BackendErrLog `
    -WindowStyle Hidden `
    -PassThru

Write-Host "Backend process started, PID: $($BackendProc.Id)"
Write-Host "Backend log: $BackendLog"

# ---------------------------------------------------------------------------
# 2. Wait for backend readiness
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "[2/3] Waiting for backend health endpoint: $HealthUrl"

$MaxRetry = 30
$Ready = $false
for ($Retry = 1; $Retry -le $MaxRetry; $Retry++) {
    try {
        $Response = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($Response.StatusCode -eq 200) {
            Write-Host "Backend is ready!"
            Write-Host "  Health check: $HealthUrl"
            Write-Host "  User list:    http://127.0.0.1:8081/backend/api/users"
            $Ready = $true
            break
        }
    }
    catch {
        # Check if backend process crashed
        if ($BackendProc.HasExited) {
            Write-Host ""
            Write-Host "[ERROR] Backend process exited unexpectedly."
            Write-Host "Check logs: $BackendLog"
            exit 1
        }
    }
    Write-Host "  Waiting for backend... ($Retry/$MaxRetry)"
    Start-Sleep -Seconds 2
}

if (-not $Ready) {
    Write-Host ""
    Write-Host "[ERROR] Backend did not become ready after $MaxRetry attempts."
    Write-Host "Check logs: $BackendLog"
    Stop-Backend
    exit 1
}

# ---------------------------------------------------------------------------
# 3. Start frontend dev server (foreground)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "[3/3] Starting frontend UmiJS dev server (port 8000)..."
Write-Host ""
Write-Host "Access URLs:"
Write-Host "  - Frontend:       http://127.0.0.1:8000"
Write-Host "  - API via proxy:  http://127.0.0.1:8000/api/users"
Write-Host "  - Backend direct: http://127.0.0.1:8081/backend/api/users"
Write-Host ""
Write-Host "Press Ctrl+C in this window to stop both servers."
Write-Host ""

cd "$ProjectRoot\frontend"
pnpm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Frontend dependency installation failed."
    Stop-Backend
    exit 1
}

pnpm run dev

# ---------------------------------------------------------------------------
# 4. Cleanup
# ---------------------------------------------------------------------------
Stop-Backend
