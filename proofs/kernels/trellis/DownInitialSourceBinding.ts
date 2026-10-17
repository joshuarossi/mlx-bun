import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownLoopSourceBinding} from './DownLoopSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down initial literal '+name);return JSON.parse(matches[0]![1]!);
}
function check(source:string,lean:string):void{
 let previous=-1;for(const name of ['declarationSource','initializerSource']){const fragment=literal(lean,name),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Down accumulator initializer changed '+name);previous=at;
 }
 if(previous>=source.indexOf('uint r = 0;'))throw Error('Down accumulator initialization moved after row loop');
}
export async function checkDownInitialSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownLoopSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownInitialSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['declarationSource','acc[P]','acc[U]'],['declarationSource','float','half'],
  ['initializerSource','i = 0','i = 1'],['initializerSource','i < (uint)P','i <= (uint)P'],
  ['initializerSource','++i','i++'],['initializerSource','acc[i]','acc[0]'],
  ['initializerSource','0.0f','-0.0f'],['initializerSource','0.0f','1.0f']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);if(changed===fragment)throw Error('Ineffective initial mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean);}catch{rejected=true;}if(!rejected)throw Error('Initial mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownInitialSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed down FP32 accumulator allocation and positive-zero initialization match pinned source.');}
