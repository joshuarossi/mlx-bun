/** Cache component A/B: fixed bytes and request traces, no model sampling.
 * bun scripts/bench/cache-tiers.ts [--mib 64] [--samples 3] [--output path]
 * Measures warm filesystem reads; use bench-serve for end-to-end claims. */
import { ptr } from "bun:ffi";
import { cpus, hostname, tmpdir } from "node:os";
import { mkdtempSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { KvWriter } from "../../src/storage/kv-writer";
import { HostBuffer } from "../../src/storage/host-buffer";
import type { KvFileHeader } from "../../src/kv-store";
const arg = (name: string, fallback: string) => process.argv[process.argv.indexOf(name) + 1] && process.argv.includes(name)
  ? process.argv[process.argv.indexOf(name) + 1]! : fallback;
const mib = Number(arg("--mib", "64")), samples = Number(arg("--samples", "3"));
const dir = mkdtempSync(join(tmpdir(), "mlx-cache-bench-"));
const writer = new KvWriter(), reader = new KvWriter();
const heads = 8, width = 256, capacity = Math.floor(mib * 2 ** 20 / heads / width);
const source = new Uint8Array(heads * capacity * width);
let seed = 42;
for (let i = 0; i < source.length; i++) { seed = (Math.imul(seed, 1664525) + 1013904223) | 0; source[i] = seed >>> 24; }
function header(length: number): KvFileHeader {
  return { formatVersion: 3, createdAt: 0, tokens: Array.from({ length }, (_, i) => i),
    caches: [{ kind: "ssm", offset: length, tensors: [{ off: 0, bytes: heads * length * width,
      shape: [1, heads, length, width], dtype: 1, hash: "0".repeat(16) }] }] };
}
function fileHeader(path: string): KvFileHeader & { dataStart: number } {
  const file = readFileSync(path), view = new DataView(file.buffer, file.byteOffset, file.length);
  return { ...JSON.parse(file.subarray(26, 26 + view.getUint32(10, true)).toString()), dataStart: view.getUint32(14, true) };
}
function diskBytes(path: string): number {
  return readdirSync(path).reduce((sum, file) => { const p = join(path, file), st = statSync(p);
    return sum + (st.isDirectory() ? diskBytes(p) : st.size); }, 0);
}
const results: object[] = [];
try {
  const warm = join(dir, "warm.mlxkv"), h = header(1);
  await writer.write({ path: warm, header: h, tensors: [{ pointer: Number(ptr(source)), shape: h.caches[0]!.tensors[0]!.shape,
    strides: [source.length, capacity * width, width, 1], itemSize: 1 }] });
  using destination = new HostBuffer(heads * capacity * width);
  await reader.read({ path: warm, header: fileHeader(warm), pointers: [destination.pointer] });
  for (let sample = 0; sample < samples; sample++) {
    const modes = sample % 2 ? ["blocks", "packed-blocks", "whole"] : ["whole", "packed-blocks", "blocks"];
    for (const mode of modes) {
      const runDir = join(dir, `${sample}-${mode}`); mkdirSync(runDir);
      let writeMs = 0, writtenBytes = 0, reusedBytes = 0, copiedBytes = 0, scratchPeak = 0;
      let path = "";
      for (const fraction of [0.25, 0.5, 0.75, 1]) {
        const length = Math.floor(capacity * fraction), h = header(length);
        path = join(runDir, `${length}.mlxkv`);
        const start = performance.now();
        await writer.write({ path, header: h, layout: mode === "whole" ? "whole" : "blocks", segmented: mode !== "packed-blocks",
          tensors: [{ pointer: Number(ptr(source)), shape: h.caches[0]!.tensors[0]!.shape,
            strides: [source.length, capacity * width, width, 1], itemSize: 1 }] });
        writeMs += performance.now() - start;
        const m = writer.lastMetrics;
        writtenBytes += m?.writtenBytes ?? statSync(path).size; reusedBytes += m?.reusedBytes ?? 0;
        copiedBytes += m?.copiedBytes ?? (fraction < 1 ? h.caches[0]!.tensors[0]!.bytes : 0);
        scratchPeak = Math.max(scratchPeak, m?.scratchPeak ?? (fraction < 1 ? h.caches[0]!.tensors[0]!.bytes : 0));
      }
      const h = fileHeader(path), start = performance.now();
      let ticks = 0; const timer = setInterval(() => ticks++, 1);
      await reader.read({ path, header: h, pointers: [destination.pointer], verify: true });
      const readMs = performance.now() - start; clearInterval(timer);
      results.push({ sample, mode, writeMs, readMs, eventLoopTicksDuringRead: ticks,
        writtenBytes, reusedBytes, copiedBytes, scratchPeak, diskBytes: diskBytes(runDir) });
      rmSync(runDir, { recursive: true });
    }
  }
  const report = { machine: hostname(), cpu: cpus()[0]?.model, bun: Bun.version, mib, samples,
    workload: "four growing immutable checkpoints; warm filesystem reads; seed 42", results };
  const output = arg("--output", "");
  if (output) { mkdirSync(dirname(output), { recursive: true }); writeFileSync(output, JSON.stringify(report, null, 2)); }
  console.log(JSON.stringify(report, null, 2));
} finally { rmSync(dir, { recursive: true, force: true }); }
