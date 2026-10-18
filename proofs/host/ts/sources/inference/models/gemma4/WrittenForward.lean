import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.WrittenForward
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/written-forward.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { MlxLayerCapture } from "../../contracts/mlx/graph";
import type { Cache } from "../../contracts/mlx/cache";
import { GraphForwardScope } from "../../runtime/graph-forward";
import type { DonorRead, PerLayerInputs, Gemma4Phase } from "./blocks";
import type { GemmaLayerWeights, GemmaInputLayerWeights, GemmaMoeLayerWeights } from "./written-blocks";
import type { QuantizedLinear } from "../../layers/quantized-linear";

export interface GemmaLayerResult { h: MlxArray; donor: DonorRead | null }

/** Carries reads between explicitly written layer calls; owns every retained
 * donor read and the current hidden handle during failures as well as success. */
export class GemmaForwardScope extends GraphForwardScope {
  readonly reads: (DonorRead | null)[];
  constructor(hidden: MlxArray, capture: MlxLayerCapture | null, caches: number) {
    super(hidden, capture); this.reads = Array(caches).fill(null);
  }
  own(index: number, result: GemmaLayerResult): void {
    result.donor!.dispose(); this.accept(index, result.h);
  }
  donor(index: number, result: GemmaLayerResult): void {
    this.reads[index] = result.donor; this.accept(index, result.h);
  }
  shared(index: number, result: GemmaLayerResult): void { this.accept(index, result.h); }
  override [Symbol.dispose](): void {
    super[Symbol.dispose](); for (const read of this.reads) read?.dispose();
  }
}

