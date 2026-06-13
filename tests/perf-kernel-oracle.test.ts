// Perf-mode quality gate (docs/design/optimization_plan.md Phase E): the fused
// decode kernel is NOT bit-exact (it can't be — every implementation
// that rounds scores to bf16 differs by final-rounding ties), so it
// gates against the FROZEN compat oracle under TEACHER FORCING: feed
// compat's frozen token at every step (contexts stay identical — free-
// running greedy comparison measures chaos, not quality) and count
// argmax agreement.
//
// Thresholds are LABELED from measurement (2026-06-11, 12B):
//   fused kernel:        60/64 @600, 62/64 @2k
//   accepted tier-b tiled path (the precedent): 62/64, 63/64
// Gate: ≥ 56/64 per prompt — kernel quality at the envelope the project
// already ships.

import { afterAll, describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();
const haveOracle = await Bun.file("goldens/perf-oracle/12b.json").exists();

describe.skipIf(!haveWeights || !haveOracle)("fused kernel vs frozen perf oracle (12B)", async () => {
  if (!haveWeights || !haveOracle) return;
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { argmaxLastPosition } = await import("../src/model/gemma4");
  const g12b = await import("../src/model/generated/gemma4-12b");
  const kernel = await import("../src/model/fused-decode-kernel");
  const { loadTokenizer } = await import("../src/tokenizer");

  const frozen = (await Bun.file("goldens/perf-oracle/12b.json").json()) as {
    fingerprint: string;
    short: { promptLen: number; trajectory: number[] };
    long: { promptLen: number; trajectory: number[] };
  };
  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new g12b.GeneratedGemma4(weights, config);
  const tok = await loadTokenizer(SNAPSHOT);

  afterAll(async () => {
    weights.dispose();
    (await import("../src/mlx/ffi")).clearCache();
  });

  const textPrompt = (len: number): number[] => {
    let msg =
      "The history of computing begins with mechanical calculators and " +
      "proceeds through relays, vacuum tubes, transistors, and integrated " +
      "circuits. Each generation multiplied both speed and reliability. ";
    while (tok.encode(msg).length < len) msg += msg.slice(0, 400);
    return [2, ...tok.encode(msg).slice(0, len - 1)];
  };

  for (const key of ["short", "long"] as const) {
    test(`teacher-forced agreement >= 56/64 (${key})`, () => {
      expect(frozen.fingerprint).toBe(g12b.FINGERPRINT);
      process.env.MLX_BUN_PERF_KERNEL = "1";
      process.env.MLX_BUN_COMPILED_DECODE = "0";
      const calls0 = kernel.fusedKernelCalls;
      try {
        const ref = frozen[key];
        const cache = model.makeCache();
        try {
          for (let i = 0; i < cache.length; i++) {
            const e = config.kvQuant!.find((q) => q.layerIdx === i);
            if (e)
              cache[i] = (cache[i] as unknown as { toQuantized(g: number, b: number): (typeof cache)[number] }).toQuantized(e.groupSize, e.bits);
          }
          let tokens: number[] = textPrompt(ref.promptLen);
          let agree = 0;
          for (let s = 0; s < 64; s++) {
            const logits = model.forward(tokens, cache);
            if (argmaxLastPosition(logits) === ref.trajectory[s]) agree++;
            logits.dispose();
            tokens = [ref.trajectory[s]!]; // teacher-forced
          }
          expect(agree).toBeGreaterThanOrEqual(56);
        } finally {
          for (const c of cache) c.dispose();
        }
        // decode steps must have actually exercised the kernel
        expect(kernel.fusedKernelCalls - calls0).toBeGreaterThan(48 * 32);
      } finally {
        delete process.env.MLX_BUN_PERF_KERNEL;
        delete process.env.MLX_BUN_COMPILED_DECODE;
      }
    }, 600_000);
  }
});
