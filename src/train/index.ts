// Public surface for native LoRA + DPO fine-tuning.

export { ValueAndGrad } from "../mlx/autograd";

export {
  loadSftDataset, iterateSftBatches, encodeSftRow, sftRowFormat,
  loadDpoDataset, iterateDpoBatches, encodeDpoRow, tokenizePair,
  probeFormat,
  type SftExample, type SftBatch, type SftRowFormat,
  type DpoExample, type DpoBatch, type DatasetFormat,
} from "./dataset";

export { trainForward } from "./forward";

export {
  sftLoss, dpoLoss, dpoRefLogps, dpoMetrics,
} from "./loss";

export {
  AdamW, warmupCosineSchedule, type AdamWOptions,
} from "./optimizer";

export {
  buildTrainableLora, attachForTraining, detachTraining, setLoraScale,
  flatA, flatB, flatParams, saveAdapter, disposeLora,
  type TrainableLora, type TrainableTarget, type SaveAdapterConfig,
} from "./lora-params";

export {
  resolveRanks, DEFAULT_TARGET_MODULES,
  type RankScaling, type ResolveRanksOptions,
} from "./rank";

export {
  trainLora, DEFAULT_TRAIN_CONFIG,
  type TrainConfig, type TrainResult,
} from "./trainer";

export { mergeAdapters, type MergeStats } from "./merge";

export { exportAdapter, type ExportManifest } from "./export";

export { finetuneRunner, inspectDataset } from "./job";
