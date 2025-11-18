#!/bin/bash
# build_psarc.sh
# Bash script to build Rocksmith 2014 CDLC (.psarc) for Babymetal - White Flame
# This script runs on Linux/macOS and validates required files and tools

set -e

OUTPUT_DIR="dist"
OUTPUT_FILE="White_Flame_Babymetal.psarc"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================"
echo -e "Babymetal - White Flame PSARC Builder"
echo -e "========================================${NC}"
echo ""

# Validate required input files
echo -e "${YELLOW}Validating required files...${NC}"

required_files=(
    "White_Flame.wav"
    "song.xml"
    "arrangement_lead.xml"
    "arrangement_rhythm.xml"
)

all_files_present=true
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}[OK]${NC} Found: $file"
    else
        echo -e "  ${RED}[ERROR]${NC} Missing: $file"
        all_files_present=false
    fi
done

if [ "$all_files_present" = false ]; then
    echo ""
    echo -e "${RED}ERROR: Required files are missing!${NC}"
    echo -e "${RED}Please ensure all required files are in the repository root:${NC}"
    echo -e "${RED}  - White_Flame.wav${NC}"
    echo -e "${RED}  - song.xml${NC}"
    echo -e "${RED}  - arrangement_lead.xml${NC}"
    echo -e "${RED}  - arrangement_rhythm.xml${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}All required files are present.${NC}"
echo ""

# Create output directory
if [ ! -d "$OUTPUT_DIR" ]; then
    echo -e "${YELLOW}Creating output directory: $OUTPUT_DIR${NC}"
    mkdir -p "$OUTPUT_DIR"
fi

# Check for required tools
echo -e "${YELLOW}Checking for required tools...${NC}"

# Check for mono (required to run .NET apps on Linux)
if command -v mono &> /dev/null; then
    echo -e "  ${GREEN}[OK]${NC} Found: mono ($(mono --version | head -n1))"
    HAVE_MONO=true
else
    echo -e "  ${YELLOW}[WARN]${NC} mono not found"
    HAVE_MONO=false
fi

# Check for dotnet
if command -v dotnet &> /dev/null; then
    echo -e "  ${GREEN}[OK]${NC} Found: dotnet ($(dotnet --version))"
    HAVE_DOTNET=true
else
    echo -e "  ${YELLOW}[WARN]${NC} dotnet not found"
    HAVE_DOTNET=false
fi

# Check for ffmpeg (optional, for audio conversion)
if command -v ffmpeg &> /dev/null; then
    echo -e "  ${GREEN}[OK]${NC} Found: ffmpeg ($(ffmpeg -version | head -n1 | cut -d' ' -f3))"
    HAVE_FFMPEG=true
else
    echo -e "  ${YELLOW}[WARN]${NC} ffmpeg not found (optional)"
    HAVE_FFMPEG=false
fi

echo ""

# Search for Rocksmith Toolkit
echo -e "${YELLOW}Searching for Rocksmith Custom Song Toolkit...${NC}"

toolkit_paths=(
    "./RocksmithToolkitCLI.exe"
    "./tools/RocksmithToolkitCLI.exe"
    "$HOME/RocksmithToolkit/RocksmithToolkitCLI.exe"
    "/opt/RocksmithToolkit/RocksmithToolkitCLI.exe"
)

toolkit_exe=""
for path in "${toolkit_paths[@]}"; do
    if [ -f "$path" ]; then
        toolkit_exe="$path"
        echo -e "  ${GREEN}[OK]${NC} Found toolkit at: $path"
        break
    fi
done

if [ -z "$toolkit_exe" ]; then
    echo -e "  ${YELLOW}[WARN]${NC} Rocksmith Toolkit CLI not found in standard locations"
    echo ""
    
    if [ "$HAVE_MONO" = false ] && [ "$HAVE_DOTNET" = false ]; then
        echo -e "${RED}ERROR: Neither Rocksmith Toolkit nor Mono/DotNet runtime found!${NC}"
        echo ""
        echo -e "${YELLOW}Please install one of the following:${NC}"
        echo -e "${CYAN}Option 1: Install Mono${NC}"
        echo "  Ubuntu/Debian: sudo apt-get install mono-complete"
        echo "  macOS: brew install mono"
        echo ""
        echo -e "${CYAN}Option 2: Install .NET SDK${NC}"
        echo "  https://dotnet.microsoft.com/download"
        echo ""
        echo -e "${CYAN}Option 3: Install Rocksmith Custom Song Toolkit${NC}"
        echo "  https://github.com/rscustom/rocksmith-custom-song-toolkit"
        echo ""
        exit 1
    fi
