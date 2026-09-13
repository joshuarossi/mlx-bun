// Config fingerprint for generated-model dispatch (docs/archive/investigations/optimization_plan.md
// Phase C): a stable hash over every config field that changes the
// decode graph structure, plus the kv_config quant layout. A generated
// specialization is used only when the fingerprint of the loaded config
// matches the one it was generated from; everything else runs the
// monolith (slow, never broken).

import type { ModelConfig } from "../config";

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
  Pick<import("../mlx/array").MlxArray, "dtype" | "shape" | "rawBytesView">]>): string {
  const hash = new Bun.CryptoHasher("sha256");
  for (const [name, tensor] of [...entries].sort(([a], [b]) => a.localeCompare(b))) {
    hash.update(JSON.stringify([name, tensor.dtype, tensor.shape]));
    hash.update(tensor.rawBytesView());
  }
  return hash.digest("hex");
}
