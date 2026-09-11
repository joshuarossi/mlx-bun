import { expect, test } from "bun:test";
import { createHash } from "node:crypto";

const artifact = Bun.env.MLX_BUN_TEST_DEEPSPEC_DRAFT;
const control = Bun.env.MLX_BUN_TEST_DEEPSPEC_CONTROL;
const probe = String.raw`
const root=process.argv[1], artifact=process.argv[2];
const {DeepspecDrafter}=await import(root+'/src/spec/dspark/deepspec-module.ts');
const {MlxArray}=await import(root+'/src/mlx/array.ts');
const {Dtype}=await import(root+'/src/mlx/ffi.ts');
const {createHash}=await import('node:crypto');
const d=await DeepspecDrafter.load(artifact), outputs=[];
try { for(const length of [3,11]) {
 const width=d.tapLayers.length*d.hidden;
 const input=MlxArray.fromFloat32(Float32Array.from({length:length*width},(_,i)=>((i+19)%97-48)/64),[1,length,width]);
 const hidden=input.astype(Dtype.bfloat16); input.dispose();
 const context=d.projectContext(hidden); hidden.dispose();
 const kv=d.projectContextKV(context,Array.from({length},(_,i)=>i)); context.dispose();
 try { for(const threshold of [0,0.5,1]) {
  d.cfg.confidence_threshold=threshold;
  const result=d.draftBlock(kv,7,length);
  try { outputs.push({length,threshold,tokens:result.tokens,conf:result.conf,hash:createHash('sha256').update(result.baseLogits.rawBytesView()).digest('hex')}); }
  finally {result.baseLogits.dispose();}
 }} finally {for(const {k,v} of kv){k.dispose();v.dispose();}}
}} finally {d.dispose();}
console.log(JSON.stringify(outputs));
`;

test.skipIf(!artifact || !control)("DeepSpec B1 graph preserves the frozen implementation's full logits and confidence", () => {
  // Separate child processes prevent paired weight residency and global MLX
  // configuration from contaminating either implementation.
  const run = (root: string) => {
    const child = Bun.spawnSync([process.execPath,"-e",probe,root,artifact!], {env:process.env,maxBuffer:4*1024*1024});
    expect(child.exitCode,child.stderr.toString()).toBe(0);
    return JSON.parse(child.stdout.toString());
  };
  expect(run(`${import.meta.dir}/../..`)).toEqual(run(control!));
},120000);

test.skipIf(!artifact)("DeepSpec graph repeats exactly at B2/B4 with independent positions", async () => {
  const { DeepspecDrafter, plainDeepspecContext } = await import("../../src/spec/dspark/deepspec-module");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const drafter = await DeepspecDrafter.load(artifact!);
  try {
    for (const B of [2,4]) {
      const width=drafter.tapLayers.length*drafter.hidden;
      using raw=MlxArray.fromFloat32(Float32Array.from({length:B*3*width},(_,i)=>((i+13)%97-48)/64),[B,3,width]);
      using hidden=raw.astype(Dtype.bfloat16);
      using projected=drafter.projectContext(hidden);
      using positions=ops.fromInt32(Array.from({length:B},(_,row)=>row*7),[B]);
      const kv=drafter.projectContextKVRows(projected,positions);
      try {
        using next=ops.fromInt32(Array.from({length:B},(_,row)=>row*7+3),[B]);
        const anchors=Array.from({length:B},(_,row)=>7+row);
        const run=() => {
          const result=drafter.draftRows(plainDeepspecContext(kv),anchors,next,true);
          try {
            expect(result.baseLogits!.shape).toEqual([B,drafter.gamma,drafter.cfg.vocab_size]);
            return {tokens:result.tokens,conf:result.conf,hash:createHash("sha256").update(result.baseLogits!.rawBytesView()).digest("hex")};
          } finally {result.baseLogits!.dispose();}
        };
        expect(run()).toEqual(run());
      } finally {for(const {k,v} of kv){k.dispose();v.dispose();}}
    }
  } finally {drafter.dispose();}
},120000);
