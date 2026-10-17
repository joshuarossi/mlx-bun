import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkSiluHeads128SourceBinding} from './SiluHeads128SourceBinding.ts';
const here=new URL('./',import.meta.url);
const nativeHash='52c59772bf95e2cd8f7f813a69a7dfac0c352dadc3c2a1e0e550c054dd301145';
const leanHash='8a941a56671cf9331be2e8702f105f939e60ace641573ac9c1e1f596df8315e3';
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');
// Both sides of this reviewed host translation are pinned. Native descriptor
// extraction, floating literal decoding and compiler interpretation are separate.
function check(source:string,lean:string):void{
 if(hash(source)!==nativeHash)throw Error('SiLU-heads host source changed');
 if(hash(lean)!==leanHash)throw Error('SiLU-heads host translation changed');
}
export async function checkSiluHeads128HostSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkSiluHeads128SourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const source=await Bun.file(new URL('packages/inference/src/kernels/delta/silu-rms-heads.ts',root)).text();
 const lean=await Bun.file(new URL('SiluHeads128HostSelection.lean',here)).text();check(source,lean);
 if(options.selfTest){
  for(const [from,to] of [
   ['const keyWidth = qScale.size','const keyWidth = kScale.size'],
   ['x.ndim !== 3','x.ndim !== 2'],['2 * keyHeads * keyWidth + valueHeads * valueWidth','keyHeads * keyWidth + valueHeads * valueWidth'],
   ['keyWidth > 128','keyWidth > 256'],['valueWidth > 128','valueWidth > 256'],
   ['kScale.size !== keyWidth','kScale.size !== valueWidth'],['qScale.dtype !== x.dtype','qScale.dtype === x.dtype'],
   ['inputNames: ["x", "qscale", "kscale"]','inputNames: ["x", "kscale", "qscale"]'],
   ['kernel.apply([x, qScale, kScale]','kernel.apply([x, kScale, qScale]'],
   ['shape: [batch!, sequence!, valueHeads, valueWidth]','shape: [batch!, sequence!, keyHeads, keyWidth]'],
   ['grid: [32 * (2 * keyHeads + valueHeads), batch! * sequence!, 1]','grid: [32 * (keyHeads + valueHeads), batch! * sequence!, 1]'],
   ['threadGroup: [32, 1, 1]','threadGroup: [64, 1, 1]'],
   ['DK: keyWidth, DV: valueWidth','DK: valueWidth, DV: keyWidth'],
  ] as const){
   const changed=source.replace(from,to);if(changed===source)throw Error('Ineffective SiLU-heads host mutation');
   let rejected=false;try{check(changed,lean);}catch{rejected=true;}if(!rejected)throw Error('SiLU-heads host mutation escaped');
  }
  let rejected=false;try{check(source,lean+'\n');}catch{rejected=true;}
  if(!rejected)throw Error('SiLU-heads host translation mutation escaped');
 }
}
if(import.meta.main){await checkSiluHeads128HostSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Reviewed selected SiLU/QKV host launch matches pinned source.');}
