import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const pinned={'common/common.cpp':'671d20a1a25524198e078c22af18a0f02b94f642786b6655f9c4e55ec8a6d8a4','metal/copy.cpp':'35570b10905afb07f59ea16bf7abf840d290435fedbf716ca83cc7c51691e5d8','metal/kernels/copy.h':'a9fad1b262ffc25f4ccda4e09d0c76821cd580f12871acd2a0daa98151e1587c'};
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const norm=(s:string)=>s.replace(/\/\/[^\n]*/g,'').replace(/\s+/g,'').trim();
export function checkExtracted(common:string,host:string,kernel:string,syntax:string,caller:string){
 const begin=kernel.indexOf('[[kernel]] void copy_g_nd2('),start=kernel.indexOf('{',begin),end=kernel.indexOf('\n}',start);if(begin<0||start<0||end<0)throw Error('Missing selected g2 copy kernel');
 const literal=syntax.match(/def sourceBody : String := r#"([\s\S]*?)"#/)?.[1];if(!literal||norm(kernel.slice(start,end+2))!==norm(literal))throw Error('Gate reshape parsed g2 cell changed');
 const reshape=host.slice(host.indexOf('void reshape_gpu('));
 for(const text of ['auto [copy_necessary, out_strides] = prepare_reshape(in, out);','if (copy_necessary) {','out.set_data(allocator::malloc(out.nbytes()));','copy_gpu_inplace(in, out, in.shape(), in.strides(), make_contiguous_strides(in.shape()), 0, 0, CopyType::General, s);'])if(!norm(reshape).includes(norm(text)))throw Error('Gate reshape fresh General dispatch changed');
 const p=common.slice(common.indexOf('std::pair<bool, Strides> prepare_reshape('),common.indexOf('void shared_buffer_reshape('));
 for(const text of ['if (in.size() == 0 || in.flags().row_contiguous)','if (in.ndim() == 0)','auto [shape, strides] = collapse_contiguous_dims(in);','if (j < shape.size() && shape[j] % N == 0)','shape[j] /= N;','out_strides.push_back(shape[j] * strides[j]);','j += (shape[j] == 1);','else if (N == 1)','copy_necessary = true;','return {copy_necessary, out_strides};'])if(!norm(p).includes(norm(text)))throw Error('Reviewed reshape preparation changed');
 for(const text of ['const [qHeads, gateHeads] = ops.split(qpr, [this.headDim], -1)','const gate = disposing(gateHeads, ops.reshape(gateHeads, [B, L, this.nHeads * this.headDim]))'])if(!norm(caller).includes(norm(text)))throw Error('Gate split/reshape caller changed');
}
function reject(f:()=>void){let rejected=false;try{f();}catch{rejected=true;}if(!rejected)throw Error('Gate reshape mutation accepted');}
export async function checkMlxAttentionGateReshapeSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend`),sources:Record<string,string>={};
 for(const [path,sha] of Object.entries(pinned)){sources[path]=await Bun.file(resolve(dir,path)).text();if(hash(sources[path]!)!==sha)throw Error('Pinned reshape source SHA changed');}
 const common=sources['common/common.cpp']!,host=sources['metal/copy.cpp']!,kernel=sources['metal/kernels/copy.h']!,syntax=await Bun.file(resolve(root,'kernels/attention/MlxAttentionGateCopySyntax.lean')).text(),caller=await Bun.file(resolve(root,'../packages/inference/src/models/qwen/blocks.ts')).text();
 checkExtracted(common,host,kernel,syntax,caller);
 if(options.selfTest){const kstart=kernel.indexOf('[[kernel]] void copy_g_nd2(');for(const [a,b] of [['index, src_strides','index, dst_strides'],['index.x + IdxT(grid_dim.x) * index.y','index.y + IdxT(grid_dim.x) * index.x'],['dst[dst_idx]','dst[src_idx]'],['cast_to<U>(src[src_idx])','cast_to<U>(src[0])']] as const){const bad=kernel.slice(0,kstart)+kernel.slice(kstart).replace(a,b);if(hash(bad)===pinned['metal/kernels/copy.h'])throw Error('Mutation missed selected g2');reject(()=>checkExtracted(common,host,bad,syntax,caller));}
 for(const [a,b] of [['shape[j] % N == 0','shape[j] % N != 0'],['shape[j] /= N','shape[j] *= N'],['j += (shape[j] == 1)','j += (shape[j] != 1)']] as const)reject(()=>checkExtracted(common.replace(a,b),host,kernel,syntax,caller));
 const hstart=host.indexOf('void reshape_gpu('),bad=host.slice(0,hstart)+host.slice(hstart).replace('CopyType::General,','CopyType::GeneralGeneral,');reject(()=>checkExtracted(common,bad,kernel,syntax,caller));
 reject(()=>checkExtracted(common,host,kernel,syntax,caller.replace('ops.reshape(gateHeads, [B, L, this.nHeads * this.headDim])','ops.reshape(qHeads, [B, L, this.nHeads * this.headDim])')));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxAttentionGateReshapeSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX attention gate reshape source binding passed.');}
