import {checkAffineOutputSourceBinding} from "./AffineOutputSourceBinding";
import {checkAffinePreload4SourceBinding} from "./AffinePreload4SourceBinding";
import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const sourceHash="cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b";
const reviewed:Record<string,string>={
  "AffineOuter4Syntax.lean": "b6857da27f25959ca48356a179dc1c290b61fea9af2152d59bab7e093945d764",
  "AffineOuter4Call.lean": "9dacf6677ba8991607671bc5359bc5ab8d3919941a59191448765f62210d96ef",
  "AffineOuter4Source.lean": "7323942a84f1a90274c1bcd2c4fb7b27ab3203fbc7c08e4f2a144a485a52f153"
};
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed affine outer source changed");}
function rejects(action:()=>void):void{let failed=false;try{action();}catch{failed=true;}if(!failed)throw Error("Outer mutation escaped validator");}
function unique(source:string,regex:RegExp):string{const matches=[...source.matchAll(regex)];if(matches.length!==1)throw Error("Missing/ambiguous outer phase");return matches[0]![0];}
function selected(source:string):Record<string,string>{const take=(r:RegExp)=>unique(source,r);return {
 layoutSource:[take(/constexpr int BPL = [^;\r\n]*;/g),take(/constexpr int ROWB = [^;\r\n]*;/g),take(/constexpr int GROUPS = [^;\r\n]*;/g)].join("\n  "),
 headerSource:take(/for \(int k = [^\r\n]*\)/g),
 pointersSource:[take(/const device uint8_t\* ws = [^;\r\n]*;/g),take(/const device T\* sc = [^;\r\n]*;/g),take(/const device T\* bi = [^;\r\n]*;/g)].join("\n  "),
 readsSource:take(/const float sum = [^;\r\n]*;/g)+"\n    "+take(/const threadgroup float\* x_thread = [^;\r\n]*;/g)+"\n      "+take(/const float s = [^;\r\n]*;/g)+"\n      "+take(/const float b = [^;\r\n]*;/g),
 updatesSource:[take(/ws \+= [^;\r\n]*;/g),take(/sc \+= [^;\r\n]*;/g),take(/bi \+= [^;\r\n]*;/g)].join("\n    "),
 innerHeaderSource:take(/for \(int r = [^\r\n]*\)(?= \{\n      const float s = )/g),
 initialSource:take(/float result\[R\] = [^;\r\n]*;/g),
 callSource:take(/result\[r\] [^;\r\n]*mlxq_qdot[^;\r\n]*;/g)};}
function bind(source:string,lean:string):void{for(const[name,body]of Object.entries(selected(source))){const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("(?:[^"\\\\]|\\\\.)*")$','gm'))];if(matches.length!==1||JSON.parse(matches[0]![1]!)!==body)throw Error("Parsed outer literal differs: "+name);}}
export async function checkAffineOuter4SourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 await checkAffineOutputSourceBinding(options);await checkAffinePreload4SourceBinding(options);
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/quantization/affine-row.ts",root)).text();checkedHash(source,sourceHash);
 const lean=await Bun.file(new URL("AffineOuter4Syntax.lean",here)).text();for(const[path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);bind(source,lean);
 if(options.selfTest){rejects(()=>checkedHash(source+" ",sourceHash));for(const[path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
 for(const[from,to]of [["K * BITS / 8","K * BITS / 4"],["k += 512","k += 256"],["row0 * ROWB + lane * BPL","row0 * ROWB + lane"],["ss[(k + lane * 16) / 16]","ss[(k + lane * 16) / 32]"],["sc[r * GROUPS]","sc[0]"],["sc += 8;","sc += 4;"],["float result[R] = {0};","float result[R] = {1};"],["ws + r * ROWB, x_thread, s, b, sum","ws + r * ROWB, x_thread, b, s, sum"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
 const at=source.indexOf("for (int r = 0; r < R; r++)");if(at<0)throw Error("Missing inner loop mutation");rejects(()=>bind(source.slice(0,at)+source.slice(at).replace("r < R","r <= R"),lean));
 rejects(()=>bind(source,lean.replace("k += 512","k += 256")));}
}
if(import.meta.main){await checkAffineOuter4SourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Affine outer source binding passed");}
