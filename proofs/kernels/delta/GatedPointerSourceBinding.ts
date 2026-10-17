import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGatedStepSourceBinding} from './GatedStepSourceBinding';
const here=new URL('./',import.meta.url);
const names=['headerSource','querySource','valueSource','threadSource','stateSource','initialSource','gateSource'] as const;
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := r#"([\\s\\S]*?)"#','gm'))];
 if(matches.length!==1)throw Error('Expected one gated-pointer literal '+name);
 return matches[0]![1]!;
}
function check(source:string,lean:string):void{
 let previous=-1;
 for(const name of names){
  const fragment=literal(lean,name),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Gated pointer source/order changed '+name);
  previous=at;
 }
}
export async function checkGatedPointerSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGatedStepSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GatedPointerSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/delta/gated.ts',root)).text();
 check(source,lean);
 if(options.selfTest)for(const [name,from,to] of [
  ['headerSource','Tin[0]','Tin[1]'],['headerSource','n / Hv','n % Hv'],['headerSource','n % Hv','n / Hv'],
  ['headerSource','hv_idx / (Hv / Hk)','hv_idx / Hk'],['headerSource','Dk / 32','Dk / 16'],
  ['querySource','hk_idx * Dk','hv_idx * Dk'],['valueSource','hv_idx * Dv','hk_idx * Dv'],
  ['threadSource','thread_position_in_threadgroup.x','thread_position_in_grid.x'],
  ['threadSource','thread_position_in_grid.y','thread_position_in_grid.z'],
  ['stateSource','n * Dv + dv_idx','dv_idx * Dv + n'],['stateSource','state_out +','state_in +'],
  ['initialSource','i = 0','i = 1'],['initialSource','i < n_per_t','i <= n_per_t'],
  ['initialSource','n_per_t * dk_idx + i','dk_idx + n_per_t * i'],['initialSource','static_cast<float>','static_cast<InT>'],
  ['gateSource','b_idx * T * Hv','b_idx * T * Hk'],['gateSource','beta +','g +'],
 ] as const){
  const original=literal(lean,name),changed=original.replace(from,to);
  if(changed===original)throw Error('Ineffective gated-pointer mutation');
  for(const [native,proof] of [[source.replace(original,changed),lean],[source,lean.replace(original,changed)]]){
   let rejected=false;try{check(native!,proof!);}catch{rejected=true;}
   if(!rejected)throw Error('Gated-pointer mutation escaped '+name);
  }
 }
}
if(import.meta.main){await checkGatedPointerSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed gated input pointers and four-register initialization match pinned source.');}
