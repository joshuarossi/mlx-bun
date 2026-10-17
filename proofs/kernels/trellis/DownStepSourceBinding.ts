import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownControlSourceBinding} from './DownControlSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down step literal '+name);return JSON.parse(matches[0]![1]!);
}
const names=['pairInputSource','pairScaleSource','windowSource','pairStepSource','tailInputSource','tailScaleSource','windowSource','tailStepSource'];
function locations(source:string,fragment:string):number[]{let at=0;const result:number[]=[];for(;;){const next=source.indexOf(fragment,at);if(next<0)return result;result.push(next);at=next+fragment.length;}}
function check(source:string,lean:string):void{
 const counts=new Map<string,number>();for(const name of names)counts.set(name,(counts.get(name)??0)+1);
 for(const [name,count] of counts)if(locations(source,literal(lean,name)).length!==count)throw Error('Down step multiplicity changed '+name);
 const used=new Map<string,number>();let previous=-1;for(const name of names){const i=used.get(name)??0,at=locations(source,literal(lean,name))[i]!;
  if(at<=previous)throw Error('Down step phase changed '+name);used.set(name,i+1);previous=at;
 }
}
export async function checkDownStepSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownControlSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownStepSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['pairInputSource','r0 + r + u','r0 + r'],['pairScaleSource','sr[u]','sr[0]'],['pairScaleSource','float(scales','float(x'],
  ['tailInputSource','r0 + r','r0'],['tailScaleSource','float(scales','float(x'],
  ['windowSource','i * (uint)K','i + (uint)K'],['windowSource','table, w, v','table, v, w'],
  ['pairStepSource','code * sr[u]','code * xr[u]'],['pairStepSource','xr[u], acc[i]','acc[i], xr[u]'],
  ['tailStepSource','metal::fma','metal::mad'],['tailStepSource','code * sr','sr * code']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);if(changed===fragment)throw Error('Ineffective step mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean);}catch{rejected=true;}if(!rejected)throw Error('Step mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownStepSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed down scalar loads, codebook window and rounded multiply/FMA statements match pinned source.');}
