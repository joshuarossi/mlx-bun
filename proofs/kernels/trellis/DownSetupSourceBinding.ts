import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkPackedArraySourceBinding} from './PackedArraySourceBinding';
const here=new URL('./',import.meta.url);
const names=['bitsSource','shiftSource','alignedSource','countSource','loadedSource','lanesSource','wordsSource','blocksSource','localSource','firstSource'];
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down setup literal '+name);
 return JSON.parse(matches[0]![1]!);
}
function check(source:string,lean:string):void{
 let previous=-1;
 for(const name of names){const fragment=literal(lean,name),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Down setup source/order changed '+name);
  previous=at;
 }
}
export async function checkDownSetupSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkPackedArraySourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownSetupSource.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();
 check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['bitsSource','P * K','P + K'],['shiftSource','32u','16u'],['alignedSource','== 0u','== 1u'],
  ['countSource','- (uint)K','+ (uint)K'],['loadedSource','NA + 1u','NA + 2u'],
  ['lanesSource','256u','128u'],['wordsSource','8u','4u'],['blocksSource','C / 256','C / 128'],
  ['localSource','lane % LB','lane / LB'],['firstSource','>> 5','>> 4']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);
   if(changed===fragment)throw Error('Ineffective down setup mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean);}catch{rejected=true;}
   if(!rejected)throw Error('Down setup mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownSetupSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed down bit counts, lane subdivision and first-word setup match pinned source.');}
