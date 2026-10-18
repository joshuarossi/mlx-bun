import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.CompiledDecode
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/compiled-decode.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { rowOperationFor } from "../../runtime/row-operations";
// Compiled decode step (Phase A of `02d723a:docs/archive/investigations/optimization_plan.md`).
//
// The single-token decode graph is identical token-to-token except for
// integer state (RoPE offset, cache write position, active length). This
// module wraps one whole step — embed → all layers → finalNorm → logits —
// in an mx.compile'd closure (packages/mlx/src/compile.ts) so the per-step graph
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
// The trace runs the graph's own one-row decode operation (decode.one) against the stand-in
// each cache supplies for its slot (CompiledDecodeCache in
// packages/inference/src/contracts/mlx/cache.ts; the stand-ins live beside their
// cache classes in packages/inference/src/state/) — so the compiled graph
// is the production op sequence by construction, not a reimplementation, and this
// module names no cache class. Every layer reads its stand-in through the
// decode read (`appendDecode`), as the ordinary decode reads the real cache.
// Per-cache fetch strategy (see DecodeStepPlan in
// packages/inference/src/contracts/mlx/cache.ts):
// - "concat": graph returns this step's (quantized) KV row; the buffer
//   write stays OUTSIDE, right after the step — the buffer keeps a single
//   reference at its slice_update, so mlx donates it (no per-step copy).
// - "ring": write in-graph at a dynamic position, read the full updated
//   ring — bit-exact with the rotating steady state, where a concat
//   would permute KV positions and change reduction order.
//
// The composition chooses this step at load, for storage whose every cache it
// drives, and the scheduler never falls back: it refuses active LoRA
// adapters (their weights would bake into the trace as constants); a step this
// module cannot take throws.

import { disposeResources } from "../../runtime/resources";
import { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import * as ops from "@mlx-bun/mlx/ops";
import { decodeStepInputs } from "../../state/decode-step-inputs";
import { setCompiledTrace } from "../../runtime/compiled-trace";
import type { Cache, CompiledDecodeCache, DecodeSlot, DecodeTrace } from "../../contracts/mlx/cache";
import type { MlxCompiledDecodeStep, MlxRowTable, MlxCapturingForward } from "../../contracts/mlx/graph";

/** What the runner reads of the Gemma graph it compiles (the graph passes
 * itself; a structural type keeps the graph file and this one acyclic). */
export interface CompiledGemmaTarget {
  readonly config: { readonly text: { readonly numKvSharedLayers: number; readonly enableMoeBlock: boolean } };
  readonly perLayerWidth: number;
  readonly embedScale: number;
  readonly embed: { encode(ids: MlxArray): MlxArray };
  readonly finalNorm: { forward(h: MlxArray): MlxArray };
  /** A decoder layer reading its cache for one decode position. A donor layer
   *  returns its read, which the runner disposes. */
  readonly layers: readonly {
    forward(x: MlxArray, cache: Cache, phase: "decode", donor: null,
      perLayerInput: null): { h: MlxArray; donor: { dispose(): void } | null };
  }[];
  materializeGraphConstants(): void;
  /** The one-row decode operation the trace records. */
  readonly decode: MlxRowTable<MlxCapturingForward>;
  logitsFromHidden(hidden: MlxArray): MlxArray;
  /** Written graphs name their plain operations for the enclosing trace. */
  readonly traceDecode?: MlxCapturingForward;
  readonly traceLogits?: (hidden: MlxArray) => MlxArray;
  readonly traceLayers?: CompiledGemmaTarget["layers"];
}

/** Graph-shape signature: anything that changes the traced op sequence
 *  must appear here. That is the slots' cache kinds and quant params, and no
 *  kernel set: every composed affine set decodes with the one unfused kernel,
 *  which the quantized stand-ins are built with. Offsets/capacities don't —
 *  they're array values or shapeless dims. */
function closureKey(slots: DecodeSlot[]): string {
  return slots.map((d) => d.key).join(",");
}

/** The stand-ins for `slots` over the closure inputs that follow the token and
 *  RoPE offset, in slot order. */
function traceCaches(slots: readonly DecodeSlot[], inputs: readonly MlxArray[], ropeOff: MlxArray): DecodeTrace[] {
  let pos = 2;
  return slots.map((slot) => {
    const trace = slot.trace(inputs.slice(pos, pos + slot.inputs), ropeOff);
    pos += slot.inputs;
    return trace;
  });
}

function makeTraceFn(model: CompiledGemmaTarget, slots: DecodeSlot[]) {
  const decode = model.traceDecode ?? rowOperationFor(model.decode, 1);
  const head = model.traceLogits ?? model.logitsFromHidden.bind(model);
  return (inputs: MlxArray[]): MlxArray[] => {
    const adapters = traceCaches(slots, inputs, inputs[1]!);
    setCompiledTrace(true);
    try {
      const ids = ops.reshape(inputs[0]!, [1, 1]);
      const h = decode(ids, adapters, null) as MlxArray;
      ids.dispose();
      const logits = head(h);
      h.dispose();
      return [logits, ...adapters.flatMap((a) => a.outs)];
    } finally {
      setCompiledTrace(false);
    }
  };
}

// --- segmented mode (dense models) ------------------------------------------
// Measured: the concat fetch materializes a copy
// of each growing cache's active window every step — per-op encode
// overhead + 2× byte traffic + allocator churn from monotonically
// growing transient sizes. Ring-phase caches (write-in-graph, read the
// updated buffer) cost nothing extra. So for models without KV sharing /
// per-layer inputs / MoE, the compiled graph is SEGMENTED at growing-
// cache layers: those layers run uncompiled (today's exact view-based
// ops — no copies, bit-exact trivially) and everything between them
// replays compiled. At steady state on the 12B that is 6 JS layers and
// 7 compiled segments per step.

/** Trace one compiled segment: layers [from, to) — all ring caches, one slot each —
 *  with embed before (first) and finalNorm+logits after (last).
 *  Input layout: [idsOrH, ropeOffset, ...ring slots in layer order].
 *  Output layout: [hOrLogits, ...ring buffer updates]. */
function makeSegmentTraceFn(
  model: CompiledGemmaTarget, slots: DecodeSlot[], from: number, to: number,
  first: boolean, last: boolean,
) {
  const layers = model.traceLayers ?? model.layers;
  const head = model.traceLogits ?? model.logitsFromHidden.bind(model);
  return (inputs: MlxArray[]): MlxArray[] => {
    setCompiledTrace(true);
    try {
      const adapters = traceCaches(slots, inputs, inputs[1]!);

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
        const { h: next, donor } = layers[i]!.forward(h, adapters[i - from]!, "decode", null, null);
        h.dispose();
        h = next;
        donor?.dispose();
      }

      let out = h;
      if (last) {
        const normed = model.finalNorm.forward(h);
        h.dispose();
        out = head(normed);
        normed.dispose();
      }
      return [out, ...adapters.flatMap((a) => a.outs)];
    } finally {
      setCompiledTrace(false);
    }
  };
}

