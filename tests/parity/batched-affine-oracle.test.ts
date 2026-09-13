import { expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { createHash } from "node:crypto";
import { ORACLE_PYTHON } from "../support/paths";

const artifact = Bun.env.MLX_BUN_TEST_BATCH_AFFINE_MODEL ??
  `${Bun.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78`;
const enabled = Bun.env.MLX_BUN_TEST_BATCH_AFFINE_ORACLE === "1" && existsSync(`${artifact}/config.json`);
const padded = Bun.env.MLX_BUN_TEST_BATCH_AFFINE_PADDING === "1";
// Equal-length rows let stock KVCache/QuantizedKVCache carry the same B-wide
// tensors and scalar position as the unpadded production row layouts. No
// native result values are supplied to the reference. Padding is a separate gate.
const reference = String.raw`
import hashlib,json,sys
import numpy as np
from optiq.mlx_lm_patches._register import register
register()
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache, BatchKVCache, QuantizedKVCache
from mlx_lm.models.base import create_causal_mask
import mlx_lm.models.base as attention_base
# The stock quantized GQA helper groups scores as [B,KV,G,L,N], but its
# padding mask stays [B,1,L,N]. Add only the missing broadcast axis; leave
# all attention arithmetic in the pinned helper. bf16 layers retain rank 4.
stock_quantized_attention=attention_base.quantized_scaled_dot_product_attention
def padded_quantized_attention(queries,q_keys,q_values,scale,mask,group_size,bits):
    if queries.shape[1]>q_keys[0].shape[-3] and mask is not None and not isinstance(mask,str) and mask.ndim==4:
        mask=mx.expand_dims(mask,axis=1)
    return stock_quantized_attention(queries,q_keys,q_values,scale,mask,group_size,bits)
# Stock mlx-lm has no padded quantized batch cache. Compose its unchanged
# quantized storage with BatchKVCache's positions/mask, without importing any
# Bun state or logits. This is a composed reference, not stock server support.
class PaddedQuantized:
    def __init__(self, batch, bits):
        self.inner=QuantizedKVCache(group_size=64,bits=bits)
        self.bits=bits;self.group_size=64
        self.left_padding=batch.left_padding
        self.inner.update_and_fetch(batch.keys[:,:,:batch._idx,:],batch.values[:,:,:batch._idx,:])
    @property
    def offset(self):return self.inner.offset-self.left_padding
    @property
    def state(self):return self.inner.state
    def update_and_fetch(self,k,v):return self.inner.update_and_fetch(k,v)
    def make_mask(self,N,**kwargs):
        return create_causal_mask(N,offset=self.inner.offset,left_padding=self.left_padding)
    def filter(self,keep):
        self.left_padding=self.left_padding[mx.array(keep)]
        self.inner.keys=tuple(a[mx.array(keep)] for a in self.inner.keys)
        self.inner.values=tuple(a[mx.array(keep)] for a in self.inner.values)
plan=json.load(sys.stdin)
if any(case['padded'] for case in plan['cases']):
    attention_base.quantized_scaled_dot_product_attention=padded_quantized_attention
model,_=load(plan['model'])
results=[]
for case in plan['cases']:
    rows=list(range(case['width']))
    if case['padded']:
        donors=[]
        for row in rows:
            c=make_prompt_cache(model)
            prompt=mx.array([[100+row*11+i*7 for i in range([5,9,7,11][row])]])
            logits=model(prompt,cache=c);mx.eval(logits,[layer.state for layer in c]);donors.append(c)
        cache=[BatchKVCache.merge([c[i] for c in donors]) for i in range(len(donors[0]))]
        for i,c in enumerate(cache):
            if case['bits'][i]:cache[i]=PaddedQuantized(c,case['bits'][i])
        del donors
    else:
        cache=make_prompt_cache(model)
        prompt=mx.array([[100+row*11+i*7 for i in range(9)] for row in rows])
        logits=model(prompt,cache=cache);mx.eval(logits,[c.state for c in cache])
        for i,c in enumerate(cache):
            bits=case['bits'][i]
            if bits:cache[i]=c.to_quantized(group_size=64,bits=bits)
    hashes=[]
    for step in range(6):
        if step==3 and len(rows)>1:
            keep=[3,1];rows=[rows[i] for i in keep]
            for c in cache:
                if case['padded']:c.filter(keep)
                elif isinstance(c.keys,(tuple,list)):
                    c.keys=tuple(a[mx.array(keep)] for a in c.keys)
                    c.values=tuple(a[mx.array(keep)] for a in c.values)
                else:
                    c.keys=c.keys[mx.array(keep)];c.values=c.values[mx.array(keep)]
        ids=mx.array([[300+row*13+step] for row in rows])
        logits=model(ids,cache=cache);mx.eval(logits,[c.state for c in cache])
        hashes.append(hashlib.sha256(np.array(logits.astype(mx.float32)).tobytes()).hexdigest())
    results.append(hashes)
    del cache,logits
    mx.clear_cache()
print(json.dumps(results))
`;

test.skipIf(!enabled)(`${padded ? "unequal padded" : "equal-length"} full-attention affine rows match same-B reference through reordering and retirement`, async () => {
  const { loadModelConfig } = await import("../../src/config");
  const config = await loadModelConfig(artifact);
  expect(config.text.layerTypes.every(type => type === "full_attention")).toBe(true);
  const cases = (padded ? [4] : [1,4]).flatMap(width => (padded ? [0,4,8,"mixed"] : [4,8,"mixed"]).map(kind => ({ width, padded,
    bits: Array.from({ length: config.text.numHiddenLayers }, (_, i) =>
      kind === "mixed" ? [4,8,0][i%3]! : kind as number),
  })));
  const proc = Bun.spawn([ORACLE_PYTHON,"-c",reference], { stdin:"pipe",stdout:"pipe",stderr:"pipe" });
  const timer = setTimeout(() => proc.kill(), 180_000);
  let expected: string[][];
  try {
    proc.stdin.write(JSON.stringify({model:artifact,cases}));proc.stdin.end();
    const [stdout,stderr,code] = await Promise.all([new Response(proc.stdout).text(),new Response(proc.stderr).text(),proc.exited]);
    expect(code,stderr).toBe(0); expected=JSON.parse(stdout);
  } finally { clearTimeout(timer); }
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { MlxStateRows } = await import("../../src/backends/mlx/state-rows");
  const { targetCacheLayout } = await import("../../src/backends/mlx/cache-layout");
  const { maybeQuantizeKv } = await import("../../src/generate");
  const { evalCacheState } = await import("../../src/backends/mlx/prefill");
  const { disposeResources } = await import("../../src/engine/resources");
  const { clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const weights = await Weights.open(artifact);
  try {
    const model = createModel(weights,config);
    for (const [index,scenario] of cases.entries()) {
      let rows = Array.from({length:scenario.width},(_,i)=>i);
      const empty = rows.map(()=>model.makeCache());
      let state = new MlxStateRows(empty[0]!.map(targetCacheLayout));
      try { state.mergeRows(empty); } finally { disposeResources(empty.flat()); }
      try {
        if (padded) {
          const donors = rows.map(()=>model.makeCache());
          let next: typeof state | undefined;
          try {
            for (const row of rows) {
              const length = [5,9,7,11][row]!;
              using ids = ops.fromInt32(Array.from({length},(_,i)=>100+row*11+i*7),[1,length]);
              using hidden = model.forwardHidden(ids,donors[row]!);
              using logits = model.logitsFromHidden(hidden);logits.eval();evalCacheState(donors[row]!);
              maybeQuantizeKv(donors[row]!, { kvConfig: scenario.bits.flatMap((bits,layerIdx)=>bits?[{layerIdx,bits,groupSize:64}]:[]), quantizedKvStart:0 });
            }
            next=new MlxStateRows(donors[0]!.map(targetCacheLayout));next.mergeRows(donors);evalCacheState(next.caches);
          } catch(error) { next?.dispose();throw error; }
          finally { disposeResources(donors.flat()); }
          state.dispose();state=next;
        } else {
        {
          using ids = ops.fromInt32(rows.flatMap(row=>Array.from({length:9},(_,i)=>100+row*11+i*7)),[rows.length,9]);
          using hidden = model.forwardHidden(ids,state.caches);
          using logits = model.logitsFromHidden(hidden); logits.eval(); evalCacheState(state.caches);
        }
        const donors = rows.map(row=>state.extractRow(row));
        const kvConfig = scenario.bits.flatMap((bits,layerIdx)=>bits?[{layerIdx,bits,groupSize:64}]:[]);
        let next: typeof state | undefined;
        try {
          for(const donor of donors) maybeQuantizeKv(donor,{kvConfig,quantizedKvStart:0});
          next=new MlxStateRows(donors[0]!.map(targetCacheLayout));next.mergeRows(donors);evalCacheState(next.caches);
        } catch(error) { next?.dispose();throw error; }
        finally { disposeResources(donors.flat()); }
        state.dispose();state=next;
        }
        for(let step=0;step<6;step++) {
          if(step===3&&rows.length>1) { const keep=[3,1];state.filterRows(keep);rows=keep.map(i=>rows[i]!); }
          using ids=ops.fromInt32(rows.map(row=>300+row*13+step),[rows.length,1]);
          using hidden=model.forwardHidden(ids,state.caches);
          using logits=model.logitsFromHidden(hidden);
          expect(logits.shape[0]).toBe(rows.length);
          expect(createHash("sha256").update(logits.toFloat32()).digest("hex"),`case ${index} step ${step}`)
            .toBe(expected![index]![step]!);
        }
      } finally { state.dispose();clearCache(); }
    }
  } finally { weights.dispose(); clearCache(); }
}, 240_000);
