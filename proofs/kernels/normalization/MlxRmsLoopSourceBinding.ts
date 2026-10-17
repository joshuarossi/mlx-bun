import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const sourceHash='b2e04e377fdad1d645581f9beeaf9cbb06d1ad32926161e06cbc15240caf12bf';
const definesHash='a2930dbd644c69c4b66a511a094034217f3c03f48e29a1613f601532150f9163';
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');
function closing(source:string,opening:number):number{
  let depth=0;for(let i=opening;i<source.length;++i){if(source[i]==='{')++depth;if(source[i]==='}'&&--depth===0)return i;}
  throw new Error('Unclosed MLX loop/cell block');
}
// Trusted extraction replaces only arithmetic bodies covered by separate cell
// parsers. The signed/unsigned counters, full/tail guards and stride remain.
export function extractLoops(source:string):string[]{
  const start=source.indexOf('[[kernel]] void rms_looped(');
  const end=source.indexOf('template <typename T',start+1);
  if(start<0||end<0)throw new Error('MLX rms_looped boundaries missing');
  const kernel=source.slice(start,end);const loops:string[]=[];let next=0;
  for(;;){
    const start=kernel.indexOf('for (uint r',next);if(start<0)break;
    const opening=kernel.indexOf('{',start);const end=closing(kernel,opening);
    let loop=kernel.slice(start,end+1);
    const full=loop.indexOf('for (int i');const fullOpen=loop.indexOf('{',full);
    if(full<0||fullOpen<0)throw new Error('MLX full branch missing');
    loop=loop.slice(0,fullOpen)+'{ CELL; }'+loop.slice(closing(loop,fullOpen)+1);
    const tail=loop.indexOf('if ((r + lid * N_READS + i) < axis_size)');
    const tailOpen=loop.indexOf('{',tail);
    if(tail<0||tailOpen<0)throw new Error('MLX guarded tail missing');
    loop=loop.slice(0,tailOpen)+'{ CELL; }'+loop.slice(closing(loop,tailOpen)+1);
    loops.push(loop);next=end+1;
  }
  if(loops.length!==2)throw new Error('Expected both MLX rms_looped source loops');
  return loops;
}
export function checkExtracted(source:string,lean:string){
  const literal=lean.match(/def sourceBody : String := r#"([\s\S]*?)"#/);
  if(!literal||extractLoops(source).some(loop=>loop!==literal[1]))throw new Error('MLX parsed loop shell mismatch');
}
export function checkSource(source:string,defines:string,lean:string){
  if(hash(source)!==sourceHash||hash(defines)!==definesHash)throw new Error('MLX RMS source/defines SHA256 mismatch');
  if(!defines.includes('constexpr int RMS_N_READS = 4;'))throw new Error('MLX RMS_N_READS specialization changed');
  checkExtracted(source,lean);
}
function rejected(check:()=>void){let failed=false;try{check();}catch{failed=true;}if(!failed)throw new Error('MLX RMS loop guard mutation accepted');}
export async function checkMlxRmsLoopSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  const path=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels`);
  const source=await Bun.file(resolve(path,'rms_norm.metal')).text();
  const defines=await Bun.file(resolve(path,'defines.h')).text();
  const lean=await Bun.file(resolve(root,'kernels/normalization/MlxRmsLoopSyntax.lean')).text();
  checkSource(source,defines,lean);
  if(options.selfTest){
    const start=source.indexOf('[[kernel]] void rms_looped(');
    const mutate=(from:string,to:string)=>source.slice(0,start)+source.slice(start).replace(from,to);
    for(const bad of [mutate('r += lsize * N_READS','r += lsize'),mutate('r < axis_size','r <= axis_size'),
      mutate('N_READS <= axis_size','N_READS < axis_size'),mutate('int i = 0','int i = 1'),
      mutate('i++','++i'),mutate('lid * N_READS + i','lid + i')]){
      rejected(()=>checkSource(bad,defines,lean));rejected(()=>checkExtracted(bad,lean));
    }
    rejected(()=>checkSource(source,defines.replace('RMS_N_READS = 4','RMS_N_READS = 8'),lean));
    rejected(()=>checkExtracted(source,lean.replaceAll('r += lsize * N_READS','r += lsize')));
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  await checkMlxRmsLoopSourceBinding({selfTest:process.argv.includes('--self-test')});
  console.log('MLX RMS parsed loop source binding passed (host extraction boundary).');
}
