import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGateAccumulateSourceBinding} from './GateAccumulateSourceBinding';
const here=new URL('./',import.meta.url);
function fragment(text:string,name:string):string {
 const matches=[...text.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one weight fragment '+name);
 return JSON.parse(matches[0]![1]!);
}
function count(source:string,part:string):number {return source.split(part).length-1;}
export async function checkGateWeightSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGateAccumulateSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GateWeightSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text();
 const names=['gateScaleSource','upScaleSource','gateWeightSource','upWeightSource'];let previous=-1;
 for(const name of names){const selected=fragment(lean,name);const at=source.indexOf(selected);
  if(count(source,selected)!==1||at<=previous)throw Error('Weight source/order changed '+name);previous=at;
 }
 const input=source.indexOf('const float xv = as_type<float>');const fma=source.indexOf('if (j & 1u) { gAcc2');
 if(source.indexOf(fragment(lean,'gateWeightSource'))<=input||previous>=fma)throw Error('Weight arithmetic phase changed');
 if(options.selfTest){
  for(const [name,from,to] of [
   ['gateScaleSource','float(gscales[row])','float(uscales[row])'],['gateScaleSource','[row]','[row + 1u]'],
   ['gateWeightSource','table, g, gv','table, u, uv'],['gateWeightSource','31u - j','30u - j'],
   ['gateWeightSource','(uint)KG','(uint)KU'],['gateWeightSource','(uint)L','(uint)KG'],
   ['gateWeightSource','* gScale','* uScale'],['upWeightSource','* uScale','+ uScale']]){
   const selected=fragment(lean,name!);const mutated=selected.replace(from!,to!);
   if(mutated===selected||count(source,mutated)!==0)throw Error('Weight negative test ineffective '+name);
  }
 }
}
if(import.meta.main){await checkGateWeightSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed window calls and FP16-scale widening/multiplication match pinned source.');}
