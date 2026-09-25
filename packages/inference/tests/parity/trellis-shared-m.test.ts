// Opt-in real packed Qwen artifact; no timing, oracle startup or downloads.
// MLX_BUN_TEST_TRELLIS_MODEL selects it; AB_VARIANT/AB_BASELINE retain main defaults.
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync } from "node:fs";

const artifact = process.env.MLX_BUN_TEST_TRELLIS_MODEL;
if (artifact && !existsSync(`${artifact}/config.json`)) throw new Error(`unavailable packed artifact: ${artifact}`);
const candidateVariant = Number(process.env.MLX_BUN_TRELLIS_AB_VARIANT ?? "7");
if (![7, 8, 9, 10, 11, 12, 13].includes(candidateVariant)) throw new Error("candidate variant must be 7..13");
const baselineVariant = Number(process.env.MLX_BUN_TRELLIS_AB_BASELINE ?? "6");
if (![6, 7, 8, 9, 10, 11, 12].includes(baselineVariant)) throw new Error("baseline variant must be 6..12");

test.skipIf(!artifact)("shared-M kernels preserve full Qwen logits, recurrent state and KV continuation", async () => {
  const { createModel } = await import("@mlx-bun/inference/models");
  const { loadModelConfig } = await import("@mlx-bun/inference/artifacts");
  const { Weights } = await import("@mlx-bun/inference/artifacts");
  const { Qwen35Model } = await import("@mlx-bun/inference/models/qwen3_5");
  const { TrellisLinear, setTrellisVariant } = await import("@mlx-bun/inference/layers");
  const { cloneKvCaches } = await import("@mlx-bun/inference/state");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");
  const ops = await import("@mlx-bun/mlx/ops");
  const weights = await Weights.open(artifact!);
  const config = await loadModelConfig(artifact!);
  const model = createModel(weights, config);
  if (!(model instanceof Qwen35Model)) { weights.dispose(); throw new Error("test requires dense Qwen3.5/3.8"); }
  const prefix = model.makeCache();
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
        const hashes = { logits: digest(logits.rawBytesView()), state: stateHashes(caches) };
        let continuation: string | undefined;
        if (follow) {
          const next = model.forward([911], caches);
          try { continuation = digest(next.rawBytesView()); }
          finally { next.dispose(); }
        }
        return { hashes, continuation };
      } finally { logits.dispose(); }
    } finally {
      for (const cache of caches) cache.dispose(); clearCache();
    }
  };

  try {
    expect(model.layers.filter((layer) => layer.mlp.gate instanceof TrellisLinear).length).toBe(64);
    setTrellisVariant(6);
    const ids = ops.fromInt32(Array.from({ length: 32 }, (_, i) => 100 + i * 7), [1, 32]);
    try {
      const hidden = model.forwardHidden(ids, prefix);
      try { ops.evalAll([hidden, ...prefix.flatMap((cache) => cache.state())]); }
      finally { hidden.dispose(); }
    } finally { ids.dispose(); }
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

    // Preserve main's last-head screening cells and alternating invocation
    // order without its timing/report machinery.
    const lengths = [1, 2, 3, 4, 5, 8, 9, 16, ...(candidateVariant >= 11 ? [32] : []),
      ...(candidateVariant === 13 ? [128, 512] : [])];
    for (let block = 0; block < 6; block++) for (const m of lengths) {
      const tokens = Array.from({ length: m }, (_, i) => 600 + block * 13 + i);
      const order = block % 2 ? [candidateVariant, baselineVariant] : [baselineVariant, candidateVariant];
      const results = new Map(order.map(variant => [variant, run(variant, tokens, false, true)]));
      expect(results.get(candidateVariant)!.hashes).toEqual(results.get(baselineVariant)!.hashes);
    }

  } finally {
    setTrellisVariant(null);
    for (const cache of prefix) cache.dispose();
    weights.dispose(); clearCache();
  }
}, 300_000);
