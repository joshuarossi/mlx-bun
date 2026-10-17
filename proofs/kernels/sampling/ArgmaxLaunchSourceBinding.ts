// Exact launch-phase extraction for the selected BF16/B1 sampler. Restricted
// parsing and byte semantics do not establish compiler/hardware correspondence.
import {checkArgmaxTraversalSourceBinding} from "./ArgmaxTraversalSourceBinding";
import {checkArgmaxScratchSourceBinding} from "./ArgmaxScratchSourceBinding";
import {checkArgmaxFinalStoreSourceBinding} from "./ArgmaxFinalStoreSourceBinding";
import {resolve} from "node:path";
import {pathToFileURL} from "node:url";
const here=new URL("./",import.meta.url);
const sourceHash="1578cff1ef678cbff3e2e9a754c6d7ba369e455885127e8d15c8b61f22a87740";
const reviewed:Record<string,string>={
  "ArgmaxLaunchSourceSyntax.lean": "3f1420c261ebe0c9afcc1717009e71988658944908b7c9accc8758345583ff60",
  "ArgmaxLaunchSourceMemory.lean": "d1c439a731efed2d8c0c32d2702d511eaf9fa9b59f28839f68c8442911389089"
};
const hash=(s:string)=>new Bun.CryptoHasher("sha256").update(s).digest("hex");
function checkedHash(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed source hash changed");}
function rejects(action:()=>void):void{let failed=false;try{action();}catch{failed=true;}if(!failed)throw Error("Launch mutation escaped validator");}
function template(source:string,name:string):string{const marker="const "+name+" = `";const at=source.indexOf(marker);if(at<0||source.indexOf(marker,at+1)>=0)throw Error("Missing/ambiguous template");const end=source.indexOf("`",at+marker.length);if(end<0)throw Error("Unclosed template");return source.slice(at+marker.length,end);}
function unique(source:string,pattern:RegExp):string{const matches=[...source.matchAll(pattern)];if(matches.length!==1)throw Error("Missing/ambiguous source phase");return matches[0]![0];}
function selected(source:string):Record<string,string>{
 const partial=template(source,"partialSource"),finish=template(source,"finishSource"),reduction=template(source,"reduction");
 const initializer=/float best = [^;]*;\n  uint bestId = [^;]*;/g;
 const firstInit=unique(partial,initializer),lastInit=unique(finish,initializer);if(firstInit!==lastInit)throw Error("Launch initializers differ");
 return {initSource:firstInit,
 partialUpdateSource:unique(partial,/if \(better\(value, [^,\r\n]*, best, bestId\)\) \{[^}\r\n]*\}/g),
 finishUpdateSource:unique(finish,/if \(better\(value, [^,\r\n]*, best, bestId\)\) \{[^}\r\n]*\}/g),
 partialStoreSource:unique(partial,/if \(lane == [^)]*\) \{ values\[[^}\r\n]*\}/g),
 finishLoopSource:unique(finish,/for \(uint i = [^\r\n]*\) \{/g),
 finishReadSource:unique(finish,/float value = [^;\r\n]*;\n    uint id = [^;\r\n]*;/g),
 mergeReadSource:unique(reduction,/if \(simd == [^)]*\) \{\n    best = [^;\r\n]*;\n    bestId = [^;\r\n]*;/g)};
}
function bind(source:string,lean:string):void{const actual=selected(source);for(const[name,body]of Object.entries(actual)){const matches=[...lean.matchAll(new RegExp('^def '+name+' : String := ("(?:[^"\\\\]|\\\\.)*")$','gm'))];if(matches.length!==1||JSON.parse(matches[0]![1]!)!==body)throw Error("Parsed launch literal differs: "+name);}}
export async function checkArgmaxLaunchSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 await checkArgmaxTraversalSourceBinding(options);await checkArgmaxScratchSourceBinding(options);await checkArgmaxFinalStoreSourceBinding(options);
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/sampling/normalized-argmax.ts",root)).text();checkedHash(source,sourceHash);
 const lean=await Bun.file(new URL("ArgmaxLaunchSourceSyntax.lean",here)).text();for(const[path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);bind(source,lean);
 if(options.selfTest){rejects(()=>checkedHash(source+" ",sourceHash));for(const[path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
 for(const[from,to]of [["uint bestId = 0xffffffffu","uint bestId = 0xfffffffeu"],["bestId = i;","bestId = id;"],["values[row * P + tile]","values[row * P]"],["i < P; i += 128","i < P; i += 64"],["uint id = indices[row * P + i]","float id = indices[row * P + i]"],["best = lane < 4 ? scores[lane]","best = lane < 3 ? scores[lane]"],["bestId = lane < 4 ? ids[lane]","bestId = lane < 4 ? ids[0]"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,lean));}
 rejects(()=>bind(source,lean.replace("bestId = i;","bestId = id;")));}
}
if(import.meta.main){await checkArgmaxLaunchSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Parsed argmax launch source binding passed");}
