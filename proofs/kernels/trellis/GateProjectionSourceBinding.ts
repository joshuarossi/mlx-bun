import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGateLoopSourceBinding} from './GateLoopSourceBinding';
const here=new URL('./',import.meta.url);
function fragment(text:string,name:string):string {
 const matches=[...text.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one gate projection fragment '+name);
 return JSON.parse(matches[0]![1]!);
}
export async function checkGateProjectionSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGateLoopSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GateProjectionSource.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text();
 const names=['initialSource','gateSource','upSource'];const ats:number[]=[];
 for(const name of names){const selected=fragment(lean,name);if(source.split(selected).length!==2)throw Error('Gate projection fragment changed '+name);ats.push(source.indexOf(selected));}
 const run=source.indexOf('for (uint run = lane; run < N_RUNS; run += 32u) {');const fma=source.indexOf('if (j & 1u) { gAcc2');const store=source.indexOf('if (lane == 0u) {');
 if(!(ats[0]!<run&&run<fma&&fma<ats[1]!&&ats[1]!<ats[2]!&&ats[2]!<store))throw Error('Gate projection phases changed');
 if(options.selfTest){for(const [name,from,to] of [
  ['initialSource','gAcc = 0.0f','gAcc = 1.0f'],['initialSource','uAcc2 =','uAcc ='],
  ['gateSource','gAcc + gAcc2','gAcc + uAcc2'],['gateSource','gAcc + gAcc2','gAcc2 + gAcc'],
  ['gateSource','simd_sum','simd_product'],['upSource','uAcc + uAcc2','uAcc + gAcc2']]){
  const selected=fragment(lean,name!);const mutated=selected.replace(from!,to!);
  if(selected===mutated||source.includes(mutated))throw Error('Gate projection negative test ineffective '+name);
 }}
}
if(import.meta.main){await checkGateProjectionSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed zero initialization and separate lane-add/SIMD-reduction statements match pinned source.');}
