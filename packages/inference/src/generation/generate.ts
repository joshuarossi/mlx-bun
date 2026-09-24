// Streaming generation — port of mlx-lm's generate_step:
// - prefill in chunks; cache state evaluated per chunk (bounded transient
//   memory), logits never computed for non-final prefill positions
// - decode pipelining via mx.async_eval: step n+1's graph is built and
//   dispatched before step n's token is read back, so the GPU never idles
//   on the JS round-trip
// - opt-in early token-zero yield reduces latency before that pipeline starts
// - sampling stays on-device; only the chosen token id crosses to JS

import {
bindLegacyAutoregressiveModel
} from "../execution/autoregressive";
import { bindLegacyDenoisingModel } from "../execution/denoising";
import { DiffusionGemmaModel } from "../models/diffusion-gemma/model";
import type { RuntimeModel } from "../models/factory";
import { generateAutoregressive } from './autoregressive';
import { generateDenoising } from './denoising';
import { Generation } from './result';
import { GenerateDiagnostics,GenerateOptions } from './types';

export function generate(
  model: RuntimeModel,
  promptTokens: number[],
  options: GenerateOptions = {},
  diagnostics: GenerateDiagnostics = {},
): Generation {
  return bindGeneration(model)(promptTokens, options, diagnostics);
}

/** Resolve the compatibility model once at host construction. Every request
 * borrows the same binding and immutable runtime snapshot. */
export function bindGeneration(model: RuntimeModel): (
  promptTokens: number[], options?: GenerateOptions, diagnostics?: GenerateDiagnostics,
) => Generation {
  // DiffusionGemma is non-autoregressive: route to the denoising engine instead
  // of the AR decode loop. Same Generation/GenerateStats contract so the CLI and
  // server stream it through the existing token machinery.
  if (!(model instanceof DiffusionGemmaModel)) {
    const binding = bindLegacyAutoregressiveModel(model);
    return (prompt, options, diagnostics) => generateAutoregressive(binding, prompt, options, diagnostics);
  }
  const binding = bindLegacyDenoisingModel(model);
  return (prompt, options) => generateDenoising(binding, prompt, options);
}
