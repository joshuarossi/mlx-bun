// Segmented backward: long-context LoRA SFT that streams the backward pass
// segment-by-segment so only ONE segment's activations are ever live, instead
// of holding every layer's recompute activations at once (the spike that makes
// naive gradient checkpointing crash at long context). Design + proof:
// docs/design/segmented-backward-training.md (mechanism validated on a toy in
// scripts/ckpt-mem-test.ts, SEG mode: 0.000% grad error, peak below per-layer
// checkpointing; bit-exact on MiniCPM5 under flash attention).
//
// Mechanism (B=1 SFT only — the responseOnlyCe path):
//   1. Forward, saving boundaries. Run the layer stack; at each segment edge
//      materialize (eval) and DETACH (copy to a graph-free leaf) the residual
//      stream hidden into a boundary. Intra-segment interiors are discarded; the
//      boundaries are small ([1, T, hidden] per edge).
//   2. Loss head. finalNorm + LM head + response-only CE over the LAST boundary,
//      differentiated w.r.t. that boundary -> the loss value and dh_out, the
//      gradient of the loss w.r.t. the final residual stream.
//   3. Backward, reverse over segments. For each segment k (last -> first) an
//      mlx_vjp of `segment_forward(boundary_k, ...LoRA)` with the cotangent dh_out
//      returns [dh_in, ...dLoRA_segment]: dh_in seeds segment k-1, the LoRA grads
//      scatter into the global flat grad vector. Only segment k's activations are
//      live. (A vjp is exactly reverse-mode AD: vjps = (df/dx)^T (.) dh.)
//
// Why mlx_vjp and not a surrogate-loss value_and_grad: the equivalent
// `value_and_grad(sum(stop_grad(dh) (.) segment_forward(...)))` is numerically
// identical but LEAKS ~one activation buffer per segment per step at the mlx
// level (measured; not GC/cache/synchronize/reuse reclaimable — see
// docs/design/segmented-backward-training.md §9.4). mlx_vjp takes the cotangent
// directly, needs no surrogate, and does not leak.
//
// IMPORTANT lifetime fact: mlx `eval` does NOT detach — an eval'd array retains
// its upstream graph, so each forward boundary must be copied into a fresh leaf
// (detachLeaf) or it keeps a whole layer-stack's activations alive (~0.1 GB per
// 4-layer segment of within-step retention otherwise). The vjp objects are built
// ONCE and reused across steps; their closures read the per-step batch from a
// mutable holder.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { Vjp } from "../mlx/autograd";
import { MiniCPM5Model, setMiniCpmPrefixPlan } from "../model/minicpm5";
import type { Gemma4Model } from "../model/gemma4";
import { setGemmaPrefixPlan } from "../model/gemma4";
import type { Cache, Mask, SharedKv } from "../model/gemma4-base";
import { TrainingCache } from "./forward";
import {
  responseOnlyCe, responseOnlyLogpMean, fusedLogpMeanFromHidden, chunkedLogpMeanFromHidden,
  orpoLossFromLogps, spanLogpMeanFromHidden, respSpanFromMask, combineFullNll,
  type ChunkCtx, type SftScope, type HeadSpan,
} from "./loss";
import { PrefixSharedCache, prefixGatherIdx, branchLogpMeanGathered, blockSparsePrefixMaskGemma, prefixFullNll } from "./prefix-shared";

// Experiment toggle: which bounded head to use inside the segmented mlx_vjp.
// "checkpoint" = per-chunk Checkpoint recompute (bounds memory under nesting);
// anything else (default) = the analytic fused CustomVjp. The fused head bounds
// memory at the TOP level but not when nested in the segmented mlx_vjp (its
// per-chunk graph isn't freed incrementally there); Checkpoint does. See
// docs/design/orpo-training.md.
const SEG_HEAD = process.env.MLX_BUN_SEG_HEAD ?? "checkpoint";
function boundedHeadFromHidden(
  model: MiniCPM5Model | Gemma4Model, h: MlxArray, ids: number[], mask: number[],
  chunkSize: number, sink: Array<{ dispose(): void }>, span?: HeadSpan,
): MlxArray {
  return SEG_HEAD === "fused"
    ? fusedLogpMeanFromHidden(model, h, ids, mask, chunkSize, sink, 0, false, span)
    : chunkedLogpMeanFromHidden(model, h, ids, mask, chunkSize, sink, span);
}
import type { TrainableLora } from "./lora-params";
import { type SftBatch, type DpoBatch } from "./dataset";

/** Split `nLayers` into contiguous `[lo, hi)` ranges of at most `segSize`
 *  layers each (the last range may be shorter). `segSize` is the memory knob:
 *  fewer layers per segment -> lower peak, ~fixed total recompute time. */
export function planSegmentsBySize(nLayers: number, segSize: number): [number, number][] {
  if (segSize < 1) throw new Error(`planSegmentsBySize: segSize must be >= 1 (got ${segSize})`);
  const ranges: [number, number][] = [];
  for (let lo = 0; lo < nLayers; lo += segSize) ranges.push([lo, Math.min(lo + segSize, nLayers)]);
  return ranges;
}

/** Detach `a` into a graph-free LEAF holding its exact (evaluated) bytes, then
 *  dispose `a`. mlx retains the upstream graph after `eval`, so a segment
 *  boundary (or a value_and_grad output) would otherwise keep its whole layer
 *  stack's activations alive. Copying the bytes into a fresh leaf frees that
 *  graph. The leaf is a valid differentiable input for the per-segment vag. */
function detachLeaf(a: MlxArray): MlxArray {
  // Force a row-major copy first: `rawBytes` reads the underlying buffer
  // linearly, so a NON-contiguous input (e.g. a transposed donor K/V view) would
  // be byte-scrambled. `ops.contiguous` is a no-op for already-contiguous arrays
  // (hidden boundaries) and materializes row-major for strided views.
  const c = ops.contiguous(a);
  c.eval();
  const leaf = MlxArray.fromBytesCopy(c.rawBytes(), c.shape, c.dtype);
  c.dispose();
  a.dispose();
  return leaf;
}

/** Layer index a target's modulePath belongs to, or -1 (e.g. embedding/head). */
function targetLayer(modulePath: string): number {
  const m = modulePath.match(/\.layers\.(\d+)\./);
  return m ? Number(m[1]) : -1;
}

/** Reusable segmented-backward driver for one (model, lora, segmentation). Build
 *  ONCE per training run and call `.step(batch)` each iteration — the per-segment
 *  value_and_grads are created up front and reused (rebuilding them every step
 *  leaks at the mlx level). Returns the loss scalar and the LoRA gradients in
 *  `flatParams(lora)` order ([...A, ...B] over targets), drop-in for
 *  `ValueAndGrad.apply(flatParams(lora))`. Caller owns the returned arrays.
 *
 *  The active adapter must be attached (attachForTraining) so the layer forward
 *  picks up the swapped LoRA leaves via loraState. B=1 SFT only. */
export class SegmentedBackward {
  private readonly nLayers: number;
  private readonly n: number; // number of LoRA targets
  private readonly segIdxs: number[][]; // target indices per segment
  private readonly caches: Cache[];
  private readonly headVjp: Vjp;
  private readonly segVjps: Vjp[];
  private readonly one: MlxArray; // scalar cotangent 1.0 for the (scalar) head loss
  // Per-step context the (reused) closures read.
  private curBatch: SftBatch | null = null;
  private disposed = false;

  constructor(
    private readonly model: MiniCPM5Model,
    private readonly lora: TrainableLora,
    private readonly ranges: [number, number][],
  ) {
    this.nLayers = model.layers.length;
    const lastHi = ranges[ranges.length - 1]?.[1] ?? 0;
    if (ranges[0]?.[0] !== 0 || lastHi !== this.nLayers)
      throw new Error(`SegmentedBackward: ranges must cover [0, ${this.nLayers}) (got ${JSON.stringify(ranges)})`);

    this.n = lora.targets.length;
    const layerOf = lora.targets.map((t) => targetLayer(t.modulePath));
    this.segIdxs = ranges.map(([lo, hi]) =>
      layerOf.map((li, j) => ({ li, j })).filter((x) => x.li >= lo && x.li < hi).map((x) => x.j),
    );
    this.caches = Array.from({ length: this.nLayers }, () => new TrainingCache());
    this.one = MlxArray.fromFloat32(new Float32Array([1]), []); // d(loss)/d(loss) = 1

    // Loss head: vjp of finalNorm + responseOnlyCe over the last boundary leaf.
    // outputs[0] = loss scalar; vjps[0] = dLoss/d(last residual stream) = dh.
    this.headVjp = new Vjp((p) => {
      const hn = model.finalNorm.forward(p[0]!);
      const loss = responseOnlyCe(model, hn, this.curBatch!);
      hn.dispose();
      return [loss];
    }, 1);

    // One reused vjp per segment over [boundary, ...segment LoRA] -> [output].
    // apply(..., [dh]) returns vjps [dh_in, dA_0, dB_0, ...].
    this.segVjps = ranges.map(([lo, hi], k) => {
      const idxs = this.segIdxs[k]!;
      return new Vjp((p) => {
        // Swap this segment's LoRA primals into the live LoraWeights so the
        // forward graph differentiates them; restore the originals after (the
        // primal wrappers are disposed by the vjp closure).
        const saved: [MlxArray, MlxArray][] = idxs.map((j) => [lora.targets[j]!.lw.a, lora.targets[j]!.lw.b]);
        idxs.forEach((j, s) => {
          lora.targets[j]!.lw.a = p[1 + 2 * s]!;
          lora.targets[j]!.lw.b = p[1 + 2 * s + 1]!;
        });
        try {
          return [model.runLayerRange(p[0]!, lo, hi, this.caches)];
        } finally {
          idxs.forEach((j, s) => {
            lora.targets[j]!.lw.a = saved[s]![0];
            lora.targets[j]!.lw.b = saved[s]![1];
          });
        }
      }, 1);
    });
  }

