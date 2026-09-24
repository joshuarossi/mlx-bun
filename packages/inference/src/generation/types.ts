// Streaming generation — port of mlx-lm's generate_step:
// - prefill in chunks; cache state evaluated per chunk (bounded transient
//   memory), logits never computed for non-final prefill positions
// - decode pipelining via mx.async_eval: step n+1's graph is built and
//   dispatched before step n's token is read back, so the GPU never idles
//   on the JS round-trip
// - opt-in early token-zero yield reduces latency before that pipeline starts
// - sampling stays on-device; only the chosen token id crosses to JS

import { MlxArray } from "@mlx-bun/mlx/array";
import type { KvQuantSpec,TurboQuantScheme } from "../artifacts/config";
import { type Cache } from "../contracts/cache";
import type { TokenLogprobs } from "../contracts/generation";
import type { PromptResponseTrace } from "../execution/trace";
import type { GrammarController } from "../sampling/grammar";
import {
type LogitsProcessorOptions,
type SamplerOptions
} from "../sampling/index";
import {
type FillSession,
type FillStats
} from "./fill/session";

export interface GenerateOptions extends SamplerOptions, LogitsProcessorOptions {
  /** Application session affinity; independent of numerical cache identity. */
  cacheSessionId?: string;
  /** Resolved host policy. Direct compatibility calls resolve from their
   * captured binding when this is absent. */
  decodePolicy?: Readonly<Pick<import("../contracts/execution").ResolvedExecution, "compiledDecode" | "grammarJump">>;
  /** Cooperatively cancel at prefill/decode boundaries; pending native work
   *  finishes before owned resources are released. */
  signal?: AbortSignal;
  maxTokens?: number;
  eosTokenIds?: number[];
  prefillChunkSize?: number;
  /** Whether the request supplied its seed explicitly. Durable generation
   *  checkpoints use this to distinguish a reproducible user policy from the
   *  server-generated seed that must be recovered from checkpoint metadata. */
  seedWasExplicit?: boolean;
  /** Fired once during prefill, at `snapshotAt` tokens (default: the full
   *  prompt) and BEFORE any further KV is written — the one moment the
   *  caches hold exactly that prefix (post-wrap rings can't be rewound
   *  later). The server's prompt-boundary cache snapshot hangs here. */
  onPrefillDone?: () => void;
  /** Token count at which onPrefillDone fires (the STABLE cache boundary —
   *  chat prompts end in a generation primer, e.g. 12B's thought-channel
   *  tokens, that the NEXT turn's re-render does not contain; snapshotting
   *  there would make the entry untrimmable-and-divergent). Prefill is
   *  split at this index when it falls mid-prompt. */
  snapshotAt?: number;
  /** Resume an interrupted autoregressive generation from a durable KV
   *  checkpoint. `cache` must cover every token in `promptTokens` exactly;
   *  `initialPendingToken` is the already-sampled next token, so no cache
   *  rewind is required (important for recurrent/untrimmable layers). */
  initialPendingToken?: number;
  /** Number of completion tokens already emitted before this resumed run. */
  initialGeneratedTokens?: number;
  /** Original request prompt length used for protocol usage accounting when
   *  `promptTokens` also contains replayed completion tokens. */
  originalPromptTokens?: number;
  /** Periodic, safe decode-boundary checkpoint hook. The cache covers
   *  `cacheTokens`; `pendingToken` has been sampled but not emitted. */
  checkpointEveryTokens?: number;
  onDecodeCheckpoint?: (state: {
    cacheTokens: number[];
    caches: Cache[];
    generatedTokens: number;
    pendingToken: number;
  }) => void | Promise<void>;
  /** Pre-warmed KV caches (e.g. from the prompt cache). cache[0].offset
   *  prompt tokens are treated as already prefilled; only the suffix is
   *  forwarded. Caller keeps ownership — generate() will not dispose. */
  cache?: Cache[];
  /** Vision path: pre-merged (unscaled) input embeddings [1, L, hidden]
   *  covering the whole prompt; prefilled in one shot (no chunking).
   *  Caller keeps ownership. */
  promptEmbeddings?: MlxArray;
  /** bool [L] marking image tokens (bidirectional attention among them).
   *  MUST be unset when the prompt contains any audio — audio prompts run
   *  fully causal (docs/design/generic-model-support.md §3.3 Q1). */
  imageMask?: MlxArray;
  /** bool [L] marking ALL multimodal soft tokens (image | audio) for
   *  per-layer-input id zeroing (e2b/e4b), decoupled from imageMask so
   *  audio-only prompts (no bidirectional mask) still zero their positions.
   *  When unset, zeroing falls back to imageMask (the legacy vision shape).
   *  Caller keeps ownership. */
  multimodalMask?: MlxArray;
  /** Quantize full-attention KV caches to this many bits (4 or 8).
   *  Full-attention and rotating caches both convert when populated. */
  kvBits?: number;
  kvGroupSize?: number;
  /** Per-layer mixed-precision KV from kv_config.json (config.kvQuant).
   *  Overrides kvBits, like optiq serve's --kv-config. layerIdx indexes
   *  the cache list (== layer index for the donor prefix), including
   *  rotating/sliding caches. */
  kvConfig?: KvQuantSpec[];
  /** Convert once a cache's offset reaches this (uniform-kvBits default
   *  5000 = mlx-lm; kvConfig default 0 = optiq serve). */
  quantizedKvStart?: number;
  /** TurboQuant scheme (docs/design/turboquant.md): rotation-based KV
   *  quantization, a CLI-only runtime lever in the same class as uniform
   *  kvBits (mutually exclusive with kvBits/kvConfig — maybeQuantizeKv
   *  checks turboQuant first, so set at most one). Full-attention
   *  KVCache layers convert via TurboQuantKVCache.fromKVCache;
   *  RotatingKVCache (sliding-window) layers stay bf16 in v1 — a one-time
   *  warning names the limitation, never a throw. */
  turboQuant?: TurboQuantScheme;
  /** OPTIONAL paged KV storage (docs/design/kv-cache.md): fresh
   *  full-attention KVCache layers are replaced with PagedKVCache (block
   *  pool + gather-to-contiguous) before prefill. Scope: B1/B>1
   *  Gemma4-family, bf16 — mutually exclusive with kvBits/kvConfig/
   *  turboQuant/draft/compiled decode (callers refuse the combos; the
   *  cache swap itself only ever touches plain empty KVCache entries).
   *  Values are gated bit-exact vs the plain path (tests/paged-kv*). */
  pagedKv?: { blockSize?: number };
  /** Mounted LoRA adapter ids to apply (resolved/validated by
   *  AdapterManager.resolveSpec). Residuals sum in order. Set on the
   *  model's LoraState for exactly the duration of this generation —
   *  a plain field, safe because the generation queue is serialized. */
  adapters?: string[];
  /** DiffusionGemma image-text-to-text: channel-first pixel_values [1,3,H,W].
   *  When set, `promptTokens` are the spliced (<|image|>-expanded) ids and the
   *  denoising engine prefills the merged vision features. Caller keeps ownership. */
  visionPixels?: MlxArray;
  /** Capture each emitted token's log-probability (mlx_lm.server `logprobs`).
   *  The distribution matches mlx-lm generate_step exactly: full-vocab
   *  log-softmax of the logits AFTER logits processors, BEFORE the sampler's
   *  temperature/top-p/top-k/min-p/XTC (generate.py L409-422). Off by default —
   *  the hot path pays nothing when unset. */
  logprobs?: boolean;
  /** Capture the top-k (token id, logprob) pairs per emitted token from the
   *  same distribution (mlx_lm.server `top_logprobs`). 0/unset = off. */
  topLogprobs?: number;
  /** Grammar-constrained decoding (src/grammar.ts): a compiled GrammarController
   *  that masks invalid tokens to -inf each step. L2-class (oMLX oracle). When
   *  set, the decode loop takes a slightly different shape: it eager-reads the
   *  token id (acceptToken needs a JS number, which the pipelined loop defers),
   *  advances the matcher, and awaits the async mask precompute (which overlaps
   *  the GPU forward). Non-grammar requests keep the fast pipelined loop. */
  grammar?: GrammarController;
  /** Token fast-forwarding (src/fill/, docs/design/speculative-decoding.md
   *  "Token fast-forwarding"): a per-request table of DETERMINED token spans
   *  (compiled from the request's `tools` + the chat template). When the
   *  stream enters one, the engine appends the whole span itself with ONE
   *  multi-token forward and resumes sampling after it.
   *
   *  This is context extension, NOT speculation: nothing is drafted, verified,
   *  or rolled back, and no comparison is made against what the model would
   *  have produced. Injection bypasses the sampler, which is a documented
   *  behavior-policy deviation at temperature > 0 — hence opt-in
   *  (MLX_BUN_FILL=strict) and the composition refusals in shouldUseFill.
   *  Serial lane only: the batch scheduler and the spec loop never read it. */
  fill?: FillSession;
}

