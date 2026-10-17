// Bind the parsed final assignment to the selected B1 finish shader. Surrounding
// SIMD-block ownership, compiler and hardware execution remain explicit contracts.
import {checkArgmaxShuffleSourceBinding} from "./ArgmaxShuffleSourceBinding";
import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const sourceHash="1578cff1ef678cbff3e2e9a754c6d7ba369e455885127e8d15c8b61f22a87740";
const reviewed:Record<string,string>={
  "ArgmaxFinalStoreSyntax.lean": "4aba33ce4c1f80755de5b6ba612a2c98f0fab86d7f180af69a3812a2a41316bb",
  "ArgmaxFinalStoreMemory.lean": "dd8b8a46c09eb7c2bae1e12f919c011d2ea27d43cc7b9510fdb030aea91ec29c"
};
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed source hash changed");}
function rejects(action:()=>void):void{let rejected=false;try{action();}catch{rejected=true;}if(!rejected)throw Error("Mutation escaped production validator");}
function selected(source:string):string{
 const marker="const finishSource = `";const at=source.indexOf(marker);
 if(at<0||source.indexOf(marker,at+1)>=0)throw Error("Missing/ambiguous finish shader");
 const end=source.indexOf("`",at+marker.length);if(end<0)throw Error("Unclosed finish shader");
 const finish=source.slice(at+marker.length,end);
 const statements=[...finish.matchAll(/if \([^()\r\n]*\) out\[[^;\r\n]*;/g)];
 if(statements.length!==1)throw Error("Expected exactly one final-store statement");
 return statements[0]![0];
}
function bind(source:string,lean:string):void{
 const literals=[...lean.matchAll(/^def sourceBody : String := "([^"\r\n]*)"$/gm)];
 if(literals.length!==1||selected(source)!==literals[0]![1])throw Error("Parsed final-store literal differs");
}
export async function checkArgmaxFinalStoreSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 await checkArgmaxShuffleSourceBinding(options);
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/sampling/normalized-argmax.ts",root)).text();checkedHash(source,sourceHash);
 const lean=await Bun.file(new URL("ArgmaxFinalStoreSyntax.lean",here)).text();
 for(const[path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);
 bind(source,lean);
 if(options.selfTest){
  rejects(()=>checkedHash(source+" ",sourceHash));
  for(const[path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
  for(const[from,to]of [["if (lane == 0) out[row] = bestId;","if (lane == 1) out[row] = bestId;"],["out[row] = bestId;","out[row + 1] = bestId;"],["out[row] = bestId;","out[row] = tid;"],["if (lane == 0) out[row]","if (lane != 0) out[row]"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
  rejects(()=>bind(source,lean.replace('"if (lane == 0) out[row] = bestId;"','"if (lane == 0) out[row] = tid;"')));
 }
}
if(import.meta.main){await checkArgmaxFinalStoreSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Parsed argmax final-store source binding passed");}
