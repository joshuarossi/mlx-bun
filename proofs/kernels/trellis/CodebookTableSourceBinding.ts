// Exact selected source-fragment binding; not a general C++ frontend or a
// proof of the Metal compiler, template metadata extraction, or barrier HW.
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkCodebookBitsSourceBinding} from './CodebookBitsSourceBinding';
const here=new URL('./',import.meta.url);
function literal(lean:string,name:string):string {
  const raw=[...lean.matchAll(new RegExp('^def '+name+' : String := r#"([\\s\\S]*?)"#','gm'))];
  if(raw.length===1)return raw[0]![1]!;
  const quoted=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
  if(quoted.length!==1)throw Error('Missing unique Lean literal '+name);
  return JSON.parse(quoted[0]![1]!);
}
function unique(source:string,fragment:string):void {
 const at=source.indexOf(fragment);
 if(at<0||source.indexOf(fragment,at+1)>=0)throw Error('Expected exact unique selected fragment');
}
export async function checkCodebookTableSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const repository=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkCodebookBitsSourceBinding({repositoryRoot:repository.pathname,
   leanSource:new URL('proofs/kernels/trellis/CodebookBitsSyntax.lean',repository).pathname,selfTest:options.selfTest});
 const launch=await Bun.file(new URL('packages/inference/src/kernels/trellis/launch.ts',repository)).text();
 if(new Bun.CryptoHasher('sha256').update(launch).digest('hex')!=='da0a19922ccc93935c5cab869de040d4b759271df08496c88c7371c386724052')throw Error('Pinned launch constants changed');
 unique(launch,'export const TRELLIS_CODEBOOK_ROW_THREADS = 1024;');
 unique(launch,'export const TRELLIS_CODEBOOK_DOWN_THREADS = 256;');
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('CodebookTableSyntax.lean',here)).text();
 const loop=literal(lean,'sourceLoop'),barrier=literal(lean,'sourceBarrier');
 for(const [file,declaration] of [['gate-up-codebook.ts','gateDeclaration'],['down-codebook.ts','downDeclaration']] as const){
  const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/'+file,repository)).text();
  unique(source,loop);unique(source,literal(lean,declaration));
  // Gate/up has further barriers later: only the first must follow the table
  // and activation staging. Down's first barrier immediately follows the loop.
  const firstBarrier=source.indexOf(barrier,source.indexOf('const SOURCE = String.raw`'));
  if(firstBarrier<source.indexOf(loop)+loop.length)throw Error('Missing post-table threadgroup barrier');
 }
 if(options.selfTest){
  const mutations=[loop.replace('i += (uint)THREADS','i += 1u'),loop.replace('trellis_y(i)','trellis_y(0u)'),
    loop.replace('codebook[i]','codebook[0]'),loop.replace('1u << (uint)L','1u << 11u'),loop+' '];
  for(const mutation of mutations){let rejected=false;try{unique(loop,mutation);}catch{rejected=true;}
    if(mutation===loop||!rejected)throw Error('Table mutation escaped source binding');}
 }
}
if(import.meta.main){await checkCodebookTableSourceBinding({selfTest:process.argv.includes('--self-test')});
 console.log('Selected float table declarations, parsed loop, helper bodies and following threadgroup barrier match pinned D1 source.');}
