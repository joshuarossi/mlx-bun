import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { hfToken } from "@mlx-bun/hub/download";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
function temporary() { const root = mkdtempSync(join(tmpdir(), "mlx-hub-token-")); roots.push(root); return root; }

test("explicit environment replaces process state and keeps env before cache precedence", () => {
  const path = join(temporary(), "token"); writeFileSync(path, "hf_cache\n");
  expect(hfToken({ environment: { HF_TOKEN: "hf_env" }, cacheTokenPath: path })).toBe("hf_env");
  expect(hfToken({ environment: {}, cacheTokenPath: path })).toBe("hf_cache");
  // Preserve download's existing raw env-token behavior; callers may trim
  // their environment input when they require a different app-level policy.
  expect(hfToken({ environment: { HF_TOKEN: "  hf_env  " }, cacheTokenPath: path })).toBe("  hf_env  ");
});

test("an explicit environment home selects the standard cache token without changing HOME", () => {
  const root = temporary(); mkdirSync(join(root, ".cache/huggingface"), { recursive: true });
  writeFileSync(join(root, ".cache/huggingface/token"), " hf_cache \n");
  expect(hfToken({ environment: { HOME: root } })).toBe("hf_cache");
});

test("missing or empty cache tokens yield null", () => {
  const path = join(temporary(), "token");
  expect(hfToken({ environment: {}, cacheTokenPath: path })).toBeNull();
  writeFileSync(path, " \n");
  expect(hfToken({ environment: {}, cacheTokenPath: path })).toBeNull();
});
