import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
import {checkMlxLogAddExpSourceBinding} from "./MlxLogAddExpSourceBinding.ts";
const runtimeHash="3f0e11f777f57b6595d57d62ec3f8b8331cbfa7263183e1baa98892efe935aec";
const pins:Record<string,string>={
  "ComputeGHostSyntax": "359d055ca57fb086850d3dad6b1a1c5fefd3e17a82ad81f0d6e65bb1b9529ecc",
  "ComputeGHostSource": "1b2a0dc039543dd5ad79e6c06cecf64925fb2255beb6c084e554ea7495eb7340",
  "ComputeGHostMemory": "b65242a12b258195aeed0415bf5f67d230840c6e1485e4b705094dfd41825305"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function extract(runtime:string):{body:string;caller:string}{
 const start=runtime.indexOf("export function computeG(");if(start<0)throw Error("computeG source missing");
 const fn=runtime.slice(start);const begin=fn.indexOf("const aL = inp[0]!");const end=fn.indexOf("return [g];",begin);
 const caller=fn.match(/return _computeGFn\.apply\([^\n]*/)?.[0];
 if(begin<0||end<0||caller===undefined)throw Error("computeG source slice missing");
 return {body:fn.slice(begin,end+"return [g];".length),caller};
}
export function checkExtracted(runtime:string,syntax:string):void{
 const actual=extract(runtime);const body=syntax.match(/def sourceBody : String := r#"([\s\S]*?)"#/ )?.[1];
 const tokens=syntax.match(/def bodyTokens : Tokens := (\[[^\n]*\])/ )?.[1];
 const actualTokens=actual.body.replace(/\/\/[^\n]*/g,"").match(/[A-Za-z0-9_]+|[()\[\]{},;=!.:?>]/g);
 if(tokens===undefined||JSON.stringify(JSON.parse(tokens))!==JSON.stringify(actualTokens))throw Error("computeG token extraction drift");
 const caller=syntax.match(/def callerSource : String := "((?:[^"\\]|\\.)*)"/)?.[1];
 if(body!==actual.body||caller===undefined||JSON.parse(`"${caller}"`)!==actual.caller)throw Error("computeG extracted source literal drift");
 for(const fragment of ["_computeGFn = new CompiledFunction((inp)","return _computeGFn.apply([aLog, a, dtBias])[0]!;"])
  if(!runtime.includes(fragment))throw Error("computeG reviewed frontend boundary drift");
}
export function checkSource(runtime:string,leans:Record<string,string>):void{
 if(hash(runtime)!==runtimeHash)throw Error("computeG runtime source drift");
 if(Object.keys(pins).length!==3)throw Error("computeG verification pins not finalized");
 for(const[file,pin]of Object.entries(pins))if(hash(leans[file]??"")!==pin)throw Error("computeG proof drift");
 checkExtracted(runtime,leans.ComputeGHostSyntax!);
}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("computeG mutation accepted");}
export async function checkComputeGHostSourceBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const runtime=await Bun.file(resolve(root,"../packages/inference/src/kernels/delta/gated.ts")).text();
 const leans=Object.fromEntries(await Promise.all(Object.keys(pins).map(async f=>[f,await Bun.file(resolve(root,`kernels/delta/${f}.lean`)).text()])));
 await checkMlxLogAddExpSourceBinding(options);checkSource(runtime,leans);
 if(options.selfTest){
  for(const[a,b]of [["inp[0]!, aa = inp[1]!","inp[1]!, aa = inp[0]!"],["aL.astype(Dtype.float32)","aL.astype(Dtype.bfloat16)"],
   ["ops.add(aa, dt)","ops.mul(aa, dt)"],["new Uint8Array([0, 0])","new Uint8Array([0, 1])"],
   ["ops.logaddexp(adt, zero)","ops.logaddexp(zero, adt)"],["ops.mul(negExpA, sp)","ops.mul(expA, sp)"],
   ["[aLog, a, dtBias]","[aLog, dtBias, a]"]]){
   const bad=runtime.replace(a!,b!);if(bad===runtime)throw Error("computeG runtime mutation anchor missing");
   rejected(()=>checkSource(bad,leans));rejected(()=>checkExtracted(bad,leans.ComputeGHostSyntax!));
  }
  for(const f of Object.keys(pins))rejected(()=>checkSource(runtime,{...leans,[f]:leans[f]+"\n"}));
  for(const[a,b]of [["ops.exp(prod)","ops.exp(negExpA)"],["ops.add(aa, dt)","ops.add(dt, aa)"]]){
   const bad=leans.ComputeGHostSyntax!.replace(a!,b!);if(bad===leans.ComputeGHostSyntax)throw Error("computeG Lean mutation anchor missing");
   rejected(()=>checkSource(runtime,{...leans,ComputeGHostSyntax:bad}));rejected(()=>checkExtracted(runtime,bad));
  }
  const badTokens=leans.ComputeGHostSyntax!.replace('"const","aL","=","inp","[","0"','"const","aL","=","inp","[","2"');
  if(badTokens===leans.ComputeGHostSyntax)throw Error("computeG token mutation anchor missing");
  rejected(()=>checkExtracted(runtime,badTokens));rejected(()=>checkSource(runtime,{...leans,ComputeGHostSyntax:badTokens}));
  rejected(()=>checkSource(runtime+"\n",leans));
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkComputeGHostSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("computeG compiled host graph source binding passed.");}
