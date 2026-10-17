// Trusted exact-fragment extraction plus full source pins. The Lean parser
// handles the loop/array syntax; TS metadata extraction, outer pointer setup,
// compiler and private/global address-space execution remain explicit boundaries.
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkCodebookWindowSourceBinding} from './CodebookWindowSourceBinding';
import {checkCodebookTableSourceBinding} from './CodebookTableSourceBinding';
const here=new URL('./',import.meta.url);
const gate=['gateDeclaration','upDeclaration','gateLoad','gateWrap','upLoad','upWrap','gateVirtualZero','upVirtualZero','gateVirtual','upVirtual'];
const down=['downIndexDeclaration','downIndex','downPairDeclaration','downPairLoad','downWordsDeclaration','downPairAlign',
  'downVirtualZero','downVirtual','downTailDeclaration','downTailLoad','downWordsDeclaration','downTailAlign','downVirtualZero','downVirtual'];
function exactLiteral(lean:string,name:string):string{
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];
 if(matches.length!==1)throw Error('Expected one Lean literal '+name);
 return JSON.parse(matches[0]![1]!);
}
function locations(source:string,fragment:string):number[]{let at=0,result:number[]=[];
 while(true){const next=source.indexOf(fragment,at);if(next<0)return result;result.push(next);at=next+fragment.length;}}
function checkOrdered(source:string,fields:string[],lean:string):void{
 const expected=new Map<string,number>();for(const field of fields)expected.set(field,(expected.get(field)??0)+1);
 for(const [field,count] of expected)if(locations(source,exactLiteral(lean,field)).length!==count)throw Error('Source fragment multiplicity changed: '+field);
 const used=new Map<string,number>();let previous=-1;
 for(const field of fields){const count=used.get(field)??0;const pos=locations(source,exactLiteral(lean,field))[count]!;
  if(pos<=previous)throw Error('Source phase order changed: '+field);previous=pos;used.set(field,count+1);}
}
export async function checkPackedArraySourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkCodebookWindowSourceBinding({repositoryRoot:root.pathname,
  leanSource:new URL('proofs/kernels/trellis/CodebookWindowSyntax.lean',root).pathname,selfTest:options.selfTest});
 await checkCodebookTableSourceBinding({repositoryRoot:root.pathname,
  leanSource:new URL('proofs/kernels/trellis/CodebookTableSyntax.lean',root).pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('PackedArraySyntax.lean',here)).text();
 const gateSource=await Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text();
 const downSource=await Bun.file(new URL('packages/inference/src/kernels/trellis/down-codebook.ts',root)).text();
 checkOrdered(gateSource,gate,lean);checkOrdered(downSource,down,lean);
 if(locations(downSource,'const SPLITS = 128, P = 16, U = 2;').length!==1)throw Error('Selected paired preload width changed');
 if(options.selfTest){
  const cases=[['gateLoad','gW0 + i','gW0 + 0u'],['gateWrap','t0 == 0u','t0 == 1u'],
   ['gateVirtual','>> 16','>> 15'],['downPairLoad','ld[u][i]','ld[0][i]'],
   ['downPairAlign','shifted ?','true ?'],['downIndex','% WPB','% NL'],['gateVirtual','i <=','i < =']];
  for(const [name,from,to] of cases){const fragment=exactLiteral(lean,name!),changed=fragment.replace(from!,to!);
   if(changed===fragment)throw Error('Mutation did not alter source');
   if(locations(name!.startsWith('gate')?gateSource:downSource,changed).length!==0)throw Error('Changed fragment escaped exact binding');}
 }
}
if(import.meta.main){await checkPackedArraySourceBinding({selfTest:process.argv.includes('--self-test')});
 console.log('Exact selected gate/up and down packed-array declarations/load/alignment/virtual loops match pinned source and phase order.');}