// --- runner -----------------------------------------------------------------

const runners = new WeakMap<object, CompiledDecode>();

/** The Gemma graph's compiled decode step (its `compiledDecodeStep`). */
export class CompiledDecode implements MlxCompiledDecodeStep {
  /** Total compiled steps executed (tests assert the compiled path ran
   *  rather than silently falling back). */
  static stepsExecuted = 0;
  /** Total UNEXPECTED retraces observed (a shapeless closure tracing more
   *  than once). Must stay 0: a retrace means per-step JS graph builds
   *  sneaked back in, which both wrecks the perf win and signals shape
   *  drift. Surfaced loudly; tests assert on it. */
  static unexpectedRetraces = 0;

  #disposed = false;
  #closures = new Map<string, CompiledFunction>();
  /** Segmented mode: per layout key, one closure per segment (null for
   *  empty middle segments, which are identity). */
  #segClosures = new Map<string, (CompiledFunction | null)[]>();
  /** Closure keys whose apply failed (e.g. a primitive without
   *  output_shapes under shapeless replay): never re-trace these — the
   *  step throws at once instead of paying a trace per
   *  generation. */
  #broken = new Set<string>();
  /** Dense models (no KV sharing, per-layer inputs, or MoE) use the
   *  segmented form — growing-cache layers uncompiled, ring runs
   *  compiled. Models with cross-layer plumbing keep the whole-graph
   *  form (measured net-win on e4b; the concat copies it pays are the
   *  price of the sharing). */
  readonly #segmented: boolean;

  private constructor(readonly model: CompiledGemmaTarget) {
    // A fresh resume has no prefill to evaluate lazy FP32 constants. Capture
    // their values, not their construction graph, in every compiled closure.
    model.materializeGraphConstants();
    const t = model.config.text;
    this.#segmented =
      t.numKvSharedLayers === 0 && !t.enableMoeBlock && model.perLayerWidth === 0;
  }

  static for(model: CompiledGemmaTarget): CompiledDecode {
    let r = runners.get(model);
    if (!r) {
      r = new CompiledDecode(model);
      runners.set(model, r);
    }
    return r;
  }

