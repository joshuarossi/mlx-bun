import { checkpointWords, literalLines, packedRows } from "./checkpoint-words.ts";

/** CPU-only extraction and attachment of the selected FP16 Trellis scales.
 * Lean checks the literal dictionaries and the bounded decoding. Host file
 * I/O and safetensors parsing remain outside that mathematical proof. */
export async function checkpointTrellisSource(directory: string) {
  const words = await checkpointWords(directory);
  let source = `import models.qwen.CheckpointTrellis
import contracts.mlx.PackedDictionary

namespace Inference.Models.Qwen.CheckpointTrellisData
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 30000
set_option maxHeartbeats 4000000

-- Exact scale data from Qwen3.8-27B-Trellis-3.2bpw, snapshot
-- cbb7a58a7222a19a3d02d36540c9cab5d9aadf0d. Each chunk encodes 32
-- dictionary indices in base dictionary.length. Host payload attachment
-- remains separate. Regeneration uses checkpoint-trellis.ts.
def raw (dictionary : List Float16.Value) (positive : 0 < dictionary.length)
    (chunks : List (List Nat)) (layer : Fin 64) (row : Fin 17408) : Float16.Value :=
  PackedDictionary.read dictionary positive
    ((chunks[layer.val]?.getD [])[row.val/32]?.getD 0) (row.val%32)
def scale (dictionary : List Float16.Value) (positive : 0 < dictionary.length)
    (chunks : List (List Nat)) (layer : Fin 64) (row : Nat) : Float32 :=
  if h : row < 17408 then Float16.widen (raw dictionary positive chunks layer ⟨row,h⟩) else 0
theorem scale_bound (dictionary : List Float16.Value) (positive : 0 < dictionary.length)
    (chunks : List (List Nat)) (cap : Float16.Value) (nonnegative : 0 ≤ Model.toReal cap)
    (checked : TensorWords.check dictionary cap = true) (layer : Fin 64) (row : Nat) :
    (scale dictionary positive chunks layer row).isFinite = true ∧
      |real (scale dictionary positive chunks layer row)| ≤ Model.toReal cap := by
  unfold scale
  split
  · exact Float16.widen_bound _ _ (PackedDictionary.read_bound dictionary positive cap checked _ _)
  · exact ⟨by decide, by simpa only [FlushedIdentities.zero_real, abs_zero] using nonnegative⟩
`;
  const counts: Record<string, number> = {};
  for (const [name, cap, bound] of [["gate", "gateCap", "9/256"], ["up", "upCap", "1/16"], ["down", "downCap", "1/32"]] as const) {
    const rows: number[][] = [];
    for (let layer = 0; layer < 64; layer++) rows.push(await words(`model.language_model.layers.${layer}.mlp.${name}_proj.scales`, "F16", [17408]));
    const { dictionary, chunks } = packedRows(rows);
    counts[name] = dictionary.length;
    source += `
def ${name}Dictionary : List Float16.Value := [
${literalLines(dictionary.map(word => `Model.ofBits 0x${word.toString(16).padStart(4, "0")}`), 16, "  ")}
]
theorem ${name}Dictionary_positive : 0 < ${name}Dictionary.length := by decide +kernel
theorem ${name}Dictionary_checked : TensorWords.check ${name}Dictionary CheckpointTrellis.${cap} = true := by decide +kernel
${chunks.map((chunk, i) => `def ${name}Chunks${i} : List Nat :=\n${chunk}`).join("\n\n")}
def ${name}Chunks : List (List Nat) := [
${literalLines(chunks.map((_, i) => `${name}Chunks${i}`), 8, "  ")}
]
theorem ${name}_dimensions : ${name}Chunks.length = 64 ∧ (${name}Chunks.all (fun row => row.length == 544)) = true := by decide +kernel
def ${name} (layer : Fin 64) (row : Nat) : Float32 := scale ${name}Dictionary ${name}Dictionary_positive ${name}Chunks layer row
theorem ${name}_bound (layer : Fin 64) (row : Nat) :
    (${name} layer row).isFinite = true ∧ |real (${name} layer row)| ≤ (${bound} : ℝ) := by
  simpa only [${name}, CheckpointTrellis.${cap}_real] using scale_bound ${name}Dictionary ${name}Dictionary_positive ${name}Chunks
    CheckpointTrellis.${cap} (by rw [CheckpointTrellis.${cap}_real]; norm_num) ${name}Dictionary_checked layer row
`;
  }
  source += "\nend Inference.Models.Qwen.CheckpointTrellisData\n";
  return { source, tensors: 192, words: 3342336, dictionaryWords: counts };
}

export async function verifyCheckpointTrellis(directory: string) {
  const { source, ...result } = await checkpointTrellisSource(directory);
  const checked = await Bun.file(new URL("./CheckpointTrellisData.lean", import.meta.url)).text();
  if (source !== checked) throw new Error("Checkpoint Trellis scale literals do not match the selected payloads");
  return result;
}

if (import.meta.main) {
  const [directory, mode, output] = process.argv.slice(2);
  if (!directory || (mode !== undefined && mode !== "--emit") || (mode === "--emit" && !output)) {
    throw new Error("Usage: bun checkpoint-trellis.ts CHECKPOINT [--emit NEW_LEAN_FILE]");
  }
  if (mode === "--emit") {
    if (await Bun.file(output!).exists()) throw new Error("Refusing to replace an existing proof file");
    const { source, ...result } = await checkpointTrellisSource(directory);
    await Bun.write(output!, source);
    console.log(JSON.stringify({ ...result, bytes: Buffer.byteLength(source) }));
  } else {
    console.log(JSON.stringify(await verifyCheckpointTrellis(directory)));
  }
}
