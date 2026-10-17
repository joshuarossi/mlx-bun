import {checkArgmaxShuffleSourceBinding} from "./ArgmaxShuffleSourceBinding";
import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const sourceHash="1578cff1ef678cbff3e2e9a754c6d7ba369e455885127e8d15c8b61f22a87740";
const reviewed:Record<string,string>={
  "ArgmaxSourceOrigins.lean": "8710f6def1adfeee30f94a85f21b74347e3e4233820bf247687a97e51125f5dd",
  "ArgmaxScratchSourceSyntax.lean": "f4b7cd695b8f7c7d3c9f02d7f112cda837d79a88b680b5c2327b87410511255c",
  "ArgmaxScratchSourceMemory.lean": "773c7ccfd625fa02eed99751a7905d1ff6f894fe72cb55487437e51326cd1d78"
};
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed source hash changed");}
function rejects(action:()=>void):void{let failed=false;try{action();}catch{failed=true;}if(!failed)throw Error("Scratch mutation escaped validator");}
function selected(source:string):string{const marker="const reduction = `";const at=source.indexOf(marker);if(at<0||source.indexOf(marker,at+1)>=0)throw Error("Missing/ambiguous shared reduction");const end=source.indexOf("`",at+marker.length);if(end<0)throw Error("Unclosed shared reduction");const reduction=source.slice(at+marker.length,end);const fragments=[...reduction.matchAll(/threadgroup float scores\[[^\]]+\];[\s\S]*?threadgroup_barrier\([^;]*\);/g)];if(fragments.length!==1)throw Error("Missing/ambiguous scratch phase");return fragments[0]![0];}
function bind(source:string,lean:string):void{const literals=[...lean.matchAll(/^def sourceBody : String := r#"([\s\S]*?)"#/gm)];if(literals.length!==1||selected(source)!==literals[0]![1])throw Error("Parsed scratch literal differs");}
export async function checkArgmaxScratchSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 await checkArgmaxShuffleSourceBinding(options);
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/sampling/normalized-argmax.ts",root)).text();checkedHash(source,sourceHash);
 const lean=await Bun.file(new URL("ArgmaxScratchSourceSyntax.lean",here)).text();for(const[path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);bind(source,lean);
 if(options.selfTest){rejects(()=>checkedHash(source+" ",sourceHash));for(const[path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
 for(const[from,to]of [["float scores[4]","float scores[3]"],["uint ids[4]","float ids[4]"],["scores[simd] = best","scores[lane] = best"],["ids[simd] = bestId","ids[simd] = best"],["mem_flags::mem_threadgroup","mem_flags::mem_device"],["if (lane == 0) { scores","if (lane == 1) { scores"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
 rejects(()=>bind(source,lean.replace("mem_flags::mem_threadgroup","mem_flags::mem_device")));}
}
if(import.meta.main){await checkArgmaxScratchSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Parsed argmax scratch source binding passed");}
