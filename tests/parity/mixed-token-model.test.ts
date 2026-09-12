import { expect, test } from "bun:test";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { ORACLE_PYTHON } from "../support/paths";

const artifact = Bun.env.MLX_BUN_TEST_MIXED_MODEL;
// Same packed geometry, pinned upstream operators. Independent attention is
// evaluated at its original B/L; only the feed-forward block packs tokens.
const oracle = String.raw`
import sys,json,hashlib
import numpy as np
from optiq.mlx_lm_patches._register import register
register()
import mlx.core as mx
import mlx.nn as nn
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache
from optiq.runtime.kv.rotating import patch_rotating_to_quantized
from optiq.runtime.fused_quant_sdpa import uninstall as uninstall_fused
patch_rotating_to_quantized();uninstall_fused()
model,_=load(sys.argv[1])
if hasattr(model,'language_model'):model=model.language_model
body=model.model
def digest(a):return hashlib.sha256(np.asarray(a.astype(mx.float32)).tobytes()).hexdigest()
def feed_forward(layer,h,pli):
    residual=h
    if layer.enable_moe:
        h1=layer.post_feedforward_layernorm_1(layer.mlp(layer.pre_feedforward_layernorm(h)))
        indices,weights=layer.router(h)
        h2=layer.post_feedforward_layernorm_2(layer.experts(layer.pre_feedforward_layernorm_2(h),indices,weights))
        h=h1+h2
    else:h=layer.mlp(layer.pre_feedforward_layernorm(h))
    h=residual+layer.post_feedforward_layernorm(h)
    if pli is not None:
        gate=nn.gelu_approx(layer.per_layer_input_gate(h))*pli
        h=h+layer.post_per_layer_input_norm(layer.per_layer_projection(gate))
    if layer.layer_scalar is not None:h=h*layer.layer_scalar
    return h
def mixed(ids,caches):
    hs=[body.embed_tokens(a)*body.embed_scale for a in ids]
    plis=[body._project_per_layer_inputs(h,body._get_per_layer_inputs(a,body.embed_tokens(a)))
          if body.hidden_size_per_layer_input else None for a,h in zip(ids,hs)]
    padded=[c+[None]*(len(body.layers)-len(c)) for c in caches]
    masks=[body._make_masks(h,c) for h,c in zip(hs,padded)]
    shared=[[(None,None)]*len(body.layers) for _ in ids]
    for i,layer in enumerate(body.layers):
        mids=[]
        for j,h in enumerate(hs):
            kv,offset=shared[j][body.previous_kvs[i]]
            attn,kv,offset=layer.self_attn(layer.input_layernorm(h),masks[j][i],padded[j][i],shared_kv=kv,offset=offset)
            mids.append(h+layer.post_attention_layernorm(attn));shared[j][i]=(kv,offset)
        joined=mx.concatenate([h.reshape(1,-1,h.shape[-1]) for h in mids],axis=1)
        pli=mx.concatenate([p[:,:,i,:].reshape(1,-1,p.shape[-1]) for p in plis],axis=1) if plis[0] is not None else None
        out=feed_forward(layer,joined,pli)
        pos=0;hs=[]
        for h in mids:
            end=pos+h.shape[0]*h.shape[1]
            hs.append(out[:,pos:end,:].reshape(h.shape));pos=end
    return [body.norm(h) for h in hs]
runs=[]
for batches,bits in [([1,1],None),([2,2],None),([1,1],4),([2,2],4),([1,3],4)]:
    caches=[make_prompt_cache(model),make_prompt_cache(model)]
    for row,c in enumerate(caches):
        prefix=mx.array([[1+row*32+b*8+t for t in range(8)] for b in range(batches[row])])
        model(prefix,cache=c);mx.eval([layer.state for layer in c])
    if bits is not None:
        caches=[[c.to_quantized(group_size=64,bits=bits) for c in cache] for cache in caches]
        mx.eval([layer.state for cache in caches for layer in cache])
    for length in [17,31,1]:
        ids=[mx.array([[11+b] for b in range(batches[0])]),mx.array([[101+b+t for t in range(length)] for b in range(batches[1])])]
        hs=mixed(ids,caches);mx.eval(hs,[layer.state for c in caches for layer in c])
        runs.append([digest(h) for h in hs])
print(json.dumps(runs))
`;

test.skipIf(!artifact)("mixed decode/prefill matches the pinned packed oracle through bf16/KV4 cache continuation at B1 and B2", async () => {
  const ref = spawnSync(ORACLE_PYTHON, ["-c", oracle, artifact!], { encoding: "utf8", maxBuffer: 8 * 1024 * 1024 });
  expect(ref.status, ref.stderr).toBe(0);
  const reference: string[][] = JSON.parse(ref.stdout);
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { Gemma4Model } = await import("../../src/model/gemma4");
  const { Dtype, clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { evalCacheState } = await import("../../src/backends/mlx/prefill");
  const { configureRuntime } = await import("../../src/runtime-config");
  // Uniform KV4 serving uses stock quantized SDPA for both query lengths.
  const restoreRuntime = configureRuntime({ MLX_BUN_NO_FUSED_SDPA: "1" });
  const weights = await Weights.open(artifact!);
  try {
    const model = createModel(weights, await loadModelConfig(artifact!));
    expect(model).toBeInstanceOf(Gemma4Model);
    const gemma = model as InstanceType<typeof Gemma4Model>;
    let index = 0;
    for (const [batches, bits] of [[[1, 1], undefined], [[2, 2], undefined], [[1, 1], 4], [[2, 2], 4], [[1, 3], 4]] as const) {
      const caches = [model.makeCache(), model.makeCache()];
      try {
        for (const [row, cache] of caches.entries()) {
          const batch = batches[row]!;
          using ids = ops.fromInt32(Array.from({ length: batch }, (_, b) =>
            Array.from({ length: 8 }, (_, t) => 1 + row * 32 + b * 8 + t)).flat(), [batch, 8]);
          using hidden = model.forwardHidden(ids, cache); evalCacheState(cache);
        }
        if (bits) for (const cache of caches) createKvMaintenance({ kvBits: bits, quantizedKvStart: 0 })(cache);
        for (const length of [17, 31, 1]) {
          using decode = ops.fromInt32(Array.from({ length: batches[0] }, (_, b) => 11 + b), [batches[0], 1]);
          using prefill = ops.fromInt32(Array.from({ length: batches[1] }, (_, b) =>
            Array.from({ length }, (_, t) => 101 + b + t)).flat(), [batches[1], length]);
          const hidden = gemma.forwardHiddenMixed([{ ids: decode, cache: caches[0]! }, { ids: prefill, cache: caches[1]! }]);
          try {
            const digests = hidden.map(h => {
              using f32 = h.astype(Dtype.float32); using contiguous = ops.contiguous(f32);
              return createHash("sha256").update(contiguous.rawBytesView()).digest("hex");
            });
            expect(digests, `batches ${batches}, KV ${bits ?? "bf16"}, prefill ${length}`).toEqual(reference[index++]!);
            for (const cache of caches) evalCacheState(cache);
          } finally { for (const h of hidden) h.dispose(); }
        }
      } finally { for (const cache of caches.flat()) cache.dispose(); }
    }
  } finally { weights.dispose(); clearCache(); restoreRuntime(); }
}, 300_000);
