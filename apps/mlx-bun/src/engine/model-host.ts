// Own one loaded model, its draft and lazy media towers. Application entry
// points supply the artifact and options; no HTTP or scheduling lives here.
import type { KvQuantSpec, ModelConfig } from "@mlx-bun/inference/artifacts/config";
import type { Weights } from "@mlx-bun/inference/artifacts";
import type { RuntimeModel, RuntimeOpenOptions, ResolvedModelProfile, ModelImplementationProvider, GenerationDefaults } from "@mlx-bun/inference/models";
import type { ChatTemplate, LoadedTokenizer, SentinelTokens } from "@mlx-bun/inference/input";
import type { AdapterManager } from "@mlx-bun/inference/adapters";
import type { AudioTokenIds, VisionTokenIds, VisionEncoder } from "@mlx-bun/inference/input/vision";
import type { AudioEncoder } from "@mlx-bun/inference/contracts/mlx";
import type { MediaPreparation } from "./media-preparation";

/** An audio encoder the context owns; released with it. */
export type LoadedAudioEncoder = AudioEncoder & { dispose?(): void };
import { sidecarShipsAudioTower } from "@mlx-bun/hub/registry";
import { fit } from "@mlx-bun/inference/execution/fit";
import { cleanupFailure, disposeResources } from "@mlx-bun/inference/runtime/resources";
import type { DisposableResource, MemoryPlan } from "@mlx-bun/inference/contracts/portable";
import type { DraftKind } from "@mlx-bun/inference/generation/speculative/draft-kind";
import type { DraftProviderRegistry, LoadedDraft } from "@mlx-bun/inference/generation/speculative/draft-registry";

export interface ServedModelInfo { readonly config: ModelConfig; readonly weightsBytes: number; }

export interface AdapterService extends Pick<AdapterManager, keyof AdapterManager> {}

export interface ModelContext<Model = RuntimeModel> {
  /** Releases owned artifacts, draft and loaded towers after execution stops. */
  dispose(): void;
  /** State serialization supplied by this model/backend implementation. */
  stateCodecs?: import("@mlx-bun/inference/state").CacheCodecProvider;
  model: Model;
  /** Declared external artifact/family profile that selected model
   * construction. Request-level methods are resolved separately. */
  profile: ResolvedModelProfile;
  tokenizer: LoadedTokenizer;
  template: ChatTemplate | null;
  /** The model's declared marker tokens for tool calls and the reasoning
   * channel, resolved against `tokenizer`; absent when generated text carries
   * them as ordinary text. */
  sentinels?: SentinelTokens | null;
  /** The model's declared chat-generation defaults; absent means the generic ones. */
  generationDefaults?: GenerationDefaults;
  modelId: string;
  /** Lazily-loaded vision tower cache — null until the first image request
   *  (see `getVisionTower`). The tower (SigLIP ~hundreds of MB, encoder-free
   *  smaller) is not loaded for text-only sessions. */
  vision: VisionEncoder | null;
  /** Loads + selects the vision tower on demand; null when the model has no
   *  (supported) vision sidecar. Invoked at most once, then cached in
   *  `vision`. */
  loadVision: (() => VisionEncoder) | null;
  /** Null when neither the config nor the model's declaration supplies the image soft tokens. */
  visionTokenIds: VisionTokenIds | null;
  /** Lazily-loaded Conformer audio tower — null until the first audio
   *  request (see `getAudioTower`). Same sidecar file as vision
   *  (optiq_vision.safetensors), separate tower; text-only sessions never
   *  pay for it. */
  audio: LoadedAudioEncoder | null;
  /** Loads the audio tower on demand; null when the model can't do audio
   *  (no `audio_config` in config.json or no sidecar). No flags — audio
   *  auto-enables exactly like vision. */
  loadAudio: (() => LoadedAudioEncoder) | null;
  /** null when the model has no `audio_config` (audio-incapable). */
  audioTokenIds: AudioTokenIds | null;
  /** Family media preparation, bound once at load; borrows this context. */
  media: MediaPreparation;
  adapters: AdapterService;
  /** Per-layer KV quantization from the repo's kv_config.json (null if
   *  absent). Applied by default — optiq serve's headline behavior;
   *  ServerOptions.kvQuant overrides ("off" | uniform bits). */
  kvConfig: KvQuantSpec[] | null;
  /** Model-author recommended sampling from generation_config.json —
   *  optiq serve injects these as server defaults (gen_config.py);
   *  explicit request fields always win. */
  genDefaults: GenSamplingDefaults;
  /** Selected draft provider; null means no draft configured. */
  draft?: {
    provider: import("@mlx-bun/inference/generation/speculative").DraftProvider;
    numDraftTokens: number;
    /** The provider is the checkpoint's own draft head, not a configured drafter. */
    native?: true;
  } | null;
  /** Present only for a runtime that plans its memory before opening weights:
   * the exact header-derived process equation it runs under. */
  memoryPlan?: MemoryPlan | null;
  /** Live telemetry of such a runtime, surfaced by `/stats`. */
  runtimeDiagnostics?(): Record<string, unknown>;
}

