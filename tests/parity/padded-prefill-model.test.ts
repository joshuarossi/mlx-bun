import { test, expect } from "bun:test";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { ORACLE_VENV } from "../support/paths";
const artifact = Bun.env.MLX_BUN_TEST_PADDED_PREFILL_MODEL;
const speculativeRotatingLayout = Bun.env.MLX_BUN_TEST_SPECULATIVE_ROTATING_LAYOUT === "1";
const delayedFullLayout = Bun.env.MLX_BUN_TEST_PADDED_FULL_LAYOUT;
const delayedRotatingLayout = Bun.env.MLX_BUN_TEST_PADDED_ROTATING_LAYOUT === "1";
const oracle = String.raw`
import sys,json,hashlib,os
import numpy as np
from optiq.mlx_lm_patches._register import register
register()
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache, BatchKVCache, BatchRotatingKVCache, RotatingKVCache, ArraysCache
model,_=load(sys.argv[1])
sequences=[[1,101,201,301,401,501,601],[1,111,211,311,411,511,611,711,811,911,1011],[1,121,221,321,421]]
runs=[]
def digest(a):return hashlib.sha256(np.asarray(a.astype(mx.float32)).tobytes()).hexdigest()
# Public mlx-lm dispatch rejects singleton right-padded chunks. Reuse its
# existing concat operation and the first query of its block mask for those.
class PaddedRotating(BatchRotatingKVCache):
    def update_and_fetch(self,k,v):
        if k.shape[2]==1 and self._lengths is not None:return self._update_concat(k,v)
        return super().update_and_fetch(k,v)
    def make_mask(self,N,window_size=None,return_array=False):
        if N==1 and self._lengths is not None:return super().make_mask(2,window_size,return_array)[...,:1,:-1]
        return super().make_mask(N,window_size,return_array)
cohorts=[sequences,[sequences[0]],[sequences[0]]*3]
if os.environ.get('MLX_BUN_TEST_PADDED_PREFILL_WIDE')=='1':cohorts += [sequences[:2],sequences+[sequences[0]],[sequences[0]]*8]
for prompts in cohorts:
    B=len(prompts); width=max(map(len,prompts))
    for side,counts in [(side,counts) for side in ['left','right'] for counts in [[width],[width//2,width-width//2-1,1],[1]*width]]:
        source=make_prompt_cache(model)
        pads=[width-len(p) for p in prompts]
        caches=[ArraysCache(len(c.cache),left_padding=pads if side=='left' else None) if isinstance(c,ArraysCache) else PaddedRotating(c.max_size,[0]*B) if isinstance(c,RotatingKVCache) else BatchKVCache([0]*B) for c in source]
        for c in caches:c.prepare(left_padding=pads if side=='left' else None,lengths=[width]*B if side=='left' else list(map(len,prompts)),right_padding=pads if side=='right' else None)
        padded=[[0]*pad+p if side=='left' else p+[0]*pad for pad,p in zip(pads,prompts)]
        last=[width-1]*B if side=='left' else [len(p)-1 for p in prompts]
        steps=[[None]*B]; start=0; states=[]
        for count in counts:
            logits=model(mx.array(padded)[:,start:start+count],cache=caches)
            for row in range(B):
                if start<=last[row]<start+count:steps[0][row]=digest(logits[row,last[row]-start])
            mx.eval([c.state for c in caches])
            states.append([[digest(a) for a in c.state] if isinstance(c,ArraysCache) else None for c in caches])
            start+=count
        for c in caches:c.finalize()
        offsets=[list(map(len,prompts)) if isinstance(c,ArraysCache) else c.offset.tolist() for c in caches]
        for step in range(3):
            logits=model(mx.array([[71+step+row] for row in range(B)]),cache=caches)
            steps.append([digest(logits[row,-1]) for row in range(B)])
        runs.append({'prompts':prompts,'side':side,'counts':counts,'states':states,'steps':steps,'offsets':offsets})
print(json.dumps(runs))
`;
test.skipIf(!artifact)("padded prompt batches and continuation match same-B model logits", async () => {
  const ref = spawnSync(`${ORACLE_VENV}/bin/python`, ["-c", oracle, artifact!], { encoding: "utf8", maxBuffer: 4 * 1024 * 1024 });
  expect(ref.status, ref.stderr).toBe(0);
  const reference = JSON.parse(ref.stdout) as { prompts: number[][]; side: string; counts: number[]; states: (string[] | null)[][]; steps: string[][]; offsets: number[][] }[];
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { RotatingKVCache } = await import("../../src/model/gemma4-base");
  const { SSMCache } = await import("../../src/model/qwen3-delta");
  const { BatchedSSMCache } = await import("../../src/model/batched-ssm");
  const { BatchedKVCache } = await import("../../src/model/batched-kv");
  const { SpeculativeRotatingKVCache } = await import("../../src/model/speculative-rotating-kv");
  const { BatchedRotatingCache } = await import("../../src/model/batched-rotating");
  const { DelayedQuantizedKVCache } = await import("../../src/model/delayed-quantized-kv");
  const { DelayedTurboQuantKVCache } = await import("../../src/model/delayed-turboquant-kv");
  const { DelayedRotatingQuantizedKVCache } = await import("../../src/model/delayed-rotating-quantized-kv");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype, clearCache } = await import("../../src/mlx/ffi");
  const weights = await Weights.open(artifact!), model = createModel(weights, await loadModelConfig(artifact!));
  try {
    for (const expected of reference) {
      const prompts=expected.prompts, B=prompts.length, width=Math.max(...prompts.map(p=>p.length)), pads=prompts.map(p=>width-p.length);
      const source=model.makeCache();
      // This mode checks the delayed layout's padded model execution before
      // conversion. Mixed-precision attention/state has its separate geometry
      // gate; the live model oracle here retains its plain KV representation.
      const caches=source.map(c=>c instanceof SSMCache ? new BatchedSSMCache() : c instanceof RotatingKVCache
        ? speculativeRotatingLayout ? new SpeculativeRotatingKVCache(c.maxSize) : delayedRotatingLayout ? new DelayedRotatingQuantizedKVCache(c.maxSize,64,4,Infinity,
          createKvMaintenance({kvBits:4,kvGroupSize:64,quantizedKvStart:Infinity}))
          : new BatchedRotatingCache(c.maxSize,Array(B).fill(0))
          : delayedFullLayout === "affine" ? new DelayedQuantizedKVCache(64,4,Infinity,
            createKvMaintenance({kvBits:4,kvGroupSize:64,quantizedKvStart:Infinity}))
          : delayedFullLayout === "turbo" ? new DelayedTurboQuantKVCache(8,3,Infinity,
            createKvMaintenance({turboQuant:{kBits:8,vBits:3},quantizedKvStart:Infinity})) : new BatchedKVCache());
      for(const c of source)c.dispose();
      try {
        for(const c of caches)c.preparePrefill({lengths:expected.side==='left'?Array(B).fill(width):prompts.map(p=>p.length),
          ...(expected.side==='left'?{leftPadding:pads}:{rightPadding:pads})});
        const inputs=prompts.map((p,row)=>expected.side==='left'?[...Array(pads[row]).fill(0),...p]:[...p,...Array(pads[row]).fill(0)]);
        let start=0;
        const { evalCacheState } = await import("../../src/backends/mlx/prefill");
        const last=prompts.map((p)=>expected.side==='left'?width-1:p.length-1);
        const check = (logits: InstanceType<typeof MlxArray>, row: number, position: number, step: number) => {
          using slice=logits.slice([row,position,0],[row+1,position+1,logits.shape[2]!]);
          using f32=slice.astype(Dtype.float32);
          expect(createHash('sha256').update(f32.rawBytesView()).digest('hex'),`${expected.side} chunks ${expected.counts} step ${step} row ${row}`).toBe(expected.steps[step]![row]!);
        };
        for(const [chunk,count] of expected.counts.entries()) {
          using ids=MlxArray.fromInt32(Int32Array.from(inputs.flatMap(row=>row.slice(start,start+count))),[B,count]);
          using hidden=model.forwardHidden(ids,caches), logits=model.logitsFromHidden(hidden);
          for(let row=0;row<B;row++)if(start<=last[row]! && last[row]!<start+count)check(logits,row,last[row]!-start,0);
          evalCacheState(caches);
          for (const [layer,c] of caches.entries()) if (c instanceof SSMCache) {
            const hashes = c.state().map(a=>{
              using f32=a.astype(Dtype.float32);
              return createHash('sha256').update(f32.rawBytesView()).digest('hex');
            });
            expect(hashes,`${expected.side} chunk ${chunk} layer ${layer} recurrent/conv state`).toEqual(expected.states[chunk]![layer]!);
          }
          for(const c of caches)if('releaseRopeArr' in c)c.releaseRopeArr();
          start+=count;
        }
        for(const c of caches)c.finalizePrefill();
        expect(caches.map(c=>'rowOffsets' in c?c.rowOffsets:c.offsetArr)).toEqual(expected.offsets);
        for(let step=1;step<4;step++) {
          using ids=MlxArray.fromInt32(Int32Array.from(prompts.map((_,row)=>70+step+row)),[B,1]);
          using hidden=model.forwardHidden(ids,caches), logits=model.logitsFromHidden(hidden);
          for(let row=0;row<B;row++)check(logits,row,0,step);
          for(const c of caches)if('releaseRopeArr' in c)c.releaseRopeArr();
        }
      } finally {for(const c of caches)c.dispose();clearCache();}
    }
  } finally {weights.dispose();clearCache();}
},300_000);
