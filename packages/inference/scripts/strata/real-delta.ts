import { createHash } from "node:crypto";
import { readFileSync, realpathSync } from "node:fs";
import { join, basename } from "node:path";
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { loadModelConfig } from "../../src/artifacts/config";
import { Weights } from "../../src/artifacts/weights";
import { QuantizedEmbedding } from "../../src/layers/quantized-embedding";
import { GatedDeltaNet } from "../../src/models/qwen/blocks";
import { qwen35WeightsView } from "../../src/models/qwen/checkpoint";
import { convDeltaDecode } from "../../src/kernels/delta/conv-step";
import { gatedRmsNorm } from "../../src/kernels/gated-rms-norm";
import { CompiledDeltaPair, fusedDelta, splitDelta, referenceDelta, type DeltaInput } from "./delta";

interface Measurement {
  difference(a: MlxArray, b: MlxArray): unknown;
  paired(a: () => MlxArray[], b: () => MlxArray[], count?: number, rounds?: number): unknown;
}
/** First recurrent layer, real checkpoint projections and a continued state.
 * This qualifies this block's samples only, not whole-model logits or serving. */
export async function realDelta(model: string, measure: Measurement, split = false): Promise<unknown[]> {
  model = realpathSync(model);
  const config = await loadModelConfig(model), weights = await Weights.open(model);
  try {
    const view = qwen35WeightsView(weights); if (view) weights.setView(view);
    const prefix = "language_model.model.layers.0";
    const block = new GatedDeltaNet(weights, config, `${prefix}.linear_attn`);
    if (block.headKDim !== 128 || block.headVDim !== 128 || block.convKernel !== 4) throw new Error("real screen requires 128-wide heads and a four-tap convolution");
    const embed = QuantizedEmbedding.load(weights, "language_model.model.embed_tokens", config);
    const gain = weights.tensor(`${prefix}.input_layernorm.weight`);
    using qScale = ops.filledBf16(1 / 128, 128); using kScale = ops.filledBf16(128 ** -.5, 128);
    const hash = (b: Uint8Array) => createHash("sha256").update(b).digest("hex");
    const hashes = Object.fromEntries(weights.tensorNames.filter(n => n.startsWith(`${prefix}.linear_attn.`) || n === `${prefix}.input_layernorm.weight`).map(n => {
      using tensor = ops.contiguous(weights.tensor(n)); return [n, hash(tensor.rawBytes())];
    }));
    const metadata = { model, revision: basename(model), configSha256: hash(readFileSync(join(model, "config.json"))),
      layer: 0, tensorSha256: hashes, hiddenSource: "checkpoint embedding followed by layer-0 input RMSNorm", prefixTokens: 16 };
    const cells: unknown[] = [];
    for (const [B, S] of [[1, 1], [1, 4], [1, 8], [2, 1]]) {
      const projected = (T: number, start: number) => {
        using ids = ops.fromInt32(Array.from({ length: B! * T }, (_, i) => 1000 + start + i * 37), [B!, T]);
        using embedding = embed.encode(ids);
        using hidden = ops.rmsNorm(embedding, gain, block.eps);
        const z = block.inProjZ.forward(hidden);
        try { return { qkv: block.inProjQkv.forward(hidden), a: block.inProjA.forward(hidden), b: block.inProjB.forward(hidden),
          z: ops.reshape(z, [B!, T, block.numVHeads, 128]) }; }
        finally { z.dispose(); }
      };
      const before = projected(16, 0);
      const C = before.qkv.shape[2]!;
      using zeroHist = ops.zeros([B!, 3, C], before.qkv.dtype);
      using zeroState = ops.zeros([B!, block.numVHeads, 128, 128], block.aLog.dtype);
      const common = { conv: block.convWeight, aLog: block.aLog, dt: block.dtBias, norm: block.normWeight,
        hk: block.numKHeads, hv: block.numVHeads, qScale, kScale };
      const seed = referenceDelta({ ...before, ...common, history: zeroHist, state: zeroState });
      const p = projected(S!, 16);
      const x: DeltaInput = { ...p, ...common, state: seed[1]!, history: seed[2]! };
      try {
        ops.evalAll([...Object.values(p), ...seed]);
        const variants = split ? ([2, 4, 8, 16] as const).map(parts => ({ name: `split-${parts}`,
          run: (x: DeltaInput, saveFirst = false) => splitDelta(x, parts, saveFirst) })) : [{ name: "full", run: fusedDelta }];
        if (split && S === 1) variants.push({ name: "decode-binding", run: (x: DeltaInput, saveFirst = false) => {
          const result = convDeltaDecode(x.qkv, x.a, x.b, x.history, x.state, x.conv, x.aLog, x.dt, x.qScale, x.kScale, x.hk, x.hv);
          using raw = result.out; result.k.dispose(); result.v.dispose();
          return [gatedRmsNorm(raw, x.z, x.norm, 1e-6), result.recurrent, result.conv,
            ...(saveFirst ? [ops.copyOf(result.recurrent)] : [])];
        } });
        for (const variant of variants) {
          using compiled = new CompiledDeltaPair(x, variant.run);
          const a = referenceDelta(x), b = variant.run(x, true);
          try {
            const slice = (v: MlxArray) => v.slice(v.shape.map(() => 0), v.shape.map((n, i) => i === 1 ? 1 : n));
            const first = { qkv: slice(p.qkv), a: slice(p.a), b: slice(p.b), z: slice(p.z) };
            try {
              const refFirst = referenceDelta({ ...x, ...first });
              try {
                const ca = compiled.baseline.apply(compiled.inputs), cb = compiled.candidate.apply(compiled.inputs);
                let compiledDiff;
                try { compiledDiff = ca.map((v, i) => measure.difference(cb[i]!, v)); }
                finally { for (const v of [...ca, ...cb]) v.dispose(); }
                const cell = { experiment: "real-layer-fused-delta", variant: variant.name, B, S, metadata,
                  diff: a.map((v, i) => measure.difference(b[i]!, v)), firstState: measure.difference(b[3]!, refFirst[1]!),
                  timing: measure.paired(() => referenceDelta(x), () => variant.run(x), 8), compiledDiff,
                  compiledTiming: measure.paired(() => compiled.baseline.apply(compiled.inputs), () => compiled.candidate.apply(compiled.inputs), 32) };
                console.log(JSON.stringify(cell)); cells.push(cell);
              } finally { for (const v of refFirst) v.dispose(); }
            } finally { for (const v of Object.values(first)) v.dispose(); }
          } finally { for (const v of [...a, ...b]) v.dispose(); }
        }
      } finally { for (const v of [...Object.values(before), ...Object.values(p), ...seed]) v.dispose(); }
    }
    return cells;
  } finally { weights.dispose(); }
}
