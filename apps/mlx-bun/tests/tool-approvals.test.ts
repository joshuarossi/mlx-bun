// Durable approval persistence uses an explicit temporary path, without
// changing the process home or reading the installed app approval store.
//
// What we assert:
//   - fresh machine -> empty set, ask every time
//   - set/list/revoke round-trip, 0600 perms
//   - a migration-shaped test: a hand-written v1 file (simulating "this is
//     what shipped before a hypothetical future version bump") loads
//     correctly and a corrupt/garbage file degrades to "ask every time"
//     rather than throwing or silently over-granting — the exact failure
//     mode risk #6 calls out (Claude-Desktop-resets-on-update) is a
//     DIFFERENT failure (losing approvals on update); this guards the
//     inverse and more dangerous one too: a config bug must never make
//     mutating tools MORE permissive.

import { afterEach, beforeEach, describe, expect, test } from "bun:test";
import { mkdtempSync, writeFileSync, statSync, readFileSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  isToolAlwaysAllowed,
  setToolAlwaysAllowed,
  revokeToolAlwaysAllowed,
  listAlwaysAllowedTools,
  loadToolApprovals,
  TOOL_APPROVALS_VERSION,
} from "../src/chat/tool-approvals";

describe("tool-approvals (isolated file)", () => {
  let tmpRoot: string;
  let approvalPath: string;

  beforeEach(() => {
    tmpRoot = mkdtempSync(join(tmpdir(), "mlx-bun-home-"));
    approvalPath = join(tmpRoot, ".mlx-bun", "tool-approvals.json");
  });
  afterEach(() => {
    rmSync(tmpRoot, { recursive: true, force: true });
  });

  test("fresh machine: nothing is always-allowed, ask every time", () => {
    expect(isToolAlwaysAllowed("bash", approvalPath)).toBe(false);
    expect(listAlwaysAllowedTools(approvalPath)).toEqual([]);
    expect(loadToolApprovals(approvalPath)).toEqual({ version: 1, allows: {} });
  });

  test("set/get round-trips and persists with 0600 perms", () => {
    setToolAlwaysAllowed("bash", approvalPath);
    expect(isToolAlwaysAllowed("bash", approvalPath)).toBe(true);
    expect(isToolAlwaysAllowed("edit", approvalPath)).toBe(false);
    expect(listAlwaysAllowedTools(approvalPath)).toEqual(["bash"]);

    const path = join(tmpRoot, ".mlx-bun", "tool-approvals.json");
    const mode = statSync(path).mode & 0o777;
    expect(mode).toBe(0o600);
    const parsed = JSON.parse(readFileSync(path, "utf8"));
    expect(parsed.version).toBe(1);
    expect(parsed.allows).toEqual({ bash: true });
  });

  test("setting is idempotent and keyed by TOOL NAME (not per-call args)", () => {
    setToolAlwaysAllowed("write", approvalPath);
    setToolAlwaysAllowed("write", approvalPath);
    expect(listAlwaysAllowedTools(approvalPath)).toEqual(["write"]);
  });

  test("multiple tools accumulate; list is sorted", () => {
    setToolAlwaysAllowed("write", approvalPath);
    setToolAlwaysAllowed("bash", approvalPath);
    setToolAlwaysAllowed("edit", approvalPath);
    expect(listAlwaysAllowedTools(approvalPath)).toEqual(["bash", "edit", "write"]);
  });

  test("revoke removes exactly the named tool and is idempotent", () => {
    setToolAlwaysAllowed("bash", approvalPath);
    setToolAlwaysAllowed("edit", approvalPath);
    revokeToolAlwaysAllowed("bash", approvalPath);
    expect(isToolAlwaysAllowed("bash", approvalPath)).toBe(false);
    expect(isToolAlwaysAllowed("edit", approvalPath)).toBe(true);
    // Revoking something not present is a no-op, not an error.
    revokeToolAlwaysAllowed("bash", approvalPath);
    expect(listAlwaysAllowedTools(approvalPath)).toEqual(["edit"]);
  });

  test("migration-shaped: a hand-written v1 file (current shape) loads exactly", () => {
    const dir = join(tmpRoot, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(
      join(dir, "tool-approvals.json"),
      JSON.stringify({ version: TOOL_APPROVALS_VERSION, allows: { bash: true, edit: true } }, null, 2) + "\n",
    );
    expect(loadToolApprovals(approvalPath)).toEqual({ version: 1, allows: { bash: true, edit: true } });
    expect(isToolAlwaysAllowed("bash", approvalPath)).toBe(true);
    expect(isToolAlwaysAllowed("edit", approvalPath)).toBe(true);
    expect(isToolAlwaysAllowed("write", approvalPath)).toBe(false);
    // And it's still writable afterward (round-trip through the real API,
    // not just readable).
    setToolAlwaysAllowed("write", approvalPath);
    expect(listAlwaysAllowedTools(approvalPath)).toEqual(["bash", "edit", "write"]);
  });

  test("a file with no version field (defensive: hand-edited/pre-versioning) still loads its allows", () => {
    const dir = join(tmpRoot, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(join(dir, "tool-approvals.json"), JSON.stringify({ allows: { bash: true } }));
    expect(loadToolApprovals(approvalPath)).toEqual({ version: 1, allows: { bash: true } });
  });

  test("an unrecognized FUTURE version degrades to ask-every-time, not a guess at its shape", () => {
    const dir = join(tmpRoot, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(join(dir, "tool-approvals.json"), JSON.stringify({ version: 99, allows: { bash: true } }));
    expect(loadToolApprovals(approvalPath)).toEqual({ version: 1, allows: {} });
    expect(isToolAlwaysAllowed("bash", approvalPath)).toBe(false);
  });

  test("corrupt JSON degrades to ask-every-time rather than throwing", () => {
    const dir = join(tmpRoot, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(join(dir, "tool-approvals.json"), "{ not json !!! ");
    expect(() => loadToolApprovals(approvalPath)).not.toThrow();
    expect(loadToolApprovals(approvalPath)).toEqual({ version: 1, allows: {} });
  });

  test("a non-boolean-true entry in `allows` is dropped, not coerced truthy", () => {
    const dir = join(tmpRoot, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(
      join(dir, "tool-approvals.json"),
      JSON.stringify({ version: 1, allows: { bash: true, edit: "yes", write: 1, grep: false } }),
    );
    // Only the literal `true` entry survives — a malformed/tampered file
    // can't accidentally always-allow something.
    expect(loadToolApprovals(approvalPath)).toEqual({ version: 1, allows: { bash: true } });
  });

  test("missing file (never configured) is the same as an empty allows set, not an error", () => {
    expect(() => isToolAlwaysAllowed("bash", approvalPath)).not.toThrow();
    expect(isToolAlwaysAllowed("bash", approvalPath)).toBe(false);
  });
});
