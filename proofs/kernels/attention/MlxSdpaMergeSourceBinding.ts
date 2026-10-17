import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {extractKernel} from './MlxSdpaVectorSourceBinding';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const kernelHash='de098d50a67a865e2e64fb1700fc4819307861f009a65642679777a9a9cec7cd';
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const normalize=(s:string)=>s.replace(/\s+/g,' ').trim();
function literal(s:string,name:string){const m=s.match(new RegExp(`def ${name} : String := r#"([\\s\\S]*?)"#`));if(!m)throw new Error('Missing SDPA merge literal');return m[1]!;}
function close(s:string,start:number){let d=0;for(let i=start;i<s.length;++i){if(s[i]==='{')++d;if(s[i]==='}'&&--d===0)return i;}throw new Error('Unclosed SDPA merge block');}
export function checkExtracted(source:string,lean:string){
  const kernel=extractKernel(source),start=kernel.indexOf('if (simd_lid == 0)'),end=kernel.indexOf('sum_exp_score = simd_sum(sum_exp_scores[simd_lid] * factor);',start);
  if(start<0||end<0)throw new Error('SDPA summary publication/reduction missing');
  const summary=kernel.slice(start,end+'sum_exp_score = simd_sum(sum_exp_scores[simd_lid] * factor);'.length);
  if(normalize(summary)!==normalize(literal(lean,'sourceSummary')))throw new Error('Parsed SDPA summary source changed');
  const write=kernel.indexOf('outputs[simd_lid * BD + simd_gid] = o[i];',end),loop=kernel.lastIndexOf('for (',write),opening=kernel.indexOf('{',loop);
  if(write<0||loop<end||opening<0)throw new Error('SDPA transpose phase missing');
  const loopEnd=close(kernel,opening),transpose=kernel.slice(loop,loopEnd+1);
  if(normalize(transpose)!==normalize(literal(lean,'sourceTranspose')))throw new Error('Parsed SDPA transpose/divide source changed');
  const gate=kernel.indexOf('if (simd_lid == 0)',loopEnd),gateOpen=kernel.indexOf('{',gate),gateEnd=close(kernel,gateOpen),cellOpen=kernel.indexOf('{',gateOpen+1),cellEnd=close(kernel,cellOpen);
  if(gate<0||cellOpen<0)throw new Error('SDPA output writer gate missing');
  const shell=kernel.slice(gate,cellOpen)+'{ CELL; }'+kernel.slice(cellEnd+1,gateEnd+1);
  if(normalize(shell)!==normalize(literal(lean,'sourceGate')))throw new Error('Parsed SDPA output writer shell changed');
  if(normalize(kernel.slice(cellOpen+1,cellEnd))!=='out[i] = static_cast<T>(o[i]);')throw new Error('SDPA final BF16 source store changed');
  for(const text of ['typedef float U;','threadgroup U outputs[BN * BD];','threadgroup U max_scores[BN];','threadgroup U sum_exp_scores[BN];'])if(!kernel.includes(text))throw new Error('SDPA merge typed storage changed');
}
function reject(f:()=>void){let bad=false;try{f();}catch{bad=true;}if(!bad)throw new Error('SDPA merge mutation accepted');}
export async function checkMlxSdpaMergeSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  const source=await Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/sdpa_vector.h`)).text(),lean=await Bun.file(resolve(root,'kernels/attention/MlxSdpaMergeSyntax.lean')).text();
  if(hash(source)!==kernelHash)throw new Error('SDPA merge pinned SHA mismatch');checkExtracted(source,lean);
  if(options.selfTest){const begin=source.indexOf('if (simd_lid == 0)');for(const [a,b] of [['max_scores[simd_gid] = max_score','max_scores[simd_lid] = max_score'],['simd_max(max_score)','simd_sum(max_score)'],['max_score - new_max','new_max - max_score'],['sum_exp_scores[simd_lid] * factor','sum_exp_scores[simd_gid] * factor'],['outputs[simd_lid * BD + simd_gid]','outputs[simd_gid * BD + simd_lid]'],['outputs[simd_gid * BD + simd_lid] * factor','outputs[simd_lid * BD + simd_gid] * factor'],['sum_exp_score == 0 ? o[i]','sum_exp_score == 1 ? o[i]'],['o[i] / sum_exp_score','sum_exp_score / o[i]'],['out[i] = static_cast<T>(o[i]);','out[i] = static_cast<T>(o[0]);'],['threadgroup_barrier(mem_flags::mem_threadgroup);','threadgroup_barrier(mem_flags::mem_none);']] as const){const bad=source.slice(0,begin)+source.slice(begin).replace(a,b);if(hash(bad)===kernelHash)throw new Error('SDPA merge mutation did not change selected source');reject(()=>checkExtracted(bad,lean));}
    const gate=source.lastIndexOf('if (simd_lid == 0)',source.indexOf('[[kernel]] void sdpa_vector_2pass_1('));
    const bad=source.slice(0,gate)+source.slice(gate).replace('simd_lid == 0','simd_gid == 0');reject(()=>checkExtracted(bad,lean));
    const shifted=source.slice(0,gate)+source.slice(gate).replace('int i = 0','int i = 1');reject(()=>checkExtracted(shifted,lean));
    const write=source.indexOf('outputs[simd_lid * BD + simd_gid] = o[i];'),firstBarrier=source.indexOf('threadgroup_barrier(',write),secondBarrier=source.indexOf('threadgroup_barrier(',firstBarrier+1);
    const missing=source.slice(0,secondBarrier)+source.slice(secondBarrier).replace('threadgroup_barrier(mem_flags::mem_threadgroup);','');reject(()=>checkExtracted(missing,lean));
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxSdpaMergeSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX SDPA crossgroup merge/output source binding passed.');}
