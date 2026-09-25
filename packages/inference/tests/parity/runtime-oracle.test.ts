import { describe, expect, test } from "bun:test";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { compareReports, parsePlan } from "../../scripts/runtime-oracle";

const plan = parsePlan({ model: "/external/model", runtime: "0.32.2", contexts: [0, 4], lengths: [1, 2], prefixChunk: 2 });
function report() {
  const array = (shape: number[]) => ({ shape, dtype: "float32", sha256: "a".repeat(64) });
  const state = (offset: number) => [{ offset, recurrent: false, arrays: offset ? [array([1, 2, offset, 4])] : [] }];
  return { runtime: plan.runtime, configSha256: "b".repeat(64), provenance: { runtimeEnvironment: {} },
    rows: plan.contexts.flatMap(context => plan.lengths.map(m => ({ context, m,
      prefix: state(context), logits: array([1, m, 12]), state: state(context + m),
      continuation: array([1, 1, 12]), continuationState: state(context + m + 1) }))) };
}
describe("runtime report comparison (CPU only)", () => {
  test("accepts complete matching grids and state regardless of timing metadata", () => {
    compareReports({ ...report(), activeAfter: 42 }, { ...report(), activeAfter: 0 }, plan);
  });
  test("rejects empty, duplicate and invalid plan cases", () => {
    for (const patch of [{ contexts: [] }, { contexts: [0, 0] }, { contexts: [-1] }, { lengths: [0] }, { prefixChunk: 0 }, { lengths: [1.5] }])
      expect(() => parsePlan({ ...plan, ...patch })).toThrow();
  });
  test("matching omissions and malformed tensors cannot pass", () => {
    const cases = [
      (r: any) => { r.rows = []; },
      (r: any) => { r.rows[0].state = []; },
      (r: any) => { r.rows[0].state[0].arrays = []; },
      (r: any) => { r.rows[0].continuationState[0].offset = 0; },
      (r: any) => { delete r.rows[0].continuation; },
      (r: any) => { r.rows[0].logits.sha256 = ""; },
      (r: any) => { r.rows[1].logits.shape = [1, 1, 12]; },
      (r: any) => { r.rows[0].m = 2; },
      (r: any) => { r.runtime = "wrong"; },
    ];
    for (const mutate of cases) { const r = report(); mutate(r); expect(() => compareReports(r, r, plan)).toThrow(); }
  });
  test("localizes the first unequal state plane", () => {
    const reference = report();
    reference.rows[0]!.state[0]!.arrays[0]!.sha256 = "c".repeat(64);
    expect(() => compareReports(report(), reference, plan)).toThrow("rows.0.state.0.arrays.0.sha256");
  });
  test("rejects mismatched model config and runtime overrides", () => {
    expect(() => compareReports(report(), { ...report(), configSha256: "c".repeat(64) }, plan)).toThrow("configuration");
    const reference = { ...report(), provenance: { runtimeEnvironment: { MLX_BUN_COMPILED_DECODE: "1" } } };
    expect(() => compareReports(report(), reference, plan)).toThrow("runtimeEnvironment");
  });
  test("legacy configuration requires explicit acceptance and never bypasses row checks", () => {
    const { provenance, ...legacy } = report();
    expect(() => compareReports(report(), legacy, plan)).toThrow("configuration provenance missing");
    compareReports(report(), legacy, plan, true);
    legacy.rows.pop();
    expect(() => compareReports(report(), legacy, plan, true)).toThrow("missing or extra");
  });
  test("help does not load native libraries", () => {
    const proc = Bun.spawnSync([process.execPath, resolve(import.meta.dir, "../../scripts/runtime-oracle.ts"), "--help"],
      { env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
    expect(proc.exitCode).toBe(0);
    expect(proc.stdout.toString()).toContain("Full logits and live-state parity");
  });
});

// References and weights are supplied externally. This test never starts Python.
const planPath = process.env.MLX_BUN_PARITY_PLAN;
const referencePath = process.env.MLX_BUN_PARITY_REFERENCE;
test.skipIf(!planPath || !referencePath)("local model matches the supplied external runtime report", async () => {
  const directory = await mkdtemp(join(tmpdir(), "mlx-runtime-parity-"));
  const output = join(directory, "actual.json");
  let passed = false;
  try {
    const worker = Bun.spawn([process.execPath, resolve(import.meta.dir, "../../scripts/runtime-oracle.ts"), "emit", "--plan", planPath!, "--report", output],
      { stdout: "inherit", stderr: "inherit" });
    expect(await worker.exited).toBe(0);
    compareReports(await Bun.file(output).json(), await Bun.file(referencePath!).json(),
      parsePlan(await Bun.file(planPath!).json()), process.env.MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG === "1");
    passed = true;
  } finally {
    if (passed) await rm(directory, { recursive: true });
    else console.error(`Parity evidence retained at ${directory}`);
  }
}, Number(process.env.MLX_BUN_PARITY_TIMEOUT_MS ?? 600_000));
