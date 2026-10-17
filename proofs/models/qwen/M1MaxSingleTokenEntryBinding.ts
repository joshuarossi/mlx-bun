// Trusted byte/hash guard for the reviewed manual host-route translation.
// This is not a verified TypeScript parser/interpreter or a native-run proof.
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
const hashes: Record<string,string> = {
  "models/factory.ts": "8c9fa7ad26c51197673d20522a5ec1946ffadeb5fcd77df151737bc2b47c9023",
  "models/implementation.ts": "fab08e8ed6431920c41ad28a726607ef1d2cd60a3aae7793e9c79040ffaef499",
  "models/composition.ts": "b455b4498b44a2be4edc0d0c9aa4392574a203a66ce37a8c6b85119dd613dff9",
  "models/cache-composition.ts": "b51b0056cce40215b2a5811058b59ea08855670518253b5e3c8078ee5029bbd8",
  "models/capabilities.ts": "1c8e7c349233af2e865d5516421fc42c2557c87ba84fd11e0b8675d651162be7",
  "models/qwen/qwen38-27b-trellis-m1max.ts": "915f129881b5ce85f97b6bca5c98afe06dedc21be514a81137a75e058cac882b",
  "models/qwen/blocks.ts": "2fa644511dbafc027cf4f191be69e932abda7d8c6a92ebe45f7d76332324645f",
  "state/kv-scheme.ts": "631a92f5a487cac486202a92dbac4fd1aa045242489747b0b9d90e5609c2e416",
  "state/bf16-first-kv.ts": "91eb3dbe8857e5b2348402008f91b625e6135dea9b41c0a48e24d2d9bd018eaf",
  "state/kv.ts": "526a42d976c7dd0a8e908dcf8b515b94d43269042dc3fc3023e1a5baf0d8a579",
  "state/request-policy.ts": "95d6cffc7cd3eedb5db76e69c8defab9c50f3f67c787211ed1098dc8819b9ba4",
  "generation/bindings/autoregressive.ts": "4d39973a00dea72a42659dd839805dc36169bc605c53426e4b3e6f2225a716c1",
  "generation/autoregressive.ts": "d2a0b3980e26da231528aa04b1ceb1a904ef738e24bc4c4636cf206383c7a89c",
  "generation/phase-dispatch.ts": "b17182d02c7d3fedb9335263b164907c99bb1898c176324b30076425432708de",
  "generation/prefill.ts": "e7da71898c2ad711cf9250ece089220fcd9ba23071b5f9d690198b9488f9a2c3",
  "contracts/portable/prefill.ts": "5709777b08e8915cf0f3fbcb3bf8226bf24b3fbe7a646eda4c040d2bb92ede3b"
};
const fragments: Record<string,string> = {
  "selection": "models/factory.ts",
  "kvDefault": "state/kv-scheme.ts",
  "bf16Cache": "state/bf16-first-kv.ts",
  "bindCaches": "models/cache-composition.ts",
  "bindMakeCache": "generation/bindings/autoregressive.ts",
  "newKv": "state/kv.ts",
  "phase": "contracts/portable/prefill.ts",
  "promptDecode": "generation/phase-dispatch.ts",
  "d1": "models/qwen/qwen38-27b-trellis-m1max.ts",
  "one": "models/qwen/qwen38-27b-trellis-m1max.ts",
  "table": "models/qwen/qwen38-27b-trellis-m1max.ts",
  "read": "models/qwen/blocks.ts",
  "direct": "state/kv.ts",
  "uncompiled": "models/qwen/qwen38-27b-trellis-m1max.ts"
};
const translationHash = "44ebffcbd5cfeb5fe0233cc4cec271d03eccc89fee165ad7f7f57da3692a8a74";
function hash(text: string): string { return new Bun.CryptoHasher("sha256").update(text).digest("hex"); }
function verify(texts: Record<string,string>, lean: string): void {
  for(const [path,expected] of Object.entries(hashes)) {
    if(hash(texts[path]!)!==expected) throw Error("Host source changed: "+path+"; review the manual route");
  }
  if(hash(lean)!==translationHash) throw Error("Reviewed Lean translation changed");
  for(const [name,path] of Object.entries(fragments)) {
    const matches=[...lean.matchAll(new RegExp('^def '+name+'Source : String := r#"([\\s\\S]*?)"#','gm'))];
    if(matches.length!==1 || !texts[path]!.includes(matches[0]![1]!)) throw Error("Source fragment binding failed: "+name+"/"+path);
  }
}
export interface EntryBindingOptions { repositoryRoot?: string; leanSource?: string; selfTest?: boolean }
export async function checkM1MaxSingleTokenEntry(options: EntryBindingOptions = {}): Promise<void> {
  const here=new URL("./",import.meta.url);
  const root=options.repositoryRoot ? pathToFileURL(resolve(options.repositoryRoot)+"/") : new URL("../../../",here);
  const texts: Record<string,string>={};
  for(const path of Object.keys(hashes)) texts[path]=await Bun.file(new URL("packages/inference/src/"+path,root)).text();
  const lean=await Bun.file(options.leanSource ? resolve(options.leanSource) : new URL("M1MaxSingleTokenEntry.lean",here)).text();
  verify(texts,lean);
  if(options.selfTest) {
    for(const path of Object.keys(texts)) {
      let rejected=false;try{verify({...texts,[path]:texts[path]+" "},lean);}catch{rejected=true;}
      if(!rejected) throw Error("Source mutation escaped: "+path);
    }
    let rejected=false;try{verify(texts,lean.replace('def compiledDecode : Bool := false','def compiledDecode : Bool := true'));}catch{rejected=true;}
    if(!rejected) throw Error("Manual translation mutation escaped");
  }
}
function option(name: string): string|undefined { const i=process.argv.indexOf(name);if(i<0)return undefined;const v=process.argv[i+1];if(!v||v.startsWith("--"))throw Error("Missing "+name);return v; }
if(import.meta.main) {
  await checkM1MaxSingleTokenEntry({repositoryRoot:option("--repository-root"),leanSource:option("--lean-source"),selfTest:process.argv.includes("--self-test")});
  console.log("M1 Max single-token BF16 entry source binding passed");
}
