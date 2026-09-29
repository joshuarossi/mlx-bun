// The model-family registry: every family the engine serves, in one list. A new
// model is one record here plus its graph and its native implementation
// (`factory.ts`). Everything else that used to restate a family (support tiers,
// profiles, engine capabilities, declarations) is derived from this list.

import type { ModelConfig } from "../artifacts/config";
import { DIFFUSION_GEMMA_FAMILY } from "./diffusion-gemma/family";
import type { EngineCapability, ModelFamily, ModelGraph } from "./family";
import { GEMMA4_FAMILY } from "./gemma4/family";
import { GLM52_FAMILY } from "./glm52/family";
import { MINICPM5_FAMILY } from "./minicpm5/family";
import { QWEN35_FAMILY, QWEN3_FAMILY, QWEN3_MOE_FAMILY } from "./qwen/families";
import { GENERIC_MODEL_TYPES, remapModelType } from "./universal/archs";
import { UNIVERSAL_FAMILY } from "./universal/family";
import { WHISPER_FAMILY } from "./whisper/family";

/** First match wins. Targeted families accept disjoint configs; the universal
 * family comes last so it never shadows one. */
export const MODEL_FAMILIES: readonly ModelFamily[] = Object.freeze([
  GEMMA4_FAMILY,
  DIFFUSION_GEMMA_FAMILY,
  GLM52_FAMILY,
  QWEN35_FAMILY,
  QWEN3_FAMILY,
  QWEN3_MOE_FAMILY,
  WHISPER_FAMILY,
  MINICPM5_FAMILY,
  UNIVERSAL_FAMILY,
]);

{
  const graphs = MODEL_FAMILIES.map(family => family.graph);
  const duplicate = graphs.find((graph, index) => graphs.indexOf(graph) !== index);
  if (duplicate) throw new Error(`model families: duplicate graph ${duplicate}`);
}

/** The family whose graph runs this config, or null. Throws where the family's
 * own parser rejects a malformed config. */
export function familyOf(config: ModelConfig): ModelFamily | null {
  return MODEL_FAMILIES.find(family => family.accepts(config)) ?? null;
}

/** The family a registry record's `model_type` names before any config is read. */
export function familyOfModelType(modelType: string): ModelFamily | null {
  if (typeof modelType !== "string") return null; // a record with no model_type names no family
  return MODEL_FAMILIES.find(family => family.hasModelType(modelType)) ?? null;
}

export function familyForGraph(graph: ModelGraph): ModelFamily | null {
  return MODEL_FAMILIES.find(family => family.graph === graph) ?? null;
}

/** What the engine can do independent of any model. */
const BASE_CAPABILITIES = [
  "autoregressive", "colibri-container", "diffusion", "encoder-decoder", "generated-graph",
  "mixed-precision-kv", "native-mtp", "safetensors", "vision-sidecar",
] as const satisfies readonly EngineCapability[];

/** The base capabilities plus what every registered family's graph brings. */
export const ENGINE_CAPABILITIES: readonly EngineCapability[] = Object.freeze(
  [...new Set([...BASE_CAPABILITIES, ...MODEL_FAMILIES.flatMap(family => family.capabilities)])].sort());

/** Why no family serves this config, naming what is served. */
export function unsupportedModelMessage(config: ModelConfig): string {
  const arch = remapModelType(config.modelType);
  return `unsupported model_type "${config.modelType}"` +
    (arch !== config.modelType ? ` (mlx-lm remaps it to "${arch}")` : "") +
    ` — targeted: ${MODEL_FAMILIES.flatMap(family => family.label ?? []).join(", ")};` +
    ` generic (Tier-0): ${[...GENERIC_MODEL_TYPES].sort().join(", ")}`;
}
