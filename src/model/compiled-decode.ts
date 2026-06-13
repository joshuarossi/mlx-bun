// Compiled decode step (Phase A of docs/design/optimization_plan.md).
//
// The single-token decode graph is identical token-to-token except for
// integer state (RoPE offset, cache write position, active length). This
// module wraps one whole step — embed → all layers → finalNorm → logits —
// in an mx.compile'd closure (src/mlx/compile.ts) so the per-step graph
// is REPLAYED in C++ instead of rebuilt through ~2000 bun:ffi crossings.
//
// How the per-step state crosses into a fixed graph:
// - RoPE offset and ring write positions enter as int32 ARRAY inputs
//   (fast_rope_dynamic / slice_update_dynamic) — values change, graph
//   doesn't.
// - Shapes that grow (the active KV prefix) enter as inputs and the
//   closure is compiled shapeless=true: dim sizes may vary per step,
//   ndim/dtype may not.
//
// The trace runs the UNMODIFIED Gemma4Model.forwardHidden against trace
// adapters that subclass the real cache classes — so the compiled graph
// is the production op sequence by construction, not a reimplementation.
// Per-cache fetch strategy (see DecodeStepPlan in gemma4.ts):
// - "concat": graph returns this step's (quantized) KV row; the buffer
//   write stays OUTSIDE, right after the step — the buffer keeps a single
//   reference at its slice_update, so mlx donates it (no per-step copy).
// - "ring": write in-graph at a dynamic position, read the full updated
//   ring — bit-exact with the rotating steady state, where a concat
//   would permute KV positions and change reduction order.
//
// Anything this module can't express falls back to the uncompiled path
// (generate.ts catches and disables for the generation): active LoRA
// adapters (their weights would bake into the trace as constants),
// unknown cache classes, diverged cache offsets.

import { MlxArray } from "../mlx/array";
import { CompiledFunction } from "../mlx/compile";
import * as ops from "../mlx/ops";
import { perfKernelEnabled } from "./fused-decode-kernel";
import {
  Gemma4Model,
  KVCache,
  QuantizedKVCache,
  RotatingKVCache,
  RotatingQuantizedKVCache,
  setCompiledTrace,
  type Cache,
  type DecodeStepPlan,
  type SharedKv,
} from "./gemma4";

type AnyCache = KVCache | QuantizedKVCache | RotatingKVCache | RotatingQuantizedKVCache;

const fullSlice = (a: MlxArray): MlxArray => {
  const stop = a.shape;
  return a.slice(stop.map(() => 0), stop);
};

const catAxis2 = (a: ops.QuantizedTensor, b: ops.QuantizedTensor): ops.QuantizedTensor => ({
  packed: ops.concatAxis([a.packed, b.packed], 2),
  scales: ops.concatAxis([a.scales, b.scales], 2),
  biases: ops.concatAxis([a.biases, b.biases], 2),
});

// --- trace adapters ---------------------------------------------------------
// Subclasses so Attention.forward's instanceof dispatch (quantized vs
// plain) routes exactly as it does for the real cache. `offset` is set
// for completeness only: at L=1 every makeMask returns mode "" and the
// RoPE offset rides the ropeOffsetArr input, so the baked value cannot
// leak into the graph. Adapters live only for the duration of one trace.

/** Growing plain cache (KVCache, or RotatingKVCache before the window
 *  fills): fetch = concat(active prefix, new row); new row is a closure
 *  output for the outside write. */
class TraceConcatPlain extends KVCache {
  override readonly ropeOffsetArr: MlxArray;
  outs: MlxArray[] = [];
  constructor(
    offset: number,
    readonly activeK: MlxArray,
    readonly activeV: MlxArray,
    ropeOffsetArr: MlxArray,
  ) {
    super();
    this.offset = offset;
    this.ropeOffsetArr = ropeOffsetArr;
  }

  override updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    // same-shape reshape: an owned alias that survives the caller's
    // dispose of k/v, so the row can be a closure output
    this.outs = [ops.reshape(k, k.shape), ops.reshape(v, v.shape)];
    return [
      ops.concatAxis([this.activeK, k], 2),
      ops.concatAxis([this.activeV, v], 2),
    ];
  }
}

