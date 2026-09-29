// The spawned `mlx-bun convert`: help, usage errors, and a real job child that fails cleanly without native MLX.
// The verb itself (`@mlx-bun/module-quantize`) is tested in its package with injected dependencies.
import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");

async function cli(home: string, ...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, ...args], {
    cwd: home, stdout: "pipe", stderr: "pipe",
    env: { ...process.env, HOME: home, MLX_BUN_HOME: join(home, ".mlx-bun"), HF_HUB_CACHE: join(home, "hub"), HF_HUB_OFFLINE: "1", HF_TOKEN: "", NO_COLOR: "1",
      MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" },
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("the spawned CLI renders help, refuses usage errors with main's messages, and fails cleanly without native MLX", async () => {
  const home = mkdtempSync(join(tmpdir(), "mlx-convert-cli-"));
  try {
    const overview = await cli(home, "--help");
    expect(overview.code).toBe(0); expect(overview.out).toMatch(/convert\s+Quantize an HF model/);
    const help = await cli(home, "convert", "--help");
    expect(help.code).toBe(0); expect(help.err).toBe("");
    for (const marker of ["Usage: mlx-bun convert [repo-or-path] [options]", "-q, --quantize", "-d, --dequantize", "--hf-path <value>",
      "--mlx-path <value>", "--target-bpw <value>", "--rotate-weights", "--upload-repo <value>", "--q-mode <value>"]) expect(help.out).toContain(marker);
    expect((await cli(home, "help", "convert")).out).toContain("--target-bpw");
    const local = join(home, "src"); mkdirSync(local); writeFileSync(join(local, "config.json"), JSON.stringify({ model_type: "qwen3" }));
    const taken = join(home, "taken"); mkdirSync(taken);
    const refusals: [string[], string][] = [
      [["convert"], "usage: mlx-bun convert --hf-path <repo-or-path> [-q]"],
      [["convert", "--hf-path", "x", "-q", "--dtype", "int8"], "--dtype must be float16, bfloat16, float32"],
      [["convert", "--hf-path", "x", "-q", "-d"], "Choose either quantize or dequantize, not both."],
      [["convert", "--hf-path", "x", "-q", "--quant-predicate", "mixed_4_6"], "--quant-predicate: not supported"],
      [["convert", "--hf-path", "x", "-q", "--q-mode", "mxfp4"], 'only "affine" and "trellis" are supported'],
      [["convert", "--hf-path", "x", "-q", "--upload-repo"], "--upload-repo expects a repo id (org/name)"],
      [["convert", "--hf-path", "x", "-q", "--q-bits", "3"], "--q-bits must be 4 or 8"],
      [["convert", "--hf-path", "x", "-q", "--q-group-size", "128"], "--q-group-size must be 32 or 64"],
      [["convert", "--hf-path", "x", "-q", "--rotate-weights", "--rotation-seed", "not-an-integer"], "--rotation-seed expects an integer"],
      [["convert", "--hf-path", "x", "-q", "--mlx-path", taken], "already exists"],
      [["convert", local, "-q", "--upload-repo", "org/quant"], "needs a Hugging Face WRITE token"],
      [["convert", "x", "-q", "--serial"], "--serial"],
    ];
    for (const [args, message] of refusals) {
      const result = await cli(home, ...args);
      expect(result.code).toBe(1); expect(result.err).toContain(message);
    }
    expect(existsSync(join(home, ".mlx-bun/db/registry.sqlite"))).toBe(false);
    const missing = await cli(home, "convert", "tiny", "-q");
    expect(missing.code).toBe(1); expect(missing.err).toContain('no model matching "tiny"');
    const failed = await cli(home, "convert", local, "-q");
    expect(failed.code).toBe(1); expect(failed.out).toContain("convert failed"); expect(failed.err).not.toBe("");
    expect(readdirSync(join(home, ".mlx-bun", "models"))).toEqual([]);
    // Nothing lands in the working directory (HOME here) by default: no mlx_lm-style
    // `mlx_model`, no models or staging outside MLX_BUN_HOME. (The OS may add its own
    // entries such as ~/Library, so this names what must not exist.)
    for (const name of ["mlx_model", "src-4bit", "models", "hub"]) expect(existsSync(join(home, name))).toBe(false);
    expect(readdirSync(home).filter(name => name.startsWith(".src-4bit"))).toEqual([]);
  } finally { rmSync(home, { recursive: true, force: true }); }
});
