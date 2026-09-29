import type { ModelConfig } from "../artifacts/config";
import { configFingerprint } from "../artifacts/fingerprint";
import type { TemplateFallback } from "../input/chat-template";
import type { MediaTokenTexts, SentinelTokenTexts } from "../input/special-tokens";
import { ENGINE_CAPABILITIES, MODEL_FAMILIES, familyForGraph, familyOf, unsupportedModelMessage } from "./families";
import {
  GENERIC_GENERATION_DEFAULTS,
  GENERIC_TRAINING_DEFAULTS,
  L1,
  L3,
  type EmbeddingDeclaration,
  type EngineCapability,
  type FidelityTarget,
  type GenerationDefaults,
  type GenerationLoop,
  type ModelFamily,
  type ModelGraph,
  type ModelLoader,
  type ModelSpecialization,
  type TrainingDefaults,
} from "./family";
import { GENERATED_GEMMA_FINGERPRINTS } from "./gemma4/family";

export { ENGINE_CAPABILITIES, GENERATED_GEMMA_FINGERPRINTS, GENERIC_GENERATION_DEFAULTS, GENERIC_TRAINING_DEFAULTS };
export type {
  EmbeddingDeclaration, EngineCapability, FidelityTarget, FidelityTier, GenerationDefaults, GenerationLoop, ModelGraph, ModelLoader,
  ModelSpecialization, TrainingDefaults,
} from "./family";

export interface ModelExecutionComposition {
  readonly loader: ModelLoader;
  readonly graph: ModelGraph;
  readonly loop: GenerationLoop;
  readonly specialization: ModelSpecialization;
  /** Engine-owned code registration. Model files never supply executable code.
   * Omit to retain the existing graph implementation. */
  readonly implementation?: string;
}

/** A profile declares construction only. Request methods such as MTP, KV
 * schemes, adapters, grammar, and sampling are resolved independently and
 * cannot be rewritten by profile selection. */
export interface ModelProfile {
  readonly id: string;
  /** Exact external identity. Family profiles omit this field. */
  readonly artifactFingerprint?: string;
  /** Structural guard for an exact artifact declaration. */
  readonly configFingerprint?: string;
  readonly fidelity: FidelityTarget;
  readonly requiredCapabilities: readonly EngineCapability[];
  readonly execution: ModelExecutionComposition;
}

export interface ArtifactModelProfile extends ModelProfile {
  readonly artifactFingerprint: string;
  readonly configFingerprint: string;
}

export interface ModelArtifactIdentity {
  readonly fingerprint: string | null;
  readonly configFingerprint: string;
}

export interface ResolvedModelProfile {
  readonly profile: ModelProfile;
  readonly artifact: ModelArtifactIdentity;
  readonly exactArtifact: boolean;
}

export interface ResolveModelProfileOptions {
  /** Explicit identity for a non-Hugging-Face artifact. The caller owns its
   * provenance; mlx-bun never mistakes a local path for a content identity. */
  readonly artifactFingerprint?: string | null;
  /** Additional exact declarations composed with the shipped profiles. */
  readonly artifactProfiles?: readonly ArtifactModelProfile[];
  readonly engineCapabilities?: readonly EngineCapability[];
}

function freezeProfile<T extends ModelProfile>(profile: T): T {
  Object.freeze(profile.fidelity);
  Object.freeze(profile.requiredCapabilities);
  Object.freeze(profile.execution);
  return Object.freeze(profile);
}

function snapshotProfile(profile: ModelProfile): ModelProfile {
  return freezeProfile({
    ...profile,
    fidelity: { ...profile.fidelity },
    requiredCapabilities: [...profile.requiredCapabilities],
    execution: { ...profile.execution },
  });
}

/** Exact artifact declarations already backed by this repository's parity or
 * measured evidence. A new revision gets the family profile until it earns a
 * declaration of its own. */