  step(batch: SftBatch): { value: MlxArray; grads: MlxArray[] } {
    if (this.disposed) throw new Error("SegmentedBackward used after dispose");
    const { model, lora, ranges, caches, segIdxs, n } = this;
    const B = batch.ids.length;
    if (B !== 1) throw new Error("SegmentedBackward: only B=1 is supported (responseOnlyCe path)");
    const L = batch.ids[0]!.length;
    if (L < 2) throw new Error("SegmentedBackward: sequence too short (need >= 2 tokens)");
    this.curBatch = batch;

    const nSeg = ranges.length;
    const T = L - 1;
    const inputHost = new Int32Array(T);
    for (let t = 0; t < T; t++) inputHost[t] = batch.ids[0]![t]!;
    const inputIds = MlxArray.fromInt32(inputHost, [1, T]);

    const boundaries: (MlxArray | null)[] = [];
    let value: MlxArray | null = null;
    let dhOut: MlxArray | null = null;
    let transferred = false;
    const grads: (MlxArray | null)[] = new Array(2 * n).fill(null);

    try {
      // --- 1. Forward, saving detached boundaries at segment edges. --------
      boundaries.push(detachLeaf(model.embed.encode(inputIds))); // [1, T, hidden]
      for (let k = 0; k < nSeg; k++) {
        const [lo, hi] = ranges[k]!;
        boundaries.push(detachLeaf(model.runLayerRange(boundaries[k]!, lo, hi, caches)));
      }

      // --- 2. Loss head over the last boundary (vjp with cotangent 1.0). ---
      const head = this.headVjp.apply([boundaries[nSeg]!], [this.one]);
      value = detachLeaf(head.outputs[0]!); // scalar loss, detached from the head graph (frees logits)
      dhOut = detachLeaf(head.vjps[0]!); // dLoss / d(last residual stream), graph-free
      boundaries[nSeg]!.dispose();
      boundaries[nSeg] = null;

      // --- 3. Backward, reverse over segments (vjp, cotangent = dh). --------
      for (let k = nSeg - 1; k >= 0; k--) {
        const idxs = segIdxs[k]!;
        const params: MlxArray[] = [boundaries[k]!];
        for (const j of idxs) params.push(lora.targets[j]!.lw.a, lora.targets[j]!.lw.b);

        const res = this.segVjps[k]!.apply(params, [dhOut!]);
        res.outputs[0]!.dispose(); // segment output — unused (only its vjp matters)
        // vjps[0] = dh_in (grad w.r.t. this segment's input boundary) -> dh_out
        // for segment k-1; the rest scatter into the global flat vector. Detach
        // each to a graph-free leaf (eval doesn't detach; keeps peak bounded).
        idxs.forEach((j, s) => {
          grads[j] = detachLeaf(res.vjps[1 + 2 * s]!); // dA
          grads[n + j] = detachLeaf(res.vjps[1 + 2 * s + 1]!); // dB
        });
        dhOut!.dispose(); // consumed as this segment's cotangent
        dhOut = detachLeaf(res.vjps[0]!);
        boundaries[k]!.dispose();
        boundaries[k] = null;
      }

      // Segment-0 dh_in is the gradient w.r.t. the embedding output — MiniCPM5's
      // embedding carries no LoRA, so it is discarded (disposed in finally).
      transferred = true;
      return { value: value!, grads: grads as MlxArray[] };
    } finally {
      inputIds.dispose();
      this.curBatch = null;
      dhOut?.dispose();
      for (const b of boundaries) b?.dispose();
      if (!transferred) {
        value?.dispose();
        for (const g of grads) g?.dispose();
      }
    }
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    this.headVjp.dispose();
    for (const v of this.segVjps) v.dispose();
    for (const c of this.caches) c.dispose();
    this.one.dispose();
  }
}

// ===========================================================================
// e4b (Gemma4Model): segmented backward with KV-shared donor threading.
// ===========================================================================
//
// Same skeleton as SegmentedBackward (forward boundaries -> head vjp -> reverse
// per-segment vjp), with the two e4b-specific pieces (docs §10):
//
//  - per-layer-input is a PURE CONSTANT boundary: the per_layer_input_gate /
//    per_layer_projection LoRA live inside the layer (differentiated normally
//    within each segment); the [B,L,nLayers,width] tensor feeds in as a
//    constant (its grad would flow to the embed / per_layer_model_projection,
//    neither a LoRA target) — detached once, sliced per segment, cotangent
//    discarded.
//
//  - the KV-shared donor K/V is a SECOND boundary stream WITH its own cotangent.
//    A reused donor d (e4b: 22 sliding, 23 full) is PRODUCED by the segment
//    containing d (saved as a detached boundary) and CONSUMED by later segments
//    whose sharers reuse it. In the backward, a consumer segment's vjp yields a
//    cotangent on the donor K/V (accumulated into dKV[d]); the producer segment
//    has a MULTI-OUTPUT forward [h, donorK, donorV] whose vjp takes cotangents
//    [dh, dKV[d].k, dKV[d].v] — folding the sharers' gradient into the donor.

type KvPair = { keys: MlxArray; values: MlxArray };

export class SegmentedBackwardGemma4 {
  private readonly nLayers: number;
  private readonly n: number;
  private readonly segIdxs: number[][];
  private readonly consumes: number[][]; // reused donors consumed as input, per segment
  private readonly produces: number[][]; // reused donors output for later segments, per segment
  private readonly caches: Cache[];
  private readonly headVjp: Vjp;
  private readonly segVjps: Vjp[];
  private readonly one: MlxArray;
  // Per-step constants the (reused) closures read.
  private curBatch: SftBatch | null = null;
  private curMasks: Map<string, Mask> | null = null;
  private curPerLayer: MlxArray | null = null;
  private disposed = false;

  constructor(
    private readonly model: Gemma4Model,
    private readonly lora: TrainableLora,
    private readonly ranges: [number, number][],
  ) {
    this.nLayers = model.layers.length;
    const lastHi = ranges[ranges.length - 1]?.[1] ?? 0;
    if (ranges[0]?.[0] !== 0 || lastHi !== this.nLayers)
      throw new Error(`SegmentedBackwardGemma4: ranges must cover [0, ${this.nLayers})`);
    this.n = lora.targets.length;

    const layerOf = lora.targets.map((t) => targetLayer(t.modulePath));
    this.segIdxs = ranges.map(([lo, hi]) =>
      layerOf.map((li, j) => ({ li, j })).filter((x) => x.li >= lo && x.li < hi).map((x) => x.j),
    );

    // Donor/sharer KV threading: for each reused donor d, the segment that holds
    // d PRODUCES its K/V; a later segment with a sharer of d CONSUMES it.
    const segOfLayer = new Map<number, number>();
    ranges.forEach(([lo, hi], k) => { for (let i = lo; i < hi; i++) segOfLayer.set(i, k); });
    const reused = model.reusedDonors;
    const producerSeg = new Map<number, number>();
    for (const d of reused) producerSeg.set(d, segOfLayer.get(d)!);
    this.consumes = ranges.map(() => []);
    this.produces = ranges.map(() => []);
    for (let i = 0; i < this.nLayers; i++) {
      if (model.cacheIndex[i] !== -1) continue; // donors don't consume
      const d = model.previousKvs[i]!; // this sharer's donor (a reused donor)
      const sSeg = segOfLayer.get(i)!;
      const pSeg = producerSeg.get(d)!;
      if (sSeg > pSeg) { // cross-segment: thread d's K/V from pSeg to sSeg
        if (!this.consumes[sSeg]!.includes(d)) this.consumes[sSeg]!.push(d);
        if (!this.produces[pSeg]!.includes(d)) this.produces[pSeg]!.push(d);
      }
      // sSeg === pSeg: runLayerRange threads d internally; no boundary needed.
    }

    this.caches = Array.from({ length: model.numDonors }, () => new TrainingCache());
    this.one = MlxArray.fromFloat32(new Float32Array([1]), []);

    // Loss head (identical to MiniCPM5): finalNorm + responseOnlyCe over the last
    // boundary, vjp with cotangent 1.0 -> [loss], [dh].
    this.headVjp = new Vjp((p) => {
      const hn = model.finalNorm.forward(p[0]!);
      const loss = responseOnlyCe(model, hn, this.curBatch!);
      hn.dispose();
      return [loss];
    }, 1);

    // One reused vjp per segment. Inputs: [boundary, (k,v)*consumes, (a,b)*lora].
    // Outputs: [h, (k,v)*produces]. The closures read curMasks/curPerLayer.
    this.segVjps = ranges.map(([lo, hi], k) => {
      const idxs = this.segIdxs[k]!;
      const cons = this.consumes[k]!;
      const prod = this.produces[k]!;
      const base = 1 + 2 * cons.length; // first LoRA primal index
      const nOut = 1 + 2 * prod.length;
      const vjp = new Vjp((p) => {
        const boundary = p[0]!;
        const kvIn = new Map<number, SharedKv>();
        cons.forEach((d, ci) => kvIn.set(d, { kind: "plain", keys: p[1 + 2 * ci]!, values: p[1 + 2 * ci + 1]!, offset: 0 }));
        const saved: [MlxArray, MlxArray][] = idxs.map((j) => [lora.targets[j]!.lw.a, lora.targets[j]!.lw.b]);
        idxs.forEach((j, s) => {
          lora.targets[j]!.lw.a = p[base + 2 * s]!;
          lora.targets[j]!.lw.b = p[base + 2 * s + 1]!;
        });
        try {
          const { h, donorKvOut } = model.runLayerRange(
            boundary, lo, hi, this.caches, this.curMasks!, this.curPerLayer, kvIn,
          );
          const outs: MlxArray[] = [h];
          for (const d of prod) {
            const kv = donorKvOut.get(d)!;
            if (kv.kind !== "plain") throw new Error("segmented e4b: quantized donor KV unsupported in training");
            // Output the CONTIGUOUS donor K/V: the consumer segments received a
            // contiguous (detachLeaf'd) copy, so their accumulated cotangent dKV
            // is row-major. The producer's raw K/V are transposed views; matching
            // layouts keeps the vjp's cotangent indexing consistent.
            const ck = ops.contiguous(kv.keys), cv = ops.contiguous(kv.values);
            kv.keys.dispose(); kv.values.dispose();
            outs.push(ck, cv);
          }
          // in-segment-only reused donors (produced but not threaded forward) — free.
          for (const [d, kv] of donorKvOut)
            if (!prod.includes(d) && kv.kind === "plain") { kv.keys.dispose(); kv.values.dispose(); }
          return outs;
        } finally {
          idxs.forEach((j, s) => { lora.targets[j]!.lw.a = saved[s]![0]; lora.targets[j]!.lw.b = saved[s]![1]; });
        }
      }, nOut);
      return vjp;
    });
  }

