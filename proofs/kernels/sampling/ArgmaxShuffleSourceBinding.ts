// Exact reviewed source slices for a restricted parser/interpreter. Compiler,
// shuffle hardware, float comparison and scheduling correspondence stay external.
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
const here = new URL("./", import.meta.url);
const sourceHash = "1578cff1ef678cbff3e2e9a754c6d7ba369e455885127e8d15c8b61f22a87740";
const reviewed: Record<string,string> = {
  "ArgmaxShuffleSyntax.lean": "8a28551fc26793e899e754fca3369f825598fd19ff27a6dbe51dd83351562d98",
  "ArgmaxShuffleSemantics.lean": "5f73691e796271daa9ace1531f9119873aef51dfc7c98ceb747fa028acbc79dc"
};
const hash = (text:string) => new Bun.CryptoHasher("sha256").update(text).digest("hex");
function checkedHash(text:string, expected:string):void { if(hash(text)!==expected) throw Error("Reviewed hash changed"); }
function rejects(action:()=>void):void { let rejected=false;try{action();}catch{rejected=true;}if(!rejected)throw Error("Mutation escaped production validation"); }
function template(source:string,name:string):string {
  const marker="const "+name+" = `";
  const start=source.indexOf(marker);
  if(start<0||source.indexOf(marker,start+1)>=0)throw Error("Missing/ambiguous template");
  const end=source.indexOf("`",start+marker.length);
  if(end<0)throw Error("Unterminated template");
  const body=source.slice(start+marker.length,end);
  if(body.includes("${"))throw Error("Unexpected template interpolation");
  return body;
}
function block(source:string,marker:string):string {
  const at=source.indexOf(marker);
  if(at<0||source.indexOf(marker,at+1)>=0)throw Error("Missing/ambiguous selected loop");
  const start=source.indexOf("{",at);
  if(start<0)throw Error("Missing block");
  let depth=0;
  for(let i=start;i<source.length;i++){
    if(source[i]==="{")depth++;
    if(source[i]==="}"&&--depth===0)return source.slice(at,i+1);
  }
  throw Error("Unclosed block");
}
function slices(source:string):Record<string,string>{
 const header=template(source,"header");const reduction=template(source,"reduction");
 const helper=block(header,"inline bool better(float x, uint xi, float y, uint yi)");
 return {betterBody:helper.slice(helper.indexOf("{")),
 simdLoop:block(reduction,"for (uint distance = 16;"),mergeLoop:block(reduction,"for (uint distance = 2;")};
}
function literals(lean:string):Record<string,string>{
 const found:Record<string,string>={};
 for(const name of ["betterBody","simdLoop","mergeLoop"]){const marker="def "+name+" : String := r#\"";const at=lean.indexOf(marker);if(at<0||lean.indexOf(marker,at+1)>=0)throw Error("Missing/ambiguous Lean literal");const end=lean.indexOf('"#',at+marker.length);if(end<0)throw Error("Unterminated Lean literal");found[name]=lean.slice(at+marker.length,end);}
 return found;
}
function bind(source:string,lean:string):void {const actual=slices(source),expected=literals(lean);for(const name of Object.keys(expected))if(actual[name]!==expected[name])throw Error("Parsed source literal differs: "+name);}
export async function checkArgmaxShuffleSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+"/"):new URL("../../../",here);
 const source=await Bun.file(new URL("packages/inference/src/kernels/sampling/normalized-argmax.ts",root)).text();
 checkedHash(source,sourceHash);
 const syntax=await Bun.file(new URL("ArgmaxShuffleSyntax.lean",here)).text();
 for(const [path,expected]of Object.entries(reviewed))checkedHash(await Bun.file(new URL(path,here)).text(),expected);
 bind(source,syntax);
 if(options.selfTest){
  rejects(()=>checkedHash(source+" ",sourceHash));
  for(const [path,expected]of Object.entries(reviewed)){const text=await Bun.file(new URL(path,here)).text();rejects(()=>checkedHash(text+" ",expected));}
  for(const [from,to]of [["xi < yi","xi > yi"],["distance = 16","distance = 8"],["distance >>= 1","distance >>= 2"],["distance < 32","distance < 31"],["best = other; bestId = oi;","bestId = oi; best = other;"],["&& better(other","|| better(other"]]){const changed=source.replace(from!,to!);if(changed===source)throw Error("Mutation did not apply");rejects(()=>bind(changed,syntax));}
  rejects(()=>bind(source,syntax.replace("xi < yi","xi > yi")));
 }
}
if(import.meta.main){await checkArgmaxShuffleSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Parsed argmax shuffle source binding passed");}
