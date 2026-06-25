// DiffusionGemma D2 (denoising engine) token-for-token parity (OPT-IN slow tier).
// Same global seed + confidence-threshold sampler at temperature 0 as the optiq
// golden → identical canvas draws (ops.randint threads the global mlx key) →
// identical denoising trajectory → identical emitted tokens.
//
//   MLX_BUN_TEST_DIFFUSION=1 bun test tests/diffusion-gen-parity.test.ts
//
// Regen golden first:
//   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-diffusion-gen-golden.py

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { DiffusionGemmaModel } from "../src/model/diffusion-gemma";
import { diffusionGenerate } from "../src/diffusion/diffusion-generate";
import { Weights } from "../src/weights";
import { SNAPSHOT_DIFFUSION, snapshotDiffusionAvailable } from "./paths";

const optIn = process.env.MLX_BUN_TEST_DIFFUSION === "1";
const haveWeights = await snapshotDiffusionAvailable();

interface Gen {
  prompt_ids: number[];
  max_tokens: number;
  threshold: number;
  t_min: number;
  t_max: number;
  max_denoising_steps: number;
  entropy_bound: number;
  stability_threshold: number;
  confidence_threshold: number;
  eos_token_id: number[];
  tokens: number[];
  total_steps: number;
  finish_reason: string;
}

function runCase(label: string, goldenFile: string, sampler: "confidence-threshold" | "entropy-bound"): void {
  const skip = !optIn || !haveWeights || !existsSync(goldenFile);
  describe.skipIf(skip)(`DiffusionGemma D2 generation parity — ${label} (vs mlx-optiq)`, () => {
    test("matches the optiq engine token-for-token @ temp0", async () => {
      const g = (await Bun.file(goldenFile).json()) as Gen;
      const config = await loadModelConfig(SNAPSHOT_DIFFUSION);
      const model = new DiffusionGemmaModel(await Weights.open(SNAPSHOT_DIFFUSION), config);

      const out = diffusionGenerate(model, g.prompt_ids, {
        maxTokens: g.max_tokens,
        maxDenoisingSteps: g.max_denoising_steps,
        sampler,
        threshold: g.threshold,
        entropyBound: g.entropy_bound,
        temperature: 0,
        tMin: g.t_min,
        tMax: g.t_max,
        // No stable-stop config: the shipped checkpoint loads
        // generation_config=None in optiq, so the oracle never stops here.
        eosTokenIds: g.eos_token_id, // [1, 106] (tokenizer stopping set)
        seed: 0n,
      });

      // eslint-disable-next-line no-console
      console.log(
        `[diffusion D2 ${label}] ours ${out.tokens.length} tok / ${out.steps} steps (${out.finishReason}) · ` +
          `ref ${g.tokens.length} tok / ${g.total_steps} steps (${g.finish_reason})`,
      );

      expect(out.steps).toBe(g.total_steps);
      expect(out.tokens).toEqual(g.tokens);
      expect(out.finishReason).toBe(g.finish_reason as "stop" | "length");
    }, 600_000);
  });
}

runCase("confidence-threshold", "goldens/diffusion/gen.json", "confidence-threshold");
runCase("entropy-bound", "goldens/diffusion/gen-entropy.json", "entropy-bound");
