// Model construction with generated-specialization dispatch
// (docs/design/optimization_plan.md Phase C): pick the generated class whose config
// fingerprint matches, else the monolith. Generated classes subclass
// Gemma4Model and only override forwardLayers (with their own
// cache-signature guard), so the choice is always safe.

import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { Gemma4Model } from "./gemma4";
import { configFingerprint } from "./fingerprint";
import { GENERATED } from "./generated";
import { MiniCPM5Model } from "./minicpm5";
import { Qwen35Model } from "./qwen3_5";
import { DiffusionGemmaModel } from "./diffusion-gemma";
import { isDiffusionGemmaConfig, isMiniCPM5Config, isQwen35Config } from "./support";

export type RuntimeModel = Gemma4Model | MiniCPM5Model | Qwen35Model | DiffusionGemmaModel;

export function createModel(weights: Weights, config: ModelConfig): RuntimeModel {
  // DiffusionGemma is non-autoregressive — generate() detects it and routes to
  // the denoising engine instead of the AR decode loop. It exposes the shared
  // RuntimeModel surface (config/weightsBytes/loraState/makeCache) with the
  // AR-only methods as throwing stubs (never called on this model).
  if (isDiffusionGemmaConfig(config)) return new DiffusionGemmaModel(weights, config);
  if (isMiniCPM5Config(config)) return new MiniCPM5Model(weights, config);
  if (isQwen35Config(config)) return new Qwen35Model(weights, config);
  if (config.modelType === "llama")
    throw new Error("unsupported llama config: only MiniCPM5-1B-OptiQ-4bit is wired");
  if (config.modelType.startsWith("qwen3_5"))
    throw new Error(`unsupported qwen3_5 config (MoE variants are deferred)`);
  const cls = GENERATED.get(configFingerprint(config)) ?? Gemma4Model;
  return new cls(weights, config);
}
