import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const here=new URL('./',import.meta.url);
const pinned='e402118d33622ef62a017e964c257e23456d03f96b0fdc855b48704ff0fb954f';
const names=['initialSource','firstSource','multiSource','inverseSource','outputSource'] as const;
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := r#"([\\s\\S]*?)"#','gm'))];
 if(matches.length!==1)throw Error('Expected one gated RMS literal '+name);return matches[0]![1]!;
}
function fragments(source:string,lean:string):void{
 let previous=-1;
 for(const name of names){const fragment=literal(lean,name),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Gated RMS source/order changed '+name);previous=at;}
}
function check(source:string,lean:string):void{
 if(createHash('sha256').update(source).digest('hex')!==pinned)throw Error('Gated RMS source hash changed');fragments(source,lean);
}
export async function checkGatedRms128SourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GatedRms128Syntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/gated-rms-norm.ts',root)).text();check(source,lean);
 if(options.selfTest){
  for(const [name,from,to] of [
   ['initialSource','threadgroup_position_in_grid.x','thread_position_in_grid.x'],['initialSource','0.0f','-0.0f'],
   ['initialSource','thread_position_in_threadgroup.x','thread_index_in_simdgroup'],
   ['firstSource','r = 0','r = 1'],['firstSource','r < uint(D)','r <= uint(D)'],['firstSource','i < 4u','i < 3u'],
   ['firstSource','tid * 4u','tid * 2u'],['firstSource','col < uint(D)','col <= uint(D)'],
   ['firstSource','acc += value * value','acc += value + value'],['firstSource','simd_sum(acc)','simd_max(acc)'],
   ['multiSource','THREADS > 32','THREADS >= 32'],['multiSource','sums[lane] = 0.0f','sums[lane] = 1.0f'],
   ['inverseSource','THREADS > 32','THREADS >= 32'],['inverseSource','acc / float(D)','acc * float(D)'],
   ['outputSource','col >= uint(D)','col > uint(D)'],['outputSource','weight[col] * T(float(x[index]) * inv)','T(weight[col] * float(x[index]) * inv)'],
   ['outputSource','metal::abs(g)','g'],['outputSource','g < 0.0f','g <= 0.0f'],
   ['outputSource','(g * sigmoid) * float(normalized)','g * (sigmoid * float(normalized))'],
  ] as const){
   const original=literal(lean,name),changed=original.replace(from,to);if(changed===original)throw Error('Ineffective gated RMS mutation');
   for(const [native,proof] of [[source.replace(original,changed),lean],[source,lean.replace(original,changed)]]){
    let rejected=false;try{fragments(native!,proof!);}catch{rejected=true;}if(!rejected)throw Error('Gated RMS mutation escaped '+name);
   }
  }
  let rejected=false;try{check(source+'\n',lean);}catch{rejected=true;}if(!rejected)throw Error('Gated RMS source mutation escaped');
 }
}
if(import.meta.main){await checkGatedRms128SourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed 128-wide gated RMS phases match pinned source.');}
