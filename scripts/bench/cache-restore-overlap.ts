/** Read-side counterpart to the CPU persistence overlap probe.
 * Fixed generated tokens, an unrelated durable snapshot, and identical cache
 * codecs. Measures synchronous restore versus CPU-worker restore during decode. */
import { ptr, toArrayBuffer } from "bun:ffi";
import { mkdtempSync,rmSync,mkdirSync,writeFileSync } from "node:fs";
import { tmpdir,hostname,cpus } from "node:os";
import { join,dirname } from "node:path";
import { Weights } from "../../src/weights";
import { loadModelConfig } from "../../src/config";
import { createModel } from "../../src/model/factory";
import { QwenMtpProvider } from "../../src/spec/qwen-mtp-source";
import { bindSpeculativeGroupRequests } from "../../src/backends/mlx/speculative-group";
import { MlxBatchExecutionGroup } from "../../src/backends/mlx/batch-group";
import { MlxArray } from "../../src/mlx/array";
import { Dtype,clearCache } from "../../src/mlx/ffi";
import { SSMCache } from "../../src/model/qwen3-delta";
import { HostBuffer } from "../../src/storage/host-buffer";
import { saveKvCacheAsync,loadKvCache,loadKvCacheAsync,type LoadedKvCache } from "../../src/kv-store";
import { disposeResources } from "../../src/engine/resources";
import { makeStepSampler } from "../../src/sampler";
import { createRowSampling } from "../../src/backends/mlx/row-sampling";
const arg=(name:string,fallback="")=>process.argv.includes(name)?process.argv[process.argv.indexOf(name)+1]!:fallback;
const modelPath=arg("--model"),draftPath=arg("--draft"),mib=Number(arg("--mib","256")),count=Number(arg("--tokens","128"));
const directory=mkdtempSync(join(tmpdir(),"cache-restore-overlap-")),path=join(directory,"snapshot.mlxkv");
const blob=new SSMCache();
using memory=new HostBuffer(mib*2**20);
new Uint8Array(toArrayBuffer(memory.pointer as ReturnType<typeof ptr>,0,memory.bytes)).fill(37);
blob.conv=MlxArray.adoptHostBuffer(memory,[1,1,mib*2**18,1],Dtype.float32);
blob.recurrent=MlxArray.fromFloat32(new Float32Array([1]),[1]);blob.offset=1;
await saveKvCacheAsync(path,[1],[blob]);blob.dispose();
const codecModel={makeCache:()=>[new SSMCache()]};
const warm=await loadKvCacheAsync(path,codecModel);disposeResources(warm.caches);
const weights=await Weights.open(modelPath),model=createModel(weights,await loadModelConfig(modelPath));
const provider=draftPath?await QwenMtpProvider.load(draftPath):undefined;
const options={temperature:0,seed:42,kvBits:4,kvGroupSize:64,quantizedKvStart:0};
const promptIds=[1,2,3,4,5,6,7,8];
const results:Array<Record<string,unknown>>=[];
let expected:number[]|undefined;
try{
 for(const mode of ["warm","sync","async","async","sync"] as const){
  // Warm file pages and the synchronous allocation path before each arm.
  // Loading model weights can evict the setup read from the filesystem cache.
  const ioWarm = loadKvCache(path, codecModel); disposeResources(ioWarm.caches);
  const group=new MlxBatchExecutionGroup(model,{maxBatch:8});
  const tokens:number[]=[],arrivals:number[]=[];
  let reading:Promise<LoadedKvCache>|undefined,loaded:LoadedKvCache|undefined,readStart=0,readEnd=0,completedAtToken=0;
  const onToken=(token:number)=>{
    tokens.push(token);arrivals.push(performance.now());
    if(tokens.length===16 && mode!=="warm"){
      readStart=performance.now();
      if(mode==="sync"){loaded=loadKvCache(path,codecModel);readEnd=performance.now();completedAtToken=tokens.length;}
      else reading=loadKvCacheAsync(path,codecModel).then(value=>{readEnd=performance.now();completedAtToken=tokens.length;return value;});
    }
  };
  const sampling=provider?undefined:createRowSampling(makeStepSampler(options,{tokenRepresentation:"device",grammarWait:"external",historyUpdate:"after-sample",initialHistory:promptIds}),onToken);
  try{
    const start=performance.now();
    const stats=await group.submit({promptIds,maxTokens:count,eosTokenIds:[],compiledDecode:false,
      ...(provider?{method:bindSpeculativeGroupRequests(model,provider,2)(options),onToken}:{sample:sampling!.sample,plainGreedy:sampling!.plainGreedy,onToken:sampling!.onToken})});
    const decodeFinished=performance.now();
    if(reading)loaded=await reading;
    if(expected&&JSON.stringify(tokens)!==JSON.stringify(expected))throw new Error("restore changed generated token IDs");expected??=tokens;
    const gaps=arrivals.slice(1).map((time,index)=>time-arrivals[index]!).sort((a,b)=>a-b);
    if(mode!=="warm") results.push({mode,generated:tokens.length,outputHash:Bun.hash(JSON.stringify(tokens)).toString(16),
      wallMs:decodeFinished-start,decodeMs:stats.decodeMs,decodeTps:(tokens.length-1)/stats.decodeMs*1000,
      readMs:readEnd-readStart,completedAtToken,maxTokenGapMs:Math.max(...gaps),p95TokenGapMs:gaps[Math.floor(gaps.length*0.95)],
      readBoundaryGapMs:arrivals[16]!-arrivals[15]!,totalWithReadMs:performance.now()-start});
  }finally{await group.close();sampling?.dispose();if(reading&&!loaded)loaded=await reading;disposeResources(loaded?.caches??[]);}
 }
 const report={machine:hostname(),cpu:cpus()[0]?.model,bun:Bun.version,modelPath,draftPath,mib,
  settings:{...options,maxBatch:8,actualBatch:1,mtp:provider?2:0},
  workload:"ABBA; restore an unrelated immutable recurrent checkpoint at output token 16; same greedy IDs required",results};
 const output=arg("--output");if(output){mkdirSync(dirname(output),{recursive:true});writeFileSync(output,JSON.stringify(report,null,2));}
 console.log(JSON.stringify(report,null,2));
}finally{provider?.dispose();weights.dispose();clearCache();rmSync(directory,{recursive:true,force:true});}