/** Growing quantized cache: quantize in-graph, fetch = per-component
 *  concat, the six quantized row components are closure outputs. */
class TraceConcatQuant extends QuantizedKVCache {
  override readonly ropeOffsetArr: MlxArray;
  outs: MlxArray[] = [];
  constructor(
    offset: number, groupSize: number, bits: number,
    readonly activeKq: ops.QuantizedTensor,
    readonly activeVq: ops.QuantizedTensor,
    ropeOffsetArr: MlxArray,
  ) {
    super(groupSize, bits);
    this.offset = offset;
    this.ropeOffsetArr = ropeOffsetArr;
  }

  override updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor] {
    const kq = ops.quantize(k, this.groupSize, this.bits);
    const vq = ops.quantize(v, this.groupSize, this.bits);
    this.outs = [kq.packed, kq.scales, kq.biases, vq.packed, vq.scales, vq.biases];
    return [catAxis2(this.activeKq, kq), catAxis2(this.activeVq, vq)];
  }
}

/** Rotating plain cache at steady state: write in-graph at the dynamic
 *  ring position, fetch the full updated buffer (mirrors #updateInPlace →
 *  #fetchAll); updated buffers are closure outputs. */
class TraceRingPlain extends RotatingKVCache {
  override readonly ropeOffsetArr: MlxArray;
  outs: MlxArray[] = [];
  constructor(
    offset: number, maxSize: number,
    readonly bufK: MlxArray,
    readonly bufV: MlxArray,
    readonly writePosArr: MlxArray,
    ropeOffsetArr: MlxArray,
  ) {
    super(maxSize);
    this.offset = offset;
    this.ropeOffsetArr = ropeOffsetArr;
  }

  override updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const updK = ops.sliceUpdateDynamic(this.bufK, k, this.writePosArr, [2]);
    const updV = ops.sliceUpdateDynamic(this.bufV, v, this.writePosArr, [2]);
    this.outs = [updK, updV];
    return [fullSlice(updK), fullSlice(updV)];
  }
}

/** Rotating quantized cache at steady state: quantize + six dynamic
 *  writes in-graph, fetch full updated buffers (mirrors the oracle's
 *  _update_in_place → _active_slices). */
class TraceRingQuant extends RotatingQuantizedKVCache {
  override readonly ropeOffsetArr: MlxArray;
  outs: MlxArray[] = [];
  constructor(
    offset: number, maxSize: number, groupSize: number, bits: number,
    readonly bufKq: ops.QuantizedTensor,
    readonly bufVq: ops.QuantizedTensor,
    readonly writePosArr: MlxArray,
    ropeOffsetArr: MlxArray,
  ) {
    super(maxSize, groupSize, bits);
    this.offset = offset;
    this.ropeOffsetArr = ropeOffsetArr;
  }

  override updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor] {
    const kq = ops.quantize(k, this.groupSize, this.bits);
    const vq = ops.quantize(v, this.groupSize, this.bits);
    const upd = (buf: ops.QuantizedTensor, row: ops.QuantizedTensor): ops.QuantizedTensor => ({
      packed: ops.sliceUpdateDynamic(buf.packed, row.packed, this.writePosArr, [2]),
      scales: ops.sliceUpdateDynamic(buf.scales, row.scales, this.writePosArr, [2]),
      biases: ops.sliceUpdateDynamic(buf.biases, row.biases, this.writePosArr, [2]),
    });
    const updK = upd(this.bufKq, kq);
    const updV = upd(this.bufVq, vq);
    for (const t of [kq, vq])
      for (const a of [t.packed, t.scales, t.biases]) a.dispose();
    this.outs = [updK.packed, updK.scales, updK.biases, updV.packed, updV.scales, updV.biases];
    return [
      { packed: fullSlice(updK.packed), scales: fullSlice(updK.scales), biases: fullSlice(updK.biases) },
      { packed: fullSlice(updV.packed), scales: fullSlice(updV.scales), biases: fullSlice(updV.biases) },
    ];
  }
}

// --- slot layout ------------------------------------------------------------

