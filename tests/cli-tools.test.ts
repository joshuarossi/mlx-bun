// CLI tool verbs (fuse / convert / perplexity) — arg plumbing + gated smokes.
//
// The arg-parsing tests spawn `bun src/cli.ts …` and only exercise paths that
// exit BEFORE any model/network work (usage errors, unsupported flags,
// existing-output refusal) — they are model-free and never download.
//
// The real smokes load the on-disk MiniCPM5-1B-OptiQ-4bit base, so they are
// GATED behind MLX_BUN_TEST_TOOLS=1 and skipped by default (same isolation
// rule as tests/train-e2e.test.ts — don't load a model inside the fast suite):
//
//   MLX_BUN_TEST_TOOLS=1 bun test tests/cli-tools.test.ts
//
//   - fuse: fold a real MiniCPM5 adapter into the base (CPU stream), assert a
//     loadable snapshot: fused module scales change, untouched tensors are
//     BIT-IDENTICAL passthrough, config quantization block unchanged.
//   - perplexity: 5-sample inline dataset, assert a finite ppl and the exact
//     exp(mean CE) relationship.

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const CLI = join(import.meta.dir, "../src/cli.ts");

/** Run the CLI, capture exit code + combined output. */
async function runCli(args: string[]): Promise<{ code: number; out: string }> {
  const p = Bun.spawn(["bun", CLI, ...args], { stdout: "pipe", stderr: "pipe" });
  const [stdout, stderr, code] = await Promise.all([
    new Response(p.stdout).text(),
    new Response(p.stderr).text(),
    p.exited,
  ]);
  return { code, out: stdout + stderr };
}

// ---------------------------------------------------------------- arg parsing

describe("cli tool verbs — arg plumbing (model-free)", () => {
  test("overview help lists the three verbs", async () => {
    const { code, out } = await runCli(["--help"]);
    expect(code).toBe(0);
    for (const verb of ["fuse", "convert", "perplexity"]) expect(out).toContain(verb);
  });

  test("per-verb help renders", async () => {
    for (const [verb, marker] of [
      ["fuse", "--save-path"],
      ["convert", "--target-bpw"],
      ["perplexity", "--sequence-length"],
    ] as const) {
      const { code, out } = await runCli(["help", verb]);
      expect(code).toBe(0);
      expect(out).toContain(marker);
    }
  });

  test("fuse: usage error without a model", async () => {
    const { code, out } = await runCli(["fuse", "--adapter", "/tmp/nowhere"]);
    expect(code).toBe(1);
    expect(out).toContain("usage: mlx-bun fuse");
  });

  test("fuse: unsupported mlx_lm flags exit 1 loudly", async () => {
    for (const bad of ["--export-gguf", "--de-quantize", "--upload-repo"]) {
      const { code, out } = await runCli(["fuse", "some-model", bad]);
      expect(code).toBe(1);
      expect(out).toContain("not supported");
    }
  });

  test("fuse: missing adapter dir exits 1", async () => {
    const { code, out } = await runCli(["fuse", "some-model", "--adapter", "/tmp/definitely-not-an-adapter"]);
    expect(code).toBe(1);
    expect(out).toContain("adapter dir not found");
  });

  test("convert: --upload-repo says not supported yet", async () => {
    const { code, out } = await runCli(["convert", "--hf-path", "x", "-q", "--upload-repo", "org/x"]);
    expect(code).toBe(1);
    expect(out).toContain("--upload-repo: not supported yet");
  });

  test("convert: --dtype / --dequantize / --quant-predicate refused", async () => {
    for (const args of [["--dtype", "float16"], ["--dequantize"], ["--quant-predicate", "mixed_4_6"]]) {
      const { code, out } = await runCli(["convert", "--hf-path", "x", "-q", ...args]);
      expect(code).toBe(1);
      expect(out).toContain("not supported");
    }
  });

  test("convert: requires -q or --target-bpw", async () => {
    const { code, out } = await runCli(["convert", "--hf-path", "x"]);
    expect(code).toBe(1);
    expect(out).toContain("pass -q or --target-bpw");
  });

  test("convert: refuses an existing --mlx-path (mlx_lm parity)", async () => {
    const tmp = mkdtempSync(join(tmpdir(), "cli-convert-"));
    try {
      const { code, out } = await runCli(["convert", "--hf-path", "x", "-q", "--mlx-path", tmp]);
      expect(code).toBe(1);
      expect(out).toContain("already exists");
    } finally {
      rmSync(tmp, { recursive: true, force: true });
    }
  });

  test("convert: validates --q-bits / --q-group-size", async () => {
    const a = await runCli(["convert", "--hf-path", "x", "-q", "--q-bits", "3"]);
    expect(a.code).toBe(1);
    expect(a.out).toContain("--q-bits must be 4 or 8");
    const b = await runCli(["convert", "--hf-path", "x", "-q", "--q-group-size", "128"]);
    expect(b.code).toBe(1);
    expect(b.out).toContain("--q-group-size must be 32 or 64");
  });

  test("perplexity: usage error without model/data", async () => {
    const { code, out } = await runCli(["perplexity"]);
    expect(code).toBe(1);
    expect(out).toContain("usage: mlx-bun perplexity");
  });

  test("perplexity: missing data file exits 1 without loading anything", async () => {
    const { code, out } = await runCli(["perplexity", "some-model", "--data-path", "/tmp/absent.jsonl"]);
    expect(code).toBe(1);
    expect(out).toContain("data file not found");
  });
});

