# PSARC Packaging Instructions for White Flame CDLC

This document explains how to build a Rocksmith 2014 Remastered Custom DLC (CDLC) `.psarc` file for "Babymetal - White Flame".

## Overview

The repository contains:
- `White_Flame.wav` - Audio file (already in repository)
- `song.xml` - Song metadata
- `arrangement_lead.xml` - Lead guitar arrangement (Eb tuning, 176 BPM)
- `arrangement_rhythm.xml` - Rhythm guitar arrangement (Eb tuning, 176 BPM)
- Build scripts for automated packaging

## Automated Build (GitHub Actions)

The easiest way to build the PSARC is using the GitHub Actions workflow:

### Triggering the Workflow Manually

1. Go to your repository on GitHub
2. Click on the **Actions** tab
3. Select **Build PSARC** workflow from the left sidebar
4. Click **Run workflow** button
5. Select the `build/psarc` branch
6. Click the green **Run workflow** button

The workflow will:
- Verify all required files exist
- Run the build script on both Windows and Linux runners
- Upload build artifacts
- Create/update a draft release with the build outputs

### Workflow Outputs

- **Artifacts**: Build manifests and XML files are uploaded as artifacts
- **Release**: A draft release named `v-cdlc-auto` is created/updated with the build outputs

## Local Build Instructions

To build the PSARC locally, you'll need proper Rocksmith modding tools. The scripts in this repository provide a foundation, but complete PSARC creation requires additional tools.

### Prerequisites

1. **RocksmithToolkitLib** (Recommended)
   - Download from: https://github.com/rscustom/rocksmith-custom-song-toolkit
   - Or use the RocksmithToolkit GUI application

2. **Audio Conversion Tools**
   - Wwise (for converting WAV to Wwise OGG/WEM format)
   - Or ffmpeg (for basic audio conversion)

3. **PSARC Packer**
   - Included in RocksmithToolkit
   - Or standalone PSARC tools

### Windows Build Steps

1. **Open PowerShell** in the repository directory

2. **Run the build script**:
   ```powershell
   .\build_psarc.ps1 -OutputDir .\output
   ```

3. **Complete the packaging** (requires RocksmithToolkit):
   - Open RocksmithToolkit
   - Create a new CDLC project
   - Import the audio file: `White_Flame.wav`
   - Import the arrangement XMLs: `arrangement_lead.xml` and `arrangement_rhythm.xml`
   - Import song metadata: `song.xml`
   - Set the following properties:
     - Artist: Babymetal
     - Title: White Flame
     - Album: The Other One (2023)
     - Tuning: Eb Standard (half-step down)
     - Tempo: 176 BPM
   - Generate the PSARC file

### Linux/Mac Build Steps

1. **Make the script executable**:
   ```bash
   chmod +x build_psarc.sh
   ```

2. **Run the build script**:
   ```bash
   ./build_psarc.sh ./output
   ```

3. **Complete the packaging**:
   - Install Mono: `sudo apt-get install mono-complete`
   - Use RocksmithToolkit with Mono, or
   - Use alternative tools like pyrocksmith (Python-based)

### Using RocksmithToolkit GUI (Easiest Method)

1. Download and install RocksmithToolkit from the official source
2. Launch the application
3. Click "Create New Song"
4. Fill in the song details:
   - Artist: **Babymetal**
   - Title: **White Flame**
   - Album: **The Other One**
   - Year: **2023**
5. Import audio: Select `White_Flame.wav`
6. Import arrangements: Add `arrangement_lead.xml` and `arrangement_rhythm.xml`
7. Verify tuning is set to **Eb Standard** (all strings -1 semitone)
8. Set tempo to **176 BPM**
9. Click "Generate PSARC"
10. Output will be `White_Flame_Babymetal.psarc`

## Adjusting Audio Offset

If the audio is not synced properly in-game:

1. Open RocksmithToolkit
2. Load the PSARC or project
3. Adjust the **Offset** value in `song.xml`:
   - Positive values delay the audio
   - Negative values advance the audio
   - Typical range: -50ms to +50ms
   - Start with ±10ms increments
4. Rebuild the PSARC
5. Test in-game and iterate

Common offset adjustments:
- **Audio too early**: Increase offset (e.g., `0.0` → `0.020` for +20ms)
- **Audio too late**: Decrease offset (e.g., `0.0` → `-0.020` for -20ms)

## Troubleshooting

### Missing Dependencies

If the build script reports missing tools:
- **Windows**: Install .NET SDK and PowerShell 7+
- **Linux**: Install mono-complete and dotnet SDK
- **All platforms**: Install ffmpeg for audio processing

### Build Failures

1. Verify all required files exist:
   ```
   White_Flame.wav
   song.xml
   arrangement_lead.xml
   arrangement_rhythm.xml
   ```

2. Check file permissions (Linux/Mac):
   ```bash
   chmod +x build_psarc.sh
   ```

3. Ensure audio file is valid WAV format:
   ```bash
   ffmpeg -i White_Flame.wav
   ```

### PSARC Validation

To verify the PSARC file:
1. Try loading it in Rocksmith 2014
2. Check the file size (should be several MB)
3. Use RocksmithToolkit to inspect the contents

## Additional Resources

- **RocksmithToolkit**: https://github.com/rscustom/rocksmith-custom-song-toolkit
- **CustomsForge**: https://customsforge.com/ (Community and tutorials)
- **CDLC Creator's Guide**: Search for tutorials on CustomsForge forums

## Notes

- The `.psarc` file is **not** committed to the repository to save space
- The GitHub Actions workflow creates build artifacts and draft releases
- Always test the PSARC in Rocksmith before distributing
- Respect copyright laws when sharing CDLC files
