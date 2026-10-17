import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const here=new URL('./',import.meta.url);
const pinned='52c59772bf95e2cd8f7f813a69a7dfac0c352dadc3c2a1e0e550c054dd301145';
const names=['headerSource','activationSource','outputSource'] as const;
function literal(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := r#"([\\s\\S]*?)"#','gm'))];
 if(matches.length!==1)throw Error('Expected one SiLU-heads literal '+name);return matches[0]![1]!;
}
function fragments(source:string,lean:string):void{
 let previous=-1;
 for(const name of names){const fragment=literal(lean,name),at=source.indexOf(fragment);
  if(at<0||source.split(fragment).length!==2||at<=previous)throw Error('SiLU-heads source/order changed '+name);previous=at;}
}
function check(source:string,lean:string):void{
 if(createHash('sha256').update(source).digest('hex')!==pinned)throw Error('SiLU-heads source hash changed');fragments(source,lean);
}
export async function checkSiluHeads128SourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 const lean=await Bun.file(new URL('SiluHeads128Syntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/delta/silu-rms-heads.ts',root)).text();check(source,lean);
 if(options.selfTest){
  for(const [name,from,to] of [
   ['headerSource','threadgroup_position_in_grid.x','thread_position_in_grid.x'],
   ['headerSource','head < uint(2 * HK)','head < uint(HK)'],
   ['headerSource','normalize ? uint(DK) : uint(DV)','normalize ? uint(DV) : uint(DK)'],
   ['headerSource','float sum = 0.0f','float sum = -0.0f'],
   ['activationSource','i < 4u','i < 3u'],['activationSource','lane * 4u','lane * 2u'],
   ['activationSource','col < width','col <= width'],['activationSource','metal::abs(value)','value'],
   ['activationSource','value < T(0)','value <= T(0)'],['activationSource','T(value * sigmoid)','T(float(value) * float(sigmoid))'],
   ['activationSource','sum += activated * activated','sum += activated + activated'],
   ['outputSource','metal::simd_sum(sum)','metal::simd_max(sum)'],['outputSource','sum / float(DK) + 1e-6f','sum / float(DK) + 1e-5f'],
   ['outputSource','head % uint(HK)','head / uint(HK)'],['outputSource','lane * 4u + i >= uint(DK)','lane * 4u + i > uint(DK)'],
   ['outputSource','T(float(values[i]) * inv)','T(values[i] * T(inv))'],
   ['outputSource','qscale[lane * 4u + i] * normalized','kscale[lane * 4u + i] * normalized'],
   ['outputSource','head - uint(2 * HK)','head - uint(HK)'],['outputSource','v[index + i] = values[i]','v[index + i] = values[0]'],
  ] as const){
   const original=literal(lean,name),changed=original.replace(from,to);if(changed===original)throw Error('Ineffective SiLU-heads mutation');
   for(const [native,proof] of [[source.replace(original,changed),lean],[source,lean.replace(original,changed)]]){
    let rejected=false;try{fragments(native!,proof!);}catch{rejected=true;}if(!rejected)throw Error('SiLU-heads mutation escaped '+name);
   }
  }
  let rejected=false;try{check(source+'\n',lean);}catch{rejected=true;}if(!rejected)throw Error('SiLU-heads source mutation escaped');
 }
}
if(import.meta.main){await checkSiluHeads128SourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed selected SiLU/QKV heads match pinned source.');}
