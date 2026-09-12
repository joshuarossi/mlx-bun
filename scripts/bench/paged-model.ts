/** Paired complete-request paged-layout benchmark. Cache/sampling settings and
 * prompt IDs are fixed; this records output agreement without asserting L1. */
import { hostname,cpus } from "node:os";
import { mkdirSync,writeFileSync } from "node:fs";
import { dirname } from "node:path";
import { Weights } from "../../src/weights";
import { loadModelConfig } from "../../src/config";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { MlxBatchExecutionGroup } from "../../src/backends/mlx/batch-group";
import { bindPagedRequestState } from "../../src/backends/mlx/request-state-policy";
import { configureRuntime } from "../../src/runtime-config";
import * as ops from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
const arg=(name:string,fallback="")=>process.argv.includes(name)?process.argv[process.argv.indexOf(name)+1]!:fallback;
const modelPath=arg("--model"),length=Number(arg("--context","4096")),count=Number(arg("--tokens","64")),bits=Number(arg("--bits","0"));
const weights=await Weights.open(modelPath),model=createModel(weights,await loadModelConfig(modelPath));
const tokenizer=await loadTokenizer(modelPath);
const text="Explain how a cache retains reusable data and chooses which entries to move between RAM and disk. ";
const encoded=tokenizer.encode(text.repeat(Math.ceil(length/8)+20));
const results:Array<Record<string,unknown>>=[];const controls=new Map<number,string>();
try{
 for(const batch of [1,4]) for(const mode of ["gather","direct","direct","gather"] as const){
  const reset=configureRuntime({MLX_BUN_PAGED_ATTN:mode==="direct"?"1":"0"});
  let held=true;const group=new MlxBatchExecutionGroup(model,{maxBatch:8,admissionHeld:()=>held});
  const tokens:number[][]=Array.from({length:batch},()=>[]);
  try{
    const start=performance.now();
    const pending=tokens.map((out,row)=>{
      const promptIds=encoded.slice(0,length+row*17);
      return group.submit({promptIds,maxTokens:count,eosTokenIds:[],compiledDecode:false,snapshotAt:0,
        statePolicy:bindPagedRequestState(model,{pagedKv:{blockSize:256},...(bits?{kvBits:bits,kvGroupSize:64,quantizedKvStart:0}:{})},promptIds.length+count),
        sample:logits=>ops.argmaxAxis(logits,-1),onToken(token){out.push(token);}});
    });
    held=false;group.kick();const stats=await Promise.all(pending),wallMs=performance.now()-start;
    const output=JSON.stringify(tokens);if(!controls.has(batch))controls.set(batch,output);
    const reference=JSON.parse(controls.get(batch)!) as number[][];
    const agreeingTokens=tokens.map((ids,row)=>ids.filter((id,index)=>id===reference[row]![index]).length);
    results.push({batch,mode,bits,promptTokens:stats.map(s=>s.promptTokens),generated:tokens.map(t=>t.length),
      wallMs,prefillMs:stats.map(s=>s.prefillMs),decodeMs:stats.map(s=>s.decodeMs),
      decodeTps:stats.map((s,row)=>(tokens[row]!.length-1)/s.decodeMs*1000),
      outputHash:Bun.hash(output).toString(16),identicalOutput:output===controls.get(batch),agreeingTokens,
      promptHashes:tokens.map((_,row)=>Bun.hash(JSON.stringify(encoded.slice(0,length+row*17))).toString(16))});
  }finally{await group.close();reset();clearCache();}
 }
 const report={machine:hostname(),cpu:cpus()[0]?.model,bun:Bun.version,modelPath,length,count,bits,
   workload:"ABBA, greedy, independent uneven request lengths, batch cap 8; no prompt cache; gathered pages vs direct pages",results};
 const output=arg("--output");if(output){mkdirSync(dirname(output),{recursive:true});writeFileSync(output,JSON.stringify(report,null,2));}
 console.log(JSON.stringify(report,null,2));
}finally{weights.dispose();clearCache();}
