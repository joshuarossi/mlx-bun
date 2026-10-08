// Segmented backward: long-context LoRA SFT that streams the backward pass
// segment-by-segment so only ONE segment's activations are ever live, instead
// of holding every layer's recompute activations at once (the spike that makes
// naive gradient checkpointing crash at long context). Design + proof:
// `02d723a:docs/design/orpo-training.md` §5.3 (mechanism validated on a toy,
// SEG mode: 0.000% grad error, peak below per-layer
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
// `02d723a:docs/design/orpo-training.md` §5.3). mlx_vjp takes the cotangent
// directly, needs no surrogate, and does not leak.
//
// IMPORTANT lifetime fact: mlx `eval` does NOT detach — an eval'd array retains
// its upstream graph, so each forward boundary must be copied into a fresh leaf
// (detachLeaf) or it keeps a whole layer-stack's activations alive (~0.1 GB per
// 4-layer segment of within-step retention otherwise). The vjp objects are built
// ONCE and reused across steps; their closures read the per-step batch from a
// mutable holder.


import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { peakMemory } from "@mlx-bun/mlx/ffi";
import { Vjp } from "@mlx-bun/mlx/autograd";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";
import type { RuntimeModel } from "@mlx-bun/inference/models";
import type { PrefixLayout, SegmentedPass, SegmentedTraining, SharedKv } from "@mlx-bun/inference/contracts/mlx";
import {
  responseOnlyLogpMean, fusedLogpMeanFromHidden, chunkedLogpMeanFromHidden,
  orpoLossFromLogps, spanLogpMeanFromHidden, respSpanFromMask, combineFullNll,
  type ChunkCtx, type SftScope, type HeadSpan,
} from "./loss";
import { prefixGatherIdx, branchLogpMeanGathered, prefixFullNll } from "./prefix-shared";
import { declaredTraining } from "./declared";
import type { TrainableLora } from "./lora-params";
import { rowLength, type SftBatch, type DpoBatch } from "./dataset";

// MLX_BUN_SEG_MEM_LOG=1: log the within-step peak after each phase of the
// segmented step (forward+boundaries / head vjp / each segment backward).
// The trainer resets the peak at step start (MLX_BUN_MEM_LOG=1), so the phase
// where the monotone peak JUMPS is where the step's memory actually lives.
// (This is how the backlog-#2 refutation below was measured. An inter-segment
// clearCache was also tried and had NO effect — the watermark is live memory,
// not allocator cache retention.)
const SEG_MEM = runtimeValue("MLX_BUN_SEG_MEM_LOG") === "1";
const segMem = (label: string): void => {
  if (SEG_MEM) console.log(`  [seg-mem] ${label}: peak=${(peakMemory() / 1e9).toFixed(2)} GB`);
};

// Experiment toggle: which bounded head to use inside the segmented mlx_vjp.
// "checkpoint" = per-chunk Checkpoint recompute (bounds memory under nesting);
// anything else (default) = the analytic fused CustomVjp. The fused head bounds
// memory at the TOP level but not when nested in the segmented mlx_vjp (its
// per-chunk graph isn't freed incrementally there); Checkpoint does. See
// `02d723a:docs/design/orpo-training.md`.
const SEG_HEAD = runtimeValue("MLX_BUN_SEG_HEAD") ?? "checkpoint";
function boundedHeadFromHidden(
  model: RuntimeModel, h: MlxArray, ids: number[], mask: number[],
  chunkSize: number, sink: Array<{ dispose(): void }>, span?: HeadSpan,
): MlxArray {
  return SEG_HEAD === "fused"
    ? fusedLogpMeanFromHidden(model, h, ids, mask, chunkSize, sink, 0, false, span)
    : chunkedLogpMeanFromHidden(model, h, ids, mask, chunkSize, sink, span);
}

// Token-chunk size for the bounded SFT head (the ORPO paths take theirs from
// cfg.orpoChunkSize; SFT has no per-run knob, 512 matches the ORPO default).
const SFT_HEAD_CHUNK = Number(runtimeValue("MLX_BUN_SEG_HEAD_CHUNK") ?? "512");

/** [M,V]-bounded response-only CE from post-finalNorm hidden — the SFT
 *  segmented head (kernel-review backlog #8). Same span arithmetic and
 *  token-mean reduction as loss.ts responseOnlyCe, but the logits only ever
 *  exist per token-chunk ([chunk,V] Checkpoint recompute, or the fused
 *  CustomVjp head via MLX_BUN_SEG_HEAD) instead of the full [1,M,V] + its
 *  cotangent inside the head vjp. CE = −(mean response logp); per-position
 *  grads are bit-exact vs the whole-vocab head (chunking is over TOKEN
 *  positions; each position's full-V lse is computed unchanged — only the
 *  scalar loss VALUE can differ in fp association across chunks). */