interface SlotDesc {
  kind: "p-cat" | "q-cat" | "p-ring" | "q-ring";
  offset: number;
  maxSize: number;
  groupSize: number;
  bits: number;
}

function slotDesc(c: AnyCache, plan: DecodeStepPlan): SlotDesc {
  const cat = plan.fetch === "concat";
  if (c instanceof QuantizedKVCache)
    return { kind: "q-cat", offset: c.offset, maxSize: 0, groupSize: c.groupSize, bits: c.bits };
  if (c instanceof RotatingQuantizedKVCache)
    return { kind: cat ? "q-cat" : "q-ring", offset: c.offset, maxSize: c.maxSize, groupSize: c.groupSize, bits: c.bits };
  if (c instanceof RotatingKVCache)
    return { kind: cat ? "p-cat" : "p-ring", offset: c.offset, maxSize: c.maxSize, groupSize: 0, bits: 0 };
  return { kind: "p-cat", offset: c.offset, maxSize: 0, groupSize: 0, bits: 0 };
}

/** Graph-shape signature: anything that changes the traced op sequence
 *  must appear here (cache kinds/quant params and the env flags read
 *  inside quantizedSdpa's dispatch). Offsets/capacities don't — they're
 *  array values or shapeless dims. */
function closureKey(descs: SlotDesc[]): string {
  const flags =
    `fd=${process.env.MLX_BUN_FUSED_DECODE === "1" ? 1 : 0}` +
    `,nf=${process.env.MLX_BUN_NO_FUSED_SDPA === "1" ? 1 : 0}` +
    `,pk=${process.env.MLX_BUN_PERF_KERNEL === "1" ? 1 : 0}`;
  return descs.map((d) => `${d.kind}:${d.groupSize}:${d.bits}`).join(",") + "|" + flags;
}

function makeTraceFn(model: Gemma4Model, descs: SlotDesc[]) {
  return (inputs: MlxArray[]): MlxArray[] => {
    const ropeOff = inputs[1]!;
    let pos = 2;
    const triple = (at: number): ops.QuantizedTensor => ({
      packed: inputs[at]!, scales: inputs[at + 1]!, biases: inputs[at + 2]!,
    });
    const adapters: (TraceConcatPlain | TraceConcatQuant | TraceRingPlain | TraceRingQuant)[] = [];
    for (const d of descs) {
      switch (d.kind) {
        case "p-cat":
          adapters.push(new TraceConcatPlain(d.offset, inputs[pos]!, inputs[pos + 1]!, ropeOff));
          pos += 2;
          break;
        case "q-cat":
          adapters.push(new TraceConcatQuant(d.offset, d.groupSize, d.bits, triple(pos), triple(pos + 3), ropeOff));
          pos += 6;
          break;
        case "p-ring":
          adapters.push(new TraceRingPlain(d.offset, d.maxSize, inputs[pos]!, inputs[pos + 1]!, inputs[pos + 2]!, ropeOff));
          pos += 3;
          break;
        case "q-ring":
          adapters.push(new TraceRingQuant(d.offset, d.maxSize, d.groupSize, d.bits, triple(pos), triple(pos + 3), inputs[pos + 6]!, ropeOff));
          pos += 7;
          break;
      }
    }
    setCompiledTrace(true);
    try {
      const ids = ops.reshape(inputs[0]!, [1, 1]);
      const h = model.forwardHidden(ids, adapters as unknown as Cache[]);
      ids.dispose();
      const logits = model.logitsFromHidden(h);
      h.dispose();
      return [logits, ...adapters.flatMap((a) => a.outs)];
    } finally {
      setCompiledTrace(false);
    }
  };
}

// --- segmented mode (dense models) ------------------------------------------
// Measured (PLAN Phase A findings): the concat fetch materializes a copy
// of each growing cache's active window every step — per-op encode
// overhead + 2× byte traffic + allocator churn from monotonically
// growing transient sizes. Ring-phase caches (write-in-graph, read the
// updated buffer) cost nothing extra. So for models without KV sharing /
// per-layer inputs / MoE, the compiled graph is SEGMENTED at growing-
// cache layers: those layers run uncompiled (today's exact view-based
// ops — no copies, bit-exact trivially) and everything between them
// replays compiled. At steady state on the 12B that is 6 JS layers and
// 7 compiled segments per step.

