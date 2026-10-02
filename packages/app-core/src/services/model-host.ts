/** An exact catalog id. */
export type ModelId = string;

/** What a loaded graph declares when it is built. Consumers ask for an
 * operation; they never branch on a model family or class. */
export type ModelOperation = "generate" | "embed" | "transcribe";

/** `companion` models (Whisper, a draft or embedding model) can be pinned resident beside the primary. */
export type ModelRole = "primary" | "companion";
export type ModelState = "loading" | "ready" | "draining" | "flushing";

export interface ResidentModel {
  readonly id: ModelId;
  readonly role: ModelRole;
  readonly state: ModelState;
  readonly operations: readonly ModelOperation[];
  /** Weights plus the state the model currently holds. */
  readonly bytes: number;
  readonly pinned: boolean;
  /** Leases currently held; a leased model is never evicted. */
  readonly leases: number;
  readonly lastUsedAt: number;
  /** Directories the model reads: the one its id names and any it holds besides (a snapshot another feature loaded into it). Cache cleanup keeps them. */
  readonly uses?: readonly string[];
}

export interface ResidencyPolicy {
  /** Bytes all resident models may use together; a load that would exceed it evicts first. */
  readonly budgetBytes: number;
  /** Never evicted. */
  readonly pinned: readonly ModelId[];
  /** Seconds an unpinned model stays loaded after its last lease is released; 0 releases it at once. */
  readonly idleUnloadSec: number;
}

/** What acquiring a model would do, for previews. */
export interface ResidencyPlan {
  readonly fits: boolean;
  readonly requiredBytes: number;
  readonly freeBytes: number;
  /** Least recently used first; empty when it fits without evicting. */
  readonly evict: readonly ModelId[];
}

export interface AcquireOptions {
  /** Rejected with `does-not-fit` unless the model declares all of these. */
  readonly need?: readonly ModelOperation[];
  readonly role?: ModelRole;
  /** Seconds the model stays loaded after this lease is released, overriding the policy's `idleUnloadSec`; 0 releases it at once. */
  readonly keepAliveSec?: number;
  readonly signal?: AbortSignal;
}

export interface TranscriptWord { word: string; start: number; end: number; readonly probability: number }

export interface TranscriptSegment {
  readonly id: number;
  readonly seek: number;
  /** Seconds from the start of the audio. */
  start: number;
  end: number;
  readonly text: string;
  readonly tokens: number[];
  readonly temperature: number;
  readonly avgLogprob: number;
  readonly compressionRatio: number;
  readonly noSpeechProb: number;
  /** With `wordTimestamps`. */
  words?: TranscriptWord[];
}

export interface Transcript {
  readonly text: string;
  readonly segments: TranscriptSegment[];
  readonly language: string;
}

/** How one transcription decodes. Nothing here names a model family. */
export interface TranscribeOptions {
  readonly task?: "transcribe" | "translate";
  /** ISO code or name; null detects it from the first window. */
  readonly language?: string | null;
  /** Text the decoder is primed with: vocabulary hints, style. */
  readonly prompt?: string | null;
  /** Beam search width; null is greedy. */
  readonly beamSize?: number | null;
  /** One sampling temperature; omitted runs the model's fallback ladder. */
  readonly temperature?: number;
  readonly conditionOnPreviousText?: boolean;
  readonly noSpeechThreshold?: number | null;
  /** Decode text only, no timestamp tokens. */
  readonly withoutTimestamps?: boolean;
  readonly wordTimestamps?: boolean;
  /** The reference-faithful graph instead of the fast path. */
  readonly faithful?: boolean;
  /** Lab: encoder positions kept (at most 1500). */
  readonly audioCtx?: number | null;
  /** Called with each finalized segment. */
  readonly onSegment?: (segment: TranscriptSegment) => void;
  /** Seeked frames out of the total. */
  readonly onProgress?: (done: number, total: number) => void;
  /** An aborted signal rejects the transcription. */
  readonly signal?: AbortSignal;
}

/** A transcription over audio that is still arriving: complete windows decode as they fill. */
export interface TranscriptionRun {
  readonly segments: readonly TranscriptSegment[];
  /** Append audio without decoding (no speech seen yet). */
  feedSilent(samples: Float32Array): void;
  /** Append audio; every complete window decodes. `signal` cancels the wait for the model. */
  feed(samples: Float32Array, signal?: AbortSignal): Promise<unknown>;
  /** Decode the remainder; the run is finished afterwards. */
  finish(signal?: AbortSignal): Promise<Transcript>;
}

/** The `transcribe` operation. Each decode call takes the host's execution lease, so it never overlaps generation. */
export interface TranscriptionOperation {
  /** Tokens a prompt may hold; vocabulary hints are fitted into it. */
  readonly promptTokenBudget: number;
  encode(text: string): number[];
  /** 16 kHz mono PCM. */
  transcribe(samples: Float32Array, options?: TranscribeOptions): Promise<Transcript>;
  start(options?: TranscribeOptions): TranscriptionRun;
}

