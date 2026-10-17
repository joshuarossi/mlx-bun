import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const revision = "1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const sourceHash = "b2e04e377fdad1d645581f9beeaf9cbb06d1ad32926161e06cbc15240caf12bf";
const hash = (source: string) => createHash("sha256").update(source).digest("hex");

// Trusted host extraction binds both output assignment literals to the pinned
// upstream file. It does not prove dispatch, surrounding loops, or compilation.
export function extractOutput(source: string): string[] {
  const start = source.indexOf("[[kernel]] void rms_looped(");
  const end = source.indexOf("template <typename T", start + 1);
  if (start < 0 || end < 0) throw new Error("MLX rms_looped boundaries missing");
  const body = source.slice(start, end);
  const statements = [...body.matchAll(/out\[r \+ i\] = [\s\S]*?;/g)].map(match => match[0]);
  if (statements.length !== 2) throw new Error("Expected both rms_looped output assignments");
  return statements;
}

export function checkExtracted(source: string, lean: string): void {
  const statements = extractOutput(source);
  for (const [index, name] of ["sourceBody", "sourceTailBody"].entries()) {
    const literal = lean.match(new RegExp(`def ${name} : String := r#"([\\s\\S]*?)"#`))?.[1];
    if (literal === undefined || statements[index] !== literal) {
      throw new Error(`MLX RMS parsed output literal mismatch: ${name}`);
    }
  }
}

export function checkPointers(source: string, lean: string): void {
  const start = source.indexOf("[[kernel]] void rms_looped(");
  const end = source.indexOf("template <typename T", start + 1);
  if (start < 0 || end < 0) throw new Error("MLX rms_looped boundaries missing");
  const statements = [...source.slice(start, end).matchAll(/\b(?:x|w|out) \+= [^;]*;/g)].map(match => match[0]);
  if (statements.length !== 3) throw new Error("Expected three rms_looped pointer updates");
  for (const [index, name] of ["sourceX", "sourceW", "sourceOut"].entries()) {
    const literal = lean.match(new RegExp(`def ${name} : String := "([^"\\n]*)"`))?.[1];
    if (literal === undefined || statements[index] !== literal) {
      throw new Error(`MLX RMS parsed pointer literal mismatch: ${name}`);
    }
  }
}

export function checkSource(source: string, lean: string, pointers: string): void {
  if (hash(source) !== sourceHash) throw new Error("MLX RMS source SHA256 mismatch");
  checkExtracted(source, lean);
  checkPointers(source, pointers);
}

function rejected(check: () => void): void {
  let failed = false;
  try { check(); } catch { failed = true; }
  if (!failed) throw new Error("MLX RMS source guard mutation accepted");
}

export async function checkMlxRmsOutputSourceBinding(options: { proofsRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  const root = options.proofsRoot ?? resolve(fileURLToPath(new URL("../../", import.meta.url)));
  const source = await Bun.file(resolve(root, `.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/rms_norm.metal`)).text();
  const lean = await Bun.file(resolve(root, "kernels/normalization/MlxRmsOutputSyntax.lean")).text();
  const pointers = await Bun.file(resolve(root, "kernels/normalization/MlxRmsPointerSource.lean")).text();
  checkSource(source, lean, pointers);
  if (options.selfTest) {
    const start = source.indexOf("[[kernel]] void rms_looped(");
    const mutate = (from: string, to: string) => source.slice(0, start) + source.slice(start).replace(from, to);
    for (const bad of [
      mutate("w[w_stride * (i + r)]", "w[w_stride * i]"),
      mutate("static_cast<T>(x[r + i] * local_inv_mean[0])", "static_cast<T>(x[r + i]) * local_inv_mean[0]"),
      mutate("out[r + i] =", "out[r] ="),
      mutate("local_inv_mean[0]);", "local_inv_mean[1]);"),
    ]) {
      rejected(() => checkSource(bad, lean, pointers));
      // Exercise the literal binding independently of the whole-file hash.
      rejected(() => checkExtracted(bad, lean));
    }
    for (const bad of [
      mutate("gid * size_t(axis_size)", "gid * axis_size"),
      mutate("w_stride * lid * N_READS", "w_stride * lid"),
      mutate("out += gid", "out += lid"),
    ]) {
      rejected(() => checkSource(bad, lean, pointers));
      rejected(() => checkPointers(bad, pointers));
    }
    rejected(() => checkSource(source + "\n", lean, pointers));
    rejected(() => checkSource(source, lean.replace("w_stride * (i + r)", "w_stride * (i + i)"), pointers));
    rejected(() => checkSource(source, lean.replace("def sourceTailBody", "def removedTailBody"), pointers));
    rejected(() => checkSource(source, lean, pointers.replace("size_t(axis_size)", "uint(axis_size)")));
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await checkMlxRmsOutputSourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("MLX RMS output assignments bound to pinned source (host extraction boundary).");
}
