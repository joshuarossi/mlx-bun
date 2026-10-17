import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownHostSourceBinding} from './DownHostSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down builtin literal '+name);return JSON.parse(matches[0]![1]!);
}
function check(source:string,lean:string):void{
 const body=source.split('const SOURCE = String.raw`')[1]?.split('`;')[0];if(!body)throw Error('Missing producer body');
 let previous=-1;for(const name of ['laneSource','simdSource','groupSource']){
  const fragment=literal(lean,name),at=body.indexOf(fragment);
  if(at<0||at<=previous||body.split(fragment).length!==2)throw Error('Down producer builtin changed '+name);previous=at;
 }
 if(previous>=body.indexOf('const uint y = ty % 32u;'))throw Error('Down builtin phase changed');
}
export async function checkDownBuiltinSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownHostSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(new URL('DownBuiltinSource.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['laneSource','thread_index_in_simdgroup','thread_index_in_threadgroup'],
  ['simdSource','simdgroup_index_in_threadgroup','simdgroup_index_in_grid'],
  ['groupSource','grid.y','grid.x'],['laneSource','uint lane','uint lane2'],
  ['simdSource','uint sg','uint simd'],['groupSource','uint ty','uint group']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);if(changed===fragment)throw Error('Ineffective builtin mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean);}catch{rejected=true;}if(!rejected)throw Error('Builtin mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownBuiltinSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed producer builtin declarations match pinned source and selected dispatch.');}
