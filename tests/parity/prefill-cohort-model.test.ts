import { test, expect } from "bun:test";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { ORACLE_VENV } from "../support/paths";
import type { Row } from "../../src/backends/mlx/batch-group";
const artifact = Bun.env.MLX_BUN_TEST_COHORT_MODEL;
const oracle = String.raw`
import sys,json,hashlib
import numpy as np
from optiq.mlx_lm_patches._register import register
register()
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache, BatchKVCache, BatchRotatingKVCache, RotatingKVCache, ArraysCache
model,_=load(sys.argv[1])
prompts=[[1]+list(range(101,112)),[2]+list(range(201,211)),[3]+list(range(301,307))]
def digest(a):return hashlib.sha256(np.asarray(a.astype(mx.float32)).tobytes()).hexdigest()
def merge(rows):
    return [(ArraysCache if isinstance(cs[0],ArraysCache) else BatchRotatingKVCache if isinstance(cs[0],RotatingKVCache) else BatchKVCache).merge(cs) for cs in zip(*rows)]
cache=make_prompt_cache(model); members=[0]; positions=[0,0,0]; batched=False; runs=[]; finished={}; first_logits={}
# Chunk schedule is fixed independently of the implementation under test.
# Join after first/second chunks; retire each completed row as soon as ready.
for add,count in [(None,4),(1,3),(2,1),(None,1),(None,1),(None,1),(None,1),(None,1),(None,1),(None,1)]:
    if add is not None:
        rows=[[c.extract(i) for c in cache] for i in range(len(members))] if batched else [cache]
        rows.append(make_prompt_cache(model)); cache=merge(rows); members.append(add);batched=True
    ids=[prompts[i][positions[i]:positions[i]+count] for i in members]
    assert all(len(p)==count for p in ids),(members,positions,count)
    logits=model(mx.array(ids),cache=cache)
    mx.eval(logits,[c.state for c in cache])
    states=[[digest(a) for a in c.state] if isinstance(c,ArraysCache) else None for c in cache]
    runs.append({'ids':ids,'logits':digest(logits),'states':states})
    for i in members:positions[i]+=count
    keep=[]
    for row,i in enumerate(members):
        if positions[i]==len(prompts[i]):
            finished[i]=[c.extract(row) for c in cache] if batched else cache
            first_logits[i]=digest(logits[row,-1])
        else:keep.append(row)
    if len(keep)!=len(members) and keep:
        for c in cache:c.filter(mx.array(keep))
    members=[members[i] for i in keep]
assert not members
continuations=[]
for i in range(3):
    logits=model(mx.array([[51+i]]),cache=finished[i]);continuations.append(digest(logits))
print(json.dumps({'runs':runs,'continuations':continuations,'first_logits':[first_logits[i] for i in range(3)]}))
`;
test.skipIf(!artifact)("staggered serving prefill matches the pinned same-B model through joins, retirement and continuation", async () => {
  const ref = spawnSync(`${ORACLE_VENV}/bin/python`, ["-c", oracle, artifact!], { encoding: "utf8", maxBuffer: 8 * 1024 * 1024 });
  expect(ref.status, ref.stderr).toBe(0);
  const reference = JSON.parse(ref.stdout) as { runs: { ids: number[][]; logits: string; states: (string[] | null)[] }[]; continuations: string[]; first_logits: string[] };
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { MlxPrefillCohort } = await import("../../src/backends/mlx/prefill-cohort");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype, clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const { evalCacheState } = await import("../../src/backends/mlx/prefill");
  const { SSMCache } = await import("../../src/model/qwen3-delta");
  type Cache = import("../../src/model/gemma4-base").Cache;
  const weights = await Weights.open(artifact!), model = createModel(weights, await loadModelConfig(artifact!));
  const finished = new Map<number, Cache[]>(), failures: unknown[] = [];
  const digest = (array: InstanceType<typeof MlxArray>) => {
    using f32 = array.astype(Dtype.float32);
    using contiguous = ops.contiguous(f32);
    return createHash("sha256").update(contiguous.rawBytesView()).digest("hex");
  };
  const prompts = [[1,...Array.from({length:11},(_,i)=>101+i)], [2,...Array.from({length:10},(_,i)=>201+i)], [3,...Array.from({length:6},(_,i)=>301+i)]];
  let step = 0;
  const cohort = new MlxPrefillCohort({ model, chunkSize: 4, tailSplit: true,
    async forward(ids, caches) {
      const expected = reference.runs[step++]!;
      expect(ids.toIntTokens(),`step ${step} tokens`).toEqual(expected.ids.flat());
      expect(ids.shape,`step ${step} shape`).toEqual([expected.ids.length,expected.ids[0]!.length]);
      const hidden = model.forwardHidden(ids,caches);
      try {
        using logits=model.logitsFromHidden(hidden);
        expect(digest(logits),`step ${step} full logits`).toBe(expected.logits);
        evalCacheState(caches);
        for(const [layer,cache] of caches.entries()) if(cache instanceof SSMCache)
          expect(cache.state().map(digest),`step ${step} layer ${layer} recurrent state`).toEqual(expected.states[layer]!);
        return hidden;
      } catch(error) {hidden.dispose();throw error;}
    },
    project(hidden) { return model.logitsFromHidden(hidden); },
    async complete(state, logits) {
      const row = state.row.req.promptIds[0]!-1;
      expect(digest(logits),`row ${row} token-zero sampler logits`).toBe(reference.first_logits[row]!);
      finished.set(row,state.solo);
    },
    reject(_row,error){failures.push(error);},
  });
  const request=(index:number):Row=>({req:{promptIds:prompts[index]!,prefillChunkSize:4-index,maxTokens:1,eosTokenIds:[],sample:logits=>ops.argmaxAxis(logits,-1),onToken(){}},
    resolve(){},reject(){},current:0,generated:0,sampled:0,promptTokens:prompts[index]!.length,cachedTokens:0,admittedAt:0,firstTokenAt:0,fed:[],fedTainted:false,merged:false});
  try {
    cohort.admit(request(0));expect(await cohort.advance()).toBe(false);
    cohort.admit(request(1));expect(await cohort.advance()).toBe(false);
    cohort.admit(request(2));
    for(let tick=0;tick<20;tick++)if(await cohort.advance())break;
    expect(cohort.rows).toHaveLength(0);expect(failures).toEqual([]);expect(step).toBe(reference.runs.length);
    for(let row=0;row<3;row++){
      using ids=MlxArray.fromInt32(Int32Array.of(51+row),[1,1]);
      using hidden=model.forwardHidden(ids,finished.get(row)!);
      using logits=model.logitsFromHidden(hidden);
      expect(digest(logits),`row ${row} restored continuation`).toBe(reference.continuations[row]!);
    }
  } finally {cohort.dispose();for(const caches of finished.values())for(const cache of caches)cache.dispose();weights.dispose();clearCache();}
},300_000);