export type LoadedModelContext = ModelContext<ServedModelInfo>;

export interface ModelHostSource {
  readonly modelDir: string;
  readonly modelId: string | undefined;
  readonly options: Omit<LoadContextOptions, "implementations">;
}

export interface LoadContextOptions<Model extends ServedModelInfo = RuntimeModel> {
  /** Raw generation and embeddings do not require a chat template. Default true. */
  requireChatTemplate?: boolean;
  /** Engine-owned complete implementations may own their loader and methods.
   * Selection happens before opening the default resident or streamed weights. */
  implementations?: ModelImplementationProvider<ModelHostSource, Promise<ModelContext<Model>>>;
  profiles?: import("@mlx-bun/inference/models").ResolveModelProfileOptions;
  memoryBudgetBytes?: number;
  /** Resource overrides for runtimes that plan memory up front; models
   * without one ignore them. */
  runtime?: RuntimeOpenOptions;
  /** Snapshot dir of a draft model for speculative decoding
   * (`--draft-model`). Loaded alongside the target; the pair must share
   * a tokenizer family. */
  draftModelDir?: string;
  /** Drafts per round (`--num-draft-tokens`, mlx_lm.server default 3). */
  numDraftTokens?: number;
  /** Draft-provider kind override (`--draft-kind`); any kind the registry knows. */
  draftKind?: DraftKind | (string & {});
  /** The draft providers this load may select and detect among; defaults to
   * the library's. Extend a registry to add a provider kind. */
  draftProviders?: DraftProviderRegistry;
  /** A ready draft provider and its round width, instead of loading one from
   * `draftModelDir`/`draftKind`. The context owns it from the call on. */
  draftProvider?: LoadedDraft;
  ngramMax?: number;
  ngramMin?: number;
}

export interface GenSamplingDefaults {
  temperature?: number;
  topP?: number;
  topK?: number;
  repetitionPenalty?: number;
}

export { detectDraftKind, type DraftKind } from "@mlx-bun/inference/generation/speculative/draft-kind";

/** Serving requires a template; one-shot consumers retain main's raw fallback. */
export async function loadContextTemplate(modelDir: string, required: boolean,
  load: (directory: string) => Promise<ChatTemplate>): Promise<ChatTemplate | null> {
  try { return await load(modelDir); }
  catch (error) { if (required) throw error; return null; }
}

export function requireChatTemplate<T extends { template: ChatTemplate | null; modelId: string }>(context: T): asserts context is T & { template: ChatTemplate } {
  if (!context.template) throw new Error(`model ${context.modelId} has no chat template`);
}

async function loadGenSamplingDefaults(modelDir: string): Promise<GenSamplingDefaults> {
  const file = Bun.file(`${modelDir}/generation_config.json`);
  if (!(await file.exists())) return {};
  try {
    const raw = (await file.json()) as Record<string, unknown>;
    const num = (v: unknown) => (typeof v === "number" ? v : undefined);
    return {
      temperature: num(raw.temperature),
      topP: num(raw.top_p),
      topK: num(raw.top_k),
      repetitionPenalty: num(raw.repetition_penalty),
    };
  } catch {
    return {};
  }
}

