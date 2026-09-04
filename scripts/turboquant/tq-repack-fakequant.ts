// Eval carrier for a trellis artifact — fake-quant OR packed. The trellis drivers write the
// decoded MLP tensors as bf16 flagged `false` (unquantized) so stock mlx-lm
// loads them, but at 27B that is ~38 GiB — it only ever runs layer-streamed
// (tq-kl-vs-teacher.py --stream), and the task evals (tq-evals.py: MMLU logprob
// scoring, GSM8K greedy generation) need the whole model resident. This tool
// re-packs exactly those bf16 MLP tensors as 8-bit g64 affine (≈ −45 dB vs the
// weights, negligible next to the ≈ −13 dB trellis error) and leaves every
// other tensor byte-identical, so the carrier is the SAME model numerically
// and fits a 32 GB box (~20 GiB). Not a shipping format: the real Q2b format
// is the packed trellis + Metal kernel.
//
// A PACKED artifact (`mode: "trellis"`, uint32 codes + fp16 row scales) cannot
// load in mlx-lm at all, and our own engine-side eval CLI swap-thrashes a 32 GB
// box at 27B (the reason tq-evals.py exists) — so the packed arms get scored
// through the same carrier: decode each trellis tensor with the Metal expand
// kernel, re-quantize 8-bit g64, write a stock-affine artifact.
//
//   bun scripts/turboquant/tq-repack-fakequant.ts <artifact-dir> <out> \
//       [--bits 8] [--group 64] [--dry-run]

