// Draft-selection policy for the speculative engine.
//
// Verification is exact token match: at each window position the TARGET
// samples its own token with the step key (seed, step), independent of the
// draft, and the draft is accepted only when equal. Draft policy therefore
// cannot change the output distribution, only acceptance and draft cost.
// It is NOT output-neutral trajectory by trajectory: a token's bf16 logits
// depend on which row of the verify window computed it, so a different
// acceptance pattern re-rolls some seeded trajectories. Compare draft-side
// arms by ms per round and tokens per round; compare tok/s only on items whose
// outputs are byte-identical.
//
// The default draft uses the request sampler with the SAME step key as the
// target position it predicts. MLX's categorical over a [1, V] input draws by
// INVERSE CDF in token-id order from ONE uniform of that key (see
// draft-vocab.ts), so draft and target read the same point of their own CDFs:
// a coupled draw whose match rate is far above independent sampling. Every
// knob here keeps that key; each is default off and needs a paired microbench
// win before any default (flag-and-try-both).
import { runtimeFlag, runtimeValue } from "../../runtime/config";
import type { SamplerOptions } from "../../sampling/index";

/** Argmax drafts (`MLX_BUN_SPEC_GREEDY_DRAFT=1`). Drops the key coupling. */
export function greedyDraftPolicy(): boolean {
  return runtimeFlag("MLX_BUN_SPEC_GREEDY_DRAFT", false);
}

/** Sampler options for the DRAFT of a request.
 *  `MLX_BUN_SPEC_DRAFT_TEMPERATURE=<t>` samples the draft at its own
 *  temperature: a head flatter than its target matches more often when
 *  sharpened (t < request temperature); t=0 is argmax.
 *  `MLX_BUN_SPEC_DRAFT_FILTER=0` drops top-p/top-k/min-p/XTC from the draft:
 *  the coupled inverse-CDF draw over the full vocabulary, a quarter of the
 *  per-step sampling cost, which at low temperature rarely leaves the
 *  filtered set. */
export function draftSamplerOptions<T extends SamplerOptions>(options: T): T {
  if (greedyDraftPolicy()) return { ...options, temperature: 0 };
  let next = options;
  const temperature = runtimeValue("MLX_BUN_SPEC_DRAFT_TEMPERATURE");
  if (temperature !== undefined && Number.isFinite(Number(temperature)) && Number(temperature) >= 0)
    next = { ...next, temperature: Number(temperature) };
  if (!runtimeFlag("MLX_BUN_SPEC_DRAFT_FILTER", true))
    next = { ...next, topP: 0, topK: 0, minP: 0, xtcProbability: 0 };
  return next;
}