/** Inputs are sliced one layer at a time in the same order as the graph calls. */
export class GemmaInputForwardScope extends GemmaForwardScope {
  readonly #inputs: MlxArray;
  #current: MlxArray | null = null;
  readonly #batch: number;
  readonly #length: number;
  constructor(hidden: MlxArray, ids: MlxArray, capture: MlxLayerCapture | null, caches: number,
    readonly perLayer: PerLayerInputs) {
    super(hidden, capture, caches);
    [this.#batch, this.#length] = ids.shape as [number, number];
    try { this.#inputs = perLayer.compute(ids, hidden); }
    catch (error) { super[Symbol.dispose](); throw error; }
  }
  input(index: number): MlxArray {
    this.#current?.dispose();
    this.#current = this.perLayer.layer(this.#inputs, index, this.#batch, this.#length);
    return this.#current;
  }
  override accept(index: number, next: MlxArray): void {
    this.#current?.dispose(); this.#current = null; super.accept(index, next);
  }
  override [Symbol.dispose](): void {
    this.#current?.dispose(); this.#inputs.dispose(); super[Symbol.dispose]();
  }
}

/** Record only mounting targets; it never chooses a projection operation. */
export function denseLoraTargets(parts: readonly GemmaLayerWeights[]): Map<string, QuantizedLinear> {
  const targets = new Map<string, QuantizedLinear>();
  for (const layer of parts) {
    const add = (suffix: string, projection: QuantizedLinear | null) => { if (projection) targets.set(`${layer.prefix}.${suffix}`, projection); };
    add("self_attn.q_proj", layer.attn.qProj); add("self_attn.k_proj", layer.attn.kProj);
    add("self_attn.v_proj", layer.attn.vProj); add("self_attn.o_proj", layer.attn.oProj);
    add("mlp.gate_proj", layer.mlp.gate); add("mlp.up_proj", layer.mlp.up); add("mlp.down_proj", layer.mlp.down);
  }
  return targets;
}
export function inputLoraTargets(parts: readonly GemmaInputLayerWeights[]): Map<string, QuantizedLinear> {
  const targets = denseLoraTargets(parts);
  for (const layer of parts) {
    targets.set(`${layer.prefix}.per_layer_input_gate`, layer.perLayerGate);
    targets.set(`${layer.prefix}.per_layer_projection`, layer.perLayerProjection);
  }
  return targets;
}
export interface GemmaMixedGroup {
  readonly ids: MlxArray;
  readonly cache: Cache[];
  readonly phase: Gemma4Phase;
  readonly reads: (DonorRead | null)[];
  h: MlxArray;
  inputs: MlxArray | null;
}

/** Request-data iteration for a mixed forward. The file calls each layer in
 * order and supplies literal attention and feed-forward operations; this scope
 * only packs that layer's token rows and carries each group's owned state. */
export class GemmaMixedScope {
  readonly groups: GemmaMixedGroup[] = [];
  readonly #results: MlxArray[] = [];
  constructor(readonly work: readonly { ids: MlxArray; state: Cache[]; phase: "decode" | "window" | "verify"; capture: MlxLayerCapture | null }[],
    embed: (ids: MlxArray) => MlxArray, readonly caches: number, readonly perLayer: PerLayerInputs | null = null) {
    try {
      for (const row of work) {
        const group: GemmaMixedGroup = { ids: row.ids, cache: row.state, phase: row.phase === "decode" ? "decode" : "window",
          reads: Array(caches).fill(null), h: embed(row.ids), inputs: null };
        this.groups.push(group);
        if (perLayer) group.inputs = perLayer.compute(row.ids, group.h);
      }
    } catch (error) { this[Symbol.dispose](); throw error; }
  }
  layer(index: number, attend: (x: MlxArray, group: GemmaMixedGroup) => MlxArray,
    feedforward: (x: MlxArray, input: MlxArray | null) => MlxArray): void {
    const mids: MlxArray[] = [], inputs: MlxArray[] = [];
    try {
      for (const group of this.groups) {
        mids.push(attend(group.h, group));
        if (this.perLayer) inputs.push(this.perLayer.layer(group.inputs!, index, group.ids.shape[0]!, group.ids.shape[1]!));
      }
      let packedInput: MlxArray | null = null;
      if (inputs.length) {
        const flat = inputs.map(input => ops.reshape(input, [1, -1, this.perLayer!.width]));
        try { packedInput = ops.concatAxis(flat, 1); } finally { for (const input of flat) input.dispose(); }
      }
      using held = packedInput;
      const outputs = mapPackedTokens(mids, packed => feedforward(packed, held));
      for (const [row, group] of this.groups.entries()) { group.h.dispose(); group.h = outputs[row]!; }
      for (const [row, group] of this.groups.entries()) this.work[row]!.capture?.(index, group.h);
    } finally { for (const mid of mids) mid.dispose(); for (const input of inputs) input.dispose(); }
  }
  finish(layerCount: number, norm: { forward(x: MlxArray): MlxArray }): MlxArray[] {
    try {
      for (const [index, group] of this.groups.entries()) {
        const hidden = norm.forward(group.h); this.#results.push(hidden);
        this.work[index]!.capture?.(layerCount, hidden);
      }
      return this.#results.splice(0);
    } catch (error) { for (const result of this.#results) result.dispose(); this.#results.length = 0; throw error; }
  }
  [Symbol.dispose](): void {
    for (const group of this.groups) { group.h.dispose(); group.inputs?.dispose(); for (const read of group.reads) read?.dispose(); }
  }
}

export function ownMixed(result: GemmaLayerResult): MlxArray { result.donor!.dispose(); return result.h; }
export function donorMixed(group: GemmaMixedGroup, cache: number, result: GemmaLayerResult): MlxArray { group.reads[cache] = result.donor; return result.h; }
export function sharedMixed(result: GemmaLayerResult): MlxArray { return result.h; }

import { mapPackedTokens } from "../../input/token-groups";

export function weightBytes(weights: { shards: { files: Map<string, { mmap: { size: number } }> } }): number {
  return [...weights.shards.files.values()].reduce((total, file) => total + file.mmap.size, 0);
}

/** Construction ownership until the written graph transfers its constants. */
export class GemmaBuildScope {
  readonly #constants: MlxArray[] = [];
  hold<T extends GemmaLayerWeights>(layer: T): T {
    if (layer.attn.ropeFreqs) this.#constants.push(layer.attn.ropeFreqs);
    return layer;
  }
  holdMoe(layer: GemmaMoeLayerWeights): GemmaMoeLayerWeights {
    this.hold(layer); this.#constants.push(layer.router.normWeight); return layer;
  }
  finish() { return ownResource(this.#constants.splice(0), disposeResources); }
  [Symbol.dispose](): void { disposeResources(this.#constants.splice(0)); }
}

import { ownResource, disposeResources } from "../../runtime/resources";
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.WrittenForward