export interface GenerateStats {
  promptTokens: number;
  /** An observed terminal cause takes precedence over the token-count limit. */
  finishReason?: "stop" | "length";
  /** Prompt tokens skipped via a pre-warmed cache. */
  cachedTokens: number;
  generatedTokens: number;
  prefillTps: number;
  decodeTps: number;
  prefillMs: number;
  decodeMs: number;
  /** Exact token sequence whose KV now lives in the cache (prompt + every
   *  decoded token that was forwarded, including a trailing EOS the
   *  pipeline forwarded before reading it). For PromptCache.put(). */
  cacheTokens: number[];
  /** Speculative-decoding telemetry (serve --draft-model path only).
   *  draftedByPos/acceptedByPos: per-draft-position round counts (index =
   *  position within a round's block) — the Phase-1c per-position
   *  acceptance signal. */
  spec?: {
    drafted: number; accepted: number; targetCalls: number;
    draftedByPos?: number[]; acceptedByPos?: number[];
    rejected?: number; rounds?: number; acceptanceLengths?: number[];
    tokensPerForward?: number; forwardsSaved?: number;
    /** Round phase wall time, summed over the request's rounds. Present only
     *  under `MLX_BUN_SPEC_PHASE_TIMING=1`, which forces an evaluation at each
     *  phase boundary (diagnostic: it removes the overlap production decode
     *  relies on, so the sum is not production round time). */
    phaseMs?: SpecPhaseMs;
  };
  /** Token fast-forwarding telemetry (serial lane, MLX_BUN_FILL=strict).
   *  Present only when a fill table was actually armed for this generation. */
  fill?: FillStats;
}

/** Wall milliseconds per speculative round phase (see GenerateStats.spec). */
export interface SpecPhaseMs {
  /** draft(): the drafter's chain including its proposal readback. */
  draft: number;
  /** Target verify forward, forced to completion before sampling. */
  verify: number;
  /** Window sampling and its readback, plus the host accept walk. */
  sample: number;
  /** Target transaction resolve plus draft commit. */
  commit: number;
  rounds: number;
  /** Target-forward component wall ms (`MLX_BUN_SPEC_LAYER_PROFILE=1`): per-op
   *  evaluation barriers inside the verify forward, so `verify` grows while set. */
  layers?: Record<string, number>;
  /** Graph nodes built per op name (`MLX_BUN_SPEC_OP_INVENTORY=1`), summed over rounds. */
  verifyOps?: Record<string, number>;
  draftOps?: Record<string, number>;
}

export interface GenerateDiagnostics {
  trace?: PromptResponseTrace;
  mechanism?: "serial" | "continuous";
}

export interface GeneratedToken {
  token: number;
  index: number;
  /** Present only when GenerateOptions.logprobs / topLogprobs requested it. */
  logprobs?: TokenLogprobs;
}
