import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const kernelHash='de098d50a67a865e2e64fb1700fc4819307861f009a65642679777a9a9cec7cd';
const hostHash='215ebac6495706cf01a2635c4dcec29802e130165ed8704f212d789679d2e673';
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const norm=(s:string)=>s.replace(/\/\/[^\n]*/g,'').replace(/\s+/g,' ').trim();
function literal(s:string,n:string){const x=s.match(new RegExp(`def ${n} : String := r#"([\\s\\S]*?)"#`))?.[1];if(!x)throw Error('Missing merge literal');return x;}
function match(s:string,re:RegExp){const m=s.match(re)?.[0];if(!m)throw Error(`Merge source missing ${re}`);return m;}
function block(s:string,marker:string){const start=s.indexOf(marker);if(start<0)throw Error('Missing merge phase');const begin=s.indexOf('{',start);let depth=1,end=begin+1;for(;end<s.length&&depth;end++){if(s[end]==='{')depth++;if(s[end]==='}')depth--;}if(depth)throw Error('Unclosed merge phase');return s.slice(start,end);}
export function checkExtracted(source:string,host:string,syntax:string){
 const start=source.indexOf('[[kernel]] void sdpa_vector_2pass_2(');if(start<0)throw Error('Missing second pass');const k=source.slice(start);
 const pointers=['partials','sums','maxs','out'].map(n=>match(k,new RegExp(`${n} \\+= [^;]*;`))).join('\n');
 const maximum=block(k.slice(k.indexOf('// Reduce the max')),'for (int b')+'\n'+match(k,/max_score = simd_max\(max_score\);/);
 const denominator=block(k.slice(k.indexOf('// Reduce the d')),'for (int b')+'\n'+match(k,/sum_exp_score = simd_sum\(sum_exp_score\);/);
 const numerator=block(k.slice(k.indexOf('// Reduce the sum exp and partials')),'for (int b');
 const transpose=block(k.slice(k.indexOf('// Use shared memory')),'for (int i');
 const gate=block(k.slice(k.indexOf('// And write the output')),'if (simd_lid');
 const initial=match(k,/thread U o\[elem_per_thread\] = \{0\};/)+'\n'+match(k,/U sum_exp_score = 0\.0;\s*U max_score = Limits<U>::finite_min;/);
 for(const [name,value] of Object.entries({Pointers:pointers,Maximum:maximum,Denominator:denominator,Numerator:numerator,Transpose:transpose,Gate:gate,Initial:initial}))if(norm(value)!==norm(literal(syntax,`source${name}`)))throw Error(`Parsed merge ${name} changed`);
 for(const text of ['const device T* partials [[buffer(0)]]','const device float* sums [[buffer(1)]]','const device float* maxs [[buffer(2)]]','device T* out [[buffer(3)]]','const constant int& blocks [[buffer(4)]]','constexpr int BN = 32;','constexpr int BD = 32;','constexpr int elem_per_thread = D / BD;','typedef float U;','const int head_idx = tid.x;','const int q_seq_idx = tid.y;','const int q_offset = head_idx * tpg.y + q_seq_idx;'])if(!k.includes(text))throw Error('Merge type/index boundary changed');
 const h=host.slice(host.indexOf('void sdpa_vector_2pass('));
 for(const text of ['sdpa_vector_2pass_2','compute_encoder.set_input_array(intermediate, 0);','compute_encoder.set_input_array(sums, 1);','compute_encoder.set_input_array(maxs, 2);','compute_encoder.set_output_array(out, 3);','compute_encoder.set_bytes(blocks, 4);','group_dims = MTL::Size(1024, 1, 1);','grid_dims = MTL::Size(q.shape(0) * q.shape(1), q.shape(2), 1);'])if(!h.includes(text))throw Error('Merge host dispatch changed');
}
function reject(f:()=>void){let rejected=false;try{f();}catch{rejected=true;}if(!rejected)throw Error('Merge mutation accepted');}
export async function checkMlxSdpaTwoPassMergeSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal`);
 const source=await Bun.file(resolve(dir,'kernels/sdpa_vector.h')).text(),host=await Bun.file(resolve(dir,'scaled_dot_product_attention.cpp')).text(),syntax=await Bun.file(resolve(root,'kernels/attention/MlxSdpaTwoPassMergeSyntax.lean')).text();
 if(hash(source)!==kernelHash||hash(host)!==hostHash)throw Error('Pinned merge SHA mismatch');checkExtracted(source,host,syntax);
 if(options.selfTest){const start=source.indexOf('[[kernel]] void sdpa_vector_2pass_2(');for(const [a,b] of [['blocks / BN','blocks / BD + 1'],['simd_max(max_score)','simd_sum(max_score)'],['maxs[simd_lid + BN * b]','maxs[simd_gid + BN * b]'],['factor * sums[simd_lid + BN * b]','factor + sums[simd_lid + BN * b]'],['maxs[simd_gid] - max_score','max_score - maxs[simd_gid]'],['static_cast<U>(partials[i])','static_cast<T>(partials[i])'],['partials += BN * D','partials += D'],['outputs[simd_lid * BD + simd_gid]','outputs[simd_gid * BD + simd_lid]'],['sum_exp_score == 0','sum_exp_score != 0'],['threadgroup_barrier(mem_flags::mem_threadgroup);',''],['(o[i] / sum_exp_score);\n    threadgroup_barrier(mem_flags::mem_threadgroup);','(o[i] / sum_exp_score);'],['if (simd_lid == 0)','if (simd_gid == 0)'],['static_cast<T>(o[i])','static_cast<U>(o[i])']] as const){const bad=source.slice(0,start)+source.slice(start).replace(a,b);if(hash(bad)===kernelHash)throw Error('Mutation missed production second pass');reject(()=>checkExtracted(bad,host,syntax));}
 const hstart=host.indexOf('kname = "sdpa_vector_2pass_2_";');for(const [a,b] of [['set_input_array(sums, 1)','set_input_array(maxs, 1)'],['MTL::Size(1024, 1, 1)','MTL::Size(512, 1, 1)'],['q.shape(0) * q.shape(1)','q.shape(0) * k.shape(1)']] as const){const bad=host.slice(0,hstart)+host.slice(hstart).replace(a,b);if(hash(bad)===hostHash)throw Error('Host mutation missed second pass');reject(()=>checkExtracted(source,bad,syntax));}
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxSdpaTwoPassMergeSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX two-pass merge source binding passed.');}
