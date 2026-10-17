import {checkAffineOuter4SourceBinding} from "./AffineOuter4SourceBinding";
import {checkAffineRowHostSourceBinding} from "./AffineRowHostSourceBinding";
const here=new URL("./",import.meta.url);
const reviewed="2ae33bd8fa01d7e2af24cbe2e43633714eda0e939c1e9919d88706ce83ba308a";
const hash=(text:string)=>new Bun.CryptoHasher("sha256").update(text).digest("hex");
function checked(text:string):void{if(hash(text)!==reviewed)throw Error("Reviewed affine lifecycle proof changed");}
export async function checkAffineOuter4LifecycleSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 await checkAffineOuter4SourceBinding(options);await checkAffineRowHostSourceBinding(options);
 const lean=await Bun.file(new URL("AffineOuter4Lifecycle.lean",here)).text();checked(lean);
 if(options.selfTest){let rejected=false;try{checked(lean+" ");}catch{rejected=true;}if(!rejected)throw Error("Lifecycle mutation escaped validator");}
}
if(import.meta.main){await checkAffineOuter4LifecycleSourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Affine lifecycle source binding passed");}
