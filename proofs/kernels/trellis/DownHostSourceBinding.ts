import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkDownFoldSourceBinding} from './DownFoldSourceBinding';
const here=new URL('./',import.meta.url);
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const hostHash='c648079064ba368181e2f323bf70e1f47f0e9c8564a8d1f337f0788afc5fa574';
const leanHash="bb897b7750776e01756d800db0fca5b3904b1226f81a65fd744914da98ddcbb5";
// Pins a reviewed translation. No TypeScript frontend, native descriptor,
// contiguous-buffer attachment, command dependency, or lifetime proof is claimed.
function check(source:string,constants:string,lean:string):void{
 const start=source.indexOf('function launch(');
 if(start<0||source.indexOf('function launch(',start+1)>=0||hash(source.slice(start))!==hostHash)
  throw Error('Down reviewed host source changed');
 if(!source.includes('const SPLITS = 128, P = 16, U = 2;')||
    !constants.includes('export const TRELLIS_CODEBOOK_DOWN_THREADS = 256;'))throw Error('Down host constants changed');
 if(hash(lean)!==leanHash)throw Error('Down reviewed host translation changed');
}
export async function checkDownHostSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkDownFoldSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const [source,constants,lean]=await Promise.all([
  Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text(),
  Bun.file(new URL('packages/inference/src/kernels/trellis/launch.ts',root)).text(),
  Bun.file(new URL('DownHostSelection.lean',here)).text()]);
 check(source,constants,lean);
 if(options.selfTest){
  const reject=(s:string,c:string,l:string)=>{let rejected=false;try{check(s,c,l);}catch{rejected=true;}if(!rejected)throw Error('Down host mutation escaped');};
  for(const [from,to] of [
   ['x2.shape[0] !== 1','x2.shape[0] !== 2'],['g.axis !== 0','g.axis !== 1'],['g.T !== 256','g.T !== 128'],
   ['g.L > 12','g.L > 13'],['g.cols % 256','g.cols % 128'],['Math.ceil(groupsPerSplit / 2)','Math.floor(groupsPerSplit / 2)'],
   ['[1, 32, g.cols]','[1, 16, g.cols]'],['dtype: Dtype.float32','dtype: Dtype.float16'],
   ['32 * Math.ceil','16 * Math.ceil'],['templateDtypes: { T: x2.dtype }','templateDtypes: { T: Dtype.float32 }'],
   ['partial!.dispose();','out!.dispose();'],['g.k !== 2 && g.k !== 4','g.k !== 2 && g.k !== 3'],
   ['g.blockInterleave !== 2','g.blockInterleave !== 1'],['const SPLITS = 128','const SPLITS = 64']]){
    const changed=source.replace(from!,to!);if(changed===source)throw Error('Ineffective down host mutation');reject(changed,constants,lean);
  }
  reject(source,constants.replace('DOWN_THREADS = 256','DOWN_THREADS = 128'),lean);
  reject(source,constants,lean.replace('def positions : Nat := 16','def positions : Nat := 8'));
 }
}
if(import.meta.main){await checkDownHostSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Reviewed down host metadata, templates, shapes and launch geometry match pinned source.');}
