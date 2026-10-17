import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const kernelHash='de098d50a67a865e2e64fb1700fc4819307861f009a65642679777a9a9cec7cd';
const hostHash='215ebac6495706cf01a2635c4dcec29802e130165ed8704f212d789679d2e673';
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
function literal(s:string,name:string){return s.match(new RegExp(`def ${name} : String := r#"([\\s\\S]*?)"#`))?.[1];}
function match(s:string,re:RegExp){const m=s.match(re)?.[0];if(!m)throw new Error(`SDPA source missing ${re}`);return m;}
function close(s:string,start:number){let d=0;for(let i=start;i<s.length;++i){if(s[i]==='{')++d;if(s[i]==='}'&&--d===0)return i;}throw new Error('SDPA source block not closed');}
export function extractKernel(source:string){const start=source.indexOf('[[kernel]] void sdpa_vector('),end=source.indexOf('template <typename T',start+1);if(start<0||end<0)throw new Error('One-pass SDPA kernel missing');return source.slice(start,end);}
export function checkExtracted(kernelSource:string,host:string,syntax:string,loop:string){
  const kernel=extractKernel(kernelSource);
  const pointers=[match(kernel,/queries \+= q_offset \* D \+ simd_lid \* qk_per_thread;/),match(kernel,/keys \+= kv_head_idx \* k_head_stride \+ simd_gid \* k_seq_stride \+\s*simd_lid \* qk_per_thread;/),match(kernel,/values \+= kv_head_idx \* v_head_stride \+ simd_gid \* v_seq_stride \+\s*simd_lid \* v_per_thread;/)].join('\n  ')+'\n'+match(kernel,/out \+= o_offset \* V \+ simd_gid \* v_per_thread;/);
  if(pointers!==literal(syntax,'sourcePointers'))throw new Error('SDPA parsed pointers differ');
  for(const [name,re] of [['sourceQuery',/q\[i\] = static_cast<U>\(scale\) \* queries\[i\];/],['sourceKey',/k\[j\] = keys\[j\];/],['sourceOutput',/out\[i\] = static_cast<T>\(o\[i\]\);/]] as const)if(match(kernel,re)!==literal(syntax,name))throw new Error('SDPA parsed scalar cell differs');
  const start=kernel.indexOf('for (int i = simd_gid;'),opening=kernel.indexOf('{',start);if(start<0||opening<0)throw new Error('SDPA strided key loop missing');
  if(kernel.slice(start,opening)+'{ CELL; }'!==literal(loop,'sourceLoop'))throw new Error('SDPA parsed loop control differs');
  const body=kernel.slice(opening+1,close(kernel,opening));
  if(match(body,/keys \+= inner_k_stride;\s*values \+= inner_v_stride;/)!==literal(loop,'sourceAdvances'))throw new Error('SDPA pointer advances differ');
  for(const s of ['constexpr int BN = 32;','constexpr int BD = 32;','constexpr int qk_per_thread = D / BD;','constexpr int v_per_thread = V / BD;','int inner_k_stride = BN * int(k_seq_stride);','int inner_v_stride = BN * int(v_seq_stride);','typedef float U;',
    'const int kv_head_idx = q_batch_head_idx / gqa_factor;','const int q_batch_head_idx = tid.x;','const int q_seq_idx = tid.y;','const int o_offset = q_batch_head_idx * tpg.y + q_seq_idx;',
    'query_transposed ? tpg.x * q_seq_idx + q_batch_head_idx : o_offset;','for (int i = 0; i < qk_per_thread; i++) {','for (int j = 0; j < qk_per_thread; j++) {','for (int i = 0; i < v_per_thread; i++) {','bool use_key = true;'])if(!kernel.includes(s))throw new Error('SDPA source index/type/loop shell changed');
  const oneStart=host.indexOf('void sdpa_vector('),one=host.slice(oneStart,host.indexOf('void sdpa_vector_2pass(',oneStart));
  for(const s of ['int gqa_factor = q.shape(1) / k.shape(1);','MTL::Size group_dims(1024, 1, 1);','MTL::Size grid_dims(q.shape(0) * q.shape(1), q.shape(2), 1);','compute_encoder.set_input_array(q, 0);','compute_encoder.set_input_array(k, 1);','compute_encoder.set_input_array(v, 2);','compute_encoder.set_output_array(out, 3);','compute_encoder.set_bytes(scale, 10);'])if(!one.includes(s))throw new Error('SDPA one-pass host binding changed');
  if(!host.includes("if (((devc == 'd' || devc == 's') && k.shape(2) >= 1024) ||\n        (k.shape(1) < q.shape(1) && k.shape(2) >= 4096))"))throw new Error('SDPA architecture/cache transition changed');
  if(!host.includes('bool do_causal = do_causal_ && q.shape(2) > 1;'))throw new Error('SDPA selected decode causal exclusion changed');
}
export function checkSpecialization(source:string){
  for(const text of ["instantiate_sdpa_vector_heads(bfloat16_t)","instantiate_sdpa_vector(type, 256, 256)","\"sdpa_vector_\" #type \"_\" #qk_dim \"_\" #value_dim", "      sdpa_vector,"])
    if(!source.includes(text))throw new Error("SDPA BF16 width256 pipeline specialization changed");
}
export function checkSource(kernel:string,host:string,syntax:string,loop:string){if(hash(kernel)!==kernelHash||hash(host)!==hostHash)throw new Error('Pinned SDPA SHA mismatch');checkExtracted(kernel,host,syntax,loop);}
function reject(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw new Error('SDPA source mutation accepted');}
export async function checkMlxSdpaVectorSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal`);
  const kernel=await Bun.file(resolve(dir,'kernels/sdpa_vector.h')).text(),host=await Bun.file(resolve(dir,'scaled_dot_product_attention.cpp')).text(),syntax=await Bun.file(resolve(root,'kernels/attention/MlxSdpaVectorSyntax.lean')).text(),loop=await Bun.file(resolve(root,'kernels/attention/MlxSdpaVectorLoop.lean')).text();checkSource(kernel,host,syntax,loop);
  const specialization=await Bun.file(resolve(dir,'kernels/scaled_dot_product_attention.metal')).text();
  if(hash(specialization)!=='f6fefad1d91b01f05c12095e69f248e255f880d65b5ae9e9d8bc2714da56fb41')throw new Error('SDPA specialization SHA mismatch');checkSpecialization(specialization);
  if(options.selfTest){reject(()=>checkSpecialization(specialization.replace('instantiate_sdpa_vector(type, 256, 256)','instantiate_sdpa_vector(type, 256, 128)')));
for(const [a,b] of [['q_offset * D + simd_lid * qk_per_thread','q_offset * D + simd_gid * qk_per_thread'],['kv_head_idx * k_head_stride','kv_head_idx * k_seq_stride'],['scale) * queries[i]','scale) + queries[i]'],['k[j] = keys[j]','k[j] = keys[0]'],['out[i] = static_cast<T>(o[i])','out[i] = static_cast<T>(o[0])'],['i < N; i += BN','i <= N; i += BN'],['keys += inner_k_stride','keys += inner_v_stride'],['constexpr int BN = 32;','constexpr int BN = 16;'],['typedef float U;','typedef T U;'],['q_batch_head_idx / gqa_factor','q_batch_head_idx * gqa_factor']] as const){const bad=kernel.replace(a,b);reject(()=>checkSource(bad,host,syntax,loop));reject(()=>checkExtracted(bad,host,syntax,loop));}
    for(const [a,b] of [['k.shape(2) >= 1024','k.shape(2) > 1024'],['k.shape(2) >= 4096','k.shape(2) > 4096'],['MTL::Size group_dims(1024, 1, 1);','MTL::Size group_dims(512, 1, 1);'],['compute_encoder.set_input_array(k, 1);','compute_encoder.set_input_array(v, 1);'],['bool do_causal = do_causal_ && q.shape(2) > 1;','bool do_causal = do_causal_ && q.shape(2) >= 1;']] as const){const start=(a.startsWith('MTL::')||a.startsWith('compute_encoder'))?host.indexOf('void sdpa_vector('):0;const bad=host.slice(0,start)+host.slice(start).replace(a,b);reject(()=>checkSource(kernel,bad,syntax,loop));reject(()=>checkExtracted(kernel,bad,syntax,loop));}
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxSdpaVectorSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX selected one-pass SDPA source binding passed.');}
