import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const sourceHash='27353e109e7f91bc030fbd493785fcc4839eeccea2d585c22d610ba8f9e909d0';
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');
function closing(source:string,opening:number):number{
  let depth=0;
  for(let i=opening;i<source.length;++i){if(source[i]==='{')++depth;if(source[i]==='}'&&--depth===0)return i;}
  throw new Error('Unclosed loop/cell block');
}
// Trusted host extraction replaces only the separately parsed cell body with
// a CELL marker. All counter, guard and loop-shell bytes remain unchanged.
export function extractLoops(source:string):string[]{
  const raw=source.match(/const SOURCE = String.raw`([\s\S]*?)`;/)?.[1];
  if(!raw)throw new Error('Residual RMS raw kernel missing');
  const result:string[]=[];let next=0;
  for(;;){
    const start=raw.indexOf('for (uint r',next);if(start<0)break;
    const opening=raw.indexOf('{',start);if(opening<0)throw new Error('Missing loop opening');
    const end=closing(raw,opening);const loop=raw.slice(start,end+1);
    const guard=loop.indexOf('if (col < uint(D))');if(guard<0)throw new Error('Missing cell guard');
    const cell=loop.indexOf('{',guard);if(cell<0)throw new Error('Missing cell opening');
    result.push(loop.slice(0,cell)+'{ CELL; }'+loop.slice(closing(loop,cell)+1));
    next=end+1;
  }
  if(result.length!==2)throw new Error('Expected both residual RMS source loops');
  return result;
}
export function checkSource(source:string,lean:string){
  if(hash(source)!==sourceHash)throw new Error('Residual RMS source SHA256 mismatch');
  const literal=lean.match(/def sourceBody : String := r#"([\s\S]*?)"#/);
  if(!literal||extractLoops(source).some(loop=>loop!==literal[1]))throw new Error('Parsed loop shell mismatch');
}
export async function checkResidualRmsLoopSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  const source=await Bun.file(resolve(root,'../packages/inference/src/kernels/residual-rms-norm.ts')).text();
  const lean=await Bun.file(resolve(root,'kernels/normalization/ResidualRmsLoopSyntax.lean')).text();
  checkSource(source,lean);
  if(options.selfTest){
    for(const bad of [
      source.replace('r += uint(THREADS) * 4u','r += uint(THREADS) * 8u'),
      source.replace('uint i = 0','uint i = 1'),
      source.replace('i < 4u','i <= 4u'),
      source.replace('++i','i++'),
      source.replace('tid * 4u + i','tid * 2u + i'),
      source.replace('if (col < uint(D))','if (col <= uint(D))'),
      source.replace('r += uint(THREADS)','r = uint(THREADS)'),
    ]){let rejected=false;try{checkSource(bad,lean);}catch{rejected=true;}if(!rejected)throw new Error('Source loop mutation accepted');}
    for(const bad of [lean.replaceAll('uint i = 0','uint i = 1'),lean.replaceAll('tid * 4u + i','tid * 2u + i')]){
      let rejected=false;try{checkSource(source,bad);}catch{rejected=true;}if(!rejected)throw new Error('Lean loop literal mutation accepted');
    }
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  await checkResidualRmsLoopSourceBinding({selfTest:process.argv.includes('--self-test')});
  console.log('Residual RMS parsed loop control source binding passed (host extraction boundary).');
}
