import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const pinned={'kernels/unary.h':'fb952a2c30a6d0cd01f6c61e852cc15e426b286475de8ff139bb65b8d9001c8c','unary.cpp':'35a7a35a9d14f5cac74e1535106093383aeb91c147a8a1a5f486913e74ccc521','utils.h':'2b57319453758b5f7c776de946375701f97f84deabca02a1ef024f0153599c70','jit_kernels.cpp':'8201a166cc426cd7b1f6983e5e6f282d3ca7a1992cc4c3a80fa42cf8dd237c46'};
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const norm=(s:string)=>s.replace(/\s+/g,' ').trim();
export function checkExtracted(kernel:string,host:string,utils:string,jit:string,proof:string){
 const start=kernel.indexOf('index *= N;'),end=kernel.indexOf('\n}',start);if(start<0||end<0)throw Error('Missing unary vector body');
 const literal=proof.match(/def sourceBody : String := r#"([\s\S]*?)"#/)?.[1];if(!literal||norm(kernel.slice(start,end))!==norm(literal))throw Error('Unary vector parsed loop changed');
 if(!kernel.includes('uint index [[thread_position_in_grid]]'))throw Error('Unary thread index changed');
 for(const text of ['bool contig = in.flags().contiguous;','large = in.data_size() > UINT32_MAX;','work_per_thread = get_work_per_thread(in.dtype(), in.data_size());','kernel_name = (large ? "v2" : (work_per_thread > 1 ? "vn" : "v"));','size_t nthreads = ceildiv(in.data_size(), work_per_thread);','compute_encoder.set_input_array(in, 0);','compute_encoder.set_output_array(out, 1);','compute_encoder.set_bytes<int>(in.data_size(), 2);','grid_dims = MTL::Size(nthreads, 1, 1);'])if(!host.includes(text))throw Error('Unary contiguous host dispatch changed');
 for(const text of ['constexpr size_t wpt_threshold = 1 << 16;','return size < wpt_threshold ? 1 : std::max(1, 8 / dtype.size());'])if(!utils.includes(text))throw Error('Unary selected width threshold changed');
 if(!jit.includes('get_template_definition("v_" + lib_name, "unary_v", in_t, out_t, op, 1)'))throw Error('Unary v specialization changed');
}
function reject(f:()=>void){let rejected=false;try{f();}catch{rejected=true;}if(!rejected)throw Error('Unary source mutation accepted');}
export async function checkMlxOutputGateUnarySourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal`),sources:Record<string,string>={};
 for(const [path,sha] of Object.entries(pinned)){sources[path]=await Bun.file(resolve(dir,path)).text();if(hash(sources[path]!)!==sha)throw Error('Pinned unary SHA changed');}
 const [kernel,host,utils,jit]=['kernels/unary.h','unary.cpp','utils.h','jit_kernels.cpp'].map(p=>sources[p]!),proof=await Bun.file(resolve(root,'kernels/attention/MlxOutputGateUnaryLoop.lean')).text();
 checkExtracted(kernel!,host!,utils!,jit!,proof);
 if(options.selfTest){for(const [a,b] of [['index *= N','index += N'],['index + N > size','index + N < size'],['index + i < size','index + i <= size'],['i < N','i <= N'],['in[index + i]','in[index]'],['out[index + i]','out[index]'],['static_cast<U>','static_cast<T>']] as const){const bad=kernel!.replace(a,b);if(hash(bad)===pinned['kernels/unary.h'])throw Error('Unary mutation missed production');reject(()=>checkExtracted(bad,host!,utils!,jit!,proof));}
 reject(()=>checkExtracted(kernel!,host!.replace('grid_dims = MTL::Size(nthreads, 1, 1);','grid_dims = MTL::Size(nthreads + 1, 1, 1);'),utils!,jit!,proof));
 reject(()=>checkExtracted(kernel!,host!,utils!.replace('1 << 16','1 << 12'),jit!,proof));
 reject(()=>checkExtracted(kernel!,host!,utils!,jit!.replace('"unary_v", in_t, out_t, op, 1','"unary_v", in_t, out_t, op, 4'),proof));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxOutputGateUnarySourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX attention gate unary loop source binding passed.');}