  step(batch: SftBatch): { value: MlxArray; grads: MlxArray[] } {
    if (this.disposed) throw new Error("SegmentedBackwardGemma4 used after dispose");
    const { model, lora, ranges, caches, segIdxs, consumes, produces, n } = this;
    const B = batch.ids.length;
    if (B !== 1) throw new Error("SegmentedBackwardGemma4: only B=1 is supported");
    const L = batch.ids[0]!.length;
    if (L < 2) throw new Error("SegmentedBackwardGemma4: sequence too short");
    this.curBatch = batch;

    const nSeg = ranges.length;
    const T = L - 1;
    const inputHost = new Int32Array(T);
    for (let t = 0; t < T; t++) inputHost[t] = batch.ids[0]![t]!;
    const inputIds = MlxArray.fromInt32(inputHost, [1, T]);

    const boundaries: (MlxArray | null)[] = [];
    const donorBnd = new Map<number, KvPair>(); // detached reused-donor K/V boundaries
    const dKV = new Map<number, KvPair>(); // accumulated reused-donor cotangents
    let value: MlxArray | null = null;
    let dhOut: MlxArray | null = null;
    let transferred = false;
    const grads: (MlxArray | null)[] = new Array(2 * n).fill(null);

    try {
      // --- 1. Forward, saving detached boundaries (hidden + reused donor K/V). ---
      const { hScaled, perLayer } = model.embedForSegmented(inputIds);
      boundaries.push(detachLeaf(hScaled));
      this.curPerLayer = perLayer ? detachLeaf(perLayer) : null;
      this.curMasks = model.makeTrainingMasks(caches, T);

      for (let k = 0; k < nSeg; k++) {
        const [lo, hi] = ranges[k]!;
        const kvIn = new Map<number, SharedKv>();
        for (const d of consumes[k]!) {
          const b = donorBnd.get(d)!;
          kvIn.set(d, { kind: "plain", keys: b.keys, values: b.values, offset: 0 });
        }
        const { h, donorKvOut } = model.runLayerRange(boundaries[k]!, lo, hi, caches, this.curMasks, this.curPerLayer, kvIn);
        for (const d of produces[k]!) {
          const kv = donorKvOut.get(d)!;
          if (kv.kind !== "plain") throw new Error("segmented e4b: quantized donor KV unsupported in training");
          donorBnd.set(d, { keys: detachLeaf(kv.keys), values: detachLeaf(kv.values) });
        }
        for (const [d, kv] of donorKvOut)
          if (!produces[k]!.includes(d) && kv.kind === "plain") { kv.keys.dispose(); kv.values.dispose(); }
        boundaries.push(detachLeaf(h));
      }

      // --- 2. Loss head (vjp, cotangent 1.0). ---
      const head = this.headVjp.apply([boundaries[nSeg]!], [this.one]);
      value = detachLeaf(head.outputs[0]!);
      dhOut = detachLeaf(head.vjps[0]!);
      boundaries[nSeg]!.dispose();
      boundaries[nSeg] = null;

      // --- 3. Backward, reverse over segments (vjp, cotangents dh + dKV). ---
      for (let k = nSeg - 1; k >= 0; k--) {
        const idxs = segIdxs[k]!;
        const cons = consumes[k]!;
        const prod = produces[k]!;
        const dh = dhOut!;

        const primals: MlxArray[] = [boundaries[k]!];
        for (const d of cons) { const b = donorBnd.get(d)!; primals.push(b.keys, b.values); }
        for (const j of idxs) primals.push(lora.targets[j]!.lw.a, lora.targets[j]!.lw.b);

        const cots: MlxArray[] = [dh];
        for (const d of prod) {
          const acc = dKV.get(d)!; // set by the consumer segments already processed (reverse order)
          cots.push(acc.keys, acc.values);
        }

        const res = this.segVjps[k]!.apply(primals, cots);
        for (const o of res.outputs) o.dispose();

        // vjps[0] = dh_in; then (dk,dv) per consumed donor; then (da,db) per LoRA.
        const newDh = detachLeaf(res.vjps[0]!);
        cons.forEach((d, ci) => {
          const dk = detachLeaf(res.vjps[1 + 2 * ci]!);
          const dv = detachLeaf(res.vjps[1 + 2 * ci + 1]!);
          this.accumulateDKV(dKV, d, dk, dv);
        });
        const base = 1 + 2 * cons.length;
        idxs.forEach((j, s) => {
          grads[j] = detachLeaf(res.vjps[base + 2 * s]!);
          grads[n + j] = detachLeaf(res.vjps[base + 2 * s + 1]!);
        });

        dh.dispose();
        dhOut = newDh;
        // produced donors' cotangents are now consumed -> free them + their boundary.
        for (const d of prod) {
          const acc = dKV.get(d)!; acc.keys.dispose(); acc.values.dispose(); dKV.delete(d);
          const b = donorBnd.get(d)!; b.keys.dispose(); b.values.dispose(); donorBnd.delete(d);
        }
        boundaries[k]!.dispose();
        boundaries[k] = null;
      }

      transferred = true;
      return { value: value!, grads: grads as MlxArray[] };
    } finally {
      inputIds.dispose();
      this.curBatch = null;
      this.curPerLayer?.dispose();
      this.curPerLayer = null;
      if (this.curMasks) { for (const m of this.curMasks.values()) m.arr?.dispose(); this.curMasks = null; }
      dhOut?.dispose();
      for (const b of boundaries) b?.dispose();
      for (const kv of donorBnd.values()) { kv.keys.dispose(); kv.values.dispose(); }
      for (const kv of dKV.values()) { kv.keys.dispose(); kv.values.dispose(); }
      if (!transferred) {
        value?.dispose();
        for (const g of grads) g?.dispose();
      }
    }
  }

  /** Accumulate a reused-donor K/V cotangent (sum across consuming segments) in
   *  bf16. The donor K/V grad ends up ~0.5-1% (relNorm) off the full backward —
   *  bf16 NON-ASSOCIATIVITY, established (not a logic bug), via:
   *    - single-consumer reuse is BIT-EXACT (no sum to reorder);
   *    - the error is flat in consumer-SEGMENT count and tracks SUMMAND count
   *      (donor 22's 15 sharers ≈0.46%, donor 23's 3 sharers ≈0.000%);
   *    - it is grouping-DEPENDENT (donor-22 grad moves ~0.5% from a 2- vs
   *      9-consumer split) for BOTH bf16 AND fp32 accumulation.
   *  fp32 cross-segment accumulation does NOT fix it (it's identical at the
   *  natural cut and marginally worse at fine cuts): the dominant term is mlx's
   *  WITHIN-vjp bf16 cotangent sum per consumer, which regrouping the sharers
   *  changes — unfixable without an fp32 forward. bf16-class, fine for training.
   *  `dk`/`dv` are detached bf16 leaves; the sum is re-detached. */
  private accumulateDKV(dKV: Map<number, KvPair>, d: number, dk: MlxArray, dv: MlxArray): void {
    const prev = dKV.get(d);
    if (!prev) { dKV.set(d, { keys: dk, values: dv }); return; }
    const sk = detachLeaf(ops.add(prev.keys, dk));
    const sv = detachLeaf(ops.add(prev.values, dv));
    prev.keys.dispose(); prev.values.dispose(); dk.dispose(); dv.dispose();
    dKV.set(d, { keys: sk, values: sv });
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    this.headVjp.dispose();
    for (const v of this.segVjps) v.dispose();
    for (const c of this.caches) c.dispose();
    this.one.dispose();
  }
}

// ===========================================================================
// SegmentedBackwardOrpo: segmented backward for ORPO (MiniCPM5 only, B=1).
// ===========================================================================
//
// Same skeleton as SegmentedBackward, but operates over TWO sequences
// (chosen + rejected) per step, accumulating LoRA gradients from both branches.
// Memory profile: TWO sets of boundary buffers ([1,T,hidden] per segment edge)
// are live during the forward phase; only one segment's activations are live per
// backward sub-step (one branch at a time). Grads from chosen and rejected are
// summed per parameter before being returned.
//
// The head VJP takes [h_chosen_last, h_rejected_last] → [loss scalar].
// Its cotangents [dh_chosen, dh_rejected] seed the two backward passes separately.

/** Segmented backward for ORPO (MiniCPM5 only, B=1). Runs chosen+rejected forwards
 *  segment-by-segment, accumulating LoRA gradients from both branches. */
export class SegmentedBackwardOrpo {
  private readonly nLayers: number;
  private readonly n: number;
  private readonly segIdxs: number[][];
  private readonly caches: Cache[];
  private readonly headVjp: Vjp;
  private readonly segVjps: Vjp[];
  private readonly one: MlxArray;
  // Per-step mutable context
  private curChosenIds: number[] | null = null;
  private curChosenMask: number[] | null = null;
  private curRejectedIds: number[] | null = null;
  private curRejectedMask: number[] | null = null;
  private disposed = false;

  // When > 0, the loss head runs the FUSED linear-CE path (fusedLogpMeanFromHidden:
  // token-chunked analytic CustomVjp) instead of the full-[M,V] responseOnlyLogpMean
  // — so the head term is bounded to [chunk,V] INSIDE the segmented backward,
  // compounding with the per-segment layer savings (ORPO pressure = layers +
  // response length + head). Per-step disposables (the CustomVjps + response slices)
  // live in headSink, disposed after the head vjp is eval'd.
  private headSink: Array<{ dispose(): void }> = [];

  constructor(
    private readonly model: MiniCPM5Model,
    private readonly lora: TrainableLora,
    private readonly ranges: [number, number][],
    private readonly lambda: number,
    private readonly fusedChunkSize = 0,
    private readonly sftScope: SftScope = "response",
  ) {
    this.nLayers = model.layers.length;
    const lastHi = ranges[ranges.length - 1]?.[1] ?? 0;
    if (ranges[0]?.[0] !== 0 || lastHi !== this.nLayers)
      throw new Error(`SegmentedBackwardOrpo: ranges must cover [0, ${this.nLayers})`);
    this.n = lora.targets.length;
    const layerOf = lora.targets.map((t) => targetLayer(t.modulePath));
    this.segIdxs = ranges.map(([lo, hi]) =>
      layerOf.map((li, j) => ({ li, j })).filter((x) => x.li >= lo && x.li < hi).map((x) => x.j),
    );
    this.caches = Array.from({ length: this.nLayers }, () => new TrainingCache());
    this.one = MlxArray.fromFloat32(new Float32Array([1]), []);

    // Head VJP: inputs = [h_chosen_last, h_rejected_last] (pre-finalNorm at last boundary).
    // Applies finalNorm to each, computes ℓw and ℓr, returns scalar orpo loss.
    // nOut = 1 (one scalar loss output, one cotangent needed from caller).
    // apply([hC, hR], [one]) returns vjps[0] = dh_chosen, vjps[1] = dh_rejected.
    this.headVjp = new Vjp((p) => {
      const hnC = model.finalNorm.forward(p[0]!);  // [1, T, hidden]
      const hnR = model.finalNorm.forward(p[1]!);
      const cs = this.fusedChunkSize;
      const lw = cs > 0 // [1]
        ? boundedHeadFromHidden(model, hnC, this.curChosenIds!, this.curChosenMask!, cs, this.headSink)
        : responseOnlyLogpMean(model, hnC, this.curChosenIds!, this.curChosenMask!);
      const lr = cs > 0 // [1]
        ? boundedHeadFromHidden(model, hnR, this.curRejectedIds!, this.curRejectedMask!, cs, this.headSink)
        : responseOnlyLogpMean(model, hnR, this.curRejectedIds!, this.curRejectedMask!);
      // sft_scope:"full": the chosen head additionally runs over the PROMPT span
      // [0, startT) of the SAME hnC (same tier: bounded or whole-vocab), and the
      // full-scope chosen NLL replaces mean(-ℓw). The prompt-position gradient
      // rides into this vjp's dh_chosen automatically (the loss graph includes
      // the prompt-span head). ℓw/ℓr stay response-only for the odds ratio.
      let nllFull: MlxArray | null = null;
      if (this.sftScope === "full") {
        const { startT, M } = respSpanFromMask(this.curChosenMask!, this.curChosenIds!.length - 1);
        let pm: MlxArray | null = null;
        if (M > 0 && startT > 0)
          pm = cs > 0
            ? boundedHeadFromHidden(model, hnC, this.curChosenIds!, this.curChosenMask!, cs, this.headSink, { startT: 0, M: startT })
            : spanLogpMeanFromHidden(model, hnC, this.curChosenIds!, 0, startT);
        nllFull = combineFullNll(pm, lw, M > 0 ? startT : 0, M);
        pm?.dispose();
      }
      hnC.dispose(); hnR.dispose();
      const loss = orpoLossFromLogps(lw, lr, this.lambda, nllFull ?? undefined);
      lw.dispose(); lr.dispose();
      nllFull?.dispose();
      return [loss];
    }, 1);

    // One reused vjp per segment — same as SegmentedBackward; reused across both branches.
    this.segVjps = ranges.map(([lo, hi], k) => {
      const idxs = this.segIdxs[k]!;
      return new Vjp((p) => {
        const saved: [MlxArray, MlxArray][] = idxs.map((j) => [lora.targets[j]!.lw.a, lora.targets[j]!.lw.b]);
        idxs.forEach((j, s) => { lora.targets[j]!.lw.a = p[1 + 2 * s]!; lora.targets[j]!.lw.b = p[1 + 2 * s + 1]!; });
        try {
          return [model.runLayerRange(p[0]!, lo, hi, this.caches)];
        } finally {
          idxs.forEach((j, s) => { lora.targets[j]!.lw.a = saved[s]![0]; lora.targets[j]!.lw.b = saved[s]![1]; });
        }
      }, 1);
    });
  }

