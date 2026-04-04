#!/usr/bin/env node
/**
 * promote.cjs - Shorebird patch promotion (staging → stable)
 * Cross-platform compatible version.
 * 
 * Usage: node promote.cjs <release-version> <patch-number>
 * Example: node promote.cjs 1.7.0+20 3
 */

const { execSync, spawn } = require('child_process');
const path = require('path');
const os = require('os');

function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.log('Usage: %s <release-version> <patch-number>', path.basename(process.argv[1]));
    console.log('Example: %s 1.7.0+20 3', path.basename(process.argv[1]));
    process.exit(1);
  }
  
  const RELEASE_VERSION = args[0];
  const PATCH_NUMBER = args[1];
  
  // Get script directory and project directory
  const SCRIPT_DIR = __dirname;
  const PROJECT_DIR = path.join(SCRIPT_DIR, '..', '..', '..', 'apps', 'mobile');
  
  console.log('=== Shorebird Promote ===');
  console.log('Release version: %s', RELEASE_VERSION);
  console.log('Patch number: %s', PATCH_NUMBER);
  console.log('Track: staging → stable');
  console.log('');
  
  try {
    // Change to project directory
    process.chdir(PROJECT_DIR);
    
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
    
    // Run shorebird patches promote command
    const result = spawn(shorebirdPath, [
      'patches', 'promote',
      '--release-version=' + RELEASE_VERSION,
      '--patch-number=' + PATCH_NUMBER
    ], {
      stdio: 'inherit',
      shell: true
    });
    
    return new Promise((resolve, reject) => {
      result.on('close', (code) => {
        console.log('');
        console.log('=== Done ===');
        console.log('Patch %s promoted to stable. All users will receive it on next app restart.', PATCH_NUMBER);
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
