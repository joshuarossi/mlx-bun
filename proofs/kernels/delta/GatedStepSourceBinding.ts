import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const here=new URL('./',import.meta.url);
const pinned='3f0e11f777f57b6595d57d62ec3f8b8331cbfa7263183e1baa98892efe935aec';
const names=['predictionSource','deltaSource','correctionSource'] as const;
function literal(lean:string,name:string):string{
 const raw=[...lean.matchAll(new RegExp('^def '+name+' : String := r#"([\\s\\S]*?)"#','gm'))];
 const quoted=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(raw.length+quoted.length!==1)throw Error('Expected one gated-step literal '+name);
 return raw.length?raw[0]![1]!:JSON.parse(quoted[0]![1]!);
}
function fragments(source:string,lean:string):void{
 let previous=-1;
 for(const name of names){
  const fragment=literal(lean,name),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('Gated recurrence source/order changed '+name);
  previous=at;
 }
}
function check(source:string,lean:string):void{
 if(createHash('sha256').update(source).digest('hex')!==pinned)throw Error('Gated recurrence source hash changed');
 fragments(source,lean);
}
export async function checkGatedStepSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GatedStepSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/delta/gated.ts',root)).text();
 check(source,lean);
 if(options.selfTest){
  for(const [name,from,to] of [
   ['predictionSource','0.0f','-0.0f'],['predictionSource','i = 0','i = 1'],
   ['predictionSource','i < n_per_t','i <= n_per_t'],['predictionSource','n_per_t * dk_idx + i','dk_idx + n_per_t * i'],
   ['predictionSource','state[i] * g_[hv_idx]','state[i] + g_[hv_idx]'],
   ['predictionSource','kv_mem += state[i] * k_[s_idx]','kv_mem += state[i] * q_[s_idx]'],
   ['predictionSource','simd_sum(kv_mem)','simd_max(kv_mem)'],
   ['deltaSource','v_[dv_idx] - kv_mem','kv_mem - v_[dv_idx]'],['deltaSource','* beta_[hv_idx]','+ beta_[hv_idx]'],
   ['correctionSource','0.0f','-0.0f'],['correctionSource','i = 0','i = 1'],
   ['correctionSource','state[i] + k_[s_idx] * delta','state[i] + q_[s_idx] * delta'],
   ['correctionSource','out += state[i] * q_[s_idx]','out += state[i] * k_[s_idx]'],
   ['correctionSource','simd_sum(out)','simd_max(out)'],
  ] as const){
   const original=literal(lean,name),changed=original.replace(from,to);
   if(changed===original)throw Error('Ineffective gated-step mutation '+name);
   // Exercise fragment binding independently of the whole-file hash.
   for(const [native,proof] of [[source.replace(original,changed),lean],[source,lean.replace(original,changed)]]){
    let rejected=false;try{fragments(native!,proof!);}catch{rejected=true;}
    if(!rejected)throw Error('Gated-step mutation escaped '+name);
   }
  }
  let rejected=false;try{check(source+'\n',lean);}catch{rejected=true;}
  if(!rejected)throw Error('Gated-step whole-source mutation escaped');
 }
}
if(import.meta.main){await checkGatedStepSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed gated decay, prediction, correction and readout match pinned source.');}
