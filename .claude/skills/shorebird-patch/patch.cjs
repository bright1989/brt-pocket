#!/usr/bin/env node
/**
 * patch.cjs - Shorebird patch creation (staging)
 * Cross-platform compatible version.
 * 
 * Usage: node patch.cjs <ios|android> <release-version> [extra-args...]
 * Example: node patch.cjs ios 1.7.0+20
 */

const { execSync, spawn } = require('child_process');
const path = require('path');
const os = require('os');

function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.log('Usage: %s <ios|android> <release-version> [extra-args...]', path.basename(process.argv[1]));
    console.log('Example: %s ios 1.7.0+20', path.basename(process.argv[1]));
    process.exit(1);
  }
  
  const PLATFORM = args[0];
  const RELEASE_VERSION = args[1];
  const EXTRA_ARGS = args.slice(2);
  
  // Get script directory and project directory
  const SCRIPT_DIR = __dirname;
  const PROJECT_DIR = path.join(SCRIPT_DIR, '..', '..', '..', 'apps', 'mobile');
  
  console.log('=== Shorebird Patch (%s) ===', PLATFORM);
  console.log('Release version: %s', RELEASE_VERSION);
  console.log('Track: staging');
  console.log('');
  
  try {
    // Change to project directory
    process.chdir(PROJECT_DIR);
    
    console.log('--- Creating %s patch (staging) ---', PLATFORM);
    
    // Build shorebird command
    const shorebirdArgs = ['patch', PLATFORM];
    shorebirdArgs.push('--release-version=' + RELEASE_VERSION);
    shorebirdArgs.push('--track=staging');
    shorebirdArgs.push('--allow-asset-diffs');
    shorebirdArgs.push('--allow-native-diffs');
    shorebirdArgs.push('--');
    shorebirdArgs.push('--no-tree-shake-icons');
    
    // Add any extra arguments
    shorebirdArgs.push(...EXTRA_ARGS);
    
    // Determine shorebird executable based on platform
    let shorebirdCmd = 'shorebird';
    if (os.platform() === 'win32') {
      shorebirdCmd = 'shorebird.bat';
    }
    
    // Try to find shorebird in PATH or use default location
    let shorebirdPath = shorebirdCmd;
    try {
      // Check if shorebird is in PATH
      if (os.platform() === 'win32') {
        execSync(`where ${shorebirdCmd}`, { stdio: 'ignore' });
      } else {
        execSync(`command -v ${shorebirdCmd}`, { stdio: 'ignore' });
      }
    } catch (e) {
      // Use default location
      const homeDir = os.homedir();
      shorebirdPath = path.join(homeDir, '.shorebird', 'bin', shorebirdCmd);
    }
    
    // Run shorebird patch command
    const result = spawn(shorebirdPath, shorebirdArgs, {
      stdio: 'inherit',
      shell: true
    });
    
    return new Promise((resolve, reject) => {
      result.on('close', (code) => {
        console.log('');
        console.log('=== Done ===');
        console.log('Patch published to staging.');
        console.log('');
        console.log('Next steps:');
        console.log('  1. Verify: Open debug screen → set track to \'Staging\' → restart app');
        console.log('  2. Promote: node %s/promote.cjs <release-version> <patch-number>', SCRIPT_DIR);
        resolve(code);
      });
      
      result.on('error', (err) => {
        console.error('Error running shorebird:', err.message);
        reject(err);
      });
    });
    
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main().catch(error => {
  console.error('Error:', error.message);
  process.exit(1);
});
