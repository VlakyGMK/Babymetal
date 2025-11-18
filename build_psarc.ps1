# build_psarc.ps1
# PowerShell script to build Rocksmith 2014 CDLC (.psarc) for Babymetal - White Flame
# This script runs on Windows and validates required files and tools

param(
    [string]$OutputDir = "dist",
    [string]$OutputFile = "White_Flame_Babymetal.psarc"
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Babymetal - White Flame PSARC Builder" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Validate required input files
Write-Host "Validating required files..." -ForegroundColor Yellow

$requiredFiles = @(
    "White_Flame.wav",
    "song.xml",
    "arrangement_lead.xml",
    "arrangement_rhythm.xml"
)

$allFilesPresent = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  [OK] Found: $file" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] Missing: $file" -ForegroundColor Red
        $allFilesPresent = $false
    }
}

if (-not $allFilesPresent) {
    Write-Host ""
    Write-Host "ERROR: Required files are missing!" -ForegroundColor Red
    Write-Host "Please ensure all required files are in the repository root:" -ForegroundColor Red
    Write-Host "  - White_Flame.wav" -ForegroundColor Red
    Write-Host "  - song.xml" -ForegroundColor Red
    Write-Host "  - arrangement_lead.xml" -ForegroundColor Red
    Write-Host "  - arrangement_rhythm.xml" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "All required files are present." -ForegroundColor Green
Write-Host ""

# Create output directory
if (-not (Test-Path $OutputDir)) {
    Write-Host "Creating output directory: $OutputDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Search for Rocksmith Toolkit
Write-Host "Searching for Rocksmith Custom Song Toolkit..." -ForegroundColor Yellow

$toolkitPaths = @(
    "C:\Program Files (x86)\Rocksmith Custom Song Toolkit\RocksmithToolkitCLI.exe",
    "C:\Program Files\Rocksmith Custom Song Toolkit\RocksmithToolkitCLI.exe",
    "${env:ProgramFiles(x86)}\Rocksmith Custom Song Toolkit\RocksmithToolkitCLI.exe",
    "${env:ProgramFiles}\Rocksmith Custom Song Toolkit\RocksmithToolkitCLI.exe",
    ".\RocksmithToolkitCLI.exe",
    ".\tools\RocksmithToolkitCLI.exe"
)

$toolkitExe = $null
foreach ($path in $toolkitPaths) {
    if (Test-Path $path) {
        $toolkitExe = $path
        Write-Host "  [OK] Found toolkit at: $path" -ForegroundColor Green
        break
    }
}

if ($null -eq $toolkitExe) {
    Write-Host ""
    Write-Host "ERROR: Rocksmith Custom Song Toolkit not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Rocksmith Custom Song Toolkit from:" -ForegroundColor Yellow
    Write-Host "  https://github.com/rscustom/rocksmith-custom-song-toolkit" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or place RocksmithToolkitCLI.exe in one of these locations:" -ForegroundColor Yellow
    foreach ($path in $toolkitPaths) {
        Write-Host "  - $path" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Alternative: Install .NET SDK and try using a .NET-based packager." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""

# Build the PSARC
$outputPath = Join-Path $OutputDir $OutputFile

Write-Host "Building PSARC package..." -ForegroundColor Yellow
Write-Host "  Toolkit: $toolkitExe" -ForegroundColor Gray
Write-Host "  Output: $outputPath" -ForegroundColor Gray
Write-Host ""

try {
    # Note: The actual CLI parameters may vary depending on the toolkit version
    # This is a template - adjust as needed for your specific toolkit
    
    # Attempt to run the toolkit (syntax may need adjustment)
    & $toolkitExe `
        --input "White_Flame.wav" `
        --output "$outputPath" `
        --metadata "song.xml" `
        --lead "arrangement_lead.xml" `
        --rhythm "arrangement_rhythm.xml" `
        2>&1 | Tee-Object -Variable toolkitOutput
    
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -ne 0) {
        Write-Host ""
        Write-Host "WARNING: Toolkit exited with code $exitCode" -ForegroundColor Yellow
        Write-Host "This may be normal if the toolkit doesn't support these exact parameters." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Toolkit output:" -ForegroundColor Gray
        Write-Host $toolkitOutput -ForegroundColor Gray
        Write-Host ""
        Write-Host "Please build manually using Rocksmith Toolkit GUI:" -ForegroundColor Yellow
        Write-Host "  1. Open Rocksmith Custom Song Toolkit" -ForegroundColor Cyan
        Write-Host "  2. Create new CDLC project" -ForegroundColor Cyan
        Write-Host "  3. Add White_Flame.wav as audio" -ForegroundColor Cyan
        Write-Host "  4. Import arrangement_lead.xml and arrangement_rhythm.xml" -ForegroundColor Cyan
        Write-Host "  5. Import metadata from song.xml" -ForegroundColor Cyan
        Write-Host "  6. Build and save as White_Flame_Babymetal.psarc" -ForegroundColor Cyan
        Write-Host ""
    }
    
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to run Rocksmith Toolkit CLI" -ForegroundColor Red
    Write-Host "Error details: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please build manually using Rocksmith Toolkit GUI (see README_packaging.md)" -ForegroundColor Yellow
    exit 1
}

# Verify output file was created
if (Test-Path $outputPath) {
    $fileSize = (Get-Item $outputPath).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! PSARC package built successfully" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Output file: $outputPath" -ForegroundColor Cyan
    Write-Host "File size: $fileSizeMB MB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Copy the .psarc file to your Rocksmith 2014 DLC folder" -ForegroundColor Gray
    Write-Host "  2. Launch Rocksmith 2014" -ForegroundColor Gray
    Write-Host "  3. Look for 'White Flame' by Babymetal in your song list" -ForegroundColor Gray
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "WARNING: Output file was not created at expected location" -ForegroundColor Yellow
    Write-Host "Expected: $outputPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "This may indicate that the CLI parameters need adjustment." -ForegroundColor Yellow
    Write-Host "Please refer to README_packaging.md for manual build instructions." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

exit 0
