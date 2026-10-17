// Source bytes and reviewed host selection remain a trusted binding layer.
// This guard does not validate native descriptors, compiler lowering or Metal.
import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath} from "node:url";
import {checkGatherFrontSourceBinding} from "../copy/GatherFrontSourceBinding.ts";

const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const proofPins:Record<string,string>={
  "kernels/quantization/AffineDequantizeSyntax.lean": "1ea287e4b3eabf225e1ee36b45b6f23fd6b0a80b92f26e1ead8e840c87363a83",
  "kernels/quantization/AffineDequantizeSource.lean": "b17b8b945b43a2153a16fbf1604b5fcb3744d2ecada2784c7c87d02653627aca",
  "kernels/quantization/AffineDequantizeHost.lean": "2f63821b8688b4a7946d74dc32ad1d3e5008e51866dbd11db9a686c08e4ca181",
  "layers/QuantizedEmbeddingDequantizeSource.lean": "6729821f92084561c207d32cf3ff51fe3c9bcfe0f973f0df65c3cc04d0155f59",
  "layers/QuantizedEmbeddingParsedPipeline.lean": "11563b36fb9dccb354c2e8d6e6458e84fff0c87910e06a26b9b90f82eec50d07"
};
const nativePins:Record<string,string>={
  "mlx/backend/metal/kernels/quantized.h":"2a007016da606afe569adb9adcc05e00f14558ad2e094bcb4f8974beb53c316f",
  "mlx/backend/metal/quantized.cpp":"44483286a359afb7f35d8a9c1658ffaec6ff6c01a7ab34ac7bb35cf6438804a6",
  "mlx/backend/metal/kernels/bf16.h":"abd87446a310b77ac530ef52a324feae5cb285d03ec9613e3a88ebb71410fdcb",
};
const hash=(source:string)=>createHash("sha256").update(source).digest("hex");

