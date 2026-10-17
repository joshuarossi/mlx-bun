import {checkAffineInput3SourceBinding} from "./AffineInput3SourceBinding";
import {checkAffineDot3FunctionSourceBinding} from "./AffineDot3FunctionSourceBinding";
import {checkAffineOuter4LifecycleSourceBinding} from "./AffineOuter4LifecycleSourceBinding";
const here=new URL("./",import.meta.url);
const reviewed:Record<string,string>={
  "AffineDot3PreloadFrame.lean": "60d01d55cc8c20b565382fb5674be16c07ffe305702a4d80793c4d1d4ecb68b2",
  "AffineOutput3Source.lean": "db42e3454316081b4b94a026127b01cdd7ec96c66b7b06f3b7ca67a5558b48f3",
  "AffineOuter3Call.lean": "d22db4cfd4b2f5662bf9500e86e844a3457452f9ef128b8886f601132a3939aa",
  "AffineOuter3Source.lean": "dd7f02cc36d84e271d5d7a9217b256d8d4e2ed09740ee584e2390799a6b3da15",
  "AffineOuter3Lifecycle.lean": "9dfef10d799c7e54419ea3a4b501fbe1f9c6690d5eab603a92cdacc105d1a23f"
};
const hash=(text:string)=>new Bun.CryptoHasher("sha256").update(text).digest("hex");
function checked(text:string,expected:string):void{if(hash(text)!==expected)throw Error("Reviewed three-bit lifecycle proof changed");}
export async function checkAffineOuter3SourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 await checkAffineInput3SourceBinding(options);await checkAffineDot3FunctionSourceBinding(options);await checkAffineOuter4LifecycleSourceBinding(options);
 for(const[path,expected]of Object.entries(reviewed)){
  const lean=await Bun.file(new URL(path,here)).text();checked(lean,expected);
  if(options.selfTest){let rejected=false;try{checked(lean+" ",expected);}catch{rejected=true;}if(!rejected)throw Error("Three-bit lifecycle mutation escaped validator");}
 }
}
if(import.meta.main){await checkAffineOuter3SourceBinding({selfTest:process.argv.includes("--self-test")});console.log("Three-bit lifecycle source binding passed");}
