import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const hashes=['0a5492b65ae39ecb6d8b04e64ea5007e0a4ff60d8d9428559bfbfd03387ece2a','2dd13c2496f5d6f0856e4ca99db2ceb5c6d7dc0c344b9ba8e41ef3b7d7ed8a97'];
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const norm=(s:string)=>s.replace(/\s+/g,' ').trim();
function literal(s:string,n:string){const value=s.match(new RegExp(`def ${n} : String := r#"([\\s\\S]*?)"#`))?.[1];if(!value)throw Error('Missing output gate parsed literal');return value;}
function body(s:string,name:string){const struct=s.indexOf(`struct ${name} {`);if(struct<0)throw Error('Missing output gate overload');const sub=s.slice(struct),match=sub.match(/template <typename T>\s*T operator\(\)\(T x(?:, T y)?\) thread \{([\s\S]*?)\}/);if(!match)throw Error('Missing selected scalar overload');return match[1]!;}
export function checkExtracted(unary:string,binary:string,syntax:string,caller:string){
 if(norm(body(unary,'Sigmoid'))!==norm(literal(syntax,'sourceSigmoid')))throw Error('Sigmoid parsed source changed');
 if(norm(body(binary,'Multiply'))!==norm(literal(syntax,'sourceMultiply')))throw Error('Multiply parsed source changed');
 const selected='const sig = ops.sigmoid(gate); gate.dispose(); const gated = ops.mul(merged, sig); merged.dispose(); sig.dispose(); const out = this.oProj.forward(gated, rowsApart);';
 if(!norm(caller).includes(selected))throw Error('Attention gate caller operation order changed');
}
function reject(f:()=>void){let rejected=false;try{f();}catch{rejected=true;}if(!rejected)throw Error('Gate source mutation accepted');}
export async function checkMlxOutputGateSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels`);
 const unary=await Bun.file(resolve(dir,'unary_ops.h')).text(),binary=await Bun.file(resolve(dir,'binary_ops.h')).text(),syntax=await Bun.file(resolve(root,'kernels/attention/MlxOutputGateSyntax.lean')).text(),caller=await Bun.file(resolve(root,'../packages/inference/src/models/qwen/blocks.ts')).text();
 if(hash(unary)!==hashes[0]||hash(binary)!==hashes[1])throw Error('Pinned gate primitive SHA changed');checkExtracted(unary,binary,syntax,caller);
 if(options.selfTest){const start=unary.indexOf('struct Sigmoid {');for(const [a,b] of [['1 / (1 +','1 / (1 -'],['metal::exp(metal::abs(x))','metal::exp(x)'],['(x < 0) ? y : 1 - y','(x < 0) ? 1 - y : y']] as const){const bad=unary.slice(0,start)+unary.slice(start).replace(a,b);if(hash(bad)===hashes[0])throw Error('Mutation missed production sigmoid');reject(()=>checkExtracted(bad,binary,syntax,caller));}
 const startMul=binary.indexOf('struct Multiply {'),bad=binary.slice(0,startMul)+binary.slice(startMul).replace('return x * y;','return x + y;');reject(()=>checkExtracted(unary,bad,syntax,caller));
 for(const [a,b] of [['ops.sigmoid(gate)','ops.sigmoid(merged)'],['ops.mul(merged, sig)','ops.mul(gate, sig)']] as const)reject(()=>checkExtracted(unary,binary,syntax,caller.replace(a,b)));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxOutputGateSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX attention output gate scalar source binding passed.');}
