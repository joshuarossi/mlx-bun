import { expect, test } from "bun:test";
import { resolve } from "node:path";
import { parseNativeBenchArgs, validatePromptIds } from "../scripts/bench";
const required = ["--model-path", "/model", "--prompt-ids", "/ids.json", "--json", "/result.json"];
test("benchmark options preserve main's sample defaults and explicit overrides", () => {
  const defaults = parseNativeBenchArgs(required);
  expect(defaults).toMatchObject({ tokens: 64, samples: 5, warmup: 1, prefillChunk: 2048, clearBeforeRequest: false });
  expect(parseNativeBenchArgs([...required, "--tokens", "8", "--samples", "2", "--warmup", "0", "--prefill-chunk", "16", "--clear-before-request", "--hash-weights"]))
    .toMatchObject({ tokens: 8, samples: 2, warmup: 0, prefillChunk: 16, clearBeforeRequest: true, hashWeights: true });
});
test("benchmark rejects ambiguous options and invalid measurement bounds", () => {
  for (const args of [[], [...required, "--stack", "mlx-lm"], [...required, "--tokens", "0"],
    [...required, "--samples", "0"], [...required, "--warmup", "-1"], [...required, "--tokens", "1.5"],
    [...required, "--tokens"], [...required, "--json", "duplicate"], [...required, "--prefill-chunk", "0"]])
    expect(() => parseNativeBenchArgs(args)).toThrow();
});
test("prompt IDs must be nonempty integers within the chosen vocabulary", () => {
  expect(validatePromptIds([0, 15], 16)).toEqual([0, 15]);
  for (const ids of [[], [16], [-1], [1.5], [null], "text"])
    expect(() => validatePromptIds(ids, 16)).toThrow();
});
test("benchmark help works without a native runtime", () => {
  const result = Bun.spawnSync([process.execPath, resolve(import.meta.dir, "../scripts/bench.ts"), "--help"],
    { env: { ...process.env, MLX_BUN_LIBMLXC: "/missing" } });
  expect(result.exitCode).toBe(0);
  expect(result.stdout.toString()).toContain("Measure direct library generation");
});

import { pairReports } from "../scripts/bench";
function pair() {
  return (["main", "branch", "branch", "main"] as const).map((tree, i) => {
    const sample = { startedAt: new Date(i * 10000 + 1000).toISOString(), completedAt: new Date(i * 10000 + 2000).toISOString(), wallMs: 10 + i, firstTokenMs: 1, tokens: [4, 5], finishReason: "length",
      peakBytes: 100, memoryBefore: { activeBytes: 10, cacheBytes: 0 }, memoryAfter: { activeBytes: 20, cacheBytes: 0 },
      engineTiming: { prefillMs: 1, decodeMs: 8, cachedTokens: 0, generatedTokens: 2 } };
    return { tree, report: { complete: true, sourceCommit: (tree === "main" ? "a" : "b").repeat(40), dirty: false,
      artifact: "/model", configSha256: "c".repeat(64), indexSha256: null, promptSha256: "d".repeat(64),
      promptIds: [1, 2], eosTokenIds: [9], runtimeEnvironment: {}, weightHashes: { "model.safetensors": "e".repeat(64) },
      host: "machine", chip: "chip", ramBytes: 1000, options: { tokens: 2, samples: 1, warmup: 1, prefillChunk: 128, clearBeforeRequest: false },
      warmups: [{ ...structuredClone(sample), startedAt: new Date(i * 10000).toISOString(), completedAt: new Date(i * 10000 + 500).toISOString() }], samples: [sample] } };
  });
}
test("paired summaries retain ABBA order and exclude warmups from distributions", () => {
  const runs = pair(); runs[0]!.report.warmups[0]!.wallMs = 999;
  const result = pairReports(runs);
  expect(result.order).toEqual(["main", "branch", "branch", "main"]);
  expect(result.trees.main!.wallMs).toEqual({ median: 11.5, min: 10, max: 13 });
  expect(result.trees.branch!.samples).toBe(2);
});
test("pairing refuses token drift, missing evidence and mismatched settings before timing", () => {
  const mutations = [
    (r: any) => { r[1].report.samples[0].tokens = [4, 6]; },
    (r: any) => { r[1].report.warmups[0].tokens = [4, 6]; },
    (r: any) => { r[1].report.complete = false; },
    (r: any) => { r[1].report.samples = []; },
    (r: any) => { delete r[0].report.runtimeEnvironment; },
    (r: any) => { r[1].report.eosTokenIds = [10]; },
    (r: any) => { r[1].report.promptSha256 = "f".repeat(64); },
    (r: any) => { r[1].report.weightHashes = {}; },
    (r: any) => { r[1].report.options.prefillChunk = 64; },
    (r: any) => { r[1].report.runtimeEnvironment = { MLX_BUN_COMPILED_DECODE: "1" }; },
    (r: any) => { r[1].report.samples[0].wallMs = NaN; },
    (r: any) => { r[1].report.samples[0].engineTiming.cachedTokens = 1; },
    (r: any) => { r[1].report.dirty = true; },
    (r: any) => { r[1].report.samples[0].startedAt = r[0].report.samples[0].startedAt; },
    (r: any) => { r[2].report.sourceCommit = "c".repeat(40); },
    (r: any) => { [r[0], r[1]] = [r[1], r[0]]; },
  ];
  for (const mutate of mutations) { const runs = pair(); mutate(runs); expect(() => pairReports(runs)).toThrow(); }
  expect(() => pairReports(pair().slice(0, 2))).toThrow();
});
