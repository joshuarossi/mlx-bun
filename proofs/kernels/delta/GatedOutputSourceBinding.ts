import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGatedPointerSourceBinding} from './GatedPointerSourceBinding';
const here=new URL('./',import.meta.url);
const names=['timeSource','writerSource','advanceSource','finalSource'] as const;
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := r#"([\\s\\S]*?)"#','gm'))];
 if(matches.length!==1)throw Error('Expected one gated-output literal '+name);
 return matches[0]![1]!;
}
function check(source:string,lean:string):void{
 let previous=-1;
 for(const name of names){
  const fragment=literal(lean,name),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Gated output source/order changed '+name);
  previous=at;
 }
}
export async function checkGatedOutputSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGatedPointerSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GatedOutputSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/delta/gated.ts',root)).text();check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['timeSource','t = 0','t = 1'],['timeSource','t < T','t <= T'],['timeSource','if (true)','if (false)'],
  ['writerSource','== 0','== 1'],['writerSource','y[dv_idx]','y[dk_idx]'],['writerSource','static_cast<InT>','static_cast<StT>'],
  ['advanceSource','q_ += Hk * Dk','q_ += Hv * Dk'],['advanceSource','g_ += Hv','g_ += Hk'],
  ['finalSource','i = 0','i = 1'],['finalSource','i < n_per_t','i <= n_per_t'],
  ['finalSource','n_per_t * dk_idx + i','n_per_t * dv_idx + i'],['finalSource','static_cast<StT>','static_cast<InT>'],
 ] as const){
  const original=literal(lean,name),changed=original.replace(from,to);
  if(changed===original)throw Error('Ineffective gated-output mutation');
  for(const [native,proof] of [[source.replace(original,changed),lean],[source,lean.replace(original,changed)]]){
   let rejected=false;try{check(native!,proof!);}catch{rejected=true;}
   if(!rejected)throw Error('Gated-output mutation escaped '+name);
  }
 }
}
if(import.meta.main){await checkGatedOutputSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed gated single-step control and output/state stores match pinned source.');}