import { existsSync, mkdirSync, copyFileSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { type MlxArray, gpuStream } from "../../src/mlx/array";
import { Dtype, clearCache, activeMemory } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { quantize } from "../../src/mlx/ops";
import { ShardedWriter } from "../../src/quantize/safetensors-writer";
import { writeQuantizedConfig, type QuantizationBlock } from "../../src/quantize/config-writer";
import { expandTrellis, trellisGeometry } from "../../src/model/trellis-linear";
import type { QuantSpec } from "../../src/config";

const argv = process.argv.slice(2);
const positional = argv.filter((a, i) => !a.startsWith("--") && !(i > 0 && ["--bits", "--group"].includes(argv[i - 1]!)));
const opt = (k: string, d: string): string => { const i = argv.indexOf(`--${k}`); return i >= 0 ? argv[i + 1]! : d; };
const flag = (k: string): boolean => argv.includes(`--${k}`);
const [srcDir, outDir] = positional;
if (!srcDir || (!outDir && !flag("dry-run"))) {
  console.error("usage: bun scripts/turboquant/tq-repack-fakequant.ts <fakequant-dir> <out> [--bits 8] [--group 64] [--dry-run]");
  process.exit(2);
}
const BITS = Number(opt("bits", "8"));
const GROUP = Number(opt("group", "64"));
const dryRun = flag("dry-run");

const raw = JSON.parse(readFileSync(join(srcDir, "config.json"), "utf8")) as Record<string, unknown>;
const srcBlock = raw.quantization as QuantizationBlock | undefined;
if (!srcBlock || typeof srcBlock !== "object") throw new Error(`${srcDir}/config.json has no quantization block`);
const block: QuantizationBlock = JSON.parse(JSON.stringify(srcBlock));

const LM = "model.language_model.";
const MLP_RE = /\.layers\.\d+\.mlp\.(gate_proj|up_proj|down_proj)$/;
const mlxLmPath = (base: string): string => base.replace("model.language_model", "language_model.model");
type TrellisEntry = { mode?: string; bits?: number; group_size?: number; trellis?: { L: number; code: string; axis: 0 | 1 } };
/** The packed spec for a module, when the config says it is trellis-coded. */
function trellisSpecOf(base: string): QuantSpec | null {
  const e = block[base] as TrellisEntry | false | undefined;
  if (!e || typeof e !== "object" || e.mode !== "trellis" || !e.trellis) return null;
  return { bits: e.bits!, groupSize: e.group_size!, mode: "trellis", trellis: e.trellis };
}
/** A fake-quant trellis tensor: language-model MLP projection, stored bf16, flagged `false`. */
const isTarget = (base: string, shape: readonly number[]): boolean =>
  base.startsWith(LM) && MLP_RE.test(base) && block[base] === false &&
  shape.length === 2 && shape[1]! % GROUP === 0;

const weights = await Weights.open(srcDir);
const names = weights.tensorNames;
let nTarget = 0, targetBytes = 0, packedBytes = 0;
for (const name of names) {
  if (!name.endsWith(".weight")) continue;
  const base = name.slice(0, -".weight".length);
  const info = weights.info(name);
  const ts = trellisSpecOf(base);
  if (ts) {
    nTarget++;
    const cols = (info.shape[1]! * 32) / ts.bits;
    const params = info.shape[0]! * cols;
    targetBytes += params * 2;
    packedBytes += (params * (BITS + 32 / GROUP)) / 8;
    continue;
  }
  if (!isTarget(base, info.shape)) continue;
  nTarget++;
  const params = info.shape[0]! * info.shape[1]!;
  targetBytes += params * 2;
  packedBytes += (params * (BITS + 32 / GROUP)) / 8;
}
console.log(
  `${nTarget} trellis MLP tensors → ${BITS}-bit g${GROUP} affine: ` +
  `${(targetBytes / 2 ** 30).toFixed(2)} GiB bf16 → ${(packedBytes / 2 ** 30).toFixed(2)} GiB packed`,
);
if (nTarget === 0) throw new Error("nothing to repack: no fake-quant or packed trellis MLP tensors");
if (dryRun) { weights.dispose(); process.exit(0); }

mkdirSync(outDir!, { recursive: true });
const writer = new ShardedWriter(outDir!, { shardBytes: 2 * 1024 ** 3 });
const repacked: string[] = [];
const t0 = performance.now();
try {
  const byFile = new Map<string, string[]>();
  for (const n of names) {
    const f = weights.fileOf(n)!;
    let list = byFile.get(f);
    if (!list) byFile.set(f, (list = []));
    list.push(n);
  }
  let done = 0;
  for (const [file, list] of byFile) {
    for (const name of list) {
      if (name.endsWith(".scales") && trellisSpecOf(name.slice(0, -".scales".length))) continue;
      const base = name.endsWith(".weight") ? name.slice(0, -".weight".length) : null;
      const ts = base !== null ? trellisSpecOf(base) : null;
      if (ts && base !== null) {
        // Packed: decode with the Metal expand kernel, orient to [out, in].
        const codes = weights.tensor(name);
        const g = trellisGeometry(codes, ts);
        const stored = expandTrellis(codes, weights.tensor(`${base}.scales`), g, Dtype.bfloat16);
        let w = stored;
        if (g.axis === 0) {
          const t = ops.transposeAxes(stored, [1, 0], gpuStream);
          w = ops.contiguous(t, gpuStream);
          t.dispose(); stored.dispose();
        }
        const q = quantize(w, GROUP, BITS, "affine", gpuStream);
        ops.evalAll([q.packed, q.scales, ...(q.biases ? [q.biases] : [])]);
        w.dispose();
        weights.release(name); weights.release(`${base}.scales`);
        writer.add(`${base}.weight`, q.packed);
        writer.add(`${base}.scales`, q.scales);
        if (q.biases) writer.add(`${base}.biases`, q.biases);
        block[base] = { bits: BITS, group_size: GROUP };
        block[mlxLmPath(base)] = { bits: BITS, group_size: GROUP };
        repacked.push(base);
        done++;
        process.stdout.write(`\r  ${done}/${names.length} tensors · repacked ${repacked.length} · mlx ${(activeMemory() / 2 ** 30).toFixed(2)} GiB   `);
        clearCache();
        continue;
      }
      if (base !== null && names.includes(`${base}.scales`) && trellisSpecOf(base)) continue;
      const src = weights.tensor(name);
      if (base !== null && isTarget(base, src.shape)) {
        const q = quantize(src, GROUP, BITS, "affine", gpuStream);
        ops.evalAll([q.packed, q.scales, ...(q.biases ? [q.biases] : [])]);
        writer.add(`${base}.weight`, q.packed);
        writer.add(`${base}.scales`, q.scales);
        if (q.biases) writer.add(`${base}.biases`, q.biases);
        block[base] = { bits: BITS, group_size: GROUP };
        block[mlxLmPath(base)] = { bits: BITS, group_size: GROUP };
        repacked.push(base);
      } else {
        // Own a copy: the writer holds tensors until a shard fills, but the
        // source array dies with releaseShard(file) below.
        writer.add(name, ops.copyOf(src, gpuStream));   // byte-identical passthrough
      }
      done++;
      process.stdout.write(`\r  ${done}/${names.length} tensors · repacked ${repacked.length} · mlx ${(activeMemory() / 2 ** 30).toFixed(2)} GiB   `);
    }
    weights.releaseShard(file);
    clearCache();
  }
  const res = writer.finish();
  console.log(`\non-disk ${(res.totalSize / 2 ** 30).toFixed(3)} GiB · ${((performance.now() - t0) / 60000).toFixed(1)} min`);

  await writeQuantizedConfig(raw, outDir!, block, { srcDir });
  for (const f of ["preprocessor_config.json", "video_preprocessor_config.json", "turboquant_fold.json"])
    if (existsSync(join(srcDir, f))) copyFileSync(join(srcDir, f), join(outDir!, f));
  const srcMeta = existsSync(join(srcDir, "optiq_metadata.json"))
    ? JSON.parse(readFileSync(join(srcDir, "optiq_metadata.json"), "utf8")) as Record<string, unknown>
    : {};
  await Bun.write(join(outDir!, "optiq_metadata.json"), JSON.stringify({
    ...srcMeta,
    eval_carrier: {
      note: "trellis MLP tensors (fake-quant bf16 or packed codes) re-packed as affine for dense loading; NOT the shipping format",
      source: srcDir, bits: BITS, group_size: GROUP, repacked_modules: repacked.length,
    },
  }, null, 2));
  console.log(`wrote ${outDir}: ${repacked.length} modules repacked, config + sidecars written`);
} finally {
  weights.dispose();
}
