import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const pinned={'kernels/binary.h':'9a367967a48907ac6792be685bab4cc062f3ad916cccacb441c627d87a4b7898','binary.cpp':'2ff749f1ffb9ee35ed11d4c4c877c61578df51d0b5da3ecf3c0dfba3498c1c5e','jit_kernels.cpp':'8201a166cc426cd7b1f6983e5e6f282d3ca7a1992cc4c3a80fa42cf8dd237c46'};
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const norm=(s:string)=>s.replace(/\s+/g,' ').trim();
export function checkExtracted(kernel:string,host:string,jit:string,proof:string){
 const begin=kernel.indexOf('[[kernel]] void binary_vv('),start=kernel.indexOf('index *= N;',begin),end=kernel.indexOf('\n}',start);if(begin<0||start<0||end<0)throw Error('Missing binary vector body');
 const literal=proof.match(/def sourceBody : String := r#"([\s\S]*?)"#/)?.[1];if(!literal||norm(kernel.slice(start,end))!==norm(literal))throw Error('Binary vector parsed loop changed');
 for(const text of ['case BinaryOpType::VectorVector:\n      kname = "vv";','large = out.data_size() > UINT32_MAX;','work_per_thread = get_work_per_thread(a.dtype(), out.data_size());','size_t nthreads = ceildiv(out.data_size(), work_per_thread);','compute_encoder.set_input_array(a, arg_idx++);','compute_encoder.set_input_array(b, arg_idx++);','compute_encoder.set_output_array(outputs[0], arg_idx++);','compute_encoder.set_bytes<int>(out.data_size(), arg_idx++);','grid_dims = MTL::Size(nthreads, 1, 1);'])if(!host.includes(text))throw Error('Binary vv host dispatch changed');
 if(!jit.includes('"vv_" + lib_name, "binary_vv", in_t, out_t, op, 1'))throw Error('Binary vv specialization changed');
}
function reject(f:()=>void){let rejected=false;try{f();}catch{rejected=true;}if(!rejected)throw Error('Binary source mutation accepted');}
export async function checkMlxOutputGateBinarySourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal`),sources:Record<string,string>={};
 for(const [path,sha] of Object.entries(pinned)){sources[path]=await Bun.file(resolve(dir,path)).text();if(hash(sources[path]!)!==sha)throw Error('Pinned binary SHA changed');}
 const kernel=sources['kernels/binary.h']!,host=sources['binary.cpp']!,jit=sources['jit_kernels.cpp']!,proof=await Bun.file(resolve(root,'kernels/attention/MlxOutputGateBinaryLoop.lean')).text();
 checkExtracted(kernel,host,jit,proof);
 if(options.selfTest){const begin=kernel.indexOf('[[kernel]] void binary_vv(');for(const [a,b] of [['index *= N','index += N'],['index + N > size','index + N < size'],['index + i < size','index + i <= size'],['i < N','i <= N'],['a[index + i]','a[0]'],['b[index + i]','b[0]'],['c[index + i]','c[index]']] as const){const bad=kernel.slice(0,begin)+kernel.slice(begin).replace(a,b);if(hash(bad)===pinned['kernels/binary.h'])throw Error('Binary mutation missed production');reject(()=>checkExtracted(bad,host,jit,proof));}
 reject(()=>checkExtracted(kernel,host.replace('grid_dims = MTL::Size(nthreads, 1, 1);','grid_dims = MTL::Size(nthreads + 1, 1, 1);'),jit,proof));
 reject(()=>checkExtracted(kernel,host,jit.replace('"binary_vv", in_t, out_t, op, 1','"binary_vv", in_t, out_t, op, 4'),proof));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxOutputGateBinarySourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX attention gate binary loop source binding passed.');}
