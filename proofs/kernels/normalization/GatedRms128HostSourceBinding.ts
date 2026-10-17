import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGatedRms128SourceBinding} from './GatedRms128SourceBinding.ts';
const here=new URL('./',import.meta.url);
const nativeHash='e402118d33622ef62a017e964c257e23456d03f96b0fdc855b48704ff0fb954f';
const leanHash='feee25783f8991e20751e3ec9fd9277066f0a37bc831893d1015183e09475d07';
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');
// Pins both sides of the reviewed host translation; this does not claim a
// verified TypeScript frontend or native descriptor/compiler attachment.
function check(source:string,lean:string):void{
 if(hash(source)!==nativeHash)throw Error('Gated RMS host source changed');
 if(hash(lean)!==leanHash)throw Error('Gated RMS host translation changed');
}
export async function checkGatedRms128HostSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGatedRms128SourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const source=await Bun.file(new URL('packages/inference/src/kernels/gated-rms-norm.ts',root)).text();
 const lean=await Bun.file(new URL('GatedRms128HostSelection.lean',here)).text();check(source,lean);
 if(options.selfTest){
  for(const [from,to] of [
   ['Math.min(1024, Math.ceil(width / 128) * 32)','Math.min(1024, Math.ceil(width / 64) * 32)'],
   ['new Uint32Array(new Float32Array([eps]).buffer)','new Uint32Array([eps])'],
   ['inputNames: ["x", "gate", "weight"]','inputNames: ["gate", "x", "weight"]'],
   ['kernel.apply([x, gate, weight]','kernel.apply([gate, x, weight]'],
   ['outputs: [{ shape, dtype: x.dtype }]','outputs: [{ shape, dtype: gate.dtype }]'],
   ['grid: [x.size / width * threads, 1, 1]','grid: [x.size * threads, 1, 1]'],
   ['threadGroup: [threads, 1, 1]','threadGroup: [threads, 2, 1]'],
   ['templateDtypes: { T: x.dtype }','templateDtypes: { T: weight.dtype }'],
   ['templateInts: { D: width, THREADS: threads, EPS: epsBits }','templateInts: { D: width, THREADS: threads, EPS: eps }'],
  ] as const){
   const changed=source.replace(from,to);if(changed===source)throw Error('Ineffective gated RMS host mutation');
   let rejected=false;try{check(changed,lean);}catch{rejected=true;}if(!rejected)throw Error('Gated RMS host mutation escaped');
  }
  let rejected=false;try{check(source,lean+'\n');}catch{rejected=true;}
  if(!rejected)throw Error('Gated RMS host translation mutation escaped');
 }
}
if(import.meta.main){await checkGatedRms128HostSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Reviewed gated RMS host launch matches pinned source.');}
