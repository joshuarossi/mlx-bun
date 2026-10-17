import { join } from "node:path";

/** CPU-only literal extraction/attachment for CheckpointDeltaData.lean.
 * Lean proves the generated words' bounds. Host I/O and safetensors parsing
 * remain outside that proof; this tool never treats a float scan as a proof. */
type Tensor = { dtype: string; shape: number[]; data_offsets: [number, number] };
type Header = { file: ReturnType<typeof Bun.file>; dataStart: number; tensors: Record<string, unknown> };

function record(value: unknown, label: string): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) throw new Error(`Invalid ${label}`);
  return value as Record<string, unknown>;
}

function tensor(value: unknown, label: string): Tensor {
  const item = record(value, label);
  if (typeof item.dtype !== "string" || !Array.isArray(item.shape) || !Array.isArray(item.data_offsets)
    || item.data_offsets.length !== 2 || !item.shape.every(v => Number.isSafeInteger(v) && v > 0)
    || !item.data_offsets.every(v => Number.isSafeInteger(v) && v >= 0)) throw new Error(`Invalid tensor ${label}`);
  return item as Tensor;
}

function lines(entries: string[], indent: string): string {
  const result: string[] = [];
  for (let i = 0; i < entries.length; i += 16) result.push(indent + entries.slice(i, i + 16).join(", "));
  return result.join(",\n");
}

