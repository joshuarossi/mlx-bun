import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownInitialSourceBinding} from './DownInitialSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down scratch literal '+name);return JSON.parse(matches[0]![1]!);
}
function locations(source:string,fragment:string):number[]{let at=0;const result:number[]=[];for(;;){const next=source.indexOf(fragment,at);if(next<0)return result;result.push(next);at=next+fragment.length;}}
function check(source:string,lean:string):void{
 const barriers=locations(source,literal(lean,'barrierSource'));if(barriers.length!==3)throw Error('Down threadgroup barrier count changed');
 const points=new Map<string,number>();for(const name of ['columnsSource','aliasSource','localSource','storeSource']){
  const found=locations(source,literal(lean,name));if(found.length!==1)throw Error('Down scratch multiplicity changed '+name);points.set(name,found[0]!);
 }
 if(!(barriers[0]!<points.get('columnsSource')!&&points.get('columnsSource')!<barriers[1]!&&
  barriers[1]!<points.get('aliasSource')!&&points.get('aliasSource')!<points.get('localSource')!&&
  points.get('localSource')!<points.get('storeSource')!&&points.get('storeSource')!<barriers[2]!))throw Error('Down shared-memory phase order changed');
}
export async function checkDownScratchSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownInitialSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownScratchSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['barrierSource','mem_threadgroup','mem_device'],['aliasSource','= codebook','= replacement'],['aliasSource','float* sums','float* scratch'],
  ['columnsSource','32u','16u'],['localSource','lane / LB','lane % LB'],['localSource','255u - li','255u + li'],
  ['storeSource','i < (uint)P','i <= (uint)P'],['storeSource','local - i','local + i'],
  ['storeSource','sg * SG_COLS','sg + SG_COLS'],['storeSource','acc[i]','acc[0]']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);if(changed===fragment)throw Error('Ineffective scratch mutation');
   let rejected=false;try{check(source.replace(fragment,changed),lean);}catch{rejected=true;}if(!rejected)throw Error('Scratch mutation escaped '+name);
 }
}
if(import.meta.main){await checkDownScratchSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed down same-allocation scratch alias, stores and barrier phase order match pinned source.');}
