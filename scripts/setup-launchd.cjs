#!/usr/bin/env node
/**
 * setup-launchd.cjs - Register Bridge Server as a launchd service (macOS only)
 * Cross-platform compatible version.
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');
const homedir = require('os').homedir();

function main() {
  // Check if running on macOS
  if (os.platform() !== 'darwin') {
    console.log('Note: launchd is only available on macOS.');
    console.log('This script does nothing on %s.', os.platform());
    console.log('You can run the bridge server directly with: npm run bridge');
    return;
  }
  
  const ROOT_DIR = path.join(__dirname, '..');
  const PLIST_LABEL = 'com.ccpocket.bridge';
  const PLIST_PATH = path.join(homedir, 'Library', 'LaunchAgents', `${PLIST_LABEL}.plist`);
  
  // Defaults
  let PORT = process.env.BRIDGE_PORT || '8765';
  let HOST = process.env.BRIDGE_HOST || '0.0.0.0';
  let API_KEY = process.env.BRIDGE_API_KEY || '';
  let NO_START = false;
  let UNINSTALL = false;
  
  // Parse CLI args
  const args = process.argv.slice(2);
  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--port':
        PORT = args[++i];
        break;
      case '--host':
        HOST = args[++i];
        break;
      case '--api-key':
        API_KEY = args[++i];
        break;
      case '--no-start':
        NO_START = true;
        break;
      case '--uninstall':
        UNINSTALL = true;
        break;
      case '-h':
      case '--help':
        console.log(`Usage: ${path.basename(process.argv[1])} [OPTIONS]

Register Bridge Server as a macOS launchd service.

Options:
  --port <port>       Bridge port (default: 8765)
  --host <host>       Bind address (default: 0.0.0.0)
  --api-key <key>     API key for authentication
  --no-start          Register only, don't start immediately
  --uninstall         Remove the launchd service
  -h, --help          Show this help`);
        return;
    }
  }
  
  try {
    // --- Uninstall ---
    if (UNINSTALL) {
      console.log('==> Uninstalling Bridge Server service...');
      try {
        execSync(`launchctl stop ${PLIST_LABEL}`, { stdio: 'ignore' });
        execSync(`launchctl unload ${PLIST_PATH}`, { stdio: 'ignore' });
      } catch (e) {
        // Ignore errors
      }
      fs.unlinkSync(PLIST_PATH);
      console.log('    Service removed.');
      return;
    }
    
    // --- Verify node is available ---
    try {
      execSync('command -v node', { stdio: 'ignore' });
    } catch (e) {
      console.error('ERROR: node not found in PATH. Install Node.js first.');
      process.exit(1);
    }
    console.log('==> Node.js: %s', execSync('command -v node', { encoding: 'utf8' }).trim());
    
    // --- Build if needed ---
    const distDir = path.join(ROOT_DIR, 'packages/bridge', 'dist');
    if (!fs.existsSync(distDir)) {
      console.log('==> Building Bridge Server...');
      execSync('npm run bridge:build', { cwd: ROOT_DIR, stdio: 'inherit' });
    }
    
    const ENTRY_POINT = path.join(ROOT_DIR, 'packages/bridge/dist/index.js');
    
    // --- Create LaunchAgents directory ---
    const launchAgentsDir = path.join(homedir, 'Library', 'LaunchAgents');
    if (!fs.existsSync(launchAgentsDir)) {
      fs.mkdirSync(launchAgentsDir, { recursive: true });
    }
    
    // --- Build environment block ---
    let envBlock = `        <key>BRIDGE_PORT</key>
        <string>${PORT}</string>
        <key>BRIDGE_HOST</key>
        <string>${HOST}</string>`;
    
    if (API_KEY) {
      envBlock += `\n        <key>BRIDGE_API_KEY</key>
        <string>${API_KEY}</string>`;
    }
    
    // --- Generate plist ---
    console.log('==> Writing %s', PLIST_PATH);
    const plistContent = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_LABEL}</string>

    <!--
        Launch via login+interactive shell to inherit the user's full
        environment (mise, nvm, pyenv, Homebrew, etc.) — same as Terminal.app.
        exec replaces the zsh process with node, so the process tree
        becomes: launchd → node (no leftover zsh).
    -->
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>-li</string>
        <string>-c</string>
        <string>exec node ${ENTRY_POINT}</string>
    </array>

    <key>WorkingDirectory</key>
    <string>${ROOT_DIR}</string>

    <key>EnvironmentVariables</key>
    <dict>
${envBlock}
    </dict>

    <key>RunAtLoad</key>
    <false/>

    <key>KeepAlive</key>
    <false/>

    <key>StandardOutPath</key>
    <string>/tmp/ccpocket-bridge.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/ccpocket-bridge.err</string>
</dict>
</plist>`;
    
    fs.writeFileSync(PLIST_PATH, plistContent);
    
    // --- Register with launchctl ---
    console.log('==> Registering service...');
    try {
      execSync(`launchctl unload ${PLIST_PATH}`, { stdio: 'ignore' });
    } catch (e) {
      // Ignore errors
    }
    execSync(`launchctl load ${PLIST_PATH}`, { stdio: 'inherit' });
    
    // --- Start ---
    if (!NO_START) {
      const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
      sleep(1000).then(() => {
        try {
          execSync(`launchctl start ${PLIST_LABEL}`, { stdio: 'ignore' });
        } catch (e) {
          // Ignore errors
        }
        console.log('==> Bridge Server started on port %s', PORT);
        console.log('    Done.');
      });
    } else {
      console.log('==> Service registered (not started). Run: launchctl start %s', PLIST_LABEL);
      console.log('    Done.');
    }
    
  } catch (error) {
    console.error('Error setting up launchd:', error.message);
    process.exit(1);
  }
}

main();