export function loadContext<Model extends ServedModelInfo>(
  modelDir: string, modelId: string | undefined,
  opts: LoadContextOptions<Model> & {
    implementations: ModelImplementationProvider<ModelHostSource, Promise<ModelContext<Model>>>;
  },
): Promise<ModelContext<Model>>;
export function loadContext(modelDir: string, modelId?: string, opts?: LoadContextOptions): Promise<ModelContext>;
export function loadContext<Model extends ServedModelInfo>(
  modelDir: string, modelId: string | undefined, opts: LoadContextOptions<Model>,
): Promise<LoadedModelContext>;
export async function loadContext(
  modelDir: string, modelId?: string,
  opts: LoadContextOptions<ServedModelInfo> = {},
): Promise<LoadedModelContext> {
  const { loadModelConfig } = await import("@mlx-bun/inference/artifacts/config");
  const { resolveModelProfile } = await import("@mlx-bun/inference/models/profile");
  const config = await loadModelConfig(modelDir);
  const profile = resolveModelProfile(config, opts.profiles);
  if (opts.implementations) {
    const implementation = opts.implementations.select(config, profile);
    const { implementations: _provider, ...options } = opts;
    return implementation.create({ modelDir, modelId, options }, config, profile);
  }
  const [{ Weights }, { createModel, declaredGraph, openPlannedRuntime, plansMemory, loadModelChatTemplate,
      sentinelDeclarationFor, mediaTokenDeclarationFor, generationDefaultsFor },
    { loadTokenizer, resolveSentinelTokens, resolveVisionTokenIds, resolveAudioTokenIds },
    { AdapterManager }, { bindLegacyDraftTarget }, { defaultDraftProviders }] = await Promise.all([
    import("@mlx-bun/inference/artifacts"), import("@mlx-bun/inference/models"),
    import("@mlx-bun/inference/input"),
    import("@mlx-bun/inference/adapters"), import("@mlx-bun/inference/generation/speculative/binding"),
    import("@mlx-bun/inference/generation/speculative/draft-kind"),
  ]);
  const planned = plansMemory(profile);
  const draftRegistry = opts.draftProviders ?? defaultDraftProviders();
  if (opts.draftProvider && (opts.draftModelDir !== undefined || opts.draftKind !== undefined))
    throw new Error("a ready draft provider cannot combine with --draft-model/--draft-kind");
  // A kind that bundles its companion in the target artifact (`--draft-kind
  // mtp`: the artifact's own mtp/ subfolder — single-repo packaging, the
  // companion is a complete model dir the provider already loads) resolves
  // there when no --draft-model is given. Explicit --draft-model still wins; a
  // missing bundle is a clear refusal.
  const bundledCompanion = opts.draftKind === undefined ? undefined : draftRegistry.get(opts.draftKind)?.bundledCompanion;
  if (bundledCompanion && !opts.draftModelDir) {
    const bundled = `${modelDir}/${bundledCompanion}`;
    if (await Bun.file(`${bundled}/config.json`).exists()) {
      opts = { ...opts, draftModelDir: bundled };
    } else {
      throw new Error(
        `--draft-kind ${opts.draftKind} needs a companion: pass --draft-model <dir> or use ` +
        `an artifact that bundles one at <model>/${bundledCompanion}/ (none at ${bundled})`,
      );
    }
  }
  const externalDraft = opts.draftModelDir !== undefined || opts.draftKind !== undefined || opts.draftProvider !== undefined;
  const resolvedDraftKind = opts.draftModelDir
    ? opts.draftKind ?? await draftRegistry.detect(opts.draftModelDir)
    : opts.draftKind;
  if (planned && externalDraft && opts.runtime?.nativeDraft === true)
    throw new Error("the checkpoint-native draft head and --draft-model/--draft-kind are mutually exclusive");
  const owned = new Set<DisposableResource>();
  const release = (resource: DisposableResource) => { owned.delete(resource); resource.dispose(); };
  try {
    let weights: Weights | null = null;
    let model!: RuntimeModel;
    // A runtime that plans memory opens its own graph and owns its native draft head.
    let runtime: Awaited<ReturnType<typeof openPlannedRuntime>> | null = null;
    if (planned) {
      const nativeDraft = !externalDraft && opts.runtime?.nativeDraft !== false;
      runtime = await openPlannedRuntime(modelDir, profile, {
        ...opts.runtime,
        memoryBudgetBytes: opts.memoryBudgetBytes ?? opts.runtime?.memoryBudgetBytes,
        // Preserve the existing loader's draft residency equation.
        batchSize: nativeDraft || externalDraft ? 1 : opts.runtime?.batchSize,
        // An explicit alternate drafter replaces the native head.
        nativeDraft,
      });
      model = runtime.model;
      owned.add(runtime.model);
    } else {
      weights = await Weights.open(modelDir);
      owned.add(weights);
    }
    // memoryBudget enforcement at load: Weights.open only mmaps
    // (no GPU allocation yet), so a model whose weights can never serve
    // within the budget is refused HERE — before any unified-memory
    // commitment — with an actionable error instead of a Metal OOM later.
    if (!planned && opts.memoryBudgetBytes) {
      const weightsBytes = [...weights!.shards.files.values()]
        .reduce((a, f) => a + f.mmap.size, 0);
      const report = fit(config, weightsBytes, 1, undefined, undefined, 0, opts.memoryBudgetBytes);
      if (report.maxSafeContext < 1)
        throw new Error(
          `model does not fit the memory budget: weights ${(weightsBytes / 1e9).toFixed(2)} GB ` +
          `+ prefill transient leave no room for any context within ` +
          `${(opts.memoryBudgetBytes / 1e9).toFixed(2)} GB`,
        );
    }
    if (!planned) {
      model = createModel(weights!, config, profile);
      if ("dispose" in model && typeof model.dispose === "function") owned.add(model);
    }
    const tokenizer = await loadTokenizer(modelDir);
    // Generation must stop on the tokenizer's eos_token — the chat turn
    // terminator (e.g. Qwen <|im_end|> = 248046). Some configs (Qwen3.5-4B)
    // declare a different eos_token_id in config.json than the chat format
    // emits, so without this a turn never ends and generation runs away,
    // hallucinating both sides of the dialogue until max_tokens. mlx-lm stops on
    // the tokenizer eos; union it in. No-op when already present (Gemma, 27B).
    if (tokenizer.eosTokenId != null && !config.eosTokenIds.includes(tokenizer.eosTokenId))
      config.eosTokenIds = [...config.eosTokenIds, tokenizer.eosTokenId];

    // Speculative decoding: load the draft (mlx_lm.server --draft-model). The
    // draft artifact's KIND selects the provider, each of which recognizes and
    // loads its own artifact; all share ONE serve loop
    // (packages/inference/src/generation/speculative/run.ts). `--draft-kind`
    // overrides the detect.
    let draft: ModelContext["draft"] = null;
    let validateDraft = true;
    if (opts.draftProvider) {
      draft = opts.draftProvider;
      owned.add(draft.provider);
    } else if (resolvedDraftKind !== undefined) {
      const kind = draftRegistry.get(resolvedDraftKind);
      if (kind && !kind.artifact && opts.draftModelDir)
        throw new Error(`--draft-kind ${resolvedDraftKind} is model-free — drop --draft-model (it would be ignored)`);
      // Every artifact kind names an artifact to load — refuse instead of
      // silently serving without speculation.
      if (kind?.artifact && !opts.draftModelDir)
        throw new Error(`--draft-kind ${resolvedDraftKind} requires --draft-model`);
      draft = await draftRegistry.load(resolvedDraftKind, {
        dir: opts.draftModelDir, target: { vocabSize: config.text.vocabSize, tokenizer },
        numDraftTokens: opts.numDraftTokens, ngram: { max: opts.ngramMax, min: opts.ngramMin },
      });
      owned.add(draft.provider);
      // A model-free provider has no pairing to probe and no weights to budget.
      validateDraft = kind!.artifact;
    }
    if (draft && validateDraft) {
      const { provider } = draft;
      // Fail-fast pairing validation (2026-07-07 review): a source validates the
      // (target, drafter) pairing in open() — a target that lacks the port it
      // reads, DeepSpec target-layer-count mismatch — which used to surface as a
      // 500 from inside specServeRun on EVERY text request. Probe-open once with
      // throwaway caches here so a mismatch refuses at load; open() allocates no
      // per-request tensors before prefill/draft, so this is free. The probe
      // sampler is never called during open().
      {
        const probeCaches = model.makeCache();
        try {
          provider
            .open({
              sampler: () => { throw new Error("probe sampler never samples"); },
              target: bindLegacyDraftTarget(model, probeCaches),
            })
            .dispose();
        } catch (err) {
          release(provider);
          throw new Error(
            `--draft-model is incompatible with this target: ${err instanceof Error ? err.message : String(err)}`,
          );
        } finally {
          for (const c of probeCaches) c.dispose();
        }
      }
      if (opts.memoryBudgetBytes) {
        const targetBytes = weights
          ? [...weights.shards.files.values()].reduce((a, f) => a + f.mmap.size, 0)
          : model.weightsBytes;
        // Draft weights shrink the target's envelope. Draft KV is not modeled
        // (small relative to its weights at serve contexts); admission stays
        // approximately conservative via the combined-weights term.
        const report = fit(config, targetBytes + provider.weightsBytes, 1, undefined, undefined, 0, opts.memoryBudgetBytes);
        if (report.maxSafeContext < 1) {
          release(provider);
          throw new Error(
            `target + draft do not fit the memory budget (draft adds ` +
              `${(provider.weightsBytes / 1e9).toFixed(2)} GB)`,
          );
        }
      }
    }

    // A checkpoint-native draft head (a planned runtime's is the production
    // default) comes from the graph's own declaration: it uses the
    // already-planned bounded auxiliary tier and the same tokenizer, so there is
    // no second artifact or compatibility probe to load.
    if (!draft) {
      const declared = await draftRegistry.native(model);
      if (declared) draft = { ...declared, native: true };
    }

    if (draft) owned.add(draft.provider);
    const adapters = new AdapterManager(model);
    owned.add({ dispose() { disposeResources(adapters.list().map(({ id }) => ({ dispose() { adapters.unmount(id); } }))); } });
    // A compiled decode step borrows graph constants and weights. Retire it first,
    // after the owning engine has drained, including if later loading fails.
    owned.add({ dispose() { declaredGraph(model).releaseCompiledDecode?.(); } });
    const template = await loadContextTemplate(modelDir, opts.requireChatTemplate ?? true, dir => loadModelChatTemplate(dir, profile));
    const id = modelId ?? modelDir.split("/").filter(Boolean).at(-1)!;
    // Soft-token ids: the checkpoint's config, else the token text the profile declares.
    const mediaTokens = mediaTokenDeclarationFor(profile);
    const visionTokenIds = resolveVisionTokenIds(config.raw, tokenizer, mediaTokens?.vision ?? null);
    const audioTokenIds = resolveAudioTokenIds(config.raw, tokenizer, mediaTokens?.audio ?? null);
    const sentinelTexts = sentinelDeclarationFor(profile);
    const { bindMediaPreparation } = await import("./media-preparation");
    // Encoders load lazily (getVisionTower/getAudioTower): text-only sessions
    // never pay for a tower. The graph knows which its checkpoint ships.
    const encoders = await declaredGraph(model).mediaEncoders?.(modelDir, { shipsAudioTower: sidecarShipsAudioTower })
      ?? { vision: null, audio: null };
    const context: Omit<ModelContext, "dispose"> = {
      draft,
      model,
      profile,
      sentinels: sentinelTexts ? resolveSentinelTokens(tokenizer, sentinelTexts) : null,
      generationDefaults: generationDefaultsFor(profile),
      memoryPlan: runtime?.memoryPlan ?? null,
      ...(runtime ? { runtimeDiagnostics: runtime.diagnostics } : {}),
      adapters,
      kvConfig: config.kvQuant,
      genDefaults: await loadGenSamplingDefaults(modelDir),
      tokenizer,
      template,
      modelId: id,
      vision: null,
      loadVision: encoders.vision,
      visionTokenIds,
      // Audio mirrors vision: loaded on the first audio request only
      // (`02d723a:docs/design/generic-model-support.md` §6.6).
      audio: null,
      loadAudio: encoders.audio,
      audioTokenIds,
      // The family route is chosen once; it borrows the towers through this
      // context's lazy slots, so the context stays their only owner.
      media: await bindMediaPreparation({
        modelId: id, tokenizer, template, visionTokenIds, audioTokenIds,
        visionTower: () => getVisionTower(context), audioTower: () => getAudioTower(context),
      }, model),
    };
    return ownModelContext(context, [...owned].reverse());
  } catch (error) { return cleanupFailure(error, () => disposeResources([...owned].reverse())); }
}

