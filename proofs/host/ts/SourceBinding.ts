// Binds each embedded Lean source literal to its repository file. Lean lexes
// and parses the literal itself (kernel-checked); this check is only byte
// equality with the file, its sha256 pin, and the exact generated module.
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { embedded, literalOf, modulePath, render } from "./sources.ts";

/** Executed files of the decode route; changing a pin requires reviewing its uses. */
export const pins: Record<string, string> = {
  "packages/inference/src/artifacts/config.ts": "696f575a1c8882086207c40137d91fbf7ed77e157dbac75cda74dbd0421bc97f",
  "packages/inference/src/artifacts/safetensors.ts": "78c27fb29817a58007f67dab130e9b7f903c7d4a6bc6094bd877e48ecd440f7f",
  "packages/inference/src/artifacts/weights.ts": "dbab9baf25188d34347c0cbaafd5a7c35c68b1ecbaf1ba1e0ee9c1f959a567d5",
  "packages/inference/src/generation/autoregressive.ts": "d2a0b3980e26da231528aa04b1ceb1a904ef738e24bc4c4636cf206383c7a89c",
  "packages/inference/src/generation/phase-dispatch.ts": "b17182d02c7d3fedb9335263b164907c99bb1898c176324b30076425432708de",
  "packages/inference/src/generation/result.ts": "932c6da3a24d27ede91446e66f42a42e44413b29af78484c3173b4d07df4e99f",
  "packages/inference/src/kernels/delta/gated.ts": "3f0e11f777f57b6595d57d62ec3f8b8331cbfa7263183e1baa98892efe935aec",
  "packages/inference/src/kernels/delta/silu-rms-heads.ts": "52c59772bf95e2cd8f7f813a69a7dfac0c352dadc3c2a1e0e550c054dd301145",
  "packages/inference/src/kernels/gated-rms-norm.ts": "e402118d33622ef62a017e964c257e23456d03f96b0fdc855b48704ff0fb954f",
  "packages/inference/src/kernels/quantization/affine-row.ts": "cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b",
  "packages/inference/src/kernels/residual-rms-norm.ts": "27353e109e7f91bc030fbd493785fcc4839eeccea2d585c22d610ba8f9e909d0",
  "packages/inference/src/kernels/sampling/normalized-argmax.ts": "1578cff1ef678cbff3e2e9a754c6d7ba369e455885127e8d15c8b61f22a87740",
  "packages/inference/src/kernels/trellis/codebook.ts": "0ba8624952767d077cdecc531fd9f49a159545b95ae4fc4ddd213ed13fa1e276",
  "packages/inference/src/kernels/trellis/down-codebook.ts": "5649124f12f6828241d88bb86f9e9f6bf965af2b3b5a298ddd8a2973277eec55",
  "packages/inference/src/kernels/trellis/gate-up-codebook.ts": "c0aec9b9f951c5fd94270a52f4bf4da43e7fb7d0ecda6ccd65e20571e8931f45",
  "packages/inference/src/kernels/trellis/launch.ts": "da0a19922ccc93935c5cab869de040d4b759271df08496c88c7371c386724052",
  "packages/inference/src/layers/affine-verify-linear.ts": "ee519b24ad34a0322dee6f35d9a0ed9e3c37a367b78a6b09bd4d0353c81a3870",
  "packages/inference/src/layers/compiled-normalization.ts": "4a649678daf44c73e8528b519a57bace1a735178e29710711a5067c5e5e7d9cc",
  "packages/inference/src/layers/delta-heads.ts": "3d44375dd8bf8be8ea6ebf9772a4c3f1321fa22f567e9e9c7e7da11301a87a6d",
  "packages/inference/src/layers/helpers.ts": "63bdb85f6eae6a6ea52f65f3445bb0a77ce2ec90c7ffb0c86907a3444d202371",
  "packages/inference/src/layers/lora.ts": "6f822c55eddc932368409944b926f7f4a90b546127bb07d5abd536da60b01fbc",
  "packages/inference/src/layers/normalization.ts": "3da742f8b9321aea3e05699361bb82a425b9c548f1a63340e2ca96fc7b8108c8",
  "packages/inference/src/layers/quantized-embedding.ts": "cdead9d17af0a47f7f178ee4bd6b2710364a485dd7001e4ca98c62dec991fe4c",
  "packages/inference/src/layers/quantized-linear.ts": "bf1c24c17d04951c5ea296bcd2bf34f818ffd7aefc684793e7792a8e5c25e798",
  "packages/inference/src/layers/swiglu.ts": "bfc43fd5e4adbe5a97123f5eaf31efc1b3e4d27e34d692ed6804ea5925e2e00a",
  "packages/inference/src/layers/trellis-codebook-down.ts": "48752c429a3ab558131f95c6d361b15b6795c3bb6ee161f8afdca71609437898",
  "packages/inference/src/layers/trellis-codebook-gate-up.ts": "28d27e84cb669c18a4532723e8dbc66786e386a4390454121640a3e14e5526f5",
  "packages/inference/src/layers/trellis-linear.ts": "381239d621385cd6c015d871323c4941826a7a5d1592a5edf77782acac1b89a6",
  "packages/inference/src/layers/trellis-prompt.ts": "58154be1967060324045caff47c1e603313850f1e8dc74ca82f41daa4515834c",
  "packages/inference/src/models/qwen/blocks.ts": "2fa644511dbafc027cf4f191be69e932abda7d8c6a92ebe45f7d76332324645f",
  "packages/inference/src/models/qwen/checkpoint.ts": "1ec846424a2d4e5a046bcb62b43a5e6b8e1f3d9c2b4b3f5f3d7180276362edd8",
  "packages/inference/src/models/qwen/qwen38-27b-trellis-m1max.ts": "915f129881b5ce85f97b6bca5c98afe06dedc21be514a81137a75e058cac882b",
  "packages/inference/src/models/qwen/written-layers.ts": "ebf7710ffdf202d3e25ec7721930e5d992df31fb3d7fa5bde9709aa7a608c2c9",
  "packages/inference/src/runtime/config.ts": "af77a8aa9816126a9d9d8bcad4089e2aafcc802c3d80cb063529fd3a049adab2",
  "packages/inference/src/runtime/graph-forward.ts": "cf774ab1a76d63bcc308ab91a61ff317d7fa75f051d3e246d8394976f9b4fdef",
  "packages/inference/src/runtime/row-operations.ts": "663617a8509b6b2b0dd4d41fcfdbaa6e303bc1f9c66338bc457855d6d44d9e11",
  "packages/inference/src/sampling/extras.ts": "4389ca6265f0e9e18748436e1e384dd82e52002f4a0afa0844dddb87a48f8408",
  "packages/inference/src/sampling/step.ts": "3f83101131b569127fd9b9923cbeebead676c3e175afbbaa97bc66b10023e925",
  "packages/inference/src/state/attention-read.ts": "8081b76f6bd7676825511476c2275601c0c34cb5b68ef30637c7a1c8f9f1c50c",
  "packages/inference/src/state/kv.ts": "526a42d976c7dd0a8e908dcf8b515b94d43269042dc3fc3023e1a5baf0d8a579",
  "packages/inference/src/state/ssm.ts": "96b6f33dac6da5f75cfba8ab760b4dcdce92c73b88d4927b8afa1b413896a7d1",
  "packages/mlx/src/array.ts": "9602f6e19ef3b0639791f68a86287c093e64891ad1c57e7184665e6f46de08ac",
  "packages/mlx/src/compile.ts": "90b19a80123e3e8ff274b5e7fdad4e03bfe757d7fcf0d64d88d5dd7c054cc280",
  "packages/mlx/src/ffi.ts": "c9b3ba73cb7a52f264bd0ffc5dc4523d1633f8eb3c0a8c970398ae03e83b1f8c",
  "packages/mlx/src/materialize.ts": "30a4811b8fd57b10e30779e864051328a012db7df3af38b32acad1108fb9db01",
  "packages/mlx/src/metal-kernel.ts": "b1b054745a88735fdb80f14195d11d35ea366513ee78197a512c7784726a5af1",
  "packages/mlx/src/ops.ts": "0672d9fa77e95490cad3201eb7a9eae073aa41a7c1aa0afaf3e1a640e32dc2cd",
};

