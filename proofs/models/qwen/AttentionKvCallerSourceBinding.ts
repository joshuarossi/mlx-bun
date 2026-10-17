import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const marker='updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {';
const norm=(s:string)=>s.replace(/\/\*[^]*?\*\//g,'').replace(/\/\/[^\n]*/g,'').replace(/\s+/g,'');
function method(source:string){const owner=source.indexOf('export class KVCache '),start=source.indexOf(marker,owner);if(owner<0||start<0)throw Error('Missing production KVCache updateAndFetch');let at=source.indexOf('{',start),depth=1,end=at+1;for(;depth&&end<source.length;end++){if(source[end]==='{')depth++;if(source[end]==='}')depth--;}if(depth)throw Error('Unclosed KV caller method');return source.slice(start,end);}
export function checkExtracted(caller:string,lean:string){
 const expected=lean.match(/def callerSource : String := r#"([^]*?)"#/u)?.[1];
 if(!expected||norm(method(caller))!==norm(expected))throw Error('Selected KV caller method differs from reviewed Lean source');
 const owner=caller.indexOf('export class KVCache '),prefix=caller.slice(owner,caller.indexOf(marker,owner));
 if(!norm(prefix).includes('staticreadonlySTEP=256;'))throw Error('KV caller growth extent changed');
}
function reject(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error('KV caller source mutation accepted');}
export async function checkAttentionKvCallerSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
 const caller=await Bun.file(resolve(root,'../packages/inference/src/state/kv.ts')).text(),lean=await Bun.file(resolve(root,'models/qwen/AttentionKvCallerSelection.lean')).text();
 checkExtracted(caller,lean);
 if(options.selfTest){for(const [before,after] of [
 ['static readonly STEP = 256;','static readonly STEP = 128;'],
 ['if (this.keys && this.values) {','if (this.keys || this.values) {'],
 ['this.keys = newK;','this.keys = ops.concatAxis([newK, newK], 2);'],
 ['this.values = newV;','this.values = newK;'],
 ['ops.concatAxis([oldK, newK], 2)','ops.concatAxis([oldK, newK], 1)'],
 ['const newK = ops.zeros([B, H, nSteps * KVCache.STEP, D], k.dtype);','const newK = ops.zeros([B, H, nSteps * KVCache.STEP, vD], k.dtype);'],
 ['if (prev % KVCache.STEP !== 0)','if (prev % KVCache.STEP === 0)'],
 ['this.offset += L;','this.offset += 1;'],
 ['ops.sliceUpdate(this.keys!, k, [0, 0, prev, 0]','ops.sliceUpdate(this.keys!, v, [0, 0, prev, 0]'],
 ] as const){const bad=caller.replace(before,after);if(bad===caller)throw Error('Mutation missed production KV source');reject(()=>checkExtracted(bad,lean));}}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkAttentionKvCallerSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Selected KV initial/existing/nonempty-growth caller source binding passed.');}
