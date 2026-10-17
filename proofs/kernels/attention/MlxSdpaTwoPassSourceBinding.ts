import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const kernelHash='de098d50a67a865e2e64fb1700fc4819307861f009a65642679777a9a9cec7cd';
const hostHash='215ebac6495706cf01a2635c4dcec29802e130165ed8704f212d789679d2e673';
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const norm=(s:string)=>s.replace(/\/\/[^\n]*/g,'').replace(/\s+/g,' ').trim();
function literal(s:string,n:string){const x=s.match(new RegExp(`def ${n} : String := r#"([\\s\\S]*?)"#`))?.[1];if(!x)throw new Error('Missing two-pass source literal');return x;}
function match(s:string,re:RegExp){const m=s.match(re)?.[0];if(!m)throw new Error(`Two-pass source missing ${re}`);return m;}
export function extractKernel(source:string){const start=source.indexOf('[[kernel]] void sdpa_vector_2pass_1('),end=source.indexOf('// Duplication-free variant',start);if(start<0||end<0)throw new Error('Ordinary two-pass source missing');return source.slice(start,end);}
export function checkExtracted(source:string,host:string,syntax:string,loop:string,first:string,stores:string){
  const kernel=extractKernel(source);
  const pointers=['queries','keys','values','out','sums','maxs'].map(name=>match(kernel,new RegExp(`${name} \\+= [^;]*;`))).join('\n');
  if(norm(pointers)!==norm(literal(syntax,'sourcePointers')))throw new Error('Two-pass parsed pointers changed');
  const header=match(kernel,/for \(int i = block_idx; i < N; i \+= blocks\) \{/).replace('{','{ CELL; }');
  if(norm(header)!==norm(literal(loop,'sourceBody')))throw new Error('Two-pass parsed partition loop changed');
  const dot=match(kernel,/U score = 0;\s*for \(int i = 0; i < qk_per_thread; i\+\+\) \{\s*score \+= q\[i\] \* keys\[i\];\s*\}\s*score = simd_sum\(score\);/);
  if(norm(dot)!==norm(literal(syntax,'sourceDot')))throw new Error('Two-pass parsed score changed');
  const update=match(kernel,/U new_max = max\(max_score, score\);[\s\S]*?for \(int i = 0; i < v_per_thread; i\+\+\) \{[\s\S]*?\}/);
  if(norm(update)!==norm(literal(first,'sourceUpdate')))throw new Error('Two-pass parsed online update changed');
  const initial=[match(kernel,/thread U o\[v_per_thread\] = \{0\};/),match(kernel,/U max_score = Limits<U>::finite_min;\s*U sum_exp_score = 0;/)].join('\n');
  if(norm(initial)!==norm(literal(stores,'sourceInitial')))throw new Error('Two-pass parsed aggregate/scalar initialization changed');
  const advances=match(kernel,/keys \+= blocks \* int\(k_seq_stride\);\s*values \+= blocks \* int\(v_seq_stride\);/);
  if(norm(advances)!==norm(literal(stores,'sourceAdvances')))throw new Error('Two-pass parsed advances changed');
  const output=match(kernel,/if \(simd_lid == 0\) \{\s*sums\[0\] = sum_exp_score;\s*maxs\[0\] = max_score;\s*\}\s*for \(int i = 0; i < v_per_thread; i\+\+\) \{\s*out\[i\] = static_cast<T>\(o\[i\]\);\s*\}/);
  if(norm(output)!==norm(literal(stores,'sourceStores')))throw new Error('Two-pass FP32 summary/BF16 partial stores changed');
  for(const text of ['typedef float U;','constexpr int BD = 32;','constexpr int qk_per_thread = D / BD;','constexpr int v_per_thread = V / BD;',
    'const int kv_head_idx = tid.x;','const int batch_idx = tid.y;','const int block_idx = tid.z;','const int gqa_factor = tptg.y;','const int q_head_idx = gqa_factor * kv_head_idx + tidtg.y;',
    'const int kv_batch_head_idx = batch_idx * num_kv_heads + kv_head_idx;','q[i] = static_cast<U>(scale) * queries[i];'])if(!kernel.includes(text))throw new Error('Two-pass selected source metadata/type binding changed');
  const begin=host.indexOf('void sdpa_vector_2pass('),tail=host.slice(begin,host.indexOf('void',begin+5));
  for(const text of ['(q.shape(-1) == 64 || q.shape(-1) == 128)','q.shape(1) == 8 * k.shape(1)','MTL::Size group_dims(32, gqa_factor, q.shape(2));','MTL::Size grid_dims(k.shape(1), q.shape(0), blocks);','env::get_var("MLX_SDPA_BLOCKS", 0)','blocks = ((blocks_env + 31) / 32) * 32;'])if(!tail.includes(text))throw new Error('Two-pass host ordinary dispatch/partition changed');
}
function reject(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw new Error('Two-pass source mutation accepted');}
export async function checkMlxSdpaTwoPassSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal`);
  const source=await Bun.file(resolve(dir,'kernels/sdpa_vector.h')).text(),host=await Bun.file(resolve(dir,'scaled_dot_product_attention.cpp')).text();
  const syntax=await Bun.file(resolve(root,'kernels/attention/MlxSdpaTwoPassSyntax.lean')).text(),loop=await Bun.file(resolve(root,'kernels/attention/MlxSdpaTwoPassLoop.lean')).text(),first=await Bun.file(resolve(root,'kernels/attention/MlxSdpaTwoPassFirstSource.lean')).text(),stores=await Bun.file(resolve(root,'kernels/attention/MlxSdpaTwoPassStores.lean')).text();
  if(hash(source)!==kernelHash||hash(host)!==hostHash)throw new Error('Pinned two-pass SHA mismatch');checkExtracted(source,host,syntax,loop,first,stores);
  if(options.selfTest){const start=source.indexOf('[[kernel]] void sdpa_vector_2pass_1(');for(const [a,b] of [['block_idx * k_seq_stride','block_idx * k_head_stride'],['o_offset * blocks * V','o_offset * V'],['i < N; i += blocks','i < N; i += BN'],['score += q[i] * keys[i]','score += q[i] * keys[0]'],['simd_sum(score)','simd_max(score)'],['o[v_per_thread] = {0}','o[v_per_thread] = {1}'],['max_score - new_max','new_max - max_score'],['sums[0] = sum_exp_score','sums[0] = max_score'],['static_cast<T>(o[i])','static_cast<U>(o[i])'],['blocks * int(k_seq_stride)','BN * int(k_seq_stride)'],['q_head_idx = gqa_factor * kv_head_idx + tidtg.y','q_head_idx = gqa_factor * kv_head_idx + tidtg.z']] as const){const bad=source.slice(0,start)+source.slice(start).replace(a,b);if(hash(bad)===kernelHash)throw new Error('Two-pass mutation missed selected source');reject(()=>checkExtracted(bad,host,syntax,loop,first,stores));}
    for(const [a,b] of [['q.shape(-1) == 128','q.shape(-1) == 256'],['group_dims(32, gqa_factor, q.shape(2))','group_dims(64, gqa_factor, q.shape(2))'],['MLX_SDPA_BLOCKS','MLX_OTHER_BLOCKS']] as const){const start=host.indexOf('void sdpa_vector_2pass('),bad=host.slice(0,start)+host.slice(start).replace(a,b);reject(()=>checkExtracted(source,bad,syntax,loop,first,stores));}
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxSdpaTwoPassSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX ordinary two-pass first-phase source binding passed.');}
