// Own one loaded model, its draft and lazy media towers. Application entry
// points supply the artifact and options; no HTTP or scheduling lives here.
import { existsSync } from "node:fs";
import type { KvQuantSpec, ModelConfig } from "@mlx-bun/inference/artifacts/config";
import type { Weights } from "@mlx-bun/inference/artifacts";
import type { RuntimeModel, Glm52RuntimeOpenOptions, ResolvedModelProfile, ModelImplementationProvider } from "@mlx-bun/inference/models";
import type { Glm52MemoryPlan } from "@mlx-bun/inference/artifacts/glm52";
import type { ChatTemplate, LoadedTokenizer } from "@mlx-bun/inference/input";
import type { AdapterManager } from "@mlx-bun/inference/adapters";
import type { AudioTokenIds, VisionTokenIds, VisionEncoder } from "@mlx-bun/inference/input/vision";
import type { AudioTower } from "@mlx-bun/inference/models/audio/conformer";
import { sidecarShipsAudioTower, fit } from "@mlx-bun/hub";
import { cleanupFailure, disposeResources } from "@mlx-bun/inference/runtime/resources";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";

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
  template: ChatTemplate;
  modelId: string;
  /** Lazily-loaded vision tower cache — null until the first image request
   *  (see `getVisionTower`). The tower (SigLIP ~hundreds of MB, encoder-free
   *  smaller) is not loaded for text-only sessions. */
  vision: VisionEncoder | null;
  /** Loads + selects the vision tower on demand; null when the model has no
   *  (supported) vision sidecar. Invoked at most once, then cached in
   *  `vision`. */
  loadVision: (() => VisionEncoder) | null;
  visionTokenIds: VisionTokenIds;
  /** Lazily-loaded Conformer audio tower — null until the first audio
   *  request (see `getAudioTower`). Same sidecar file as vision
   *  (optiq_vision.safetensors), separate tower; text-only sessions never
   *  pay for it. */
  audio: AudioTower | null;
  /** Loads the audio tower on demand; null when the model can't do audio
   *  (no `audio_config` in config.json or no sidecar). No flags — audio
   *  auto-enables exactly like vision. */
  loadAudio: (() => AudioTower) | null;
  /** null when the model has no `audio_config` (audio-incapable). */
  audioTokenIds: AudioTokenIds | null;
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
  } | null;
  /** Present only for the direct Colibri GLM runtime. This is the exact
   * header-derived process equation used before opening resident state. */
  glmMemoryPlan?: Glm52MemoryPlan | null;
}

export type LoadedModelContext = ModelContext<ServedModelInfo>;

export interface ModelHostSource {
  readonly modelDir: string;
  readonly modelId: string | undefined;
  readonly options: Omit<LoadContextOptions, "implementations">;
}

export interface LoadContextOptions<Model extends ServedModelInfo = RuntimeModel> {
  /** Engine-owned complete implementations may own their loader and methods.
   * Selection happens before opening the default resident or streamed weights. */
  implementations?: ModelImplementationProvider<ModelHostSource, Promise<ModelContext<Model>>>;
  profiles?: import("@mlx-bun/inference/models").ResolveModelProfileOptions;
  memoryBudgetBytes?: number;
  /** Direct Colibri runtime/resource overrides. Ignored by other models. */
  glm?: Glm52RuntimeOpenOptions;
  /** Snapshot dir of a draft model for speculative decoding
   * (`--draft-model`). Loaded alongside the target; the pair must share
   * a tokenizer family. */
  draftModelDir?: string;
  /** Drafts per round (`--num-draft-tokens`, mlx_lm.server default 3). */
  numDraftTokens?: number;
  /** Draft-provider kind override (`--draft-kind`). */
  draftKind?: DraftKind;
  ngramMax?: number;
  ngramMin?: number;
}

export interface GenSamplingDefaults {
  temperature?: number;
  topP?: number;
  topK?: number;
  repetitionPenalty?: number;
}

export type DraftKind = "dspark" | "deepspec" | "assistant" | "two-model" | "ngram" | "mtp";

/** Detect the draft artifact's kind so the right provider is loaded. All
 *  providers share ONE serve loop (src/spec/serve-loop.ts). Exported for the
 *  bench harness (scripts/bench-matrix.ts features) — one detection, no drift.
 *  "ngram" is never detected — it has no artifact (model-free prompt lookup,
 *  src/spec/ngram-source.ts) and mounts via an explicit `--draft-kind ngram`. */
