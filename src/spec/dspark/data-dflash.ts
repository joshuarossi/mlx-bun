// Data path for faithful DFlash (multi-layer H_ctx). Parallel to data.ts.
//
// Shard stores, per packed sequence, the target's tapped hiddens at m layers
// concatenated on the feature axis: `hidden_ml` [Ltot, m*H] bf16 (the m layers
// in tapLayers order, the LAST being the post-finalNorm hidden used for p^t),
// plus `ids` [Ltot], `seq_lens` [nSeq], `resp_starts` [nSeq].
//
// A training anchor at response position t attends the FULL prefix context
// [0..t] (paper Eq 2/3), so sampleBatch slices a per-anchor variable-length
// prefix and LEFT-PADS the batch to a fixed maxCtx with a key-padding mask.

import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import { loadAdapterTensors } from "../../lora";
import { writeShardedSafetensors, type NamedTensor } from "../../quantize/safetensors-writer";
import { mkdirSync, writeFileSync, readFileSync, existsSync, readdirSync } from "node:fs";
import { join } from "node:path";

/** One re-forwarded sequence: ids, the response-region start, and the m-layer
 *  hiddens over the FULL sequence (row-major [L, m*H] bf16 bytes). */
export interface DflashRecord {
  ids: number[];
  respStart: number;
  hiddenMlBf16: Uint8Array;
}

export interface DflashShardMeta {
  nSeq: number; nTokens: number; hiddenSize: number; m: number; tapLayers: number[];
}

export function writeDflashShard(outDir: string, shardIdx: number, records: DflashRecord[], hiddenSize: number, m: number, tapLayers: number[]): DflashShardMeta {
  const dir = join(outDir, `shard_${String(shardIdx).padStart(5, "0")}`);
  mkdirSync(dir, { recursive: true });
  const mH = m * hiddenSize;
  const seqLens: number[] = [], respStarts: number[] = [], allIds: number[] = [], parts: Uint8Array[] = [];
  for (const r of records) {
    seqLens.push(r.ids.length); respStarts.push(r.respStart);
    for (const id of r.ids) allIds.push(id);
    parts.push(r.hiddenMlBf16);
  }
  const nTokens = allIds.length;
  let total = 0; for (const p of parts) total += p.length;
  const bytes = new Uint8Array(total); let off = 0; for (const p of parts) { bytes.set(p, off); off += p.length; }
  const hidden = MlxArray.fromBytesCopy(bytes, [nTokens, mH], Dtype.bfloat16);
  const ids = MlxArray.fromInt32(new Int32Array(allIds), [nTokens]);
  const lens = MlxArray.fromInt32(new Int32Array(seqLens), [seqLens.length]);
  const rs = MlxArray.fromInt32(new Int32Array(respStarts), [respStarts.length]);
  const tensors: NamedTensor[] = [
    { name: "hidden_ml", array: hidden }, { name: "ids", array: ids },
    { name: "seq_lens", array: lens }, { name: "resp_starts", array: rs },
  ];
  writeShardedSafetensors(dir, tensors);
  for (const t of tensors) t.array.dispose();
  const meta: DflashShardMeta = { nSeq: records.length, nTokens, hiddenSize, m, tapLayers };
  writeFileSync(join(dir, "shard.json"), JSON.stringify(meta, null, 2));
  return meta;
}

export class DflashShard {
  readonly hiddenMl: MlxArray; // [Ltot, m*H] bf16
  readonly ids: Int32Array;
  readonly seqStart: number[]; readonly seqLen: number[]; readonly respStart: number[];
  readonly hiddenSize: number; readonly m: number;
  constructor(hiddenMl: MlxArray, ids: Int32Array, seqLens: Int32Array, respStarts: Int32Array, hiddenSize: number, m: number) {
    this.hiddenMl = hiddenMl; this.ids = ids; this.hiddenSize = hiddenSize; this.m = m;
    this.seqStart = []; this.seqLen = []; this.respStart = [];
    let off = 0;
    for (let i = 0; i < seqLens.length; i++) { this.seqStart.push(off); this.seqLen.push(seqLens[i]!); this.respStart.push(respStarts[i]!); off += seqLens[i]!; }
  }
  static load(dir: string): DflashShard {
    const meta = JSON.parse(readFileSync(join(dir, "shard.json"), "utf8")) as DflashShardMeta;
    const t = loadAdapterTensors(join(dir, "model.safetensors"));
    try {
      const hidden = t.get("hidden_ml"), idsA = t.get("ids"), lensA = t.get("seq_lens"), rsA = t.get("resp_starts");
      if (!hidden || !idsA || !lensA || !rsA) throw new Error(`shard ${dir} missing tensors`);
      const ids = Int32Array.from(idsA.toFloat32(), (v) => Math.round(v));
      const lens = Int32Array.from(lensA.toFloat32(), (v) => Math.round(v));
      const rs = Int32Array.from(rsA.toFloat32(), (v) => Math.round(v));
      idsA.dispose(); lensA.dispose(); rsA.dispose();
      return new DflashShard(hidden, ids, lens, rs, meta.hiddenSize, meta.m);
    } catch (e) { for (const [, a] of t) a.dispose(); throw e; }
  }
  dispose(): void { this.hiddenMl.dispose(); }
}

