#!/usr/bin/env node
/**
 * build-android.cjs - Build Flutter Android app for local testing
 * Cross-platform compatible version.
 * 
 * Usage:
 *   node scripts/build-android.cjs              # Build debug APK
 *   node scripts/build-android.cjs --release    # Build release APK
 *   node scripts/build-android.cjs --bundle     # Build release bundle (AAB)
 *   node scripts/build-android.cjs --clean      # Clean build
 *   node scripts/build-android.cjs --help       # Show help
 */

const { execSync, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

// Configuration
const MOBILE_DIR = path.join(__dirname, '..', 'apps', 'mobile');
const ANDROID_DIR = path.join(MOBILE_DIR, 'android');
const BUILD_OUTPUT_DIR = path.join(MOBILE_DIR, 'build', 'app', 'outputs', 'flutter-apk');
const BUILD_OUTPUT_BUNDLE_DIR = path.join(MOBILE_DIR, 'build', 'app', 'outputs', 'bundle');

// Parse arguments
const args = process.argv.slice(2);
const SHOW_HELP = args.includes('--help') || args.includes('-h');
const BUILD_RELEASE = args.includes('--release');
const BUILD_BUNDLE = args.includes('--bundle');
const CLEAN_BUILD = args.includes('--clean');

if (SHOW_HELP) {
  console.log(`
Flutter Android Build Script
============================

Usage: node ${path.basename(process.argv[1])} [OPTIONS]

Options:
  --release    Build release APK (signed if keystore configured)
  --bundle     Build release bundle (AAB) for Google Play
  --clean      Perform clean build
  --help, -h   Show this help

Examples:
  node ${path.basename(process.argv[1])}                    # Build debug APK
  node ${path.basename(process.argv[1])} --release          # Build release APK
  node ${path.basename(process.argv[1])} --bundle           # Build AAB
  node ${path.basename(process.argv[1])} --clean --release  # Clean release build

Output:
  Debug APK:     apps/mobile/build/app/outputs/flutter-apk/app-debug.apk
  Release APK:   apps/mobile/build/app/outputs/flutter-apk/app-release.apk
  Release AAB:   apps/mobile/build/app/outputs/bundle/release/app-release.aab
`);
  process.exit(0);
}

// Helper functions
function log(message) {
  console.log(message);
}

function error(message) {
  console.error(`ERROR: ${message}`);
}

function runCommand(command, cwd = null) {
  try {
    const options = {
      cwd: cwd || MOBILE_DIR,
      stdio: 'inherit',
      shell: true
    };
    execSync(command, options);
    return true;
  } catch (err) {
    error(`Command failed: ${command}`);
    return false;
  }
}

function fileExists(filePath) {
  return fs.existsSync(filePath);
}

function getOutputFileName() {
  if (BUILD_BUNDLE) {
    return 'app-release.aab';
  }
  return BUILD_RELEASE ? 'app-release.apk' : 'app-debug.apk';
}

function getOutputDir() {
  if (BUILD_BUNDLE) {
    return BUILD_OUTPUT_BUNDLE_DIR;
  }
  return BUILD_OUTPUT_DIR;
}

async function main() {
  log('=== Flutter Android Build ===');
  log(`Platform: ${os.platform()} ${os.arch()}`);
  log(`Build type: ${BUILD_BUNDLE ? 'Bundle (AAB)' : 'APK'} ${BUILD_RELEASE ? '(Release)' : '(Debug)'}`);
  log('');
  
  // Check if Flutter is installed
  log('==> Checking Flutter installation...');
  try {
    const flutterVersion = execSync('flutter --version', { encoding: 'utf8', cwd: MOBILE_DIR });
    log(flutterVersion.split('\n')[0]);
  } catch (err) {
    error('Flutter not found. Please install Flutter first.');
    process.exit(1);
  }
  
  // Check if Android SDK is available
  log('==> Checking Android SDK...');
  try {
    if (os.platform() === 'win32') {
      execSync('where adb', { stdio: 'ignore' });
    } else {
      execSync('command -v adb', { stdio: 'ignore' });
    }
    log('Android SDK: OK');
  } catch (err) {
    log('Warning: Android SDK not found in PATH. Build may fail.');
  }
  
  // Clean if requested
  if (CLEAN_BUILD) {
    log('');
    log('==> Performing clean build...');
    if (!runCommand('flutter clean', MOBILE_DIR)) {
      process.exit(1);
    }
    
    log('');
    log('==> Getting dependencies...');
    if (!runCommand('flutter pub get', MOBILE_DIR)) {
      process.exit(1);
    }
  }
  
  // Build command
  let buildCommand;
  if (BUILD_BUNDLE) {
    buildCommand = `flutter build appbundle ${BUILD_RELEASE ? '--release' : ''}`;
  } else {
    buildCommand = `flutter build apk ${BUILD_RELEASE ? '--release' : ''}`;
  }
  
  log('');
  log('==> Building...');
  log(`Command: ${buildCommand}`);
  
  if (!runCommand(buildCommand, MOBILE_DIR)) {
    log('');
    error('Build failed!');
    process.exit(1);
  }
  
  // Check output
  log('');
  log('==> Build completed!');
  
  const outputDir = getOutputDir();
  const outputFile = getOutputFileName();
  const outputPath = path.join(outputDir, outputFile);
  
  if (fileExists(outputPath)) {
    const stats = fs.statSync(outputPath);
    const fileSizeMB = (stats.size / (1024 * 1024)).toFixed(2);
    
    log('');
    log('✅ Build successful!');
    log('');
    log('Output file: %s', outputPath);
    log('File size: %s MB', fileSizeMB);
    log('');
    
    // Show installation instructions for debug builds
    if (!BUILD_RELEASE && !BUILD_BUNDLE) {
      log('To install on connected device:');
      log('  adb install "%s"', outputPath);
      log('');
      
      // Try to detect connected devices
      try {
        const devices = execSync('adb devices', { encoding: 'utf8' });
        const deviceLines = devices.split('\n').slice(1).filter(line => line.trim() && !line.includes('List'));
        if (deviceLines.length > 0) {
          log('Connected devices:');
          deviceLines.forEach(line => {
            const [deviceId, status] = line.split(/\s+/);
            if (status === 'device') {
              log('  - %s (%s)', deviceId, status);
            }
          });
          log('');
          log('Hint: Install directly with: adb install "%s"', outputPath);
        } else {
          log('No Android devices detected. Connect a device and enable USB debugging.');
        }
      } catch (err) {
        log('Note: ADB not available. Install manually using Android Studio or device file manager.');
      }
    }
    
    // Show signing info for release builds
    if (BUILD_RELEASE || BUILD_BUNDLE) {
      const keystoreFile = path.join(ANDROID_DIR, 'keystore.properties');
      if (fileExists(keystoreFile)) {
        log('ℹ️  App signed with configured keystore');
      } else {
        log('⚠️  No keystore configured. App signed with debug key.');
        log('   For production releases, configure keystore.properties first.');
      }
      log('');
      
      if (BUILD_BUNDLE) {
        log('Next steps for Google Play deployment:');
        log('  1. Upload %s to Google Play Console', outputFile);
        log('  2. Create new release in Production/Staging track');
        log('  3. Review and publish');
      } else {
        log('Next steps:');
        log('  - Distribute APK to testers');
        log('  - Or upload to internal testing track on Google Play');
      }
    }
  } else {
    error('Build output not found!');
    log('Expected output: %s', outputPath);
    process.exit(1);
  }
}

main().catch(err => {
  error(err.message);
  process.exit(1);
});
