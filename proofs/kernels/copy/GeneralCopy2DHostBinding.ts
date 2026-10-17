// Trusted exact-byte guard for the manually translated selected GG2 host path.
// It is not a verified C++ frontend, loader, compiler or hardware proof.
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const here=new URL('./',import.meta.url);
const bindings=[
  {
    "path": "backend/metal/copy.cpp",
    "literal": "kernelBranchSource",
    "start": "  if (ctype == CopyType::General || ctype == CopyType::GeneralGeneral) {\n    if (shape.size()",
    "end": "  auto kernel = dynamic ?",
    "hash": "35570b10905afb07f59ea16bf7abf840d290435fedbf716ca83cc7c51691e5d8"
  },
  {
    "path": "backend/metal/copy.cpp",
    "literal": "pointerBindingSource",
    "start": "  inp_offset *= size_of(in.dtype());",
    "end": "  auto thread_group_size =",
    "hash": "35570b10905afb07f59ea16bf7abf840d290435fedbf716ca83cc7c51691e5d8"
  },
  {
    "path": "backend/metal/copy.cpp",
    "literal": "strideBindingSource",
    "start": "    compute_encoder.set_vector_bytes(strides_in, ndim, 3);",
    "end": "\n\n    size_t dim0",
    "hash": "35570b10905afb07f59ea16bf7abf840d290435fedbf716ca83cc7c51691e5d8"
  },
  {
    "path": "backend/metal/device.cpp",
    "literal": "encoderBindingSource",
    "start": "  get_command_encoder()->setBuffer(a_buf, a.offset() + offset, idx);",
    "end": "\n}",
    "hash": "008b67e599f5508ab670a91f2ea80372162a8767b5226fbbeb9f3d23c85cdb7c"
  },
  {
    "path": "backend/metal/jit_kernels.cpp",
    "literal": "jitLibrarySource",
    "start": "MTL::ComputePipelineState* get_copy_kernel(\n    metal::Device& d,\n    const std::string& kernel_name,\n    const array& in,\n    const array& out) {\n  std::string lib_name = kernel_name.substr(kernel_name.find(\"_\") + 1);\n  auto lib = d.get_library(lib_name, [&]() {\n    std::string kernel_source = metal::utils();\n    kernel_source += metal::copy();\n    auto in_type = get_type_string(in.dtype());\n    auto out_type = get_type_string(out.dtype());",
    "end": "\n    kernel_source += get_template_definition(",
    "hash": "8201a166cc426cd7b1f6983e5e6f282d3ca7a1992cc4c3a80fa42cf8dd237c46",
    "retrieved": "/tmp/mlx-pinned-metal-jit_kernels.cpp"
  },
  {
    "path": "backend/metal/jit_kernels.cpp",
    "literal": "jitEntrySource",
    "start": "    kernel_source += get_template_definition(\n        \"gg2_\" + lib_name, \"copy_gg_nd2\", in_type, out_type, \"int\");",
    "end": "\n    kernel_source +=",
    "hash": "8201a166cc426cd7b1f6983e5e6f282d3ca7a1992cc4c3a80fa42cf8dd237c46",
    "retrieved": "/tmp/mlx-pinned-metal-jit_kernels.cpp"
  },
  {
    "path": "backend/metal/nojit_kernels.cpp",
    "literal": "noJitLookupSource",
    "start": "MTL::ComputePipelineState* get_copy_kernel(",
    "end": "\n\n",
    "hash": "94b31481ce88c7edd7c993008e4f708dcff2f8a0936c0b237c750a93a3cbe610",
    "retrieved": "/tmp/mlx-pinned-metal-nojit_kernels.cpp"
  },
  {
    "path": "backend/common/compiled.cpp",
    "literal": "bfloatTypeSource",
    "start": "    case bfloat16:\n      return \"bfloat16_t\";",
    "end": "\n",
    "hash": "a5a4e711add8b57b153be9c096089e312c747691dcb9ec61d4db1bf29186e2cc",
    "retrieved": "/tmp/mlx-pinned-common-compiled.cpp"
  },
  {
    "path": "backend/metal/utils.cpp",
    "literal": "bfloatNameSource",
    "start": "    case bfloat16:",
    "end": "\n      break;",
    "hash": "180b558f6e317df418aec0bf56e866aaf75e450f87cedb40c45f7882b8645b13",
    "retrieved": "/tmp/mlx-pinned-metal-utils.cpp"
  },
  {
    "path": "backend/metal/kernels.h",
    "literal": "templateFormatSource",
    "start": "  return fmt::format(\n      \"\\ntemplate [[host_name(\\\"{0}\\\")]] [[kernel]] decltype({1}) {1};\\n\",",
    "end": "\n}",
    "hash": "f45059a96ffa4cf38c6cb85754a818075563b455ca008d0ae624737546f7b972",
    "retrieved": "/tmp/mlx-pinned-metal-kernels.h"
  },
  {
    "path": "backend/metal/kernels/copy.metal",
    "literal": "precompiledEntrySource",
    "start": "  instantiate_kernel(\"gg2_copy\" #tname, copy_gg_nd2, type, type, int)",
    "end": "\n",
    "hash": "ed8a579eb6fe6a14c36560d2c8b548baf99e66fa77d300fb4ad7554883820eba"
  },
  {
    "path": "backend/metal/kernels/copy.metal",
    "literal": "precompiledTypeSource",
    "start": "instantiate_copy_itype(bfloat16, bfloat16_t)",
    "end": "\n",
    "hash": "ed8a579eb6fe6a14c36560d2c8b548baf99e66fa77d300fb4ad7554883820eba"
  },
  {
    "path": "backend/common/slicing.cpp",
    "literal": "prepareSliceSource",
    "start": "  for (int i = 0; i < in.ndim(); ++i) {\n    data_offset += start_indices[i] * in.strides()[i];",
    "end": "\n  return std::make_tuple(data_offset, inp_strides);",
    "hash": "ac82dd8972605a46dd4eab0c04303ed6758b273065bd9bde696d4591f914b1a2"
  }
];

