// The perplexity runner's flags and input checks (no model, no MLX: a bad input
// must fail before the library is imported, so these run with no native library).
// Opt in to a real-weight smoke with MLX_BUN_TEST_PERPLEXITY_MODEL=/abs/snapshot
// (a small, already-downloaded model; MLX resolves as the library does).
import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { parseOptions } from "./perplexity";

const SCRIPT = join(import.meta.dir, "perplexity.ts");
function run(...args: string[]) {
  const child = Bun.spawnSync([process.execPath, SCRIPT, ...args], { env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" } });
  return { code: child.exitCode, out: child.stdout.toString() + child.stderr.toString() };
}

test("main's defaults; the model is positional or --model", () => {
  expect(parseOptions(["/m", "--data-path", "/d.txt"]))
    .toEqual({ model: "/m", dataPath: "/d.txt", sequenceLength: 512, numSamples: 256, batchSize: 8, seed: 123, json: false });
  expect(parseOptions(["--model", "/m", "--data-path", "/d.jsonl", "--json"])).toMatchObject({ model: "/m", json: true });
});

test("-1 means every row for --num-samples only, in either spelling", () => {
  const base = ["/m", "--data-path", "/d.txt"];
  expect(parseOptions([...base, "--num-samples", "-1", "--sequence-length", "128", "--batch-size", "3", "--seed", "0"]))
    .toMatchObject({ numSamples: -1, sequenceLength: 128, batchSize: 3, seed: 0 });
  expect(parseOptions([...base, "--num-samples=-1"]).numSamples).toBe(-1);
  expect(() => parseOptions([...base, "--batch-size", "-1"])).toThrow('--batch-size expects an integer >= 1 (got "-1")');
  expect(() => parseOptions([...base, "--sequence-length", "1"])).toThrow("--sequence-length expects an integer >= 2");
  expect(() => parseOptions([...base, "--num-samples", "0"])).toThrow("--num-samples expects an integer >= 1");
  expect(() => parseOptions([...base, "--seed", "1.5"])).toThrow("--seed expects an integer >= 0");
  expect(() => parseOptions([...base, "--stride", "4"])).toThrow();
});

test("usage without a model or data; --help documents the flags", () => {
  expect(() => parseOptions(["/m"])).toThrow("usage: bun scripts/perplexity.ts");
  expect(() => parseOptions(["--data-path", "/d.txt"])).toThrow("usage: bun scripts/perplexity.ts");
  const help = run("--help");
  expect(help.code).toBe(0);
  for (const flag of ["--data-path", "--sequence-length", "--num-samples", "--batch-size", "--seed", "--json"]) expect(help.out).toContain(flag);
});

test("a missing data file or model directory exits 1 before MLX loads", () => {
  const dir = mkdtempSync(join(tmpdir(), "ppl-args-"));
  try {
    const data = join(dir, "d.txt");
    writeFileSync(data, "text");
    const noData = run(dir, "--data-path", join(dir, "absent.jsonl"));
    expect(noData).toMatchObject({ code: 1 });
    expect(noData.out).toContain("data file not found");
    const noModel = run(dir, "--data-path", data);
    expect(noModel).toMatchObject({ code: 1 });
    expect(noModel.out).toContain("model directory not found");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

const modelDir = process.env.MLX_BUN_TEST_PERPLEXITY_MODEL;
test.skipIf(!modelDir)("real weights: a finite ppl over a small jsonl, every position of rows[:, 1:] counted", () => {
  const dir = mkdtempSync(join(tmpdir(), "ppl-smoke-"));
  try {
    const data = join(dir, "ppl.jsonl"), lines = [
      "The quick brown fox jumps over the lazy dog while the farmer watches from the porch of the old house near the river bend in early autumn light.",
      "Apple silicon machines share one memory pool between the CPU and the GPU, which changes how inference engines think about weights, caches, and transient buffers.",
      "A perplexity measurement packs tokenized samples into fixed-length rows and scores every next-token prediction of the model under a causal mask in one forward pass.",
      "She sells sea shells by the sea shore, and the shells she sells are surely sea shells, so if she sells shells on the seashore, the shells are seashore shells.",
      "Local models remember nothing between sessions unless you give them a durable memory, which is why a personal wiki the assistant can read changes what it can do.",
    ];
    writeFileSync(data, lines.map(text => JSON.stringify({ text })).join("\n") + "\n");
    const child = Bun.spawnSync([process.execPath, SCRIPT, modelDir!, "--data-path", data, "--sequence-length", "32", "--num-samples", "4",
      "--batch-size", "2", "--json"], { env: { ...process.env, HF_HUB_OFFLINE: "1" } });
    expect(child.exitCode).toBe(0);
    const record = JSON.parse(child.stdout.toString());
    expect(record).toMatchObject({ data: { samples: 5 }, options: { sequenceLength: 32, numSamples: 4, batchSize: 2, seed: 123 } });
    const r = record.result;
    expect(r.rows).toBe(4);
    expect(r.tokens).toBe(r.rows * 31);
    expect(r.ppl).toBe(Math.exp(r.meanLoss));
    expect(r.ppl).toBeGreaterThan(1);
    expect(r.ppl).toBeLessThan(1e4);
    expect(r.standardError).toBeGreaterThan(0);
  } finally { rmSync(dir, { recursive: true, force: true }); }
}, 300_000);
