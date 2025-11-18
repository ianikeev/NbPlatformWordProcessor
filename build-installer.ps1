# WordProcessor Automated Build Script - NSIS Version
# PowerShell version - more reliable than batch

# Generate version timestamp
$version = Get-Date -Format "yyyy.MM.dd.HHmm"
$appGuid = "{{23B70FBF-C3B3-4F38-8C20-C3D72ADCAA6D}"

Write-Host "========================================" -ForegroundColor Green
Write-Host "   WordProcessor Automated Build (NSIS)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Version: $version" -ForegroundColor Yellow
Write-Host "App GUID: $appGuid" -ForegroundColor Yellow
Write-Host "Directory: $PSScriptRoot" -ForegroundColor Yellow
Write-Host ""

# Step 1: Build the NetBeans application
Write-Host "[1/2] Building application..." -ForegroundColor Cyan
& ant -quiet "-Dapp.version=$version" clean create-platform

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "Build successful!" -ForegroundColor Green

# Alternative: Create minimal JRE with required modules
Write-Host "[1.5/2] Creating custom JRE with required modules..." -ForegroundColor Cyan

if (Test-Path $env:JAVA_HOME) {
    $jlinkPath = "$env:JAVA_HOME\bin\jlink.exe"
    
    if (Test-Path $jlinkPath) {
        $jreDest = ".\dist\wordprocessor\jre"
        
        if (Test-Path $jreDest) {
            Remove-Item $jreDest -Recurse -Force
        }
        
        # Modules required by NetBeans platform
        $modules = @(
            "java.base",
            "java.desktop",
            "java.instrument",  # Critical - includes IllegalClassFormatException
            "java.logging",
            "java.management",
            "java.naming",
            "java.prefs",
            "java.sql",
            "java.xml",
            "jdk.unsupported",
            "jdk.jsobject",
            "jdk.management"
        ) -join ","
        
        & $jlinkPath --add-modules $modules --output $jreDest --strip-debug --no-man-pages --no-header-files
        
        if (Test-Path "$jreDest\bin\java.exe") {
            Write-Host "Custom JRE created successfully with required modules!" -ForegroundColor Green
        } else {
            Write-Host "WARNING: Custom JRE creation may have failed" -ForegroundColor Yellow
        }
    } else {
        Write-Host "WARNING: jlink.exe not found. Using full JDK copy." -ForegroundColor Yellow
        # Fall back to full JDK copy
    }
}

# Step 2: Create installer using NSIS
Write-Host "[2/2] Creating NSIS installer..." -ForegroundColor Cyan
if (-not (Test-Path "installer.nsis")) {
    Write-Host "ERROR: installer.nsis not found!" -ForegroundColor Red
    Write-Host "Looking in: $PSScriptRoot" -ForegroundColor Red
    pause
    exit 1
}

# Create Output directory if it doesn't exist
if (-not (Test-Path "Output")) {
    New-Item -ItemType Directory -Path "Output" | Out-Null
}

# Compile NSIS installer with version and GUID parameters
$nsisArgs = @(
    "/DAPP_VERSION=$version",
    "/DAPP_GUID=$appGuid",
    "installer.nsis"
)

& "makensis.exe" $nsisArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: NSIS installer compilation failed!" -ForegroundColor Red
    Write-Host "Make sure NSIS is installed and is in PATH." -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Version: $version" -ForegroundColor Yellow
Write-Host "App GUID: $appGuid" -ForegroundColor Yellow
Write-Host "Installer: Output\MyWordProcessor-${version}-Setup.exe" -ForegroundColor Yellow
Write-Host ""

# Optional: Open the output directory
$outputDir = Join-Path $PSScriptRoot "Output"
if (Test-Path $outputDir) {
    Write-Host "Opening output directory..." -ForegroundColor Cyan
    Start-Process "explorer.exe" $outputDir
}