  step(batch: DpoBatch): { value: MlxArray; grads: MlxArray[] } {
    if (this.disposed) throw new Error("SegmentedBackwardOrpo used after dispose");
    const { model, lora, ranges, caches, segIdxs, n } = this;
    if (batch.chosenIds.length !== 1) throw new Error("SegmentedBackwardOrpo: only B=1 is supported");
    // Store per-step batch for the head VJP closure
    this.curChosenIds = batch.chosenIds[0]!;
    this.curChosenMask = batch.chosenMask[0]!;
    this.curRejectedIds = batch.rejectedIds[0]!;
    this.curRejectedMask = batch.rejectedMask[0]!;

    const Lc = batch.chosenIds[0]!.length;
    const Lr = batch.rejectedIds[0]!.length;
    if (Lc < 2 || Lr < 2) throw new Error("SegmentedBackwardOrpo: sequences too short");
    const nSeg = ranges.length;
    const gradsC: (MlxArray | null)[] = new Array(2 * n).fill(null);
    const gradsR: (MlxArray | null)[] = new Array(2 * n).fill(null);
    const bndC: (MlxArray | null)[] = [];
    const bndR: (MlxArray | null)[] = [];
    let value: MlxArray | null = null;
    let dhC: MlxArray | null = null;
    let dhR: MlxArray | null = null;
    let transferred = false;

    try {
      // --- 1. Forward chosen ---
      const Tc = Lc - 1;
      const chosenInput = new Int32Array(Tc);
      for (let t = 0; t < Tc; t++) chosenInput[t] = batch.chosenIds[0]![t]!;
      const chosenIds = MlxArray.fromInt32(chosenInput, [1, Tc]);
      bndC.push(detachLeaf(model.embed.encode(chosenIds)));
      chosenIds.dispose();
      for (let k = 0; k < nSeg; k++) {
        const [lo, hi] = ranges[k]!;
        bndC.push(detachLeaf(model.runLayerRange(bndC[k]!, lo, hi, caches)));
      }

      // --- 2. Forward rejected ---
      const Tr = Lr - 1;
      const rejInput = new Int32Array(Tr);
      for (let t = 0; t < Tr; t++) rejInput[t] = batch.rejectedIds[0]![t]!;
      const rejIds = MlxArray.fromInt32(rejInput, [1, Tr]);
      bndR.push(detachLeaf(model.embed.encode(rejIds)));
      rejIds.dispose();
      for (let k = 0; k < nSeg; k++) {
        const [lo, hi] = ranges[k]!;
        bndR.push(detachLeaf(model.runLayerRange(bndR[k]!, lo, hi, caches)));
      }

      // --- 3. Head VJP: [last_chosen, last_rejected] → [loss], cotangent 1.0 → [dh_c, dh_r] ---
      // The fused head pushes per-step CustomVjps + response slices into headSink;
      // they recompute during this apply's backward, so dispose only AFTER the
      // outputs/vjps are detached to leaves (which forces the eval).
      this.headSink = [];
      const head = this.headVjp.apply([bndC[nSeg]!, bndR[nSeg]!], [this.one]);
      // Materialize the full head-VJP graph (incl. the nested CustomVjp backward that
      // reads savedLse/savedBlockMax) BEFORE freeing headSink — avoids the lazy-eval
      // use-after-free segfault (see the segmented-prefix crash diagnosis).
      ops.evalAll([head.outputs[0]!, head.vjps[0]!, head.vjps[1]!]);
      value = detachLeaf(head.outputs[0]!);
      dhC = detachLeaf(head.vjps[0]!);
      dhR = detachLeaf(head.vjps[1]!);
      for (const d of this.headSink) d.dispose();
      this.headSink = [];
      bndC[nSeg]!.dispose(); bndC[nSeg] = null;
      bndR[nSeg]!.dispose(); bndR[nSeg] = null;

      // --- 4. Backward chosen ---
      for (let k = nSeg - 1; k >= 0; k--) {
        const idxs = segIdxs[k]!;
        const params: MlxArray[] = [bndC[k]!];
        for (const j of idxs) params.push(lora.targets[j]!.lw.a, lora.targets[j]!.lw.b);
        const res = this.segVjps[k]!.apply(params, [dhC!]);
        res.outputs[0]!.dispose();
        idxs.forEach((j, s) => {
          gradsC[j] = detachLeaf(res.vjps[1 + 2 * s]!); // dA
          gradsC[n + j] = detachLeaf(res.vjps[1 + 2 * s + 1]!); // dB
        });
        dhC!.dispose();
        dhC = detachLeaf(res.vjps[0]!);
        bndC[k]!.dispose(); bndC[k] = null;
      }
      dhC!.dispose(); dhC = null; // embedding grad, discarded (no LoRA on embed)

      // --- 5. Backward rejected ---
      for (let k = nSeg - 1; k >= 0; k--) {
        const idxs = segIdxs[k]!;
        const params: MlxArray[] = [bndR[k]!];
        for (const j of idxs) params.push(lora.targets[j]!.lw.a, lora.targets[j]!.lw.b);
        const res = this.segVjps[k]!.apply(params, [dhR!]);
        res.outputs[0]!.dispose();
        idxs.forEach((j, s) => {
          gradsR[j] = detachLeaf(res.vjps[1 + 2 * s]!); // dA
          gradsR[n + j] = detachLeaf(res.vjps[1 + 2 * s + 1]!); // dB
        });
        dhR!.dispose();
        dhR = detachLeaf(res.vjps[0]!);
        bndR[k]!.dispose(); bndR[k] = null;
      }
      dhR!.dispose(); dhR = null; // embedding grad, discarded

      // --- 6. Sum LoRA grads from both branches ---
      const grads: MlxArray[] = gradsC.map((gc, i) => {
        const gr = gradsR[i]!;
        const sum = ops.add(gc!, gr);
        gc!.dispose(); gr.dispose();
        gradsC[i] = null; gradsR[i] = null;
        return detachLeaf(sum);
      });

      transferred = true;
      return { value: value!, grads };
    } finally {
      this.curChosenIds = this.curChosenMask = this.curRejectedIds = this.curRejectedMask = null;
      dhC?.dispose(); dhR?.dispose();
      for (const b of bndC) b?.dispose();
      for (const b of bndR) b?.dispose();
      if (!transferred) {
        value?.dispose();
        for (const g of gradsC) g?.dispose();
        for (const g of gradsR) g?.dispose();
      }
    }
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    this.headVjp.dispose();
    for (const v of this.segVjps) v.dispose();
    for (const c of this.caches) c.dispose();
    this.one.dispose();
  }
}

// ===========================================================================
// SegmentedBackwardOrpoPrefix: segmented backward + PREFIX-SHARING (MiniCPM5, B=1).
// ===========================================================================
//
// The composition of SegmentedBackwardOrpo (layer-streaming backward) with
// prefix-sharing (one forward over [prompt; chosen; rejected], block-sparse mask
// + block-wise RoPE). Instead of TWO separate sequences, this streams ONE concat
// sequence segment-by-segment, so the shared prompt is encoded exactly once even
// at long sequence length — the prefix-share saving now holds AT seq 8192.
//
// Differences from SegmentedBackwardOrpo:
//  - input = the single concat [prompt(P); chosen(Rc); rejected(Rr)] (T = P+Rc+Rr),
//    NOT two branches. One boundary stream, one backward walk.
//  - per-layer cache = PrefixSharedCache (its makeMask returns the block-sparse
//    mask: chosen & rejected each attend the prompt but NOT each other). Flows
//    through runLayerRange automatically (it calls cache[aIdx].makeMask).
//  - setMiniCpmPrefixPlan({P,Rc,Rr}) is ACTIVE for the whole step (set in step(),
//    cleared in finally) so block-wise RoPE rides through BOTH the streaming
//    forward AND every segment's recompute inside the per-segment vjp.
//  - the head gathers the chosen/rejected response hiddens from the final
//    [1,T,hidden] (via branchLogpMeanGathered — the same [M,V]-free per-branch
//    flash head the non-segmented prefix path uses) and ORPO-combines them. Its
//    vjp w.r.t. the last boundary is the full [1,T,hidden] dh (the gather's
//    takeAxis vjp scatter-adds each branch's response-position cotangent back
//    into the full sequence), which seeds the single segmented backward.

export class SegmentedBackwardOrpoPrefix {
  private readonly nLayers: number;
  private readonly n: number;
  private readonly segIdxs: number[][];
  private readonly headVjp: Vjp;
  private readonly segVjps: Vjp[];
  private readonly one: MlxArray;
  // Per-step mutable context the (reused) closures read.
  private curP = 0;
  private curRc = 0;
  private curRr = 0;
  private curPromptIds: number[] | null = null;
  private curChosenResp: number[] | null = null;
  private curRejectedResp: number[] | null = null;
  private curChunk: ChunkCtx | undefined = undefined;
  // Per-step prefix caches (rebuilt each step — they capture P/Rc/Rr). The seg
  // vjps read them via this.curCaches so makeMask returns the block-sparse mask.
  private curCaches: Cache[] = [];
  private headSink: Array<{ dispose(): void }> = [];
  private disposed = false;

  constructor(
    private readonly model: MiniCPM5Model,
    private readonly lora: TrainableLora,
    private readonly ranges: [number, number][],
    private readonly lambda: number,
    private readonly chunkCtx?: ChunkCtx,
    private readonly sftScope: SftScope = "response",
  ) {
    this.nLayers = model.layers.length;
    const lastHi = ranges[ranges.length - 1]?.[1] ?? 0;
    if (ranges[0]?.[0] !== 0 || lastHi !== this.nLayers)
      throw new Error(`SegmentedBackwardOrpoPrefix: ranges must cover [0, ${this.nLayers})`);
    this.n = lora.targets.length;
    const layerOf = lora.targets.map((t) => targetLayer(t.modulePath));
    this.segIdxs = ranges.map(([lo, hi]) =>
      layerOf.map((li, j) => ({ li, j })).filter((x) => x.li >= lo && x.li < hi).map((x) => x.j),
    );
    this.one = MlxArray.fromFloat32(new Float32Array([1]), []);

    // Head VJP: input = the last boundary [1, T, hidden] (pre-finalNorm). Applies
    // finalNorm, gathers each branch's response hiddens, computes ℓw/ℓr through the
    // [M,V]-free per-branch head (branchLogpMeanGathered), returns the scalar orpo
    // loss. nOut = 1; apply([h_last], [one]) returns vjps[0] = dh [1, T, hidden]
    // (the gather's takeAxis vjp scatter-adds the per-branch dh into the full seq).
    this.headVjp = new Vjp((p) => {
      const hn = model.finalNorm.forward(p[0]!); // [1, T, hidden]
      const { chosenIdx, rejectedIdx } = prefixGatherIdx(this.curP, this.curRc, this.curRr);
      const lw = branchLogpMeanGathered(model, hn, chosenIdx, this.curChosenResp!, this.curChunk);
      const lr = branchLogpMeanGathered(model, hn, rejectedIdx, this.curRejectedResp!, this.curChunk);
      // sft_scope:"full": prompt predictions (H[0..P-2] → prompt[1..P-1]) from the
      // same concat hiddens; the gather's takeAxis vjp scatter-adds the prompt
      // cotangent into dh alongside the responses'. ℓw/ℓr stay response-only.
      const nllFull = this.sftScope === "full"
        ? prefixFullNll(model, hn, this.curPromptIds!, lw, this.curRc, this.curChunk)
        : null;
      hn.dispose();
      const loss = orpoLossFromLogps(lw, lr, this.lambda, nllFull ?? undefined);
      lw.dispose(); lr.dispose();
      nllFull?.dispose();
      return [loss];
    }, 1);

    // One reused vjp per segment — same shape as SegmentedBackwardOrpo, but the
    // forward calls runLayerRange with the PREFIX caches (block-sparse mask). The
    // prefix RoPE plan is active for the whole step (set in step), so the recompute
    // here ropes block-wise too. (branchLogpMeanGathered handles the head; these
    // only stream the transformer layers.)
    this.segVjps = ranges.map(([lo, hi], k) => {
      const idxs = this.segIdxs[k]!;
      return new Vjp((p) => {
        const saved: [MlxArray, MlxArray][] = idxs.map((j) => [lora.targets[j]!.lw.a, lora.targets[j]!.lw.b]);
        idxs.forEach((j, s) => { lora.targets[j]!.lw.a = p[1 + 2 * s]!; lora.targets[j]!.lw.b = p[1 + 2 * s + 1]!; });
        try {
          return [model.runLayerRange(p[0]!, lo, hi, this.curCaches)];
        } finally {
          idxs.forEach((j, s) => { lora.targets[j]!.lw.a = saved[s]![0]; lora.targets[j]!.lw.b = saved[s]![1]; });
        }
      }, 1);
    });
  }

