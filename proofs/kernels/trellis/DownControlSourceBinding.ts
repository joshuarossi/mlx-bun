import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownDispatchSourceBinding} from './DownDispatchSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down control literal '+name);return JSON.parse(matches[0]![1]!);
}
function check(source:string,lean:string,dispatch:string):void{
 let previous=-1;for(const [text,name] of [[dispatch,'groupsSource'],[lean,'activeSource'],[lean,'shiftedSource'],[lean,'rowsSource']]){
  const fragment=literal(text!,name!),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Down control source/order changed '+name);previous=at;
 }
}
export async function checkDownControlSourceBinding(options:{repositoryRoot?:string;leanSource?:string;dispatchSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownDispatchSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownControlSyntax.lean',here)).text();
 const dispatch=await Bun.file(options.dispatchSource?resolve(options.dispatchSource):new URL('DownControlDispatch.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();check(source,lean,dispatch);
 if(options.selfTest)for(const [name,from,to] of [
  ['groupsSource','NB + 32u / LB - 1u','NB + 32u / LB + 1u'],['activeSource','&&','&'],
  ['activeSource','blk < NB','blk < SGS'],['shiftedSource','!ALIGNED','ALIGNED'],['shiftedSource','li & 1u','li & 2u'],
  ['rowsSource','!active','active'],['rowsSource','== 0u','== 1u'],['rowsSource','r0 >=','r0 >'],
  ['rowsSource','metal::min','metal::max'],['rowsSource','(uint)R - r0','r0 - (uint)R']]){
   const fragment=literal(name==='groupsSource'?dispatch:lean,name!),changed=fragment.replace(from!,to!);if(changed===fragment)throw Error('Ineffective control mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean,dispatch);}catch{rejected=true;}if(!rejected)throw Error('Control mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownControlSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed down active, shifted and selected row-count controls match pinned source.');}
