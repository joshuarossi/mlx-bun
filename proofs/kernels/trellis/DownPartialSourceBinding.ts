import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownScratchSourceBinding} from './DownScratchSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down partial literal '+name);return JSON.parse(matches[0]![1]!);
}
function check(source:string,lean:string):void{
 let previous=source.lastIndexOf('threadgroup_barrier(metal::mem_flags::mem_threadgroup);');
 for(const name of ['outputSource','groupSource','guardSource','zeroSource','sumSource','storeSource']){
  const fragment=literal(lean,name),at=source.indexOf(fragment);if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Down partial source/order changed '+name);previous=at;
 }
}
export async function checkDownPartialSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownScratchSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownPartialSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['outputSource','thread_position_in_threadgroup.x','thread_position_in_grid.x'],['outputSource','c += (uint)THREADS','c += 1u'],
  ['groupSource','c / SG_COLS','c % SG_COLS'],['groupSource','+ group2','+ 0u'],['guardSource','col >=','col >'],
  ['zeroSource','0.0f','-0.0f'],['sumSource','k < 4u','k < 8u'],['sumSource','] + t',' ] + 0.0f'],
  ['sumSource','group2 * 4u + k','group2 + 4u * k'],['storeSource','(ulong)y * (ulong)C','(uint)y * (uint)C'],
  ['storeSource','+ col','+ col + 1ul']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);if(changed===fragment)throw Error('Ineffective partial mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean);}catch{rejected=true;}if(!rejected)throw Error('Partial mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownPartialSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed down four-split partial producer and uint64 output address match pinned source.');}
