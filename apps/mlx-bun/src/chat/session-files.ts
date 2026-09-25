import { readFile, realpath } from "node:fs/promises";
import { homedir } from "node:os";
import { join, resolve, sep } from "node:path";

/** Shared by Pi persistence and the read-only session HTTP surface. */
export function defaultSessionDir(): string {
  return join(homedir(), ".mlx-bun", "sessions");
}

export function isUnderSessionDir(path: string, sessionDir: string): boolean {
  const root = resolve(sessionDir), candidate = resolve(path);
  return candidate === root || candidate.startsWith(root + sep);
}

export type SessionRead = { ok: true; content: string } | { ok: false; reason: "forbidden" | "not_found" };

/** Check both the submitted path and its resolved target. Configured directory
 * aliases are allowed, but neither a leaf nor parent symlink may escape it. */
export async function readSessionFile(sessionDir: string, path: string): Promise<SessionRead> {
  if (!isUnderSessionDir(path, sessionDir)) return { ok: false, reason: "forbidden" };
  try {
    const [root, target] = await Promise.all([realpath(sessionDir), realpath(path)]);
    if (!isUnderSessionDir(target, root)) return { ok: false, reason: "forbidden" };
    return { ok: true, content: await readFile(target, "utf8") };
  } catch { return { ok: false, reason: "not_found" }; }
}

/** Preserve raw JSON values and tolerate malformed or mid-append lines. */
export function sessionEntries(content: string): unknown[] {
  const entries: unknown[] = [];
  for (const line of content.split("\n")) {
    if (!line.trim()) continue;
    try { entries.push(JSON.parse(line.trim())); } catch { /* incomplete JSONL line */ }
  }
  return entries;
}
