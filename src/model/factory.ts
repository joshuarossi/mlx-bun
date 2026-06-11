// Model construction with generated-specialization dispatch
// (optimization_plan.md Phase C): pick the generated class whose config
// fingerprint matches, else the monolith. Generated classes subclass
// Gemma4Model and only override forwardLayers (with their own
// cache-signature guard), so the choice is always safe.

import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { Gemma4Model } from "./gemma4";
import { configFingerprint } from "./fingerprint";
import { GENERATED } from "./generated";

export function createModel(weights: Weights, config: ModelConfig): Gemma4Model {
  const cls = GENERATED.get(configFingerprint(config)) ?? Gemma4Model;
  return new cls(weights, config);
}
