import { expect, test } from "bun:test";
import { parseNativeBenchArgs, validatePromptIds } from "../../scripts/bench/native";

const required = ["--model-path", "/tmp/model", "--prompt-ids", "/tmp/prompt.json", "--json", "/tmp/result.json"];
test("native benchmark rejects ambiguous controls before loading weights", () => {
  expect(() => parseNativeBenchArgs([...required, "--samples", "0"])).toThrow("--samples");
  expect(() => parseNativeBenchArgs([...required, "--tokens", "NaN"])).toThrow("--tokens");
  expect(() => parseNativeBenchArgs([...required, "--stack", "unknown"])).toThrow("--stack");
  expect(() => parseNativeBenchArgs([...required, "--tokens", "3", "--tokens", "4"])).toThrow("duplicate");
  expect(() => parseNativeBenchArgs([...required, "--force"])).toThrow("unknown");
  expect(() => parseNativeBenchArgs(["--model-path", "/tmp/model"])).toThrow("--prompt-ids");
});
test("native benchmark freezes sample count and requires explicit diagnostic override", () => {
  expect(parseNativeBenchArgs(required)).toMatchObject({ stack: "mlx-bun", samples: 5, warmup: 1, diagnostic: false });
  expect(parseNativeBenchArgs([...required, "--diagnostic", "--dry-run", "--samples", "6", "--stack", "mlx-lm"]))
    .toMatchObject({ stack: "mlx-lm", samples: 6, diagnostic: true, dryRun: true });
});
test("shared prompt IDs reject empty, fractional and out-of-vocabulary inputs", () => {
  for (const bad of [[], [1.5], [-1], [10], ["1"], { ids: [1] }])
    expect(() => validatePromptIds(bad, 10)).toThrow("prompt file");
  expect(validatePromptIds([0, 9, 3], 10)).toEqual([0, 9, 3]);
});