/** An adapter mounted on a loaded model. */
export interface MountedAdapter {
  readonly id: string;
  /** The adapter directory it was mounted from. */
  readonly path: string;
  /** Null when its config states none. */
  readonly rank: number | null;
  readonly scale: number;
  /** Bytes of its weights on disk. */
  readonly sizeBytes: number;
  readonly mountedLayers: number;
  /** Bytes it holds in memory while mounted. */
  readonly ramBytes: number;
}

/** What merging two adapters wrote and how many tensors it combined; the fields are the merge's own report. */
export type AdapterMergeStats = Readonly<Record<string, unknown>>;

/** The `adapters` operation: LoRA adapters mounted on the model's own weights. Every call runs under the model's execution lease, in the process that holds the model (a worker, when the host isolates its models), never in the host's. */
export interface AdapterOperation {
  list(signal?: AbortSignal): Promise<readonly MountedAdapter[]>;
  /** Mounts the adapter directory under `id`; rejects with the reason when the model cannot take it. */
  mount(id: string, directory: string, signal?: AbortSignal): Promise<MountedAdapter>;
  /** Removes a mounted adapter; resolves to the layers it was mounted on, 0 when `id` was not mounted. */
  unmount(id: string, signal?: AbortSignal): Promise<number>;
  /** Combines two adapter directories, each scaled, into a new adapter directory. */
  merge(request: { readonly adapters: readonly [string, string]; readonly output: string; readonly scales?: readonly number[] }, signal?: AbortSignal): Promise<AdapterMergeStats>;
}

/** The operations a lease may expose, keyed by `ModelOperation` (`adapters` is offered on a model that mounts adapters). */
export interface ModelOperations {
  /** An OpenAI, Anthropic or Responses wire request already bound to this model. */
  generate(request: Request): Promise<Response>;
  embed(inputs: readonly string[], instruction?: string): Promise<readonly { readonly vector: Float32Array; readonly tokens: number }[]>;
  transcribe: TranscriptionOperation;
  adapters: AdapterOperation;
}

/** Holding a lease keeps the model resident; the holder must release it. */
export interface ModelLease {
  readonly model: ResidentModel;
  /** Milliseconds this acquire waited for the model to load; 0 when it was already resident. */
  readonly loadMs: number;
  /** Only the operations the model declared. */
  readonly operations: Partial<ModelOperations>;
  release(): void;
}

/** Counters for one model id since the host started. */
export interface ModelStats {
  readonly resident: boolean;
  readonly loads: number;
  readonly unloads: number;
  /** Time of the most recent load, 0 before the first. */
  readonly lastLoadMs: number;
  /** Seconds the model stays loaded after its last lease; null when pinned. */
  readonly idleUnloadSec: number | null;
}

export type ResidencyFailure = "does-not-fit" | "no-evictable-model" | "load-failed" | "aborted" | "in-use" | "closed" | "not-switchable" | "not-found";
export interface ModelHostError extends Error { readonly code: ResidencyFailure }

/**
 * Owns loaded models and their residency. Residency is by memory fit: a model
 * that fits the budget loads beside the others; otherwise the least recently
 * used unpinned, unleased model is evicted first. Eviction stops admitting to
 * it, waits for in-flight work to finish (drain), flushes its KV and prefix
 * state under the storage root, then releases it; acquiring it again resumes
 * that state. The host never holds more than the budget, including during a
 * swap. Load, unload and memory are published as events. Failures reject with
 * a `ModelHostError`.
 */
export interface ModelHost {
  readonly policy: ResidencyPolicy;
  acquire(id: ModelId, options?: AcquireOptions): Promise<ModelLease>;
  /** The model the host serves an operation with when the caller names none: the one the user configured, else the first local model that declares it. */
  defaultFor(operation: ModelOperation): Promise<ModelId | undefined>;
  plan(id: ModelId): Promise<ResidencyPlan>;
  /** Makes `id` the model `defaultFor("generate")` answers, loading it beside the resident ones when it fits, else in place of the least recently used unpinned one (its state is saved and resumes on return). Rejects with `not-found` for an id that is not a local model, `not-switchable` on a host that holds one model, and otherwise as `acquire` does. */
  serve(id: ModelId, options?: { readonly signal?: AbortSignal }): Promise<void>;
  /** Drains, optionally flushes state (default true), then releases. Rejects with `in-use` while a lease is held unless `force`; a model that is not resident resolves. */
  unload(id: ModelId, options?: { readonly flush?: boolean; readonly force?: boolean }): Promise<void>;
  pin(id: ModelId): void;
  unpin(id: ModelId): void;
  resident(): readonly ResidentModel[];
  stats(id: ModelId): ModelStats;
}
