import {checkAffineInput4SourceBinding} from "./AffineInput4SourceBinding";
import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const sourceHash="cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b";
const reviewed:Record<string,string>={
  "AffinePreload4Syntax.lean": "561dbfd598d40e704a5478439c84d231dd4efdcaa16417ef2f520a4aa2efedec",
  "AffinePreload4Source.lean": "fc1e50af148b6833fc0a77167bd4ba98a2e2d7469f507587ae93bd78d747530e"
};
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed preload source changed");}
function rejects(action:()=>void):void{let failed=false;try{action();}catch{failed=true;}if(!failed)throw Error("Preload mutation escaped validator");}
function unique(source:string,regex:RegExp):string{const matches=[...source.matchAll(regex)];if(matches.length!==1)throw Error("Missing/ambiguous preload phase");return matches[0]![0];}
function selected(source:string):Record<string,string>{return {
 sourceGroups:unique(source,/const R = [^;\r\n]*;/g),
 sourceHeader:unique(source,/for \(int c = [^\r\n]*\{/g),
 sourceBarrier:unique(source,/threadgroup_barrier\([^;\r\n]*;/g)};}
function bind(source:string,lean:string):void{for(const[name,body]of Object.entries(selected(source))){const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("(?:[^"\\\\]|\\\\.)*")$','gm'))];if(matches.length!==1||JSON.parse(matches[0]![1]!)!==body)throw Error("Parsed preload literal differs: "+name);}}
export async function checkAffinePreload4SourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 await checkAffineInput4SourceBinding(options);
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/quantization/affine-row.ts",root)).text();checkedHash(source,sourceHash);
 const lean=await Bun.file(new URL("AffinePreload4Syntax.lean",here)).text();for(const[path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);bind(source,lean);
 if(options.selfTest){rejects(()=>checkedHash(source+" ",sourceHash));for(const[path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
 for(const[from,to]of [["const R = 4, S = 16;","const R = 4, S = 8;"],["sg * 32 + lane","sg * 16 + lane"],["c < K / 16","c < K / 32"],["c += S * 32","c += S * 16"],["threadgroup_barrier(mem_flags::mem_threadgroup)","threadgroup_barrier(mem_flags::mem_device)"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
 rejects(()=>bind(source,lean.replace("c += S * 32","c += S * 16")));}
}
if(import.meta.main){await checkAffinePreload4SourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Affine preload source binding passed");}