/** Non-mutating phase check (segmented mode decides layer placement
 *  BEFORE any cache bookkeeping runs). Mirrors prepareDecodeStep's
 *  outcome: rotating caches go ring once the next write lands at or past
 *  the window; everything else grows. Under the perf kernel, quantized
 *  layers run as JS layers regardless — the CustomKernel primitive has
 *  no output_shapes and cannot live inside a compiled closure. */
function decodePhase(c: AnyCache): "concat" | "ring" {
  if (perfKernelEnabled() && (c instanceof QuantizedKVCache || c instanceof RotatingQuantizedKVCache))
    return "concat";
  if (c instanceof RotatingKVCache || c instanceof RotatingQuantizedKVCache)
    return c.offset + 1 < c.maxSize ? "concat" : "ring";
  return "concat";
}

function disposeShared(s: SharedKv): void {
  if (s.kind === "plain") {
    s.keys.dispose();
    s.values.dispose();
  } else {
    for (const t of [s.keys, s.values])
      for (const a of [t.packed, t.scales, t.biases]) a.dispose();
  }
}

/** Trace one compiled segment: layers [from, to) — all ring caches —
 *  with embed before (first) and finalNorm+logits after (last).
 *  Input layout: [idsOrH, ropeOffset, ...ring slots in layer order].
 *  Output layout: [hOrLogits, ...ring buffer updates]. */
function makeSegmentTraceFn(
  model: Gemma4Model, descs: SlotDesc[], from: number, to: number,
  first: boolean, last: boolean,
) {
  return (inputs: MlxArray[]): MlxArray[] => {
    setCompiledTrace(true);
    try {
      const ropeOff = inputs[1]!;
      let pos = 2;
      const triple = (at: number): ops.QuantizedTensor => ({
        packed: inputs[at]!, scales: inputs[at + 1]!, biases: inputs[at + 2]!,
      });
      const adapters: (TraceRingPlain | TraceRingQuant)[] = [];
      for (const d of descs) {
        if (d.kind === "p-ring") {
          adapters.push(new TraceRingPlain(d.offset, d.maxSize, inputs[pos]!, inputs[pos + 1]!, inputs[pos + 2]!, ropeOff));
          pos += 3;
        } else {
          adapters.push(new TraceRingQuant(d.offset, d.maxSize, d.groupSize, d.bits, triple(pos), triple(pos + 3), inputs[pos + 6]!, ropeOff));
          pos += 7;
        }
      }

      let h: MlxArray;
      if (first) {
        const ids = ops.reshape(inputs[0]!, [1, 1]);
        const embedded = model.embed.encode(ids);
        ids.dispose();
        h = ops.mulScalar(embedded, model.embedScale);
        embedded.dispose();
      } else {
        // owned alias of the carried hidden state (constant [1,1,H])
        h = ops.reshape(inputs[0]!, inputs[0]!.shape);
      }

      for (let i = from; i < to; i++) {
        const layer = model.layers[i]!;
        const adapter = adapters[i - from]!;
        const window = layer.layerType === "sliding_attention" ? model.windowSize : null;
        const mask = adapter.makeMask(1, window); // N=1 → mode ""
        const { h: next, shared } = layer.forward(h, mask, adapter as unknown as Cache, null, null);
        h.dispose();
        h = next;
        disposeShared(shared);
      }

      let out = h;
      if (last) {
        const normed = model.finalNorm.forward(h);
        h.dispose();
        out = model.logitsFromHidden(normed);
        normed.dispose();
      }
      return [out, ...adapters.flatMap((a) => a.outs)];
    } finally {
      setCompiledTrace(false);
    }
  };
}

// --- runner -----------------------------------------------------------------

const runners = new WeakMap<Gemma4Model, CompiledDecode>();

export class CompiledDecode {
  /** Total compiled steps executed (tests assert the compiled path ran
   *  rather than silently falling back). */
  static stepsExecuted = 0;
  /** Total UNEXPECTED retraces observed (a shapeless closure tracing more
   *  than once). Must stay 0: a retrace means per-step JS graph builds
   *  sneaked back in, which both wrecks the perf win and signals shape
   *  drift. Surfaced loudly; tests assert on it. */
  static unexpectedRetraces = 0;

