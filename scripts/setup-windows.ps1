# =============================================================================
# setup-windows.ps1: Download and extract portable JDK, Maven and Nginx for Windows
# =============================================================================
# This script installs the following tools into the project's tools/ directory:
#   - Eclipse Temurin JDK 17
#   - Apache Maven 3.9.x
#   - Nginx for Windows (stable)
#
# Run from the project root:
#   powershell -ExecutionPolicy Bypass -File scripts\setup-windows.ps1
# Or use the wrapper:
#   scripts\setup-windows.bat
# =============================================================================

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ToolsDir = Join-Path $ProjectRoot "tools"

if (!(Test-Path $ToolsDir)) {
    New-Item -ItemType Directory -Path $ToolsDir | Out-Null
    Write-Host "Created tools directory: $ToolsDir"
}

function Download-File {
    param(
        [string]$Url,
        [string]$OutFile,
        [string]$Description
    )

    if ((Test-Path $OutFile) -and !$Force) {
        Write-Host "  $Description already exists, skipping download."
        return
    }

    Write-Host "  Downloading $Description ..."
    Write-Host "    Source: $Url"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -MaximumRedirection 5
    }
    catch {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -MaximumRedirection 5
    }
    Write-Host "  Saved to: $OutFile"
}

function Expand-Zip {
    param(
        [string]$ZipFile,
        [string]$DestinationDir
    )
    Write-Host "  Extracting: $(Split-Path -Leaf $ZipFile)"
    Expand-Archive -Path $ZipFile -DestinationPath $DestinationDir -Force
}

# -----------------------------------------------------------------------------
# 1. Eclipse Temurin JDK 17
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "[1/3] Preparing JDK 17 ..."

$JdkMarker = Join-Path $ToolsDir "jdk"
$JdkZip = Join-Path $ToolsDir "jdk17.zip"

if ((Test-Path $JdkMarker) -and !$Force) {
    Write-Host "  JDK directory already exists: $JdkMarker. Use -Force to reinstall."
}
else {
    $JdkUrl = "https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse"
    Write-Host "  Downloading Eclipse Temurin JDK 17 ..."

    Download-File -Url $JdkUrl -OutFile $JdkZip -Description "JDK 17"

    $JdkExtractTemp = Join-Path $ToolsDir "jdk-extract-temp"
    if (Test-Path $JdkExtractTemp) { Remove-Item -Recurse -Force $JdkExtractTemp }
    New-Item -ItemType Directory -Path $JdkExtractTemp | Out-Null
    Expand-Zip -ZipFile $JdkZip -DestinationDir $JdkExtractTemp

    $ExtractedJdkDir = Get-ChildItem -Path $JdkExtractTemp -Directory | Select-Object -First 1
    if (Test-Path $JdkMarker) { Remove-Item -Recurse -Force $JdkMarker }
    Move-Item -Path $ExtractedJdkDir.FullName -Destination $JdkMarker
    Remove-Item -Recurse -Force $JdkExtractTemp
    Remove-Item -Path $JdkZip -Force
    Write-Host "  JDK installed at: $JdkMarker"
}

# -----------------------------------------------------------------------------
# 2. Apache Maven
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "[2/3] Preparing Apache Maven ..."

$MavenVersion = "3.9.9"
$MavenMarker = Join-Path $ToolsDir "maven"
$MavenZip = Join-Path $ToolsDir "maven-$MavenVersion-bin.zip"

if ((Test-Path $MavenMarker) -and !$Force) {
    Write-Host "  Maven directory already exists: $MavenMarker. Use -Force to reinstall."
}
else {
    $MavenUrl = "https://archive.apache.org/dist/maven/maven-3/$MavenVersion/binaries/apache-maven-$MavenVersion-bin.zip"
    Download-File -Url $MavenUrl -OutFile $MavenZip -Description "Apache Maven $MavenVersion"

    $MavenExtractTemp = Join-Path $ToolsDir "maven-extract-temp"
    if (Test-Path $MavenExtractTemp) { Remove-Item -Recurse -Force $MavenExtractTemp }
    New-Item -ItemType Directory -Path $MavenExtractTemp | Out-Null
    Expand-Zip -ZipFile $MavenZip -DestinationDir $MavenExtractTemp

    $ExtractedMavenDir = Join-Path $MavenExtractTemp "apache-maven-$MavenVersion"
    if (Test-Path $MavenMarker) { Remove-Item -Recurse -Force $MavenMarker }
    Move-Item -Path $ExtractedMavenDir -Destination $MavenMarker
    Remove-Item -Recurse -Force $MavenExtractTemp
    Remove-Item -Path $MavenZip -Force
    Write-Host "  Maven installed at: $MavenMarker"
}

# -----------------------------------------------------------------------------
# 3. Nginx for Windows
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "[3/3] Preparing Nginx for Windows ..."

$NginxVersion = "1.26.3"
$NginxMarker = Join-Path $ToolsDir "nginx"
$NginxZip = Join-Path $ToolsDir "nginx-$NginxVersion.zip"

if ((Test-Path $NginxMarker) -and !$Force) {
    Write-Host "  Nginx directory already exists: $NginxMarker. Use -Force to reinstall."
}
else {
    $NginxUrl = "https://nginx.org/download/nginx-$NginxVersion.zip"
    Download-File -Url $NginxUrl -OutFile $NginxZip -Description "Nginx $NginxVersion"

    $NginxExtractTemp = Join-Path $ToolsDir "nginx-extract-temp"
    if (Test-Path $NginxExtractTemp) { Remove-Item -Recurse -Force $NginxExtractTemp }
    New-Item -ItemType Directory -Path $NginxExtractTemp | Out-Null
    Expand-Zip -ZipFile $NginxZip -DestinationDir $NginxExtractTemp

    $ExtractedNginxDir = Join-Path $NginxExtractTemp "nginx-$NginxVersion"
    if (Test-Path $NginxMarker) { Remove-Item -Recurse -Force $NginxMarker }
    Move-Item -Path $ExtractedNginxDir -Destination $NginxMarker
    Remove-Item -Recurse -Force $NginxExtractTemp
    Remove-Item -Path $NginxZip -Force
    Write-Host "  Nginx installed at: $NginxMarker"
}

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host "Windows dependencies ready!"
Write-Host "============================================================"
Write-Host "  JDK:   $JdkMarker"
Write-Host "  Maven: $MavenMarker"
Write-Host "  Nginx: $NginxMarker"
Write-Host ""
Write-Host "Next step: run scripts\build.bat"
