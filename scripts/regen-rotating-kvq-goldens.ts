// Regenerate Phase 9 rotating-KV-quant goldens from the optiq oracle.
// Explicit command, never automatic:  bun scripts/regen-rotating-kvq-goldens.ts
//
// Two tiers:
//  (1) MECHANICS — optiq's RotatingQuantizedKVCache driven through a
//      scripted update sequence covering: first prefill, decode growth,
//      ring wrap, prefill-concat OVER a wrapped ring, post-wrap decode.
//      Dumps the active (packed, scales, biases) triples + offset/_idx
//      at checkpoints. Our class must match bit-for-bit.
//  (2) END-TO-END — 12B single forward over a PAST-WINDOW prompt
//      (1.5k tokens > sliding window 1024) with uniform kv8 on ALL
//      layers (rotating + full, via patch_rotating_to_quantized), fused
//      SDPA installed (the serving reference; our dispatch matches it
//      scenario-for-scenario incl. unfused window-mask prefill), plus a
//      16-token greedy trajectory with fused UNINSTALLED for decode
//      (mirrors our stock-L=1 dispatch — same convention as
//      regen-kvq-goldens.ts).
//      Uses the 12B only: e4b's 8-bit sliding layers hit optiq's
//      registry-miss shim bug (Phase 15 finding).
//
// Writes goldens/rotating-kvq.json + goldens/rotating-kvq.bin (+ e2e
// logits in the same blob).

import { ORACLE_PYTHON, SNAPSHOT } from "../tests/paths";

const py = `
import json, sys
import mlx.core as mx
from optiq.runtime.kv.rotating import RotatingQuantizedKVCache, patch_rotating_to_quantized

manifest = {"mechanics": {"steps": [], "checkpoints": {}}, "e2e": {}}
blob = bytearray()

def put(arr, kind="f32"):
    global blob
    a = arr.astype(mx.float32) if kind == "f32" else arr
    mx.eval(a)
    b = bytes(memoryview(a))
    entry = {"offset": len(blob) // 4, "shape": list(arr.shape), "dtype": kind}
    blob.extend(b)
    return entry

# ---- (1) mechanics ----
MAX_SIZE, H, D, GROUP, BITS = 64, 2, 64, 32, 8
mx.random.seed(3)
cache = RotatingQuantizedKVCache(max_size=MAX_SIZE, keep=0, group_size=GROUP, bits=BITS)
# prefill 48 -> 20 decodes (wraps at 64) -> prefill 16 over the wrapped
# ring (concat path + temporal order) -> 8 post-wrap decodes
SEQ = [48] + [1] * 20 + [16] + [1] * 8
CHECK_AT = {0, 10, 16, 20, 21, 25, len(SEQ) - 1}
for i, S in enumerate(SEQ):
    k = mx.random.normal((1, H, S, D)).astype(mx.bfloat16)
    v = mx.random.normal((1, H, S, D)).astype(mx.bfloat16)
    step = {"S": S, "k": put(k), "v": put(v)}
    qk, qv = cache.update_and_fetch(k, v)
    if i in CHECK_AT:
        manifest["mechanics"]["checkpoints"][str(i)] = {
            "offset": cache.offset, "idx": cache._idx,
            "k_packed": put(qk[0], "u32"), "k_scales": put(qk[1]), "k_biases": put(qk[2]),
            "v_packed": put(qv[0], "u32"), "v_scales": put(qv[1]), "v_biases": put(qv[2]),
        }
    manifest["mechanics"]["steps"].append(step)
manifest["mechanics"]["config"] = {
    "max_size": MAX_SIZE, "heads": H, "dim": D, "group_size": GROUP, "bits": BITS,
}

# ---- (2) end-to-end ----
from optiq.mlx_lm_patches._register import register
register()
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache, KVCache, RotatingKVCache
from optiq.runtime.fused_quant_sdpa import install as install_fused, uninstall as uninstall_fused

patch_rotating_to_quantized()
snap = sys.argv[1]
model, tokenizer = load(snap)

para = tokenizer.encode(
    "The unified memory architecture lets the CPU and GPU share one pool, "
    "so a model's weights are mapped once and read by both without copies. "
    "Decode speed is bounded by how fast those bytes stream from DRAM. ",
)
ids = [2]
while len(ids) < 1536:
    ids.extend(para[1:] if para and para[0] == tokenizer.bos_token_id else para)
ids = ids[:1536]
manifest["e2e"]["prompt_ids"] = ids

def quantize_all(bits):
    cache = make_prompt_cache(model)
    for i, c in enumerate(cache):
        if isinstance(c, (KVCache, RotatingKVCache)):
            cache[i] = c.to_quantized(group_size=64, bits=bits)
    return cache

for key, bits in (("kv8", 8), ("kv4", 4)):
    install_fused()
    cache = quantize_all(bits)
    logits = model(mx.array([ids]), cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    manifest["e2e"][key + "_logits"] = put(last)
    # greedy continuation: fused prefill already happened; decode unfused
    uninstall_fused()
    y = mx.array([[int(mx.argmax(last).item())]])
    toks = [int(y.item())]
    for _ in range(15):
        logits = model(y, cache=cache)
        t = int(mx.argmax(logits[0, -1, :]).item())
        toks.append(t)
        y = mx.array([[t]])
    manifest["e2e"][key + "_greedy"] = toks
    del cache

with open("goldens/rotating-kvq.bin", "wb") as f:
    f.write(bytes(blob))
print(json.dumps(manifest))
`;

const proc = Bun.spawn([ORACLE_PYTHON, "-c", py, SNAPSHOT], {
  stdout: "pipe", stderr: "pipe", cwd: import.meta.dir + "/..",
});
const [out, err, code] = await Promise.all([
  new Response(proc.stdout).text(),
  new Response(proc.stderr).text(),
  proc.exited,
]);
if (code !== 0) throw new Error(`oracle failed (${code}):\n${err.slice(-2000)}`);
await Bun.write("goldens/rotating-kvq.json", JSON.stringify(JSON.parse(out)));
console.log("wrote goldens/rotating-kvq.json + goldens/rotating-kvq.bin");
