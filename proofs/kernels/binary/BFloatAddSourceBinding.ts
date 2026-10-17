import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';

// Host extraction/hash boundary only. This does not certify the Metal compiler,
// builtin bfloat arithmetic, template lookup, or actual native array descriptors.
export const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
export const helperHash='2dd13c2496f5d6f0856e4ca99db2ceb5c6d7dc0c344b9ba8e41ef3b7d7ed8a97';
export const helper=`struct Add {
  template <typename T>
  T operator()(T x, T y) thread {
    return x + y;
  }
};`;
export const body=`{\n    return x + y;\n  }`;
const hash=(source:string)=>createHash('sha256').update(source).digest('hex');
export function checkHelper(source:string){
  if(hash(source)!==helperHash)throw new Error('Pinned binary_ops.h SHA256 mismatch');
  if(!source.includes(helper))throw new Error('Complete Add helper mismatch');
  const start=source.indexOf('T operator()(T x, T y) thread {');
  const opening=source.indexOf('{',start),closing=source.indexOf('}',opening);
  if(source.slice(opening,closing+1)!==body)throw new Error('Add body binding mismatch');
}
export async function check(root:string,header:string){
  checkHelper(await Bun.file(header).text());
  const prefix=resolve(root,'.lake/sources/mlx',revision,'mlx/backend/metal');
  const bf=await Bun.file(resolve(prefix,'kernels/bf16.h')).text();
  if(!bf.includes('typedef bfloat bfloat16_t;'))throw new Error('Builtin bfloat alias mismatch');
  const cpp=await Bun.file(resolve(prefix,'binary.cpp')).text();
  for(const literal of ['BINARY_GPU(Add)','binary_op_gpu(inputs, out, name());','work_per_thread = get_work_per_thread(a.dtype(), out.data_size());','size_t nthreads = ceildiv(out.data_size(), work_per_thread);','compute_encoder.dispatch_threads(grid_dims, group_dims);'])
    if(!cpp.includes(literal))throw new Error('Binary dispatch fragment mismatch: '+literal);
  const utils=await Bun.file(resolve(prefix,'utils.h')).text();
  if(!utils.includes('return size < wpt_threshold ? 1 : std::max(1, 8 / dtype.size());'))throw new Error('Work selection mismatch');
  const lean=await Bun.file(resolve(root,'kernels/binary/BFloatAddSource.lean')).text();
  if(!lean.includes('def sourceBody : String := "{\\n    return x + y;\\n  }"'))throw new Error('Lean exact-body literal mismatch');
}
export function selfTest(source:string){
  checkHelper(source);
  for(const altered of [source.replace('return x + y;','return x - y;'),source.replace('T operator()(T x, T y)','T operator()(T y, T x)'),source+'\n']){
    let rejected=false;try{checkHelper(altered);}catch{rejected=true;}
    if(!rejected)throw new Error('Mutation accepted');
  }
}
export async function checkBFloatAddSourceBinding(options:{proofsRoot?:string,header?:string,selfTest?:boolean}={}) {
  const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
  const header=options.header??resolve(root,".lake/sources/mlx",revision,"mlx/backend/metal/kernels/binary_ops.h");
  await check(root,header);
  if(options.selfTest)selfTest(await Bun.file(header).text());
}
if(process.argv[1] && import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  const header=process.argv.slice(2).find(arg=>!arg.startsWith("--"));
  await checkBFloatAddSourceBinding({header,selfTest:process.argv.includes("--self-test")});
  console.log("BF16 Add helper exact-source binding passed (host extraction boundary).");
}