export async function detectDraftKind(dir: string): Promise<DraftKind> {
  if (await Bun.file(`${dir}/dspark.json`).exists()) return "dspark"; // our trained module
  try {
    const cfg = (await Bun.file(`${dir}/config.json`).json()) as {
      model_type?: string;
      architectures?: string[];
    };
    // DeepSeek's released DSpark drafters (DeepSpec reference): no
    // dspark.json, plain HF config stamped Gemma4DSparkModel.
    if (cfg.architectures?.[0] === "Gemma4DSparkModel") return "deepspec";
    if (String(cfg.model_type ?? "").includes("assistant")) return "assistant";
    // Native MTP heads split from a qwen3_5-family release
    // (mlx-community/Qwen3.8-27B-MTP-*): model_type "qwen3_5_mtp". The
    // target's recurrent DeltaNet caches roll back via the serve loop's
    // spec-round snapshot/replay contract (SSMCache.specRound*).
    if (String(cfg.model_type ?? "").endsWith("_mtp")) return "mtp";
  } catch {
    // no/unreadable config → fall through to a full second model
  }
  return "two-model";
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
  const { resolveModelProfile } = await import("@mlx-bun/inference/models");
  const config = await loadModelConfig(modelDir);
  const profile = resolveModelProfile(config, opts.profiles);
  if (opts.implementations) {
    const implementation = opts.implementations.select(config, profile);
    const { implementations: _provider, ...options } = opts;
    return implementation.create({ modelDir, modelId, options }, config, profile);
  }
  const [{ Weights }, { createModel, openGlm52RuntimeModel }, { Glm52Model },
    { ChatTemplate, loadTokenizer }, { AdapterManager }, { bindLegacyDraftTarget }, { Glm52NativeMtpProvider }] = await Promise.all([
    import("@mlx-bun/inference/artifacts"), import("@mlx-bun/inference/models"),
    import("@mlx-bun/inference/models/glm52"), import("@mlx-bun/inference/input"),
    import("@mlx-bun/inference/adapters"), import("@mlx-bun/inference/generation/speculative/binding"),
    import("@mlx-bun/inference/generation/speculative"),
  ]);
  const glm = profile.profile.execution.loader === "colibri";
  // Bundled MTP companion: `--draft-kind mtp` with no --draft-model resolves
  // to the artifact's own mtp/ subfolder (single-repo packaging — the
  // companion is a complete model dir the provider already loads). Explicit
  // --draft-model still wins; a missing bundle is a clear refusal below.
  if (opts.draftKind === "mtp" && !opts.draftModelDir) {
    const bundled = `${modelDir}/mtp`;
    if (await Bun.file(`${bundled}/config.json`).exists()) {
      opts = { ...opts, draftModelDir: bundled };
    } else {
      throw new Error(
        `--draft-kind mtp needs a companion: pass --draft-model <dir> or use ` +
        `an artifact that bundles one at <model>/mtp/ (none at ${bundled})`,
      );
    }
  }
  const externalDraft = opts.draftModelDir !== undefined || opts.draftKind !== undefined;
  const resolvedDraftKind = opts.draftModelDir
    ? opts.draftKind ?? await detectDraftKind(opts.draftModelDir)
    : opts.draftKind;
  if (glm && externalDraft && opts.glm?.enableMtp === true)
    throw new Error("native GLM MTP and --draft-model/--draft-kind are mutually exclusive");
  const owned = new Set<DisposableResource>();
  const release = (resource: DisposableResource) => { owned.delete(resource); resource.dispose(); };
  try {
    let weights: Weights | null = null;
    let model!: RuntimeModel;
    let glmMemoryPlan: Glm52MemoryPlan | null = null;
    if (glm) {
      const enableNativeMtp = !externalDraft && opts.glm?.enableMtp !== false;
      const opened = await openGlm52RuntimeModel(modelDir, {
        ...opts.glm,
        memoryBudgetBytes: opts.memoryBudgetBytes ?? opts.glm?.memoryBudgetBytes,
        // Preserve the existing loader's draft residency equation.
        batchSize: enableNativeMtp || externalDraft ? 1 : opts.glm?.batchSize,
        // An explicit alternate drafter replaces native MTP.
        enableMtp: enableNativeMtp,
      });
      model = opened.model;
      owned.add(opened.model);
      glmMemoryPlan = opened.plan;
    } else {
      weights = await Weights.open(modelDir);
      owned.add(weights);
    }
    // memoryBudget enforcement at load: Weights.open only mmaps
    // (no GPU allocation yet), so a model whose weights can never serve
    // within the budget is refused HERE — before any unified-memory
    // commitment — with an actionable error instead of a Metal OOM later.
    if (!glm && opts.memoryBudgetBytes) {
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
    if (!glm) model = createModel(weights!, config, profile);
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
    // draft artifact's KIND selects the provider — all three share ONE serve
    // loop (src/spec/serve-loop.ts): dspark.json → DSpark (KV-injected), a
    // *_assistant config → the optiq KV-borrowing Gemma drafter, otherwise a
    // full second model (mlx-lm parity). `--draft-kind` overrides the detect.
    let draft: ModelContext["draft"] = null;
    if (opts.draftKind === "ngram") {
      // Model-free prompt lookup: no artifact, no dir, no probe/budget concerns
      // (weightsBytes 0, open() never throws). Default γ=10 per the reference
      // implementation — drafting is free, so wide blocks cost only verify-window
      // width when wrong.
      if (opts.draftModelDir)
        throw new Error(
          "--draft-kind ngram is model-free — drop --draft-model (it would be ignored)",
        );
      const { NgramProvider } = await import("@mlx-bun/inference/generation/speculative");
      draft = {
        provider: new NgramProvider({ max: opts.ngramMax, min: opts.ngramMin }),
        numDraftTokens: Math.max(1, opts.numDraftTokens ?? 10),
      };
    } else if (opts.draftModelDir) {
      const dir = opts.draftModelDir;
      const kind = resolvedDraftKind!;
      let provider: import("@mlx-bun/inference/generation/speculative").DraftProvider;
      let numDraftTokens = Math.max(1, opts.numDraftTokens ?? 3);
      if (kind === "dspark") {
        const { DflashProvider } = await import("@mlx-bun/inference/generation/speculative");
        const p = await DflashProvider.load(dir);
        provider = p;
        owned.add(provider);
        // Pin to the trained block width — the serve loop must never ask for
        // more positions than the DSpark block was trained for (n ≤ cfg.gamma).
        numDraftTokens = Math.max(1, Math.min(opts.numDraftTokens ?? p.gamma, p.gamma));
      } else if (kind === "deepspec") {
        const { DeepspecProvider } = await import("@mlx-bun/inference/generation/speculative");
        const p = await DeepspecProvider.load(dir);
        provider = p;
        owned.add(provider);
        // Same pin, from their config's block_size (e.g. 7 for the released
        // dspark_gemma4_12b_block7).
        numDraftTokens = Math.max(1, Math.min(opts.numDraftTokens ?? p.gamma, p.gamma));
      } else if (kind === "assistant") {
        const { AssistantProvider } = await import("@mlx-bun/inference/generation/speculative");
        provider = await AssistantProvider.load(dir);
        owned.add(provider);
      } else if (kind === "mtp") {
        const { QwenMtpProvider } = await import("@mlx-bun/inference/generation/speculative");
        const p = await QwenMtpProvider.load(dir);
        provider = p;
        owned.add(provider);
        // Default the round width to the head's trained block (block_size 3 →
        // 2 recursive drafts + the pending row per round; the head was trained
        // multi-step, so an explicit larger --num-draft-tokens is allowed but
        // acceptance decides whether it pays).
        const block = (await Bun.file(`${dir}/config.json`).json() as { block_size?: number }).block_size;
        if (opts.numDraftTokens === undefined && typeof block === "number")
          numDraftTokens = Math.max(1, block - 1);
      } else {
        const { TwoModelProvider } = await import("@mlx-bun/inference/generation/speculative");
        provider = await TwoModelProvider.load(dir, config.text.vocabSize);
        owned.add(provider);
        // Tokenizer-family hard check — two-model ONLY (it ships its own
        // tokenizer). Exact-token-match acceptance is meaningful only when both
        // models tokenize identically; a probe that ENCODES differently means
        // different families — refuse instead of silently accepting ~0% of
        // drafts. The KV-borrowing drafters share the target's tokenization by
        // construction, so this check does not apply to them.
        const draftTok = await loadTokenizer(dir);
        const probe = "The 3 quick brown foxes jumped över the lazy dog?! 🦊";
        if (JSON.stringify(tokenizer.encode(probe)) !== JSON.stringify(draftTok.encode(probe))) {
          release(provider);
          throw new Error(
            `--draft-model tokenizer differs from the target's (probe string encodes ` +
              `differently) — speculation needs the same tokenizer family`,
          );
        }
      }
      // Fail-fast pairing validation (2026-07-07 review): the KV-borrowing
      // sources validate the (target, drafter) pairing in open() — non-Gemma4
      // target, DeepSpec target-layer-count mismatch — which used to surface
      // as a 500 from inside specServeRun on EVERY text request. Probe-open
      // once with throwaway caches here so a mismatch refuses at load; open()
      // allocates no per-request tensors before prefill/draft, so this is
      // free. The probe sampler is never called during open().
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
      draft = { provider, numDraftTokens };
    } else if (opts.draftKind) {
      // Every other kind names an artifact to load — refuse instead of silently
      // serving without speculation.
      throw new Error(`--draft-kind ${opts.draftKind} requires --draft-model`);
    }

    // GLM's checkpoint-native MTP row is the production default. It uses the
    // already-planned bounded auxiliary expert tier and the same tokenizer, so
    // there is no second artifact or compatibility probe to load.
    if (!draft && model instanceof Glm52Model && glmMemoryPlan?.enableMtp) {
      draft = {
        provider: new Glm52NativeMtpProvider(model),
        numDraftTokens: glmMemoryPlan.mtpDraftTokens,
      };
    }

    if (draft) owned.add(draft.provider);
    const adapters = new AdapterManager(model);
    owned.add({ dispose() { disposeResources(adapters.list().map(({ id }) => ({ dispose() { adapters.unmount(id); } }))); } });
    const context = {
      draft,
      model,
      profile,
      glmMemoryPlan,
      adapters,
      kvConfig: config.kvQuant,
      genDefaults: await loadGenSamplingDefaults(modelDir),
      tokenizer,
      template: await ChatTemplate.load(modelDir),
      modelId: modelId ?? modelDir.split("/").filter(Boolean).at(-1)!,
      // Vision is loaded lazily (getVisionTower) — text-only sessions never
      // pay for the tower. The loader picks the encoder-free gemma4_unified
      // (12B) tower vs the SigLIP encoder (e2b/e4b/26B/31B) by the sidecar's
      // vision_config.model_type. Vision sidecars are a Gemma4 feature;
      // MiniCPM5 never ships one.
      vision: null,
      loadVision: await makeVisionLoader(modelDir, model, config),
      visionTokenIds: {
        imageTokenId: (config.raw.image_token_id as number) ?? 258880,
        boiTokenId: (config.raw.boi_token_id as number) ?? 255999,
        eoiTokenId: (config.raw.eoi_token_id as number) ?? 258882,
      },
      // Audio mirrors vision: lazy tower from the same sidecar, loaded on the
      // first audio request only (docs/design/generic-model-support.md A4).
      audio: null,
      loadAudio: await makeAudioLoader(modelDir, model, config),
      audioTokenIds: config.raw.audio_config
        ? {
            audioTokenId: (config.raw.audio_token_id as number) ?? 258881,
            boaTokenId: (config.raw.boa_token_id as number) ?? 256000,
            eoaTokenId: (config.raw.eoa_token_id as number) ?? 258883,
          }
        : null,
    };
    return ownModelContext(context, [...owned].reverse());
  } catch (error) { return cleanupFailure(error, () => disposeResources([...owned].reverse())); }
}

/** Build the on-demand vision-tower loader, selecting the encoder-free
 *  (gemma4_unified, 12B) tower vs the SigLIP encoder (gemma4_vision:
 *  e2b/e4b/26B/31B) by the sidecar's vision_config.model_type. Returns null
 *  when the model has no usable vision sidecar. */
export async function makeVisionLoader(
  modelDir: string, model: RuntimeModel, config: ModelConfig,
): Promise<(() => VisionEncoder) | null> {
  const [{ Qwen35Model }, { Gemma4Model }] = await Promise.all([
    import("@mlx-bun/inference/models/qwen3_5"), import("@mlx-bun/inference/models/gemma4"),
  ]);
  // Qwen3.5/3.8: the tower ships as optiq/optiq_vision.safetensors (the
  // artifact's bf16 sidecar). The returned tower is a Qwen3VLVisionTower —
  // it rides the same lazy slot/capability flags; the qwen chat branch is
  // the only consumer and casts it back (the gemma branches are gated on
  // `instanceof Gemma4Model`, so the union never crosses).
  if (model instanceof Qwen35Model) {
    // Vision weights arrive either as the OptiQ-convention sidecar OR in-main
    // (mlx-vlm convention; our artifacts ship one copy in-main since
    // 2026-08-18 — the tower loader handles both).
    const hasSidecar = existsSync(`${modelDir}/optiq/optiq_vision.safetensors`);
    const hasInMain = config.raw.vision_config !== undefined;
    if (!hasSidecar && !hasInMain) return null;
    const { Qwen3VLVisionTower } = await import("@mlx-bun/inference/models/vision/qwen3vl");
    return () =>
      Qwen3VLVisionTower.load(modelDir) as unknown as VisionEncoder;
  }
  if (!(config.hasVisionSidecar && model instanceof Gemma4Model)) return null;
  const vc = config.raw.vision_config as Record<string, any> | undefined;
  if (vc?.model_type === "gemma4_vision") {
    const { SiglipVisionTower, parseSiglipConfig } = await import("@mlx-bun/inference/models/vision/siglip");
    const sigCfg = parseSiglipConfig(vc);
    return () => SiglipVisionTower.load(modelDir, sigCfg, model.embedScale);
  }
  // gemma4_unified_vision (or unlabelled): the encoder-free patch embedder.
  const { VisionTower } = await import("@mlx-bun/inference/embeddings/vision");
  return () => VisionTower.load(modelDir, model.embedScale, config.text.rmsNormEps);
}

/** Lazily load + cache the vision tower on first use. A sidecar that fails
 *  to load is a capability gap, not a fatal error: returns null and the
 *  request is answered with a 400 (the loader is cleared so we don't retry
 *  a known-bad load every request). */
export function getVisionTower(ctx: ModelContext): VisionEncoder | null {
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

/** Build the on-demand audio-tower loader (gemma-4 Conformer, A4 of
 *  docs/design/generic-model-support.md). Auto-enables — no flags — when
 *  config.json carries an `audio_config` AND the optiq_vision.safetensors
 *  sidecar exists (the audio tensors ship in the same sidecar as vision).
 *  Returns null when the model can't do audio (no audio_config: 26B-A4B,
 *  DiffusionGemma, bf16 assistants — architectural, not a porting gap). */
export async function makeAudioLoader(
  modelDir: string, model: RuntimeModel, config: ModelConfig,
): Promise<(() => AudioTower) | null> {
  const { Gemma4Model } = await import("@mlx-bun/inference/models/gemma4");
  if (!(config.hasVisionSidecar && config.raw.audio_config && model instanceof Gemma4Model))
    return null;
  // The sidecar header must actually name the Conformer tensors: the local
  // 12B snapshot pairs audio_config with a STUB sidecar (embed_audio only),
  // and a non-null loader here is what advertises `audio: true` on every
  // capability surface (ws handshake, /v1/models). Header-only read.
  if (!sidecarShipsAudioTower(`${modelDir}/optiq_vision.safetensors`)) return null;
  const { AudioTower, parseAudioConfig } = await import("@mlx-bun/inference/models/audio/conformer");
  const audioCfg = parseAudioConfig(config.raw.audio_config as Record<string, any>);
  return () => AudioTower.load(modelDir, audioCfg, model.embedScale);
}

/** Lazily load + cache the audio tower on first use. Unlike vision's
 *  warn-and-continue (text-only degrade is correct for requests WITHOUT
 *  images), this is only ever consulted for requests WITH audio — the
 *  caller turns null into an explicit 400, never a silent text-only
 *  degrade. A failed load is not retried every request. (The stub-sidecar
 *  case — the local 12B state — never gets here: makeAudioLoader checks the
 *  sidecar header and returns a null loader.) */
export function getAudioTower(ctx: ModelContext): AudioTower | null {
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
