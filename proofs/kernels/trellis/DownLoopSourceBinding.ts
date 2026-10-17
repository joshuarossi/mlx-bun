import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownStepSourceBinding} from './DownStepSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down loop literal '+name);return JSON.parse(matches[0]![1]!);
}
const names=['initialSource','pairSource','uSource','uSource','iSource','tailSource','iSource'];
function locations(source:string,fragment:string):number[]{let at=0;const result:number[]=[];for(;;){const next=source.indexOf(fragment,at);if(next<0)return result;result.push(next);at=next+fragment.length;}}
function check(source:string,lean:string):void{
 const counts=new Map<string,number>();for(const name of names)counts.set(name,(counts.get(name)??0)+1);
 for(const [name,count] of counts)if(locations(source,literal(lean,name)).length!==count)throw Error('Down loop multiplicity changed '+name);
 const used=new Map<string,number>();let previous=-1;for(const name of names){const i=used.get(name)??0,at=locations(source,literal(lean,name))[i]!;
  if(at<=previous)throw Error('Down loop phase changed '+name);used.set(name,i+1);previous=at;
 }
}
export async function checkDownLoopSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownStepSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownLoopSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['initialSource','r = 0','r = 1'],['pairSource','<= rows','< rows'],['pairSource','r + (uint)U','r + 1u'],
  ['pairSource','r += (uint)U','r += 1u'],['tailSource','r < rows','r <= rows'],['tailSource','++r','r++'],
  ['uSource','u < (uint)U','u <= (uint)U'],['iSource','i < (uint)P','i <= (uint)P']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);if(changed===fragment)throw Error('Ineffective loop mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean);}catch{rejected=true;}if(!rejected)throw Error('Loop mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownLoopSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed down paired/tail row loops and inner u/i traversal match pinned source.');}
