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
import type { MiniCPM5Model } from "../model/minicpm5";
import type { Gemma4Model } from "../model/gemma4";
import type { Cache, Mask, SharedKv } from "../model/gemma4-base";
import { TrainingCache } from "./forward";
import { responseOnlyCe } from "./loss";
import type { TrainableLora } from "./lora-params";
import { type SftBatch } from "./dataset";

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
   *  bf16 — the array dtype, matching how the full backward accumulates (fp32
   *  here diverges MORE: measured 1.44% vs 0.97%). The residual ~1% on donor
   *  K/V grads is bf16 non-associativity (this pre-sum's order vs mlx's) — not a
   *  logic bug (single-consumer is bit-exact) and well within training tolerance.
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
