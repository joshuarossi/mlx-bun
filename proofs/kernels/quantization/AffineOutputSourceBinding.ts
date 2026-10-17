import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const sourceHash="cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b";
const reviewed:Record<string,string>={
  "AffineOutputSyntax.lean": "1f52c830a1ad70c7646448442461a5c0a07f6453764bc3eb4454b382ea3a52e7",
  "AffineOutputSource.lean": "0f66a67432ee8291cb12d0befff9b14345f84b76a96027b8bacbd052f111be02"
};
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed affine output source changed");}
function rejects(action:()=>void):void{let failed=false;try{action();}catch{failed=true;}if(!failed)throw Error("Output mutation escaped validator");}
function unique(source:string,regex:RegExp):string{const matches=[...source.matchAll(regex)];if(matches.length!==1)throw Error("Missing/ambiguous output phase");return matches[0]![0];}
function selected(source:string):Record<string,string>{return {
 configSource:unique(source,/const R = [^;\r\n]*;/g),
 rowSource:unique(source,/const int row0 = [^;\r\n]*;/g),
 loopSource:unique(source,/for \(int r = [^\r\n]*\)(?= \{\n    const float v = )/g),
 projectionSource:unique(source,/const float v = [^;\r\n]*;/g),
 storeSource:unique(source,/if \(lane [^\r\n]*y\[[^;\r\n]*;/g)};}
function bind(source:string,lean:string):void{for(const[name,body]of Object.entries(selected(source))){const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("(?:[^"\\\\]|\\\\.)*")$','gm'))];if(matches.length!==1||JSON.parse(matches[0]![1]!)!==body)throw Error("Parsed output literal differs: "+name);}}
export async function checkAffineOutputSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/quantization/affine-row.ts",root)).text();checkedHash(source,sourceHash);
 const lean=await Bun.file(new URL("AffineOutputSyntax.lean",here)).text();for(const[path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);bind(source,lean);
 if(options.selfTest){rejects(()=>checkedHash(source+" ",sourceHash));for(const[path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
 for(const[from,to]of [["const R = 4, S = 16;","const R = 4, S = 8;"],["threadgroup_position_in_grid.y * S + sg","threadgroup_position_in_grid.x * S + sg"],["const float v = simd_sum(result[r]);","const float v = simd_sum(result[0]);"],["if (lane == 0) y[row0 + r]","if (lane == 1) y[row0 + r]"],["static_cast<T>(v)","static_cast<float>(v)"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
 const loop=source.lastIndexOf("for (int r = 0; r < R; r++)");if(loop<0)throw Error("Missing mutation target");rejects(()=>bind(source.slice(0,loop)+source.slice(loop).replace("r < R","r <= R"),lean));
 rejects(()=>bind(source,lean.replace("simd_sum(result[r])","simd_sum(result[0])")));}
}
if(import.meta.main){await checkAffineOutputSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Affine output source binding passed");}
