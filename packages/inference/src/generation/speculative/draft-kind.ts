import { isAssistantModelType, isDeepspecDrafterConfig, isDflash2DrafterConfig, isMtpModelType, NATIVE_MTP_DRAFT } from "../../models/drafters";
import type { DraftProvider } from "./source";
import { DraftProviderRegistry, type DraftLoadRequest, type DraftProviderKind, type LoadedDraft } from "./draft-registry";

export const DRAFT_KINDS = ["dspark", "deepspec", "dflash2", "assistant", "mtp", "two-model", "ngram"] as const;
export type DraftKind = typeof DRAFT_KINDS[number];

/** The library's draft providers. Each entry is the provider's own convention
 *  for recognizing its artifact (files only, never MLX) and for loading it; the
 *  provider modules load on demand. All providers share ONE serve loop
 *  (run.ts). "ngram" has no artifact (model-free prompt lookup,
 *  sources/ngram-source.ts) and is chosen only by name.
 *  The two-model provider, a full second model, is the catch-all: it accepts
 *  whatever no other provider recognizes. */
export function defaultDraftProviders(): DraftProviderRegistry {
  return new DraftProviderRegistry()
    .register(dspark).register(deepspec).register(dflash2).register(assistant).register(mtp).register(twoModel).register(ngram)
    .registerNative(nativeMtp);
}

/** Detect the draft artifact's kind among the library's providers. */
export async function detectDraftKind(dir: string): Promise<DraftKind> {
  return await defaultDraftProviders().detect(dir) as DraftKind;
}

const artifactDir = (request: DraftLoadRequest): string => {
  if (request.dir === undefined) throw new Error("this draft provider loads an artifact directory");
  return request.dir;
};
const fixedWidth = (request: DraftLoadRequest, fallback: number) => Math.max(1, request.numDraftTokens ?? fallback);
/** A block-trained drafter never verifies more positions than it was trained for. */
const pinned = (request: DraftLoadRequest, gamma: number) => Math.max(1, Math.min(request.numDraftTokens ?? gamma, gamma));

/** Our trained module: dspark.json beside the weights. */
const dspark: DraftProviderKind = {
  kind: "dspark", artifact: true,
  detect: artifact => artifact.has("dspark.json"),
  async load(request) {
    const { DflashProvider } = await import("./sources/dflash-source");
    const provider = await DflashProvider.load(artifactDir(request));
    return { provider, numDraftTokens: pinned(request, provider.gamma) };
  },
};

/** DeepSeek's released DSpark drafters (DeepSpec reference): no dspark.json,
 *  a plain HF config stamped Gemma4DSparkModel. The width pins to their
 *  config's block_size (e.g. 7 for dspark_gemma4_12b_block7). */
const deepspec: DraftProviderKind = {
  kind: "deepspec", artifact: true,
  detect: async artifact => isDeepspecDrafterConfig(await artifact.config()),
  async load(request) {
    const { DeepspecProvider } = await import("./sources/deepspec-source");
    const provider = await DeepspecProvider.load(artifactDir(request));
    return { provider, numDraftTokens: pinned(request, provider.gamma) };
  },
};

/** DFlash 2 block drafters (z-lab/incoai): a plain HF config stamped
 *  DFlash2DraftModel. The width pins to block_size − 1 (7). */
const dflash2: DraftProviderKind = {
  kind: "dflash2", artifact: true,
  detect: async artifact => isDflash2DrafterConfig(await artifact.config()),
  async load(request) {
    const { Dflash2Provider } = await import("./sources/dflash2-source");
    const provider = await Dflash2Provider.load(artifactDir(request));
    return { provider, numDraftTokens: pinned(request, provider.gamma) };
  },
};

/** The optiq KV-borrowing drafter (a *_assistant config). */
const assistant: DraftProviderKind = {
  kind: "assistant", artifact: true,
  detect: async artifact => isAssistantModelType(String((await artifact.config())?.model_type ?? "")),
  async load(request) {
    const { AssistantProvider } = await import("./sources/assistant-source");
    return { provider: await AssistantProvider.load(artifactDir(request)), numDraftTokens: fixedWidth(request, 3) };
  },
};

/** Native MTP heads split from a qwen3_5-family release
 *  (mlx-community/Qwen3.8-27B-MTP-*). The target's recurrent DeltaNet caches
 *  roll back via the serve loop's spec-round snapshot/replay contract
 *  (SSMCache.specRound*). A target artifact may bundle the head at `mtp/`. */
const mtp: DraftProviderKind = {
  kind: "mtp", artifact: true, bundledCompanion: "mtp",
  detect: async artifact => isMtpModelType(String((await artifact.config())?.model_type ?? "")),
  async load(request) {
    const dir = artifactDir(request);
    const { QwenMtpProvider } = await import("./sources/qwen-mtp-source");
    const provider = await QwenMtpProvider.load(dir);
    // Default the round width to the head's trained block (block_size 3 → 2
    // recursive drafts + the pending row per round; the head was trained
    // multi-step, so an explicit larger width is allowed but acceptance
    // decides whether it pays).
    const block = (await Bun.file(`${dir}/config.json`).json() as { block_size?: number }).block_size;
    const numDraftTokens = request.numDraftTokens === undefined && typeof block === "number"
      ? Math.max(1, block - 1) : fixedWidth(request, 3);
    return { provider, numDraftTokens };
  },
};

const PROBE = "The 3 quick brown foxes jumped över the lazy dog?! 🦊";

/** A full second model (mlx-lm parity). It ships its own tokenizer, and exact
 *  token-match acceptance is meaningful only when both models tokenize
 *  identically: a probe that ENCODES differently means different families —
 *  refuse instead of silently accepting ~0% of drafts. */
const twoModel: DraftProviderKind = {
  kind: "two-model", artifact: true, fallback: true,
  detect: async () => true,
  async load(request) {
    const dir = artifactDir(request);
    const { TwoModelProvider } = await import("./sources/two-model");
    const { loadTokenizer } = await import("../../input");
    const provider = await TwoModelProvider.load(dir, request.target.vocabSize);
    try {
      const draftTokenizer = await loadTokenizer(dir);
      if (JSON.stringify(request.target.tokenizer.encode(PROBE)) !== JSON.stringify(draftTokenizer.encode(PROBE)))
        throw new Error(
          `the draft model's tokenizer differs from the target's (probe string encodes ` +
            `differently) — speculation needs the same tokenizer family`);
    } catch (error) { provider.dispose(); throw error; }
    return { provider, numDraftTokens: fixedWidth(request, 3) };
  },
};

/** Model-free prompt lookup: no artifact, weightsBytes 0, open() never throws.
 *  Default γ=10 per the reference implementation — drafting is free, so wide
 *  blocks cost only verify-window width when wrong. */
const ngram: DraftProviderKind = {
  kind: "ngram", artifact: false,
  async load(request): Promise<LoadedDraft> {
    const { NgramProvider } = await import("./sources/ngram-source");
    return { provider: new NgramProvider({ max: request.ngram?.max, min: request.ngram?.min }), numDraftTokens: fixedWidth(request, 10) };
  },
};

/** The checkpoint-native MTP row of a graph that declares it: the graph
 *  declares the head and its width; this binds the provider that drives it. */
const nativeMtp = {
  kind: NATIVE_MTP_DRAFT,
  async create(graph: object): Promise<DraftProvider> {
    const { Glm52NativeMtpProvider } = await import("./sources/glm52-mtp-source");
    return new Glm52NativeMtpProvider(graph);
  },
};