fi

# Build the PSARC
output_path="$OUTPUT_DIR/$OUTPUT_FILE"

echo -e "${YELLOW}Building PSARC package...${NC}"
if [ -n "$toolkit_exe" ]; then
    echo -e "  Toolkit: ${GRAY}$toolkit_exe${NC}"
fi
echo -e "  Output: ${GRAY}$output_path${NC}"
echo ""

if [ -n "$toolkit_exe" ]; then
    # Attempt to run the toolkit with mono
    if [ "$HAVE_MONO" = true ]; then
        echo -e "${YELLOW}Running Rocksmith Toolkit CLI with Mono...${NC}"
        
        # Note: The actual CLI parameters may vary depending on the toolkit version
        # This is a template - adjust as needed for your specific toolkit
        if mono "$toolkit_exe" \
            --input "White_Flame.wav" \
            --output "$output_path" \
            --metadata "song.xml" \
            --lead "arrangement_lead.xml" \
            --rhythm "arrangement_rhythm.xml" 2>&1; then
            echo -e "${GREEN}Toolkit completed successfully${NC}"
        else
            exit_code=$?
            echo ""
            echo -e "${YELLOW}WARNING: Toolkit exited with code $exit_code${NC}"
            echo -e "${YELLOW}This may be normal if the toolkit doesn't support these exact parameters.${NC}"
            echo ""
        fi
    elif [ "$HAVE_DOTNET" = true ]; then
        echo -e "${YELLOW}Attempting to run with dotnet...${NC}"
        echo -e "${YELLOW}(This may not work if the toolkit requires full .NET Framework)${NC}"
        # Most likely won't work, but worth a try
        dotnet "$toolkit_exe" \
            --input "White_Flame.wav" \
            --output "$output_path" \
            --metadata "song.xml" \
            --lead "arrangement_lead.xml" \
            --rhythm "arrangement_rhythm.xml" 2>&1 || true
    fi
else
    echo -e "${YELLOW}No automated build tool found.${NC}"
    echo ""
    echo -e "${YELLOW}Manual build steps:${NC}"
    echo -e "${CYAN}1. Install Rocksmith Custom Song Toolkit${NC}"
    echo "   Download from: https://github.com/rscustom/rocksmith-custom-song-toolkit"
    echo ""
    echo -e "${CYAN}2. Install Mono (if on Linux)${NC}"
    echo "   Ubuntu/Debian: sudo apt-get install mono-complete"
    echo "   macOS: brew install mono"
    echo ""
    echo -e "${CYAN}3. Run the toolkit GUI${NC}"
    echo "   mono RocksmithToolkitGUI.exe"
    echo ""
    echo -e "${CYAN}4. Create CDLC project${NC}"
    echo "   - Add White_Flame.wav as audio"
    echo "   - Import arrangement_lead.xml and arrangement_rhythm.xml"
    echo "   - Import metadata from song.xml"
    echo "   - Build and save as White_Flame_Babymetal.psarc"
    echo ""
    
    # Create a placeholder file to indicate manual build is needed
    echo "MANUAL BUILD REQUIRED - See README_packaging.md" > "$output_path.txt"
    
    exit 1
fi

# Verify output file was created
if [ -f "$output_path" ]; then
    file_size=$(stat -f%z "$output_path" 2>/dev/null || stat -c%s "$output_path" 2>/dev/null)
    file_size_mb=$(echo "scale=2; $file_size / 1048576" | bc)
    
    echo ""
    echo -e "${GREEN}========================================"
    echo -e "SUCCESS! PSARC package built successfully"
    echo -e "========================================${NC}"
    echo ""
    echo -e "${CYAN}Output file: $output_path${NC}"
    echo -e "${CYAN}File size: ${file_size_mb} MB${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "${GRAY}  1. Copy the .psarc file to your Rocksmith 2014 DLC folder${NC}"
    echo -e "${GRAY}  2. Launch Rocksmith 2014${NC}"
    echo -e "${GRAY}  3. Look for 'White Flame' by Babymetal in your song list${NC}"
    echo ""
    
    exit 0
else
    echo ""
    echo -e "${YELLOW}WARNING: Output file was not created at expected location${NC}"
    echo -e "${GRAY}Expected: $output_path${NC}"
    echo ""
    echo -e "${YELLOW}This may indicate that the CLI parameters need adjustment.${NC}"
    echo -e "${YELLOW}Please refer to README_packaging.md for manual build instructions.${NC}"
    echo ""
    
    exit 1
fi