  /** One ORPO step over the prefix-shared concat. `promptIds`/`chosenResp`/
   *  `rejectedResp` come from splitPrefixBatch. Returns the loss + LoRA grads in
   *  flatParams(lora) order (caller owns). */
  stepPrefix(promptIds: number[], chosenResp: number[], rejectedResp: number[]): { value: MlxArray; grads: MlxArray[] } {
    if (this.disposed) throw new Error("SegmentedBackwardOrpoPrefix used after dispose");
    const { model, lora, ranges, segIdxs, n } = this;
    const P = promptIds.length, Rc = chosenResp.length, Rr = rejectedResp.length;
    if (P < 1 || Rc < 1 || Rr < 1) throw new Error("SegmentedBackwardOrpoPrefix: need P,Rc,Rr >= 1");
    const T = P + Rc + Rr;
    this.curP = P; this.curRc = Rc; this.curRr = Rr;
    this.curPromptIds = promptIds;
    this.curChosenResp = chosenResp; this.curRejectedResp = rejectedResp;
    // Per-step chunk ctx pointing the head's CustomVjp/slice disposables at this
    // step's headSink (the flash/fused head recompute runs during headVjp.apply;
    // we dispose headSink only AFTER the outputs/vjps are detached -> eval forced).
    this.headSink = [];
    this.curChunk = this.chunkCtx ? { ...this.chunkCtx, sink: this.headSink } : undefined;
    // One prefix cache per layer (captures P/Rc/Rr; makeMask -> block-sparse mask).
    this.curCaches = model.layers.map(() => new PrefixSharedCache(P, Rc, Rr));

    const nSeg = ranges.length;
    const concat = new Int32Array(T);
    concat.set(promptIds, 0);
    concat.set(chosenResp, P);
    concat.set(rejectedResp, P + Rc);
    const inputIds = MlxArray.fromInt32(concat, [1, T]);

    const boundaries: (MlxArray | null)[] = [];
    let value: MlxArray | null = null;
    let dhOut: MlxArray | null = null;
    let transferred = false;
    const grads: (MlxArray | null)[] = new Array(2 * n).fill(null);

    // Block-wise RoPE active for the WHOLE step (forward + every segment recompute).
    setMiniCpmPrefixPlan({ P, Rc, Rr });
    try {
      // --- 1. Forward over the concat, saving detached boundaries at seg edges. ---
      boundaries.push(detachLeaf(model.embed.encode(inputIds))); // [1, T, hidden]
      for (let k = 0; k < nSeg; k++) {
        const [lo, hi] = ranges[k]!;
        boundaries.push(detachLeaf(model.runLayerRange(boundaries[k]!, lo, hi, this.curCaches)));
      }

      // --- 2. Head over the last boundary (vjp, cotangent 1.0) -> [dh 1,T,hidden]. ---
      const head = this.headVjp.apply([boundaries[nSeg]!], [this.one]);
      // Force the FULL head-VJP graph (incl. the nested flash-CCE CustomVjp backward,
      // which reads savedLse/savedBlockMax) to materialize BEFORE the headSink dispose
      // below — else that deferred backward can run AFTER its lse/blockMax are freed
      // under MLX lazy eval (a use-after-free → segfault at a tiny address, ~step 100).
      ops.evalAll([head.outputs[0]!, head.vjps[0]!]);
      value = detachLeaf(head.outputs[0]!);
      dhOut = detachLeaf(head.vjps[0]!); // dLoss / d(last residual stream), [1,T,hidden]
      for (const d of this.headSink) d.dispose();
      this.headSink = [];
      boundaries[nSeg]!.dispose(); boundaries[nSeg] = null;

      // --- 3. Backward, reverse over segments (single stream, cotangent = dh). ---
      for (let k = nSeg - 1; k >= 0; k--) {
        const idxs = segIdxs[k]!;
        const params: MlxArray[] = [boundaries[k]!];
        for (const j of idxs) params.push(lora.targets[j]!.lw.a, lora.targets[j]!.lw.b);
        const res = this.segVjps[k]!.apply(params, [dhOut!]);
        res.outputs[0]!.dispose();
        idxs.forEach((j, s) => {
          grads[j] = detachLeaf(res.vjps[1 + 2 * s]!); // dA
          grads[n + j] = detachLeaf(res.vjps[1 + 2 * s + 1]!); // dB
        });
        dhOut!.dispose();
        dhOut = detachLeaf(res.vjps[0]!);
        boundaries[k]!.dispose(); boundaries[k] = null;
      }
      // Segment-0 dh_in = grad w.r.t. the embedding output (no LoRA on embed) — drop.

      transferred = true;
      return { value: value!, grads: grads as MlxArray[] };
    } finally {
      setMiniCpmPrefixPlan(null);
      inputIds.dispose();
      for (const c of this.curCaches) c.dispose();
      this.curCaches = [];
      this.curPromptIds = this.curChosenResp = this.curRejectedResp = null;
      for (const d of this.headSink) d.dispose();
      this.headSink = [];
      dhOut?.dispose();
      for (const b of boundaries) b?.dispose();
      if (!transferred) {
        value?.dispose();
        for (const g of grads) g?.dispose();
      }
    }
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    this.headVjp.dispose();
    for (const v of this.segVjps) v.dispose();
    this.one.dispose();
  }
}

// ===========================================================================
// SegmentedBackwardOrpoGemma4: segmented backward for ORPO on e4b (B=1).
// ===========================================================================
//
// The cross of SegmentedBackwardGemma4 (KV-shared donor threading + per-layer-
// input boundary + per-segment vjp with consumes/produces) and
// SegmentedBackwardOrpo (TWO sequences — chosen + rejected — and the ORPO head).
//
// Per step: forward each branch segment-by-segment (saving detached hidden +
// reused-donor K/V boundaries, the branch's per-layer-input constant, and the
// branch's masks); the ORPO head vjp over [last_chosen, last_rejected] -> loss
// yields [dh_chosen, dh_rejected]; then each branch is walked backward in
// reverse over its segments (donor cotangents accumulated in dKV exactly as in
// SegmentedBackwardGemma4). LoRA grads from the two branches are summed.
//
// The donor consumes/produces TOPOLOGY is a function of the architecture and the
// segmentation only (not the data), so it is computed ONCE and reused for both
// branches. The masks and per-layer-input DIFFER per branch (different lengths),
// so the reused per-segment vjp closures read the active branch's masks/perLayer
// off curMasks/curPerLayer, swapped per backward pass.

/** Per-branch forward state: the detached boundaries + reused-donor K/V
 *  boundaries, plus the masks and per-layer-input constant for THAT branch
 *  (held across its backward; the reused seg vjps read them via curMasks/
 *  curPerLayer). The step's finally disposes whatever survives. */
interface BranchState {
  boundaries: (MlxArray | null)[];
  donorBnd: Map<number, KvPair>;
  masks: Map<string, Mask> | null;
  perLayer: MlxArray | null;
}

export class SegmentedBackwardOrpoGemma4 {
  private readonly nLayers: number;
  private readonly n: number;
  private readonly segIdxs: number[][];
  private readonly consumes: number[][];
  private readonly produces: number[][];
  private readonly caches: Cache[];
  private readonly headVjp: Vjp;
  private readonly segVjps: Vjp[];
  private readonly one: MlxArray;
  // Per-step / per-branch mutable context the (reused) closures read.
  private curChosenIds: number[] | null = null;
  private curChosenMask: number[] | null = null;
  private curRejectedIds: number[] | null = null;
  private curRejectedMask: number[] | null = null;
  private curMasks: Map<string, Mask> | null = null; // active branch (set per backward pass)
  private curPerLayer: MlxArray | null = null;
  // Fused linear-CE head sink (see SegmentedBackwardOrpo): per-step CustomVjps +
  // response slices, disposed after the head vjp is eval'd. Bounds the head term
  // to [chunk,V] inside the e4b segmented backward.
  private headSink: Array<{ dispose(): void }> = [];
  private disposed = false;

