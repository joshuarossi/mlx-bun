import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGatedOutputSourceBinding} from './GatedOutputSourceBinding';
const here=new URL('./',import.meta.url);
const nativeHash='3f0e11f777f57b6595d57d62ec3f8b8331cbfa7263183e1baa98892efe935aec';
const leanHash='92e3d1bfb3e7cc3a9477a1475871e4cf7124bd79eb11ca39779ffc48b974f485';
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');
// Both sides of the reviewed host translation are pinned. This is not a
// TypeScript frontend or a proof of native array/command attachment.
function check(source:string,lean:string):void{
 if(hash(source)!==nativeHash)throw Error('Gated reviewed host source changed');
 if(hash(lean)!==leanHash)throw Error('Gated reviewed host translation changed');
}
export async function checkGatedHostSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGatedOutputSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const source=await Bun.file(new URL('packages/inference/src/kernels/delta/gated.ts',root)).text();
 const lean=await Bun.file(new URL('GatedHostSelection.lean',here)).text();check(source,lean);
 if(options.selfTest){
  for(const [from,to] of [
   ['new Int32Array([T])','new Int32Array([T + 1])'],['const inputs = [q, k, v, g, beta, stateIn, tArr]','const inputs = [k, q, v, g, beta, stateIn, tArr]'],
   ['getKernel(mask !== null)','getKernel(mask === null)'],['shape: [B, T, Hv, Dv]','shape: [B, T, Hk, Dv]'],
   ['shape: [B, Hv, Dv, Dk]','shape: [B, Hv, Dk, Dv]'],['grid: [32, Dv, B * Hv]','grid: [16, Dv, B * Hv]'],
   ['threadGroup: [32, 4, 1]','threadGroup: [32, 1, 1]'],['templateInts: { Dk, Dv, Hk, Hv }','templateInts: { Dk, Dv, Hk, Hv: Hk }'],
   ['InT: q.dtype, StT: Dtype.float32','InT: q.dtype, StT: q.dtype'],['ensureRowContiguous: true','ensureRowContiguous: false'],
   ['differentiable = false','differentiable = true'],['launchRecurrence(q, k, v, g, beta, stateIn, mask)','launchRecurrence(k, q, v, g, beta, stateIn, mask)'],
  ] as const){
   const changed=source.replace(from,to);if(changed===source)throw Error('Ineffective gated host mutation');
   let rejected=false;try{check(changed,lean);}catch{rejected=true;}if(!rejected)throw Error('Gated host mutation escaped');
  }
  let rejected=false;try{check(source,lean+'\n');}catch{rejected=true;}
  if(!rejected)throw Error('Gated host translation mutation escaped');
 }
}
if(import.meta.main){await checkGatedHostSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Reviewed gated recurrence host route, templates and dispatch match pinned source.');}
