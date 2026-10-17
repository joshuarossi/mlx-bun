import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {extractKernel} from './MlxSdpaVectorSourceBinding';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const kernelHash='de098d50a67a865e2e64fb1700fc4819307861f009a65642679777a9a9cec7cd';
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const normalized=(s:string)=>s.replace(/\/\/[^\n]*/g,'').replace(/\s+/g,' ').trim();
function literal(s:string){const result=s.match(/def sourceBody : String := r#"([\s\S]*?)"#/);if(!result)throw new Error('SDPA score/update literal missing');return result[1]!;}
export function checkExtracted(source:string,scoreLean:string,updateLean:string,partialLean:string){
  const kernel=extractKernel(source);
  const score=kernel.match(/U score = 0;\s*for \(int j = 0; j < qk_per_thread; j\+\+\) \{\s*score \+= q\[j\] \* k\[j\];\s*\}\s*score = simd_sum\(score\);/)?.[0];
  const update=kernel.match(/U new_max = max\(max_score, score\);[\s\S]*?for \(int j = 0; j < v_per_thread; j\+\+\) \{[\s\S]*?\}/)?.[0];
  if(!score||normalized(score)!==normalized(literal(scoreLean)))throw new Error('Parsed SDPA ordered score body changed');
  if(!update||normalized(update)!==normalized(literal(updateLean)))throw new Error('Parsed SDPA softmax update body changed');
  const initial=kernel.match(/for \(int i = 0; i < v_per_thread; i[+][+]\) \{\s*o\[i\] = 0;\s*\}\s*U max_score = Limits<U>::finite_min;\s*U sum_exp_score = 0;/)?.[0];
  const expected=partialLean.match(/def sourceInitial : String := r#"([\s\S]*?)"#/);
  if(!initial||!expected||normalized(initial)!==normalized(expected[1]!))throw new Error('SDPA parsed initial registers changed');
  if(!(kernel.indexOf('q[i] = static_cast<U>(scale) * queries[i];')<kernel.indexOf(score)&&kernel.indexOf('k[j] = keys[j];')<kernel.indexOf(score)&&kernel.indexOf(score)<kernel.indexOf(update)))throw new Error('SDPA source operand/update chronology changed');
  for(const text of ['typedef float U;','constexpr int qk_per_thread = D / BD;','constexpr int v_per_thread = V / BD;','constexpr int BD = 32;','bool use_key = true;','if (use_key) {'])if(!kernel.includes(text))throw new Error('SDPA selected score/update shell changed');
}
function reject(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw new Error('SDPA score mutation accepted');}
export async function checkMlxSdpaScoreSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  const source=await Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/sdpa_vector.h`)).text();
  const score=await Bun.file(resolve(root,'kernels/attention/MlxSdpaScoreSource.lean')).text(),update=await Bun.file(resolve(root,'kernels/attention/MlxSdpaUpdateSource.lean')).text(),partial=await Bun.file(resolve(root,'kernels/attention/MlxSdpaPartialSource.lean')).text();
  if(hash(source)!==kernelHash)throw new Error('SDPA score pinned SHA mismatch');checkExtracted(source,score,update,partial);
  if(options.selfTest){for(const [a,b] of [['o[i] = 0;','o[i] = 1;'],['Limits<U>::finite_min','Limits<U>::finite_max'],['U sum_exp_score = 0;','U sum_exp_score = 1;']] as const){const bad=source.replace(a,b);reject(()=>checkExtracted(bad,score,update,partial));}
    for(const [a,b] of [['U score = 0;','U score = 1;'],['score += q[j] * k[j];','score += q[0] * k[j];'],['j < qk_per_thread','j <= qk_per_thread'],['score = simd_sum(score);','score = simd_max(score);'],['max(max_score, score)','max(score, max_score)'],['max_score - new_max','new_max - max_score'],['fast::exp(score - new_max)','fast::exp(score - max_score)'],['sum_exp_score * factor + exp_score','sum_exp_score + factor * exp_score'],['o[j] * factor + exp_score * values[j]','o[j] * exp_score + factor * values[j]'],['j < v_per_thread','j <= v_per_thread']] as const){const start=source.indexOf('U score = 0;');const bad=source.slice(0,start)+source.slice(start).replace(a,b);if(hash(bad)===kernelHash)throw new Error('SDPA score mutation did not alter production source');reject(()=>checkExtracted(bad,score,update,partial));}
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxSdpaScoreSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX SDPA ordered score/update source binding passed.');}
