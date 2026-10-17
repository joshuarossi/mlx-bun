import host.ts.Source
namespace Host.Ts.Sources.Inference.Runtime.GraphForward
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/runtime/graph-forward.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
type LayerCapture=(layer:number,hidden:MlxArray)=>void;
interface ForwardCache { state():MlxArray[]; readonly stateNeedsDispose?:boolean }

/** Owns intermediates of a written forward. The graph calls its layers itself;
 * this scope only releases the previous output and records the new one. */
export class GraphForwardScope {
  #hidden: MlxArray | null;
  constructor(hidden: MlxArray, readonly capture: LayerCapture | null) { this.#hidden = hidden; }
  get hidden(): MlxArray { return this.#hidden!; }
  protected replace(next: MlxArray): void {
    this.#hidden!.dispose();
    this.#hidden = next;
  }
  accept(layer: number, next: MlxArray): void {
    this.replace(next);
    this.capture?.(layer, next);
  }
  bound(layer: number, next: MlxArray, cache: ForwardCache): void {
    this.replace(next);
    const state = cache.state();
    try { ops.evalAll([next, ...state]); }
    finally { if (cache.stateNeedsDispose) for (const array of state) array.dispose(); }
    this.capture?.(layer, next);
  }
  submit(): void { ops.asyncEvalAll([this.#hidden!]); }
  finish(layers: number, output: MlxArray): MlxArray {
    this.#hidden!.dispose();
    this.#hidden = null;
    try { this.capture?.(layers, output); return output; }
    catch (error) { output.dispose(); throw error; }
  }
  [Symbol.dispose](): void { this.#hidden?.dispose(); this.#hidden = null; }
}

/** The written prompt operation requests one materialization per layer. */
export class BoundedGraphForwardScope extends GraphForwardScope {
  constructor(hidden: MlxArray, capture: LayerCapture | null, readonly caches: readonly ForwardCache[]) { super(hidden, capture); }
  override accept(layer: number, next: MlxArray): void { this.bound(layer, next, this.caches[layer]!); }
}

/** Submission cadence only; projection and layer calls remain in the file. */
export class SubmittedGraphForwardScope extends GraphForwardScope {
  constructor(hidden: MlxArray, capture: LayerCapture | null, readonly layers: number, readonly every: number) { super(hidden, capture); }
  override accept(layer: number, next: MlxArray): void {
    this.replace(next);
    if ((layer + 1) % this.every === 0 && layer + 1 < this.layers) this.submit();
    this.capture?.(layer, next);
  }
}


/** Queue a written layer and its cache state together before the next layer
 * writes shared ANE buffers. Submission remains asynchronous. */
export class QueuedGraphForwardScope extends GraphForwardScope {
  constructor(hidden: MlxArray, capture: LayerCapture | null, readonly caches: readonly ForwardCache[]) { super(hidden, capture); }
  override accept(layer: number, next: MlxArray): void {
    this.replace(next);
    const cache = this.caches[layer]!, state = cache.state();
    try { ops.asyncEvalAll([next, ...state]); }
    finally { if (cache.stateNeedsDispose) for (const array of state) array.dispose(); }
    this.capture?.(layer, next);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Runtime.GraphForward
