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
import { Vjp } from "../mlx/autograd";
import type { MiniCPM5Model } from "../model/minicpm5";
import type { Cache } from "../model/gemma4-base";
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
  a.eval();
  const leaf = MlxArray.fromBytesCopy(a.rawBytes(), a.shape, a.dtype);
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