  #closures = new Map<string, CompiledFunction>();
  /** Segmented mode: per layout key, one closure per segment (null for
   *  empty middle segments, which are identity). */
  #segClosures = new Map<string, (CompiledFunction | null)[]>();
  /** Closure keys whose apply failed (e.g. a primitive without
   *  output_shapes under shapeless replay): never re-trace these — the
   *  caller falls back to uncompiled without paying a trace per
   *  generation. */
  #broken = new Set<string>();
  /** Dense models (no KV sharing, per-layer inputs, or MoE) use the
   *  segmented form — growing-cache layers uncompiled, ring runs
   *  compiled. Models with cross-layer plumbing keep the whole-graph
   *  form (measured net-win on e4b; the concat copies it pays are the
   *  price of the sharing). */
  readonly #segmented: boolean;

  private constructor(readonly model: Gemma4Model) {
    const t = model.config.text;
    this.#segmented =
      t.numKvSharedLayers === 0 && !t.enableMoeBlock && model.perLayerWidth === 0;
  }

  static for(model: Gemma4Model): CompiledDecode {
    let r = runners.get(model);
    if (!r) {
      r = new CompiledDecode(model);
      runners.set(model, r);
    }
    return r;
  }

  /** Compilable this step? (Cheap; checked per generation setup.) */
  static supports(caches: Cache[]): boolean {
    return caches.every(
      (c) =>
        c instanceof KVCache ||
        c instanceof QuantizedKVCache ||
        c instanceof RotatingKVCache ||
        c instanceof RotatingQuantizedKVCache,
    );
  }

  /** One decode step: consumes the pending token array (uint32 [1],
   *  unevaluated is fine), advances every cache by one position, returns
   *  the logits node plus the cache-update nodes that must ride the same
   *  async_eval. Throws on unsupported state — caller falls back to the
   *  uncompiled path (any growth already done is benign). */
  step(cur: MlxArray, caches: Cache[]): { logits: MlxArray; evalWith: MlxArray[] } {
    const offset0 = caches[0]!.offset;
    for (const c of caches)
      if (c.offset !== offset0)
        throw new Error("compiled decode: cache offsets diverged");
    return this.#segmented
      ? this.#stepSegmented(cur, caches as AnyCache[], offset0)
      : this.#stepWhole(cur, caches as AnyCache[], offset0);
  }

