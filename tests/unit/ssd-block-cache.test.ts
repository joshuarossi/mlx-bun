import { expect,test } from "bun:test";
import { mkdtempSync,rmSync,readdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "../../src/mlx/array";
import { KVCache } from "../../src/model/gemma4-base";
import { SSMCache } from "../../src/model/qwen3-delta";
import { SsdCacheStore } from "../../src/ssd-cache";
import { kvWriter } from "../../src/storage/kv-writer";
import { disposeResources } from "../../src/engine/resources";
function caches(offset:number){
  const kv=new KVCache(),ssm=new SSMCache();
  const values=()=>MlxArray.fromFloat32(Float32Array.from({length:2*16*64},(_,i)=>Math.sin(i)),[1,2,16,64]);
  kv.restoreState(values(),values(),offset);
  ssm.conv=MlxArray.fromFloat32(new Float32Array([offset,2]),[1,2]);
  ssm.recurrent=MlxArray.fromFloat32(new Float32Array([3,offset]),[1,2]);ssm.offset=offset;
  return [kv,ssm];
}
test("SSD shared blocks survive restart and ancestor removal with exact recurrent checkpoints",async()=>{
 const dir=mkdtempSync(join(tmpdir(),"ssd-shared-"));
 const opts={dir,maxBytes:Infinity,configFingerprint:"model",tokenizerHash:"vocab",modelId:"test",
   storage:{layout:"blocks" as const,blockBytes:512},verify:true};
 const store=new SsdCacheStore(opts),a=caches(4),b=caches(6);
 try{
  expect(await store.storeAsync([1,2,3,4],a)).toBe(true);
  expect(await store.storeAsync([1,2,3,4,5,6],b)).toBe(true);
  expect(store.entries).toBe(2);
  const restart=new SsdCacheStore(opts);expect(restart.scan()).toBe(2);expect(restart.totalBytes).toBe(store.totalBytes);
  const first=restart.find([1,2,3,4,9])!,second=restart.find([1,2,3,4,5,6,9])!;
  expect(first.prefixLen).toBe(4);expect(second.prefixLen).toBe(6);
  expect(restart.findExact([1,2,3,4,5,6])?.entry.path).toBe(second.entry.path);
  expect(restart.findExact([1,2,3,4,5,6], "other")).toBeNull();
  restart.remove(first.entry.path);expect(restart.findExact([1,2,3,4])).toBeNull();await kvWriter.collect(join(dir,"model"));
  const loaded=await restart.restoreAsync(second.entry,{makeCache:()=>[new KVCache(),new SSMCache()]});
  expect(loaded?.tokens).toEqual([1,2,3,4,5,6]);
  expect((loaded!.caches[1] as SSMCache).conv!.toFloat32()).toEqual(new Float32Array([6,2]));
  disposeResources(loaded!.caches);
  restart.remove(second.entry.path);await kvWriter.collect(join(dir,"model"));
  expect(readdirSync(join(dir,"model","base","blocks"))).toHaveLength(0);
 }finally{disposeResources([...a,...b]);rmSync(dir,{recursive:true,force:true});}
});

test("an explicit SSD cap rejection collects newly written unreferenced blocks", async () => {
  const dir = mkdtempSync(join(tmpdir(), "ssd-block-cap-")), state = caches(4);
  const store = new SsdCacheStore({ dir, maxBytes: 1, configFingerprint: "model",
    tokenizerHash: "vocab", modelId: "test", storage: { layout: "blocks", blockBytes: 512 } });
  try {
    expect(await store.storeAsync([1, 2, 3, 4], state)).toBe(false);
    await kvWriter.collect(join(dir, "model"));
    expect(store.entries).toBe(0);
    expect(readdirSync(join(dir, "model", "base", "blocks"))).toHaveLength(0);
  } finally { disposeResources(state); rmSync(dir, { recursive: true, force: true }); }
});
