import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

// The train, train-watch, fuse and draft verbs are the train module's (`packages/module-train`); this file drives them through
// the app's verb table in a spawned CLI, with native MLX blocked.
const preference = (i: number) => JSON.stringify({ prompt: `p${i}`, chosen: "c", rejected: "r" }) + "\n";

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
async function cli(home: string, ...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, ...args], {
    env: { ...process.env, HOME: home, MLX_BUN_HOME: join(home, ".mlx-bun"), HF_HUB_CACHE: join(home, "absent"), HF_HUB_OFFLINE: "1", NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" },
    stdout: "pipe", stderr: "pipe",
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("the spawned CLI prints help, usage errors, refusals, and a dry-run plan with native MLX blocked", async () => {
  const home = mkdtempSync(join(tmpdir(), "mlx-train-cli-spawn-"));
  const snapshot = join(home, "snap"), data = join(home, "data"), adapter = join(home, "adapter");
  try {
    mkdirSync(snapshot); mkdirSync(data); mkdirSync(adapter);
    writeFileSync(join(snapshot, "config.json"), JSON.stringify({ model_type: "qwen3", hidden_size: 8, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 2,
    intermediate_size: 16, vocab_size: 32, max_position_embeddings: 64 }));
    writeFileSync(join(snapshot, "model.safetensors"), new Uint8Array(4096));
    writeFileSync(join(data, "train.jsonl"), preference(0) + preference(1));
    writeFileSync(join(data, "valid.jsonl"), preference(2));
    for (const command of ["train", "train-watch", "fuse", "draft"]) {
      const shown = await cli(home, command, "--help");
      expect(shown.code).toBe(0); expect(shown.out).toContain(`Usage: mlx-bun ${command}`);
    }
    expect((await cli(home, "train", "--help")).out).toContain("--sft-scope");
    expect((await cli(home, "fuse", "--help")).out).toContain("--adapter-path");
    // draft's help keeps its subcommand paragraph between the usage line and the options.
    const draftHelp = (await cli(home, "help", "draft")).out;
    expect(draftHelp).toContain("Usage: mlx-bun draft <action> [model] [options]\n\nProduce the drafters `mlx-bun serve --draft-model` mounts.");
    expect(draftHelp.indexOf("quantize <drafter-dir>")).toBeLessThan(draftHelp.indexOf("Options:"));
    const failures: [string[], string][] = [
      [["train"], "usage: mlx-bun train <model> --data <dir>   (see: mlx-bun help train)"],
      [["train", "--data", "/nope"], "no train.jsonl in /nope"],
      [["train", snapshot, "--data", data, "--method", "ppo"], '--method must be sft | dpo | orpo (got "ppo")'],
      [["train", snapshot, "--data", data, "--iters", "ten"], '--iters expects a number (got "ten")'],
      [["train", "--data", data, "--serial"], "Unknown option"],
      [["fuse"], "usage: mlx-bun fuse <model-query-or-path> --adapter <dir> [--save-path <dir>]"],
      [["draft"], "usage: mlx-bun draft <regen|train|calibrate|quantize> <model|drafter-dir> [options]"],
      [["draft", "fly", "m"], "usage: mlx-bun draft <regen|train|calibrate|quantize> <model> [options]   (see: mlx-bun help draft)"],
      [["draft", "regen", "m"], "draft regen: --topics is required"],
      [["draft", "regen", "m", "extra", "--topics", "t"], "Too many arguments for draft"],
      [["fuse", "m", "--export-gguf"], "--export-gguf: not supported (GGUF export is not implemented; fuse writes safetensors; see: mlx-bun help fuse)"],
      [["fuse", "m", "--de-quantize"], "Unknown option '--de-quantize'"],
      [["fuse", "m", "--adapter", "/nope"], "adapter dir not found: /nope"],
      [["fuse", "m", "--adapter", adapter], 'no model matching "m"'],
      [["train-watch", "/nope"], "no metrics.jsonl in /nope"],
      [["train-watch", "a", "b"], "Too many arguments for train-watch"],
    ];
    for (const [args, message] of failures) {
      const failed = await cli(home, ...args);
      expect(failed.code).toBe(1); expect(failed.err).toContain(message);
    }
    const dry = await cli(home, "train", snapshot, "--data", data, "--dry-run", "--method", "dpo", "--adapter", "/out");
    expect(dry.code).toBe(0); expect(dry.err).toBe("");
    expect(dry.out).toContain("╭"); expect(dry.out).toContain("╰"); // the host's box around the plan
    for (const line of ["● train dpo · snap", "data       2 train · 1 valid · format preference", "lr 0.00005 · rank 8 · scale 1 · seq 4096",
      "stack      segmented off", "adapter    /out", "watch live (other tab): mlx-bun train-watch /out", "dry run — not training."])
      expect(dry.out).toContain(line);
    // Policy passes for a snapshot path; the merge then needs the native library, which is blocked.
    const fused = await cli(home, "fuse", snapshot, "--adapter", adapter, "--save-path", join(home, "fused"));
    expect(fused.code).toBe(1); expect(fused.out).toContain("fuse failed:"); expect(existsSync(join(home, "fused"))).toBe(false);
  } finally { rmSync(home, { recursive: true, force: true }); }
});
