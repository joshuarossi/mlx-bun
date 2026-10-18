import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.Graphs
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/graphs.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { Weights } from "../../artifacts/weights";
import type { GraphEntry, ServedComposition } from "../implementation";
import * as e4b from "./gemma4-e4b";
import * as twelve from "./gemma4-12b";
import * as moe from "./gemma4-26b";

export type Gemma4Graph = e4b.Gemma4E4b | twelve.Gemma4TwelveB | moe.Gemma4Moe;

// Loader lookup keys. The graph files contain only their written operations.
const e4bKey: ServedComposition = Object.freeze({
  fingerprint: e4b.FINGERPRINT,
  kv: Object.freeze([Object.freeze({
    kind: "affine-layers" as const,
    layers: Object.freeze([
      { layer: 0, bits: 4, groupSize: 64 },
      { layer: 1, bits: 4, groupSize: 64 },
      { layer: 2, bits: 4, groupSize: 64 },
      { layer: 3, bits: 8, groupSize: 64 },
      { layer: 4, bits: 8, groupSize: 64 },
      { layer: 5, bits: 4, groupSize: 64 },
      { layer: 6, bits: 4, groupSize: 64 },
      { layer: 7, bits: 4, groupSize: 64 },
      { layer: 8, bits: 4, groupSize: 64 },
      { layer: 9, bits: 8, groupSize: 64 },
      { layer: 10, bits: 8, groupSize: 64 },
      { layer: 11, bits: 8, groupSize: 64 },
      { layer: 12, bits: 4, groupSize: 64 },
      { layer: 13, bits: 4, groupSize: 64 },
      { layer: 14, bits: 8, groupSize: 64 },
      { layer: 15, bits: 4, groupSize: 64 },
      { layer: 16, bits: 4, groupSize: 64 },
      { layer: 17, bits: 4, groupSize: 64 },
      { layer: 18, bits: 4, groupSize: 64 },
      { layer: 19, bits: 4, groupSize: 64 },
      { layer: 20, bits: 4, groupSize: 64 },
      { layer: 21, bits: 4, groupSize: 64 },
      { layer: 22, bits: 4, groupSize: 64 },
      { layer: 23, bits: 4, groupSize: 64 },
    ]),
  })]),
});

const twelveKey: ServedComposition = Object.freeze({
  fingerprint: twelve.FINGERPRINT,
  kv: Object.freeze([Object.freeze({
    kind: "affine-layers" as const,
    layers: Object.freeze([
      { layer: 0, bits: 4, groupSize: 64 },
      { layer: 1, bits: 4, groupSize: 64 },
      { layer: 2, bits: 4, groupSize: 64 },
      { layer: 3, bits: 8, groupSize: 64 },
      { layer: 4, bits: 4, groupSize: 64 },
      { layer: 5, bits: 4, groupSize: 64 },
      { layer: 6, bits: 8, groupSize: 64 },
      { layer: 7, bits: 8, groupSize: 64 },
      { layer: 8, bits: 8, groupSize: 64 },
      { layer: 9, bits: 4, groupSize: 64 },
      { layer: 10, bits: 8, groupSize: 64 },
      { layer: 11, bits: 4, groupSize: 64 },
      { layer: 12, bits: 8, groupSize: 64 },
      { layer: 13, bits: 4, groupSize: 64 },
      { layer: 14, bits: 4, groupSize: 64 },
      { layer: 15, bits: 4, groupSize: 64 },
      { layer: 16, bits: 4, groupSize: 64 },
      { layer: 17, bits: 4, groupSize: 64 },
      { layer: 18, bits: 4, groupSize: 64 },
      { layer: 19, bits: 4, groupSize: 64 },
      { layer: 20, bits: 4, groupSize: 64 },
      { layer: 21, bits: 4, groupSize: 64 },
      { layer: 22, bits: 4, groupSize: 64 },
      { layer: 23, bits: 4, groupSize: 64 },
      { layer: 24, bits: 4, groupSize: 64 },
      { layer: 25, bits: 4, groupSize: 64 },
      { layer: 26, bits: 4, groupSize: 64 },
      { layer: 27, bits: 4, groupSize: 64 },
      { layer: 28, bits: 4, groupSize: 64 },
      { layer: 29, bits: 4, groupSize: 64 },
      { layer: 30, bits: 4, groupSize: 64 },
      { layer: 31, bits: 4, groupSize: 64 },
      { layer: 32, bits: 4, groupSize: 64 },
      { layer: 33, bits: 4, groupSize: 64 },
      { layer: 34, bits: 4, groupSize: 64 },
      { layer: 35, bits: 4, groupSize: 64 },
      { layer: 36, bits: 4, groupSize: 64 },
      { layer: 37, bits: 4, groupSize: 64 },
      { layer: 38, bits: 4, groupSize: 64 },
      { layer: 39, bits: 4, groupSize: 64 },
      { layer: 40, bits: 4, groupSize: 64 },
      { layer: 41, bits: 4, groupSize: 64 },
      { layer: 42, bits: 4, groupSize: 64 },
      { layer: 43, bits: 4, groupSize: 64 },
      { layer: 44, bits: 4, groupSize: 64 },
      { layer: 45, bits: 4, groupSize: 64 },
      { layer: 46, bits: 4, groupSize: 64 },
      { layer: 47, bits: 4, groupSize: 64 },
    ]),
  })]),
});

