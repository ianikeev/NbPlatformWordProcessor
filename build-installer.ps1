#!/usr/bin/env pwsh
# WordProcessor Automated Build Script - Cross-Platform PowerShell Core
# Compatible with Windows (PowerShell 7+), Linux, and macOS

# --- [ Configuration & Setup ] ---------------------------------------

$ErrorActionPreference = "Stop"
$version = Get-Date -Format "yyyy.MM.dd.HHmm"
$appGuid = "{{23B70FBF-C3B3-4F38-8C20-C3D72ADCAA6D}"

# Set OS-specific Executables and Separators
# We use the built-in $IsWindows / $IsLinux variables directly
if ($IsWindows) {
    $exeExt = ".exe"
    $pathSep = ";"
    $nsisCmd = "makensis.exe" 
    $jlinkCmd = "jlink.exe"
} else {
    $exeExt = ""
    $pathSep = ":"
    $nsisCmd = "makensis"  # Assumes 'apt install nsis' or equivalent
    $jlinkCmd = "jlink"
}

# Define Paths (Using Join-Path for cross-platform slashes)
$distDir   = Join-Path $PSScriptRoot "dist"
$jreDest   = Join-Path $distDir "wordprocessor" | Join-Path -ChildPath "jre"
$outputDir = Join-Path $PSScriptRoot "Output"

Write-Host "========================================" -ForegroundColor Green
Write-Host "   WordProcessor Automated Build (Core) " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "OS Platform: $([System.Environment]::OSVersion.Platform)" -ForegroundColor Yellow
Write-Host "Version: $version" -ForegroundColor Yellow
Write-Host "Directory: $PSScriptRoot" -ForegroundColor Yellow
Write-Host ""

# --- [ Step 1: Build NetBeans App ] ----------------------------------
Write-Host "[1/2] Building application..." -ForegroundColor Cyan

if ($IsWindows) {
    $antExec = "ant.bat"
} else {
    $antExec = "ant"
}

try {
    & $antExec -quiet "-Dapp.version=$version" clean create-platform
} catch {
    Write-Host "ERROR: Ant build failed. Ensure Apache Ant is installed and in PATH." -ForegroundColor Red
    exit 1
}

Write-Host "Build successful!" -ForegroundColor Green

# --- [ Step 1.5: Create Custom JRE ] ---------------------------------
Write-Host "[1.5/2] Creating custom JRE..." -ForegroundColor Cyan

# Find JLink
$jlinkPath = "jlink" # Default to PATH
if ($env:JAVA_HOME) {
    # Construct path explicitly to ensure we use the JDK one
    if ($IsWindows) {
        $jlinkPath = Join-Path $env:JAVA_HOME "bin" "jlink.exe"
    } else {
        $jlinkPath = Join-Path $env:JAVA_HOME "bin" "jlink"
    }
}

# Verify JLink exists
if (-not (Get-Command $jlinkPath -ErrorAction SilentlyContinue)) {
    Write-Host "WARNING: jlink not found at $jlinkPath. Skipping JRE creation." -ForegroundColor Yellow
} else {
    # Clean previous JRE
    if (Test-Path $jreDest) {
        Remove-Item $jreDest -Recurse -Force
    }

    # Define Modules
    $modulesList = @(
        "java.base", "java.desktop", "java.instrument", "java.logging",
        "java.management", "java.naming", "java.prefs", "java.sql",
        "java.xml", "jdk.unsupported", "jdk.jsobject", "jdk.management"
    )
    
    # Join modules with comma (universal for jlink)
    $modulesArg = $modulesList -join ","

    # Run JLink
    $jlinkArgs = @(
        "--add-modules", $modulesArg,
        "--output", $jreDest,
        "--strip-debug",
        "--no-man-pages",
        "--no-header-files"
    )

    & $jlinkPath $jlinkArgs

    if (Test-Path (Join-Path $jreDest "bin" "java$exeExt")) {
        Write-Host "Custom JRE created successfully!" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Custom JRE creation might have failed." -ForegroundColor Yellow
    }
}

# --- [ Step 2: NSIS Installer ] --------------------------------------
Write-Host "[2/2] Creating NSIS installer..." -ForegroundColor Cyan

$nsisScript = Join-Path $PSScriptRoot "installer.nsis"
if (-not (Test-Path $nsisScript)) {
    Write-Host "ERROR: installer.nsis not found at $nsisScript" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Check if makensis is available
if (-not (Get-Command $nsisCmd -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: '$nsisCmd' is not in your PATH." -ForegroundColor Red
    if ($IsLinux) { Write-Host "Try: sudo apt install nsis" -ForegroundColor Gray }
    if ($IsMacOS) { Write-Host "Try: brew install nsis" -ForegroundColor Gray }
    exit 1
}

# Run NSIS
$nsisArgs = @(
    "/DAPP_VERSION=$version",
    "/DAPP_GUID=$appGuid",
    $nsisScript
)

& $nsisCmd $nsisArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: NSIS Compilation Failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "Installer: $(Join-Path $outputDir "MyWordProcessor-${version}-Setup.exe")" -ForegroundColor Yellow

# Open folder (Cross-platform way)
if ($IsWindows) { Start-Process "explorer.exe" $outputDir }
elseif ($IsMacOS) { Start-Process "open" $outputDir }
elseif ($IsLinux) { Start-Process "xdg-open" $outputDir }