export const BUILTIN_ARTIFACT_PROFILES: readonly ArtifactModelProfile[] = Object.freeze([
  freezeProfile({
    id: "qwen3.8-27b-optiq-4bit",
    artifactFingerprint:
      "hf:mlx-community/Qwen3.8-27B-OptiQ-4bit@b04599de95d7a9bfbd7f208d347c0f10d9432a42",
    configFingerprint: "50117975cb405944",
    fidelity: L1,
    requiredCapabilities: Object.freeze([
      "safetensors", "autoregressive", "qwen3.5-graph", "recurrent-state", "vision-sidecar",
    ]),
    execution: Object.freeze({
      loader: "safetensors",
      graph: "qwen3.5",
      loop: "autoregressive",
      specialization: "artifact",
    }),
  }),
  freezeProfile({
    id: "glm5.2-colibri-int4-int8-mtp",
    artifactFingerprint:
      "hf:mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp@3cc8db99b1b13fc79325d987ba3c1c430766b3b8",
    configFingerprint: "8b49d0941e18f1b9",
    fidelity: L3,
    requiredCapabilities: Object.freeze([
      "colibri-container", "autoregressive", "glm5.2-graph", "streamed-experts",
    ]),
    execution: Object.freeze({
      loader: "colibri",
      graph: "glm5.2",
      loop: "autoregressive",
      specialization: "artifact",
    }),
  }),
]);

/** The engine capability each generation loop needs. */
const loopCapability: Readonly<Record<GenerationLoop, EngineCapability>> = {
  autoregressive: "autoregressive", diffusion: "diffusion", "encoder-decoder": "encoder-decoder",
};

/** What the engine must provide to run a composition: its loader, its loop, and its graph's own capabilities. */
function executionCapabilities(execution: ModelExecutionComposition, family: ModelFamily): EngineCapability[] {
  const required: EngineCapability[] = [execution.loader === "colibri" ? "colibri-container" : "safetensors"];
  required.push(loopCapability[execution.loop]);
  required.push(...family.capabilities);
  if (execution.specialization === "generated") required.push("generated-graph");
  return required;
}

function familyProfile(family: ModelFamily, specialization: ModelSpecialization, id: string): ModelProfile {
  const execution = { loader: family.loader, graph: family.graph, loop: family.loop, specialization };
  return freezeProfile({
    id, fidelity: family.fidelity, requiredCapabilities: executionCapabilities(execution, family), execution,
  });
}

/** Return a stable external fingerprint only when the directory is an exact HF
 * snapshot revision. Relocation does not change the identity. Arbitrary local
 * directories and mutable aliases intentionally return null. */
export function externalArtifactFingerprint(modelDir: string): string | null {
  const match = modelDir.replaceAll("\\", "/").match(
    /(?:^|\/)models--([^/]+)\/snapshots\/([0-9a-f]{40,64})(?:\/|$)/i,
  );
  if (!match) return null;
  const encodedRepo = match[1]!;
  const separator = encodedRepo.indexOf("--");
  if (separator <= 0 || separator === encodedRepo.length - 2) return null;
  const repo = `${encodedRepo.slice(0, separator)}/${encodedRepo.slice(separator + 2)}`;
  return `hf:${repo}@${match[2]!.toLowerCase()}`;
}

const FAMILY_PROFILES: ReadonlyMap<ModelGraph, { dedicated: ModelProfile; generated?: ModelProfile }> = new Map(
  MODEL_FAMILIES.map(family => [family.graph, {
    dedicated: familyProfile(family, family.specialization, family.profileId),
    ...(family.generated ? { generated: familyProfile(family, "generated", family.generated.profileId) } : {}),
  }] as const));

/** The profile the config's family declares. A family lists fingerprints of the
 * graphs generated from its configs; those get the generated profile. */
