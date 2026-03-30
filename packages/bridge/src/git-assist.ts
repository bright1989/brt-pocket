import { execFileSync } from "node:child_process";
import { resolve } from "node:path";
import type { Provider } from "./parser.js";
import { getStagedDiff } from "./git-operations.js";

const COMMIT_MESSAGE_PROMPT =
  "Write a single Conventional Commits message in English for the staged changes below. Output only the commit message, with no quotes or explanation.";

export interface GitAssistOptions {
  provider: Provider;
  projectPath: string;
  model?: string;
}

export function generateCommitMessage(options: GitAssistOptions): string {
  const diff = getStagedDiff(options.projectPath).trim();
  if (!diff) {
    throw new Error("Nothing to commit: no files are staged");
  }

  const command = options.provider === "codex" ? "codex" : "claude";
  const args =
    options.provider === "codex"
      ? ["-q", ...(options.model ? ["--model", options.model] : []), COMMIT_MESSAGE_PROMPT]
      : ["-p", ...(options.model ? ["--model", options.model] : []), COMMIT_MESSAGE_PROMPT];

  const output = execFileSync(command, args, {
    cwd: resolve(options.projectPath),
    encoding: "utf-8",
    input: diff,
    maxBuffer: 1024 * 1024,
  });

  const message = output
    .split("\n")
    .map((line) => line.trim())
    .find(Boolean);
  if (!message) {
    throw new Error("Commit message generation returned empty output");
  }
  return message;
}
