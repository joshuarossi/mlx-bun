import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGatePointerSourceBinding} from './GatePointerSourceBinding';
const here=new URL('./',import.meta.url);
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const hostHash='175d3449db58ee14755a40cabd2df91c3efc015eb5962b414cb8b98edbea48e0';
const leanHash='9119be3cdc8619d3071ef7289b11cf16be988445b18b77fb8035285a7b0fa6a7';
// Reviewed host translation only. Metadata/contiguous reshape attachments,
// native descriptors, selected scalar lowering and submission remain boundaries.
function check(source:string,constants:string,lean:string):void{
 const start=source.indexOf('export function gateUpCodebookRow(');
 if(start<0||source.indexOf('export function gateUpCodebookRow(',start+1)>=0||hash(source.slice(start))!==hostHash)
  throw Error('Gate reviewed host source changed');
 for(const fragment of ['const THREADGROUPS = 160;'])if(!source.includes(fragment))throw Error('Gate group constant changed');
 for(const fragment of ['export const TRELLIS_CODEBOOK_ROW_THREADS = 1024;','export const TRELLIS_CODEBOOK_ROW_SG_PER_TG = 32;'])
  if(!constants.includes(fragment))throw Error('Gate thread constants changed');
 if(hash(lean)!==leanHash)throw Error('Gate reviewed host translation changed');
}
export async function checkGateHostSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGatePointerSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const [source,constants,lean]=await Promise.all([
  Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text(),
  Bun.file(new URL('packages/inference/src/kernels/trellis/launch.ts',root)).text(),
  Bun.file(new URL('GateHostSelection.lean',here)).text()]);check(source,constants,lean);
 if(options.selfTest){
  const reject=(s:string,c:string,l:string)=>{let rejected=false;try{check(s,c,l);}catch{rejected=true;}if(!rejected)throw Error('Gate host mutation escaped');};
  for(const [from,to] of [
   ['g.axis !== 1','g.axis !== 0'],['g.rows !== u.rows','g.rows === u.rows'],['g.cols !== u.cols','g.cols === u.cols'],
   ['g.T !== u.T','g.T === u.T'],['g.L > 12','g.L > 13'],['x.size !== x.shape.at(-1)','x.size === x.shape.at(-1)'],
   ['(4 << g.L) + 2 * g.cols','(4 << g.L) + g.cols'],['> 32768','> 65536'],
   ['[1, g.inFeatures]','[1, g.cols + 1]'],['[1, g.rows]','[2, g.rows]'],['dtype: x.dtype','dtype: Dtype.float32'],
   ['Math.min(THREADGROUPS','Math.max(THREADGROUPS'],['KG: g.k, KU: u.k','KG: u.k, KU: g.k'],
   ['g.k !== u.k && tail === "split"','tail === "split"'],['? 1 : 0','? 0 : 1'],
   ['const THREADGROUPS = 160;','const THREADGROUPS = 80;']]){
    const changed=source.replace(from!,to!);if(changed===source)throw Error('Ineffective gate host mutation');reject(changed,constants,lean);
  }
  reject(source,constants.replace('ROW_THREADS = 1024','ROW_THREADS = 512'),lean);
  reject(source,constants.replace('ROW_SG_PER_TG = 32','ROW_SG_PER_TG = 16'),lean);
  reject(source,constants,lean.replace('def groups : Nat := 160','def groups : Nat := 80'));
 }
}
if(import.meta.main){await checkGateHostSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Reviewed gate host geometry, dtype, workspace and mixed-width TAIL selection match pinned source.');}