// ------------------------------------------------- pure dataset packing units

describe("perplexity data packing (pure)", () => {
  test("parseSamples: jsonl text rows / plain text / bad rows", async () => {
    const { parseSamples } = await import("../src/eval/perplexity");
    expect(parseSamples('{"text":"a"}\n\n{"text":"b"}\n', "d.jsonl")).toEqual(["a", "b"]);
    expect(parseSamples("whole file", "d.txt")).toEqual(["whole file"]);
    expect(() => parseSamples('{"messages":[]}', "d.jsonl")).toThrow('{"text"');
    expect(() => parseSamples("not json", "d.jsonl")).toThrow("not valid JSON");
  });

  test("packRows: non-overlapping fixed rows, sample cap, deterministic seed", async () => {
    const { packRows } = await import("../src/eval/perplexity");
    const samples = Array.from({ length: 10 }, (_, s) =>
      Array.from({ length: 7 }, (_, i) => s * 100 + i));
    const opts = { sequenceLength: 4, numSamples: 5, seed: 123 };
    const rows = packRows(samples, opts);
    expect(rows.length).toBe(5);
    for (const r of rows) expect(r.length).toBe(4);
    // Deterministic under the same seed; different under another.
    expect(packRows(samples, opts).map((r) => [...r])).toEqual(rows.map((r) => [...r]));
    expect(packRows(samples, { ...opts, seed: 7 }).map((r) => [...r]))
      .not.toEqual(rows.map((r) => [...r]));
    // Rows are consecutive cuts of one concatenated stream (no overlap):
    const flat = rows.flatMap((r) => [...r]);
    expect(new Set(flat).size).toBe(flat.length);
    // -1 keeps every full row: 70 tokens → 17 rows of 4.
    expect(packRows(samples, { ...opts, numSamples: -1 }).length).toBe(17);
  });
});

// ------------------------------------------------------------- gated smokes

