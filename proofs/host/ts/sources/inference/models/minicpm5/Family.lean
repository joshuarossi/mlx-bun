import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Minicpm5.Family
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/minicpm5/family.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { GENERIC_GENERATION_DEFAULTS, L1, defineFamily } from "../family";

/** MiniCPM5 ships as `llama`; its dimensions are what tell it from a plain
 * Llama, so a listing that has only the `model_type` cannot name it. */
export const MINICPM5_FAMILY = defineFamily({
  graph: "minicpm5",
  accepts: config => {
    const t = config.text;
    return config.modelType === "llama" &&
      t.hiddenSize === 1536 &&
      t.numHiddenLayers === 24 &&
      t.numAttentionHeads === 16 &&
      t.numKeyValueHeads === 2 &&
      t.headDim === 128 &&
      t.vocabSize === 130560 &&
      t.tieWordEmbeddings === false;
  },
  hasModelType: () => false,
  tier: "targeted",
  label: "MiniCPM5",
  loader: "safetensors",
  loop: "autoregressive",
  fidelity: L1,
  specialization: "dedicated",
  profileId: "minicpm5-dedicated",
  capabilities: ["minicpm5-graph"],
  // The model card recommends direct replies unless thinking is asked for.
  generationDefaults: { ...GENERIC_GENERATION_DEFAULTS, enableThinking: false },
});
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Minicpm5.Family
