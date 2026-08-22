import type { ModelConfig } from "../config";
import { configFingerprint } from "./fingerprint";
import {
  isDiffusionGemmaConfig,
  isGlm52Config,
  isMiniCPM5Config,
  isQwen35Config,
  isQwen3Config,
  isQwen3MoeConfig,
} from "./support";
import { GENERATED } from "./generated";
import { GENERIC_MODEL_TYPES, genericArgsFor, remapModelType } from "./universal/archs";

export const ENGINE_CAPABILITIES = Object.freeze([
  "autoregressive",
  "colibri-container",
  "diffusion",
  "diffusion-gemma-graph",
  "gemma4-graph",
  "generated-graph",
  "glm5.2-graph",
  "minicpm5-graph",
  "mixed-precision-kv",
  "native-mtp",
  "qwen3-graph",
  "qwen3-moe-graph",
  "qwen3.5-graph",
  "recurrent-state",
  "safetensors",
  "streamed-experts",
  "universal-dense-graph",
  "vision-sidecar",
] as const);

export type EngineCapability = typeof ENGINE_CAPABILITIES[number];
export type FidelityTier = "l1" | "l2" | "l3";

export type FidelityTarget =
  | Readonly<{ tier: "l1"; oracle: "mlx-lm"; claim: "bit-exact" }>
  | Readonly<{ tier: "l2"; oracle: "mlx-optiq"; claim: "bit-exact" }>
  | Readonly<{ tier: "l3"; oracle: null; claim: "measured" }>;

export type ModelLoader = "safetensors" | "colibri";
export type ModelGraph =
  | "gemma4"
  | "minicpm5"
  | "qwen3.5"
  | "qwen3"
  | "qwen3-moe"
  | "diffusion-gemma"
  | "glm5.2"
  | "universal-dense";
export type GenerationLoop = "autoregressive" | "diffusion";
export type ModelSpecialization = "artifact" | "dedicated" | "generated" | "generic";

