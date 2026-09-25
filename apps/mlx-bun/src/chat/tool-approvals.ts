// Durable per-tool approval choices for web chat. Stored under ~/.mlx-bun
// with mode0600; absent, corrupt, or unknown-version data means ask again.

import { mkdirSync, readFileSync, writeFileSync, chmodSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

/** Honor the app home at call time so isolated callers can choose their store. */
function home(): string {
  return process.env.HOME || homedir();
}

function configPath(): string {
  return join(home(), ".mlx-bun", "tool-approvals.json");
}

export const TOOL_APPROVALS_VERSION = 1 as const;

/** On-disk shape. `allows` maps tool name -> true (present+true = always
 *  allow; absent = ask every time, the default). A plain boolean map (not a
 *  richer per-tool record) is deliberately the whole shape for v1 — nothing
 *  here needs migrating yet, but the version field exists so a future
 *  richer shape (e.g. per-tool scoping, expiry) has somewhere to land. */
export interface ToolApprovalsFileV1 {
  version: 1;
  allows: Record<string, true>;
}

/** Anything this module can load and return today. Widen this union (not
 *  ToolApprovalsFileV1) when a v2 shape ships, and teach loadToolApprovals'
 *  migration step to upgrade older files in place. */
export type ToolApprovalsFile = ToolApprovalsFileV1;

const EMPTY: ToolApprovalsFileV1 = { version: 1, allows: {} };

/**
 * Load the durable approvals file, migrating forward if needed.
 *
 * Never throws: a missing file, unreadable file, or corrupt JSON all
 * degrade to the empty default (ask every time) rather than crashing the
 * approval gate — a config-file bug must never make mutating tools MORE
 * permissive by accident, and "ask every time" is the safe failure mode.
 */
export function loadToolApprovals(): ToolApprovalsFile {
  let raw: string;
  try {
    raw = readFileSync(configPath(), "utf8");
  } catch {
    return { ...EMPTY, allows: {} };
  }
  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return { ...EMPTY, allows: {} };
  }
  return migrate(parsed);
}

/**
 * Migrate an arbitrary parsed JSON value to the current ToolApprovalsFile
 * shape. Unknown/missing `version` is treated as "pre-versioning" (there
 * isn't one yet — this IS v1 — but the shape is defensive against a
 * hand-edited or truncated file rather than assuming well-formedness).
 * Unknown future versions (a downgrade scenario) fall back to empty rather
 * than guessing at an unfamiliar shape.
 */
function migrate(parsed: unknown): ToolApprovalsFile {
  if (!parsed || typeof parsed !== "object") return { ...EMPTY, allows: {} };
  const obj = parsed as Record<string, unknown>;
  const version = obj.version;
  if (version === 1 || version === undefined) {
    const allowsRaw = obj.allows;
    const allows: Record<string, true> = {};
    if (allowsRaw && typeof allowsRaw === "object") {
      for (const [k, v] of Object.entries(allowsRaw as Record<string, unknown>)) {
        if (v === true) allows[k] = true;
      }
    }
    return { version: 1, allows };
  }
  // Unrecognized/future version: don't guess at its shape. Ask every time
  // is always the safe degradation.
  return { ...EMPTY, allows: {} };
}

function saveToolApprovals(file: ToolApprovalsFile): void {
  const dir = join(home(), ".mlx-bun");
  mkdirSync(dir, { recursive: true });
  const path = configPath();
  writeFileSync(path, JSON.stringify(file, null, 2) + "\n", { mode: 0o600 });
  chmodSync(path, 0o600); // writeFileSync's mode is masked by umask on create
}

/** Whether `toolName` is currently in the durable always-allow set. */
export function isToolAlwaysAllowed(toolName: string): boolean {
  return loadToolApprovals().allows[toolName] === true;
}

/** Persist "always allow this tool" for `toolName`. Idempotent. */
export function setToolAlwaysAllowed(toolName: string): ToolApprovalsFile {
  const file = loadToolApprovals();
  file.allows[toolName] = true;
  saveToolApprovals(file);
  return file;
}

/** Revoke a previously-granted always-allow (settings UI "forget" action). */
export function revokeToolAlwaysAllowed(toolName: string): ToolApprovalsFile {
  const file = loadToolApprovals();
  delete file.allows[toolName];
  saveToolApprovals(file);
  return file;
}

/** Full always-allow set, for a settings-panel listing. */
export function listAlwaysAllowedTools(): string[] {
  return Object.keys(loadToolApprovals().allows).sort();
}
