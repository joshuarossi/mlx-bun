import {createHash} from "node:crypto";
import {resolve} from "node:path";
import {fileURLToPath,pathToFileURL} from "node:url";
// Constructor/type binding only. Parsed native vector-copy execution is a
// separate descendant; this guard does not claim it for the fresh route.
const pins:Record<string,string>={
 "state/KvSliceCapacityPreparation":"45211f4f8812c264a449e6935467b169d19573181a22e3f75f0ed87b59d63bf4",
 "state/KvSliceCapacityMemory":"163578ff22eeaf72b55f07087f419ce6f5f02dff38985aeb7556d1e674cb6446",
 "state/KvCacheFreshMemory":"5f03ada6069b149bafd7dc26404a1ddf61a655ebaacf35e300112d7967a48e83",
 "models/qwen/AttentionGateCopyFreshRead":"cb49e6a6cacfd33ca7572bae1b19938bbb7213e87f5c2734e7939bf9116b8806"
};
const hash=(s:string)=>createHash("sha256").update(s).digest("hex");
export function checkProofs(sources:Record<string,string>):void{
 for(const[file,pin]of Object.entries(pins))if(hash(sources[file]??"")!==pin)throw Error("Capacity-general KV preservation constructor drift");
}
function rejected(f:()=>void){let failed=false;try{f();}catch{failed=true;}if(!failed)throw Error("Fresh KV constructor mutation accepted");}
export async function checkAttentionGateCopyFreshReadBinding(options:{proofsRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
 const sources=Object.fromEntries(await Promise.all(Object.keys(pins).map(async file=>[file,await Bun.file(resolve(root,file+".lean")).text()])));
 checkProofs(sources);
 if(options.selfTest){
  for(const file of Object.keys(pins))rejected(()=>checkProofs({...sources,[file]:sources[file]+"\n"}));
  for(const[file,a,b]of [
   ["state/KvSliceCapacityPreparation","capacity*256","capacity*128"],
   ["state/KvSliceCapacityPreparation","CopyContiguous.vectorValues before source","CopyContiguous.vectorValues before destination"],
   ["state/KvSliceCapacityMemory","same.trans (slice.oldValues head time i)","slice.oldValues head time i"],
   ["state/KvCacheFreshMemory","(keys allocation keyShared).memory storage.layout.valueBase","storage.memory storage.layout.valueBase"],
   ["state/KvCacheFreshMemory","valueShared : valueSource.bytes=storage.memory","valueShared : valueSource.bytes=otherMemory"],
   ["models/qwen/AttentionGateCopyFreshRead","positive : 0<n","positive : 0≤n"],
   ["models/qwen/AttentionGateCopyFreshRead","cache := read.kv.after","cache := otherCache"],
   ["models/qwen/AttentionGateCopyFreshRead","read.kv.values.preservation.memory","read.kv.keys.memory"]]){
    const bad=sources[file!]!.replace(a!,b!);if(bad===sources[file!])throw Error("Fresh KV mutation anchor missing");
    rejected(()=>checkProofs({...sources,[file!]:bad}));
   }
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){await checkAttentionGateCopyFreshReadBinding({selfTest:process.argv.includes("--self-test")});console.log("Capacity-general fresh/donated KV preservation construction binding passed.");}
