// Regenerate fused quantized-SDPA goldens from the optiq oracle
// (optiq/runtime/fused_quant_sdpa._prefill_flashattn_n_tiled).
// Explicit command, never run automatically (see PLAN.md testing strategy):
//
//   bun scripts/regen-fused-sdpa-goldens.ts
//
// Writes <out>/fused-sdpa.json (manifest) + <out>/fused-sdpa.bin, where
// <out> is goldenOutDir() — the flat reference set on the reference box,
// goldens/<machine-key>/ elsewhere (bit-exactness is per-GPU).
// (concatenated f32 buffers: q, k, v, out per case). Inputs are
// generated in python (mx.random), cast to bf16, and stored as f32 —
// bf16→f32 round-trips exactly, so the JS side recovers identical bf16
// inputs, quantizes with the same mx.quantize kernel, and the tiled
// output must be BIT-EXACT (same ops, same composition order).
//
// We call _prefill_flashattn_n_tiled directly (not install()/the
// wrapper) so no fallback path can silently swap in the unfused
// reference.

import { ORACLE_PYTHON } from "../tests/paths";
import { goldenOutDir } from "../tests/goldens";
import { mkdirSync } from "node:fs";

const OUT = goldenOutDir();
mkdirSync(OUT, { recursive: true });

const py = `
import json, struct, sys
import mlx.core as mx
from optiq.runtime import fused_quant_sdpa as fqs

outdir = sys.argv[1]

# (name, B, KV, n_rep, L, N, D, group_size, bits, scale, mask, seed)
# N > 2*512 exercises multi-tile + a partial final tile; N > L is a
# continuation (offset = N - L > 0), the scenario this path exists for.
# kv8-decode is L=1 with mask=None — the MLX_BUN_FUSED_DECODE
# experiment's shape (optiq's wrapper tiles decode; no L gate there).
CASES = [
    ("kv8", 1, 1, 4, 128, 1153, 64, 64, 8, 0.125, "causal", 7),
    ("kv4", 1, 1, 4, 128, 1153, 64, 64, 4, 1.0, "causal", 11),
    ("kv8-fullprefill", 1, 2, 2, 700, 700, 64, 32, 8, 0.125, "causal", 13),
    ("kv8-decode", 1, 1, 4, 1, 1153, 64, 64, 8, 1.0, None, 17),
]

manifest = {"cases": []}
blob = bytearray()

def put(arr):
    global blob
    f32 = arr.astype(mx.float32)
    mx.eval(f32)
    data = bytes(memoryview(f32))
    off = len(blob) // 4
    blob.extend(data)
    return {"offset": off, "shape": list(arr.shape)}

for (name, B, KV, n_rep, L, N, D, group, bits, scale, mask, seed) in CASES:
    mx.random.seed(seed)
    H = KV * n_rep
    q = mx.random.normal((B, H, L, D)).astype(mx.bfloat16)
    k = mx.random.normal((B, KV, N, D)).astype(mx.bfloat16)
    v = mx.random.normal((B, KV, N, D)).astype(mx.bfloat16)
    qk = mx.quantize(k, group_size=group, bits=bits)
    qv = mx.quantize(v, group_size=group, bits=bits)
    out = fqs._prefill_flashattn_n_tiled(q, qk, qv, scale, mask, group, bits)
    manifest["cases"].append({
        "name": name, "group_size": group, "bits": bits, "scale": scale,
        "mask": mask or "", "n_chunk": fqs._N_CHUNK,
        "q": put(q), "k": put(k), "v": put(v), "out": put(out),
    })

with open(f"{outdir}/fused-sdpa.bin", "wb") as f:
    f.write(bytes(blob))
print(json.dumps(manifest))
`;

const proc = Bun.spawn([ORACLE_PYTHON, "-c", py, OUT], {
  stdout: "pipe",
  stderr: "pipe",
  cwd: import.meta.dir + "/..",
});
const [out, err, code] = await Promise.all([
  new Response(proc.stdout).text(),
  new Response(proc.stderr).text(),
  proc.exited,
]);
if (code !== 0) throw new Error(`oracle script failed (${code}):\n${err}`);
await Bun.write(`${OUT}/fused-sdpa.json`, JSON.stringify(JSON.parse(out), null, 1));
console.log(`wrote ${OUT}/fused-sdpa.json + ${OUT}/fused-sdpa.bin`);