function selectFamilyProfile(config: ModelConfig, fingerprint: string): ModelProfile {
  const family = familyOf(config);
  if (!family) throw new Error(unsupportedModelMessage(config));
  const profiles = FAMILY_PROFILES.get(family.graph)!;
  return profiles.generated && family.generated!.fingerprints.includes(fingerprint) ? profiles.generated : profiles.dedicated;
}

function declaredBy(resolved: ResolvedModelProfile): ModelFamily | null {
  return familyForGraph(resolved.profile.execution.graph);
}

/** The fine-tuning defaults the resolved model's graph declares, else the
 * generic ones. */
export function trainingDefaultsFor(resolved: ResolvedModelProfile): TrainingDefaults {
  return declaredBy(resolved)?.trainingDefaults ?? GENERIC_TRAINING_DEFAULTS;
}

/** The tool-call and reasoning-channel marker tokens the resolved model's graph declares, or null. */
export function sentinelDeclarationFor(resolved: ResolvedModelProfile): SentinelTokenTexts | null {
  return declaredBy(resolved)?.sentinels ?? null;
}

/** The tower-prompt soft-token markers the resolved model's graph declares, or null. */
export function mediaTokenDeclarationFor(resolved: ResolvedModelProfile): MediaTokenTexts | null {
  return declaredBy(resolved)?.mediaTokens ?? null;
}

/** The chat-generation defaults the resolved model's graph declares, else the generic ones. */
export function generationDefaultsFor(resolved: ResolvedModelProfile): GenerationDefaults {
  return declaredBy(resolved)?.generationDefaults ?? GENERIC_GENERATION_DEFAULTS;
}

/** The renderer for artifacts that ship no chat template, or null when they must ship one. */
export function chatTemplateFallbackFor(resolved: ResolvedModelProfile): TemplateFallback | null {
  return declaredBy(resolved)?.chatTemplateFallback ?? null;
}

/** The pooled-embedding recipe the resolved model's graph declares, or null. */
export function embeddingDeclarationFor(resolved: ResolvedModelProfile): EmbeddingDeclaration | null {
  return declaredBy(resolved)?.embedding ?? null;
}

function graphAccepts(profile: ModelProfile, config: ModelConfig): boolean {
  const family = familyForGraph(profile.execution.graph);
  if (!family) return false;
  try { return family.accepts(config); } catch { return false; }
}

function validateProfile(profile: ModelProfile): void {
  if (!profile.id) throw new Error("model profile id must not be empty");
  if (profile.execution.implementation !== undefined &&
      (!profile.execution.implementation.trim() || !profile.artifactFingerprint ||
       profile.execution.specialization !== "artifact"))
    throw new Error(`model profile ${profile.id} must bind a named implementation to an exact artifact`);
  if ((profile.artifactFingerprint === undefined) !== (profile.configFingerprint === undefined))
    throw new Error(
      `model profile ${profile.id} must declare artifactFingerprint and configFingerprint together`,
    );
  const family = familyForGraph(profile.execution.graph);
  if (!family)
    throw new Error(`model profile ${profile.id} selects unknown graph ${profile.execution.graph}`);
  const fidelityOk =
    (profile.fidelity.tier === "l1" && profile.fidelity.oracle === "mlx-lm" &&
      profile.fidelity.claim === "bit-exact") ||
    (profile.fidelity.tier === "l1" && profile.fidelity.oracle === "mlx-whisper" &&
      profile.fidelity.claim === "bit-exact" && family.fidelity.oracle === "mlx-whisper") ||
    (profile.fidelity.tier === "l2" && profile.fidelity.oracle === "mlx-optiq" &&
      profile.fidelity.claim === "bit-exact") ||
    (profile.fidelity.tier === "l3" && profile.fidelity.oracle === null &&
      profile.fidelity.claim === "measured");
  if (!fidelityOk) throw new Error(`model profile ${profile.id} has an invalid fidelity contract`);
  if (profile.execution.loader !== family.loader || profile.execution.loop !== family.loop)
    throw new Error(
      `model profile ${profile.id} has an invalid execution composition for ` +
      `${profile.execution.graph}`,
    );
  const declared = new Set(profile.requiredCapabilities);
  const underdeclared = executionCapabilities(profile.execution, family).filter((capability) => !declared.has(capability));
  if (underdeclared.length)
    throw new Error(
      `model profile ${profile.id} does not declare execution capabilities: ` +
      `${underdeclared.join(", ")}`,
    );
}

