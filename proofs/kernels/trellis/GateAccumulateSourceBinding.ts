import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGateInputSourceBinding} from './GateInputSourceBinding';
const here=new URL('./',import.meta.url);
function fragment(text:string):string {
 const matches=[...text.matchAll(/^def source : String := ("[^"\n]*")/gm)];
 if(matches.length!==1)throw Error('Expected one GateAccumulate source literal');
 return JSON.parse(matches[0]![1]!);
}
function count(source:string,part:string):number {return source.split(part).length-1;}
export async function checkGateAccumulateSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGateInputSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GateAccumulateSource.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text();
 const selected=fragment(lean);
 if(count(source,selected)!==1)throw Error('Gate accumulator FMA fragment changed');
 const input='const float xv = as_type<float>((p & 1u) ? chunk[p >> 1] & 0xFFFF0000u : chunk[p >> 1] << 16);';
 const start=source.indexOf(input), end=source.indexOf('const float gate = metal::simd_sum(gAcc + gAcc2);');
 if(start<0||end<0||source.indexOf(selected)<=start||source.indexOf(selected)>=end)throw Error('Gate accumulator phase order changed');
 if(options.selfTest){
  for(const [from,to] of [['j & 1u','j & 2u'],['gAcc2 =','gAcc ='],['fma(gWeight, xv, gAcc2)','fma(gWeight, xv, gAcc)'],['fma(uWeight, xv, uAcc2)','fma(gWeight, xv, uAcc2)'],['fma(gWeight, xv, gAcc)','fma(xv, gWeight, gAcc)']]){
   const mutated=selected.replace(from!,to!);
   if(mutated===selected||count(source,mutated)!==0)throw Error('Gate FMA negative test ineffective');
  }
 }
}
if(import.meta.main){await checkGateAccumulateSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed gate/up accumulator FMA branch matches pinned source.');}
