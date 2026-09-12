/** Fixed-shape kernel A/B; no model-speed claim. Each arm includes its KV read. */
import { cpus, hostname } from "node:os";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { PagedKVCache } from "../../src/lab/paged-kv/paged-kv";
import { pagedAttentionView } from "../../src/lab/paged-kv/paged-attention";
const output = process.argv[process.argv.indexOf("--output") + 1];
const results: object[] = [];
function values(shape: number[], phase: number) {
  using f = MlxArray.fromFloat32(Float32Array.from({ length: shape.reduce((a,b)=>a*b,1) }, (_,i)=>Math.sin(i*0.013+phase)),shape);
  return f.astype(Dtype.bfloat16).eval();
}
for (const length of [256,4096,16384]) for (const bits of [undefined,4,8] as const) {
  const cache = new PagedKVCache(length,256,true,bits?{bits,groupSize:64}:undefined);
  try {
    using k=values([1,4,length,128],0),v=values([1,4,length,128],1),q=values([1,16,1,128],2);
    cache.append(k,v);ops.evalAll(cache.state());
    const direct=pagedAttentionView(cache.pool!,cache.blockTable,length,true),gather=pagedAttentionView(cache.pool!,cache.blockTable,length,false);
    try {
      for (const view of [direct,gather]) for(let i=0;i<3;i++){using out=view.attend(q,1/Math.sqrt(128),{mode:"",arr:null});out.eval();}
      using a=direct.attend(q,1/Math.sqrt(128),{mode:"",arr:null}),b=gather.attend(q,1/Math.sqrt(128),{mode:"",arr:null});
      const av=a.toFloat32(),bv=b.toFloat32();let maxError=0;
      for(let i=0;i<av.length;i++)maxError=Math.max(maxError,Math.abs(av[i]!-bv[i]!));
      for(let sample=0;sample<5;sample++) for(const batch of [1,4]) {
        const modes=sample%2?["direct","gather"]:["gather","direct"];
        for(const mode of modes){const view=mode==="direct"?direct:gather;const start=performance.now();
          for(let i=0;i<10;i++){
            const outputs:Array<MlxArray>=[];
            try{for(let row=0;row<batch;row++)outputs.push(view.attend(q,1/Math.sqrt(128),{mode:"",arr:null}));ops.evalAll(outputs);}
            finally{for(const out of outputs)out.dispose();}
          }
          results.push({length,bits:bits??16,batch,sample,mode,msPerStep:(performance.now()-start)/10,maxError,
            gatheredKvBytes:mode==="gather"?batch*4*length*128*2*2:0});
        }
      }
    }finally{direct.dispose();gather.dispose();}
  }finally{cache.dispose();}
}
const report={machine:hostname(),cpu:cpus()[0]?.model,bun:Bun.version,
  workload:"bf16 Q; 16 query heads, 4 KV heads, D128; five paired samples of ten evaluated steps; B4 independent page views",results};
if(process.argv.includes("--output")&&output){mkdirSync(dirname(output),{recursive:true});writeFileSync(output,JSON.stringify(report,null,2));}
console.log(JSON.stringify(report,null,2));
