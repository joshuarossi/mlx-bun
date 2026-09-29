// Public checkpoint-quantization API: allocation, weight transforms, sharded
// output, and quantization metadata. Model discovery belongs to @mlx-bun/hub.

export { quantizeModelDir, isQuantizable, withPreparedProbe, CONVERT_DTYPES } from "./quantizer";
export { convertModelDir } from "./convert";
export type { ConvertOptions, ConvertResult } from "./convert";
export type {
  ConvertDtype,
  PreparedProbe,
  ProbeSource,
  QuantizeOptions,
  QuantizeResult,
  ProgressEvent,
} from "./quantizer";

export {
  planQwen35Fold,
  planQwenMtpFold,
} from "./rotate";
export type {
  FoldOptions,
  QwenFoldOptions,
} from "./rotate";

export {
  automaticRotationWeightTransform,
  llamaWeightTransform,
  planLlamaWeightTransform,
  qwen35WeightTransform,
  qwenMtpWeightTransform,
} from "./weight-transform";
export type {
  LlamaWeightTransformPlan,
  QwenWeightTransformPlan,
  WeightTransform,
  WeightTransformContext,
  WeightTransformMetadata,
  WeightTransformPlan,
} from "./weight-transform";

export { quantizeTrellisModelDir } from "./trellis-quantizer";
export type { TrellisQuantizeOptions, TrellisQuantizeResult } from "./trellis-quantizer";
export { TrellisEncoder, loadHessianFactor } from "./trellis-encoder";
export type { PackedTrellisTensor, LdlqEncoding, TrellisEncoderOptions } from "./trellis-encoder";
export { parseKMap, treatmentFor, trellisBpw, mlxLmPath } from "./trellis-allocation";
export type { DownAxis, Treatment, TreatmentPolicy, TrellisKMap } from "./trellis-allocation";
export { planQwen35HfFold } from "./qwen35-hf-fold";
export type { Qwen35HfFoldPlan, Qwen35HfFoldSource } from "./qwen35-hf-fold";

export { writeShardedSafetensors, DEFAULT_SHARD_BYTES } from "@mlx-bun/inference/artifacts";
export type { NamedTensor, ShardInfo, SafetensorsIndex, WriteResult, WriteOpts } from "@mlx-bun/inference/artifacts";

export {
  buildQuantizationBlock,
  writeQuantizedConfig,
} from "./config-writer";
export type {
  QuantDef,
  PerLayerEntry,
  QuantizationBlock,
  OptiqMetadata,
} from "./config-writer";

// Mixed-precision (OptiQ sensitivity + knapsack) surface.
export {
  optimizeMixedPrecision,
  computeBpw,
  klReduction,
  UpgradeHeap,
} from "./allocator";
export type {
  LayerQuantConfig,
  OptimizationResult,
  OptimizeMixedPrecisionOptions,
  UpgradeEntry,
} from "./allocator";

export { analyzeSensitivityExact, klFromRef } from "./sensitivity";
export type {
  SensitivityResult,
  AnalyzeSensitivityOptions,
} from "./sensitivity";

export { loadLlmCalibration } from "./calibration";
