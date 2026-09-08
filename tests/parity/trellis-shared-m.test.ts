// Exact candidate-vs-current checks on one resident packed Qwen artifact.
// MLX_BUN_TEST_TRELLIS_MODEL=/path bun test tests/parity/trellis-shared-m.test.ts
// Optional diagnostic timings: MLX_BUN_TRELLIS_AB_REPORT=reports/cell.json.
// MLX_BUN_TRELLIS_AB_LAST=1 screens append lengths with only the final head.
// MLX_BUN_TRELLIS_AB_VARIANT=8 selects shared-M plus balanced 3-bit scatter.
// Variant 13 versus baseline 12 also checks vector expansion at larger prefills.
// This is not the quiet HTTP/oracle benchmark and cannot promote a default.
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { hostname } from "node:os";

const artifact = process.env.MLX_BUN_TEST_TRELLIS_MODEL;
if (artifact && !existsSync(`${artifact}/config.json`)) throw new Error(`unavailable packed artifact: ${artifact}`);
const candidateVariant = Number(process.env.MLX_BUN_TRELLIS_AB_VARIANT ?? "7");
if (![7, 8, 9, 10, 11, 12, 13].includes(candidateVariant)) throw new Error("candidate variant must be 7..13");
const baselineVariant = Number(process.env.MLX_BUN_TRELLIS_AB_BASELINE ?? "6");
if (![6, 7, 8, 9, 10, 11, 12].includes(baselineVariant)) throw new Error("baseline variant must be 6..12");

