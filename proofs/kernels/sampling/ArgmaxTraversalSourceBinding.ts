import {checkNormalizedScoreSourceBinding} from "./NormalizedScoreSourceBinding";
import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const sourceHash="1578cff1ef678cbff3e2e9a754c6d7ba369e455885127e8d15c8b61f22a87740";
const reviewed="27ca1f824329fd8d39f2de829baf7b602fefccf53ec514185bf9e9b56e407ff6";
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed source hash changed");}
function rejects(action:()=>void):void{let failed=false;try{action();}catch{failed=true;}if(!failed)throw Error("Traversal mutation escaped validator");}
function selected(source:string):string{const marker="const partialSource = `";const at=source.indexOf(marker);if(at<0||source.indexOf(marker,at+1)>=0)throw Error("Missing/ambiguous partial shader");const end=source.indexOf("`",at+marker.length);if(end<0)throw Error("Unclosed partial shader");const loops=[...source.slice(at+marker.length,end).matchAll(/for \(uint i = [^\r\n]*\) \{/g)];if(loops.length!==1)throw Error("Missing/ambiguous loop header");return loops[0]![0];}
function bind(source:string,lean:string):void{const literals=[...lean.matchAll(/^def sourceHeader : String := "([^"\r\n]*)"$/gm)];if(literals.length!==1||selected(source)!==literals[0]![1])throw Error("Parsed traversal header differs");}
export async function checkArgmaxTraversalSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 await checkNormalizedScoreSourceBinding(options);
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/sampling/normalized-argmax.ts",root)).text();checkedHash(source,sourceHash);
 const lean=await Bun.file(new URL("ArgmaxTraversalSource.lean",here)).text();checkedHash(lean,reviewed);bind(source,lean);
 if(options.selfTest){rejects(()=>checkedHash(source+" ",sourceHash));rejects(()=>checkedHash(lean+" ",reviewed));
 for(const[from,to]of [["tile * 1024 + tid","tile * 1024"],["i < min","i <= min"],["uint(V)","uint(P)"],["(tile + 1) * 1024","(tile + 2) * 1024"],["i += 128","i += 64"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
 rejects(()=>bind(source,lean.replace("i += 128","i += 64")));}
}
if(import.meta.main){await checkArgmaxTraversalSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Parsed argmax traversal source binding passed");}
