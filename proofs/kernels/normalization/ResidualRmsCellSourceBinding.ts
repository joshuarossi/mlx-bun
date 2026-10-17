import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const sourceHash='27353e109e7f91bc030fbd493785fcc4839eeccea2d585c22d610ba8f9e909d0';
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');

// This is a trusted host byte extractor, not a TypeScript/Metal compiler proof.
// It binds the parsed cell block to the shipped String.raw kernel and protects
// the surrounding source/dispatch against unreviewed changes.
export function extractCell(source:string):string{
  const raw=source.match(/const SOURCE = String.raw`([\s\S]*?)`;/)?.[1];
  if(!raw)throw new Error('Residual RMS raw kernel missing');
  const condition=raw.indexOf('if (col < uint(D)) {');
  if(condition<0)throw new Error('First-pass cell guard missing');
  const opening=raw.indexOf('{',condition);let depth=0;
  for(let i=opening;i<raw.length;++i){if(raw[i]==='{')++depth;if(raw[i]==='}'&&--depth===0)return raw.slice(opening,i+1);}
  throw new Error('Unclosed cell block');
}
export function checkSource(source:string,lean:string){
  if(hash(source)!==sourceHash)throw new Error('Residual RMS source SHA256 mismatch');
  const literal=lean.match(/def sourceBody : String := r#"([\s\S]*?)"#/);
  if(!literal||extractCell(source)!==literal[1])throw new Error('Parsed first-pass cell body mismatch');
  for(const part of ['const threads = Math.min(1024, Math.ceil(width / 128) * 32);','r += uint(THREADS) * 4u','templateDtypes: { T: x.dtype }','templateInts: { D: width, THREADS: threads, EPS: epsBits }'])
    if(!source.includes(part))throw new Error('Dispatch/source fragment mismatch');
}
export async function checkResidualRmsCellSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  const source=await Bun.file(resolve(root,'../packages/inference/src/kernels/residual-rms-norm.ts')).text();
  const lean=await Bun.file(resolve(root,'kernels/normalization/ResidualRmsCellSyntax.lean')).text();
  checkSource(source,lean);
  if(options.selfTest){
    for(const bad of [source.replace('T(float(x[index]) + float(update[index]))','T(x[index] + update[index])'),source.replace('const float v = float(value);','const float v = float(x[index]);'),source.replace('acc += v * v;','acc += float(x[index]) * v;'),source.replace('row * uint(D) + col','row * uint(D) + tid')]){
      let rejected=false;try{checkSource(bad,lean);}catch{rejected=true;}if(!rejected)throw new Error('Source mutation accepted');
    }
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  await checkResidualRmsCellSourceBinding({selfTest:process.argv.includes('--self-test')});
  console.log('Residual RMS first-pass cell source binding passed (host extraction boundary).');
}
