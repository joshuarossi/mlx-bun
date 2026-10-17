import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const revision = "1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const hostHash = "01bc537389638efe43a9bedeeb2008484864772022ac56e106a3f9911bcaa1aa";
const definesHash = "a2930dbd644c69c4b66a511a094034217f3c03f48e29a1613f601532150f9163";
const leanHash = "54bab69d3fee3fc5d95024b8459983c24bf581c92f859b5be2106e218091ce15";
const hash = (source: string) => createHash("sha256").update(source).digest("hex");

// Pins a reviewed host translation. This does not parse/prove C++, attach a
// native descriptor to a logical buffer, or certify pipeline/device properties.
export function checkTranslation(host: string, defines: string, lean: string): void {
  if (hash(host) !== hostHash) throw new Error("MLX RMS host source drift");
  if (hash(defines) !== definesHash) throw new Error("MLX RMS constant source drift");
  if (hash(lean) !== leanHash) throw new Error("MLX RMS reviewed translation drift");
  for (const [native, logical, value] of [
    ["RMS_N_READS", "reads", 4], ["RMS_LOOPED_LIMIT", "loopedLimit", 4096],
  ] as const) {
    if (!defines.includes(`constexpr int ${native} = ${value};`) ||
        !lean.includes(`def ${logical} : Nat := ${value}`)) throw new Error("MLX RMS constant binding mismatch");
  }
  for (const fragment of [
    "bool no_copy = x.flags().contiguous && x.strides()[x.ndim() - 1] == 1;",
    "no_copy &= (s == 0 || s == x.shape().back() || x.shape(-2) == 1);",
    "if (x.is_donatable())", "out.copy_shared_buffer(x);",
    "allocator::malloc(x.data_size() * x.itemsize())",
    "auto axis_size = static_cast<uint32_t>(x.shape().back());",
    "int n_rows = x.data_size() / axis_size;",
    "if (axis_size > looped_limit)", 'op_name += "_looped";',
    "size_t threadgroup_size = kernel->maxTotalThreadsPerThreadgroup();",
    "size_t n_threads = n_rows * threadgroup_size;",
    "group_dims = MTL::Size(threadgroup_size, 1, 1);",
    "uint32_t w_stride = (w.ndim() == 1) ? w.strides()[0] : 0;",
    "compute_encoder.set_bytes(axis_size, 4);", "compute_encoder.set_bytes(w_stride, 5);",
    "compute_encoder.dispatch_threads(grid_dims, group_dims);",
  ]) if (!host.includes(fragment)) throw new Error("MLX RMS host translation fragment mismatch");
}

function rejected(check: () => void): void {
  let failed = false;
  try { check(); } catch { failed = true; }
  if (!failed) throw new Error("MLX RMS host mutation accepted");
}

export async function checkMlxRmsHostSourceBinding(options: { proofsRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  const root = options.proofsRoot ?? resolve(fileURLToPath(new URL("../../", import.meta.url)));
  const prefix = resolve(root, `.lake/sources/mlx/${revision}/mlx/backend/metal`);
  const [host, defines, lean] = await Promise.all([
    Bun.file(resolve(prefix, "normalization.cpp")).text(),
    Bun.file(resolve(prefix, "kernels/defines.h")).text(),
    Bun.file(resolve(root, "kernels/normalization/MlxRmsHostSelection.lean")).text(),
  ]);
  checkTranslation(host, defines, lean);
  if (options.selfTest) {
    for (const bad of [host.replace("axis_size > looped_limit", "axis_size >= looped_limit"),
      host.replace("w.strides()[0] : 0", "w.strides()[0] : 1"),
      host.replace("n_rows * threadgroup_size", "axis_size * threadgroup_size")]) {
      rejected(() => checkTranslation(bad, defines, lean));
    }
    rejected(() => checkTranslation(host, defines.replace("RMS_N_READS = 4", "RMS_N_READS = 8"), lean));
    rejected(() => checkTranslation(host, defines, lean.replace("def loopedLimit : Nat := 4096", "def loopedLimit : Nat := 8192")));
    rejected(() => checkTranslation(host, defines, lean.replace("kernel.threads else", "1024 else")));
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await checkMlxRmsHostSourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("MLX RMS reviewed host translation binding passed (manual translation boundary).");
}