  #stepWhole(cur: MlxArray, anyCaches: AnyCache[], offset0: number): { logits: MlxArray; evalWith: MlxArray[] } {
    const plans = anyCaches.map((c) => c.prepareDecodeStep());
    const descs = anyCaches.map((c, i) => slotDesc(c, plans[i]!));
    const key = closureKey(descs);
    if (this.#broken.has(key)) throw new Error(`compiled decode: known-broken closure ${key}`);

    // gather inputs — [cur, ropeOffset, ...per-cache slots]
    const inputs: MlxArray[] = [cur];
    const temps: MlxArray[] = [];
    const ropeOff = ops.fromInt32([offset0], []);
    temps.push(ropeOff);
    inputs.push(ropeOff);
    const writePosCache = new Map<number, MlxArray>();
    const writePos = (v: number): MlxArray => {
      let a = writePosCache.get(v);
      if (!a) {
        a = ops.fromInt32([v], [1]);
        writePosCache.set(v, a);
        temps.push(a);
      }
      return a;
    };
    const activeView = (a: MlxArray, len: number): MlxArray => {
      const stop = [...a.shape];
      stop[2] = len;
      const view = a.slice(stop.map(() => 0), stop);
      temps.push(view);
      return view;
    };
    for (let i = 0; i < anyCaches.length; i++) {
      const c = anyCaches[i]!;
      const p = plans[i]!;
      const d = descs[i]!;
      if (d.kind === "p-cat") {
        const pc = c as KVCache | RotatingKVCache;
        inputs.push(activeView(pc.keys!, p.activeLen), activeView(pc.values!, p.activeLen));
      } else if (d.kind === "q-cat") {
        const qc = c as QuantizedKVCache | RotatingQuantizedKVCache;
        for (const t of [qc.keys!, qc.values!])
          inputs.push(
            activeView(t.packed, p.activeLen),
            activeView(t.scales, p.activeLen),
            activeView(t.biases, p.activeLen),
          );
      } else if (d.kind === "p-ring") {
        const rc = c as RotatingKVCache;
        inputs.push(rc.keys!, rc.values!, writePos(p.writePos));
      } else {
        const rq = c as RotatingQuantizedKVCache;
        inputs.push(
          rq.keys!.packed, rq.keys!.scales, rq.keys!.biases,
          rq.values!.packed, rq.values!.scales, rq.values!.biases,
          writePos(p.writePos),
        );
      }
    }

    let closure = this.#closures.get(key);
    if (!closure) {
      closure = new CompiledFunction(makeTraceFn(this.model, descs), true);
      this.#closures.set(key, closure);
    }

    let outs: MlxArray[];
    try {
      outs = closure.apply(inputs);
    } catch (e) {
      this.#broken.add(key);
      throw e;
    } finally {
      for (const t of temps) t.dispose();
    }
    if (closure.traceCount > 1) {
      CompiledDecode.unexpectedRetraces++;
      console.warn(
        `compiled decode: closure retraced (count=${closure.traceCount}) — ` +
          `input ndim/dtype drifted for key ${key}`,
      );
    }

    const logits = outs[0]!;
    const evalWith: MlxArray[] = [];
    let oi = 1;
    for (let i = 0; i < anyCaches.length; i++) {
      const c = anyCaches[i]!;
      const d = descs[i]!;
      if (d.kind === "p-cat") {
        evalWith.push(...(c as KVCache | RotatingKVCache).writeDecodeStep(outs[oi]!, outs[oi + 1]!));
        oi += 2;
      } else if (d.kind === "q-cat") {
        evalWith.push(...(c as QuantizedKVCache | RotatingQuantizedKVCache).writeDecodeStep(outs.slice(oi, oi + 6)));
        oi += 6;
      } else if (d.kind === "p-ring") {
        // ring updates are ancestors of the logits (the in-graph fetch
        // reads the updated buffer) — no explicit eval root needed
        (c as RotatingKVCache).adoptDecodeStep(outs[oi]!, outs[oi + 1]!);
        oi += 2;
      } else {
        (c as RotatingQuantizedKVCache).adoptDecodeStep(outs.slice(oi, oi + 6));
        oi += 6;
      }
    }
    CompiledDecode.stepsExecuted++;
    return { logits, evalWith };
  }

  #stepSegmented(cur: MlxArray, anyCaches: AnyCache[], offset0: number): { logits: MlxArray; evalWith: MlxArray[] } {
    const phases = anyCaches.map(decodePhase);
    // ring caches need their host bookkeeping (growth/trim/rotation) now;
    // growing caches keep it inside their layer's real updateAndFetch
    const plans = anyCaches.map((c, i) =>
      phases[i] === "ring" ? c.prepareDecodeStep() : null,
    );

    // layout: consecutive ring layers form compiled segments, each
    // growing-cache layer runs uncompiled between them
    const segs: { from: number; to: number }[] = [];
    const jsLayers: number[] = [];
    let runStart = 0;
    for (let i = 0; i < anyCaches.length; i++) {
      if (phases[i] === "concat") {
        segs.push({ from: runStart, to: i });
        jsLayers.push(i);
        runStart = i + 1;
      }
    }
    segs.push({ from: runStart, to: anyCaches.length });

