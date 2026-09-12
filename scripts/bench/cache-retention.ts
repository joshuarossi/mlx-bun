/** Metadata-only RAM policy replay. SSD is durable and unlimited in every arm.
 * A RAM miss measures restore traffic, not recomputation of a durable prefix. */
import { readFileSync,writeFileSync,mkdirSync } from "node:fs";
import { dirname } from "node:path";
import { CostSizeRetention,LruRetention,type RetentionPolicy,type RetentionCandidate } from "../../src/storage/retention-policy";
export type RetentionEvent = { kind:"put"|"get"; id:number; bytes:number; tokens:number };
export function replayRetention(policy:RetentionPolicy,events:readonly RetentionEvent[],budget:number){
 type Entry=RetentionCandidate&{id:number};
 const ram=new Map<number,Entry>(),disk=new Map<number,RetentionEvent>();
 let clock=0,ramHits=0,ssdRestores=0,coldMisses=0,restoredBytes=0,ramHitTokens=0,prefillTokens=0,resident=0,peak=0;
 const trim=()=>{while(resident>budget){const victim=policy.victim([...ram.values()]);policy.evicted(victim);ram.delete(victim.id);resident-=victim.bytes;}};
 const put=(event:RetentionEvent)=>{
   resident-=ram.get(event.id)?.bytes??0;
   const entry:Entry={id:event.id,bytes:event.bytes,cost:event.tokens,lastUsed:++clock,uses:1,priority:0};
   policy.accessed(entry);ram.set(event.id,entry);resident+=entry.bytes;trim();peak=Math.max(peak,resident);
 };
 for(const event of events){
   if(event.kind==="put"){disk.set(event.id,event);put(event);continue;}
   const entry=ram.get(event.id);
   if(entry){ramHits++;ramHitTokens+=event.tokens;entry.cost=event.tokens;entry.uses++;entry.lastUsed=++clock;policy.accessed(entry);}
   else if(disk.has(event.id)){ssdRestores++;restoredBytes+=event.bytes;put(event);}
   else{coldMisses++;prefillTokens+=event.tokens;disk.set(event.id,event);put(event);}
 }
 return {policy:policy.name,events:events.length,budget,ramHits,ssdRestores,coldMisses,restoredBytes,ramHitTokens,prefillTokens,peakResident:peak};
}
if(import.meta.main){
 const arg=(name:string,fallback:string)=>process.argv.includes(name)?process.argv[process.argv.indexOf(name)+1]!:fallback;
 const traces:Array<{name:string;events:RetentionEvent[];budget:number;units:string}>=[];
 const synthetic=(ids:number[],name:string)=>traces.push({name,budget:32,units:"synthetic storage units",events:ids.map(id=>({kind:"get",id,bytes:id<4?4:24,tokens:id<4?4096:8192}))});
 synthetic(Array.from({length:200},(_,i)=>[0,1,2,3,100+i]).flat(),"hot prefixes interleaved with one-shot histories");
 synthetic(Array.from({length:200},(_,i)=>Array(4).fill(100+i)).flat(),"sequential bursts");
 synthetic(Array.from({length:200},(_,i)=>[100+i,100+i,0]).flat(),"large active history and small shared prefix");
 const kanban=arg("--kanban","");
 if(kanban){
   const result=JSON.parse(readFileSync(kanban,"utf8"));
   for(const budget of [80000,160000,320000]){
     const events:RetentionEvent[]=[];
     for(const [index,request] of result.requests.entries()){
       const cached=request.usage?.prompt_tokens_details?.cached_tokens??0;
       if(cached)events.push({kind:"get",id:cached,bytes:cached+16384,tokens:cached});
       const next=result.requests[index+1]?.usage?.prompt_tokens_details?.cached_tokens;
       if(next)events.push({kind:"put",id:next,bytes:next+16384,tokens:next});
     }
     traces.push({name:"saved Kanban observed continuation boundaries",events,budget,
       units:"token-equivalent residency: prefix length + 16384 fixed recurrent-state units; not physical RAM bytes"});
   }
 }
 const report={kind:"RAM retention metadata replay",kanban:kanban||undefined,
   notes:"Kanban publishes observed next-turn checkpoint boundaries. Native tests separately establish token/state correctness. Cold cache misses prefill; durable misses restore from SSD.",
   traces:traces.map(trace=>({name:trace.name,units:trace.units,results:[replayRetention(new LruRetention(),trace.events,trace.budget),replayRetention(new CostSizeRetention(),trace.events,trace.budget)]}))};
 const output=arg("--output","");if(output){mkdirSync(dirname(output),{recursive:true});writeFileSync(output,JSON.stringify(report,null,2));}
 console.log(JSON.stringify(report,null,2));
}
