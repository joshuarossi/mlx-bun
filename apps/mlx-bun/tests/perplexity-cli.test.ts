// `mlx-bun perplexity`: main's flags, defaults and input checks (no model, no MLX: a bad
// input fails before the library loads). The method is tested in @mlx-bun/inference/scoring.
// Opt in to a real-weight run with MLX_BUN_TEST_PERPLEXITY_MODEL=/abs/snapshot (a small,
// already-downloaded model; MLX resolves as the library does).
import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { parseCommand } from "../src/cli/args";
import { perplexityOptions } from "../src/cli/perplexity";

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
const options = (...args: string[]) => perplexityOptions(parseCommand("perplexity", args));

async function cli(home: string, env: Record<string, string>, ...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, ...args], {
    cwd: home, stdout: "pipe", stderr: "pipe",
    env: { ...process.env, HOME: home, MLX_BUN_HOME: join(home, ".mlx-bun"), HF_HUB_CACHE: join(home, "hub"), HF_HUB_OFFLINE: "1", NO_COLOR: "1", ...env },
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("main's defaults; the model is positional, --model or --query", () => {
  expect(options("/m", "--data-path", "/d.txt"))
    .toEqual({ model: "/m", dataPath: "/d.txt", sequenceLength: 512, numSamples: 256, batchSize: 8, seed: 123 });
  expect(options("--model", "/m", "--data-path", "/d.jsonl").model).toBe("/m");
  expect(options("--query", "qwen", "--data-path", "/d.jsonl").model).toBe("qwen");
});

test("-1 means every row for --num-samples only, in either spelling", () => {
  const base = ["/m", "--data-path", "/d.txt"];
  expect(options(...base, "--num-samples", "-1", "--sequence-length", "128", "--batch-size", "3", "--seed", "0"))
    .toMatchObject({ numSamples: -1, sequenceLength: 128, batchSize: 3, seed: 0 });
  expect(options(...base, "--num-samples=-1").numSamples).toBe(-1);
  expect(() => options(...base, "--batch-size", "-1")).toThrow('--batch-size expects an integer >= 1 (got "-1")');
  expect(() => options(...base, "--sequence-length", "1")).toThrow("--sequence-length expects an integer >= 2");
  expect(() => options(...base, "--num-samples", "0")).toThrow("--num-samples expects an integer >= 1");
  expect(() => options(...base, "--seed", "1.5")).toThrow("--seed expects an integer >= 0");
  expect(() => options(...base, "--stride", "4")).toThrow();
});

test("the spawned verb: help, main's usage line, and a missing data file or model fails before MLX loads", async () => {
  const home = mkdtempSync(join(tmpdir(), "mlx-ppl-cli-"));
  const noMlx = { MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" };
  try {
    const help = await cli(home, noMlx, "perplexity", "--help");
    expect(help.code).toBe(0);
    for (const flag of ["--data-path", "--sequence-length", "--num-samples", "--batch-size", "--seed", "mlx_lm.perplexity"]) expect(help.out).toContain(flag);
    expect((await cli(home, noMlx, "--help")).out).toMatch(/perplexity\s+Perplexity of a model/);
    const usage = await cli(home, noMlx, "perplexity", "/m");
    expect(usage.code).toBe(1); expect(usage.err).toContain("usage: mlx-bun perplexity <model-query-or-path> --data-path");
    const data = join(home, "d.txt"); writeFileSync(data, "text");
    const noData = await cli(home, noMlx, "perplexity", home, "--data-path", join(home, "absent.jsonl"));
    expect(noData.code).toBe(1); expect(noData.err).toContain("data file not found");
    const noModel = await cli(home, noMlx, "perplexity", "no-such-model", "--data-path", data);
    expect(noModel.code).toBe(1); expect(noModel.err).not.toContain("libmlxc");
  } finally { rmSync(home, { recursive: true, force: true }); }
});

const modelDir = process.env.MLX_BUN_TEST_PERPLEXITY_MODEL;
test.skipIf(!modelDir)("real weights: a finite ppl over a small jsonl, every position of rows[:, 1:] counted", async () => {
  const home = mkdtempSync(join(tmpdir(), "mlx-ppl-smoke-"));
  try {
    const data = join(home, "ppl.jsonl"), lines = [
      "The quick brown fox jumps over the lazy dog while the farmer watches from the porch of the old house near the river bend in early autumn light.",
      "Apple silicon machines share one memory pool between the CPU and the GPU, which changes how inference engines think about weights, caches, and transient buffers.",
      "A perplexity measurement packs tokenized samples into fixed-length rows and scores every next-token prediction of the model under a causal mask in one forward pass.",
      "She sells sea shells by the sea shore, and the shells she sells are surely sea shells, so if she sells shells on the seashore, the shells are seashore shells.",
      "Local models remember nothing between sessions unless you give them a durable memory, which is why a personal wiki the assistant can read changes what it can do.",
    ];
    writeFileSync(data, lines.map(text => JSON.stringify({ text })).join("\n") + "\n");
    const run = await cli(home, {}, "perplexity", modelDir!, "--data-path", data, "--sequence-length", "32", "--num-samples", "4", "--batch-size", "2");
    expect(run.code).toBe(0);
    const ppl = Number(/ppl\s+([\d.]+)/.exec(run.out)?.[1]);
    expect(ppl).toBeGreaterThan(1); expect(ppl).toBeLessThan(1e4);
    expect(run.out).toContain("124 · 4 row(s) × 32");
  } finally { rmSync(home, { recursive: true, force: true }); }
}, 300_000);