const optIn = process.env.MLX_BUN_TEST_TOOLS === "1";
const REPO = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit`;
const BASE = (() => {
  try {
    const head = readFileSync(join(REPO, "refs", "main"), "utf8").trim();
    const p = join(REPO, "snapshots", head);
    if (existsSync(join(p, "config.json"))) return p;
    const snaps = readdirSync(join(REPO, "snapshots"));
    return snaps.length ? join(REPO, "snapshots", snaps[0]!) : null;
  } catch {
    return null;
  }
})();
const haveBase = BASE !== null && existsSync(join(BASE, "config.json"));
const ADAPTER = (() => {
  for (const c of [
    `${process.env.HOME}/.cache/mlx-bun/mlx-bun-finetunes/minicpm5-chunk-final`,
    join(import.meta.dir, "../adapters/cpm5-uf"),
  ]) {
    if (existsSync(join(c, "adapters.safetensors"))) return c;
  }
  return null;
})();

describe.skipIf(!optIn || !haveBase || ADAPTER === null)("fuse smoke (MiniCPM5 + real adapter)", () => {
  const tmp = mkdtempSync(join(tmpdir(), "fuse-smoke-"));
  afterAll(() => rmSync(tmp, { recursive: true, force: true }));

  test("fuses into a loadable snapshot; untouched tensors pass through bit-identical", async () => {
    const { fuseAdapter } = await import("../src/train/fuse");
    const outDir = join(tmp, "fused");
    const stats = await fuseAdapter(BASE!, ADAPTER!, outDir);
    expect(stats.fusedModules).toBeGreaterThan(0);
    expect(existsSync(join(outDir, "config.json"))).toBe(true);
    expect(existsSync(join(outDir, "tokenizer.json"))).toBe(true);
    const hasWeights =
      existsSync(join(outDir, "model.safetensors")) ||
      existsSync(join(outDir, "model.safetensors.index.json"));
    expect(hasWeights).toBe(true);

    // Quantization layout preserved verbatim.
    const srcCfg = JSON.parse(readFileSync(join(BASE!, "config.json"), "utf8"));
    const outCfg = JSON.parse(readFileSync(join(outDir, "config.json"), "utf8"));
    expect(outCfg.quantization).toEqual(srcCfg.quantization);

    // Untouched module (embed_tokens): BIT-IDENTICAL passthrough.
    // Fused module (layers.0 q_proj): scales must have changed.
    const { Weights } = await import("../src/weights");
    const src = await Weights.open(BASE!);
    const out = await Weights.open(outDir);
    try {
      const embedName = src.tensorNames.find((n) => n.includes("embed_tokens") && n.endsWith(".scales"))!;
      expect(out.tensor(embedName).rawBytes()).toEqual(src.tensor(embedName).rawBytes());
      const qName = src.tensorNames.find((n) => /layers\.0\..*q_proj\.scales$/.test(n))!;
      expect(out.tensor(qName).rawBytes()).not.toEqual(src.tensor(qName).rawBytes());
    } finally {
      src.dispose();
      out.dispose();
    }
  }, 600_000);
});

describe.skipIf(!optIn || !haveBase)("perplexity smoke (MiniCPM5, inline dataset)", () => {
  const tmp = mkdtempSync(join(tmpdir(), "ppl-smoke-"));
  afterAll(() => rmSync(tmp, { recursive: true, force: true }));

  test("finite ppl over a 5-line jsonl; ppl == exp(mean CE)", async () => {
    const lines = [
      "The quick brown fox jumps over the lazy dog while the farmer watches from the porch of the old house near the river bend in early autumn light.",
      "Apple silicon machines share one memory pool between the CPU and the GPU, which changes how inference engines think about weights, caches, and transient buffers.",
      "A perplexity measurement packs tokenized samples into fixed-length rows and scores every next-token prediction of the model under a causal mask in one forward pass.",
      "She sells sea shells by the sea shore, and the shells she sells are surely sea shells, so if she sells shells on the seashore, the shells are seashore shells.",
      "Local models remember nothing between sessions unless you give them a durable memory, which is why a personal wiki the assistant can read changes what it can do.",
    ];
    const dataPath = join(tmp, "ppl.jsonl");
    writeFileSync(dataPath, lines.map((text) => JSON.stringify({ text })).join("\n") + "\n");

    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { parseSamples, packRows, evalPpl } = await import("../src/eval/perplexity");

    const config = await loadModelConfig(BASE!);
    const model = createModel(await Weights.open(BASE!), config);
    const tok = await loadTokenizer(BASE!);

    const samples = parseSamples(readFileSync(dataPath, "utf8"), dataPath);
    expect(samples.length).toBe(5);
    const rows = packRows(samples.map((t) => tok.encode(t)), {
      sequenceLength: 32,
      numSamples: 4,
      seed: 123,
    });
    expect(rows.length).toBeGreaterThan(0);

    const r = evalPpl(model, rows, 2);
    expect(Number.isFinite(r.ppl)).toBe(true);
    expect(r.ppl).toBeGreaterThan(1); // real text is never perfectly predicted
    expect(r.ppl).toBeLessThan(1e4); // and a 1B model is far better than random over 130k vocab
    expect(r.ppl).toBeCloseTo(Math.exp(r.meanLoss), 6);
    expect(r.tokens).toBe(rows.length * 31); // every position of rows[:, 1:] counts
    expect(r.standardError).toBeGreaterThan(0);
  }, 300_000);
});
