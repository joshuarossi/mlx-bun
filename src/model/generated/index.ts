// Registry of generated per-architecture specializations (hand-kept;
// the files themselves come from scripts/gen-model.ts). Dispatch is by
// config fingerprint; anything unregistered runs the monolith.

import type { Weights } from "../../weights";
import type { ModelConfig } from "../../config";
import { Gemma4Model } from "../gemma4";
import * as g12b from "./gemma4-12b";
import * as ge4b from "./gemma4-e4b";
import * as g26b from "./gemma4-26b";

type ModelCtor = new (weights: Weights, config: ModelConfig) => Gemma4Model;

export const GENERATED = new Map<string, ModelCtor>([
  [g12b.FINGERPRINT, g12b.GeneratedGemma4],
  [ge4b.FINGERPRINT, ge4b.GeneratedGemma4],
  [g26b.FINGERPRINT, g26b.GeneratedGemma4],
]);