  constructor(
    private readonly model: Gemma4Model,
    private readonly lora: TrainableLora,
    private readonly ranges: [number, number][],
    private readonly lambda: number,
    private readonly fusedChunkSize = 0,
    private readonly sftScope: SftScope = "response",
  ) {
    this.nLayers = model.layers.length;
    const lastHi = ranges[ranges.length - 1]?.[1] ?? 0;
    if (ranges[0]?.[0] !== 0 || lastHi !== this.nLayers)
      throw new Error(`SegmentedBackwardOrpoGemma4: ranges must cover [0, ${this.nLayers})`);
    this.n = lora.targets.length;

    const layerOf = lora.targets.map((t) => targetLayer(t.modulePath));
    this.segIdxs = ranges.map(([lo, hi]) =>
      layerOf.map((li, j) => ({ li, j })).filter((x) => x.li >= lo && x.li < hi).map((x) => x.j),
    );

    // Donor/sharer KV threading topology (identical to SegmentedBackwardGemma4):
    // architecture + segmentation only, so shared across both branches.
    const segOfLayer = new Map<number, number>();
    ranges.forEach(([lo, hi], k) => { for (let i = lo; i < hi; i++) segOfLayer.set(i, k); });
    const reused = model.reusedDonors;
    const producerSeg = new Map<number, number>();
    for (const d of reused) producerSeg.set(d, segOfLayer.get(d)!);
    this.consumes = ranges.map(() => []);
    this.produces = ranges.map(() => []);
    for (let i = 0; i < this.nLayers; i++) {
      if (model.cacheIndex[i] !== -1) continue;
      const d = model.previousKvs[i]!;
      const sSeg = segOfLayer.get(i)!;
      const pSeg = producerSeg.get(d)!;
      if (sSeg > pSeg) {
        if (!this.consumes[sSeg]!.includes(d)) this.consumes[sSeg]!.push(d);
        if (!this.produces[pSeg]!.includes(d)) this.produces[pSeg]!.push(d);
      }
    }

    this.caches = Array.from({ length: model.numDonors }, () => new TrainingCache());
    this.one = MlxArray.fromFloat32(new Float32Array([1]), []);

    // ORPO head (identical to SegmentedBackwardOrpo): inputs = [last_chosen,
    // last_rejected] pre-finalNorm; finalNorm each, length-normalized response
    // logp, orpo loss. vjp with cotangent 1.0 -> [dh_chosen, dh_rejected].
    this.headVjp = new Vjp((p) => {
      const hnC = this.model.finalNorm.forward(p[0]!);
      const hnR = this.model.finalNorm.forward(p[1]!);
      const cs = this.fusedChunkSize;
      const lw = cs > 0
        ? boundedHeadFromHidden(this.model, hnC, this.curChosenIds!, this.curChosenMask!, cs, this.headSink)
        : responseOnlyLogpMean(this.model, hnC, this.curChosenIds!, this.curChosenMask!);
      const lr = cs > 0
        ? boundedHeadFromHidden(this.model, hnR, this.curRejectedIds!, this.curRejectedMask!, cs, this.headSink)
        : responseOnlyLogpMean(this.model, hnR, this.curRejectedIds!, this.curRejectedMask!);
      // sft_scope:"full": prompt-span head over the same hnC (see
      // SegmentedBackwardOrpo); ℓw/ℓr stay response-only for the odds ratio.
      let nllFull: MlxArray | null = null;
      if (this.sftScope === "full") {
        const { startT, M } = respSpanFromMask(this.curChosenMask!, this.curChosenIds!.length - 1);
        let pm: MlxArray | null = null;
        if (M > 0 && startT > 0)
          pm = cs > 0
            ? boundedHeadFromHidden(this.model, hnC, this.curChosenIds!, this.curChosenMask!, cs, this.headSink, { startT: 0, M: startT })
            : spanLogpMeanFromHidden(this.model, hnC, this.curChosenIds!, 0, startT);
        nllFull = combineFullNll(pm, lw, M > 0 ? startT : 0, M);
        pm?.dispose();
      }
      hnC.dispose(); hnR.dispose();
      const loss = orpoLossFromLogps(lw, lr, this.lambda, nllFull ?? undefined);
      lw.dispose(); lr.dispose();
      nllFull?.dispose();
      return [loss];
    }, 1);

    // One reused vjp per segment (identical to SegmentedBackwardGemma4); reused
    // across both branches. Inputs: [boundary, (k,v)*consumes, (a,b)*lora].
    // Outputs: [h, (k,v)*produces]. Reads curMasks/curPerLayer (active branch).
    this.segVjps = ranges.map(([lo, hi], k) => {
      const idxs = this.segIdxs[k]!;
      const cons = this.consumes[k]!;
      const prod = this.produces[k]!;
      const base = 1 + 2 * cons.length;
      const nOut = 1 + 2 * prod.length;
      return new Vjp((p) => {
        const boundary = p[0]!;
        const kvIn = new Map<number, SharedKv>();
        cons.forEach((d, ci) => kvIn.set(d, { kind: "plain", keys: p[1 + 2 * ci]!, values: p[1 + 2 * ci + 1]!, offset: 0 }));
        const saved: [MlxArray, MlxArray][] = idxs.map((j) => [lora.targets[j]!.lw.a, lora.targets[j]!.lw.b]);
        idxs.forEach((j, s) => {
          lora.targets[j]!.lw.a = p[base + 2 * s]!;
          lora.targets[j]!.lw.b = p[base + 2 * s + 1]!;
        });
        try {
          const { h, donorKvOut } = this.model.runLayerRange(
            boundary, lo, hi, this.caches, this.curMasks!, this.curPerLayer, kvIn,
          );
          const outs: MlxArray[] = [h];
          for (const d of prod) {
            const kv = donorKvOut.get(d)!;
            if (kv.kind !== "plain") throw new Error("segmented e4b orpo: quantized donor KV unsupported in training");
            const ck = ops.contiguous(kv.keys), cv = ops.contiguous(kv.values);
            kv.keys.dispose(); kv.values.dispose();
            outs.push(ck, cv);
          }
          for (const [d, kv] of donorKvOut)
            if (!prod.includes(d) && kv.kind === "plain") { kv.keys.dispose(); kv.values.dispose(); }
          return outs;
        } finally {
          idxs.forEach((j, s) => { lora.targets[j]!.lw.a = saved[s]![0]; lora.targets[j]!.lw.b = saved[s]![1]; });
        }
      }, nOut);
    });
  }

  /** Forward one branch segment-by-segment, populating `st` (boundaries +
   *  reused-donor K/V boundaries + this branch's masks + per-layer constant).
   *  Mutates `st` incrementally so the step's finally always sees partial state
   *  on throw. The last boundary (st.boundaries[nSeg]) feeds the ORPO head. */
  private forwardBranch(ids: number[], st: BranchState): void {
    const { model, ranges, caches, consumes, produces } = this;
    const T = ids.length - 1;
    const inputHost = new Int32Array(T);
    for (let t = 0; t < T; t++) inputHost[t] = ids[t]!;
    const inputIds = MlxArray.fromInt32(inputHost, [1, T]);
    try {
      const { hScaled, perLayer } = model.embedForSegmented(inputIds);
      st.boundaries.push(detachLeaf(hScaled));
      st.perLayer = perLayer ? detachLeaf(perLayer) : null;
      st.masks = model.makeTrainingMasks(caches, T);

      for (let k = 0; k < ranges.length; k++) {
        const [lo, hi] = ranges[k]!;
        const kvIn = new Map<number, SharedKv>();
        for (const d of consumes[k]!) {
          const b = st.donorBnd.get(d)!;
          kvIn.set(d, { kind: "plain", keys: b.keys, values: b.values, offset: 0 });
        }
        const { h, donorKvOut } = model.runLayerRange(st.boundaries[k]!, lo, hi, caches, st.masks, st.perLayer, kvIn);
        for (const d of produces[k]!) {
          const kv = donorKvOut.get(d)!;
          if (kv.kind !== "plain") throw new Error("segmented e4b orpo: quantized donor KV unsupported in training");
          st.donorBnd.set(d, { keys: detachLeaf(kv.keys), values: detachLeaf(kv.values) });
        }
        for (const [d, kv] of donorKvOut)
          if (!produces[k]!.includes(d) && kv.kind === "plain") { kv.keys.dispose(); kv.values.dispose(); }
        st.boundaries.push(detachLeaf(h));
      }
    } finally {
      inputIds.dispose();
    }
  }

  /** Backward one branch in reverse over segments. Takes ownership of `dhSeed`
   *  (the head's cotangent for this branch's last boundary) and fills `grads`
   *  (length 2n) in place with the branch's LoRA gradients. Reused-donor
   *  cotangents are accumulated in a per-branch dKV (bf16, as in
   *  SegmentedBackwardGemma4). Sets curMasks/curPerLayer to this branch for the
   *  duration so the reused seg vjps see the right constants. */
  private backwardBranch(st: BranchState, dhSeed: MlxArray, grads: (MlxArray | null)[]): void {
    const { lora, ranges, segIdxs, consumes, produces, n } = this;
    this.curMasks = st.masks;
    this.curPerLayer = st.perLayer;
    const dKV = new Map<number, KvPair>();
    let dhOut: MlxArray | null = dhSeed;
    try {
      for (let k = ranges.length - 1; k >= 0; k--) {
        const idxs = segIdxs[k]!;
        const cons = consumes[k]!;
        const prod = produces[k]!;
        const dh = dhOut!;

        const primals: MlxArray[] = [st.boundaries[k]!];
        for (const d of cons) { const b = st.donorBnd.get(d)!; primals.push(b.keys, b.values); }
        for (const j of idxs) primals.push(lora.targets[j]!.lw.a, lora.targets[j]!.lw.b);

        const cots: MlxArray[] = [dh];
        for (const d of prod) { const acc = dKV.get(d)!; cots.push(acc.keys, acc.values); }

        const res = this.segVjps[k]!.apply(primals, cots);
        for (const o of res.outputs) o.dispose();

        const newDh = detachLeaf(res.vjps[0]!);
        cons.forEach((d, ci) => {
          const dk = detachLeaf(res.vjps[1 + 2 * ci]!);
          const dv = detachLeaf(res.vjps[1 + 2 * ci + 1]!);
          this.accumulateDKV(dKV, d, dk, dv);
        });
        const base = 1 + 2 * cons.length;
        idxs.forEach((j, s) => {
          grads[j] = detachLeaf(res.vjps[base + 2 * s]!);
          grads[n + j] = detachLeaf(res.vjps[base + 2 * s + 1]!);
        });

        dh.dispose();
        dhOut = newDh;
        for (const d of prod) {
          const acc = dKV.get(d)!; acc.keys.dispose(); acc.values.dispose(); dKV.delete(d);
          const b = st.donorBnd.get(d)!; b.keys.dispose(); b.values.dispose(); st.donorBnd.delete(d);
        }
        st.boundaries[k]!.dispose();
        st.boundaries[k] = null;
      }
    } finally {
      dhOut?.dispose(); // segment-0 dh_in (embed / per-layer grad) — no LoRA there
      for (const kv of dKV.values()) { kv.keys.dispose(); kv.values.dispose(); }
      this.curMasks = null;
      this.curPerLayer = null;
    }
  }

  /** Accumulate a reused-donor K/V cotangent (sum across consuming segments) —
   *  identical to SegmentedBackwardGemma4 (bf16, non-associative ~0.5% class). */
  private accumulateDKV(dKV: Map<number, KvPair>, d: number, dk: MlxArray, dv: MlxArray): void {
    const prev = dKV.get(d);
    if (!prev) { dKV.set(d, { keys: dk, values: dv }); return; }
    const sk = detachLeaf(ops.add(prev.keys, dk));
    const sv = detachLeaf(ops.add(prev.values, dv));
    prev.keys.dispose(); prev.values.dispose(); dk.dispose(); dv.dispose();
    dKV.set(d, { keys: sk, values: sv });
  }

  private disposeBranch(st: BranchState | null): void {
    if (!st) return;
    for (const b of st.boundaries) b?.dispose();
    for (const kv of st.donorBnd.values()) { kv.keys.dispose(); kv.values.dispose(); }
    st.perLayer?.dispose();
    if (st.masks) for (const m of st.masks.values()) m.arr?.dispose();
  }

