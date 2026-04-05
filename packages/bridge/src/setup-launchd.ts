import { execSync } from "node:child_process";
import { existsSync, mkdirSync, writeFileSync, unlinkSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const PLIST_LABEL = "com.ccpocket.bridge";

function getPlistPath(): string {
  const dir = join(homedir(), "Library", "LaunchAgents");
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
  return join(dir, `${PLIST_LABEL}.plist`);
}

export function uninstallLaunchd(): void {
  const plistPath = getPlistPath();
  console.log("==> Uninstalling Bridge Server service...");

  try { execSync(`launchctl stop "${PLIST_LABEL}"`, { stdio: "ignore" }); } catch { /* ok */ }
  try { execSync(`launchctl unload "${plistPath}"`, { stdio: "ignore" }); } catch { /* ok */ }

  if (existsSync(plistPath)) {
    unlinkSync(plistPath);
  }
  console.log("    Service removed.");
}

interface SetupOptions {
  port?: string;
  host?: string;
  apiKey?: string;
  publicWsUrl?: string;
}

export function setupLaunchd(opts: SetupOptions): void {
  const port = opts.port ?? process.env.BRIDGE_PORT ?? "8765";
  const host = opts.host ?? process.env.BRIDGE_HOST ?? "0.0.0.0";
  const apiKey = opts.apiKey ?? process.env.BRIDGE_API_KEY ?? "";
  const publicWsUrl =
    opts.publicWsUrl ?? process.env.BRIDGE_PUBLIC_WS_URL ?? "";
  const plistPath = getPlistPath();

  // Resolve the project root (packages/bridge/) from this file's location
  const __filename = fileURLToPath(import.meta.url);
  const projectRoot = resolve(__filename, "../..");
  const nodePath = execSync("which node", { encoding: "utf-8" }).trim();
  const cliPath = join(projectRoot, "dist", "cli.js");

  if (!existsSync(cliPath)) {
    console.error(`ERROR: Built file not found: ${cliPath}`);
    console.error("    Run 'npm run build' first.");
    process.exit(1);
  }

  console.log(`==> node: ${nodePath}`);
  console.log(`==> cli:   ${cliPath}`);

  // Build environment variables block
  let envBlock = `        <key>BRIDGE_PORT</key>
        <string>${port}</string>
        <key>BRIDGE_HOST</key>
        <string>${host}</string>`;

  if (apiKey) {
    envBlock += `
        <key>BRIDGE_API_KEY</key>
        <string>${apiKey}</string>`;
  }

  if (publicWsUrl) {
    envBlock += `
        <key>BRIDGE_PUBLIC_WS_URL</key>
        <string>${publicWsUrl}</string>`;
  }

  // Generate plist
  // Use the local dist/cli.js directly instead of npx @ccpocket/bridge@latest
  // to avoid running a stale global npm-cached version. The command runs
  // inside zsh -li so that PATH includes the node binary.
  const startCmd = `PATH="$(dirname "${nodePath}"):$PATH" exec node "${cliPath}"`;
  const plist = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_LABEL}</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>-li</string>
        <string>-c</string>
        <string>${startCmd}</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
${envBlock}
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/tmp/ccpocket-bridge.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/ccpocket-bridge.err</string>
</dict>
</plist>
`;

  console.log(`==> Writing ${plistPath}`);
  writeFileSync(plistPath, plist);

  // Register with launchctl
  console.log("==> Registering service...");
  try { execSync(`launchctl unload "${plistPath}"`, { stdio: "ignore" }); } catch { /* ok */ }
  execSync(`launchctl load "${plistPath}"`);

  // Start the service
  try {
    execSync(`launchctl start "${PLIST_LABEL}"`);
    console.log(`==> Bridge Server started on port ${port}`);
  } catch {
    console.log("==> Service registered (start may have failed — check logs at /tmp/ccpocket-bridge.log)");
  }

  console.log("    Done.");
}
