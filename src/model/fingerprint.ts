// Config fingerprint for generated-model dispatch (docs/design/optimization_plan.md
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