/** Pinned files embedded as slices (`sliceOf`): the declarations a run executes. */
export const slices: Record<string, string[]> = {
  "packages/inference/src/artifacts/config.ts": ["parseQuantization", "quantFor"],
};

function hash(text: string): string { return new Bun.CryptoHasher("sha256").update(text).digest("hex"); }

function verify(texts: Record<string, string>, modules: Record<string, string>): void {
  for (const [file, expected] of Object.entries(pins)) {
    const text = texts[file]!;
    if (hash(text) !== expected) throw Error(`Host source changed: ${file}; review its Lean uses before updating the pin`);
    const lean = modules[file]!;
    if (literalOf(lean) !== embedded(file, text)) throw Error(`Lean literal differs from ${file}`);
    if (lean !== render(file, embedded(file, text))) throw Error(`Generated module changed: ${modulePath(file)}`);
  }
}

export interface HostTsBindingOptions { repositoryRoot?: string; selfTest?: boolean }

export async function checkHostTsSourceBinding(options: HostTsBindingOptions = {}): Promise<void> {
  const proofs = new URL("../../", import.meta.url);
  const root = options.repositoryRoot ? pathToFileURL(resolve(options.repositoryRoot) + "/") : new URL("../", proofs);
  const texts: Record<string, string> = {};
  const modules: Record<string, string> = {};
  for (const file of Object.keys(pins)) {
    texts[file] = await Bun.file(new URL(file, root)).text();
    modules[file] = await Bun.file(new URL(modulePath(file), proofs)).text();
  }
  verify(texts, modules);
  if (options.selfTest) {
    const escaped = (f: () => void) => { try { f(); return true; } catch { return false; } };
    for (const file of Object.keys(pins)) {
      if (escaped(() => verify({ ...texts, [file]: texts[file] + " " }, modules))) throw Error(`Source mutation escaped: ${file}`);
      const lean = modules[file]!.replace('r#"', 'r#" ');
      if (lean === modules[file] || escaped(() => verify(texts, { ...modules, [file]: lean }))) throw Error(`Literal mutation escaped: ${file}`);
    }
    const first = Object.keys(pins)[0]!;
    const theorem = modules[first]!.replace("theorem parses :", "theorem parses' :");
    if (escaped(() => verify(texts, { ...modules, [first]: theorem }))) throw Error("Module mutation escaped");
  }
}

if (import.meta.main) {
  const i = process.argv.indexOf("--repository-root");
  await checkHostTsSourceBinding({ repositoryRoot: i < 0 ? undefined : process.argv[i + 1], selfTest: process.argv.includes("--self-test") });
  console.log(`Host TypeScript source binding passed: ${Object.keys(pins).length} files`);
}