export async function checkGeneralCopy2DHostBinding(options:{proofsRoot?:string;leanSource?:string;retrievedFiles?:Record<string,string>;selfTest?:boolean}={}):Promise<void>{
 const proofs=options.proofsRoot?pathToFileURL(resolve(options.proofsRoot)+'/'):new URL('../../',here);
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GeneralCopy2DHostDispatch.lean',here)).text();
 for(const binding of bindings){
  const cached=new URL('.lake/sources/mlx/'+revision+'/mlx/'+binding.path,proofs);
  const override=options.retrievedFiles?.[binding.path];
  const native=await Bun.file(override?resolve(override):cached).text();
  if(new Bun.CryptoHasher('sha256').update(native).digest('hex')!==binding.hash)throw Error('Pinned host source changed: '+binding.path);
  const literals=[...lean.matchAll(new RegExp('^def '+binding.literal+' : String := r#"([\\s\\S]*?)"#','gm'))];
  if(literals.length!==1)throw Error('Expected unique Lean literal '+binding.literal);
  const literal=literals[0]![1]!;
  const at=native.indexOf(binding.start);if(at<0||native.indexOf(binding.start,at+1)>=0)throw Error('Nonunique fragment start');
  const end=native.indexOf(binding.end,at+binding.start.length);if(end<0)throw Error('Missing fragment end');
  const expected=native.slice(at,end);
  const equal=(actual:string)=>{if(actual!==expected)throw Error('Literal differs from exact native fragment: '+binding.literal);};
  equal(literal);
  if(options.selfTest){
   const changed=literal.replace(/[A-Za-z]/,c=>c==='X'?'Y':'X');
   for(const mutation of [changed,literal+'\n/* changed */']){if(mutation===literal)throw Error('Empty mutation');let rejected=false;try{equal(mutation)}catch{rejected=true}if(!rejected)throw Error('Mutation escaped binding');}
  }
 }
}
if(import.meta.main){
 const retrievedFiles=process.argv.includes('--retrieved')?Object.fromEntries(bindings.filter(b=>'retrieved'in b).map(b=>[b.path,(b as {retrieved:string}).retrieved])):undefined;
 await checkGeneralCopy2DHostBinding({retrievedFiles,selfTest:process.argv.includes('--self-test')});
 console.log('Exact pinned GG2 host fragments and full-file SHA256 checks passed; host translation remains trusted.');
}
