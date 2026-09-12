import { expect, test } from "bun:test";
import { PromptCache, type ColdTier } from "../../src/prompt-cache";
import type { Cache } from "../../src/model/gemma4-base";
function state(dispose = () => {}): Cache {
  return { signature:()=>"test",offset:3,state:()=>[{nbytes:8}] as never,isTrimmable:()=>false,
    updateAndFetch:()=>{throw new Error("unused");},makeMask:()=>({mode:"",arr:null}),trim(){},dispose };
}
test("prefetch coalesces IO, pins an oversized RAM donor, and releases request interest independently", async()=>{
  let finish!:()=>void,reads=0,syncReads=0,disposed=0;
  const ready=new Promise<void>(resolve=>{finish=resolve;});const handle={};
  const cold:ColdTier={find:()=>({prefixLen:3,handle}),restore:()=>{syncReads++;return null;},store:()=>true,
    async restoreAsync(){reads++;await ready;return{tokens:[1,2,3],caches:[state(()=>disposed++)],retain(){}};}};
  const cache=new PromptCache(4,null,cold,()=>[state()],()=>{});cache.canEvict=()=>true;
  const p1=cache.prefetch([1,2,3,4]),p2=cache.prefetch([1,2,3,5]);
  finish();const [release1,release2]=await Promise.all([p1,p2]);
  expect(reads).toBe(1);expect(cache.size).toBe(1);
  const hit=cache.take([1,2,3,4]);expect(hit?.tokens).toEqual([1,2,3]);expect(syncReads).toBe(0);
  release1();expect(cache.size).toBe(1);release2();expect(cache.size).toBe(0);
  expect(disposed).toBe(1);hit?.caches.forEach(c=>c.dispose());hit?.retain?.();cache.clear();
});