export function boundedSftCe(
  model: RuntimeModel, hn: MlxArray, batch: SftBatch,
  sink: Array<{ dispose(): void }>, chunkSize = SFT_HEAD_CHUNK,
): MlxArray {
  const L = batch.ids[0]!.length;
  const startT = Math.max(0, batch.promptLens[0]! - 1); // first supervised input position
  const M = Math.min(rowLength(batch, 0), L) - 1 - startT;
  if (M <= 0) throw new Error("sftLoss: no response tokens to supervise");
  const mean = boundedHeadFromHidden(model, hn, batch.ids[0]!, [], chunkSize, sink, { startT, M });
  const neg = ops.mulScalar(mean, -1); // CE = −(mean logp); exact sign flip
  mean.dispose();
  const loss = ops.sumAxis(neg, 0, false); // [1] -> scalar, matches the vjp cotangent `one`
  neg.dispose();
  return loss;
}

/** Split `nLayers` into contiguous `[lo, hi)` ranges of at most `segSize`
 *  layers each (the last range may be shorter). `segSize` is the memory knob:
 *  fewer layers per segment -> lower peak, ~fixed total recompute time. */
export function planSegmentsBySize(nLayers: number, segSize: number): [number, number][] {
  if (segSize < 1) throw new Error(`planSegmentsBySize: segSize must be >= 1 (got ${segSize})`);
  const ranges: [number, number][] = [];
  for (let lo = 0; lo < nLayers; lo += segSize) ranges.push([lo, Math.min(lo + segSize, nLayers)]);
  return ranges;
}

// NOTE (2026-07-02, kernel-review backlog #2 REFUTED BY MEASUREMENT): a
// "full-attention isolation" planner (singleton segments for e4b's 7 full
// layers) was built and A/B'd @8K — ZERO peak win (18.09 vs 18.02 GB). The
// design §5 premise is false: mlx's sdpa BACKWARD materializes the O(L²)
// scores for EVERY layer (~3.5 GB/layer @8K on e4b — sliding's window is just
// an additive mask; measured: sliding pair +7.1 GB ≈ sliding+full +7.15). The
// worst segment is set by LAYER COUNT alone, so segSize IS the whole knob:
// segment_size 1 measures 14.59 GB @8K (+3% step time) vs 17.5 @seg2. Below
// that needs the [M,V]-bounded SFT head (backlog #8, ~3 GB head-vjp spike)
// and/or an O(L)-memory attention backward. Evidence:
// seg-isolation-smoke.ts (deleted 2026-08-23; git history) + MLX_BUN_SEG_MEM_LOG=1 probes.

/** Detach `a` into a graph-free LEAF holding its exact (evaluated) bytes, then
 *  dispose `a`. mlx retains the upstream graph after `eval`, so a segment
 *  boundary (or a value_and_grad output) would otherwise keep its whole layer
 *  stack's activations alive. Copying the bytes into a fresh leaf frees that
 *  graph. The leaf is a valid differentiable input for the per-segment vag. */
function detachLeaf(a: MlxArray): MlxArray {
  // Force a row-major copy first: the buffer is read linearly, so a
  // NON-contiguous input (e.g. a transposed donor K/V view) would be
  // byte-scrambled. `ops.contiguous` is a no-op for already-contiguous arrays
  // (hidden boundaries) and materializes row-major for strided views.
  // detachCopy = ONE mlx→mlx copy (backlog #9: the old
  // fromBytesCopy(rawBytes()) route was two copies via the JS heap).
  const c = ops.contiguous(a);
  const leaf = c.detachCopy();
  c.dispose();
  a.dispose();
  return leaf;
}

/** Batch detach: ONE evalAll barrier for the whole set (backlog #9 — each
 *  per-array eval was a separate blocking GPU drain; a segment's vjp returns
 *  dh + 2·consumed-donors + 2·targets arrays, so the per-segment sync count
 *  collapses from ~2+2n to 1), then one mlx→mlx copy each. Disposes inputs. */
function detachLeaves(arrs: MlxArray[]): MlxArray[] {
  const cs = arrs.map((a) => ops.contiguous(a));
  ops.evalAll(cs);
  const leaves = cs.map((c) => c.detachCopy());
  for (const c of cs) c.dispose();
  for (const a of arrs) a.dispose();
  return leaves;
}

