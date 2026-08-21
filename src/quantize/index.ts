// Public API for native model quantization. The server (and the job system)
// import from here: quantize a model directory, write sharded safetensors,
// build the config block, and resolve/inspect models for the wizard UI.

export { quantizeModelDir, isQuantizable, withPreparedProbe } from "./quantizer";
export type {
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

export {
  writeShardedSafetensors,
  DEFAULT_SHARD_BYTES,
} from "./safetensors-writer";
export type {
  NamedTensor,
  ShardInfo,
  SafetensorsIndex,
  WriteResult,
  WriteOpts,
} from "./safetensors-writer";

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

export { quantizeRunner, inspectModel } from "./job";