  step(batch: DpoBatch): { value: MlxArray; grads: MlxArray[] } {
    if (this.disposed) throw new Error("SegmentedBackwardOrpoGemma4 used after dispose");
    const { n } = this;
    if (batch.chosenIds.length !== 1) throw new Error("SegmentedBackwardOrpoGemma4: only B=1 is supported");
    this.curChosenIds = batch.chosenIds[0]!;
    this.curChosenMask = batch.chosenMask[0]!;
    this.curRejectedIds = batch.rejectedIds[0]!;
    this.curRejectedMask = batch.rejectedMask[0]!;
    const Lc = batch.chosenIds[0]!.length;
    const Lr = batch.rejectedIds[0]!.length;
    if (Lc < 2 || Lr < 2) throw new Error("SegmentedBackwardOrpoGemma4: sequences too short");

    const nSeg = this.ranges.length;
    const stC: BranchState = { boundaries: [], donorBnd: new Map(), masks: null, perLayer: null };
    const stR: BranchState = { boundaries: [], donorBnd: new Map(), masks: null, perLayer: null };
    const gradsC: (MlxArray | null)[] = new Array(2 * n).fill(null);
    const gradsR: (MlxArray | null)[] = new Array(2 * n).fill(null);
    let value: MlxArray | null = null;
    let dhC: MlxArray | null = null;
    let dhR: MlxArray | null = null;
    let transferred = false;

    try {
      // --- 1. Forward both branches (boundaries + donor K/V + masks/perLayer). ---
      this.forwardBranch(batch.chosenIds[0]!, stC);
      this.forwardBranch(batch.rejectedIds[0]!, stR);

      // --- 2. ORPO head over the two last boundaries (cotangent 1.0). The fused
      // head pushes per-step CustomVjps + slices into headSink; dispose only after
      // outputs/vjps are detached to leaves (which forces the head eval). ---
      this.headSink = [];
      const head = this.headVjp.apply([stC.boundaries[nSeg]!, stR.boundaries[nSeg]!], [this.one]);
      // Materialize the full head-VJP graph (incl. the nested CustomVjp backward that
      // reads savedLse/savedBlockMax) BEFORE freeing headSink — avoids the lazy-eval
      // use-after-free segfault (see the segmented-prefix crash diagnosis).
      ops.evalAll([head.outputs[0]!, head.vjps[0]!, head.vjps[1]!]);
      value = detachLeaf(head.outputs[0]!);
      dhC = detachLeaf(head.vjps[0]!);
      dhR = detachLeaf(head.vjps[1]!);
      for (const d of this.headSink) d.dispose();
      this.headSink = [];
      stC.boundaries[nSeg]!.dispose(); stC.boundaries[nSeg] = null;
      stR.boundaries[nSeg]!.dispose(); stR.boundaries[nSeg] = null;

      // --- 3. Backward each branch (ownership of dh transfers to backwardBranch). ---
      const seedC = dhC; dhC = null;
      this.backwardBranch(stC, seedC, gradsC);
      const seedR = dhR; dhR = null;
      this.backwardBranch(stR, seedR, gradsR);

      // --- 4. Sum LoRA grads from both branches. ---
      const grads: MlxArray[] = gradsC.map((gc, i) => {
        const gr = gradsR[i]!;
        const sum = ops.add(gc!, gr);
        gc!.dispose(); gr.dispose();
        gradsC[i] = null; gradsR[i] = null;
        return detachLeaf(sum);
      });

      transferred = true;
      return { value: value!, grads };
    } finally {
      this.curChosenIds = this.curChosenMask = this.curRejectedIds = this.curRejectedMask = null;
      dhC?.dispose(); dhR?.dispose();
      this.disposeBranch(stC);
      this.disposeBranch(stR);
      if (!transferred) {
        value?.dispose();
        for (const g of gradsC) g?.dispose();
        for (const g of gradsR) g?.dispose();
      }
    }
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    this.headVjp.dispose();
    for (const v of this.segVjps) v.dispose();
    for (const c of this.caches) c.dispose();
    this.one.dispose();
  }
}

// ===========================================================================
// SegmentedBackwardOrpoPrefixGemma4: segmented backward + PREFIX-SHARING on e4b.
// ===========================================================================
//
// The e4b (Gemma4) analogue of SegmentedBackwardOrpoPrefix (MiniCPM5): the
// composition of SegmentedBackwardOrpoGemma4's SEGMENT machinery (donor-KV
// threading across segment boundaries, per-layer-input boundary, sliding-window
// vs full-attention per-layer-type masks) with prefix-sharing (one forward over
// the single concat [prompt; chosen; rejected]).
//
// It is SegmentedBackwardOrpoGemma4 reduced to ONE stream (not two branches),
// with three substitutions — exactly the MiniCPM5 prefix recipe lifted to e4b:
//  - the streamed sequence is the single concat [prompt(P); chosen(Rc); rejected(Rr)]
//    (T = P+Rc+Rr), so one boundary stream, one backward walk, one donor-KV thread.
//  - the per-(donor-)layer caches are Gemma4PrefixSharedSegCache (a LOCAL copy of
//    the private Gemma4PrefixSharedCache in prefix-shared.ts): makeMask(T, window)
//    returns the LOGICAL-position block-sparse + sliding-window prefix mask.
//    makeTrainingMasks(caches,T) builds one such mask per layer-type (sliding gets
//    the window AND; full gets the plain block-sparse causal), exactly like
//    orpoLossPrefixSharedGemma's forward.
//  - setGemmaPrefixPlan({P,Rc,Rr}) is ACTIVE for the whole step (set in stepPrefix,
//    cleared in finally) so block-wise RoPE rides through BOTH the streaming forward
//    AND every segment's mlx_vjp recompute, through donor AND sharer layers
//    identically to the non-segmented orpoLossPrefixSharedGemma.
//  - the head gathers the chosen/rejected response hiddens from the final
//    [1,T,hidden] (branchLogpMeanGathered — the [M,V]-free per-branch flash head)
//    and ORPO-combines; its vjp w.r.t. the last boundary is the full [1,T,hidden] dh
//    (the gather's takeAxis vjp scatter-adds each branch's response-position
//    cotangent back into the full sequence), seeding the single segmented backward.
//
// The caches count = model.numDonors (like orpoLossPrefixSharedGemma), NOT
// model.layers.length: sharers reuse the donors' fetched K/V. The donor
// consumes/produces topology is architecture+segmentation only (data-independent),
// computed ONCE — identical to SegmentedBackwardOrpoGemma4. All the hard-won
// lessons hold: mlx_vjp per segment (NOT surrogate value_and_grad), detachLeaf at
// boundaries, reused vjp objects, head disposables into a per-step sink, the
// CONTIGUOUS-donor-K/V layout matching between producer output and consumer
// cotangent, and the bf16-class accumulateDKV cross-segment donor cotangent sum.

/** Pass-through cache (offset 0) for the e4b prefix-shared SEGMENTED forward whose
 *  makeMask returns the block-sparse + logical-window mask. A LOCAL copy of the
 *  (private) Gemma4PrefixSharedCache in prefix-shared.ts — replicated here rather
 *  than exporting it (file-ownership boundary). makeTrainingMasks calls
 *  makeMask(T, window) with window = the model's sliding window for sliding layers
 *  and null for full layers; the window arg selects the sliding term. One per DONOR
 *  layer (sharers reuse donors' fetched KV inside runLayerRange). */
class Gemma4PrefixSharedSegCache implements Cache {
  offset = 0;
  constructor(private readonly P: number, private readonly Rc: number, private readonly Rr: number) {}
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    return [k.slice([0, 0, 0, 0], k.shape), v.slice([0, 0, 0, 0], v.shape)];
  }
  makeMask(N: number, windowSize: number | null): Mask {
    if (N !== this.P + this.Rc + this.Rr)
      throw new Error(`Gemma4PrefixSharedSegCache: N=${N} != P+Rc+Rr=${this.P + this.Rc + this.Rr}`);
    return { mode: "array", arr: blockSparsePrefixMaskGemma(this.P, this.Rc, this.Rr, windowSize) };
  }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return true; }
  trim(_n: number): void { /* offset pinned at 0 */ }
  dispose(): void { /* owns no arrays */ }
}

export class SegmentedBackwardOrpoPrefixGemma4 {
  private readonly nLayers: number;
  private readonly n: number;
  private readonly segIdxs: number[][];
  private readonly consumes: number[][];
  private readonly produces: number[][];
  private readonly caches: Cache[]; // numDonors TrainingCache (the running KV the seg vjps fetch into)
  private readonly headVjp: Vjp;
  private readonly segVjps: Vjp[];
  private readonly one: MlxArray;
  // Per-step mutable context the (reused) closures read.
  private curP = 0;
  private curRc = 0;
  private curRr = 0;
  private curPromptIds: number[] | null = null;
  private curChosenResp: number[] | null = null;
  private curRejectedResp: number[] | null = null;
  private curChunk: ChunkCtx | undefined = undefined;
  private curMasks: Map<string, Mask> | null = null; // prefix masks for this step
  private curPerLayer: MlxArray | null = null;
  private headSink: Array<{ dispose(): void }> = [];
  private disposed = false;

  constructor(
    private readonly model: Gemma4Model,
    private readonly lora: TrainableLora,
    private readonly ranges: [number, number][],
    private readonly lambda: number,
    private readonly chunkCtx?: ChunkCtx,
    private readonly sftScope: SftScope = "response",
  ) {
    this.nLayers = model.layers.length;
    const lastHi = ranges[ranges.length - 1]?.[1] ?? 0;
    if (ranges[0]?.[0] !== 0 || lastHi !== this.nLayers)
      throw new Error(`SegmentedBackwardOrpoPrefixGemma4: ranges must cover [0, ${this.nLayers})`);
    this.n = lora.targets.length;

    const layerOf = lora.targets.map((t) => targetLayer(t.modulePath));
    this.segIdxs = ranges.map(([lo, hi]) =>
      layerOf.map((li, j) => ({ li, j })).filter((x) => x.li >= lo && x.li < hi).map((x) => x.j),
    );

    // Donor/sharer KV threading topology (identical to SegmentedBackwardGemma4 /
    // SegmentedBackwardOrpoGemma4): architecture + segmentation only — independent
    // of the data AND of prefix-sharing (the donor structure is the same concat).
    const segOfLayer = new Map<number, number>();
    ranges.forEach(([lo, hi], k) => { for (let i = lo; i < hi; i++) segOfLayer.set(i, k); });
    const reused = model.reusedDonors;
    const producerSeg = new Map<number, number>();
    for (const d of reused) producerSeg.set(d, segOfLayer.get(d)!);
    this.consumes = ranges.map(() => []);
    this.produces = ranges.map(() => []);
    for (let i = 0; i < this.nLayers; i++) {
      if (model.cacheIndex[i] !== -1) continue;
      const d = model.previousKvs[i]!;
      const sSeg = segOfLayer.get(i)!;
      const pSeg = producerSeg.get(d)!;
      if (sSeg > pSeg) {
        if (!this.consumes[sSeg]!.includes(d)) this.consumes[sSeg]!.push(d);
        if (!this.produces[pSeg]!.includes(d)) this.produces[pSeg]!.push(d);
      }
    }

    this.caches = Array.from({ length: model.numDonors }, () => new TrainingCache());
    this.one = MlxArray.fromFloat32(new Float32Array([1]), []);

    // Head VJP: input = the last boundary [1, T, hidden] (pre-finalNorm). Applies
    // finalNorm, gathers each branch's response hiddens (prefixGatherIdx layout),
    // computes ℓw/ℓr through the [M,V]-free per-branch head (branchLogpMeanGathered),
    // returns the scalar orpo loss. nOut = 1; apply([h_last],[one]) returns
    // vjps[0] = dh [1,T,hidden] (the gather's takeAxis vjp scatter-adds the
    // per-branch dh into the full sequence) — same as the MiniCPM5 prefix head.
    this.headVjp = new Vjp((p) => {
      const hn = model.finalNorm.forward(p[0]!); // [1, T, hidden]
      const { chosenIdx, rejectedIdx } = prefixGatherIdx(this.curP, this.curRc, this.curRr);
      const lw = branchLogpMeanGathered(model, hn, chosenIdx, this.curChosenResp!, this.curChunk);
      const lr = branchLogpMeanGathered(model, hn, rejectedIdx, this.curRejectedResp!, this.curChunk);
      // sft_scope:"full": prompt predictions from the same concat hiddens (see
      // SegmentedBackwardOrpoPrefix); ℓw/ℓr stay response-only.
      const nllFull = this.sftScope === "full"
        ? prefixFullNll(model, hn, this.curPromptIds!, lw, this.curRc, this.curChunk)
        : null;
      hn.dispose();
      const loss = orpoLossFromLogps(lw, lr, this.lambda, nllFull ?? undefined);
      lw.dispose(); lr.dispose();
      nllFull?.dispose();
      return [loss];
    }, 1);

    // One reused vjp per segment — same SHAPE as SegmentedBackwardOrpoGemma4's
    // (Inputs: [boundary, (k,v)*consumes, (a,b)*lora]; Outputs: [h, (k,v)*produces]),
    // reading the active step's PREFIX masks/perLayer off curMasks/curPerLayer. The
    // prefix RoPE plan is active for the whole step (set in stepPrefix), so the
    // recompute here ropes block-wise too. (branchLogpMeanGathered handles the head;
    // these only stream the transformer layers + thread the donor KV.)
    this.segVjps = ranges.map(([lo, hi], k) => {
      const idxs = this.segIdxs[k]!;
      const cons = this.consumes[k]!;
      const prod = this.produces[k]!;
      const base = 1 + 2 * cons.length;
      const nOut = 1 + 2 * prod.length;
      return new Vjp((p) => {
        const boundary = p[0]!;
        const kvIn = new Map<number, SharedKv>();
        cons.forEach((d, ci) => kvIn.set(d, { kind: "plain", keys: p[1 + 2 * ci]!, values: p[1 + 2 * ci + 1]!, offset: 0 }));
        const saved: [MlxArray, MlxArray][] = idxs.map((j) => [lora.targets[j]!.lw.a, lora.targets[j]!.lw.b]);
        idxs.forEach((j, s) => {
          lora.targets[j]!.lw.a = p[base + 2 * s]!;
          lora.targets[j]!.lw.b = p[base + 2 * s + 1]!;
        });
        try {
          const { h, donorKvOut } = model.runLayerRange(
            boundary, lo, hi, this.caches, this.curMasks!, this.curPerLayer, kvIn,
          );
          const outs: MlxArray[] = [h];
          for (const d of prod) {
            const kv = donorKvOut.get(d)!;
            if (kv.kind !== "plain") throw new Error("segmented e4b prefix: quantized donor KV unsupported in training");
            const ck = ops.contiguous(kv.keys), cv = ops.contiguous(kv.values);
            kv.keys.dispose(); kv.values.dispose();
            outs.push(ck, cv);
          }
          for (const [d, kv] of donorKvOut)
            if (!prod.includes(d) && kv.kind === "plain") { kv.keys.dispose(); kv.values.dispose(); }
          return outs;
        } finally {
          idxs.forEach((j, s) => { lora.targets[j]!.lw.a = saved[s]![0]; lora.targets[j]!.lw.b = saved[s]![1]; });
        }
      }, nOut);
    });
  }

