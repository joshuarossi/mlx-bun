// The wire shapes of the module's JSON routes, shared by its handlers and its panel. Data only: this file imports nothing.

/** What serving a model needs on this machine, from the fit model. */
export interface FitAssessment { fits: boolean; max_safe_context: number; predicted_decode_tps: number }
export type SupportTier = "targeted" | "generic";

/** `GET /api/hub/local`: one downloaded model. */
export interface HubLocalRow {
  repo_id: string;
  model_type: string;
  size_bytes: number;
  quant_bits: number | null;
  quant_group_size: number | null;
  vision: boolean;
  supported: boolean;
  support_tier: SupportTier | null;
  assessment: FitAssessment | null;
}

/** `GET /api/hub/search`: one Hugging Face result. */
export interface HubSearchRow { id: string; downloads: number; likes: number; size_estimate: number | null }

/** `GET /downloads`: one transfer. */
export interface DownloadInfo {
  repoId: string;
  state: "active" | "done" | "error";
  currentFile: string | null;
  receivedBytes: number;
  totalBytes: number;
  bytesPerSec?: number;
  error?: string;
}

/** `GET /library`: one local model with what is running. */
export interface LibraryRow {
  repo_id: string;
  model_type: string;
  size_bytes: number;
  quant_bits: number | null;
  vision: boolean;
  audio: boolean;
  supported: boolean;
  support_tier: SupportTier | null;
  /** The model requests that name none are answered by. */
  serving: boolean;
  /** Loaded now: the served model and any that fit beside it. */
  resident: boolean;
  assessment: FitAssessment | null;
}

/** `GET /v1/adapters/available`: an adapter on disk. */
export interface AvailableAdapterRow {
  id: string;
  path: string;
  rank: number | null;
  scale: number;
  base_model: string | null;
  mounted: boolean;
  compatible: boolean;
}

/** `GET /v1/adapters`: an adapter mounted on the served model. */
export interface MountedAdapterRow {
  id: string;
  path: string;
  rank: number | null;
  scale: number;
  size_bytes: number;
  mounted_layers: number;
  ram_bytes: number;
}

/** What a panel is told about its backend (the same shape as `@mlx-bun/app-core`'s `PanelConnection`). */
export interface PanelConnection {
  readonly apiBase: string;
  readonly eventsUrl: string;
}
