import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Composition
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/composition.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// The one resolver of a composition record. The application calls it once per
// load, before the graph is built; the convenience load API calls it for
// callers that supply no record.
import { deviceArchitecture } from "@mlx-bun/mlx/ffi";
import type { ModelConfig, TurboQuantScheme } from "../artifacts/config";
import { COMPOSITION_DEFAULTS, type Composition } from "../contracts/portable/composition";
import { runtimeConfig, type RuntimeConfig } from "../runtime/config";
import { resolveKvScheme, type KvQuantOverride } from "../state/kv-scheme";
import { PagedKVCache } from "../state/paged/cache";

/** Rows per forward when the caller states no cap (the app's `--batch` default). */
export const DEFAULT_MAX_ROWS = 8;
/** The prefill chunk when `MLX_BUN_RD_PREFILL_CHUNK` is unset, the prefill
 * policy's ceiling (`generation/bindings/prefill-policy.ts`). */
export const PREFILL_CHUNK_TOKENS = 2048;

/** The chunk the prefill policy starts from: its `MLX_BUN_RD_PREFILL_CHUNK`
 * override, read through the runtime configuration exactly as it reads it
 * (a set, non-numeric value counts as 2048), else {@link PREFILL_CHUNK_TOKENS}. */
function resolveChunkTokens(runtime: RuntimeConfig): number {
  const explicit = runtime.value("MLX_BUN_RD_PREFILL_CHUNK") === undefined
    ? undefined : runtime.number("MLX_BUN_RD_PREFILL_CHUNK", 2048);
  return explicit === undefined ? PREFILL_CHUNK_TOKENS : Math.max(1, Math.floor(explicit));
}

/** What the caller decided; each absent value takes the default named on it. */
export interface CompositionRequest {
  /** The KV flags: `--kv-quant` (`override`), its TurboQuant spelling,
   * `--quantized-kv-start` and `--fused-sdpa` (the affine read kernels: on,
   * tiled-causal; off, unfused; absent, by the scheme's kind). Absent: bf16.
   * A `config` override reads the artifact's `kv_config.json` from the model
   * config. */
  readonly kv?: {
    readonly override?: KvQuantOverride;
    readonly turboQuant?: TurboQuantScheme;
    readonly quantizedKvStart?: number;
    readonly fusedSdpa?: boolean;
  };
  /** Paged KV (`--paged-kv`): full-attention storage in pages of `blockSize`
   * positions (default 256), read by the direct kernel where `direct` (default
   * false; see `PagedKvComposition`). Absent or null: unpaged. Pages store what
   * the KV scheme names for each layer. */
  readonly pagedKv?: { readonly blockSize?: number; readonly direct?: boolean } | null;
  /** The loaded drafter's tokens per round, and whether the scheduler adapts
   * each round's count up to it. Absent or null: no drafter. */
  readonly draft?: { readonly numDraftTokens: number; readonly adaptive?: boolean } | null;
  /** The most rows one forward carries. Default {@link DEFAULT_MAX_ROWS}. */
  readonly maxRows?: number;
  /** One argmax over a decode step whose live rows are all plain greedy. Default true. */
  readonly vectorGreedySampling?: boolean;
  /** One forward carries a decode group and a prefill group. Default false. */
  readonly mixedPrefill?: boolean;
  /** Prompt tokens a mixed forward carries beside its decode rows. Default 256. */
  readonly mixedTokenBudget?: number;
  /** A prompt's last token prefills alone, as the first one-position step. Default true. */
  readonly prefillTailSplit?: boolean;
  /** Grammar-forced continuations enter the KV without one forward per token. Default false. */
  readonly grammarJump?: boolean;
  /** Speculative rows draft by argmax. Default false. */
  readonly greedyDraft?: boolean;
}

/** Resolve the record for `config` on this machine. Reads the GPU architecture
 * and the prefill chunk override from the current runtime configuration. The
 * result is frozen. */
export function resolveComposition(config: ModelConfig, request: CompositionRequest = {}): Composition {
  return compose(request, resolveKvScheme({ ...request.kv, config: config.kvQuant }).storage);
}

/** The record a load resolves on this machine without an artifact's config:
 * `resolveComposition` with bf16 KV, which is what a load with no KV flag
 * resolves. The install step compiles the Neural Engine programs of this record
 * (`compileAnePrograms`), so it needs no downloaded model. Frozen. */
export function machineComposition(request: Omit<CompositionRequest, "kv"> = {}): Composition {
  return compose(request, resolveKvScheme({}).storage);
}

function compose(request: Omit<CompositionRequest, "kv">, kv: Composition["kv"]): Composition {
  const maxRows = request.maxRows ?? DEFAULT_MAX_ROWS;
  if (!Number.isSafeInteger(maxRows) || maxRows < 1) throw new Error("composition maxRows must be a positive integer");
  const draft = request.draft;
  if (draft && (!Number.isSafeInteger(draft.numDraftTokens) || draft.numDraftTokens < 1))
    throw new Error("composition draft tokens must be a positive integer");
  const mixedTokenBudget = request.mixedTokenBudget ?? COMPOSITION_DEFAULTS.mixedTokenBudget;
  if (!Number.isSafeInteger(mixedTokenBudget) || mixedTokenBudget < 1)
    throw new Error("composition mixedTokenBudget must be a positive integer");
  const pagedKv = request.pagedKv ? Object.freeze({ blockSize: request.pagedKv.blockSize ?? PagedKVCache.DEFAULT_BLOCK_SIZE,
    direct: request.pagedKv.direct ?? false }) : null;
  if (pagedKv && (!Number.isSafeInteger(pagedKv.blockSize) || pagedKv.blockSize < 1))
    throw new Error("composition paged KV block size must be a positive integer");
  const runtime = runtimeConfig();
  return Object.freeze({
    device: deviceArchitecture(),
    kv,
    pagedKv,
    draftDepth: !draft ? 0 : draft.adaptive ? Object.freeze({ adaptive: true as const, max: draft.numDraftTokens }) : draft.numDraftTokens,
    prefillChunkTokens: resolveChunkTokens(runtime),
    maxRows,
    vectorGreedySampling: request.vectorGreedySampling ?? COMPOSITION_DEFAULTS.vectorGreedySampling,
    // The caches' declaration: direct pages have no compiled form.
    mixedPrefill: request.mixedPrefill ?? COMPOSITION_DEFAULTS.mixedPrefill,
    mixedTokenBudget,
    prefillTailSplit: request.prefillTailSplit ?? COMPOSITION_DEFAULTS.prefillTailSplit,
    grammarJump: request.grammarJump ?? COMPOSITION_DEFAULTS.grammarJump,
    greedyDraft: request.greedyDraft ?? COMPOSITION_DEFAULTS.greedyDraft,
  });
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Composition
