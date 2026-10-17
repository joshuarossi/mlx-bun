// Trusted exact-fragment extraction; Lean checks tokenization, parsing and
// selected source semantics. Native metadata/uint4 coherence/compiler remain
// external. The delegated guard pins full original sources and selected route.
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkPackedArraySourceBinding} from './PackedArraySourceBinding';
const here=new URL('./',import.meta.url);
function literal(text:string,name:string):string{
 const matches=[...text.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one exact literal '+name);return JSON.parse(matches[0]![1]!);
}
function positions(source:string,fragment:string):number[]{const result:number[]=[];let at=0;while(true){const next=source.indexOf(fragment,at);if(next<0)return result;result.push(next);at=next+fragment.length;}}
export async function checkGateInputSourceBinding(options:{repositoryRoot?:string;syntaxSource?:string;contextSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkPackedArraySourceBinding({repositoryRoot:root.pathname,
  leanSource:new URL('proofs/kernels/trellis/PackedArraySyntax.lean',root).pathname,selfTest:options.selfTest});
 const syntax=await Bun.file(options.syntaxSource?resolve(options.syntaxSource):new URL('GateInputSyntax.lean',here)).text();
 const context=await Bun.file(options.contextSource?resolve(options.contextSource):new URL('GateInputContext.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text();
 const names=['declarationSource','constantSource','loopSource','chunkSource','unpackSource'];let previous=-1;
 for(const name of names){const text=literal(name==='declarationSource'||name==='chunkSource'||name==='constantSource'?context:syntax,name);const found=positions(source,text);if(found.length!==1)throw Error('Exact source fragment multiplicity changed '+name);if(found[0]!<=previous)throw Error('Source phase order changed '+name);previous=found[0]!;}
 const loopEnd=positions(source,literal(syntax,'loopSource'))[0]!+literal(syntax,'loopSource').length;
 const barrier='threadgroup_barrier(metal::mem_flags::mem_threadgroup);';const barrierAt=source.indexOf(barrier,loopEnd);
 if(barrierAt<loopEnd||barrierAt>=positions(source,literal(context,'chunkSource'))[0]!)throw Error('Staging barrier missing or moved');
 if(options.selfTest){const cases=[['loopSource','c += (uint)THREADS','c += 1u'],['loopSource','uint4*','uint2*'],
 ['loopSource','(c % N_RUNS) * 4u + c / N_RUNS','c'],['chunkSource','q * N_RUNS + run','q + run'],
 ['unpackSource','0xFFFF0000u','0x0000FFFFu'],['unpackSource','<< 16','<< 15'],['declarationSource','C / 8','C / 4'],['constantSource','32u','16u']];
 for(const [name,from,to] of cases){const text=literal(name==='declarationSource'||name==='chunkSource'||name==='constantSource'?context:syntax,name!);const changed=text.replace(from!,to!);if(changed===text||positions(source,changed).length!==0)throw Error('Mutation escaped exact binding '+name);}
 const withoutBarrier=source.slice(0,barrierAt)+source.slice(barrierAt+barrier.length);const next=withoutBarrier.indexOf(barrier,loopEnd);if(next>=0&&next<positions(withoutBarrier,literal(context,'chunkSource'))[0]!)throw Error('Barrier negative test ineffective');
 }
}
if(import.meta.main){await checkGateInputSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Exact GateRow uint4 staging, barrier placement, chunk selection and BF16 unpack match pinned source.');}