export interface ModelExecutionComposition {
  readonly loader: ModelLoader;
  readonly graph: ModelGraph;
  readonly loop: GenerationLoop;
  readonly specialization: ModelSpecialization;
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

const L1: FidelityTarget = Object.freeze({
  tier: "l1", oracle: "mlx-lm", claim: "bit-exact",
});
const L2: FidelityTarget = Object.freeze({
  tier: "l2", oracle: "mlx-optiq", claim: "bit-exact",
});
const L3: FidelityTarget = Object.freeze({
  tier: "l3", oracle: null, claim: "measured",
});

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

const FAMILY_PROFILES = {
  gemma4Generated: freezeProfile({
    id: "gemma4-generated",
    fidelity: L1,
    requiredCapabilities: ["safetensors", "autoregressive", "gemma4-graph", "generated-graph"],
    execution: {
      loader: "safetensors", graph: "gemma4", loop: "autoregressive", specialization: "generated",
    },
  }),
  gemma4: freezeProfile({
    id: "gemma4-dedicated",
    fidelity: L1,
    requiredCapabilities: ["safetensors", "autoregressive", "gemma4-graph"],
    execution: {
      loader: "safetensors", graph: "gemma4", loop: "autoregressive", specialization: "dedicated",
    },
  }),
  minicpm5: freezeProfile({
    id: "minicpm5-dedicated",
    fidelity: L1,
    requiredCapabilities: ["safetensors", "autoregressive", "minicpm5-graph"],
    execution: {
      loader: "safetensors", graph: "minicpm5", loop: "autoregressive", specialization: "dedicated",
    },
  }),
  qwen35: freezeProfile({
    id: "qwen3.5-dedicated",
    fidelity: L1,
    requiredCapabilities: ["safetensors", "autoregressive", "qwen3.5-graph", "recurrent-state"],
    execution: {
      loader: "safetensors", graph: "qwen3.5", loop: "autoregressive", specialization: "dedicated",
    },
  }),
  qwen3: freezeProfile({
    id: "qwen3-dedicated",
    fidelity: L1,
    requiredCapabilities: ["safetensors", "autoregressive", "qwen3-graph"],
    execution: {
      loader: "safetensors", graph: "qwen3", loop: "autoregressive", specialization: "dedicated",
    },
  }),
  qwen3Moe: freezeProfile({
    id: "qwen3-moe-dedicated",
    fidelity: L1,
    requiredCapabilities: ["safetensors", "autoregressive", "qwen3-moe-graph"],
    execution: {
      loader: "safetensors", graph: "qwen3-moe", loop: "autoregressive", specialization: "dedicated",
    },
  }),
  diffusionGemma: freezeProfile({
    id: "diffusion-gemma-dedicated",
    fidelity: L2,
    requiredCapabilities: ["safetensors", "diffusion", "diffusion-gemma-graph"],
    execution: {
      loader: "safetensors", graph: "diffusion-gemma", loop: "diffusion", specialization: "dedicated",
    },
  }),
  glm52: freezeProfile({
    id: "glm5.2-colibri",
    fidelity: L3,
    requiredCapabilities: ["colibri-container", "autoregressive", "glm5.2-graph", "streamed-experts"],
    execution: {
      loader: "colibri", graph: "glm5.2", loop: "autoregressive", specialization: "dedicated",
    },
  }),
  universal: freezeProfile({
    id: "universal-dense",
    fidelity: L1,
    requiredCapabilities: ["safetensors", "autoregressive", "universal-dense-graph"],
    execution: {
      loader: "safetensors", graph: "universal-dense", loop: "autoregressive", specialization: "generic",
    },
  }),
} satisfies Record<string, ModelProfile>;

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

function familyProfile(config: ModelConfig, fingerprint: string): ModelProfile {
  if (isGlm52Config(config)) return FAMILY_PROFILES.glm52;
  if (isDiffusionGemmaConfig(config)) return FAMILY_PROFILES.diffusionGemma;
  if (isMiniCPM5Config(config)) return FAMILY_PROFILES.minicpm5;
  if (isQwen35Config(config)) return FAMILY_PROFILES.qwen35;
  if (isQwen3MoeConfig(config)) return FAMILY_PROFILES.qwen3Moe;
  if (isQwen3Config(config)) return FAMILY_PROFILES.qwen3;
  if (config.modelType.startsWith("gemma4"))
    return GENERATED.has(fingerprint) ? FAMILY_PROFILES.gemma4Generated : FAMILY_PROFILES.gemma4;
  if (genericArgsFor(config)) return FAMILY_PROFILES.universal;

  const arch = remapModelType(config.modelType);
  throw new Error(
    `unsupported model_type "${config.modelType}"` +
    (arch !== config.modelType ? ` (mlx-lm remaps it to "${arch}")` : "") +
    ` — targeted: gemma4*, diffusion_gemma, glm_moe_dsa, qwen3_5, qwen3, qwen3_moe, MiniCPM5;` +
    ` generic (Tier-0): ${[...GENERIC_MODEL_TYPES].sort().join(", ")}`,
  );
}

interface GraphMetadata {
  readonly accepts: (config: ModelConfig) => boolean;
  readonly capabilities: readonly EngineCapability[];
}

const GRAPH_METADATA: Readonly<Record<ModelGraph, GraphMetadata>> = Object.freeze({
  "gemma4": {
    accepts: (config) => config.modelType.startsWith("gemma4"),
    capabilities: ["gemma4-graph"],
  },
  "minicpm5": { accepts: isMiniCPM5Config, capabilities: ["minicpm5-graph"] },
  "qwen3.5": {
    accepts: isQwen35Config,
    capabilities: ["qwen3.5-graph", "recurrent-state"],
  },
  "qwen3": { accepts: isQwen3Config, capabilities: ["qwen3-graph"] },
  "qwen3-moe": { accepts: isQwen3MoeConfig, capabilities: ["qwen3-moe-graph"] },
  "diffusion-gemma": {
    accepts: isDiffusionGemmaConfig,
    capabilities: ["diffusion-gemma-graph"],
  },
  "glm5.2": {
    accepts: isGlm52Config,
    capabilities: ["glm5.2-graph", "streamed-experts"],
  },
  "universal-dense": {
    accepts: (config) => {
      try { return genericArgsFor(config) !== null; } catch { return false; }
    },
    capabilities: ["universal-dense-graph"],
  },
});

function graphAccepts(profile: ModelProfile, config: ModelConfig): boolean {
  return GRAPH_METADATA[profile.execution.graph].accepts(config);
}

function executionCapabilities(profile: ModelProfile): EngineCapability[] {
  const required: EngineCapability[] = [profile.execution.loader === "colibri"
    ? "colibri-container"
    : "safetensors"];
  if (profile.execution.loop === "diffusion") required.push("diffusion");
  else required.push("autoregressive");
  required.push(...GRAPH_METADATA[profile.execution.graph].capabilities);
  if (profile.execution.specialization === "generated") required.push("generated-graph");
  return required;
}

function validateProfile(profile: ModelProfile): void {
  if (!profile.id) throw new Error("model profile id must not be empty");
  if ((profile.artifactFingerprint === undefined) !== (profile.configFingerprint === undefined))
    throw new Error(
      `model profile ${profile.id} must declare artifactFingerprint and configFingerprint together`,
    );
  const fidelityOk =
    (profile.fidelity.tier === "l1" && profile.fidelity.oracle === "mlx-lm" &&
      profile.fidelity.claim === "bit-exact") ||
    (profile.fidelity.tier === "l2" && profile.fidelity.oracle === "mlx-optiq" &&
      profile.fidelity.claim === "bit-exact") ||
    (profile.fidelity.tier === "l3" && profile.fidelity.oracle === null &&
      profile.fidelity.claim === "measured");
  if (!fidelityOk) throw new Error(`model profile ${profile.id} has an invalid fidelity contract`);
  const expectedLoader = profile.execution.graph === "glm5.2" ? "colibri" : "safetensors";
  const expectedLoop = profile.execution.graph === "diffusion-gemma"
    ? "diffusion"
    : "autoregressive";
  if (profile.execution.loader !== expectedLoader || profile.execution.loop !== expectedLoop)
    throw new Error(
      `model profile ${profile.id} has an invalid execution composition for ` +
      `${profile.execution.graph}`,
    );
  const declared = new Set(profile.requiredCapabilities);
  const underdeclared = executionCapabilities(profile).filter((capability) => !declared.has(capability));
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
  profile ??= familyProfile(config, fingerprint);
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
  if (resolved.exactArtifact &&
      resolved.profile.artifactFingerprint !== resolved.artifact.fingerprint)
    throw new Error(
      `model profile ${resolved.profile.id} does not match artifact ` +
      `${resolved.artifact.fingerprint ?? "<unidentified>"}`,
    );
}
