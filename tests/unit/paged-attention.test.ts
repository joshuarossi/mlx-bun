import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { PagedKVCache } from "../../src/lab/paged-kv/paged-kv";
import { pagedAttentionView } from "../../src/lab/paged-kv/paged-attention";
import { PagedKvRows } from "../../src/lab/paged-kv/paged-kv-rows";
import { disposeResources } from "../../src/engine/resources";
function values(shape: number[], dtype: Dtype, phase = 0): MlxArray {
  using source = MlxArray.fromFloat32(Float32Array.from({ length: shape.reduce((a,b)=>a*b,1) }, (_,i)=>Math.sin(i*0.31+phase)),shape);
  return source.astype(dtype);
}
function compare(actual: MlxArray, expected: MlxArray, tolerance: number) {
  const a=actual.toFloat32(), b=expected.toFloat32();
  expect(a.length).toBe(b.length);
  let maximum=0;
  for(let i=0;i<a.length;i++) maximum=Math.max(maximum,Math.abs(a[i]!-b[i]!));
  expect(maximum).toBeLessThan(tolerance);
}
test("direct paged attention reads partial blocks and grouped heads across query lengths",()=>{
  for(const dtype of [Dtype.float32,Dtype.bfloat16]) for(const n of [1,4,17]) for (const bits of [undefined,4,8] as const) {
    const cache=new PagedKVCache(512,16,true,bits ? {bits,groupSize:32} : undefined);
    try {
      using k=values([1,2,139,64],dtype), v=values([1,2,139,96],dtype,1);
      cache.append(k,v);
      using q=values([1,8,n,64],dtype,2);
      const direct=pagedAttentionView(cache.pool!,cache.blockTable,cache.offset,true);
      const oracle=pagedAttentionView(cache.pool!,cache.blockTable,cache.offset,false);
      try { using actual=direct.attend(q,0.125,{mode:n===1?"":"causal",arr:null});
        using expected=oracle.attend(q,0.125,{mode:n===1?"":"causal",arr:null});
        compare(actual,expected,dtype===Dtype.float32?1e-5:0.003); }
      finally { direct.dispose();oracle.dispose(); }
    } finally {cache.dispose();}
  }
});
test("paged row views survive append and retirement without gathered padding",()=>{
  const sources=[29,41,63,87].map(length=>{
    const cache=new PagedKVCache(256,16,true);
    using k=values([1,2,length,64],Dtype.float32), v=values([1,2,length,64],Dtype.float32,1);
    cache.append(k,v); return cache;
  });
  const rows=new PagedKvRows(256,16,true);
  try {
    rows.mergeRows(sources);
    using k=values([4,2,1,64],Dtype.float32),v=values([4,2,1,64],Dtype.float32,1);
    const view=rows.appendAndFetch(k,v);
    try {
      using q=values([4,8,1,64],Dtype.float32,2);
      using before=view.attend(q,0.125,{mode:"",arr:null}); before.eval();
      rows.filterRows([1,3]);rows.dispose();
      using after=view.attend(q,0.125,{mode:"",arr:null});compare(after,before,1e-7);
    } finally {view.dispose();}
  } finally {rows.dispose();disposeResources(sources);}
},30000);

test("encoded paged checkpoints restore through both SSD transports and grow independently",async()=>{
  const {mkdtempSync,rmSync}=await import("node:fs");
  const {tmpdir}=await import("node:os");const {join}=await import("node:path");
  const {saveKvCacheAsync,loadKvCacheAsync}=await import("../../src/kv-store");
  const dir=mkdtempSync(join(tmpdir(),"paged-ssd-"));
  try{
    for(const bits of [undefined,4,8] as const){
      const original=new PagedKVCache(16,16,true,bits?{bits,groupSize:64}:undefined);
      try{
        using k=values([1,2,16,64],Dtype.bfloat16),v=values([1,2,16,64],Dtype.bfloat16,1);
        original.append(k,v);
        for(const layout of ["whole","blocks"] as const){
          const path=join(dir,`${bits}-${layout}.mlxkv`);
          await saveKvCacheAsync(path,[...Array(16).keys()],[original],{},undefined,undefined,{layout});
          const loaded=await loadKvCacheAsync(path,{makeCache:()=>[new PagedKVCache(16,16,true)]},{verify:true});
          const restored=loaded.caches[0] as PagedKVCache;
          try{
            using q=values([1,8,1,64],Dtype.bfloat16,2);
            const before=pagedAttentionView(original.pool!,original.blockTable,16,true);
            const after=pagedAttentionView(restored.pool!,restored.blockTable,16,true);
            try{using a=before.attend(q,0.125,{mode:"",arr:null}),b=after.attend(q,0.125,{mode:"",arr:null});compare(a,b,1e-7);}
            finally{before.dispose();after.dispose();}
            using next=values([1,2,1,64],Dtype.bfloat16,3);restored.append(next,next);ops.evalAll(restored.state());
            expect(restored.offset).toBe(17);expect(original.offset).toBe(16);
          }finally{disposeResources(loaded.caches);}
        }
      }finally{original.dispose();}
    }
  }finally{rmSync(dir,{recursive:true,force:true});}
},30000);