const moeKey: ServedComposition = Object.freeze({
  fingerprint: moe.FINGERPRINT,
  kv: Object.freeze([Object.freeze({
    kind: "affine-layers" as const,
    layers: Object.freeze([
      { layer: 0, bits: 8, groupSize: 64 },
      { layer: 1, bits: 4, groupSize: 64 },
      { layer: 2, bits: 4, groupSize: 64 },
      { layer: 3, bits: 8, groupSize: 64 },
      { layer: 4, bits: 8, groupSize: 64 },
      { layer: 5, bits: 8, groupSize: 64 },
      { layer: 6, bits: 4, groupSize: 64 },
      { layer: 7, bits: 4, groupSize: 64 },
      { layer: 8, bits: 8, groupSize: 64 },
      { layer: 9, bits: 8, groupSize: 64 },
      { layer: 10, bits: 4, groupSize: 64 },
      { layer: 11, bits: 8, groupSize: 64 },
      { layer: 12, bits: 8, groupSize: 64 },
      { layer: 13, bits: 4, groupSize: 64 },
      { layer: 14, bits: 4, groupSize: 64 },
      { layer: 15, bits: 4, groupSize: 64 },
      { layer: 16, bits: 4, groupSize: 64 },
      { layer: 17, bits: 4, groupSize: 64 },
      { layer: 18, bits: 4, groupSize: 64 },
      { layer: 19, bits: 4, groupSize: 64 },
      { layer: 20, bits: 4, groupSize: 64 },
      { layer: 21, bits: 4, groupSize: 64 },
      { layer: 22, bits: 4, groupSize: 64 },
      { layer: 23, bits: 4, groupSize: 64 },
      { layer: 24, bits: 4, groupSize: 64 },
      { layer: 25, bits: 4, groupSize: 64 },
      { layer: 26, bits: 4, groupSize: 64 },
      { layer: 27, bits: 4, groupSize: 64 },
      { layer: 28, bits: 4, groupSize: 64 },
      { layer: 29, bits: 4, groupSize: 64 },
    ]),
  })]),
});

export const GEMMA_GRAPHS: readonly GraphEntry<Weights, Gemma4Graph>[] = Object.freeze([
  { id: "gemma4-e4b", serves: e4bKey, create: (weights, config) => new e4b.Gemma4E4b(weights, config) },
  { id: "gemma4-12b", serves: twelveKey, create: (weights, config) => new twelve.Gemma4TwelveB(weights, config) },
  { id: "gemma4-26b", serves: moeKey, create: (weights, config) => new moe.Gemma4Moe(weights, config) },
]);
export { Gemma4E4b } from "./gemma4-e4b";
export { Gemma4TwelveB } from "./gemma4-12b";
export { Gemma4Moe } from "./gemma4-26b";
export * from "./written-blocks";
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.Graphs
