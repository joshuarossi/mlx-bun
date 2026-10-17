import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const revision='1f8e74e3f12f31365464a6867c6579f0e9b29d85';
const hashes=['ee3e8dafc49d87dabe0edded9f617ca09682a3f5ef49310b71ca2fcbb65dc83c','c732ffd23460198800006c6d5dac4487569000fc7d5e809c9fb3a8f21d964af6'];
const hash=(s:string)=>createHash('sha256').update(s).digest('hex');
const norm=(s:string)=>s.replace(/\s+/g,'').trim();
export function checkExtracted(binary:string,unary:string,proof:string){
 const classification=`if (a.data_size() == 1 && b.data_size() == 1) { bopt = BinaryOpType::ScalarScalar; } else if (a.data_size() == 1 && b.flags().contiguous) { bopt = BinaryOpType::ScalarVector; } else if (b.data_size() == 1 && a.flags().contiguous) { bopt = BinaryOpType::VectorScalar; } else if ((a.flags().row_contiguous && b.flags().row_contiguous) || (a.flags().col_contiguous && b.flags().col_contiguous)) { bopt = BinaryOpType::VectorVector; } else { bopt = BinaryOpType::General; } return bopt;`;
 const extracted=binary.match(/inline BinaryOpType get_binary_op_type\([^]*?BinaryOpType bopt;([^]*?return bopt;)/)?.[1];if(!extracted||norm(extracted)!==norm(classification))throw Error('Reviewed binary descriptor classification changed');
 const unarySelected=`if (in.flags().contiguous) { if (is_donatable(in, out)) { out.copy_shared_buffer(in); } else { out.set_data(mallocfn(in.data_size() * out.itemsize()), in.data_size(), in.strides(), in.flags()); } }`;
 if(!norm(unary).includes(norm(unarySelected)))throw Error('Reviewed unary contiguous allocation changed');
 const binarySelected=`case BinaryOpType::VectorVector: if (a_donatable) { out.copy_shared_buffer(a); } else if (b_donatable) { out.copy_shared_buffer(b); } else { out.set_data(mallocfn(a.data_size() * out.itemsize()), a.data_size(), a.strides(), a.flags()); } break;`;
 if(!norm(binary).includes(norm(binarySelected)))throw Error('Reviewed binary vv allocation changed');
 for(const formula of ['if a.dataSize=1 ∧ b.dataSize=1 then .scalarScalar','else if a.dataSize=1 ∧ b.contiguous then .scalarVector','else if b.dataSize=1 ∧ a.contiguous then .vectorScalar','else if (a.rowContiguous && b.rowContiguous) || (a.colContiguous && b.colContiguous) then .vectorVector','if donatable then input else {input with base := allocation}','if donatableA then a else if donatableB then b else {a with base := allocation}'])if(!norm(proof).includes(norm(formula)))throw Error('Reviewed host translation changed');
}
function reject(f:()=>void){let rejected=false;try{f();}catch{rejected=true;}if(!rejected)throw Error('Host descriptor mutation accepted');}
export async function checkMlxOutputGateHostSourceBinding(options:{proofsRoot?:string,selfTest?:boolean}={}){
 const root=options.proofsRoot??resolve(fileURLToPath(new URL('../../',import.meta.url))),dir=resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/common`);
 const binary=await Bun.file(resolve(dir,'binary.h')).text(),unary=await Bun.file(resolve(dir,'unary.h')).text(),proof=await Bun.file(resolve(root,'kernels/attention/MlxOutputGateHostSelection.lean')).text();
 if(hash(binary)!==hashes[0]||hash(unary)!==hashes[1])throw Error('Pinned common host SHA changed');checkExtracted(binary,unary,proof);
 if(options.selfTest){for(const [a,b] of [['a.data_size() == 1 && b.data_size() == 1','a.data_size() == 1 || b.data_size() == 1'],['a.flags().row_contiguous && b.flags().row_contiguous','a.flags().row_contiguous || b.flags().row_contiguous'],['bopt = BinaryOpType::VectorVector','bopt = BinaryOpType::General']] as const)reject(()=>checkExtracted(binary.replace(a,b),unary,proof));
 const start=binary.indexOf('case BinaryOpType::VectorVector:',binary.indexOf('inline void set_binary_op_output_data')); const bad=binary.slice(0,start)+binary.slice(start).replace('out.copy_shared_buffer(a);','out.copy_shared_buffer(b);');reject(()=>checkExtracted(bad,unary,proof));
 reject(()=>checkExtracted(binary,unary.replace('out.copy_shared_buffer(in);','out.copy_shared_buffer(out);'),proof));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkMlxOutputGateHostSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('MLX attention gate reviewed host descriptor binding passed.');}
