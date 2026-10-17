import { checkpointWords, literalLines } from "./checkpoint-words.ts";

/** These literals certify the alphabets used by affine tensors, not their
 * full ordered contents. Native equality to the encoded tensors remains an
 * attachment obligation. The CPU scan does not replace that Lean obligation. */
export async function checkpointAffineSource(directory: string) {
  const words = await checkpointWords(directory);
  const dictionaries = {
    projectionScales: new Set<number>(), projectionBiases: new Set<number>(),
    embeddingScales: new Set<number>(), embeddingBiases: new Set<number>(),
  };
  let tensors = 0, wordCount = 0;
  async function collect(prefix: string, shape: number[], embedding = false) {
    for (const [suffix, field] of [["scales", "Scales"], ["biases", "Biases"]] as const) {
      const payload = await words(`${prefix}.${suffix}`, "BF16", shape);
      const dictionary = dictionaries[`${embedding ? "embedding" : "projection"}${field}`];
      for (const word of payload) dictionary.add(word);
      tensors++;
      wordCount += payload.length;
    }
  }
  await collect("model.language_model.embed_tokens", [248320, 80], true);
  await collect("lm_head", [248320, 80]);
  for (let layer = 0; layer < 64; layer++) {
    const prefix = `model.language_model.layers.${layer}`;
    if (layer % 4 === 3) {
      for (const [name, rows] of [["q_proj", 12288], ["k_proj", 1024], ["v_proj", 1024]] as const) {
        await collect(`${prefix}.self_attn.${name}`, [rows, 80]);
      }
      await collect(`${prefix}.self_attn.o_proj`, [5120, 96]);
    } else {
      for (const [name, rows] of [["in_proj_qkv", 10240], ["in_proj_z", 6144], ["in_proj_a", 48], ["in_proj_b", 48]] as const) {
        await collect(`${prefix}.linear_attn.${name}`, [rows, 80]);
      }
      await collect(`${prefix}.linear_attn.out_proj`, [5120, 96]);
    }
  }
  let source = `import models.qwen.CheckpointAffine
import contracts.mlx.PackedDictionary

namespace Inference.Models.Qwen.CheckpointAffineDictionaryData
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
set_option maxRecDepth 30000
set_option maxHeartbeats 4000000

-- Exact raw-word alphabets from the selected 612 affine tensors in snapshot
-- cbb7a58a7222a19a3d02d36540c9cab5d9aadf0d. The ordered tensor indices are
-- parameters, not literals here. These universal decoding bounds do not
-- establish their attachment to native checkpoint buffers.
abbrev Encoded (rows columns : Nat) := Fin rows → Fin columns → Nat
def read (dictionary : List BF) (positive : 0 < dictionary.length)
    (encoded : Encoded rows columns) (row : Fin rows) (column : Fin columns) : BF :=
  PackedDictionary.read dictionary positive (encoded row column) 0
theorem read_bound (dictionary : List BF) (positive : 0 < dictionary.length)
    (cap : BF) (checked : TensorWords.check dictionary cap = true)
    (encoded : Encoded rows columns) (row : Fin rows) (column : Fin columns) :
    Model.isFinite (read dictionary positive encoded row column) = true ∧
      |Model.toReal (read dictionary positive encoded row column)| ≤ Model.toReal cap :=
  PackedDictionary.read_bound dictionary positive cap checked (encoded row column) 0

theorem read_index (dictionary : List BF) (positive : 0 < dictionary.length) (index : Fin dictionary.length) :
    PackedDictionary.read dictionary positive index.val 0 = dictionary[index] := by
  have same : PackedDictionary.index dictionary positive index.val 0 = index := by
    apply Fin.ext
    simp only [PackedDictionary.index, PackedDictionary.digit, pow_zero, Nat.div_one, Nat.mod_eq_of_lt index.isLt]
  exact congrArg (fun i : Fin dictionary.length => dictionary[i]) same
`;
  const counts: Record<string, number> = {};
  for (const [name, cap, real, bound] of [
    ["projectionScales", "CheckpointAffine.scaleCap", "CheckpointAffine.scaleCap_real", "(2 : ℝ)^(-4 : Int)"],
    ["projectionBiases", "CheckpointAffine.biasCap", "CheckpointAffine.biasCap_real", "(2 : ℝ)^(-1 : Int)"],
    ["embeddingScales", "CheckpointRanges.embeddingScaleCap", "CheckpointRanges.embeddingScaleCap_real", "(1 : ℝ)/64"],
    ["embeddingBiases", "CheckpointRanges.embeddingBiasCap", "CheckpointRanges.embeddingBiasCap_real", "(1 : ℝ)/8"],
  ] as const) {
    const dictionary = [...dictionaries[name]].sort((a, b) => a - b);
    counts[name] = dictionary.length;
    source += `
def ${name}Dictionary : List BF := [
${literalLines(dictionary.map(word => `Model.ofBits 0x${word.toString(16).padStart(4, "0")}`), 16, "  ")}
]
theorem ${name}_positive : 0 < ${name}Dictionary.length := by decide +kernel
theorem ${name}_checked : TensorWords.check ${name}Dictionary ${cap} = true := by decide +kernel
def ${name} (encoded : Encoded rows columns) : Fin rows → Fin columns → BF :=
  read ${name}Dictionary ${name}_positive encoded
theorem ${name}_bound (encoded : Encoded rows columns) (row : Fin rows) (column : Fin columns) :
    Model.isFinite (${name} encoded row column) = true ∧ |Model.toReal (${name} encoded row column)| ≤ ${bound} := by
  simpa only [${name}, ${real}] using
    read_bound ${name}Dictionary ${name}_positive ${cap} ${name}_checked encoded row column
`;
  }
  source += "\nend Inference.Models.Qwen.CheckpointAffineDictionaryData\n";
  return { source, tensors, words: wordCount, dictionaryWords: counts };
}

export async function verifyCheckpointAffine(directory: string) {
  const { source, ...result } = await checkpointAffineSource(directory);
  const checked = await Bun.file(new URL("./CheckpointAffineDictionaryData.lean", import.meta.url)).text();
  if (source !== checked) throw new Error("Affine payload alphabets differ from the certified dictionaries");
  return result;
}

if (import.meta.main) {
  const [directory, mode, output] = process.argv.slice(2);
  if (!directory || (mode !== undefined && mode !== "--emit") || (mode === "--emit" && !output)) {
    throw new Error("Usage: bun checkpoint-affine.ts CHECKPOINT [--emit NEW_LEAN_FILE]");
  }
  if (mode === "--emit") {
    if (await Bun.file(output!).exists()) throw new Error("Refusing to replace an existing proof file");
    const { source, ...result } = await checkpointAffineSource(directory);
    await Bun.write(output!, source);
    console.log(JSON.stringify({ ...result, bytes: Buffer.byteLength(source) }));
  } else console.log(JSON.stringify(await verifyCheckpointAffine(directory)));
}
