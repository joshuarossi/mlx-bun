import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {checkBFloatAddSourceBinding,revision} from './BFloatAddSourceBinding';
const kernelHash='9a367967a48907ac6792be685bab4cc062f3ad916cccacb441c627d87a4b7898';
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
export function extract(source:string){
  const start=source.indexOf('[[kernel]] void binary_vv(');
  if(start<0)throw new Error('binary_vv missing');
  const opening=source.indexOf('{',start);let depth=0;
  for(let end=opening;end<source.length;++end){if(source[end]==='{')++depth;if(source[end]==='}'&&--depth===0)return source.slice(opening,end+1);}
  throw new Error('Unclosed binary_vv');
}
export async function checkBinaryVvSourceBinding(options:{proofsRoot?:string,header?:string,selfTest?:boolean}={}){
  const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url)));
  await checkBFloatAddSourceBinding({...options,proofsRoot:root});
  const path=resolve(root,'.lake/sources/mlx',revision,'mlx/backend/metal');
  const kernel=await Bun.file(resolve(path,'kernels/binary.h')).text();
  if(hash(kernel)!==kernelHash)throw new Error('binary.h pinned hash mismatch');
  const lean=await Bun.file(resolve(root,'kernels/binary/BinaryVvSyntax.lean')).text();
  const body=lean.match(/def sourceBody : String := r#"([\s\S]*?)"#/);if(!body||extract(kernel)!==body[1])throw new Error('Exact binary_vv body binding mismatch');
  const common=await Bun.file(resolve(path,'../common/binary.h')).text();
  for(const literal of ['(a.flags().row_contiguous && b.flags().row_contiguous)','bopt = BinaryOpType::VectorVector;','if (a_donatable) {','else if (b_donatable) {','mallocfn(a.data_size() * out.itemsize())'])
    if(!common.includes(literal))throw new Error('Binary selection/allocation fragment mismatch');
  if(options.selfTest){
    for(const mutated of [kernel.replace('Op()(a[index + i], b[index + i])','Op()(a[0], b[index + i])'),kernel.replace('index *= N;','index += N;'),kernel.replace('i < N;','i <= N;')])
      if(hash(mutated)===kernelHash)throw new Error('Source mutation accepted');
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  await checkBinaryVvSourceBinding({header:process.argv.slice(2).find(x=>!x.startsWith('--')),selfTest:process.argv.includes('--self-test')});
  console.log('binary_vv exact source/selection binding passed (host extraction boundary).');
}
