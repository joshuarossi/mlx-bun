// Manifest for the universal (Tier-0 generic) parity gate
// (docs/design/generic-model-support.md §3.5): one entry per launch arch,
// each pointing at the SMALLEST mlx-community 4-bit checkpoint of that
// arch. An arch is "supported (generic)" only when its entry is green on
// the current machine — no entry, no support claim.
//
// Downloads are a USER action (ground rules — never fetched from a
// session):   hf download <repo>
// then regen goldens on THIS machine:
//   bun scripts/regen-universal-goldens.ts [<prefix>|all]
// and run the gate:
//   MLX_BUN_TEST_UNIVERSAL=1 bun test tests/universal-parity.test.ts

import { hfSnapshot } from "./paths";

export interface UniversalManifestEntry {
  /** Golden-file prefix (`<prefix>-parity.json`, `<prefix>-logits-step*.bin`). */
  prefix: string;
  /** model_type in the checkpoint's config.json (pre-remap). */
  modelType: string;
  /** HF repo id (mlx-community small 4-bit). */
  repoId: string;
  /** Resolved local snapshot path (skip-if-absent). */
  snapshot: string;
  /** Which class createModel should hand back — "universal", or the name
   *  of the dedicated class when a targeted port shadows the descriptor
   *  (generic never shadows targeted; the gate still runs the oracle bar). */
  expectClass: "universal" | "dedicated";
  /** What this entry uniquely exercises (documentation). */
  covers: string;
}

const entry = (
  prefix: string, modelType: string, repoId: string, covers: string,
  expectClass: UniversalManifestEntry["expectClass"] = "universal",
): UniversalManifestEntry => ({
  prefix,
  modelType,
  repoId,
  snapshot: hfSnapshot(`models--${repoId.replace("/", "--")}`),
  expectClass,
  covers,
});

export const UNIVERSAL_MANIFEST: UniversalManifestEntry[] = [
  entry("uni-llama32-1b", "llama", "mlx-community/Llama-3.2-1B-Instruct-4bit",
    "llama block, llama3 rope scaling, tied embeddings"),
  entry("uni-qwen25-05b", "qwen2", "mlx-community/Qwen2.5-0.5B-Instruct-4bit",
    "qwen2: additive q/k/v bias, theta 1e6, tied"),
  entry("uni-qwen3-06b", "qwen3", "mlx-community/Qwen3-0.6B-4bit",
    "qwen3: per-head q/k RMSNorm (dedicated Qwen3Model shadows the descriptor)",
    "dedicated"),
  entry("uni-gemma-2b", "gemma", "mlx-community/quantized-gemma-2b-it",
    "gemma-1: (1+w) RMSNorm, √hidden embed scale, PRECISE-gelu MLP, always tied"),
  entry("uni-gemma2-2b", "gemma2", "mlx-community/gemma-2-2b-it-4bit",
    "gemma2: attention-score softcap (manual attn), sandwich norms, final softcap, array mask"),
  entry("uni-phi35-mini", "phi3", "mlx-community/Phi-3.5-mini-instruct-4bit",
    "phi3: fused qkv/gate_up (activation split), longrope (SuScaledRoPE)"),
  // mlx-community ships no OLMo-2 smaller than 7B; this 1B is an MLX-format
  // community conversion (verified mlx-tagged). Official alternative:
  // mlx-community/OLMo-2-1124-7B-Instruct-4bit (~4 GB).
  entry("uni-olmo2-1b", "olmo2", "ekryski/OLMo-2-0425-1B-Instruct-4bit",
    "olmo2: POST-norm block, full-width q/k norm"),
  entry("uni-glm4-9b", "glm4", "mlx-community/GLM-4-9B-0414-4bit",
    "glm4: partial rope (traditional), post_self_attn/post_mlp norms, fused gate_up, untied"),
  entry("uni-granite-2b", "granite", "mlx-community/granite-3.3-2b-instruct-4bit",
    "granite: attention/embedding/residual multipliers, logits_scaling"),
  entry("uni-starcoder2-3b", "starcoder2", "mlx-community/starcoder2-3b-4bit",
    "starcoder2: LayerNorm(+bias), all-bias projections, plain c_fc/c_proj gelu MLP"),
  entry("uni-smollm3-3b", "smollm3", "mlx-community/SmolLM3-3B-4bit",
    "smollm3: llama + NoPE layers (no_rope_layer_interval)"),
];
