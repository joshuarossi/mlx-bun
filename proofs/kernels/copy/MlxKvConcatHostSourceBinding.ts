import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const sourceHash='604d3bea4ce0e87eda3ca550200fc06eb78d949de49db42ef8bf12fb331e0b6c';
const norm=(s:string)=>s.replace(/\/\*[^]*?\*\//g,'').replace(/\/\/[^\n]*/g,'').replace(/\s+/g,'');
function body(s:string){const start=s.indexOf('void concatenate_gpu(');if(start<0)throw Error('Missing native concatenate_gpu');let at=s.indexOf('{',start),depth=1,end=at+1;for(;depth&&end<s.length;end++){if(s[end]==='{')depth++;if(s[end]==='}')depth--;}if(depth)throw Error('Unclosed native concat');return s.slice(start,end);}
export function checkExtracted(host:string,lean:string){const expected=lean.match(/def hostSource : String := r#"([^]*?)"#/u)?.[1];if(!expected||norm(body(host))!==norm(expected))throw Error('Native concatenate_gpu differs from reviewed model source');}
function reject(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error('Concat source mutation accepted');}
export async function checkMlxKvConcatHostSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
 const host=await Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/slicing.cpp`)).text(),lean=await Bun.file(resolve(root,'kernels/copy/MlxKvConcatHost.lean')).text();
 if(createHash('sha256').update(host).digest('hex')!==sourceHash)throw Error('Pinned native concat source SHA changed');checkExtracted(host,lean);
 if(options.selfTest){for(const [before,after] of [
 ['sizes.push_back(p.shape(axis));','sizes.push_back(1);'],
 ['std::partial_sum(sizes.cbegin(), sizes.cend(), sizes.begin());','sizes.clear();'],
 ['size_t data_offset = strides[axis] * sizes[i];','size_t data_offset = sizes[i];'],
 ['flags.contiguous = false;','flags.contiguous = true;'],
 ['compute_encoder.start_concurrent();','compute_encoder.end_concurrent();'],
 ['copy_gpu_inplace(inputs[i], out_slice, CopyType::GeneralGeneral, s);','copy_gpu_inplace(inputs[i], out_slice, CopyType::Vector, s);'],
 ] as const){const bad=host.replace(before,after);if(bad===host)throw Error('Mutation missed native concat production body');reject(()=>checkExtracted(bad,lean));}}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxKvConcatHostSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Native nonempty KV concatenation host source binding passed.');}
