import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const metalHash='2b35221ebea033ff43100b85eaaddec5c0e34e3cfd52e7c692573764b2b7d0ab';
const hostHash='9ec2d2f298381af6445b1e2281dd90521988861ed170a602944ec0f1fca17ecc';
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
function literal(s:string,name:string){return s.match(new RegExp(`def ${name} : String := r#"([\\s\\S]*?)"#`))?.[1];}
function match(s:string,re:RegExp){const x=s.match(re)?.[0];if(!x)throw new Error(`Missing single RoPE source ${re}`);return x;}
export function checkExtracted(metal:string,host:string,lean:string){
  const start=metal.indexOf('void rope_single_impl('),end=metal.indexOf('[[kernel]] void rope_single(');
  if(start<0||end<start)throw new Error('Missing single RoPE implementation');
  const body=metal.slice(start,end),wrapper=metal.slice(end,metal.indexOf('[[kernel]] void rope_single_freqs(',end));
  const indices=match(body,/index_1 = pos\.x \+ pos\.y \* stride;\s*index_2 = index_1 \+ grid\.x;/);
  const loads=match(body,/float x1 = static_cast<float>\(in\[index_1\]\);\s*float x2 = static_cast<float>\(in\[index_2\]\);/);
  const forward=match(body,/rx1 = x1 \* costheta - x2 \* sintheta;\s*rx2 = x1 \* sintheta \+ x2 \* costheta;/);
  const stores=match(body,/out\[index_1\] = static_cast<T>\(rx1\);\s*out\[index_2\] = static_cast<T>\(rx2\);/);
  if(!(body.indexOf(indices)<body.indexOf(loads)&&body.indexOf(loads)<body.indexOf('if (forward)')&&body.indexOf('if (forward)')<body.indexOf(stores)))throw new Error('Single RoPE capture/store chronology changed');
  if(!metal.includes('instantiate_kernel("rope_single_" #name, rope_single, type)')||!metal.includes('instantiate_rope(bfloat16, bfloat16_t)'))throw new Error('Single RoPE BF16 specialization changed');
  const frequency=match(wrapper,/float d = static_cast<float>\(pos\.x\) \/ static_cast<float>\(grid\.x\);\s*float inv_freq = metal::exp2\(-d \* base\);/);
  const position=match(body,/float L = scale \* static_cast<float>\(offset\);/);
  const trig=match(body,/float theta = L \* inv_freq;\s*float costheta = metal::fast::cos\(theta\);\s*float sintheta = metal::fast::sin\(theta\);/);
  if(indices!==literal(lean,'sourceIndices')||[loads,forward,stores].join('\n')!==literal(lean,'sourceCell')||[frequency,position,trig].join('\n')!==literal(lean,'sourceAngle'))throw new Error('Parsed single RoPE literal mismatch');
  for(const s of ['if (traditional) {','} else {\n    index_1 = pos.x','if (forward) {\n    rx1 = x1','uint index_1, index_2;','constant const int64_t& stride,','constant const int& offset,'])if(!body.includes(s))throw new Error('RoPE branch/type shell changed');
  if(!wrapper.includes('rope_single_impl<T>(in, out, offset, inv_freq, scale, stride, pos, grid);'))throw new Error('RoPE wrapper arguments changed');
  const singleBlock=host.slice(host.indexOf('if (single) {'),host.indexOf('} else {',host.indexOf('if (single) {')));
  if(!singleBlock.includes('uint32_t dim0 = dims_ / 2;'))throw new Error('Single grid rotary width changed');
  for(const s of ['if (dims_ < D) {\n    donated = true;','copy_gpu(in, out, ctype, s);','bool single = in.flags().row_contiguous && T == 1 && offset.size() == 1;',
    'compute_encoder.set_input_array(donated ? out : in, 0);','compute_encoder.set_output_array(out, 1);','compute_encoder.set_bytes(out_strides, 1, 4);',
    'uint32_t dim0 = dims_ / 2;','uint32_t dim1 = B * N;','grid_dims = MTL::Size(dim0, dim1, 1);','float base = std::log2(base_);',
    'single ? "single_" : ""','(with_freqs) ? "freqs_" : ""','{&forward_, MTL::DataType::DataTypeBool, 1}',
    '{&traditional_, MTL::DataType::DataTypeBool, 2}'])if(!host.includes(s))throw new Error('Selected single RoPE host translation changed');
}
export function checkSource(metal:string,host:string,lean:string){if(hash(metal)!==metalHash||hash(host)!==hostHash)throw new Error('Pinned RoPE SHA mismatch');checkExtracted(metal,host,lean);}
function reject(f:()=>void){let rejected=false;try{f();}catch{rejected=true;}if(!rejected)throw new Error('RoPE source mutation accepted');}
export async function checkMlxRopeSingleSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  const dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal`);
  const metal=await Bun.file(resolve(dir,'kernels/rope.metal')).text(),host=await Bun.file(resolve(dir,'rope.cpp')).text();
  const lean=await Bun.file(resolve(root,'kernels/attention/MlxRopeSingleSyntax.lean')).text();checkSource(metal,host,lean);
  if(options.selfTest){for(const [a,b] of [['index_1 = pos.x + pos.y * stride','index_1 = pos.x + pos.y + stride'],['index_1 + grid.x','index_1 + 1'],['in[index_2]','in[index_1]'],['x1 * costheta - x2 * sintheta','x1 * costheta + x2 * sintheta'],['out[index_2]','out[index_1]'],['metal::fast::sin(theta)','metal::fast::cos(theta)'],['scale * static_cast<float>(offset)','static_cast<float>(offset) * scale'],['-d * base','d * base'],['if (traditional)','if (forward)'],['uint index_1, index_2;','int index_1, index_2;'],['instantiate_rope(bfloat16, bfloat16_t)','instantiate_rope(bfloat16, half)']] as const){const bad=metal.replace(a,b);reject(()=>checkSource(bad,host,lean));reject(()=>checkExtracted(bad,host,lean));}
    for(const [a,b] of [['dims_ < D','dims_ <= D'],['T == 1','T == 2'],['donated ? out : in','donated ? in : out'],['dims_ / 2','dims_ / 4'],['B * N','B + N'],['std::log2(base_)','std::log(base_)']] as const){const bad=host.replace(a,b);reject(()=>checkSource(metal,bad,lean));reject(()=>checkExtracted(metal,bad,lean));}
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxRopeSingleSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX selected single RoPE source binding passed.');}
