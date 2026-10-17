import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const hashes=['01bc537389638efe43a9bedeeb2008484864772022ac56e106a3f9911bcaa1aa','9e6304129e8a2425aae4d913e8b9eefb2dac4bf8afac5c460cfc9331c6c48031'];
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const norm=(s:string)=>s.replace(/\/\/[^\n]*/g,'').replace(/\s+/g,'');
export function checkExtracted(host:string,copy:string,caller:string){
 const start=host.indexOf('void RMSNorm::eval_gpu('),end=host.indexOf('void RMSNormVJP::',start),rms=host.slice(start,end<0?undefined:end);if(start<0)throw Error('Missing RMS normalization host');
 for(const text of ['bool no_copy = x.flags().contiguous && x.strides()[x.ndim() - 1] == 1;','if (no_copy && x.ndim() > 1)','no_copy &= (s == 0 || s == x.shape().back() || x.shape(-2) == 1);','if (no_copy)','array x_copy = contiguous_copy_gpu(x, s);','out.copy_shared_buffer(x_copy);','return x_copy;','const array x = set_output(inputs[0]);'])if(!norm(rms).includes(norm(text)))throw Error('Query RMS required-copy host branch changed');
 const source=copy.match(/array contiguous_copy_gpu\(const array& arr, const Stream& s\) \{[^]*?\n\}/)?.[0];
 const expected='array contiguous_copy_gpu(const array& arr, const Stream& s) { array arr_copy(arr.shape(), arr.dtype(), nullptr, {}); copy_gpu(arr, arr_copy, CopyType::General, s); return arr_copy; }';
 if(!source||norm(source)!==norm(expected))throw Error('Query RMS contiguous General copy changed');
 for(const text of ['const [qHeads, gateHeads] = ops.split(qpr, [this.headDim], -1)','let q = this.qNorm.forward(qHeads);','qHeads.dispose();','q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));'])if(!norm(caller).includes(norm(text)))throw Error('Selected Q normalization caller order changed');
}
function reject(f:()=>void){let rejected=false;try{f();}catch{rejected=true;}if(!rejected)throw Error('Query-copy source mutation accepted');}
export async function checkMlxAttentionQueryCopySourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend`);
 const host=await Bun.file(resolve(dir,'metal/normalization.cpp')).text(),copy=await Bun.file(resolve(dir,'gpu/copy.cpp')).text(),caller=await Bun.file(resolve(root,'../packages/inference/src/models/qwen/blocks.ts')).text();
 if(hash(host)!==hashes[0]||hash(copy)!==hashes[1])throw Error('Pinned query copy SHA changed');checkExtracted(host,copy,caller);
 if(options.selfTest){for(const [a,b] of [['x.strides()[x.ndim() - 1] == 1','x.strides()[x.ndim() - 1] == 0'],['s == x.shape().back()','s != x.shape().back()'],['out.copy_shared_buffer(x_copy);','out.copy_shared_buffer(x);'],['return x_copy;','return x;']] as const){const bad=host.replace(a,b);if(hash(bad)===hashes[0])throw Error('Mutation missed production RMS branch');reject(()=>checkExtracted(bad,copy,caller));}
 const start=copy.indexOf('array contiguous_copy_gpu('),bad=copy.slice(0,start)+copy.slice(start).replace('CopyType::General','CopyType::Vector');reject(()=>checkExtracted(host,bad,caller));
 reject(()=>checkExtracted(host,copy,caller.replace('this.qNorm.forward(qHeads)','this.qNorm.forward(gateHeads)')));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxAttentionQueryCopySourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX Q normalization contiguous-copy source binding passed.');}
