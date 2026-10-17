import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGateWeightSourceBinding} from './GateWeightSourceBinding';
const here=new URL('./',import.meta.url);
function fragment(text:string,name:string):string {
 const matches=[...text.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one gate loop fragment '+name);
 return JSON.parse(matches[0]![1]!);
}
function body(source:string):string {
 const match=source.match(/const SOURCE = String.raw`([\s\S]*?)`;/);
 if(!match)throw Error('Gate kernel body missing');
 return match[1]!.replace(/\/\/[^\n]*/g,'');
}
function nesting(source:string,at:number):number {
 let depth=0;for(const c of source.slice(0,at)){if(c==='{')depth++;else if(c==='}')depth--;if(depth<0)throw Error('Invalid loop nesting');}return depth;
}
export async function checkGateLoopSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGateWeightSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GateLoopSource.lean',here)).text();
 const source=body(await Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text());
 const names=['runSource','qSource','pSource','columnSource'];let previous=-1;let depth=-1;
 for(const name of names){const selected=fragment(lean,name);const at=source.indexOf(selected);
  if(source.split(selected).length!==2||at<=previous)throw Error('Gate loop source/order changed '+name);
  const next=nesting(source,at);if(depth>=0&&next!==depth+1)throw Error('Gate loop nesting changed '+name);
  previous=at;depth=next;
 }
 const fma=source.indexOf('if (j & 1u) { gAcc2');
 if(fma<=previous||nesting(source,fma)!==depth)throw Error('Gate FMA moved outside selected loops');
 if(options.selfTest){for(const [name,from,to] of [
  ['runSource','run += 32u','run += 16u'],['runSource','run < N_RUNS','run < 128u'],['runSource','run = lane','run = 0u'],
  ['qSource','q < 4u','q < 3u'],['pSource','p < 8u','p < 7u'],['columnSource','q * 8u + p','p * 4u + q']]){
  const selected=fragment(lean,name!);const mutated=selected.replace(from!,to!);
  if(selected===mutated||source.includes(mutated))throw Error('Gate loop negative test ineffective '+name);
 }}
}
if(import.meta.main){await checkGateLoopSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed run/q/p loop headers, nesting, column index and FMA placement match pinned source.');}
