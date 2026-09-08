// Actual Qwen R8 gate, one artifact per process. No server or downloads.
// MLX_BUN_TEST_QWEN_CONV_MODEL=/path bun test tests/parity/qwen-conv.test.ts
// Optional MLX_BUN_TEST_QWEN_CONV_REPORT records diagnostic paired timings.
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";
import { hostname } from "node:os";

const artifact = process.env.MLX_BUN_TEST_QWEN_CONV_MODEL;
const reportPath = process.env.MLX_BUN_TEST_QWEN_CONV_REPORT;
if (artifact && !existsSync(`${artifact}/config.json`)) throw new Error(`missing model: ${artifact}`);

test.skipIf(!artifact)("fused convolution preserves Qwen logits, live state, continuation and rollback", async () => {
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { fusedQwenConvolution } = await import("../../src/model/qwen-conv");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { clearCache, resetPeakMemory, peakMemory } = await import("../../src/mlx/ffi");
  const { checkMachine } = await import("../../src/preflight");
  const ops = await import("../../src/mlx/ops");
  const weights = await Weights.open(artifact!), config = await loadModelConfig(artifact!);
  const model = createModel(weights, config);
  if (!(model instanceof Qwen35Model)) { weights.dispose(); throw new Error("dense Qwen required"); }
  const prefix = model.makeCache();
  const sha = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");
  const shell = (args: string[]) => Bun.spawnSync(args, { stdout: "pipe", stderr: "pipe" }).stdout.toString().trim();
  const before = checkMachine(), rows: unknown[] = [];
  const select = (fused: boolean) => { for (const layer of model.layers) if (layer.linearAttn)
    layer.linearAttn.convolution = fused ? fusedQwenConvolution : null; };
  const stateHashes = (caches: typeof prefix) => caches.map((c) => ({ offset: c.offset, signature: c.signature(),
    arrays: c.state().map((a) => {
      const s = a.shape;
      const crop = c.signature() !== "ssm" && s.length === 4 && c.offset < s[2]!
        ? a.slice([0, 0, 0, 0], [s[0]!, s[1]!, c.offset, s[3]!]) : null;
      const data = ops.contiguous(crop ?? a);
      try { return { shape: data.shape, dtype: data.dtype, sha256: sha(data.rawBytesView()) }; }
      finally { data.dispose(); crop?.dispose(); }
    }) }));
  const run = (fused: boolean, m: number, rollback = false) => {
    select(fused); const cache = cloneKvCaches(prefix);
    try {
      if (rollback) for (const c of cache) c.specRoundBegin?.();
      const ids = ops.fromInt32(Array.from({ length: m }, (_, i) => 500 + i * 3), [1, m]);
      resetPeakMemory(); const start = performance.now();
      const h = model.forwardHidden(ids, cache); ids.dispose();
      const last = h.slice([0, m - 1, 0], [1, m, h.shape[2]!]); h.dispose();
      const logits = model.logitsFromHidden(last); last.dispose();
      try {
        ops.evalAll([logits, ...cache.flatMap((c) => c.state())]);
        const ms = performance.now() - start, peakBytes = peakMemory();
        const logitsSha256 = sha(logits.rawBytesView());
        if (rollback) for (const c of cache) {
          if (c.specRoundRollback) c.specRoundRollback(2);
          else c.trim(m - 2);
        }
        const state = stateHashes(cache);
        const next = model.forward([911], cache);
        try { return { ms, peakBytes, logitsSha256, state, continuation: sha(next.rawBytesView()) }; }
        finally { next.dispose(); }
      } finally { logits.dispose(); }
    } finally { for (const c of cache) c.dispose(); clearCache(); }
  };
  try {
    const ids = ops.fromInt32(Array.from({ length: 32 }, (_, i) => 100 + i * 7), [1, 32]);
    const h = model.forwardHidden(ids, prefix); ids.dispose();
    ops.evalAll([h, ...prefix.flatMap((c) => c.state())]); h.dispose();
    for (const m of [1, 2, 3, 4, 5, 16, 128, 512]) {
      const baseline = run(false, m), candidate = run(true, m);
      rows.push({ m, kind: "identity", baseline, candidate });
      expect(candidate.logitsSha256).toBe(baseline.logitsSha256);
      expect(candidate.state).toEqual(baseline.state);
      expect(candidate.continuation).toBe(baseline.continuation);
    }
    const baseline = run(false, 4, true), candidate = run(true, 4, true);
    rows.push({ m: 4, kind: "rollback-to-2", baseline, candidate });
    expect(candidate.state).toEqual(baseline.state);
    expect(candidate.continuation).toBe(baseline.continuation);
    if (reportPath) for (const m of [1, 4, 128, 512]) for (let block = 0; block < 6; block++) {
      const order = block % 2 ? [true, false] : [false, true];
      const a = run(order[0]!, m), b = run(order[1]!, m);
      const baseline = order[0] ? b : a, candidate = order[0] ? a : b;
      rows.push({ m, block, kind: "paired-diagnostic", order, baseline, candidate });
      expect(candidate.logitsSha256).toBe(baseline.logitsSha256);
      expect(candidate.state).toEqual(baseline.state);
      expect(candidate.continuation).toBe(baseline.continuation);
    }
  } finally {
    if (reportPath) {
      mkdirSync(dirname(reportPath), { recursive: true });
      await Bun.write(reportPath, JSON.stringify({ kind: "qwen-conv-native-diagnostic", canonical: false,
        artifact, host: hostname(), chip: shell(["sysctl", "-n", "machdep.cpu.brand_string"]),
        sourceCommit: shell(["git", "rev-parse", "HEAD"]), configSha256: sha(await Bun.file(`${artifact}/config.json`).bytes()),
        sourceFiles: Object.fromEntries(await Promise.all(["src/model/qwen3_5.ts", "src/model/qwen-conv.ts", "src/mlx/materialize.ts", "src/mlx/array.ts", "src/mlx/ops.ts", import.meta.path]
          .map(async (path) => [path, sha(await Bun.file(path).bytes())]))),
        machineBefore: before, machineAfter: checkMachine(), rows }, null, 2) + "\n");
    }
    select(false); for (const c of prefix) c.dispose(); weights.dispose(); clearCache();
  }
}, 600_000);
