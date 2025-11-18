# Build PSARC Instructions and Troubleshooting

This document provides additional notes about GitHub Actions workflow outputs and troubleshooting for the Babymetal - White Flame CDLC build process.

## GitHub Actions Workflow Outputs

The `.github/workflows/build_psarc.yml` workflow produces the following outputs:

### 1. Build Artifacts

After each workflow run, artifacts are uploaded and can be downloaded:

- **Artifact Name:** `psarc-windows` (from Windows runner) or `psarc-linux` (from Linux runner)
- **Location:** Navigate to Actions → Select workflow run → Scroll to "Artifacts" section
- **Contents:** `White_Flame_Babymetal.psarc` (or build logs if build failed)

**To Download:**
1. Go to the repository: https://github.com/VlakyGMK/Babymetal
2. Click **Actions** tab
3. Select the workflow run you want
4. Scroll to the **Artifacts** section at the bottom
5. Click on the artifact name to download (ZIP file)
6. Extract the ZIP to get the `.psarc` file

### 2. Draft Release

The workflow creates or updates a draft release:

- **Release Name:** `v-cdlc (auto)`
- **Tag:** `v-cdlc-latest` (auto-created)
- **Status:** Draft (not published)
- **Assets:** `White_Flame_Babymetal.psarc` attached

**To Access:**
1. Go to the repository: https://github.com/VlakyGMK/Babymetal
2. Click **Releases** (on right sidebar or in Code tab)
3. Look for the draft release named **"v-cdlc (auto)"**
4. Download the `.psarc` file from the assets section

**To Publish:**
- Edit the draft release
- Add release notes if desired
- Click **Publish release** to make it public

## Workflow Triggers

The workflow runs in the following scenarios:

1. **Manual Trigger:**
   - Go to Actions → Build PSARC → Run workflow
   - Select branch: `build/psarc`
   - Click "Run workflow"

2. **Automatic Trigger:**
   - Push commits to the `build/psarc` branch
   - The workflow runs automatically

3. **What Triggers a Build:**
   - Changes to XML files
   - Changes to build scripts
   - Changes to workflow configuration
   - Manual workflow dispatch

## Troubleshooting

### Workflow Fails on Windows Runner

**Symptom:** Windows job fails with "Rocksmith Toolkit not found"

**Solution:**
- The Windows runner may not have Rocksmith Toolkit pre-installed
- The workflow will fail and upload error logs as an artifact
- This is expected behavior - the scripts are designed to fail gracefully
- Manual build is required (see README_packaging.md)

**Alternative:**
- Modify the workflow to download and install Rocksmith Toolkit
- Or use a self-hosted runner with the toolkit pre-installed

### Workflow Fails on Linux Runner

**Symptom:** Linux job fails with "mono not found" or similar

**Solution:**
- The workflow installs mono as part of the setup steps
- If installation fails, check the workflow logs
- The build may require additional dependencies

**Common Issues:**
- Package repositories may be unavailable
- Network timeout during package installation
- Incompatible mono version

### Output File Not Created

**Symptom:** Workflow completes but no `.psarc` file in artifacts

**Possible Causes:**
1. Build script failed but didn't exit with error code
2. Toolkit CLI parameters are incorrect
3. Input files (WAV, XML) have errors

**Debugging Steps:**
1. Check workflow logs for error messages
2. Download the artifact (even if build "failed") - it may contain logs
3. Run the build script locally to reproduce the issue
4. Validate XML files for syntax errors

### Invalid PSARC File

**Symptom:** `.psarc` file is created but doesn't work in Rocksmith

**Possible Causes:**
1. Audio file format is incorrect
2. XML files contain errors
3. Arrangement data is incomplete or malformed

**Solutions:**
1. Validate audio file:
   ```bash
   ffmpeg -i White_Flame.wav -ar 48000 -ac 2 -sample_fmt s16 White_Flame_validated.wav
   ```

2. Validate XML files:
   - Check for well-formed XML syntax
   - Ensure all required elements are present
   - Verify timing values are correct (176 BPM)

3. Test with Rocksmith Toolkit GUI:
   - Open the `.psarc` in the toolkit
   - Check for validation errors
   - Re-export if needed

### Artifact Upload Fails

**Symptom:** Workflow completes but artifact upload fails

**Possible Causes:**
- Artifact file is too large (>2GB limit)
- Network issues during upload
- Insufficient permissions

**Solutions:**
- Check artifact size
- Re-run the workflow
- Check repository settings for Actions permissions

### Release Asset Upload Fails

**Symptom:** Build succeeds but release asset is not attached

**Possible Causes:**
- GitHub API rate limits
- Permissions issues
- Release already exists with conflicting tag

**Solutions:**
- Check workflow logs for specific error
- Manually upload asset to release
- Delete and recreate the draft release

## Manual Verification Steps

After the workflow completes:

1. **Download the Artifact:**
   - Verify file size (should be 8-12 MB typically)
   - Verify file extension is `.psarc`

2. **Test Locally:**
   - Copy to Rocksmith DLC folder
   - Launch Rocksmith 2014
   - Look for "White Flame" in song list
   - Test both Lead and Rhythm arrangements

3. **Verify Metadata:**
   - Artist: Babymetal
   - Album: The Other One
   - Year: 2023
   - Tuning: Eb standard (half-step down)

## Advanced Troubleshooting

### Enable Debug Logging

To get more detailed logs from the workflow:

1. Go to repository Settings
2. Navigate to Secrets and variables → Actions
3. Add repository variable: `ACTIONS_STEP_DEBUG` = `true`
4. Re-run the workflow

### Local Workflow Testing

To test the workflow locally using `act`:

```bash
# Install act: https://github.com/nektos/act
# Run the workflow locally
act workflow_dispatch -j build-windows
act workflow_dispatch -j build-linux
```

### Validate XML Schema

Use an XML validator to check the arrangement files:

```bash
xmllint --noout song.xml
xmllint --noout arrangement_lead.xml
xmllint --noout arrangement_rhythm.xml
```

### Check Audio File

Verify the WAV file is in correct format:

```bash
ffprobe White_Flame.wav

# Should show:
# - Format: PCM
# - Sample Rate: 48000 Hz
# - Channels: 2 (stereo)
# - Bit Depth: 16-bit
```

## Common Error Messages

### "White_Flame.wav not found"
- Ensure WAV file is committed to repository
- Check file name spelling (case-sensitive)
- Verify file is in repository root

### "arrangement_*.xml not found"
- Verify XML files are committed
- Check branch is correct (`build/psarc`)
- Ensure files are in repository root

### "Rocksmith Toolkit not found"
- Expected on GitHub Actions runners
- Manual build required
- Or set up self-hosted runner

### "mono: command not found"
- Workflow setup step may have failed
- Check if mono installation step completed
- May need to update workflow dependencies

## Getting Help

If you encounter issues not covered here:

1. Check the workflow logs in detail
2. Review `README_packaging.md` for build instructions
3. Test the build scripts locally
4. Open an issue in the repository with:
   - Workflow run URL
   - Error messages from logs
   - Steps to reproduce

## Notes

- The workflow is designed to fail gracefully if required tools are unavailable
- Manual build is always an option (see README_packaging.md)
- The draft release allows you to review before publishing
- Artifacts expire after 90 days (GitHub default)

For more information about GitHub Actions workflows:
- https://docs.github.com/en/actions