export function resolveModelProfile(
  config: ModelConfig,
  options: ResolveModelProfileOptions = {},
): ResolvedModelProfile {
  const fingerprint = configFingerprint(config);
  const artifactFingerprint = options.artifactFingerprint === undefined
    ? externalArtifactFingerprint(config.modelDir)
    : options.artifactFingerprint;
  const artifactProfiles = options.artifactProfiles
    ? [...BUILTIN_ARTIFACT_PROFILES, ...options.artifactProfiles]
    : BUILTIN_ARTIFACT_PROFILES;
  const capabilities = new Set(options.engineCapabilities ?? ENGINE_CAPABILITIES);

  let profile: ModelProfile | undefined;
  let exactArtifact = false;
  if (artifactFingerprint) {
    const matches = artifactProfiles.filter((entry) => {
      validateProfile(entry);
      return entry.artifactFingerprint === artifactFingerprint;
    });
    if (matches.length > 1)
      throw new Error(`multiple model profiles declare artifact ${artifactFingerprint}`);
    profile = matches[0];
    if (profile) {
      exactArtifact = true;
      if (profile.configFingerprint !== fingerprint)
        throw new Error(
          `model profile ${profile.id} matched artifact ${artifactFingerprint}, but config fingerprint ` +
          `${fingerprint} != declared ${profile.configFingerprint}; refusing to fall back`,
        );
      if (!graphAccepts(profile, config))
        throw new Error(
          `model profile ${profile.id} selects ${profile.execution.graph}, which is incompatible with ` +
          `${config.modelType}; refusing to fall back`,
        );
    }
  }
  profile ??= selectFamilyProfile(config, fingerprint);
  validateProfile(profile);
  profile = snapshotProfile(profile);

  const missing = profile.requiredCapabilities.filter((capability) => !capabilities.has(capability));
  if (missing.length)
    throw new Error(
      `model profile ${profile.id} requires missing engine capabilities: ${missing.join(", ")}; ` +
      `refusing to fall back`,
    );

  return Object.freeze({
    profile,
    artifact: Object.freeze({ fingerprint: artifactFingerprint, configFingerprint: fingerprint }),
    exactArtifact,
  });
}

/** Guard the factory seam when a caller passes a previously resolved profile. */
export function assertResolvedModelProfile(
  config: ModelConfig,
  resolved: ResolvedModelProfile,
): void {
  validateProfile(resolved.profile);
  const fingerprint = configFingerprint(config);
  if (resolved.artifact.configFingerprint !== fingerprint)
    throw new Error(
      `model profile ${resolved.profile.id} was resolved for config ` +
      `${resolved.artifact.configFingerprint}, not ${fingerprint}`,
    );
  if (!graphAccepts(resolved.profile, config))
    throw new Error(
      `model profile ${resolved.profile.id} selects ${resolved.profile.execution.graph}, ` +
      `which is incompatible with ${config.modelType}`,
    );
  if (resolved.exactArtifact !== (resolved.profile.artifactFingerprint !== undefined) ||
      (resolved.exactArtifact &&
       (resolved.profile.artifactFingerprint !== resolved.artifact.fingerprint ||
        resolved.profile.configFingerprint !== fingerprint)))
    throw new Error(
      `model profile ${resolved.profile.id} does not match artifact ` +
      `${resolved.artifact.fingerprint ?? "<unidentified>"}`,
    );
}
