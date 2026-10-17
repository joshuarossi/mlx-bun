import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const sourceHash='b2e04e377fdad1d645581f9beeaf9cbb06d1ad32926161e06cbc15240caf12bf';
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');
export function extractCells(source:string):string[]{
  const start=source.indexOf('[[kernel]] void rms_looped(');
  const end=source.indexOf('acc = simd_sum(acc);',start);
  if(start<0||end<0)throw new Error('MLX RMS first-pass boundaries missing');
  const cells=[...source.slice(start,end).matchAll(/float xi = [^;]*;\s*acc \+= [^;]*;/g)].map(match=>match[0]);
  if(cells.length!==2)throw new Error('Expected both MLX RMS reduction cells');
  return cells;
}
export function checkExtracted(source:string,lean:string){
  const cells=extractCells(source);
  for(const [index,name] of ['sourceBody','sourceTailBody'].entries()){
    const literal=lean.match(new RegExp(`def ${name} : String := r#"([\\s\\S]*?)"#`))?.[1];
    if(literal===undefined||cells[index]!==literal)throw new Error('MLX RMS parsed reduction cell mismatch');
  }
}
export function extractTail(source:string):string{
  const kernel=source.indexOf("[[kernel]] void rms_looped(");
  const start=source.indexOf("acc = simd_sum(acc);",kernel);
  const end=source.indexOf("// Write the outputs",start);
  if(kernel<0||start<0||end<0)throw new Error("MLX RMS reduction-tail boundaries missing");
  return source.slice(start,end).trimEnd();
}
export function checkTail(source:string,lean:string){
  const literal=lean.match(/def sourceBody : String := r#"([\s\S]*?)"#/);
  if(!literal||extractTail(source)!==literal[1])throw new Error("MLX RMS parsed reduction tail mismatch");
}
export function checkSource(source:string,lean:string,tail:string){
  if(hash(source)!==sourceHash)throw new Error("MLX RMS source SHA256 mismatch");
  checkExtracted(source,lean);checkTail(source,tail);
}
function rejected(check:()=>void){let failed=false;try{check();}catch{failed=true;}if(!failed)throw new Error('MLX RMS reduction guard mutation accepted');}
export async function checkMlxRmsReductionSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  const source=await Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/rms_norm.metal`)).text();
  const lean=await Bun.file(resolve(root,'kernels/normalization/MlxRmsReductionCell.lean')).text();
  const tail=await Bun.file(resolve(root,'kernels/normalization/MlxRmsReductionSyntax.lean')).text();
  checkSource(source,lean,tail);
  if(options.selfTest){
    const start=source.indexOf('[[kernel]] void rms_looped(');
    const mutate=(from:string,to:string)=>source.slice(0,start)+source.slice(start).replace(from,to);
    for(const bad of [mutate('x[i + r]','x[i]'),mutate('float xi =','T xi ='),mutate('acc += xi * xi','acc += xi + xi'),mutate('acc += xi * xi','acc = xi * xi')]){
      rejected(()=>checkSource(bad,lean,tail));rejected(()=>checkExtracted(bad,lean));
    }
    rejected(()=>checkExtracted(source,lean.replaceAll("x[i + r]","x[r]")));
    for(const bad of [mutate("acc = simd_sum(acc);","acc = simd_max(acc);"),
      mutate("local_sums[simd_group_id] = acc;","local_sums[simd_lane_id] = acc;"),
      mutate("acc / axis_size + eps","acc * axis_size + eps"),
      mutate("threadgroup_barrier(mem_flags::mem_threadgroup);","")]){
      rejected(()=>checkSource(bad,lean,tail));rejected(()=>checkTail(bad,tail));
    }
    rejected(()=>checkTail(source,tail.replaceAll("local_inv_mean[0]","local_inv_mean[1]")));
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  await checkMlxRmsReductionSourceBinding({selfTest:process.argv.includes('--self-test')});
  console.log('MLX RMS parsed reduction cell source binding passed (host extraction boundary).');
}