export async function checkpointDeltaSource(directory: string) {
  const index = record(await Bun.file(join(directory, "model.safetensors.index.json")).json(), "checkpoint index");
  const weightMap = record(index.weight_map, "weight_map");
  const headers = new Map<string, Header>();
  async function words(name: string, count: number): Promise<number[]> {
    const shard = weightMap[name];
    if (typeof shard !== "string" || !/^[A-Za-z0-9_.-]+\.safetensors$/.test(shard)) throw new Error(`Missing shard for ${name}`);
    let header = headers.get(shard);
    if (!header) {
      const file = Bun.file(join(directory, shard));
      const prefix = await file.slice(0, 8).arrayBuffer();
      if (prefix.byteLength !== 8) throw new Error(`Truncated ${shard}`);
      const size = new DataView(prefix).getBigUint64(0, true);
      if (size > 64n * 1024n * 1024n || size > BigInt(file.size - 8)) throw new Error(`Invalid header size in ${shard}`);
      const dataStart = 8 + Number(size);
      header = { file, dataStart, tensors: record(JSON.parse(await file.slice(8, dataStart).text()), `${shard} header`) };
      headers.set(shard, header);
    }
    const info = tensor(header.tensors[name], name);
    const [start, end] = info.data_offsets;
    if (info.dtype !== "BF16" || info.shape.length !== 1 || info.shape[0] !== count
      || end - start !== 2 * count || end > header.file.size - header.dataStart) throw new Error(`Unexpected layout for ${name}`);
    const payload = await header.file.slice(header.dataStart + start, header.dataStart + end).arrayBuffer();
    if (payload.byteLength !== 2 * count) throw new Error(`Truncated payload for ${name}`);
    const view = new DataView(payload);
    return Array.from({ length: count }, (_, i) => view.getUint16(2 * i, true));
  }
  let source = `import models.qwen.CheckpointRanges

namespace Inference.Models.Qwen.CheckpointDeltaData
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
set_option maxRecDepth 30000

-- Literal payloads from Qwen3.8-27B-Trellis-3.2bpw, snapshot
-- cbb7a58a7222a19a3d02d36540c9cab5d9aadf0d, Delta layers 0,1,2,4,...,62.
-- These certify the literals. Host file parsing and native loader attachment
-- are separate obligations. Regeneration uses checkpoint-delta.ts.
def raw (dictionary : List BF) (table : List (List Nat)) (layer : Fin 48) (i : Fin width) : BF :=
  dictionary[((table[layer.val]?.getD [])[i.val]?.getD 0)]?.getD CheckpointRanges.zeroCap
`;
  const counts: Record<string, number> = {};
  for (const [name, suffix, width, exponent, bound] of [
    ["aLog", "A_log", 48, 3, 8], ["dtBias", "dt_bias", 48, 5, 32], ["gatedNorm", "norm.weight", 128, 1, 2],
  ] as const) {
    const rows: number[][] = [];
    for (let layer = 0; layer < 64; layer++) {
      if (layer % 4 !== 3) rows.push(await words(`model.language_model.layers.${layer}.linear_attn.${suffix}`, width));
    }
    const dictionary = [...new Set(rows.flat())].sort((a, b) => a - b);
    const indices = new Map(dictionary.map((word, i) => [word, i]));
    counts[name] = dictionary.length;
    const data = lines(dictionary.map(word => `Model.ofBits 0x${word.toString(16).padStart(4, "0")}`), "  ");
    const table = rows.map(row => "  [\n" + lines(row.map(word => String(indices.get(word))), "    ") + "\n  ]").join(",\n");
    source += `
def ${name}Dictionary : List BF := [
${data}
]
def ${name}Indices : List (List Nat) := [
${table}
]
def ${name}Cap : BF := BFloat16DyadicBounds.ceiling 1 ${exponent}
def ${name} (layer : Fin 48) : Fin ${width} → BF := raw ${name}Dictionary ${name}Indices layer

theorem ${name}Cap_real : Model.toReal ${name}Cap = ${bound} := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 ${exponent} (by decide) (by decide) (by decide)).2
  norm_num at h
  exact h

set_option maxRecDepth 30000 in
set_option maxHeartbeats 0 in
theorem ${name}_checked : TensorWords.check ${name}Dictionary ${name}Cap = true := by decide +kernel

set_option maxRecDepth 30000 in
set_option maxHeartbeats 0 in
theorem ${name}_dimensions : ${name}Dictionary.length = ${dictionary.length} ∧ ${name}Indices.length = 48 ∧
    ${name}Indices.all (fun row => decide (row.length = ${width}) && row.all (fun i => decide (i < ${dictionary.length}))) = true := by
  decide +kernel

theorem ${name}_bound (layer : Fin 48) (i : Fin ${width}) :
    Model.isFinite (${name} layer i) = true ∧ |Model.toReal (${name} layer i)| ≤ ${bound} := by
  have fallback : Model.isFinite CheckpointRanges.zeroCap = true ∧
      |Model.toReal CheckpointRanges.zeroCap| ≤ Model.toReal ${name}Cap := by
    refine ⟨by decide +kernel, ?_⟩
    rw [CheckpointRanges.zeroCap_real, ${name}Cap_real]
    norm_num
  simpa only [${name}, raw, ${name}Cap_real] using
    TensorWords.check_getD ${name}Dictionary ${name}Cap CheckpointRanges.zeroCap ${name}_checked fallback
      ((${name}Indices[layer.val]?.getD [])[i.val]?.getD 0)
`;
  }
  source += "\nend Inference.Models.Qwen.CheckpointDeltaData\n";
  return { source, tensors: 144, words: 10752, dictionaryWords: counts };
}

export async function verifyCheckpointDelta(directory: string) {
  const { source, ...counts } = await checkpointDeltaSource(directory);
  if (await Bun.file(new URL("./CheckpointDeltaData.lean", import.meta.url)).text() !== source) {
    throw new Error("Checkpoint payload differs from the proved Delta literals or certificate definitions");
  }
  return counts;
}

if (import.meta.main) {
  const directory = Bun.argv[2];
  const emit = Bun.argv[3] === "--emit";
  if (!directory || Bun.argv.length !== (emit ? 4 : 3)) throw new Error("Usage: bun proofs/models/qwen/checkpoint-delta.ts CHECKPOINT_DIRECTORY [--emit]");
  if (emit) {
    const file = Bun.file(new URL("./CheckpointDeltaData.lean", import.meta.url));
    if (await file.exists()) throw new Error("Refusing to replace existing Delta proof literals");
    const { source, ...counts } = await checkpointDeltaSource(directory);
    await Bun.write(file, source);
    console.log("Generated Delta literals for Lean checking:", counts);
  } else console.log("Exact Delta payload attachment:", await verifyCheckpointDelta(directory));
}
