/** Header facts of checkpoint tensors, for runs over the MLX FFI model.
 * bun proofs/host/ts/checkpoint-header.ts <model-dir> <virtual-dir> <name-prefix>...
 * Reads `model.safetensors.index.json` and the JSON header of each shard holding a tensor whose
 * name starts with a prefix (header bytes only), and prints JSON: `lean`, the `Host.Mlx.Ffi`
 * files table (path ↦ name, shape, mlx_dtype code), `shards`, the same entries for the driver's
 * `SafetensorsFile` objects, and `quantization`, the config.json quantization entries of those
 * modules. Paths are `<virtual-dir>/<shard>`. The shapes and dtypes are what the file says; the
 * Lean checkpoint checker (`models/qwen/CheckpointFile*`) certifies the ones it reads. */
const [dir, vdir, ...prefixes] = process.argv.slice(2);
if (!dir || !vdir || !prefixes.length) throw new Error("usage: checkpoint-header.ts <model-dir> <virtual-dir> <prefix>...");

const CODE: Record<string, number> = { BOOL: 0, U8: 1, U16: 2, U32: 3, U64: 4, I8: 5, I16: 6, I32: 7, I64: 8, F16: 9, F32: 10, F64: 11, BF16: 12 };
const index = await Bun.file(`${dir}/model.safetensors.index.json`).json() as { weight_map: Record<string, string> };
const names = Object.keys(index.weight_map).filter(n => prefixes.some(p => n.startsWith(p))).sort();
const byShard = new Map<string, string[]>();
for (const n of names) byShard.set(index.weight_map[n]!, [...(byShard.get(index.weight_map[n]!) ?? []), n]);

type Entry = { dtype: string; shape: number[]; data_offsets: [number, number] };
const shards: [string, [string, string, number[], number, number][]][] = [];
for (const [shard, ns] of [...byShard].sort()) {
  const file = Bun.file(`${dir}/${shard}`);
  const len = Number(new DataView(await file.slice(0, 8).arrayBuffer()).getBigUint64(0, true));
  const header = JSON.parse(await file.slice(8, 8 + len).text()) as Record<string, Entry>;
  shards.push([shard, ns.map(n => {
    const e = header[n]!;
    if (!(e.dtype in CODE)) throw new Error(`${n}: dtype ${e.dtype}`);
    return [n, e.dtype, e.shape, e.data_offsets[0], e.data_offsets[1]];
  })]);
}

const config = await Bun.file(`${dir}/config.json`).json() as { quantization: Record<string, unknown> };
const q = config.quantization;
const modules = new Set(names.map(n => n.replace(/\.(weight|scales|biases)$/, "")));
const quantization: Record<string, unknown> = { group_size: q.group_size, bits: q.bits, mode: q.mode };
for (const [k, v] of Object.entries(q))
  if (modules.has(k) || modules.has(k.replace(/^language_model\.model\./, "model.language_model."))) quantization[k] = v;

const chars = (s: string) => `chars!${JSON.stringify(s)}`;
const lean = `[${shards.map(([shard, es]) => `(${chars(`${vdir}/${shard}`)},\n  [${es.map(([n, d, s]) =>
  `(${chars(n)}, [${s.join(", ")}], ${CODE[d]})`).join(",\n   ")}])`).join(",\n ")}]`;
console.log(JSON.stringify({ lean, shards, quantization }));