  /** Release an existing model-owned runner without materializing constants or
   * creating a new native closure. Call only after all borrowers have stopped;
   * a no-op for a graph that owns none. */
  static release(model: object): void {
    const runner = runners.get(model);
    if (runner) runner.dispose();
  }

  /** One decode step: consumes the pending token array (uint32 [1],
   *  unevaluated is fine), advances every cache by one position, returns
   *  the logits node plus the cache-update nodes that must ride the same
   *  async_eval. Throws on unsupported state, leaving
   *  the caches as they were (any growth already done is benign). */
  step(cur: MlxArray, caches: Cache[]): { logits: MlxArray; evalWith: MlxArray[] } {
    if (this.#disposed) throw new Error("compiled decode runner is disposed");
    const offset0 = caches[0]!.offset;
    for (const c of caches)
      if (c.offset !== offset0)
        throw new Error("compiled decode: cache offsets diverged");
    const decodable = caches as CompiledDecodeCache[];
    return this.#segmented
      ? this.#stepSegmented(cur, decodable, offset0)
      : this.#stepWhole(cur, decodable, offset0);
  }

  #stepWhole(cur: MlxArray, decodable: CompiledDecodeCache[], offset0: number): { logits: MlxArray; evalWith: MlxArray[] } {
    const plans = decodable.map((c) => c.prepareDecodeStep());
    const slots = decodable.map((c, i) => c.decodeSlot(plans[i]!));
    const key = closureKey(slots);
    if (this.#broken.has(key)) throw new Error(`compiled decode: known-broken closure ${key}`);

    // gather inputs — [cur, ropeOffset, ...per-cache slots]
    const inputs: MlxArray[] = [cur];
    const temps: MlxArray[] = [];
    const ropeOff = ops.fromInt32([offset0], []);
    temps.push(ropeOff);
    inputs.push(ropeOff);
    const step = decodeStepInputs(temps);
    for (let i = 0; i < decodable.length; i++)
      inputs.push(...decodable[i]!.decodeInputs(plans[i]!, step));

    let closure = this.#closures.get(key);
    if (!closure) {
      closure = new CompiledFunction(makeTraceFn(this.model, slots), true);
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
    for (let i = 0; i < decodable.length; i++) {
      const slot = slots[i]!;
      evalWith.push(...decodable[i]!.commitDecodeStep(slot, outs.slice(oi, oi + slot.outputs)));
      oi += slot.outputs;
    }
    CompiledDecode.stepsExecuted++;
    return { logits, evalWith };
  }

  #stepSegmented(cur: MlxArray, caches: CompiledDecodeCache[], offset0: number): { logits: MlxArray; evalWith: MlxArray[] } {
    const phases = caches.map((c) => c.decodePhase());
    // ring caches need their host bookkeeping (growth/trim/rotation) now;
    // growing caches keep it inside their layer's real decode read (appendDecode)
    const plans = caches.map((c, i) =>
      phases[i] === "ring" ? c.prepareDecodeStep() : null,
    );
    const slots = caches.map((c, i) => (plans[i] ? c.decodeSlot(plans[i]!) : null));

    // layout: consecutive ring layers form compiled segments, each
    // growing-cache layer runs uncompiled between them
    const segs: { from: number; to: number }[] = [];
    const jsLayers: number[] = [];
    let runStart = 0;
    for (let i = 0; i < caches.length; i++) {
      if (phases[i] === "concat") {
        segs.push({ from: runStart, to: i });
        jsLayers.push(i);
        runStart = i + 1;
      }
    }
    segs.push({ from: runStart, to: caches.length });

    // layout key: ring slot tags at their positions; js layers only by
    // position (their quant params live outside the closures)
    const key = "seg|" + slots.map((slot) => slot?.key ?? "js").join(",");
    if (this.#broken.has(key)) throw new Error(`compiled decode: known-broken closure ${key}`);

    let closures = this.#segClosures.get(key);
    if (!closures) {
      closures = segs.map(() => null);
      this.#segClosures.set(key, closures);
    }

    const ropeOff = ops.fromInt32([offset0], []);
    const stepTemps: MlxArray[] = [ropeOff];
    const step = decodeStepInputs(stepTemps);

    const evalWith: MlxArray[] = [];
    let carried = cur; // seg 0 consumes the token array; later, hidden state
    let carriedOwned = false; // cur belongs to the caller
    // Mid-step failure safety (a later segment's closure.apply can throw at
    // first trace AFTER earlier layers already advanced): the step must be
    // TRANSACTIONAL, or the caller's uncompiled re-forward of the same token
    // double-writes the committed layers (+1 offset skew forever, silently
    // corrupted attention). Two mechanisms, chosen by what each phase allows:
    //  - ring segments: the ring commit is a pure host-side handle swap with
    //    no reader between here and step end (each cache is read only by its
    //    own layer, inside the closure that produced the update), so the
    //    adopts are STAGED and committed only once every segment and js layer
    //    has succeeded. On failure the staged buffers are disposed and the
    //    ring caches are exactly at their pre-step state (prepareDecodeStep's
    //    growth/trim/rotate bookkeeping is benign for the uncompiled path —
    //    the same invariant #stepWhole and generate.ts's fallback rely on).
    //  - js (concat) layers: layer.forward commits via the cache's real
    //    decode read (appendDecode) mid-loop, so on failure the commit is ROLLED BACK by
    //    reverting offset (and ring index) — trim(1) semantics. The written
    //    KV row beyond the reverted offset is dead data the re-forward
    //    overwrites at the same position (the decode read writes at offset/
    //    ringIdx), so post-recovery state equals a single clean write; the
    //    in-place S=1 write slot is re-derived from the reverted ringIdx.
    const stagedAdopts: { c: CompiledDecodeCache; slot: DecodeSlot; bufs: MlxArray[] }[] = [];
    const committedJs: { c: CompiledDecodeCache; offsetBefore: number }[] = [];
    try {
      for (let s = 0; s < segs.length; s++) {
        const { from, to } = segs[s]!;
        const firstSeg = s === 0;
        const lastSeg = s === segs.length - 1;
        if (firstSeg || lastSeg || from < to) {
          const ringSlots: DecodeSlot[] = [];
          const inputs: MlxArray[] = [carried, ropeOff];
          for (let i = from; i < to; i++) {
            ringSlots.push(slots[i]!);
            inputs.push(...caches[i]!.decodeInputs(plans[i]!, step));
          }
          let closure = closures[s];
          if (!closure) {
            closure = new CompiledFunction(
              makeSegmentTraceFn(this.model, ringSlots, from, to, firstSeg, lastSeg),
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
          // in-graph fetch reads the updated buffer): no eval roots. The
          // host-side adoption is deferred to the end of the step (see above).
          let oi = 1;
          for (let i = from; i < to; i++) {
            const slot = slots[i]!;
            stagedAdopts.push({ c: caches[i]!, slot, bufs: outs.slice(oi, oi + slot.outputs) });
            oi += slot.outputs;
          }
        }
        if (s < jsLayers.length) {
          const li = jsLayers[s]!;
          const c = caches[li]!;
          committedJs.push({ c, offsetBefore: c.offset });
          const { h: next, donor } = this.model.layers[li]!.forward(carried, c, "decode", null, null);
          if (carriedOwned) carried.dispose();
          carried = next;
          carriedOwned = true;
          donor?.dispose();
        }
      }
      // every segment and js layer succeeded — commit the staged ring adopts
      for (const { c, slot, bufs } of stagedAdopts) c.commitDecodeStep(slot, bufs);
      // The js layers read their caches through the ordinary decode read, so
      // those caches take the post-dispatch hook the scheduler gives them after
      // the decode operation (batch-group): a row layout's per-row RoPE
      // positions stay fixed across a step and advance only there
      // (`BatchedRotatingQuantCache.ropeOffsetArr`), and without it every
      // later step ropes at the positions of the step that last refreshed them.
      for (const { c } of committedJs) (c as { releaseRopeArr?: () => void }).releaseRopeArr?.();
    } catch (e) {
      // unwind: free staged (never-adopted) ring buffers and the owned hidden
      // state, and revert the js layers' committed writes, so the caller's
      // uncompiled re-forward of this token starts from the pre-step state.
      for (const { bufs } of stagedAdopts) for (const b of bufs) b.dispose();
      for (const { c, offsetBefore } of committedJs)
        if (c.offset > offsetBefore) c.trim(c.offset - offsetBefore);
      if (carriedOwned) carried.dispose();
      throw e;
    } finally {
      for (const t of stepTemps) t.dispose();
    }
    CompiledDecode.stepsExecuted++;
    return { logits: carried, evalWith };
  }

  /** Free compiled closures (model unload). */
  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    if (runners.get(this.model) === this) runners.delete(this.model);
    const closures = [...this.#closures.values(), ...[...this.#segClosures.values()].flat()]
      .filter((closure): closure is CompiledFunction => closure !== null);
    this.#closures.clear();
    this.#segClosures.clear();
    this.#broken.clear();
    disposeResources(closures);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.CompiledDecode
