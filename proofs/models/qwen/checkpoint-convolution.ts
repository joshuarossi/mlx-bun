import { checkpointWords, literalLines, packedRows } from "./checkpoint-words.ts";

/** Generate exact BF16 convolution literals; Lean checks their bounds. */
export async function checkpointConvolutionSource(directory: string) {
  const words = await checkpointWords(directory);
  const rows: number[][] = [];
  for (let layer = 0; layer < 64; layer++) {
    if (layer % 4 !== 3) rows.push(await words(`model.language_model.layers.${layer}.linear_attn.conv1d.weight`, "BF16", [10240, 1, 4]));
  }
  const { dictionary, chunks } = packedRows(rows);
  const source = `import models.qwen.CheckpointRanges
import contracts.mlx.PackedDictionary

namespace Inference.Models.Qwen.CheckpointConvolutionData
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
set_option maxRecDepth 30000
set_option maxHeartbeats 4000000

-- Exact BF16 words from Qwen3.8-27B-Trellis-3.2bpw, snapshot
-- cbb7a58a7222a19a3d02d36540c9cab5d9aadf0d, Delta layers 0,1,2,4,...,62.
-- [10240,1,4] and the materialized [10240,4,1] use the same flat words.
-- Chunks encode 32 indices in base dictionary.length. Native loader
-- attachment remains separate. Regeneration: checkpoint-convolution.ts.
def dictionary : List BF := [
${literalLines(dictionary.map(word => `Model.ofBits 0x${word.toString(16).padStart(4, "0")}`), 16, "  ")}
]
theorem dictionary_positive : 0 < dictionary.length := by decide +kernel
theorem dictionary_checked : TensorWords.check dictionary BFloat16Arithmetic.one = true := by decide +kernel

${chunks.map((chunk, i) => `def chunks${i} : List Nat :=\n${chunk}`).join("\n\n")}
def chunks : List (List Nat) := [
${literalLines(chunks.map((_, i) => `chunks${i}`), 8, "  ")}
]
theorem dimensions : chunks.length = 48 ∧ chunks.all (fun row => row.length == 1280) = true := by decide +kernel

def weight (layer : Fin 48) (channel : Fin 10240) (tap : Fin 4) : BF :=
  PackedDictionary.read dictionary dictionary_positive
    ((chunks[layer.val]?.getD [])[(4*channel.val+tap.val)/32]?.getD 0) ((4*channel.val+tap.val)%32)

theorem weight_bound (layer : Fin 48) (channel : Fin 10240) (tap : Fin 4) :
    Model.isFinite (weight layer channel tap) = true ∧ |Model.toReal (weight layer channel tap)| ≤ 1 := by
  simpa only [weight, BFloat16Arithmetic.real_one] using
    PackedDictionary.read_bound dictionary dictionary_positive BFloat16Arithmetic.one dictionary_checked
      ((chunks[layer.val]?.getD [])[(4*channel.val+tap.val)/32]?.getD 0) ((4*channel.val+tap.val)%32)

theorem chunk_bound (channel : Fin 10240) (tap : Fin 4) : (4*channel.val+tap.val)/32 < 1280 := by
  have := channel.isLt
  have := tap.isLt
  omega

theorem byte_binding (bytes : Fin (2*(10240*4)) → BitVec 8) (layer : Fin 48)
    (attached : ∀ channel tap, TensorWords.readBFloat16 bytes (CheckpointRanges.flatIndex channel tap) = weight layer channel tap) :
    CheckpointRanges.convolution bytes = weight layer := by
  funext channel tap
  exact attached channel tap

end Inference.Models.Qwen.CheckpointConvolutionData
`;
  return { source, tensors: 48, words: 1966080, dictionaryWords: dictionary.length };
}

export async function verifyCheckpointConvolution(directory: string) {
  const { source, ...result } = await checkpointConvolutionSource(directory);
  const checked = await Bun.file(new URL("./CheckpointConvolutionData.lean", import.meta.url)).text();
  if (source !== checked) throw new Error("Checkpoint convolution literals do not match the selected payloads");
  return result;
}

if (import.meta.main) {
  const [directory, mode, output] = process.argv.slice(2);
  if (!directory || (mode !== undefined && mode !== "--emit") || (mode === "--emit" && !output)) {
    throw new Error("Usage: bun checkpoint-convolution.ts CHECKPOINT [--emit NEW_LEAN_FILE]");
  }
  if (mode === "--emit") {
    if (await Bun.file(output!).exists()) throw new Error("Refusing to replace an existing proof file");
    const { source, ...result } = await checkpointConvolutionSource(directory);
    await Bun.write(output!, source);
    console.log(JSON.stringify({ ...result, bytes: Buffer.byteLength(source) }));
  } else console.log(JSON.stringify(await verifyCheckpointConvolution(directory)));
}