export function listDflashShards(root: string): string[] {
  if (!existsSync(root)) return [];
  return readdirSync(root).filter((n) => n.startsWith("shard_")).sort().map((n) => join(root, n));
}

export interface DflashBatch {
  hCtx: MlxArray;         // [A, maxCtx, m*H] bf16, LEFT-padded
  ctxMask: MlxArray;      // [A, maxCtx] f32 (1=real, 0=pad)
  targetHidden: MlxArray; // [A, γ, H] bf16 (final-layer hiddens at block positions → p^t)
  anchorToks: number[];
  blockToks: number[][];
  size: number;
}

/**
 * Sample A anchors and gather them into a faithful DFlash batch. Each anchor at
 * response position t contributes its full prefix context [0..t] (capped at
 * maxCtx, keeping the most recent), left-padded. The final tapped layer (last
 * in tapLayers = post-finalNorm) supplies the block's p^t hiddens.
 */
export function sampleDflashBatch(shard: DflashShard, A: number, gamma: number, maxCtx: number, rng: () => number): DflashBatch | null {
  const H = shard.hiddenSize, m = shard.m, mH = m * H;
  const ctxIdx: number[] = [];   // A*maxCtx global indices (dummy 0 for pads)
  const maskRows: number[] = []; // A*maxCtx
  const blockIdx: number[] = []; // A*γ global indices
  const anchorToks: number[] = [];
  const blockToks: number[][] = [];

  let got = 0, guard = 0;
  while (got < A && guard < A * 64) {
    guard++;
    const s = Math.floor(rng() * shard.seqLen.length);
    const len = shard.seqLen[s]!, rStart = shard.respStart[s]!, start = shard.seqStart[s]!;
    // anchor local t in [rStart, len-γ-1]; need γ tokens after and t in response.
    const lo = rStart, hi = len - gamma - 1;
    if (hi < lo) continue;
    const t = lo + Math.floor(rng() * (hi - lo + 1));
    const g = start + t;
    // prefix context [0..t], capped to the most-recent maxCtx positions.
    const La = Math.min(t + 1, maxCtx);
    const ctxStart = g - La + 1;
    const pad = maxCtx - La;
    for (let j = 0; j < pad; j++) { ctxIdx.push(0); maskRows.push(0); }
    for (let j = 0; j < La; j++) { ctxIdx.push(ctxStart + j); maskRows.push(1); }
    const bt: number[] = [];
    for (let k = 1; k <= gamma; k++) bt.push(shard.ids[g + k]!); // CE/markov targets x_{t+1..t+γ}
    // p^t hiddens: block position k predicts x_{t+1+k}, whose target dist is
    // softmax(LM_head(h_{t+k})) — the hidden that PREDICTS it. So gather
    // positions [t..t+γ-1] = [g..g+γ-1], NOT [g+1..g+γ] (off-by-one fix).
    for (let k = 0; k < gamma; k++) blockIdx.push(g + k);
    anchorToks.push(shard.ids[g]!); blockToks.push(bt); got++;
  }
  if (got === 0) return null;

  const cIdx = MlxArray.fromInt32(new Int32Array(ctxIdx), [got * maxCtx]);
  const gathered = ops.takeAxis(shard.hiddenMl, cIdx, 0); // [A*maxCtx, m*H]
  cIdx.dispose();
  const hCtx = ops.reshape(gathered, [got, maxCtx, mH]); gathered.dispose();
  const ctxMask = MlxArray.fromFloat32(new Float32Array(maskRows), [got, maxCtx]);

  const bIdx = MlxArray.fromInt32(new Int32Array(blockIdx), [got * gamma]);
  const bGathered = ops.takeAxis(shard.hiddenMl, bIdx, 0); // [A*γ, m*H]
  bIdx.dispose();
  // final tapped layer = last H columns → the post-finalNorm hidden for p^t
  const finalSlice = bGathered.slice([0, (m - 1) * H], [got * gamma, m * H]); // [A*γ, H]
  bGathered.dispose();
  const targetHidden = ops.reshape(finalSlice, [got, gamma, H]); finalSlice.dispose();

  return { hCtx, ctxMask, targetHidden, anchorToks, blockToks, size: got };
}