  /** Accumulate a reused-donor K/V cotangent (sum across consuming segments) —
   *  identical to SegmentedBackwardGemma4 (bf16, non-associative ~0.5% class). */
  private accumulateDKV(dKV: Map<number, KvPair>, d: number, dk: MlxArray, dv: MlxArray): void {
    const prev = dKV.get(d);
    if (!prev) { dKV.set(d, { keys: dk, values: dv }); return; }
    const sk = detachLeaf(ops.add(prev.keys, dk));
    const sv = detachLeaf(ops.add(prev.values, dv));
    prev.keys.dispose(); prev.values.dispose(); dk.dispose(); dv.dispose();
    dKV.set(d, { keys: sk, values: sv });
  }

  /** One ORPO step over the prefix-shared concat. `promptIds`/`chosenResp`/
   *  `rejectedResp` come from splitPrefixBatch. Returns the loss + LoRA grads in
   *  flatParams(lora) order (caller owns). Mirrors SegmentedBackwardOrpoPrefix.stepPrefix. */
  stepPrefix(promptIds: number[], chosenResp: number[], rejectedResp: number[]): { value: MlxArray; grads: MlxArray[] } {
    if (this.disposed) throw new Error("SegmentedBackwardOrpoPrefixGemma4 used after dispose");
    const { model, lora, ranges, caches, segIdxs, consumes, produces, n } = this;
    const P = promptIds.length, Rc = chosenResp.length, Rr = rejectedResp.length;
    if (P < 1 || Rc < 1 || Rr < 1) throw new Error("SegmentedBackwardOrpoPrefixGemma4: need P,Rc,Rr >= 1");
    const T = P + Rc + Rr;
    this.curP = P; this.curRc = Rc; this.curRr = Rr;
    this.curPromptIds = promptIds;
    this.curChosenResp = chosenResp; this.curRejectedResp = rejectedResp;
    this.headSink = [];
    this.curChunk = this.chunkCtx ? { ...this.chunkCtx, sink: this.headSink } : undefined;

    const nSeg = ranges.length;
    const concat = new Int32Array(T);
    concat.set(promptIds, 0);
    concat.set(chosenResp, P);
    concat.set(rejectedResp, P + Rc);
    const inputIds = MlxArray.fromInt32(concat, [1, T]);

    // Per-step prefix caches (one per DONOR layer): makeMask -> block-sparse +
    // logical-window mask. makeTrainingMasks calls makeMask(T, window) per layer-type.
    const prefixCaches: Cache[] = Array.from({ length: model.numDonors }, () => new Gemma4PrefixSharedSegCache(P, Rc, Rr));

    const boundaries: (MlxArray | null)[] = [];
    const donorBnd = new Map<number, KvPair>(); // detached reused-donor K/V boundaries
    const dKV = new Map<number, KvPair>(); // accumulated reused-donor cotangents
    let value: MlxArray | null = null;
    let dhOut: MlxArray | null = null;
    let transferred = false;
    const grads: (MlxArray | null)[] = new Array(2 * n).fill(null);

    // Block-wise RoPE active for the WHOLE step (forward + every segment recompute).
    setGemmaPrefixPlan({ P, Rc, Rr });
    try {
      // --- 1. Forward over the concat, saving detached boundaries (hidden + donor K/V). ---
      const { hScaled, perLayer } = model.embedForSegmented(inputIds);
      boundaries.push(detachLeaf(hScaled));
      this.curPerLayer = perLayer ? detachLeaf(perLayer) : null;
      // Prefix masks (block-sparse + logical-window) for this step, built from the
      // prefix caches (NOT model.makeTrainingMasks' offset-0 causal masks).
      this.curMasks = model.makeTrainingMasks(prefixCaches, T);

      for (let k = 0; k < nSeg; k++) {
        const [lo, hi] = ranges[k]!;
        const kvIn = new Map<number, SharedKv>();
        for (const d of consumes[k]!) {
          const b = donorBnd.get(d)!;
          kvIn.set(d, { kind: "plain", keys: b.keys, values: b.values, offset: 0 });
        }
        const { h, donorKvOut } = model.runLayerRange(boundaries[k]!, lo, hi, caches, this.curMasks, this.curPerLayer, kvIn);
        for (const d of produces[k]!) {
          const kv = donorKvOut.get(d)!;
          if (kv.kind !== "plain") throw new Error("segmented e4b prefix: quantized donor KV unsupported in training");
          donorBnd.set(d, { keys: detachLeaf(kv.keys), values: detachLeaf(kv.values) });
        }
        for (const [d, kv] of donorKvOut)
          if (!produces[k]!.includes(d) && kv.kind === "plain") { kv.keys.dispose(); kv.values.dispose(); }
        boundaries.push(detachLeaf(h));
      }

      // --- 2. Head over the last boundary (vjp, cotangent 1.0) -> [dh 1,T,hidden]. ---
      const head = this.headVjp.apply([boundaries[nSeg]!], [this.one]);
      // Force the FULL head-VJP graph (incl. the nested flash-CCE CustomVjp backward,
      // which reads savedLse/savedBlockMax) to materialize BEFORE the headSink dispose
      // below — else that deferred backward can run AFTER its lse/blockMax are freed
      // under MLX lazy eval (a use-after-free → segfault at a tiny address, ~step 100).
      ops.evalAll([head.outputs[0]!, head.vjps[0]!]);
      value = detachLeaf(head.outputs[0]!);
      dhOut = detachLeaf(head.vjps[0]!); // dLoss / d(last residual stream), [1,T,hidden]
      for (const d of this.headSink) d.dispose();
      this.headSink = [];
      boundaries[nSeg]!.dispose(); boundaries[nSeg] = null;

      // --- 3. Backward, reverse over segments (single stream; cotangents dh + dKV). ---
      for (let k = nSeg - 1; k >= 0; k--) {
        const idxs = segIdxs[k]!;
        const cons = consumes[k]!;
        const prod = produces[k]!;
        const dh = dhOut!;

        const primals: MlxArray[] = [boundaries[k]!];
        for (const d of cons) { const b = donorBnd.get(d)!; primals.push(b.keys, b.values); }
        for (const j of idxs) primals.push(lora.targets[j]!.lw.a, lora.targets[j]!.lw.b);

        const cots: MlxArray[] = [dh];
        for (const d of prod) { const acc = dKV.get(d)!; cots.push(acc.keys, acc.values); }

        const res = this.segVjps[k]!.apply(primals, cots);
        for (const o of res.outputs) o.dispose();

        const newDh = detachLeaf(res.vjps[0]!);
        cons.forEach((d, ci) => {
          const dk = detachLeaf(res.vjps[1 + 2 * ci]!);
          const dv = detachLeaf(res.vjps[1 + 2 * ci + 1]!);
          this.accumulateDKV(dKV, d, dk, dv);
        });
        const base = 1 + 2 * cons.length;
        idxs.forEach((j, s) => {
          grads[j] = detachLeaf(res.vjps[base + 2 * s]!);
          grads[n + j] = detachLeaf(res.vjps[base + 2 * s + 1]!);
        });

        dh.dispose();
        dhOut = newDh;
        for (const d of prod) {
          const acc = dKV.get(d)!; acc.keys.dispose(); acc.values.dispose(); dKV.delete(d);
          const b = donorBnd.get(d)!; b.keys.dispose(); b.values.dispose(); donorBnd.delete(d);
        }
        boundaries[k]!.dispose(); boundaries[k] = null;
      }
      // Segment-0 dh_in = grad w.r.t. the scaled embedding / per-layer-input (no LoRA
      // target there: per_layer_input_gate/projection are differentiated INSIDE the
      // segments) — dropped (disposed in finally).

      transferred = true;
      return { value: value!, grads: grads as MlxArray[] };
    } finally {
      setGemmaPrefixPlan(null);
      inputIds.dispose();
      for (const c of prefixCaches) c.dispose();
      this.curPerLayer?.dispose();
      this.curPerLayer = null;
      if (this.curMasks) { for (const m of this.curMasks.values()) m.arr?.dispose(); this.curMasks = null; }
      this.curPromptIds = this.curChosenResp = this.curRejectedResp = null;
      for (const d of this.headSink) d.dispose();
      this.headSink = [];
      dhOut?.dispose();
      for (const b of boundaries) b?.dispose();
      for (const kv of donorBnd.values()) { kv.keys.dispose(); kv.values.dispose(); }
      for (const kv of dKV.values()) { kv.keys.dispose(); kv.values.dispose(); }
      if (!transferred) {
        value?.dispose();
        for (const g of grads) g?.dispose();
      }
    }
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    this.headVjp.dispose();
    for (const v of this.segVjps) v.dispose();
    for (const c of this.caches) c.dispose();
    this.one.dispose();
  }
}
