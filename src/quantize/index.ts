// Public API for native model quantization. The server (and the job system)
// import from here: quantize a model directory, write sharded safetensors,
// build the config block, and resolve/inspect models for the wizard UI.

export { quantizeModelDir, isQuantizable } from "./quantizer";
export type {
  QuantizeOptions,
  QuantizeResult,
  ProgressEvent,
} from "./quantizer";

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

export { quantizeRunner, inspectModel } from "./job";
