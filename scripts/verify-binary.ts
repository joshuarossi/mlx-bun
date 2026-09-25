import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { mkdir, mkdtemp, rename, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { buildBinary, compileApp } from "./build-binary";
import { NATIVE_DIR as MLX_DIR, resolveLibmlxc } from "../packages/mlx/src/native";
import { NATIVE_DIR as INFERENCE_DIR, resolveInferenceNative } from "../packages/inference/src/runtime/native";

if (process.argv.includes("--help")) {
  console.log("Usage: bun scripts/verify-binary.ts\nBuild, relocate, and exercise the app bundle with temporary storage and no native/GPU execution.");
  process.exit(0);
}
const root = resolve(import.meta.dir, ".."), temporary = await mkdtemp(join(tmpdir(), "mlx-bundle-"));
try {
  const override = process.env.MLX_BUN_LIBMLXC;
  try {
    delete process.env.MLX_BUN_LIBMLXC;
    assert.equal(resolveLibmlxc(), join(MLX_DIR, "libmlxc.dylib"), "source execution uses its package native directory");
    process.env.MLX_BUN_LIBMLXC = "/explicit/override.dylib";
    assert.equal(resolveLibmlxc(), "/explicit/override.dylib");
    assert.equal(resolveInferenceNative("mlx-bun-frame-extract"), join(INFERENCE_DIR, "mlx-bun-frame-extract"));
  } finally {
    if (override === undefined) delete process.env.MLX_BUN_LIBMLXC; else process.env.MLX_BUN_LIBMLXC = override;
  }
  const original = join(temporary, "built"), relocated = join(temporary, "relocated"), scratch = join(temporary, "data");
  await mkdir(scratch);
  await buildBinary(original);
  await compileApp(join(root, "apps/mlx-bun/tests/compiled-consumer.ts"), join(original, "verify-consumer"));
  await rename(original, relocated);
  assert(!existsSync(original), "original bundle must be unavailable after relocation");
  const env = { ...process.env, MLX_BUN_LIBMLXC: "", MLX_BUN_EXPERT_IO_DYLIB: "", MLX_BUN_FRAME_EXTRACT: "" };
  async function run(command: string[]): Promise<string> {
    const child = Bun.spawn(command, { cwd: scratch, env, stdout: "pipe", stderr: "pipe" });
    const [out, err, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
    assert.equal(code, 0, `${command[0]} failed: ${out}\n${err}`);
    return out;
  }
  const executable = join(relocated, "mlx-bun");
  assert((await run([executable, "--version"])).startsWith("mlx-bun "));
  assert((await run([executable, "--help"])).includes("Usage: mlx-bun"));
  console.log(await run([join(relocated, "verify-consumer"), scratch]));
} finally { await rm(temporary, { recursive: true, force: true }); }
