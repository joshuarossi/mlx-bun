// Exact source-byte guard for the restricted parser and reviewed host branch.
// This does not prove the TypeScript/C ABI, descriptor attachment or compiler.
import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath} from "node:url";
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const proofPins:Record<string,string>={
  "kernels/copy/GatherFrontSyntax.lean": "e60e5a975da61716f2d9f1d47d3512f31e9d43ec6dd4b72d571c22a59341b2c4",
  "kernels/copy/GatherFrontSource.lean": "efbe74217205376b25da7e57e04da799cd36507c6c9d8caab8e5959f824d40fd",
  "kernels/copy/GatherFrontHost.lean": "1436fcd56529b2369d7fec5fe24c2a4b86d647c5a224dca972d869afa6c58205",
  "layers/QuantizedEmbeddingGatherSource.lean": "a206de02151d24064b2da013e5955667a05df8faf6a219366b32641c420601d3"
};
const nativePins:Record<string,string>={
  "mlx/backend/metal/kernels/indexing/gather_front.h": "64aacebf6576dfcd389383564fa1214bc87f2a091dd33cc64c598c5367ecab96",
  "mlx/backend/metal/kernels/indexing/indexing.h": "e820b8ee2b5132a97122780c12433ebb5100d8078d31e211d0429400a11415bb",
  "mlx/backend/metal/indexing.cpp": "6592dec7e5490acbe47301b85fd1d2b9a5186952a29ecb23e7e2ff3442d0917e",
  "mlx/ops.cpp": "6eae219354d0f9be37a064cb327c863fc3a12dba6668fd61d428e8d09d6baaf2"
};
const localPins:Record<string,string>={
  "packages/inference/src/layers/quantized-embedding.ts": "cdead9d17af0a47f7f178ee4bd6b2710364a485dd7001e4ca98c62dec991fe4c",
  "packages/mlx/src/ops.ts": "0672d9fa77e95490cad3201eb7a9eae073aa41a7c1aa0afaf3e1a640e32dc2cd"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
function body(source:string,marker:string):string {
 const at=source.indexOf(marker);if(at<0||source.indexOf(marker,at+1)>=0)throw Error("gather body marker drift");
 const start=source.indexOf("{",at);let depth=1,end=start+1;
 for(;depth&&end<source.length;end++){const c=source[end]!;if(!/[A-Za-z0-9_{}\[\]();*+=<>.,\s&?:/-]/.test(c))throw Error("gather extraction subset drift");if(c==="{")depth++;if(c==="}")depth--;}
 if(start<0||depth)throw Error("gather body unclosed");return source.slice(start+1,end-1).trim();
}
function literal(lean:string,name:string):string {
 const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := r#"([\\s\\S]*?)"#','gm'))];
 if(matches.length!==1)throw Error("gather literal drift");return matches[0]![1]!;
}
function includes(source:string,parts:string[]){for(const p of parts)if(!source.includes(p))throw Error("gather host/caller drift: "+p);}
function structure(native:Record<string,string>,local:Record<string,string>,proofs:Record<string,string>){
 const syntax=proofs["kernels/copy/GatherFrontSyntax.lean"]!;
 if(body(native["mlx/backend/metal/kernels/indexing/gather_front.h"]!,"[[kernel]] void gather_front(")!==literal(syntax,"bodySource"))throw Error("gather native body differs from Lean");
 if(body(native["mlx/backend/metal/kernels/indexing/indexing.h"]!,"METAL_FUNC size_t offset_neg_idx(")!==literal(syntax,"indexSource"))throw Error("gather index body differs from Lean");
 includes(native["mlx/backend/metal/indexing.cpp"]!,[
  'bool large_index = nidx && inputs[1].size() > INT32_MAX;',
  'bool large_src = src.size() > INT32_MAX;','bool large_out = out.size() > INT32_MAX;',
  'if (src.flags().row_contiguous && nidx == 1 && axes_[0] == 0 &&',
  'inputs[1].flags().row_contiguous && slice_size == src.strides()[0])',
  'int work_per_thread = (slice_size > 8 && src.dtype().size() < 4) ? 2 : 1;',
  'large ? "int64_t" : "int"','size_t dim_x = (slice_size + work_per_thread - 1) / work_per_thread;',
  'size_t dim_y = indices.size();','compute_encoder.set_input_array(src, 0);',
  'compute_encoder.set_input_array(indices, 1);','compute_encoder.set_output_array(out, 2);',
  'compute_encoder.set_bytes(slice_size, 3);','compute_encoder.set_bytes(src.shape(0), 4);',
  'compute_encoder.dispatch_threads(grid_dims, group_dims);']);
 includes(native["mlx/ops.cpp"]!,['Shape slice_sizes = a.shape();','slice_sizes[axis] = 1;',
  'auto out = gather(a, indices, axis, slice_sizes, s);','if (axis != 0)',
  'return squeeze(out, indices.ndim() + axis, s);']);
 includes(local["packages/inference/src/layers/quantized-embedding.ts"]!,[
  'const rows = ops.takeAxis(this.w, ids, 0);','const scaleRows = ops.takeAxis(this.scales, ids, 0);',
  'const biasRows = this.biases ? ops.takeAxis(this.biases, ids, 0) : null;',
  'const out = ops.dequantize(rows, scaleRows, biasRows, this.spec);']);
 includes(local["packages/mlx/src/ops.ts"]!,['outArray("take_axis", (o) => C.mlx_take_axis(o, a.handle, indices.handle, axis, s))']);
}
function checkPins(pins:Record<string,string>,sources:Record<string,string>){for(const[p,h]of Object.entries(pins))if(hash(sources[p]??"")!==h)throw Error("gather pinned source drift: "+p);}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("gather mutation accepted");}
async function read(paths:Record<string,string>,prefix:string){return Object.fromEntries(await Promise.all(Object.keys(paths).map(async p=>[p,await Bun.file(resolve(prefix,p)).text()])));}
export async function checkGatherFrontSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??fileURLToPath(new URL("../../",import.meta.url));
 const [native,local,proofs]=await Promise.all([read(nativePins,resolve(root,".lake/sources/mlx/"+revision)),read(localPins,resolve(root,"..")),read(proofPins,root)]);
 checkPins(nativePins,native);checkPins(localPins,local);checkPins(proofPins,proofs);structure(native,local,proofs);
 if(options.selfTest){
  const mutations:[string,string,string][]=[
   ['mlx/backend/metal/kernels/indexing/gather_front.h','src[src_idx + s_idx]','src[out_idx + s_idx]'],
   ['mlx/backend/metal/kernels/indexing/gather_front.h','i < N && s_idx < stride','i < N'],
   ['mlx/backend/metal/kernels/indexing/indexing.h','idx + size','idx - size'],
   ['mlx/backend/metal/indexing.cpp','slice_size > 8','slice_size > 80'],
   ['mlx/backend/metal/indexing.cpp','set_input_array(indices, 1)','set_input_array(indices, 0)'],
   ['mlx/ops.cpp','slice_sizes[axis] = 1;','slice_sizes[axis] = 2;']];
  for(const[file,from,to]of mutations){const changed=native[file]!.replace(from,to);if(changed===native[file])throw Error("gather native mutation anchor");rejected(()=>structure({...native,[file]:changed},local,proofs));}
  const p='packages/inference/src/layers/quantized-embedding.ts';
  const changed=local[p]!.replace('ops.takeAxis(this.scales, ids, 0)','ops.takeAxis(this.scales, ids, 1)');
  if(changed===local[p])throw Error("gather caller mutation anchor");rejected(()=>structure(native,{...local,[p]:changed},proofs));
  for(const p of Object.keys(proofPins))rejected(()=>checkPins(proofPins,{...proofs,[p]:proofs[p]+"\n"}));
  for(const p of Object.keys(nativePins))rejected(()=>checkPins(nativePins,{...native,[p]:native[p]+"\n"}));
 }
}
if(import.meta.main){await checkGatherFrontSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Embedding gather parsed source/host/current-memory binding passed.");}
