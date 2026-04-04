#!/usr/bin/env node

/**
 * Cross-platform dev script that unsets CLAUDECODE env var before starting the bridge server.
 * This replaces the Unix-specific `env -u CLAUDECODE` command.
 */

// Delete CLAUDECODE from environment if it exists
if (process.env.CLAUDECODE) {
  delete process.env.CLAUDECODE;
  console.log('[dev] CLAUDECODE environment variable removed');
}

// Import and run the main server
import { setupProxy } from './proxy.js';
import { startServer } from './index.js';

setupProxy();
startServer().catch((err) => {
  console.error('[bridge] Failed to start:', err);
  process.exit(1);
});
