import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
const revision = "1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const nativeHash = "44483286a359afb7f35d8a9c1658ffaec6ff6c01a7ab34ac7bb35cf6438804a6";
const leanHash = "de65a8cbd3ebd9e377e71d6e6dbe68fc08db4518488a935b54045a606c29bc70";
const hash = (s: string) => createHash("sha256").update(s).digest("hex");
// Manual C++ host translation boundary; no descriptor/compiler equivalence.
const fragments = [
  "auto arch_size = d.get_architecture().back();",
  "auto arch_gen = d.get_architecture_gen();",
  "int vector_limit = transpose_ ? get_qmv_batch_limit(K, N, d) : 4;",
  "if (M >= vector_limit)",
  "if ((K == 128 || K == 64) && is_power_of_2(bits) && !global_scale)",
  "if (M >= 2 && use_qmv_wide(mode, d) && !global_scale)",
  "bool fast = N % bn == 0 && K % qmv_fast_k_alignment(bits) == 0;",
  "int results_per_simdgroup = use_narrow_qmv ? 2 : 4;",
  "MTL::Size group_dims(bk, 2, 1);",
  "MTL::Size grid_dims(M, (N + bn - 1) / bn, B);",
  'mode + (fast ? "_qmv_fast_" : "_qmv_")',
  "return get_pack_factor(bits, 32) * (bits == 2 ? 1 : 2) * 32;",
];
export function checkFragments(native: string): void {
  for (const fragment of fragments) if (!native.includes(fragment)) throw Error("MLX qmv host fragment drift");
}
export function checkTranslation(native: string, lean: string): void {
  if (hash(native)!==nativeHash) throw Error("MLX qmv native source drift");
  if (hash(lean)!==leanHash) throw Error("MLX qmv reviewed translation drift");
  checkFragments(native);
}
function rejected(f: () => void): void {
  let failed=false; try { f(); } catch { failed=true; }
  if (!failed) throw Error("MLX qmv mutation accepted");
}
export async function checkMlxQmvHostSourceBinding(options: {proofsRoot?:string;selfTest?:boolean}={}): Promise<void> {
  const root=options.proofsRoot??resolve(fileURLToPath(new URL("../../",import.meta.url)));
  const [native,lean]=await Promise.all([
    Bun.file(resolve(root,`.lake/sources/mlx/${revision}/mlx/backend/metal/quantized.cpp`)).text(),
    Bun.file(resolve(root,"kernels/quantization/MlxQmvHostSource.lean")).text(),
  ]);
  checkTranslation(native,lean);
  if(options.selfTest) {
    for(const fragment of fragments) {
      const bad=native.replaceAll(fragment,fragment.replace(/./,"!"));
      rejected(()=>checkTranslation(bad,lean));
      rejected(()=>checkFragments(bad));
    }
    rejected(()=>checkTranslation(native,lean.replace("n%8==0","n%4==0")));
    rejected(()=>checkTranslation(native,lean.replace("32,2,1","32,16,1")));
    rejected(()=>checkTranslation(native,lean.replace("then 33","then 1")));
  }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href) {
  await checkMlxQmvHostSourceBinding({selfTest:process.argv.includes("--self-test")});
  console.log("MLX qmv reviewed host source binding passed.");
}
