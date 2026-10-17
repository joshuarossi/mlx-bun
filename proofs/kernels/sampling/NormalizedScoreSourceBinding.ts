// Reviewed BF16 score/NaN phase, bound to exact selected partial-shader bytes.
// Hardware/compiler primitive correspondence and surrounding traversal stay open.
import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const sourceHash="1578cff1ef678cbff3e2e9a754c6d7ba369e455885127e8d15c8b61f22a87740";
const reviewed:Record<string,string>={
  "NormalizedScoreSourceSyntax.lean": "149a3c8e0693c7631b7139584835cb5fa637b2efef0014b60ef5a849605b76a2",
  "NormalizedScoreSourceMemory.lean": "dda7a6884e50cc3588631a71917cfc87b22ddac53bca7e356e83b3621482b7bb"
};
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed source hash changed");}
function rejects(action:()=>void):void{let rejected=false;try{action();}catch{rejected=true;}if(!rejected)throw Error("Mutation escaped production validator");}
function selected(source:string):Record<string,string>{
 const marker="const partialSource = `";const at=source.indexOf(marker);if(at<0||source.indexOf(marker,at+1)>=0)throw Error("Missing/ambiguous partial shader");
 const end=source.indexOf("`",at+marker.length);if(end<0)throw Error("Unclosed partial shader");const partial=source.slice(at+marker.length,end);
 const result:Record<string,string>={};for(const[name,pattern]of [["sourceBody",/^\s*(float value = [^;\r\n]+;)/gm],["cleanBody",/^\s*(value = [^;\r\n]+;)/gm]] as const){const matches=[...partial.matchAll(pattern)];if(matches.length!==1)throw Error("Missing/ambiguous score statement");result[name]=matches[0]![1]!;}return result;
}
function bind(source:string,lean:string):void{const actual=selected(source);for(const name of ["sourceBody","cleanBody"]){const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := "([^"\\r\\n]*)"$','gm'))];if(matches.length!==1||matches[0]![1]!==actual[name])throw Error("Parsed score literal differs");}}
export async function checkNormalizedScoreSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/sampling/normalized-argmax.ts",root)).text();checkedHash(source,sourceHash);
 const lean=await Bun.file(new URL("NormalizedScoreSourceSyntax.lean",here)).text();for(const[path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);bind(source,lean);
 if(options.selfTest){rejects(()=>checkedHash(source+" ",sourceHash));for(const[path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
 for(const[from,to]of [["float(T(logits","T(float(logits"],["row * V + i","row * V"],[" - lse[row]"," + lse[row]"],["isnan(value)","isinf(value)"],["? -INFINITY : value","? value : -INFINITY"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
 rejects(()=>bind(source,lean.replace("isnan(value)","isinf(value)")));}
}
if(import.meta.main){await checkNormalizedScoreSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Parsed normalized-score source binding passed");}
