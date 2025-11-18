# Build PSARC Instructions and Troubleshooting

This document provides guidance on using the GitHub Actions workflow and troubleshooting common issues.

## GitHub Actions Workflow

The `build_psarc.yml` workflow automates the CDLC build process.

### Workflow Triggers

The workflow runs automatically on:
- **Push to `build/psarc` branch**: Any commit to this branch triggers a build
- **Manual dispatch**: You can manually trigger the workflow from the Actions tab

### Manual Trigger Steps

1. Navigate to your repository on GitHub
2. Click the **Actions** tab
3. Select **Build PSARC** from the workflows list
4. Click the **Run workflow** dropdown button
5. Ensure `build/psarc` branch is selected
6. Click **Run workflow**

### Workflow Jobs

The workflow runs two parallel jobs:

#### 1. Build on Windows (`build-windows`)
- Runs on: `windows-latest`
- Steps:
  1. Checkout repository
  2. Verify required files exist
  3. Setup .NET SDK
  4. Run PowerShell build script (`build_psarc.ps1`)
  5. Upload artifacts
  6. Create/update draft release

#### 2. Build on Linux (`build-linux`)
- Runs on: `ubuntu-latest`
- Steps:
  1. Checkout repository
  2. Verify required files exist
  3. Install Mono runtime
  4. Setup .NET SDK
  5. Run Bash build script (`build_psarc.sh`)
  6. Upload artifacts

### Workflow Outputs

#### Artifacts
Build artifacts are uploaded and available for 30 days:
- `psarc-build-windows`: Output from Windows build
- `psarc-build-linux`: Output from Linux build

To download artifacts:
1. Go to the workflow run page
2. Scroll to the **Artifacts** section
3. Click on the artifact name to download

#### Release Assets
The Windows job creates/updates a draft release:
- **Tag**: `v-cdlc-auto`
- **Name**: CDLC Build (Auto)
- **Status**: Draft (not published)
- **Assets**: Build manifest and related files

To access the release:
1. Go to the **Releases** page of your repository
2. Look for the draft release `v-cdlc-auto`
3. Download the attached assets

## Troubleshooting

### Common Issues

#### 1. Missing Required Files

**Error**: "Required file missing: [filename]"

**Solution**:
- Ensure all required files are committed to the `build/psarc` branch:
  - `White_Flame.wav`
  - `song.xml`
  - `arrangement_lead.xml`
  - `arrangement_rhythm.xml`
- Check file paths are at repository root
- Verify files are not in `.gitignore`

#### 2. Build Script Execution Failed

**Error**: Script exits with non-zero code

**Windows**:
```powershell
# Check PowerShell version (should be 7+)
$PSVersionTable.PSVersion

# Run script with verbose output
./build_psarc.ps1 -OutputDir ./output -Verbose
```

**Linux**:
```bash
# Ensure script is executable
chmod +x build_psarc.sh

# Run with debug output
bash -x ./build_psarc.sh ./output
```

#### 3. Workflow Permissions Error

**Error**: "Resource not accessible by integration" or permission denied

**Solution**:
- Ensure repository settings allow GitHub Actions to create releases
- Go to: Settings → Actions → General → Workflow permissions
- Select: "Read and write permissions"
- Check: "Allow GitHub Actions to create and approve pull requests"

#### 4. .NET or Mono Installation Failed

**Error**: Setup step fails

**Solution**:
- Check GitHub Actions status page for runner issues
- Verify the workflow uses correct setup action versions:
  - `actions/setup-dotnet@v4`
- For local builds, manually install:
  - Windows: Download .NET SDK from microsoft.com
  - Linux: `sudo apt-get install dotnet-sdk-8.0 mono-complete`

#### 5. Artifact Upload Failed

**Error**: "Unable to upload artifact"

**Solution**:
- Check artifact size (should be reasonable)
- Verify artifact path patterns in workflow YAML
- Ensure files exist before upload step runs

### Build Script Limitations

The current build scripts are **preparatory** and create a manifest, but do **not** create a complete `.psarc` file. This is because:

1. **PSARC Creation** requires proprietary or complex tools:
   - RocksmithToolkitLib (C# library)
   - PSARC packer utilities
   
2. **Audio Conversion** requires Wwise or similar:
   - WAV → Wwise OGG format
   - Proper encoding for Rocksmith

3. **Full automation** would require:
   - Hosting RocksmithToolkitLib CLI
   - License compliance for Wwise
   - Significant additional scripting

### Recommended Workflow

For complete PSARC creation:

1. **Use GitHub Actions** to validate files and create manifest
2. **Download artifacts** from the workflow run
3. **Use RocksmithToolkit locally** to complete the packaging:
   - Install RocksmithToolkit on your machine
   - Import the validated files
   - Generate the final `.psarc`
4. **Test** the PSARC in Rocksmith 2014
5. **Manually upload** the completed `.psarc` to the draft release if desired

### Viewing Workflow Logs

To debug issues:

1. Go to the **Actions** tab
2. Click on the failed workflow run
3. Click on the job name (e.g., `build-windows`)
4. Expand the step that failed
5. Review the error messages

Common log locations:
- File verification: "Verify required files" step
- Build execution: "Run build script" step
- Release creation: "Create/Update Release" step

### Getting Help

If you encounter issues:

1. Check workflow logs for specific error messages
2. Review file paths and permissions
3. Verify repository settings for Actions
4. Consult `README_packaging.md` for local build instructions
5. Search CustomsForge forums for similar issues

### Manual Release Management

To manually manage the draft release:

```bash
# List releases
gh release list

# View specific release
gh release view v-cdlc-auto

# Upload additional asset
gh release upload v-cdlc-auto path/to/file.psarc

# Publish the draft release (when ready)
gh release edit v-cdlc-auto --draft=false

# Delete release (if needed)
gh release delete v-cdlc-auto
```

## Advanced Configuration

### Customizing the Workflow

Edit `.github/workflows/build_psarc.yml` to:

- Change release tag name (default: `v-cdlc-auto`)
- Modify artifact retention period (default: 30 days)
- Add additional build steps
- Change runner OS versions

### Customizing Build Scripts

Edit `build_psarc.ps1` or `build_psarc.sh` to:

- Add actual PSARC packing logic
- Integrate with specific tools
- Add validation steps
- Customize output paths

## Security Notes

- The workflow uses `GITHUB_TOKEN` for authentication
- Token is automatically provided by GitHub Actions
- Token has limited scope to the repository
- Does not require manual secret configuration
- Permissions defined in workflow: `contents: write`

## Performance

Typical workflow execution times:
- Windows job: 2-4 minutes
- Linux job: 2-4 minutes
- Jobs run in parallel for efficiency

Artifact upload/download times vary with size and network speed.