    // layout key: ring slot tags at their positions; js layers only by
    // position (their quant params live outside the closures)
    const key =
      "seg|" +
      anyCaches
        .map((c, i) => (phases[i] === "ring" ? `${slotDesc(c, plans[i]!).kind}:${slotDesc(c, plans[i]!).groupSize}:${slotDesc(c, plans[i]!).bits}` : "js"))
        .join(",") +
      `|fd=${process.env.MLX_BUN_FUSED_DECODE === "1" ? 1 : 0}` +
      `,nf=${process.env.MLX_BUN_NO_FUSED_SDPA === "1" ? 1 : 0}` +
      `,pk=${process.env.MLX_BUN_PERF_KERNEL === "1" ? 1 : 0}`;
    if (this.#broken.has(key)) throw new Error(`compiled decode: known-broken closure ${key}`);

    let closures = this.#segClosures.get(key);
    if (!closures) {
      closures = segs.map(() => null);
      this.#segClosures.set(key, closures);
    }

    const ropeOff = ops.fromInt32([offset0], []);
    const writePosCache = new Map<number, MlxArray>();
    const stepTemps: MlxArray[] = [ropeOff];
    const writePos = (v: number): MlxArray => {
      let a = writePosCache.get(v);
      if (!a) {
        a = ops.fromInt32([v], [1]);
        writePosCache.set(v, a);
        stepTemps.push(a);
      }
      return a;
    };

    const evalWith: MlxArray[] = [];
    let carried = cur; // seg 0 consumes the token array; later, hidden state
    let carriedOwned = false; // cur belongs to the caller
    try {
      for (let s = 0; s < segs.length; s++) {
        const { from, to } = segs[s]!;
        const firstSeg = s === 0;
        const lastSeg = s === segs.length - 1;
        if (firstSeg || lastSeg || from < to) {
          const descs = [];
          const inputs: MlxArray[] = [carried, ropeOff];
          for (let i = from; i < to; i++) {
            const c = anyCaches[i]!;
            const p = plans[i]!;
            descs.push(slotDesc(c, p));
            if (c instanceof RotatingQuantizedKVCache) {
              inputs.push(
                c.keys!.packed, c.keys!.scales, c.keys!.biases,
                c.values!.packed, c.values!.scales, c.values!.biases,
                writePos(p.writePos),
              );
            } else {
              const rc = c as RotatingKVCache;
              inputs.push(rc.keys!, rc.values!, writePos(p.writePos));
            }
          }
          let closure = closures[s];
          if (!closure) {
            closure = new CompiledFunction(
              makeSegmentTraceFn(this.model, descs, from, to, firstSeg, lastSeg),
              true,
            );
            closures[s] = closure;
          }
          let outs: MlxArray[];
          try {
            outs = closure.apply(inputs);
          } catch (e) {
            this.#broken.add(key);
            throw e;
          }
          if (closure.traceCount > 1) {
            CompiledDecode.unexpectedRetraces++;
            console.warn(`compiled decode: segment ${s} retraced for key ${key}`);
          }
          if (carriedOwned) carried.dispose();
          carried = outs[0]!;
          carriedOwned = true;
          // ring updates are ancestors of the carried hidden state (the
          // in-graph fetch reads the updated buffer): no eval roots
          let oi = 1;
          for (let i = from; i < to; i++) {
            const c = anyCaches[i]!;
            if (c instanceof RotatingQuantizedKVCache) {
              c.adoptDecodeStep(outs.slice(oi, oi + 6));
              oi += 6;
            } else {
              (c as RotatingKVCache).adoptDecodeStep(outs[oi]!, outs[oi + 1]!);
              oi += 2;
            }
          }
        }
        if (s < jsLayers.length) {
          const li = jsLayers[s]!;
          const layer = this.model.layers[li]!;
          const c = anyCaches[li]!;
          const window = layer.layerType === "sliding_attention" ? this.model.windowSize : null;
          const mask = c.makeMask(1, window); // N=1 → mode ""
          const { h: next, shared } = layer.forward(carried, mask, c, null, null);
          if (carriedOwned) carried.dispose();
          carried = next;
          carriedOwned = true;
          disposeShared(shared);
          mask.arr?.dispose();
        }
      }
    } finally {
      for (const t of stepTemps) t.dispose();
    }
    CompiledDecode.stepsExecuted++;
    return { logits: carried, evalWith };
  }

  /** Free compiled closures (model unload). */
  dispose(): void {
    for (const c of this.#closures.values()) c.dispose();
    this.#closures.clear();
    for (const arr of this.#segClosures.values())
      for (const c of arr) c?.dispose();
    this.#segClosures.clear();
  }
}
