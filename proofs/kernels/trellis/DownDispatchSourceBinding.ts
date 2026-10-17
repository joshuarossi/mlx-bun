import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownPointerSourceBinding} from './DownPointerSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down dispatch literal '+name);
 return JSON.parse(matches[0]![1]!);
}
function check(source:string,lean:string):void{
 let previous=-1;for(const name of ['countSource','ySource','splitSource','groupSource','blockSource','rowSource']){
  const fragment=literal(lean,name),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Down dispatch source/order changed '+name);
  previous=at;
 }
}
export async function checkDownDispatchSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownPointerSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownDispatchSource.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['countSource','- 1u','+ 1u'],['countSource','/ (uint)SPLITS','% (uint)SPLITS'],
  ['ySource','ty % 32u','ty / 32u'],['splitSource','sg % 4u','sg / 4u'],
  ['groupSource','sg / 4u','sg % 4u'],['blockSource','lane / LB','lane % LB'],['rowSource','split * ROWS_PER','split + ROWS_PER']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);if(changed===fragment)throw Error('Ineffective dispatch mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean);}catch{rejected=true;}if(!rejected)throw Error('Dispatch mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownDispatchSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed down split, column group, block and row dispatch match pinned source.');}
