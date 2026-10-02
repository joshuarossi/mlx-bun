// Producing DSpark/DFlash drafters: regen (target generations + tapped hiddens),
// train (the DSpark objective), calibrate (STS thresholds). Serving a drafter is
// `@mlx-bun/inference`; quantizing a DeepSpec drafter is `@mlx-bun/quantize`.

export { DEFAULT_LOSS_WEIGHTS, dsparkLoss, analyticAcceptance, positionWeights, type LossWeights } from "./loss";
export {
  writeDflashShard, DflashShard, listDflashShards, sampleDflashBatch,
  type DflashRecord, type DflashShardMeta, type DflashBatch,
} from "./data";
export { regenDrafterData, type RegenOptions, type RegenProgress, type RegenResult } from "./regen";
export {
  trainDrafter, DEFAULT_DRAFTER_TRAIN_CONFIG,
  type DrafterTrainConfig, type DrafterTrainProgress, type DrafterTrainResult,
} from "./train";
export { fitStsThresholds, type ConfSample } from "./sts";
export { calibrateDrafter, readSts, writeSts, type CalibrateOptions, type CalibrationFit } from "./calibrate";
export { saveDrafter, DRAFTER_MODEL_TYPE } from "./checkpoint";
export { draftProjection } from "./target";
