import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import { independentGreedySampling, makeStepSampler } from "../../src/sampler";

const config = { tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample" } as const;

test("independent sampling preserves normalized-score ties and the per-position sampler", async () => {
  const sampler = makeStepSampler({ temperature: 0 }, config);
  try {
    for (const dtype of [Dtype.float32, Dtype.bfloat16]) for (const vocab of [32, 4096, 262144]) {
      const positions = 8;
      using input = MlxArray.fromFloat32(Float32Array.from({ length: positions * vocab }, (_, i) =>
        Math.sin(i * 0.3) * 4 + Math.cos(i * 0.21)), [positions, vocab]);
      using logits = input.astype(dtype);
      using tokens = independentGreedySampling.sample(logits);
      const together = tokens.toIntTokens(), separately: number[] = [];
      for (let row = 0; row < positions; row++) {
        using scores = logits.slice([row, 0], [row + 1, vocab]);
        separately.push((await sampler.sample(scores, row)).token);
      }
      expect(together).toEqual(separately);
    }
    using tiny = MlxArray.fromFloat32(new Float32Array([0, 1e-8, 0, 0]), [1, 4]);
    using normalized = independentGreedySampling.sample(tiny);
    using raw = ops.argmaxAxis(tiny, -1);
    expect(raw.toIntTokens()).toEqual([1]);
    expect(normalized.toIntTokens()).toEqual([0]);
    expect((await sampler.sample(tiny, 0)).token).toBe(0);
  } finally { sampler.dispose(); }
});

test("stateful, metadata-producing and custom samplers keep their own sampling operation", () => {
  const custom = (_scores: MlxArray) => ops.fromInt32([3], [1]);
  const sessions = [
    makeStepSampler({ temperature: 0.8, seed: 17 }, config),
    makeStepSampler({ temperature: 0, repetitionPenalty: 1.2 }, config),
    makeStepSampler({ temperature: 0 }, { ...config, captureSelectedLogprob: true }),
    makeStepSampler({ temperature: 0 }, { ...config, captureTopLogprobs: 2 }),
    makeStepSampler({ temperature: 0 }, { ...config, sampler: custom }),
  ];
  const plain = makeStepSampler({ temperature: 0 }, config);
  try {
    expect(plain.independent).toBe(independentGreedySampling);
    for (const session of sessions) expect(session.independent).toBeUndefined();
  } finally { for (const session of [...sessions, plain]) session.dispose(); }
});
