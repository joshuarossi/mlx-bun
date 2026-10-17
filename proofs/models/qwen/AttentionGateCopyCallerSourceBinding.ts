import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const norm=(s:string)=>s.replace(/\/\*[\s\S]*?\*\//g,'').replace(/\/\/[^\n]*/g,'').replace(/\s+/g,'');
const stages=[
 'const qp = this.qProj.forward(x, rowsApart);',
 'ops.reshape(qp, [B, L, this.nHeads, this.headDim * 2])',
 'ops.split(qpr, [this.headDim], -1)',
 'ops.reshape(gateHeads, [B, L, this.nHeads * this.headDim])',
 'let k = this.kProj.forward(x, rowsApart);',
 'let v = this.vProj.forward(x, rowsApart);',
 'let q = this.qNorm.forward(qHeads);',
 'q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));',
 'k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));',
 'k = disposing(k, this.kNorm.forward(k));',
 'k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));',
 'v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));',
 'v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));',
 'q = disposing(q, position(q));',
 'k = disposing(k, position(k));',
 'const read = this.reads.read(cache, phase, k, v);',
 'attn = read.attend(q, this.scale);',
 'const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);',
 'const merged = ops.reshape(attnT, [B, L, -1]);',
 'const sig = ops.sigmoid(gate);',
 'const gated = ops.mul(merged, sig);',
 'const out = this.oProj.forward(gated, rowsApart);',
] as const;
// This guard binds the reviewed caller order to actual production statements;
// it is not a TypeScript frontend/compiler correctness theorem.
export function checkExtracted(source:string){
 const start=source.indexOf('export class Qwen3Attention<');if(start<0)throw Error('Missing selected attention class');
 const caller=norm(source.slice(start));let cursor=0;
 for(const stage of stages){const index=caller.indexOf(norm(stage),cursor);if(index<0)throw Error('Attention stage missing or reordered');cursor=index+norm(stage).length;}
}
function reject(f:()=>void){let rejected=false;try{f();}catch{rejected=true;}if(!rejected)throw Error('Caller stage mutation accepted');}
export async function checkAttentionGateCopyCallerSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),source=await Bun.file(resolve(root,'../packages/inference/src/models/qwen/blocks.ts')).text();checkExtracted(source);
 if(options.selfTest){for(const stage of [stages[3],stages[6],stages[9],stages[13],stages[16],stages[19],stages[20]])reject(()=>checkExtracted(source.replace(stage,'')));
 for(const [a,b] of [[stages[4],stages[5]],[stages[13],stages[14]],[stages[19],stages[20]]] as const){const swapped=source.replace(a,'__STAGE_SWAP__').replace(b,a).replace('__STAGE_SWAP__',b);reject(()=>checkExtracted(swapped));}
 reject(()=>checkExtracted(source.replace('ops.split(qpr, [this.headDim], -1)','ops.split(qpr, [this.headDim * 2], -1)')));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkAttentionGateCopyCallerSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Attention gate-copy caller stage order binding passed.');}
