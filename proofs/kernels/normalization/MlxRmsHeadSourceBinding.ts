import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const sourceHash='b2e04e377fdad1d645581f9beeaf9cbb06d1ad32926161e06cbc15240caf12bf';
const definesHash='a2930dbd644c69c4b66a511a094034217f3c03f48e29a1613f601532150f9163';
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');
function closing(source:string,opening:number){let depth=0;for(let i=opening;i<source.length;++i){if(source[i]==='{')++depth;if(source[i]==='}'&&--depth===0)return i;}throw new Error('Unclosed head RMS block');}
export function extractKernel(source:string){const start=source.indexOf('[[kernel]] void rms_single_row(');const end=source.indexOf('template <typename T',start+1);if(start<0||end<0)throw new Error('Head RMS kernel missing');return source.slice(start,end);}
function literal(lean:string,name:string){return lean.match(new RegExp(`def ${name} : String := r#"([\\s\\S]*?)"#`))?.[1];}
export function extractBranches(kernel:string){
  const result:string[]=[];let next=0;
  for(;;){const start=kernel.indexOf('if (lid * N_READS + N_READS <= axis_size)',next);if(start<0)break;
    const opening=kernel.indexOf('{',start),fullEnd=closing(kernel,opening),elseStart=kernel.indexOf('else',fullEnd),elseOpen=kernel.indexOf('{',elseStart),end=closing(kernel,elseOpen);
    let branch=kernel.slice(start,end+1);const forStart=branch.indexOf('for (int i'),cell=branch.indexOf('{',forStart);
    if(forStart<0||cell<0)throw new Error('Head full loop missing');
    branch=branch.slice(0,cell)+'{ CELL; }'+branch.slice(closing(branch,cell)+1);
    const tail=branch.indexOf('else'),tailOpen=branch.indexOf('{',tail);
    branch=branch.slice(0,tailOpen)+'{ TAIL; }'+branch.slice(closing(branch,tailOpen)+1);
    result.push(branch);next=end+1;
  }
  if(result.length!==2)throw new Error('Expected capture and cached-output branches');return result;
}
export function checkExtracted(source:string,lean:string){
  const kernel=extractKernel(source);
  const capture=kernel.match(/thread_x\[i\] = x\[i\];\s*acc \+= thread_x\[i\] \* thread_x\[i\];/)?.[0];
  const output=kernel.match(/out\[i\] =[\s\S]*?;/)?.[0];
  if(capture!==literal(lean,'sourceCaptureBody')||output!==literal(lean,'sourceOutputBody'))throw new Error('Parsed head cache/output cell mismatch');
  if(extractBranches(kernel).some(branch=>branch!==literal(lean,'sourceBranchBody')))throw new Error('Parsed head full/tail branch mismatch');
  for(const text of ['float thread_x[N_READS];','float acc = 0;','x += gid * size_t(axis_size) + lid * N_READS;','w += w_stride * lid * N_READS;','out += gid * size_t(axis_size) + lid * N_READS;'])
    if(!kernel.includes(text))throw new Error('Head typed cache or pointer binding changed');
  if(!source.includes('instantiate_kernel("rms" #name, rms_single_row, itype)')||!source.includes('instantiate_rms(bfloat16, bfloat16_t)'))throw new Error('Head RMS pipeline specialization changed');
}
export function checkTail(source:string,tail:string){
  const kernel=extractKernel(source),start=kernel.indexOf("acc = simd_sum(acc);"),end=kernel.indexOf("// Write the outputs using cached x values",start);
  if(start<0||end<0||kernel.slice(start,end).trimEnd()!==literal(tail,"sourceBody"))throw new Error("Head parsed reduction-tail mismatch");
}
export function checkSource(source:string,defines:string,lean:string,tail:string){
  if(hash(source)!==sourceHash||hash(defines)!==definesHash)throw new Error('Head RMS source SHA256 mismatch');
  if(!defines.includes('constexpr int RMS_N_READS = 4;'))throw new Error('Head N_READS specialization changed');checkExtracted(source,lean);checkTail(source,tail);
}
function rejected(check:()=>void){let failed=false;try{check();}catch{failed=true;}if(!failed)throw new Error('Head RMS mutation accepted');}
export async function checkMlxRmsHeadSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  const kernels=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels`);
  const source=await Bun.file(resolve(kernels,'rms_norm.metal')).text(),defines=await Bun.file(resolve(kernels,'defines.h')).text();
  const lean=await Bun.file(resolve(root,"kernels/normalization/MlxRmsHeadSyntax.lean")).text();
  const tail=await Bun.file(resolve(root,"kernels/normalization/MlxRmsReductionSyntax.lean")).text();checkSource(source,defines,lean,tail);
  if(options.selfTest){const start=source.indexOf('[[kernel]] void rms_single_row(');const mutate=(from:string,to:string)=>source.slice(0,start)+source.slice(start).replace(from,to);
    for(const bad of [mutate('thread_x[i] = x[i];','thread_x[i] = x[0];'),mutate('thread_x[i] * thread_x[i]','thread_x[i] + thread_x[i]'),
      mutate('static_cast<T>(thread_x[i] * local_inv_mean[0])','static_cast<T>(x[i] * local_inv_mean[0])'),
      mutate('N_READS <= axis_size','N_READS < axis_size'),mutate('int i = 0','int i = 1'),
      mutate('float thread_x[N_READS];','T thread_x[N_READS];'),mutate('gid * size_t(axis_size)','gid * axis_size'),
      mutate('w[w_stride * i]','w[i]')]){rejected(()=>checkSource(bad,defines,lean,tail));rejected(()=>checkExtracted(bad,lean));}
    for(const bad of [mutate("acc = simd_sum(acc);","acc = simd_max(acc);"),mutate("local_sums[simd_group_id] = acc;","local_sums[simd_lane_id] = acc;"),mutate("acc / axis_size + eps","acc * axis_size + eps")]){
      rejected(()=>checkSource(bad,defines,lean,tail));rejected(()=>checkTail(bad,tail));
    }
    rejected(()=>checkExtracted(source,lean.replaceAll('thread_x[i] = x[i];','thread_x[i] = x[0];')));
    rejected(()=>checkSource(source,defines.replace('RMS_N_READS = 4','RMS_N_READS = 8'),lean,tail));
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxRmsHeadSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX single-row head RMS source binding passed (host extraction boundary).');}
