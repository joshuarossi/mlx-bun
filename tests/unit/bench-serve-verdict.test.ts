// bench-serve pure helpers (fast tier — no servers, no weights). The 2026-07-06
// serve h2h produced "diverged at char 0" verdicts that were TEMPLATE drift
// (mlx-lm silently pins enable_thinking; prompt_tokens 25 vs 32), not engine
// divergence — probeVerdict's hard precondition is what prevents a recurrence.
// bench-serve.ts is import-safe (main() gated on import.meta.main).

import { describe, expect, test } from "bun:test";
import { benchmarkSourceSnapshot, probeVerdict, scaledBudgetMs, type ProbeOut } from "../../scripts/bench-serve";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const p = (text: string, promptTokens: number): ProbeOut => ({ text, promptTokens });

test("source identity includes unstaged kernels, edits and deletions while ignoring reports", () => {
  const cwd = mkdtempSync(join(tmpdir(), "bench-source-"));
  try {
    expect(Bun.spawnSync(["git", "init", "-q"], { cwd }).exitCode).toBe(0);
    mkdirSync(join(cwd, "src"));
    mkdirSync(join(cwd, "reports"));
    writeFileSync(join(cwd, "src/base.ts"), "base");
    expect(Bun.spawnSync(["git", "add", "src"], { cwd }).exitCode).toBe(0);
    const base = benchmarkSourceSnapshot(cwd);
    writeFileSync(join(cwd, "src/new-kernel.ts"), "v1");
    const added = benchmarkSourceSnapshot(cwd);
    expect(added.sha256).not.toBe(base.sha256);
    expect(added.files.map((f) => f.path)).toEqual(["src/base.ts", "src/new-kernel.ts"]);
    writeFileSync(join(cwd, "src/new-kernel.ts"), "v2");
    expect(benchmarkSourceSnapshot(cwd).sha256).not.toBe(added.sha256);
    rmSync(join(cwd, "src/new-kernel.ts"));
    writeFileSync(join(cwd, "reports/result.json"), "{}");
    expect(benchmarkSourceSnapshot(cwd).sha256).toBe(base.sha256);
    rmSync(join(cwd, "src/base.ts"));
    expect(benchmarkSourceSnapshot(cwd).files).toEqual([]);
  } finally { rmSync(cwd, { recursive: true, force: true }); }
});

describe("probeVerdict", () => {
  test("prompt_tokens inequality is a HARD stop — drift verdict, never a char-diff", () => {
    const v = probeVerdict("chat", "bf16 drop-in", p("2, 3, 5", 25), p("2, 3, 5", 32));
    expect(v).toContain("TEMPLATE/TOKENIZER DRIFT (25 vs 32)");
    expect(v).toContain("parity not attempted");
    expect(v).not.toContain("diverged at char");
  });

  test("completion probe drift is labeled TOKENIZER (no template on that path)", () => {
    const v = probeVerdict("completion", "bf16 drop-in", p("x", 8), p("x", 9));
    expect(v).toContain("TOKENIZER DRIFT (8 vs 9)");
    expect(v).not.toContain("TEMPLATE/");
  });

  test("equal tokens + identical text = parity pass", () => {
    const v = probeVerdict("completion", "bf16 drop-in", p(" 2, 3, 5, 7", 8), p(" 2, 3, 5, 7", 8));
    expect(v).toContain("parity ✓");
    expect(v).toContain("[completion-probe]");
    expect(v).toContain("prompt_tokens 8 both");
  });

  test("equal tokens + differing text = char-diff at the right offset", () => {
    const v = probeVerdict("chat", "mixed-KV", p("abcdef", 30), p("abcXef", 30));
    expect(v).toContain("parity ✗");
    expect(v).toContain("diverged at char 3");
    expect(v).toContain("equal prompt token counts");
  });

  test("missing probe on either side = not attempted, names the side", () => {
    expect(probeVerdict("chat", "L", null, p("x", 1))).toContain("first arm");
    expect(probeVerdict("chat", "L", p("x", 1), undefined)).toContain("second arm");
    expect(probeVerdict("chat", "L", null, null)).toContain("both arms");
  });

  test("missing token usage cannot produce a parity pass", () => {
    const v = probeVerdict("chat", "L", p("same", 0), p("same", 0));
    expect(v).toContain("parity ?");
    expect(v).toContain("UNVERIFIED");
  });
});

describe("scaledBudgetMs", () => {
  test("scales tokens/tps with the safety factor", () => {
    // 16384 tok at 512 tok/s = 32 s; ×4 safety = 128 s
    expect(scaledBudgetMs(16384, 512, 60_000)).toBe(128_000);
  });

  test("clamps to the floor when the scaled budget is small", () => {
    expect(scaledBudgetMs(1024, 4096, 180_000)).toBe(180_000);
  });

  test("unknown rate (failed measuring leg) falls back generous, never tight", () => {
    expect(scaledBudgetMs(16384, 0, 180_000)).toBe(600_000);
    expect(scaledBudgetMs(16384, Number.NaN, 180_000)).toBe(600_000);
  });

  test("custom safety factor honored (ctx cold uses 6)", () => {
    expect(scaledBudgetMs(16384, 512, 0, 6)).toBe(192_000);
  });
});
