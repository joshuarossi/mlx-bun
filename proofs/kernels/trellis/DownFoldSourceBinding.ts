import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownPartialSourceBinding} from './DownPartialSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one down fold literal '+name);return JSON.parse(matches[0]![1]!);
}
function check(source:string,lean:string):void{
 const bodies=[...source.matchAll(/const FOLD = String\.raw`([^`]*)`;/g)];
 if(bodies.length!==1)throw Error('Expected one down fold body');
 const expected=['laneSource','columnSource','vectorSource'].map(n=>literal(lean,n)).concat(
  ['#pragma clang loop unroll(full)',literal(lean,'loopSource'),literal(lean,'reductionSource'),literal(lean,'storeSource'),'}']).join('\n');
 const compact=(s:string)=>s.replace(/\s+/g,' ').trim();
 if(compact(bodies[0]![1]!)!==compact(expected))throw Error('Down fold body/order changed');
}
export async function checkDownFoldSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownPartialSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('DownFoldSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['laneSource','thread_index_in_simdgroup','thread_index_in_threadgroup'],
  ['columnSource','32u','16u'],['columnSource','* 4u','* 8u'],['columnSource','grid.x','grid.y'],
  ['vectorSource','float4*','float2*'],['vectorSource','(ulong)lane','(uint)lane'],
  ['vectorSource','(ulong)C','(uint)C'],['vectorSource','+ col','+ col + 1u'],
  ['loopSource','i < 4u','i <= 4u'],['reductionSource','t[i]','t[0]'],
  ['reductionSource','simd_sum','simd_max'],['storeSource','lane == 0u','lane == 1u'],
  ['storeSource','col + i','col + 0u'],['storeSource','T(v)','T(0.0f)']]){
   const fragment=literal(lean,name!),changed=fragment.replace(from!,to!);if(changed===fragment)throw Error('Ineffective fold mutation');
   let rejected=false;try{check(source.replaceAll(fragment,changed),lean);}catch{rejected=true;}if(!rejected)throw Error('Fold mutation escaped '+name);
 }
 if(options.selfTest){
  const reduction=literal(lean,'reductionSource'),store=literal(lean,'storeSource');
  for(const changed of [source.replace(reduction,'if (lane == 0u) '+reduction),source.replace(store,store+' out[0] = T(v);')]){
   let rejected=false;try{check(changed,lean);}catch{rejected=true;}if(!rejected)throw Error('Fold collective/store phase mutation escaped');
  }
 }
}
if(import.meta.main){await checkDownFoldSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed complete down fold body, all-lane collective and writer phase match pinned source.');}