/** Layer index a target's modulePath belongs to, or -1 (e.g. embedding/head). */
function targetLayer(modulePath: string): number {
  const m = modulePath.match(/\.layers\.(\d+)\./);
  return m ? Number(m[1]) : -1;
}

/** The int32 [1, len] input ids of a training sequence (all but its last token). */
function inputIdsOf(ids: number[], len: number): MlxArray {
  const host = new Int32Array(len);
  for (let t = 0; t < len; t++) host[t] = ids[t]!;
  return MlxArray.fromInt32(host, [1, len]);
}

type KvPair = { keys: MlxArray; values: MlxArray };

/** One sequence's forward state: its pass (caches, masks, per-layer inputs), the
 *  detached hidden boundaries and the detached reused-donor K/V boundaries. */
interface Stream {
  pass: SegmentedPass;
  boundaries: (MlxArray | null)[];
  donorBnd: Map<number, KvPair>;
}

/** The segmented-backward machinery shared by every driver: the segment/target
 *  topology, one reused vjp per segment, and the forward/backward walks over one
 *  sequence. The graph declares how a range of layers runs (`SegmentedTraining`);
 *  what crosses a segment boundary is the hidden stream plus, for a graph whose
 *  layers reuse an earlier layer's K/V (e4b: the last donor of each attention
 *  type), that donor K/V as a SECOND boundary stream WITH its own cotangent:
 *  the segment holding donor d PRODUCES its K/V (saved as a detached boundary),
 *  later segments with a sharer of d CONSUME it, and in the backward each
 *  consumer's vjp yields a cotangent on d's K/V (accumulated into dKV[d]) that
 *  seeds the producer's multi-output vjp [dh, dKV[d].k, dKV[d].v]. A graph
 *  without KV sharing has no donors, so both lists are empty. Per-layer inputs
 *  (e4b's per_layer_input tensor) are pure constant boundaries inside the pass:
 *  their LoRA (gate/projection) lives in the layer and is differentiated
 *  normally within each segment, while the tensor itself feeds in as a constant
 *  (its grad would flow to the embedding, not a LoRA target) — detached once,
 *  sliced per layer. The topology is a function of the architecture and the
 *  segmentation only, so it is computed once and shared by every stream. */
class SegmentedStreams {
  readonly seg: SegmentedTraining;
  readonly n: number; // number of LoRA targets
  readonly nSeg: number;
  readonly one: MlxArray; // scalar cotangent 1.0 for the (scalar) head loss
  private readonly segIdxs: number[][]; // target indices per segment
  private readonly consumes: number[][]; // reused donors consumed as input, per segment
  private readonly produces: number[][]; // reused donors output for later segments, per segment
  private readonly segVjps: Vjp[];
  // The stream whose backward is running: the reused vjp closures read its pass.
  private active: SegmentedPass | null = null;