test.skipIf(!artifact)("shared-M kernels preserve full Qwen logits, recurrent state and KV continuation", async () => {
  const { createModel } = await import("../../src/model/factory");
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { TrellisLinear, setTrellisVariant } = await import("../../src/model/trellis-linear");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { clearCache, peakMemory, resetPeakMemory } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const { checkMachine } = await import("../../src/preflight");
  const weights = await Weights.open(artifact!);
  const config = await loadModelConfig(artifact!);
  const model = createModel(weights, config);
  if (!(model instanceof Qwen35Model)) { weights.dispose(); throw new Error("test requires dense Qwen3.5/3.8"); }
  const prefix = model.makeCache();
  const machineBefore = checkMachine();
  let observedPeak = peakMemory();
  const digest = (data: Uint8Array) => createHash("sha256").update(data).digest("hex");
  const stateHashes = (caches: typeof prefix) => caches.map((cache) => ({
    signature: cache.signature(), offset: cache.offset,
    tensors: cache.state().map((array) => {
      // Plain KV storage can have unused capacity. Compare only valid tokens;
      // recurrent matrices and convolution buffers are fully live state.
      const shape = array.shape;
      const cropped = cache.signature() !== "ssm" && shape.length === 4 && cache.offset < shape[2]!
        ? array.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
      const contiguous = ops.contiguous(cropped ?? array);
      try { return { shape: contiguous.shape, dtype: contiguous.dtype, sha256: digest(contiguous.rawBytesView()) }; }
      finally { contiguous.dispose(); cropped?.dispose(); }
    }),
  }));
  const run = (variant: number, tokens: number[], follow: boolean, lastOnly = false) => {
    const caches = cloneKvCaches(prefix);
    try {
      ops.evalAll(caches.flatMap((cache) => cache.state()));
      setTrellisVariant(variant);
      resetPeakMemory();
      const start = performance.now();
      const logits = (() => {
        if (!lastOnly) return model.forward(tokens, caches);
        const ids = ops.fromInt32(tokens, [1, tokens.length]);
        let hidden;
        try { hidden = model.forwardHidden(ids, caches); }
        finally { ids.dispose(); }
        const last = hidden.slice([0, tokens.length - 1, 0], [1, tokens.length, hidden.shape[2]!]);
        try { return model.logitsFromHidden(last); }
        finally { last.dispose(); hidden.dispose(); }
      })();
      try {
        ops.evalAll([logits, ...caches.flatMap((cache) => cache.state())]);
        const ms = performance.now() - start;
        const peakBytes = peakMemory();
        const hashes = { logits: digest(logits.rawBytesView()), state: stateHashes(caches) };
        let continuation: string | undefined;
        if (follow) {
          const next = model.forward([911], caches);
          try { continuation = digest(next.rawBytesView()); }
          finally { next.dispose(); }
        }
        return { ms, peakBytes, hashes, continuation };
      } finally { logits.dispose(); }
    } finally {
      observedPeak = Math.max(observedPeak, peakMemory());
      for (const cache of caches) cache.dispose(); clearCache();
    }
  };
  const trials: { m: number; block: number; order: number[]; baselineMs: number; candidateMs: number; baselinePeakBytes: number; candidatePeakBytes: number }[] = [];
  try {
    expect(model.layers.filter((layer) => layer.mlp.gate instanceof TrellisLinear).length).toBe(64);
    setTrellisVariant(6);
    const ids = ops.fromInt32(Array.from({ length: 32 }, (_, i) => 100 + i * 7), [1, 32]);
    try {
      const hidden = model.forwardHidden(ids, prefix);
      try { ops.evalAll([hidden, ...prefix.flatMap((cache) => cache.state())]); }
      finally { hidden.dispose(); }
    } finally { ids.dispose(); }
    observedPeak = Math.max(observedPeak, peakMemory());
    // Includes M=1 fallback, partial vector groups and the expansion boundary.
    for (const m of [1, 2, 3, 4, 5]) {
      const tokens = Array.from({ length: m }, (_, i) => 420 + i);
      const reference = run(baselineVariant, tokens, true), candidate = run(candidateVariant, tokens, true);
      expect(candidate.hashes).toEqual(reference.hashes);
      expect(candidate.continuation).toBe(reference.continuation);
      console.log(`[trellis-variant-${candidateVariant}] M=${m}: logits, state and continuation match`);
    }
    if (candidateVariant === 13) for (const m of [16, 128, 512]) {
      const tokens = Array.from({ length: m }, (_, i) => 600 + i * 3);
      const reference = run(baselineVariant, tokens, true, true), candidate = run(candidateVariant, tokens, true, true);
      expect(candidate.hashes).toEqual(reference.hashes);
      expect(candidate.continuation).toBe(reference.continuation);
      console.log(`[trellis-variant-13] M=${m}: last logits, state and continuation match`);
    }
    const reportPath = process.env.MLX_BUN_TRELLIS_AB_REPORT;
    if (reportPath) {
      const lastOnly = process.env.MLX_BUN_TRELLIS_AB_LAST === "1";
      const lengths = lastOnly ? [1, 2, 3, 4, 5, 8, 9, 16, ...(candidateVariant >= 11 ? [32] : []), ...(candidateVariant === 13 ? [128, 512] : [])] : [1, 2, 3, 4];
      // Explicit warmup of every selected shape/head path; retained elsewhere
      // in this test, the M=1..5 identity cells use the all-position head.
      for (const m of lengths) for (const variant of [baselineVariant, candidateVariant])
        run(variant, Array.from({ length: m }, (_, i) => 580 + i), false, lastOnly);
      for (let block = 0; block < 6; block++) for (const m of lengths) {
        const tokens = Array.from({ length: m }, (_, i) => 600 + block * 13 + i);
        const order = block % 2 ? [candidateVariant, baselineVariant] : [baselineVariant, candidateVariant];
        const results = new Map(order.map((v) => [v, run(v, tokens, false, lastOnly)]));
        const baseline = results.get(baselineVariant)!, candidate = results.get(candidateVariant)!;
        expect(candidate.hashes).toEqual(baseline.hashes);
        trials.push({ m, block, order, baselineMs: baseline.ms, candidateMs: candidate.ms,
          baselinePeakBytes: baseline.peakBytes, candidatePeakBytes: candidate.peakBytes });
      }
      const command = (args: string[]) => Bun.spawnSync(args, { stdout: "pipe", stderr: "pipe" }).stdout.toString().trim();
      const report = { kind: "full-model-forward-diagnostic", httpMeasurement: false,
        host: hostname(), chip: command(["sysctl", "-n", "machdep.cpu.brand_string"]),
        ramBytes: Number(command(["sysctl", "-n", "hw.memsize"])), artifact: resolve(artifact!),
        configSha256: digest(await Bun.file(`${artifact}/config.json`).bytes()),
        sourceCommit: command(["git", "rev-parse", "HEAD"]),
        diffSha256: digest(new TextEncoder().encode(command(["git", "diff", "HEAD", "--", "src"]))),
        kernelSha256: digest(await Bun.file(new URL("../../src/model/trellis-shared-m.ts", import.meta.url)).bytes()),
        scatterKernelSha256: digest(await Bun.file(new URL("../../src/model/trellis-balanced-scatter.ts", import.meta.url)).bytes()),
        sharedScatterKernelSha256: digest(await Bun.file(new URL("../../src/model/trellis-shared-scatter.ts", import.meta.url)).bytes()),
        tiledPrefillKernelSha256: digest(await Bun.file(new URL("../../src/model/trellis-tiled-prefill.ts", import.meta.url)).bytes()),
        splitKPrefillKernelSha256: digest(await Bun.file(new URL("../../src/model/trellis-splitk-prefill.ts", import.meta.url)).bytes()),
        vectorExpandKernelSha256: digest(await Bun.file(new URL("../../src/model/trellis-vector-expand.ts", import.meta.url)).bytes()),
        baselineVariant, candidateVariant,
        machineBefore, machineAfter: checkMachine(), peakBytes: observedPeak,
        prefixTokens: 32, kv: "bf16 plus f32 recurrent state", outputIdentity: "exact observed logits and state",
        head: lastOnly ? "last-position-only" : "all-positions", lengths,
        note: "Synthetic token IDs; cloned common prefix. Timings include graph construction and eval of the selected output positions and cache state; cloning, hashing and cleanup are outside timing. Not user-facing throughput.", trials };
      mkdirSync(dirname(resolve(reportPath)), { recursive: true });
      await Bun.write(reportPath, JSON.stringify(report, null, 2) + "\n");
    }
  } finally {
    setTrellisVariant(null);
    for (const cache of prefix) cache.dispose();
    weights.dispose(); clearCache();
  }
}, 300_000);
