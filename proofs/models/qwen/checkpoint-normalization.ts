import { join } from "node:path";

/** CPU-only attachment check for the normalization literals proved in Lean.
 * Reads selected payloads, compares exact words, and performs no floating-point
 * range testing. This host I/O/parser is outside Lean's checked mathematics. */
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

function literalRows(entries: string[], indent: string): string {
  const rows: string[] = [];
  for (let i = 0; i < entries.length; i += 16) rows.push(indent + entries.slice(i, i + 16).join(", "));
  return rows.join(",\n");
}

function requireLiteral(source: string, name: string, type: string, body: string): void {
  const expected = `def ${name} : ${type} := [\n${body}\n]`;
  if (!source.includes(expected)) throw new Error(`Checkpoint payload differs from proved ${name} literals`);
}

export async function verifyCheckpointNormalization(directory: string) {
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
      const tensors = record(JSON.parse(await file.slice(8, dataStart).text()), `${shard} header`);
      header = { file, dataStart, tensors };
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
  const prefix = "model.language_model";
  for (let layer = 0; layer < 64; layer++) {
    for (const kind of ["input_layernorm", "post_attention_layernorm"]) {
      const name = `${prefix}.layers.${layer}.${kind}.weight`;
      if ((await words(name, 5120)).some(word => word !== 0)) throw new Error(`Nonzero word in ${name}`);
    }
  }
  if ((await words(`${prefix}.norm.weight`, 5120)).some(word => word !== 0)) throw new Error("Nonzero final normalization word");
  const query: number[][] = [], key: number[][] = [];
  for (let layer = 3; layer < 64; layer += 4) {
    query.push(await words(`${prefix}.layers.${layer}.self_attn.q_norm.weight`, 256));
    key.push(await words(`${prefix}.layers.${layer}.self_attn.k_norm.weight`, 256));
  }
  const dictionary = [...new Set([...query.flat(), ...key.flat()])].sort((a, b) => a - b);
  const indices = new Map(dictionary.map((word, i) => [word, i]));
  const source = await Bun.file(new URL("./CheckpointNormalizationData.lean", import.meta.url)).text();
  requireLiteral(source, "dictionary", "List BF",
    literalRows(dictionary.map(word => `Model.ofBits 0x${word.toString(16).padStart(4, "0")}`), "  "));
  function tables(rows: number[][]): string {
    return rows.map(row => "  [\n" + literalRows(row.map(word => String(indices.get(word))), "    ") + "\n  ]").join(",\n");
  }
  requireLiteral(source, "queryIndices", "List (List Nat)", tables(query));
  requireLiteral(source, "keyIndices", "List (List Nat)", tables(key));
  // Also bind the compact all-zero payload representation to the checked
  // definition, rather than merely observing zeros in the external file.
  if (!source.includes("def mainNorm (_layer : Fin 129) : Fin 5120 → BF :=\n  CheckpointTransforms.shiftNorm (fun _ => CheckpointRanges.zeroCap)")) {
    throw new Error("Unexpected main normalization literal definition");
  }
  return { mainNormalizationTensors: 129, headNormalizationTensors: 32, headWords: 8192, dictionaryWords: dictionary.length };
}

if (import.meta.main) {
  const directory = Bun.argv[2];
  if (!directory || Bun.argv.length !== 3) throw new Error("Usage: bun proofs/models/qwen/checkpoint-normalization.ts CHECKPOINT_DIRECTORY");
  console.log("Exact normalization payload attachment:", await verifyCheckpointNormalization(directory));
}
