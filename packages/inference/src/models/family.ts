// A model family is one record: what accepts a parsed config, which graph runs
// it, how it is composed, and every fact the layers above read about it. The
// records are listed once in `models/families.ts`; support tiers, profiles,
// engine capabilities, implementation composition and the declarations
// (training, generation, embedding, sentinels, media tokens, chat fallback)
// are all derived from that list. Records are native-free: they never import a
// graph class, so listing a model's support never loads MLX.

import type { ModelConfig } from "../artifacts/config";
import type { TemplateFallback } from "../input/chat-template";
import type { MediaTokenTexts, SentinelTokenTexts } from "../input/special-tokens";

/** An open string: a graph is a name a family declares and an implementation registers under. */
export type ModelGraph = string;
/** A named thing the engine can do. Families declare the ones their graph needs. */
export type EngineCapability = string;
export type FidelityTier = "l1" | "l2" | "l3";

export type FidelityTarget =
  | Readonly<{ tier: "l1"; oracle: "mlx-lm"; claim: "bit-exact" }>
  | Readonly<{ tier: "l1"; oracle: "mlx-whisper"; claim: "bit-exact" }>
  | Readonly<{ tier: "l2"; oracle: "mlx-optiq"; claim: "bit-exact" }>
  | Readonly<{ tier: "l3"; oracle: null; claim: "measured" }>;

export type ModelLoader = "safetensors" | "colibri";
export type GenerationLoop = "autoregressive" | "diffusion" | "encoder-decoder";
export type ModelSpecialization = "artifact" | "dedicated" | "generated" | "generic";

export const L1: FidelityTarget = Object.freeze({ tier: "l1", oracle: "mlx-lm", claim: "bit-exact" });
/** L1 for speech: the capability's own reference implementation (mlx-whisper)
 * plays the mlx-lm role; no mlx-lm arm exists for Whisper. */
export const L1_WHISPER: FidelityTarget = Object.freeze({ tier: "l1", oracle: "mlx-whisper", claim: "bit-exact" });
export const L2: FidelityTarget = Object.freeze({ tier: "l2", oracle: "mlx-optiq", claim: "bit-exact" });
export const L3: FidelityTarget = Object.freeze({ tier: "l3", oracle: null, claim: "measured" });

/** Fine-tuning defaults a graph may declare. The CLI reads these from the
 * resolved profile; nothing outside the model decides them by name. */
export interface TrainingDefaults {
  /** Default maximum training sequence length in tokens. */
  readonly maxSeqLength: number;
}

/** Applies to every graph that declares nothing of its own. */
export const GENERIC_TRAINING_DEFAULTS: TrainingDefaults = Object.freeze({ maxSeqLength: 4096 });

/** Request defaults a graph declares for chat generation. The server applies
 * them under explicit request and server settings; nothing outside the model
 * decides them by name. */
export interface GenerationDefaults {
  /** `enable_thinking` when neither the request nor the server chose; absent leaves the template's own default. */
  readonly enableThinking?: boolean;
  /** Upper bound on the configured sampling temperature for replies with thinking off
   * (model authors publish one think-mode temperature and recommend a cooler one for direct replies). */
  readonly noThinkTemperatureCap: number;
}

/** Applies to every graph that declares nothing of its own. */
export const GENERIC_GENERATION_DEFAULTS: GenerationDefaults = Object.freeze({ noThinkTemperatureCap: 0.7 });

/** How a graph's pooled text embedding is formed from tokenized input. */
export interface EmbeddingDeclaration {
  /** Special token appended to every input; its final hidden state is the vector. */
  readonly terminator: string;
}

/** The experts a sparse graph routes each token through. */
export interface MoeDeclaration {
  readonly experts: number;
  readonly topK: number;
}

/** A MoE family whose config spells its experts with the shared text fields. */
export function configuredMoe(config: ModelConfig): MoeDeclaration | null {
  const text = config.text;
  return text.enableMoeBlock && text.numExperts > 0 ? { experts: text.numExperts, topK: text.topKExperts } : null;
}

export interface ModelFamily {
  /** The graph this family runs: what profiles select, what an implementation
   * registers under, and the key of every declaration below. */
  readonly graph: ModelGraph;
  /** The one structural rule: does this family's graph run this parsed config?
   * May throw for a config too malformed to read (the generic parser does). */
  accepts(config: ModelConfig): boolean;
  /** Whether a bare `model_type` (a registry record, no config read) is this
   * family's. False where the rule needs more than the type: MiniCPM5 shares
   * `llama` and is told apart only by its dimensions. */
  hasModelType(modelType: string): boolean;
  /** `targeted`: a dedicated forward with its own oracle path. `generic`: the
   * universal module (L1 only). */
  readonly tier: "targeted" | "generic";
  /** Names a targeted family in the unsupported-model message. */
  readonly label?: string;
  readonly loader: ModelLoader;
  readonly loop: GenerationLoop;
  readonly fidelity: FidelityTarget;
  /** `dedicated` for a graph written for the family, `generic` for the universal one. */
  readonly specialization: "dedicated" | "generic";
  /** The family profile's id. */
  readonly profileId: string;
  /** Capabilities the graph needs of the engine, beyond its loader and loop's own. */
  readonly capabilities: readonly EngineCapability[];
  /** Configs whose fingerprint is listed here run a graph generated from them (`profileId` names that profile). */
  readonly generated?: { readonly profileId: string; readonly fingerprints: readonly string[] };
  /** A speech-to-text family, served by the transcription engine. */
  readonly transcribes?: true;
  readonly moe?: (config: ModelConfig) => MoeDeclaration | null;
  readonly trainingDefaults?: TrainingDefaults;
  /** Present when the graph declares `GraphCapabilities.embeddings`. */
  readonly embedding?: EmbeddingDeclaration;
  /** Present when generated text delimits tool calls and reasoning with special tokens. */
  readonly sentinels?: SentinelTokenTexts;
  /** Soft-token markers of the graph's tower prompts. */
  readonly mediaTokens?: MediaTokenTexts;
  readonly generationDefaults?: GenerationDefaults;
  /** Renders chats for artifacts that ship no template of their own. */
  readonly chatTemplateFallback?: TemplateFallback;
}

/** Declare a family: typed against the record, frozen. */
export function defineFamily(family: ModelFamily): ModelFamily {
  return Object.freeze(family);
}
