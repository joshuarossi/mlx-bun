// Model hub entry points: discover local checkpoints, fetch artifacts from
// Hugging Face, and estimate whether a model fits a machine. Estimates are
// advisory; nothing here refuses work, and nothing here chooses a model for the caller.
export {
  Registry, DEFAULT_HUB, DEFAULT_DB, visionCapable, audioCapable, pickCanonicalRevision,
  sidecarShipsAudioTower, scanSnapshot, planRepoGc, planGc, executeGc,
} from "./registry";
export type { ModelRecord, GcRepoPlan, GcSkippedSnapshot } from "./registry";
export {
  downloadModel, downloadOne, listRepoFiles, planDownloadSpace, hfToken, isSafeRepoFilename,
  gitBlobSha1, downloadsSnapshot, isDownloadActive, DOWNLOAD_DISK_RESERVE_BYTES,
} from "./download";
export type { RepoFile, RepoListing, DownloadOptions, DownloadSpacePlan, DownloadStatus } from "./download";
export {
  fit, skuMatrix, thisMachine, detectChip,
  kvBytesAt, kvQuantBytesPerElement, sdpaFallbackBytes,
  APPLE_SKUS, DEFAULT_CHUNK, WIRED_FRACTION, TRANSIENT_PER_TOKEN,
  DECODE_EFFICIENCY, MOE_DECODE_EFFICIENCY,
} from "./fit";
export type { MachineSpec, FitReport, FitKvScheme } from "./fit";
