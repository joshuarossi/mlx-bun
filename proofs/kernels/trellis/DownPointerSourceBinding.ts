import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownSetupSourceBinding} from './DownSetupSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down pointer literal '+name);
 return JSON.parse(matches[0]![1]!);
}
function check(source:string,lean:string):void{
 let previous=-1;
 for(const name of ['strideSource','blockSource','pairSource','tailSource']){
  const fragment=literal(lean,name),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Down pointer source/order changed '+name);
  previous=at;
 }
}
export async function checkDownPointerSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownSetupSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownPointerSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();
 check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['strideSource','2ul * WPB','2u * WPB'],['strideSource','(ulong)NB','NB'],
  ['blockSource','!active','active'],['blockSource','blk / 2u','blk % 2u'],
  ['blockSource','(ulong)R','R'],['blockSource','(blk % 2u) * WPB','(blk / 2u) * WPB'],
  ['pairSource','(ulong)(r0 + r + u)','(ulong)(r0 + r) + u'],
  ['tailSource','(ulong)(r0 + r)','(ulong)r0 + r']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);
   if(changed===fragment)throw Error('Ineffective down pointer mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean);}catch{rejected=true;}
   if(!rejected)throw Error('Down pointer mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownPointerSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed down ulong stride, block and row pointers match pinned source.');}
