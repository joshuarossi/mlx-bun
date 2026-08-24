// Durable "always allow this tool" persistence (src/tool-approvals.ts),
// web-chat-redesign.md §5.4/§6.5/§9 Phase 2, risk #6. Exercised entirely
// against a THROWAWAY tmp HOME (never ~/.mlx-bun) — matches tests/
// hf-push.test.ts's own tmp-HOME pattern for the sibling ~/.mlx-bun/hf.json
// config file.
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

import { afterAll, beforeEach, describe, expect, test } from "bun:test";
import { mkdtempSync, writeFileSync, statSync, readFileSync, mkdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  isToolAlwaysAllowed,
  setToolAlwaysAllowed,
  revokeToolAlwaysAllowed,
  listAlwaysAllowedTools,
  loadToolApprovals,
  TOOL_APPROVALS_VERSION,
} from "../../src/tool-approvals";

describe("tool-approvals (tmp HOME)", () => {
  let tmpHome: string;
  let realHome: string | undefined;

  beforeEach(() => {
    realHome = process.env.HOME;
    tmpHome = mkdtempSync(join(tmpdir(), "mlx-bun-home-"));
    process.env.HOME = tmpHome;
  });
  afterAll(() => {
    if (realHome !== undefined) process.env.HOME = realHome;
  });

  test("fresh machine: nothing is always-allowed, ask every time", () => {
    expect(isToolAlwaysAllowed("bash")).toBe(false);
    expect(listAlwaysAllowedTools()).toEqual([]);
    expect(loadToolApprovals()).toEqual({ version: 1, allows: {} });
  });

  test("set/get round-trips and persists with 0600 perms", () => {
    setToolAlwaysAllowed("bash");
    expect(isToolAlwaysAllowed("bash")).toBe(true);
    expect(isToolAlwaysAllowed("edit")).toBe(false);
    expect(listAlwaysAllowedTools()).toEqual(["bash"]);

    const path = join(tmpHome, ".mlx-bun", "tool-approvals.json");
    const mode = statSync(path).mode & 0o777;
    expect(mode).toBe(0o600);
    const parsed = JSON.parse(readFileSync(path, "utf8"));
    expect(parsed.version).toBe(1);
    expect(parsed.allows).toEqual({ bash: true });
  });

  test("setting is idempotent and keyed by TOOL NAME (not per-call args)", () => {
    setToolAlwaysAllowed("write");
    setToolAlwaysAllowed("write");
    expect(listAlwaysAllowedTools()).toEqual(["write"]);
  });

  test("multiple tools accumulate; list is sorted", () => {
    setToolAlwaysAllowed("write");
    setToolAlwaysAllowed("bash");
    setToolAlwaysAllowed("edit");
    expect(listAlwaysAllowedTools()).toEqual(["bash", "edit", "write"]);
  });

  test("revoke removes exactly the named tool and is idempotent", () => {
    setToolAlwaysAllowed("bash");
    setToolAlwaysAllowed("edit");
    revokeToolAlwaysAllowed("bash");
    expect(isToolAlwaysAllowed("bash")).toBe(false);
    expect(isToolAlwaysAllowed("edit")).toBe(true);
    // Revoking something not present is a no-op, not an error.
    revokeToolAlwaysAllowed("bash");
    expect(listAlwaysAllowedTools()).toEqual(["edit"]);
  });

  test("migration-shaped: a hand-written v1 file (current shape) loads exactly", () => {
    const dir = join(tmpHome, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(
      join(dir, "tool-approvals.json"),
      JSON.stringify({ version: TOOL_APPROVALS_VERSION, allows: { bash: true, edit: true } }, null, 2) + "\n",
    );
    expect(loadToolApprovals()).toEqual({ version: 1, allows: { bash: true, edit: true } });
    expect(isToolAlwaysAllowed("bash")).toBe(true);
    expect(isToolAlwaysAllowed("edit")).toBe(true);
    expect(isToolAlwaysAllowed("write")).toBe(false);
    // And it's still writable afterward (round-trip through the real API,
    // not just readable).
    setToolAlwaysAllowed("write");
    expect(listAlwaysAllowedTools()).toEqual(["bash", "edit", "write"]);
  });

  test("a file with no version field (defensive: hand-edited/pre-versioning) still loads its allows", () => {
    const dir = join(tmpHome, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(join(dir, "tool-approvals.json"), JSON.stringify({ allows: { bash: true } }));
    expect(loadToolApprovals()).toEqual({ version: 1, allows: { bash: true } });
  });

  test("an unrecognized FUTURE version degrades to ask-every-time, not a guess at its shape", () => {
    const dir = join(tmpHome, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(join(dir, "tool-approvals.json"), JSON.stringify({ version: 99, allows: { bash: true } }));
    expect(loadToolApprovals()).toEqual({ version: 1, allows: {} });
    expect(isToolAlwaysAllowed("bash")).toBe(false);
  });

  test("corrupt JSON degrades to ask-every-time rather than throwing", () => {
    const dir = join(tmpHome, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(join(dir, "tool-approvals.json"), "{ not json !!! ");
    expect(() => loadToolApprovals()).not.toThrow();
    expect(loadToolApprovals()).toEqual({ version: 1, allows: {} });
  });

  test("a non-boolean-true entry in `allows` is dropped, not coerced truthy", () => {
    const dir = join(tmpHome, ".mlx-bun");
    mkdirSync(dir, { recursive: true });
    writeFileSync(
      join(dir, "tool-approvals.json"),
      JSON.stringify({ version: 1, allows: { bash: true, edit: "yes", write: 1, grep: false } }),
    );
    // Only the literal `true` entry survives — a malformed/tampered file
    // can't accidentally always-allow something.
    expect(loadToolApprovals()).toEqual({ version: 1, allows: { bash: true } });
  });

  test("missing file (never configured) is the same as an empty allows set, not an error", () => {
    expect(() => isToolAlwaysAllowed("bash")).not.toThrow();
    expect(isToolAlwaysAllowed("bash")).toBe(false);
  });
});