/** Lazily load + cache the vision tower on first use. A sidecar that fails
 *  to load is a capability gap, not a fatal error: returns null and the
 *  request is answered with a 400 (the loader is cleared so we don't retry
 *  a known-bad load every request). */
export function getVisionTower(ctx: Pick<ModelContext<unknown>, "vision" | "loadVision">): VisionEncoder | null {
  if (ctx.vision) return ctx.vision;
  if (!ctx.loadVision) return null;
  try {
    ctx.vision = ctx.loadVision();
    return ctx.vision;
  } catch (e) {
    console.warn(`vision sidecar not loadable (${(e as Error).message}) — serving text-only`);
    ctx.loadVision = null;
    return null;
  }
}

/** Lazily load + cache the audio tower on first use. Unlike vision's
 *  warn-and-continue (text-only degrade is correct for requests WITHOUT
 *  images), this is only ever consulted for requests WITH audio — the
 *  caller turns null into an explicit 400, never a silent text-only
 *  degrade. A failed load is not retried every request. (The stub-sidecar
 *  case — the local 12B state — never gets here: the graph checks the
 *  sidecar header and returns a null loader.) */
export function getAudioTower(ctx: Pick<ModelContext<unknown>, "audio" | "loadAudio">): LoadedAudioEncoder | null {
  if (ctx.audio) return ctx.audio;
  if (!ctx.loadAudio) return null;
  try {
    ctx.audio = ctx.loadAudio();
    return ctx.audio;
  } catch (e) {
    console.warn(`audio sidecar not loadable (${(e as Error).message})`);
    ctx.loadAudio = null;
    return null;
  }
}

/** Who releases a served context. "owned": its server disposes it once, after
 * execution drains, including when startup fails. "borrowed": its server never
 * disposes it; the caller keeps it usable and disposes it after the server closed. */
export type ContextOwnership = "owned" | "borrowed";

/** The one release rule every serving composition applies to its context. */
export function releaseContext(context: { dispose(): void }, ownership: ContextOwnership): void {
  if (ownership === "owned") context.dispose();
}

/** Attach an idempotent owner to a loaded context. Supplied resources are owned,
 * never borrowed; all are attempted even when an individual cleanup fails. */
export function ownModelContext<Model extends ServedModelInfo>(
  context: Omit<ModelContext<Model>, "dispose">, resources: readonly DisposableResource[],
): ModelContext<Model> {
  const owned = [...resources];
  let disposed = false;
  return Object.assign(context, {
    dispose() {
      if (disposed) return;
      disposed = true;
      const media = [context.vision, context.audio].filter((value): value is NonNullable<typeof value> => value != null);
      context.vision = null; context.audio = null;
      context.loadVision = null; context.loadAudio = null;
      disposeResources([...media.map(value => ({ dispose() { value.dispose?.(); } })), ...owned]);
    },
  });
}
