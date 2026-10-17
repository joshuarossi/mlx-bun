import { join } from "node:path";

type Header = { file: ReturnType<typeof Bun.file>; dataStart: number; tensors: Record<string, unknown> };
function record(value: unknown, label: string): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) throw new Error(`Invalid ${label}`);
  return value as Record<string, unknown>;
}

/** CPU-only raw-word attachment. File I/O and safetensors parsing are outside Lean. */
export async function checkpointWords(directory: string) {
  const index = record(await Bun.file(join(directory, "model.safetensors.index.json")).json(), "checkpoint index");
  const weightMap = record(index.weight_map, "weight_map");
  const headers = new Map<string, Header>();
  return async (name: string, dtype: "F16" | "BF16", shape: readonly number[]): Promise<number[]> => {
    if (shape.length === 0 || !shape.every(v => Number.isSafeInteger(v) && v > 0)) throw new Error("Invalid expected shape");
    const count = shape.reduce((a, b) => a * b, 1);
    if (!Number.isSafeInteger(2 * count)) throw new Error("Expected payload is too large");
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
    const tensor = record(header.tensors[name], name);
    const offsets = tensor.data_offsets;
    if (tensor.dtype !== dtype || !Array.isArray(tensor.shape) || tensor.shape.length !== shape.length
      || !tensor.shape.every((v, i) => v === shape[i])
      || !Array.isArray(offsets) || offsets.length !== 2 || !offsets.every(v => Number.isSafeInteger(v) && v >= 0)
      || offsets[1] - offsets[0] !== 2 * count || offsets[1] > header.file.size - header.dataStart) throw new Error(`Unexpected layout for ${name}`);
    const payload = await header.file.slice(header.dataStart + offsets[0], header.dataStart + offsets[1]).arrayBuffer();
    if (payload.byteLength !== 2 * count) throw new Error(`Truncated payload for ${name}`);
    const view = new DataView(payload);
    return Array.from({ length: count }, (_, i) => view.getUint16(2 * i, true));
  };
}

export function literalLines(entries: string[], count: number, indent: string): string {
  const result: string[] = [];
  for (let i = 0; i < entries.length; i += count) result.push(indent + entries.slice(i, i + count).join(", "));
  return result.join(",\n");
}

/** Encode in base dictionary.length and verify every decoded raw word. */
export function packedRows(rows: readonly number[][]) {
  const dictionary = [...new Set(rows.flat())].sort((a, b) => a - b);
  if (!dictionary.length) throw new Error("Empty dictionary");
  const indices = new Map(dictionary.map((word, i) => [word, i]));
  const base = BigInt(dictionary.length);
  const chunks = rows.map(row => {
    if (row.length % 32 !== 0) throw new Error("Expected complete 32-word chunks");
    const packed: string[] = [];
    for (let start = 0; start < row.length; start += 32) {
      let chunk = 0n;
      for (let i = start + 31; i >= start; i--) {
        const index = indices.get(row[i]!);
        if (index === undefined) throw new Error("Missing dictionary entry");
        chunk = chunk * base + BigInt(index);
      }
      let remaining = chunk;
      for (let i = 0; i < 32; i++) {
        if (dictionary[Number(remaining % base)] !== row[start + i]) throw new Error("Packed word mismatch");
        remaining /= base;
      }
      packed.push("0x" + chunk.toString(16));
    }
    return "  [\n" + literalLines(packed, 4, "    ") + "\n  ]";
  });
  return { dictionary, chunks };
}
