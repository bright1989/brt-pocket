#!/usr/bin/env node
/**
 * dev-restart.cjs - Restart Bridge Server + Flutter app for development
 * Cross-platform compatible version.
 */

const { spawn, execSync } = require('child_process');
const path = require('path');
const os = require('os');

const ROOT_DIR = path.join(__dirname, '..');
const BRIDGE_PORT = process.env.BRIDGE_PORT || '8765';
const DEVICE = process.argv[2] || '';
const TARGET = 'lib/main.dart';

async function run() {
  // --- Bridge Server ---
  console.log('==> Stopping Bridge Server (port %s)...', BRIDGE_PORT);
  
  try {
    let bridgePid;
    if (os.platform() === 'win32') {
      // Windows: use netstat to find process on port
      try {
        const result = execSync(`netstat -ano | findstr :${BRIDGE_PORT}`, { encoding: 'utf8' });
        const lines = result.split('\n').filter(line => line.includes('LISTENING'));
        if (lines.length > 0) {
          const parts = lines[0].trim().split(/\s+/);
          bridgePid = parts[parts.length - 1];
        }
      } catch (e) {
        // No process found
      }
    } else {
      // macOS/Linux: use lsof
      try {
        bridgePid = execSync(`lsof -ti :${BRIDGE_PORT}`, { encoding: 'utf8' }).trim();
      } catch (e) {
        // No process found
      }
    }
    
    if (bridgePid) {
      process.kill(parseInt(bridgePid), 'SIGTERM');
      await new Promise(resolve => setTimeout(resolve, 1000));
      console.log('    Killed PID %s', bridgePid);
    } else {
      console.log('    Not running');
    }
  } catch (error) {
    console.log('    Error stopping bridge:', error.message);
  }
  
  console.log('==> Starting Bridge Server...');
  
  // Start bridge server in background
  const bridgeProcess = spawn('npm', ['run', 'bridge'], {
    cwd: ROOT_DIR,
    stdio: 'inherit',
    detached: false,
    shell: true
  });
  
  // Wait for bridge to start
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  // Verify bridge is running
  try {
    if (os.platform() === 'win32') {
      execSync(`netstat -an | findstr :${BRIDGE_PORT} | findstr LISTENING`, { stdio: 'ignore' });
    } else {
      execSync(`lsof -ti :${BRIDGE_PORT}`, { stdio: 'ignore' });
    }
    console.log('    Bridge Server running on port %s', BRIDGE_PORT);
  } catch (error) {
    console.log('    ERROR: Bridge Server failed to start');
    process.exit(1);
  }
  
  // --- Flutter App ---
  console.log('==> Launching Flutter app (%s)...', TARGET);
  
  const flutterArgs = ['-t', TARGET];
  if (DEVICE) {
    flutterArgs.push('-d', DEVICE);
  }
  
  return new Promise((resolve, reject) => {
    const flutterProcess = spawn('flutter', ['run', ...flutterArgs], {
      cwd: path.join(ROOT_DIR, 'apps/mobile'),
      stdio: 'inherit',
      shell: true
    });
    
    flutterProcess.on('close', (code) => {
      // Cleanup: stop bridge when flutter exits
      console.log('==> Stopping Bridge Server...');
      try {
        bridgeProcess.kill('SIGTERM');
      } catch (e) {
        // Already stopped
      }
      resolve(code);
    });
    
    flutterProcess.on('error', (err) => {
      console.error('Flutter error:', err.message);
      reject(err);
    });
  });
}

run().catch(error => {
  console.error('Error:', error.message);
  process.exit(1);
});
