import host.ts.Source
namespace Host.Ts.Sources.Inference.Input.PackedMixed
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/input/packed-mixed.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../contracts/mlx/cache";
import type { MlxPhaseGroup } from "../contracts/mlx/graph";
import { mapPackedTokens } from "./token-groups";

/** Group geometry and ownership for written packed operations. The graph
 * supplies each layer's direct calls; this scope selects no numerical operation. */
export class PackedMixedScope {
  readonly #hidden:MlxArray[]=[];
  readonly #bounded:boolean;
  constructor(readonly groups:readonly MlxPhaseGroup[],embed:(ids:MlxArray)=>MlxArray) {
    this.#bounded=groups.some(group=>group.phase==="window" && group.rows>=5);
    try { for (const group of groups) this.#hidden.push(embed(group.ids)); }
    catch (error) { this[Symbol.dispose](); throw error; }
  }
  accept(layer:number,attention:(hidden:MlxArray,cache:Cache,phase:"decode"|"window")=>MlxArray,
    mlp:(hidden:MlxArray)=>MlxArray):void {
    const mids:MlxArray[]=[];
    try {
      for (const [row,group] of this.groups.entries()) mids.push(attention(this.#hidden[row]!,group.state[layer]!,group.phase==="decode"?"decode":"window"));
      const outputs=mapPackedTokens(mids,mlp);
      for (const [row,output] of outputs.entries()) { this.#hidden[row]!.dispose(); this.#hidden[row]=output; }
      if (this.#bounded) {
        const caches=this.groups.map(group=>group.state[layer]!);
        const state=caches.map(cache=>cache.state());
        try { ops.evalAll([...this.#hidden,...state.flat()]); }
        finally { for (const [row,cache] of caches.entries()) if (cache.stateNeedsDispose) for (const array of state[row]!) array.dispose(); }
      }
      for (const [row,group] of this.groups.entries()) group.capture?.(layer,this.#hidden[row]!);
    } finally { for (const mid of mids) mid.dispose(); }
  }
  finish(layer:number,norm:(hidden:MlxArray)=>MlxArray):MlxArray[] {
    const result:MlxArray[]=[];
    try {
      for (const [row,hidden] of this.#hidden.entries()) {
        const output=norm(hidden); result.push(output); this.groups[row]!.capture?.(layer,output);
      }
      return result;
    } catch (error) { for (const output of result) output.dispose(); throw error; }
  }
  [Symbol.dispose]():void { for (const hidden of this.#hidden.splice(0)) hidden.dispose(); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Input.PackedMixed
