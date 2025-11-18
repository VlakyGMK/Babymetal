#!/bin/bash
# Bash script to build Rocksmith 2014 CDLC (.psarc) for White Flame
# This script runs on Linux/Ubuntu GitHub Actions runners

set -e

OUTPUT_DIR="${1:-.}"
OUTPUT_NAME="${2:-White_Flame_Babymetal.psarc}"

echo "=== Rocksmith CDLC Build Script (Bash) ==="
echo "Building: $OUTPUT_NAME"

# Check for required files
required_files=(
    "White_Flame.wav"
    "song.xml"
    "arrangement_lead.xml"
    "arrangement_rhythm.xml"
)

echo ""
echo "Checking for required files..."
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "ERROR: Required file missing: $file" >&2
        exit 1
    fi
    echo "  ✓ Found: $file"
done

echo ""
echo "=== Attempting to build PSARC ==="

# Try to use pyrocksmith if Python is available
echo ""
echo "Attempting method 1: pyrocksmith (Python)..."
if command -v python3 &> /dev/null; then
    echo "Python3 found. Attempting to install pyrocksmith..."
    if python3 -m pip install --quiet pyrocksmith 2>/dev/null; then
        echo "pyrocksmith installed successfully"
        # pyrocksmith typically doesn't have direct CLI, note for future
    else
        echo "pyrocksmith installation failed, trying next method..."
    fi
else
    echo "Python3 not found, skipping pyrocksmith"
fi

# Try mono/dotnet approach
echo ""
echo "Attempting method 2: Checking for .NET/Mono..."
if command -v dotnet &> /dev/null; then
    echo "dotnet found: $(dotnet --version)"
    # Could potentially use RocksmithToolkitLib here if available as NuGet
elif command -v mono &> /dev/null; then
    echo "mono found: $(mono --version | head -n1)"
    # Could potentially use RocksmithToolkitLib here if compiled
else
    echo "Neither dotnet nor mono found"
fi

# For now, create a placeholder since actual Rocksmith toolkit may not be available
echo ""
echo "WARNING: Full PSARC build requires RocksmithToolkitLib or equivalent"
echo "Creating placeholder output for demonstration purposes"

# Create a minimal manifest for demonstration
cat > build_manifest.json <<EOF
{
  "Entries": {
    "audio.wem": "White_Flame.wav",
    "songs.xml": "song.xml",
    "lead.xml": "arrangement_lead.xml",
    "rhythm.xml": "arrangement_rhythm.xml"
  },
  "Version": "RS2014",
  "Artist": "Babymetal",
  "Title": "White Flame"
}
EOF

echo ""
echo "To complete the build, you need:"
echo "1. RocksmithToolkitLib (https://github.com/rscustom/rocksmith-custom-song-toolkit)"
echo "2. Wwise (for audio conversion)"
echo "3. PSARC packer tool"

echo ""
echo "Current files verified and ready for packaging:"
ls -1 *.xml White_Flame.wav 2>/dev/null | sed 's/^/  - /'

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo ""
echo "Manifest created: $OUTPUT_DIR/build_manifest.json"
mv build_manifest.json "$OUTPUT_DIR/"

echo ""
echo "=== Build Script Completed ==="
echo "Note: For actual PSARC creation, integrate with RocksmithToolkitLib CLI"
echo "See README_packaging.md for local build instructions"

exit 0
