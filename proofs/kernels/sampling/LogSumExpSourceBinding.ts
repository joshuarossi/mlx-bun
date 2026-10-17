import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkArgmaxLaunchSourceBinding} from "./ArgmaxLaunchSourceBinding.ts";
const revision="1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const nativePins:Record<string,string>={
 "logsumexp.cpp":"e629a1fa0b8744c7ee7913ccdb37caf6d22ad76aa6945282aa6adc4afdd316e7",
 "kernels/logsumexp.h":"233f9a7072bed21f2b71f522c41aa5e86208e3bcfd18fafc87cf28a7d7f13154",
 "kernels/logsumexp.metal":"f9bec5e1e5a23d20bedf9ff8d29a8c03bbb5144bc5d751bbfe906d32ee894817",
 "kernels/utils.h":"5e1568e9edde9d05dbf86f68fa0d6c6240f2c32b973c7c6a76166b9c0d91543d"
};
const pins:Record<string,string>={
  "LogSumExpSourceSyntax": "482386a166d9cc78fd67f5dcb43d5711ce9a141471dcf6d73d5687f0653b5673",
  "LogSumExpSourceArithmetic": "d849a02a8375dc2a78313aed0032b3f31becc9700f13007f24a174d52007b8d3",
  "LogSumExpSourceGeometry": "137461cdb8d138829b5b6278ccb62bc28837362c08640475b652ae1fc98e67fb",
  "LogSumExpSourceLoop": "9d4deb8a39fd491e930d629b9bc2cceaba5c9138da4639af0dc37ff5999a80ae",
  "LogSumExpSourceMerge": "bff74816a233db06671cac9e3ff4025fb50e1d23fc5fac7082da750d3574d6d6",
  "LogSumExpSourceScratch": "a0406daceec461f579bf4f08045f456cb0274f04de6469a1781c43c78d2aea15",
  "LogSumExpSourceHost": "e3957cbe8623d8ca8440082521913e25a0da8a82471087fc85976bef36097b46",
  "LogSumExpSourceMemory": "07fd28ac5ddac932bcf876d4aca44d1e9755f0a1680ee9e2f91126a867a04c9e",
  "LogSumExpSamplerSource": "c546740c58619ca1cf617d3231132629ce7aa43d9af107993c27f66316215f65"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
const phases=["pointer","setup","loop","group","maxScratch","normalizerScratch","output"] as const;
export function tokenize(source:string):string[]{
 const plain=source.replace(/\/\/[^\n]*/g,"");const token=/[A-Za-z0-9_]+|[()\[\]{};,=+*<>?:.\/-]/g;
 const tokens=plain.match(token)??[];if(plain.replace(token,"").trim()!=="")throw Error("Unsupported logsumexp source token");return tokens;
}
export function extract(header:string):Record<string,string>{
 const start=header.indexOf("[[kernel]] void logsumexp_looped(");const open=header.indexOf(") {",start)+2;
 if(start<0||open<2)throw Error("Logsumexp looped kernel boundary missing");
 let depth=1,end=open+1;for(;depth&&end<header.length;end++){if(header[end]==="{")depth++;if(header[end]==="}")depth--;}
 if(depth)throw Error("Logsumexp looped kernel is unclosed");const body=header.slice(open+1,end-1).trim();
 const balanced=(begin:number)=>{let level=0,found=false;for(let i=begin;i<body.length;i++){
  if(body[i]==="{"){level++;found=true;}if(body[i]==="}"&&--level===0&&found)return i+1;
 }throw Error("Logsumexp outer loop is unclosed");};
 const pointerEnd=body.indexOf(";")+1,loopStart=body.indexOf("for (int r"),loopEnd=balanced(loopStart);
 const groupEnd=body.indexOf("  prevmax = maxval;",body.indexOf("normalizer = simd_sum(normalizer);",loopEnd));
 const maxText="maxval = simd_max(local_max[simd_lane_id]);",maxStart=body.indexOf(maxText,groupEnd),maxEnd=maxStart+maxText.length;
 const normText="normalizer = simd_sum(local_normalizer[simd_lane_id]);",normStart=body.indexOf(normText,maxEnd),normEnd=normStart+normText.length;
 if(pointerEnd<=0||loopStart<0||groupEnd<0||maxStart<0||normStart<0)throw Error("Logsumexp native phase boundary missing");
 return {body,pointer:body.slice(0,pointerEnd).trim(),setup:body.slice(pointerEnd,loopStart).trim(),loop:body.slice(loopStart,loopEnd).trim(),
 group:body.slice(loopEnd,groupEnd).trim(),maxScratch:body.slice(groupEnd,maxEnd).trim(),normalizerScratch:body.slice(maxEnd,normEnd).trim(),output:body.slice(normEnd).trim()};
}
export function checkExtracted(header:string,syntax:string):void{
 const actual=extract(header);const body=syntax.match(/def bodyTokens : Tokens := (\[[^\n]*\])/ )?.[1];
 if(body===undefined||JSON.stringify(JSON.parse(body))!==JSON.stringify(tokenize(actual.body!)))throw Error("Logsumexp full-body token extraction drift");
 for(const phase of phases){const literal=syntax.match(new RegExp(`\\| \\.${phase} => (\\[[^\\n]*\\])`))?.[1];
  if(literal===undefined||JSON.stringify(JSON.parse(literal))!==JSON.stringify(tokenize(actual[phase]!)))throw Error(`Logsumexp native grammar drift: ${phase}`);
 }
}
const hostFragments=[
 "constexpr int LOGSUMEXP_LOOPED_LIMIT = 4096;","if (x.flags().contiguous && x.strides()[x.ndim() - 1] == 1)",
 "auto in = ensure_contiguous(inputs[0]);","if (in.flags().row_contiguous)","out.set_data(allocator::malloc(out.nbytes()));",
 "int axis_size = in.shape().back();","int n_rows = in.data_size() / axis_size;","const int simd_size = 32;","const int n_reads = 4;",
 'std::string kernel_name = (axis_size > looped_limit) ? "looped_" : "block_";',"kernel_name += type_to_name(out);",
 "auto kernel = get_logsumexp_kernel(d, kernel_name, out);","size_t threadgroup_size = kernel->maxTotalThreadsPerThreadgroup();",
 "size_t n_threads = n_rows * threadgroup_size;","grid_dims = MTL::Size(n_threads, 1, 1);","group_dims = MTL::Size(threadgroup_size, 1, 1);",
 "compute_encoder.set_input_array(in, 0);","compute_encoder.set_output_array(out, 1);","compute_encoder.set_bytes(axis_size, 2);",
 "compute_encoder.dispatch_threads(grid_dims, group_dims);"
];
export function checkNative(sources:Record<string,string>):void{
 const host=sources["logsumexp.cpp"]!,header=sources["kernels/logsumexp.h"]!,metal=sources["kernels/logsumexp.metal"]!,utils=sources["kernels/utils.h"]!;
 for(const fragment of hostFragments)if(!host.includes(fragment))throw Error("Logsumexp selected host translation drift");
 for(const fragment of ["template <typename T, typename AccT = float, int N_READS = 4>","uint gid [[threadgroup_position_in_grid]]", "uint lid [[thread_position_in_threadgroup]]",
  "uint lsize [[threads_per_threadgroup]]"])if(!header.includes(fragment))throw Error("Logsumexp native argument binding drift");
 for(const fragment of ['instantiate_kernel("looped_logsumexp_" #name, logsumexp_looped, itype)',"instantiate_logsumexp(bfloat16, bfloat16_t)"])
  if(!metal.includes(fragment))throw Error("Logsumexp selected BF16 instantiation drift");
 for(const fragment of ["inline T ceildiv(T N, U M)","return (N + M - 1) / M;","-metal::numeric_limits<type>::infinity();",
  "-metal::numeric_limits<type>::max();","instantiate_float_limit(float);"])
  if(!utils.includes(fragment))throw Error("Logsumexp ceildiv/float limits helper drift");
}
export function checkSource(native:Record<string,string>,leans:Record<string,string>):void{
 for(const[file,pin]of Object.entries(nativePins))if(hash(native[file]??"")!==pin)throw Error("Pinned logsumexp native source drift");
 if(Object.keys(pins).length!==9)throw Error("Logsumexp proof verification pins not finalized");
 for(const[file,pin]of Object.entries(pins))if(hash(leans[file]??"")!==pin)throw Error("Logsumexp proof source drift");
 checkNative(native);checkExtracted(native["kernels/logsumexp.h"]!,leans.LogSumExpSourceSyntax!);
}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("Logsumexp source mutation accepted");}
export async function checkLogSumExpSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const native=Object.fromEntries(await Promise.all(Object.keys(nativePins).map(async file=>[file,await Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/${file}`)).text()])));
 const leans=Object.fromEntries(await Promise.all(Object.keys(pins).map(async file=>[file,await Bun.file(resolve(root,`kernels/sampling/${file}.lean`)).text()])));
 await checkArgmaxLaunchSourceBinding({repositoryRoot:resolve(root,".."),selfTest:options.selfTest});checkSource(native,leans);
 if(options.selfTest){
  const header=native["kernels/logsumexp.h"]!,syntax=leans.LogSumExpSourceSyntax!;
  for(const phase of phases){const fragment=extract(header)[phase]!;const bad=header.replace(fragment,fragment.replace(/./,"!"));
   rejected(()=>checkSource({...native,"kernels/logsumexp.h":bad},leans));rejected(()=>checkExtracted(bad,syntax));}
  for(const[a,b]of [["offset + N_READS <= axis_size","offset + N_READS < axis_size"],["offset + i < axis_size","offset + i <= axis_size"],
   ["(maxval < vals[i])","(maxval <= vals[i])"],["normalizer *= fast::exp(prevmax - maxval)","normalizer += fast::exp(prevmax - maxval)"],
   ["normalizer += fast::exp(vals[i] - maxval)","normalizer += fast::exp(maxval - vals[i])"],
   ["local_max[simd_lane_id]","local_max[simd_group_id]"],["threadgroup_barrier(mem_flags::mem_threadgroup);",""],
   ["T(log(normalizer) + maxval)","T(log(normalizer)) + maxval"]]){
   const bad=header.replaceAll(a!,b!);if(bad===header)throw Error("Logsumexp native mutation anchor missing");
   rejected(()=>checkSource({...native,"kernels/logsumexp.h":bad},leans));rejected(()=>checkExtracted(bad,syntax));
  }
  for(const[a,b]of [["kernel->maxTotalThreadsPerThreadgroup()","32"],["in.data_size() / axis_size","in.size() / axis_size"],["set_bytes(axis_size, 2)","set_bytes(axis_size, 3)"]]){
   const bad=native["logsumexp.cpp"]!.replaceAll(a!,b!);if(bad===native["logsumexp.cpp"])throw Error("Logsumexp host mutation anchor missing");
   rejected(()=>checkSource({...native,"logsumexp.cpp":bad},leans));rejected(()=>checkNative({...native,"logsumexp.cpp":bad}));
  }
  for(const[file,a,b]of [["kernels/logsumexp.h","typename AccT = float","typename AccT = half"],
   ["kernels/logsumexp.metal","instantiate_logsumexp(bfloat16, bfloat16_t)","instantiate_logsumexp(bfloat16, half)"],
   ["kernels/utils.h","return (N + M - 1) / M;","return (N + M) / M;"],
   ["kernels/utils.h","-metal::numeric_limits<type>::max();","-metal::numeric_limits<type>::infinity();"]]){
   const bad=native[file!]!.replaceAll(a!,b!);if(bad===native[file!])throw Error("Logsumexp type/helper mutation anchor missing");
   rejected(()=>checkSource({...native,[file!]:bad},leans));rejected(()=>checkNative({...native,[file!]:bad}));
  }
  for(const file of Object.keys(pins))rejected(()=>checkSource(native,{...leans,[file]:leans[file]+"\n"}));
  const badTokens=syntax.replace('def bodyTokens : Tokens := ["in"','def bodyTokens : Tokens := ["out"');
  const badGrammar=syntax.replace('| .pointer => ["in"','| .pointer => ["out"');
  for(const bad of [badTokens,badGrammar]){if(bad===syntax)throw Error("Logsumexp Lean token mutation anchor missing");rejected(()=>checkSource(native,{...leans,LogSumExpSourceSyntax:bad}));rejected(()=>checkExtracted(header,bad));}
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkLogSumExpSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Parsed looped logsumexp/current sampler source binding passed.");}
