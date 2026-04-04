#!/usr/bin/env node
/**
 * setup-hooks.cjs - Install git hooks for the project.
 * Cross-platform compatible version.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

try {
  // Get repository root using git
  const repoRoot = execSync('git rev-parse --show-toplevel', { encoding: 'utf8' }).trim();
  const hooksDir = path.join(repoRoot, '.git', 'hooks');
  
  console.log('Installing git hooks...');
  
  // Ensure hooks directory exists
  if (!fs.existsSync(hooksDir)) {
    fs.mkdirSync(hooksDir, { recursive: true });
  }
  
  // pre-commit hook
  const preCommitHook = `#!/usr/bin/env bash
# Auto-installed by scripts/setup-hooks.cjs
# Runs secret detection before every commit.

REPO_ROOT="$(git rev-parse --show-toplevel)"
exec "$REPO_ROOT/scripts/check-secrets.sh"
`;
  
  const preCommitPath = path.join(hooksDir, 'pre-commit');
  fs.writeFileSync(preCommitPath, preCommitHook, { mode: 0o755 });
  
  console.log('Installed: pre-commit (secret detection)');
  console.log('Done. Hooks are active.');
  
} catch (error) {
  console.error('Error setting up git hooks:', error.message);
  console.log('Git hooks setup skipped. You can run it manually later if needed.');
  // Don't fail the install process
  process.exit(0);
}
