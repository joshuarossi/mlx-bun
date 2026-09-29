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
}

export interface ResidencyPolicy {
  /** Bytes all resident models may use together; a load that would exceed it evicts first. */
  readonly budgetBytes: number;
  /** Never evicted. */
  readonly pinned: readonly ModelId[];
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
  readonly signal?: AbortSignal;
}

export interface TranscribeRequest {
  /** 16 kHz mono PCM. */
  readonly samples: Float32Array;
  readonly language?: string | null;
  readonly task?: "transcribe" | "translate";
  readonly prompt?: string | null;
  readonly wordTimestamps?: boolean;
  readonly signal?: AbortSignal;
  readonly onSegment?: (segment: TranscriptSegment) => void;
}

export interface TranscriptSegment { readonly start: number; readonly end: number; readonly text: string }

export interface Transcript {
  readonly text: string;
  readonly language: string | null;
  readonly segments: readonly TranscriptSegment[];
  readonly durationSeconds: number;
}

/** The operations a lease may expose, keyed by `ModelOperation`. */
export interface ModelOperations {
  /** An OpenAI, Anthropic or Responses wire request already bound to this model. */
  generate(request: Request): Promise<Response>;
  embed(inputs: readonly string[], instruction?: string): Promise<readonly { readonly vector: Float32Array; readonly tokens: number }[]>;
  transcribe(request: TranscribeRequest): Promise<Transcript>;
}

/** Holding a lease keeps the model resident; the holder must release it. */
export interface ModelLease {
  readonly model: ResidentModel;
  /** Only the operations the model declared. */
  readonly operations: Partial<ModelOperations>;
  release(): void;
}

export type ResidencyFailure = "does-not-fit" | "no-evictable-model" | "load-failed" | "aborted";
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
  plan(id: ModelId): Promise<ResidencyPlan>;
  /** Drains, optionally flushes state (default true), then releases. Rejects while a lease is held unless `force`. */
  unload(id: ModelId, options?: { readonly flush?: boolean; readonly force?: boolean }): Promise<void>;
  pin(id: ModelId): void;
  unpin(id: ModelId): void;
  resident(): readonly ResidentModel[];
}