function body(source:string,marker:string):string {
  const at=source.indexOf(marker);
  if(at<0||source.indexOf(marker,at+1)>=0)throw Error("dequantize declaration drift");
  const start=source.indexOf("{",at);let depth=1,end=start+1;
  for(;depth&&end<source.length;end++){
    const c=source[end]!;
    if(!/[A-Za-z0-9_{}\[\]();*+=<>.,\s&|#?:/\-]/.test(c))throw Error("dequantize extraction subset drift");
    if(c==="{")depth++;if(c==="}")depth--;
  }
  if(start<0||depth)throw Error("dequantize body unclosed");
  return source.slice(start+1,end-1).trim();
}
function literal(source:string,name:string):string {
  const matches=[...source.matchAll(new RegExp('^def '+name+' : String := r#"([\\s\\S]*?)"#','gm'))];
  if(matches.length!==1)throw Error("dequantize literal drift");return matches[0]![1]!;
}
function structure(native:Record<string,string>,proofs:Record<string,string>):void {
  const kernel=native["mlx/backend/metal/kernels/quantized.h"]!;
  if(!native["mlx/backend/metal/kernels/bf16.h"]!.includes("typedef bfloat bfloat16_t;"))throw Error("dequantize BF16 type drift");
  const syntax=proofs["kernels/quantization/AffineDequantizeSyntax.lean"]!;
  for(const[marker,name]of [["[[kernel]] void affine_dequantize(","bodySource"],
    ["inline constexpr short get_pack_factor()","packSource"],
    ["inline constexpr short get_bytes_per_pack()","bytesSource"]]){
    const extracted=body(kernel,marker!);
    if(extracted!==literal(syntax,name!))throw Error("dequantize source differs from Lean "+name);
    const tokenName=name!.replace(/Source$/,"Tokens");
    const matches=[...syntax.matchAll(new RegExp('^def '+tokenName+' : Tokens := (\\[[^\\n]*\\])$','gm'))];
    if(matches.length!==1)throw Error("dequantize token declaration drift");
    const tokens=extracted.match(/[A-Za-z0-9_.]+|[^\s]/g);
    if(JSON.stringify(tokens)!==JSON.stringify(JSON.parse(matches[0]![1]!)))throw Error("dequantize guarded token extraction drift");
  }
  const host=native["mlx/backend/metal/quantized.cpp"]!;
  for(const part of [
    "int packs_per_int = (bits == 3 || bits == 5) ? 8 : bits == 6 ? 4 : 8 / bits;",
    "dequantize ? out.size() / packs_per_int : w.size() / per_thread;",
    "NS::UInteger thread_group_size = kernel->maxTotalThreadsPerThreadgroup();",
    "if (thread_group_size > nthreads)","thread_group_size = nthreads;",
    "bool use_2d = nthreads > UINT_MAX;","MTL::Size(nthreads, 1, 1);",
    "bool has_biases = (mode == QuantizationMode::Affine);",
    "auto w = ensure_row_contiguous(w_pre, d, s);",
    "auto scales = ensure_row_contiguous(inputs[1], d, s);",
    "auto biases = ensure_row_contiguous(inputs[2], d, s);",
    "compute_encoder.set_input_array(biases, 2);","compute_encoder.set_input_array(w, 0);",
    "compute_encoder.set_input_array(scales, 1);","compute_encoder.set_output_array(out, 3);",
    "auto type_string = dequantize ? get_type_string(out.dtype())",
    'mode_string + (dequantize ? "_dequantize" : "_quantize")',
    "get_quantize_kernel_dims(kernel, w, out, group_size, bits, dequantize);",
    "compute_encoder.dispatch_threads(grid_dims, group_dims);"]){
    if(!host.includes(part))throw Error("dequantize host drift "+part);
  }
}
function pins(expected:Record<string,string>,sources:Record<string,string>):void {
  for(const[path,sha]of Object.entries(expected))if(hash(sources[path]??"")!==sha)throw Error("dequantize source pin drift "+path);
}
function rejected(action:()=>void){let failed=false;try{action();}catch{failed=true;}if(!failed)throw Error("dequantize mutation accepted");}
async function read(paths:Record<string,string>,prefix:string){return Object.fromEntries(await Promise.all(Object.keys(paths).map(async p=>[p,await Bun.file(resolve(prefix,p)).text()])));}

export async function checkAffineDequantizeSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
  if(Object.keys(proofPins).length!==5)throw Error("dequantize proof pins not finalized");
  const root=options.proofsRoot??fileURLToPath(new URL("../../",import.meta.url));
  const [native,proofs]=await Promise.all([read(nativePins,resolve(root,".lake/sources/mlx/"+revision)),read(proofPins,root)]);
  await checkGatherFrontSourceBinding(options);
  pins(nativePins,native);pins(proofPins,proofs);structure(native,proofs);
  if(options.selfTest){
    const file="mlx/backend/metal/kernels/quantized.h";
    const mutations:[string,string,string][]=[
      [file,"uint val = w[offset];","uint val = w[0];"],
      [file,"d = (val >> (bits * i)) & 0x0f;","d = (val >> (bits * i)) & 0x03;"],
      [file,"out[i] = scale * d + bias;","out[i] = scale + d * bias;"],
      [file,"size_t gindex = oindex / group_size;","size_t gindex = offset / group_size;"],
      [file,"(bits == 6 ? 4 : wsize / bits)","(bits == 6 ? 4 : wsize * bits)"],
      ["mlx/backend/metal/quantized.cpp","dequantize ? out.size() / packs_per_int","dequantize ? out.size() * packs_per_int"],
      ["mlx/backend/metal/quantized.cpp","compute_encoder.set_input_array(biases, 2);","compute_encoder.set_input_array(biases, 1);"],
    ];
    for(const[path,from,to]of mutations){const changed=native[path]!.replace(from,to);if(changed===native[path])throw Error("dequantize mutation anchor missing");rejected(()=>structure({...native,[path]:changed},proofs));}
    const syntaxPath="kernels/quantization/AffineDequantizeSyntax.lean";
    const changedTokens=proofs[syntaxPath]!.replace('def bodyTokens : Tokens := ["constexpr"','def bodyTokens : Tokens := ["auto"');
    if(changedTokens===proofs[syntaxPath])throw Error("dequantize token mutation anchor missing");
    rejected(()=>structure(native,{...proofs,[syntaxPath]:changedTokens}));
    for(const path of Object.keys(proofPins))rejected(()=>pins(proofPins,{...proofs,[path]:proofs[path]+"\n"}));
    for(const path of Object.keys(nativePins))rejected(()=>pins(nativePins,{...native,[path]:native[path]+"\n"}));
  }
}
if(import.meta.main){await checkAffineDequantizeSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Embedding parsed dequantization and current-heap source pipeline passed.");}