  constructor(
    model: RuntimeModel,
    private readonly lora: TrainableLora,
    private readonly ranges: [number, number][],
    who: string,
  ) {
    const seg = this.seg = declaredTraining(model, "segmented", "segmented backward");
    const nLayers = seg.layerCount;
    const lastHi = ranges[ranges.length - 1]?.[1] ?? 0;
    if (ranges[0]?.[0] !== 0 || lastHi !== nLayers)
      throw new Error(`${who}: ranges must cover [0, ${nLayers}) (got ${JSON.stringify(ranges)})`);
    this.n = lora.targets.length;
    this.nSeg = ranges.length;
    const layerOf = lora.targets.map((t) => targetLayer(t.modulePath));
    this.segIdxs = ranges.map(([lo, hi]) =>
      layerOf.map((li, j) => ({ li, j })).filter((x) => x.li >= lo && x.li < hi).map((x) => x.j),
    );

    // Donor/sharer KV threading: for each reused donor d, the segment that holds
    // d PRODUCES its K/V; a later segment with a sharer of d CONSUMES it.
    const segOfLayer = new Map<number, number>();
    ranges.forEach(([lo, hi], k) => { for (let i = lo; i < hi; i++) segOfLayer.set(i, k); });
    const producerSeg = new Map<number, number>();
    for (const d of seg.sharedKv.reusedDonors) producerSeg.set(d, segOfLayer.get(d)!);
    this.consumes = ranges.map(() => []);
    this.produces = ranges.map(() => []);
    for (let i = 0; i < nLayers; i++) {
      const d = seg.sharedKv.donorOf[i];
      if (d === null || d === undefined) continue; // a layer attending its own K/V consumes nothing
      const sSeg = segOfLayer.get(i)!;
      const pSeg = producerSeg.get(d)!;
      if (sSeg > pSeg) { // cross-segment: thread d's K/V from pSeg to sSeg
        if (!this.consumes[sSeg]!.includes(d)) this.consumes[sSeg]!.push(d);
        if (!this.produces[pSeg]!.includes(d)) this.produces[pSeg]!.push(d);
      }
      // sSeg === pSeg: the range threads d internally; no boundary needed.
    }

    this.one = MlxArray.fromFloat32(new Float32Array([1]), []); // d(loss)/d(loss) = 1

    // One reused vjp per segment. Inputs: [boundary, (k,v)*consumes, (a,b)*lora].
    // Outputs: [h, (k,v)*produces]. apply(..., [dh, ...dKV]) returns vjps
    // [dh_in, (dk,dv)*consumes, (dA,dB)*lora]. The closures read the active pass.
    this.segVjps = ranges.map(([lo, hi], k) => {
      const idxs = this.segIdxs[k]!;
      const cons = this.consumes[k]!;
      const prod = this.produces[k]!;
      const base = 1 + 2 * cons.length; // first LoRA primal index
      const nOut = 1 + 2 * prod.length;
      return new Vjp((p) => {
        const boundary = p[0]!;
        const kvIn = new Map<number, SharedKv>();
        cons.forEach((d, ci) => kvIn.set(d, { kind: "plain", keys: p[1 + 2 * ci]!, values: p[1 + 2 * ci + 1]!, offset: 0 }));
        // Swap this segment's LoRA primals into the live LoraWeights so the
        // forward graph differentiates them; restore the originals after (the
        // primal wrappers are disposed by the vjp closure).
        const saved: [MlxArray, MlxArray][] = idxs.map((j) => [lora.targets[j]!.lw.a, lora.targets[j]!.lw.b]);
        idxs.forEach((j, s) => {
          lora.targets[j]!.lw.a = p[base + 2 * s]!;
          lora.targets[j]!.lw.b = p[base + 2 * s + 1]!;
        });
        try {
          const { h, donorKvOut } = this.active!.runRange(boundary, lo, hi, kvIn);
          const outs: MlxArray[] = [h];
          for (const d of prod) {
            const kv = donorKvOut.get(d)!;
            if (kv.kind !== "plain") throw new Error("segmented training: quantized donor KV is unsupported");
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
    });
  }

  /** Begin a stream over `ids` [1, T] and run its forward segment-by-segment,
   *  saving detached boundaries (hidden + reused donor K/V). The last boundary
   *  (`boundaries[nSeg]`) feeds the loss head. A `prefix` layout makes the pass
   *  rope and mask the prefix-shared concat until the stream is disposed. */
  forward(ids: MlxArray, prefix?: PrefixLayout): Stream {
    const pass = this.seg.begin(ids, prefix);
    const st: Stream = { pass, boundaries: [], donorBnd: new Map() };
    try {
      st.boundaries.push(detachLeaf(pass.input)); // [1, T, hidden]
      for (let k = 0; k < this.nSeg; k++) {
        const [lo, hi] = this.ranges[k]!;
        const kvIn = new Map<number, SharedKv>();
        for (const d of this.consumes[k]!) {
          const b = st.donorBnd.get(d)!;
          kvIn.set(d, { kind: "plain", keys: b.keys, values: b.values, offset: 0 });
        }
        const { h, donorKvOut } = pass.runRange(st.boundaries[k]!, lo, hi, kvIn);
        for (const d of this.produces[k]!) {
          const kv = donorKvOut.get(d)!;
          if (kv.kind !== "plain") throw new Error("segmented training: quantized donor KV is unsupported");
          st.donorBnd.set(d, { keys: detachLeaf(kv.keys), values: detachLeaf(kv.values) });
        }
        for (const [d, kv] of donorKvOut)
          if (!this.produces[k]!.includes(d) && kv.kind === "plain") { kv.keys.dispose(); kv.values.dispose(); }
        st.boundaries.push(detachLeaf(h));
        segMem(`fwd seg ${k} [${lo},${hi})`);
      }
    } catch (error) {
      this.disposeStream(st);
      throw error;
    }
    return st;
  }

  /** Backward one stream in reverse over segments (vjp, cotangents dh + dKV).
   *  Takes ownership of `dhSeed` (the head's cotangent for the last boundary)
   *  and fills `grads` (length 2n) in place with the stream's LoRA gradients.
   *  Reused-donor cotangents accumulate per stream (bf16). Segment-0 dh_in is
   *  the gradient w.r.t. the embedding (and per-layer input), which carry no
   *  LoRA target, so it is dropped. */
  backward(st: Stream, dhSeed: MlxArray, grads: (MlxArray | null)[]): void {
    const { lora, ranges, segIdxs, consumes, produces, n } = this;
    this.active = st.pass;
    const dKV = new Map<number, KvPair>(); // accumulated reused-donor cotangents
    let dhOut: MlxArray | null = dhSeed;
    try {
      for (let k = this.nSeg - 1; k >= 0; k--) {
        const idxs = segIdxs[k]!;
        const cons = consumes[k]!;
        const prod = produces[k]!;
        const dh = dhOut!;

        const primals: MlxArray[] = [st.boundaries[k]!];
        for (const d of cons) { const b = st.donorBnd.get(d)!; primals.push(b.keys, b.values); }
        for (const j of idxs) primals.push(lora.targets[j]!.lw.a, lora.targets[j]!.lw.b);

        const cots: MlxArray[] = [dh];
        for (const d of prod) {
          const acc = dKV.get(d)!; // set by the consumer segments already processed (reverse order)
          cots.push(acc.keys, acc.values);
        }

        const res = this.segVjps[k]!.apply(primals, cots);
        for (const o of res.outputs) o.dispose(); // segment outputs — unused (only the vjps matter)

        // vjps[0] = dh_in (grad w.r.t. this segment's input boundary) -> dh for
        // segment k-1; then (dk,dv) per consumed donor; then (dA,dB) per LoRA,
        // scattered into the global flat vector. Detached to graph-free leaves
        // (eval doesn't detach; keeps peak bounded) — ONE barrier for the
        // segment's whole vjp set.
        const leaves = detachLeaves(res.vjps);
        const newDh = leaves[0]!;
        cons.forEach((d, ci) => {
          this.accumulateDKV(dKV, d, leaves[1 + 2 * ci]!, leaves[1 + 2 * ci + 1]!);
        });
        const base = 1 + 2 * cons.length;
        idxs.forEach((j, s) => {
          grads[j] = leaves[base + 2 * s]!; // dA
          grads[n + j] = leaves[base + 2 * s + 1]!; // dB
        });

        dh.dispose(); // consumed as this segment's cotangent
        dhOut = newDh;
        // produced donors' cotangents are now consumed -> free them + their boundary.
        for (const d of prod) {
          const acc = dKV.get(d)!; acc.keys.dispose(); acc.values.dispose(); dKV.delete(d);
          const b = st.donorBnd.get(d)!; b.keys.dispose(); b.values.dispose(); st.donorBnd.delete(d);
        }
        st.boundaries[k]!.dispose();
        st.boundaries[k] = null;
        segMem(`bwd seg ${k} [${ranges[k]![0]},${ranges[k]![1]})`);
      }
    } finally {
      dhOut?.dispose(); // segment-0 dh_in — no LoRA there
      for (const kv of dKV.values()) { kv.keys.dispose(); kv.values.dispose(); }
      this.active = null;
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

  /** Release whatever a stream still holds (surviving boundaries, donor K/V, its pass). */
  disposeStream(st: Stream | null): void {
    if (!st) return;
    for (const b of st.boundaries) b?.dispose();
    for (const kv of st.donorBnd.values()) { kv.keys.dispose(); kv.values.dispose(); }
    st.pass.dispose();
  }

  /** The chosen and rejected branches' LoRA gradients summed into one flat vector. */
  sumGrads(gradsC: (MlxArray | null)[], gradsR: (MlxArray | null)[]): MlxArray[] {
    return gradsC.map((gc, i) => {
      const gr = gradsR[i]!;
      const sum = ops.add(gc!, gr);
      gc!.dispose(); gr.dispose();
      gradsC[i] = null; gradsR[i] = null;
      return detachLeaf(sum);
    });
  }

  dispose(): void {
    for (const v of this.segVjps) v.dispose();
    this.one.dispose();
  }
}

/** Reusable segmented-backward driver for one (model, lora, segmentation). Build
 *  ONCE per training run and call `.step(batch)` each iteration — the per-segment
 *  value_and_grads are created up front and reused (rebuilding them every step
 *  leaks at the mlx level). Returns the loss scalar and the LoRA gradients in
 *  `flatParams(lora)` order ([...A, ...B] over targets), drop-in for
 *  `ValueAndGrad.apply(flatParams(lora))`. Caller owns the returned arrays.
 *
 *  The active adapter must be attached (attachForTraining) so the layer forward
 *  picks up the swapped LoRA leaves via loraState. B=1 SFT only. The graph must
 *  declare `segmented` training. */
export class SegmentedBackward {
  private readonly streams: SegmentedStreams;
  private readonly headVjp: Vjp;
  // Per-step context the (reused) closures read.
  private curBatch: SftBatch | null = null;
  // Bounded-head per-step transients (chunk slices + Checkpoint/CustomVjp
  // objects): the head backward recomputes through them, so they are disposed
  // only AFTER the head vjp's outputs are detached (which forces the eval).
  private headSink: Array<{ dispose(): void }> = [];
  private disposed = false;

  constructor(model: RuntimeModel, lora: TrainableLora, ranges: [number, number][]) {
    const streams = this.streams = new SegmentedStreams(model, lora, ranges, "SegmentedBackward");
    // Loss head: vjp of finalNorm + the [M,V]-BOUNDED response CE over the last
    // boundary leaf (kernel-review backlog #8: the old responseOnlyCe here
    // materialized [1,M,V] logits + cotangents inside the head vjp — measured
    // ~3 GB @8K on e4b, the exact transient the segmentation exists to kill).
    // CE = −(mean response logp); span and reduction identical to
    // responseOnlyCe, per-position grads bit-exact (chunking is over token
    // positions — each position's full-V lse/softmax is computed unchanged).
    // outputs[0] = loss scalar; vjps[0] = dLoss/d(last residual stream) = dh.
    this.headVjp = new Vjp((p) => {
      const hn = streams.seg.finalNorm(p[0]!);
      const loss = boundedSftCe(model, hn, this.curBatch!, this.headSink);
      hn.dispose();
      return [loss];
    }, 1);
  }

  step(batch: SftBatch): { value: MlxArray; grads: MlxArray[] } {
    if (this.disposed) throw new Error("SegmentedBackward used after dispose");
    const { streams } = this;
    const { n, nSeg } = streams;
    const B = batch.ids.length;
    if (B !== 1) throw new Error("SegmentedBackward: only B=1 is supported (responseOnlyCe path)");
    const L = batch.ids[0]!.length;
    if (L < 2) throw new Error("SegmentedBackward: sequence too short (need >= 2 tokens)");
    this.curBatch = batch;

    const inputIds = inputIdsOf(batch.ids[0]!, L - 1);
    let st: Stream | null = null;
    let value: MlxArray | null = null;
    let dhOut: MlxArray | null = null;
    let transferred = false;
    const grads: (MlxArray | null)[] = new Array(2 * n).fill(null);

    try {
      // --- 1. Forward, saving detached boundaries at segment edges. --------
      st = streams.forward(inputIds);

      // --- 2. Loss head over the last boundary (vjp with cotangent 1.0). ---
      // The bounded head pushes per-step chunk slices + Checkpoints into
      // headSink; the head BACKWARD recomputes through them, so materialize
      // the full head-vjp graph BEFORE freeing the sink (lazy-eval UAF
      // discipline, same as the ORPO classes).
      this.headSink = [];
      const head = this.headVjp.apply([st.boundaries[nSeg]!], [streams.one]);
      ops.evalAll([head.outputs[0]!, head.vjps[0]!]);
      value = detachLeaf(head.outputs[0]!); // scalar loss, detached from the head graph (frees logits)
      dhOut = detachLeaf(head.vjps[0]!); // dLoss / d(last residual stream), graph-free
      for (const d of this.headSink) d.dispose();
      this.headSink = [];
      st.boundaries[nSeg]!.dispose();
      st.boundaries[nSeg] = null;
      segMem("head vjp");

      // --- 3. Backward, reverse over segments (vjp, cotangent = dh). --------
      const seed = dhOut; dhOut = null;
      streams.backward(st, seed, grads);

      transferred = true;
      return { value: value!, grads: grads as MlxArray[] };
    } finally {
      inputIds.dispose();
      this.curBatch = null;
      for (const d of this.headSink) d.dispose(); // no-op unless the head threw mid-step
      this.headSink = [];
      dhOut?.dispose();
      streams.disposeStream(st);
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
    this.streams.dispose();
  }
}

// ===========================================================================
// SegmentedBackwardOrpo: segmented backward for ORPO (B=1).
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

/** Segmented backward for ORPO (B=1). Runs chosen+rejected forwards
 *  segment-by-segment, accumulating LoRA gradients from both branches. */
export class SegmentedBackwardOrpo {
  private readonly streams: SegmentedStreams;
  private readonly headVjp: Vjp;
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
    model: RuntimeModel,
    lora: TrainableLora,
    ranges: [number, number][],
    private readonly lambda: number,
    private readonly fusedChunkSize = 0,
    private readonly sftScope: SftScope = "response",
  ) {
    const streams = this.streams = new SegmentedStreams(model, lora, ranges, "SegmentedBackwardOrpo");

    // Head VJP: inputs = [h_chosen_last, h_rejected_last] (pre-finalNorm at last boundary).
    // Applies finalNorm to each, computes ℓw and ℓr, returns scalar orpo loss.
    // nOut = 1 (one scalar loss output, one cotangent needed from caller).
    // apply([hC, hR], [one]) returns vjps[0] = dh_chosen, vjps[1] = dh_rejected.
    this.headVjp = new Vjp((p) => {
      const hnC = streams.seg.finalNorm(p[0]!); // [1, T, hidden]
      const hnR = streams.seg.finalNorm(p[1]!);
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
  }

  step(batch: DpoBatch): { value: MlxArray; grads: MlxArray[] } {
    if (this.disposed) throw new Error("SegmentedBackwardOrpo used after dispose");
    const { streams } = this;
    const { n, nSeg } = streams;
    if (batch.chosenIds.length !== 1) throw new Error("SegmentedBackwardOrpo: only B=1 is supported");
    // Store per-step batch for the head VJP closure
    this.curChosenIds = batch.chosenIds[0]!;
    this.curChosenMask = batch.chosenMask[0]!;
    this.curRejectedIds = batch.rejectedIds[0]!;
    this.curRejectedMask = batch.rejectedMask[0]!;

    const Lc = batch.chosenIds[0]!.length;
    const Lr = batch.rejectedIds[0]!.length;
    if (Lc < 2 || Lr < 2) throw new Error("SegmentedBackwardOrpo: sequences too short");
    const gradsC: (MlxArray | null)[] = new Array(2 * n).fill(null);
    const gradsR: (MlxArray | null)[] = new Array(2 * n).fill(null);
    let stC: Stream | null = null;
    let stR: Stream | null = null;
    let value: MlxArray | null = null;
    let dhC: MlxArray | null = null;
    let dhR: MlxArray | null = null;
    let transferred = false;

    try {
      // --- 1. Forward chosen, then rejected ---
      const chosenIds = inputIdsOf(batch.chosenIds[0]!, Lc - 1);
      try { stC = streams.forward(chosenIds); } finally { chosenIds.dispose(); }
      const rejectedIds = inputIdsOf(batch.rejectedIds[0]!, Lr - 1);
      try { stR = streams.forward(rejectedIds); } finally { rejectedIds.dispose(); }

      // --- 2. Head VJP: [last_chosen, last_rejected] → [loss], cotangent 1.0 → [dh_c, dh_r] ---
      // The fused head pushes per-step CustomVjps + response slices into headSink;
      // they recompute during this apply's backward, so dispose only AFTER the
      // outputs/vjps are detached to leaves (which forces the eval).
      this.headSink = [];
      const head = this.headVjp.apply([stC.boundaries[nSeg]!, stR.boundaries[nSeg]!], [streams.one]);
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

      // --- 3. Backward each branch (ownership of dh transfers to backward). ---
      const seedC = dhC; dhC = null;
      streams.backward(stC, seedC, gradsC);
      const seedR = dhR; dhR = null;
      streams.backward(stR, seedR, gradsR);

      // --- 4. Sum LoRA grads from both branches ---
      const grads = streams.sumGrads(gradsC, gradsR);

      transferred = true;
      return { value: value!, grads };
    } finally {
      this.curChosenIds = this.curChosenMask = this.curRejectedIds = this.curRejectedMask = null;
      dhC?.dispose(); dhR?.dispose();
      streams.disposeStream(stC);
      streams.disposeStream(stR);
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
    this.streams.dispose();
  }
}

// ===========================================================================
// SegmentedBackwardOrpoPrefix: segmented backward + PREFIX-SHARING (B=1).
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
//    NOT two branches. One boundary stream, one backward walk, one donor-KV thread.
//  - the pass is begun with the prefix layout, so the graph's masks are the
//    block-sparse (and, for sliding layers, logical-window) prefix masks and its
//    RoPE is block-wise for the WHOLE step: the streaming forward AND every
//    segment's recompute inside the per-segment vjp.
//  - the head gathers the chosen/rejected response hiddens from the final
//    [1,T,hidden] (via branchLogpMeanGathered — the same [M,V]-free per-branch
//    flash head the non-segmented prefix path uses) and ORPO-combines them. Its
//    vjp w.r.t. the last boundary is the full [1,T,hidden] dh (the gather's
//    takeAxis vjp scatter-adds each branch's response-position cotangent back
//    into the full sequence), which seeds the single segmented backward.
//
// The graph must declare both `segmented` and `prefixShared`.

export class SegmentedBackwardOrpoPrefix {
  private readonly streams: SegmentedStreams;
  private readonly headVjp: Vjp;
  // Per-step mutable context the (reused) closures read.
  private curP = 0;
  private curRc = 0;
  private curRr = 0;
  private curPromptIds: number[] | null = null;
  private curChosenResp: number[] | null = null;
  private curRejectedResp: number[] | null = null;
  private curChunk: ChunkCtx | undefined = undefined;
  private headSink: Array<{ dispose(): void }> = [];
  private disposed = false;

  constructor(
    model: RuntimeModel,
    lora: TrainableLora,
    ranges: [number, number][],
    private readonly lambda: number,
    private readonly chunkCtx?: ChunkCtx,
    private readonly sftScope: SftScope = "response",
  ) {
    declaredTraining(model, "prefixShared", "prefix-shared training");
    const streams = this.streams = new SegmentedStreams(model, lora, ranges, "SegmentedBackwardOrpoPrefix");

    // Head VJP: input = the last boundary [1, T, hidden] (pre-finalNorm). Applies
    // finalNorm, gathers each branch's response hiddens, computes ℓw/ℓr through the
    // [M,V]-free per-branch head (branchLogpMeanGathered), returns the scalar orpo
    // loss. nOut = 1; apply([h_last], [one]) returns vjps[0] = dh [1, T, hidden]
    // (the gather's takeAxis vjp scatter-adds the per-branch dh into the full seq).
    this.headVjp = new Vjp((p) => {
      const hn = streams.seg.finalNorm(p[0]!); // [1, T, hidden]
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
  }

  /** One ORPO step over the prefix-shared concat. `promptIds`/`chosenResp`/
   *  `rejectedResp` come from splitPrefixBatch. Returns the loss + LoRA grads in
   *  flatParams(lora) order (caller owns). */
  stepPrefix(promptIds: number[], chosenResp: number[], rejectedResp: number[]): { value: MlxArray; grads: MlxArray[] } {
    if (this.disposed) throw new Error("SegmentedBackwardOrpoPrefix used after dispose");
    const { streams } = this;
    const { n, nSeg } = streams;
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

    const concat = new Int32Array(T);
    concat.set(promptIds, 0);
    concat.set(chosenResp, P);
    concat.set(rejectedResp, P + Rc);
    const inputIds = MlxArray.fromInt32(concat, [1, T]);

    let st: Stream | null = null;
    let value: MlxArray | null = null;
    let dhOut: MlxArray | null = null;
    let transferred = false;
    const grads: (MlxArray | null)[] = new Array(2 * n).fill(null);

    try {
      // --- 1. Forward over the concat, saving detached boundaries at seg edges. ---
      // Block-wise RoPE + prefix masks are active for the WHOLE step (forward +
      // every segment recompute) until the stream's pass is disposed.
      st = streams.forward(inputIds, { P, Rc, Rr });

      // --- 2. Head over the last boundary (vjp, cotangent 1.0) -> [dh 1,T,hidden]. ---
      const head = this.headVjp.apply([st.boundaries[nSeg]!], [streams.one]);
      // Force the FULL head-VJP graph (incl. the nested flash-CCE CustomVjp backward,
      // which reads savedLse/savedBlockMax) to materialize BEFORE the headSink dispose
      // below — else that deferred backward can run AFTER its lse/blockMax are freed
      // under MLX lazy eval (a use-after-free → segfault at a tiny address, ~step 100).
      ops.evalAll([head.outputs[0]!, head.vjps[0]!]);
      value = detachLeaf(head.outputs[0]!);
      dhOut = detachLeaf(head.vjps[0]!); // dLoss / d(last residual stream), [1,T,hidden]
      for (const d of this.headSink) d.dispose();
      this.headSink = [];
      st.boundaries[nSeg]!.dispose(); st.boundaries[nSeg] = null;

      // --- 3. Backward, reverse over segments (single stream, cotangent = dh). ---
      const seed = dhOut; dhOut = null;
      streams.backward(st, seed, grads);

      transferred = true;
      return { value: value!, grads: grads as MlxArray[] };
    } finally {
      inputIds.dispose();
      this.curPromptIds = this.curChosenResp = this.curRejectedResp = null;
      for (const d of this.headSink) d.dispose();
      this.headSink = [];
      dhOut?.dispose();
      streams.disposeStream(st);
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
    this.streams.dispose();
  }
}
