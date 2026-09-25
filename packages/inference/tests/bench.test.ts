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
