import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const sourceHash='27353e109e7f91bc030fbd493785fcc4839eeccea2d585c22d610ba8f9e909d0';
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');

// Trusted host extraction binds the Lean token parser to the shipped source.
// It is not a TypeScript/Metal compiler or hardware barrier proof.
export function extractTail(source:string):string{
  const raw=source.match(/const SOURCE = String.raw`([\s\S]*?)`;/)?.[1];
  if(!raw)throw new Error('Residual RMS raw kernel missing');
  const start=raw.indexOf('acc = metal::simd_sum(acc);');
  const ending='threadgroup_barrier(metal::mem_flags::mem_threadgroup | metal::mem_flags::mem_device);';
  const finish=raw.indexOf(ending,start);
  if(start<0||finish<0)throw new Error('Residual RMS reduction tail missing');
  return raw.slice(start,finish+ending.length);
}
export function checkSource(source:string,lean:string){
  if(hash(source)!==sourceHash)throw new Error('Residual RMS source SHA256 mismatch');
  const literal=lean.match(/def sourceBody : String := r#"([\s\S]*?)"#/);
  if(!literal||extractTail(source)!==literal[1])throw new Error('Parsed reduction tail body mismatch');
}
export async function checkResidualRmsTailSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  const source=await Bun.file(resolve(root,'../packages/inference/src/kernels/residual-rms-norm.ts')).text();
  const lean=await Bun.file(resolve(root,'kernels/normalization/ResidualRmsTailSyntax.lean')).text();
  checkSource(source,lean);
  if(options.selfTest){
    const mutations=[
      source.replace('acc = metal::simd_sum(acc);','acc = metal::simd_max(acc);'),
      source.replace('if (sg == 0) sums[lane] = 0.0f;','if (sg == 1) sums[lane] = 0.0f;'),
      source.replace('if (lane == 0) sums[sg] = acc;','if (lane == 0) sums[lane] = acc;'),
      source.replace('acc / float(D)','acc * float(D)'),
      source.replace('mem_threadgroup | metal::mem_flags::mem_device','mem_threadgroup'),
    ];
    for(const bad of mutations){let rejected=false;try{checkSource(bad,lean);}catch{rejected=true;}if(!rejected)throw new Error('Source mutation accepted');}
    for(const bad of [lean.replaceAll('sums[sg] = acc','sums[lane] = acc'),lean.replaceAll('acc / float(D)','acc * float(D)')]){
      let rejected=false;try{checkSource(source,bad);}catch{rejected=true;}if(!rejected)throw new Error('Lean literal mutation accepted');
    }
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  await checkResidualRmsTailSourceBinding({selfTest:process.argv.includes('--self-test')});
  console.log('Residual RMS parsed reduction tail source binding passed (host extraction boundary).');
}
