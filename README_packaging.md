# White Flame CDLC Packaging Guide

This document provides step-by-step instructions for building a Rocksmith 2014 Remastered CDLC (.psarc) package for **Babymetal - White Flame**.

## Prerequisites

### Required Files (Already in Repository)
- `White_Flame.wav` - Audio file (8.5 MB, already present in repo)
- `song.xml` - Song metadata and arrangement references
- `arrangement_lead.xml` - Lead guitar arrangement (176 BPM, Eb standard tuning)
- `arrangement_rhythm.xml` - Rhythm guitar arrangement (176 BPM, Eb standard tuning)

### Required Tools

#### Windows
- **Rocksmith Custom Song Toolkit** (recommended)
  - Download from: https://github.com/rscustom/rocksmith-custom-song-toolkit
  - Install the GUI version or use the CLI
- **PowerShell 5.1+** (included with Windows 10/11)
- **FFmpeg** (optional, for audio conversion)
  - Download from: https://ffmpeg.org/download.html

#### Linux/macOS
- **Mono** or **.NET Core** runtime
- **FFmpeg** (for audio conversion)
  - Install: `sudo apt-get install ffmpeg` (Ubuntu/Debian)
  - Install: `brew install ffmpeg` (macOS)
- **Rocksmith Custom Song Toolkit** (requires Mono)

## Local Build Instructions

### Windows (PowerShell)

1. **Install Rocksmith Custom Song Toolkit** if not already installed
   - Download and install from the link above
   - Note the installation directory (typically `C:\Program Files (x86)\Rocksmith Custom Song Toolkit`)

2. **Clone the repository** (if you haven't already)
   ```powershell
   git clone https://github.com/VlakyGMK/Babymetal.git
   cd Babymetal
   git checkout build/psarc
   ```

3. **Run the build script**
   ```powershell
   .\build_psarc.ps1
   ```

4. **Output**
   - The built CDLC will be located at: `.\dist\White_Flame_Babymetal.psarc`
   - Copy this file to your Rocksmith 2014 DLC folder

### Linux/macOS (Bash)

1. **Install prerequisites**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install mono-complete ffmpeg
   
   # macOS
   brew install mono ffmpeg
   ```

2. **Clone the repository** (if you haven't already)
   ```bash
   git clone https://github.com/VlakyGMK/Babymetal.git
   cd Babymetal
   git checkout build/psarc
   ```

3. **Run the build script**
   ```bash
   chmod +x build_psarc.sh
   ./build_psarc.sh
   ```

4. **Output**
   - The built CDLC will be located at: `./dist/White_Flame_Babymetal.psarc`

## Audio Offset Adjustment

If you experience timing issues in-game:

1. **Using Rocksmith Toolkit GUI:**
   - Open the `.psarc` file in the toolkit
   - Adjust the offset value in the song properties
   - Typical offsets range from -50ms to +50ms
   - Re-save the package

2. **Manual adjustment:**
   - Edit `song.xml` and change the `<offset>` value
   - Rebuild the package using the build scripts

## FFmpeg Audio Conversion

The audio file `White_Flame.wav` should be in the correct format for Rocksmith:
- Format: 16-bit PCM WAV
- Sample Rate: 48000 Hz
- Channels: Stereo

If you need to convert the audio:

```bash
ffmpeg -i White_Flame.wav -ar 48000 -ac 2 -sample_fmt s16 White_Flame_converted.wav
```

Then replace the original WAV file and rebuild.

## GitHub Actions Workflow

### Manual Trigger via GitHub UI

1. Navigate to the repository on GitHub: https://github.com/VlakyGMK/Babymetal
2. Click on **Actions** tab
3. Select **Build PSARC** workflow from the left sidebar
4. Click **Run workflow** button
5. Select branch: `build/psarc`
6. Click the green **Run workflow** button

### Automatic Trigger

The workflow automatically runs when you push commits to the `build/psarc` branch:

```bash
git add .
git commit -m "Update arrangement files"
git push origin build/psarc
```

### Workflow Artifacts

After the workflow completes:

1. **Build Artifacts:**
   - Go to the workflow run page
   - Download the artifact named `psarc-windows` or `psarc-linux`
   - Extract the `.psarc` file

2. **Release Assets:**
   - The workflow creates/updates a draft release named **"v-cdlc (auto)"**
   - Navigate to **Releases** tab
   - Find the draft release
   - Download the `.psarc` file attached to the release

## Rocksmith Toolkit CLI Usage

If you prefer using the command-line interface directly:

### Windows
```powershell
# Assuming toolkit is installed at default location
& "C:\Program Files (x86)\Rocksmith Custom Song Toolkit\RocksmithToolkitCLI.exe" `
  -i "White_Flame.wav" `
  -o "dist\White_Flame_Babymetal.psarc" `
  -l "arrangement_lead.xml" `
  -r "arrangement_rhythm.xml" `
  -m "song.xml"
```

### Linux/macOS
```bash
mono RocksmithToolkitCLI.exe \
  -i "White_Flame.wav" \
  -o "dist/White_Flame_Babymetal.psarc" \
  -l "arrangement_lead.xml" \
  -r "arrangement_rhythm.xml" \
  -m "song.xml"
```

## Troubleshooting

### Build Script Fails

**Error: "Rocksmith Toolkit not found"**
- Ensure Rocksmith Custom Song Toolkit is installed
- Update the toolkit path in the build script if it's in a non-standard location

**Error: "White_Flame.wav not found"**
- Ensure you're in the correct directory
- Verify the WAV file exists: `ls White_Flame.wav` (Linux/macOS) or `dir White_Flame.wav` (Windows)

**Error: "Missing arrangement files"**
- Ensure all XML files are present:
  - `song.xml`
  - `arrangement_lead.xml`
  - `arrangement_rhythm.xml`

### In-Game Issues

**Song doesn't appear in Rocksmith:**
- Ensure the `.psarc` file is in the correct DLC folder:
  - Windows: `Steam\steamapps\common\Rocksmith2014\dlc`
  - macOS: `~/Library/Application Support/Steam/steamapps/common/Rocksmith2014/dlc`
- Restart Rocksmith after adding the file

**Timing is off:**
- Adjust the offset value (see "Audio Offset Adjustment" section above)
- Typical adjustments: ±50ms

**Notes don't match the audio:**
- Verify you're using the correct tuning: Eb standard (half-step down)
- Check that you've selected the correct arrangement (Lead vs. Rhythm)

## Additional Resources

- **Rocksmith Custom Song Toolkit**: https://github.com/rscustom/rocksmith-custom-song-toolkit
- **CustomsForge**: https://customsforge.com/ (community forum and tutorials)
- **CDLC Creation Guide**: https://customsforge.com/topic/52-how-to-create-cdlc-custom-dlc/

## Notes

- The arrangements were transcribed from tab images for "Babymetal - White Flame"
- Tempo: 176 BPM
- Tuning: Eb standard (half-step down on all strings)
- Album: The Other One (2023)
- The Lead arrangement includes solo sections
- The Rhythm arrangement focuses on chord progressions and power chords

For questions or issues, please refer to `build_psarc_instructions.md` or open an issue in the repository.
