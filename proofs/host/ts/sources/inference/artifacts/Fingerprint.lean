import host.ts.Source
namespace Host.Ts.Sources.Inference.Artifacts.Fingerprint
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/artifacts/fingerprint.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Config fingerprint (`02d723a:docs/archive/investigations/optimization_plan.md`
// Phase C): a stable hash over every config field that changes the decode graph
// structure, plus the kv_config quant layout. The default graph table keys a
// written graph's entry on its declared fingerprint and composition, and uses
// the family's generic graph otherwise. Explicit graph choices bypass the table.

import type { ModelConfig } from "./config";

export function configFingerprint(config: ModelConfig): string {
  const t = config.text;
  const payload = JSON.stringify({
    layerTypes: t.layerTypes,
    hiddenSize: t.hiddenSize,
    headDim: t.headDim,
    globalHeadDim: t.globalHeadDim,
    numAttentionHeads: t.numAttentionHeads,
    numKeyValueHeads: t.numKeyValueHeads,
    numGlobalKeyValueHeads: t.numGlobalKeyValueHeads,
    attentionKEqV: t.attentionKEqV,
    numKvSharedLayers: t.numKvSharedLayers,
    enableMoeBlock: t.enableMoeBlock,
    numExperts: t.enableMoeBlock ? t.numExperts : 0,
    topKExperts: t.enableMoeBlock ? t.topKExperts : 0,
    hiddenSizePerLayerInput: t.hiddenSizePerLayerInput,
    slidingWindow: t.slidingWindow,
    finalLogitSoftcapping: t.finalLogitSoftcapping,
    kvQuant: config.kvQuant ?? null,
  });
  const h = new Bun.CryptoHasher("sha256");
  h.update(payload);
  return h.digest("hex").slice(0, 16);
}

/** Exact immutable model-component identity, calculated once while its owner
 * holds the native execution lease. Names/shapes/dtypes disambiguate layouts. */
export function tensorFingerprint(entries: Iterable<readonly [string,
  Pick<import("@mlx-bun/mlx/array").MlxArray, "dtype" | "shape" | "rawBytesView">]>): string {
  const hash = new Bun.CryptoHasher("sha256");
  for (const [name, tensor] of [...entries].sort(([a], [b]) => a.localeCompare(b))) {
    hash.update(JSON.stringify([name, tensor.dtype, tensor.shape]));
    hash.update(tensor.rawBytesView());
  }
  return hash.digest("hex");
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Artifacts.Fingerprint
