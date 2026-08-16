// G2 exit gate against the immutable tiny-model trajectory captured from the
// pinned Colibri engine. The converted tiny Colibri artifact is intentionally
// external: set MLX_BUN_GLM52_TINY_COLIBRI to its directory to run the gate.

import { describe, expect, test } from "bun:test";
import {
  existsSync,
  mkdtempSync,
  readdirSync,
  rmSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import fixture from "../fixtures/colibri-glm52/tiny-teacher-forcing.json";

const modelDir = process.env.MLX_BUN_GLM52_TINY_COLIBRI ?? "";
const haveArtifact =
  modelDir.length > 0 &&
  existsSync(join(modelDir, "config.json")) &&
  readdirSync(modelDir).some((name) => /^out-\d+\.safetensors$/.test(name));

function rowArgmax(
  logits: Float32Array,
  rows: number,
  vocabulary: number,
): number[] {
  if (logits.length !== rows * vocabulary) {
    throw new Error(
      `teacher logits length ${logits.length} != ${rows} × ${vocabulary}`,
    );
  }
  const tokens: number[] = [];
  for (let row = 0; row < rows; row++) {
    const base = row * vocabulary;
    let best = 0;
    let bestValue = logits[base]!;
    for (let token = 1; token < vocabulary; token++) {
      const value = logits[base + token]!;
      if (value > bestValue) {
        best = token;
        bestValue = value;
      }
    }
    tokens.push(best);
  }
  return tokens;
}

function minimumTopTwoMargin(
  logits: Float32Array,
  rows: number,
  vocabulary: number,
): number {
  let minimum = Number.POSITIVE_INFINITY;
  for (let row = 0; row < rows; row++) {
    const base = row * vocabulary;
    let first = Number.NEGATIVE_INFINITY;
    let second = Number.NEGATIVE_INFINITY;
    for (let token = 0; token < vocabulary; token++) {
      const value = logits[base + token]!;
      if (value > first) {
        second = first;
        first = value;
      } else if (value > second) {
        second = value;
      }
    }
    minimum = Math.min(minimum, first - second);
  }
  return minimum;
}

describe.skipIf(!haveArtifact)(
  "GLM-5.2 tiny Colibri teacher forcing",
  () => {
    test("matches all 32 pinned next-token predictions", async () => {
      const { Glm52Model } = await import("../src/model/glm52");
      const model = await Glm52Model.open(modelDir);
      const cache = model.makeCache();
      try {
        const logits = model.forward(fixture.full_ids, cache);
        try {
          const values = logits.toFloat32();
          const predictions = rowArgmax(
            values,
            fixture.full_ids.length,
            model.glmConfig.vocabSize,
          );
          expect(predictions).toEqual(fixture.tf_pred);
          // The smallest observed direct-container margin is ~0.00343, so this
          // is a real trajectory comparison rather than exact-tie luck.
          expect(minimumTopTwoMargin(
            values,
            fixture.full_ids.length,
            model.glmConfig.vocabSize,
          )).toBeGreaterThan(
            fixture.numeric_contract.required_minimum_top_two_margin,
          );
        } finally {
          logits.dispose();
        }
      } finally {
        for (const layer of cache) layer.dispose();
        model.dispose();
      }
    }, 120_000);

    test("streams routed experts through bounded slabs with the same trajectory", async () => {
      const dir = mkdtempSync(join(tmpdir(), "mlx-bun-glm52-g3-"));
      const libraryPath = join(dir, "libexpert_io.dylib");
      try {
        const build = Bun.spawn(
          ["sh", "scripts/build-expert-io.sh", libraryPath],
          { stdout: "ignore", stderr: "pipe" },
        );
        if (await build.exited)
          throw new Error(await new Response(build.stderr).text());
        const { Glm52Model } = await import("../src/model/glm52");
        const model = await Glm52Model.openStreamed(modelDir, {
          budgetBytes: 1024 * 1024 * 1024,
          reserveBytes: 0,
          maxSlotsPerLayer: 1,
          usagePath: false,
          libraryPath,
        });
        const cache = model.makeCache();
        try {
          const logits = await model.forwardAsync(fixture.full_ids, cache);
          try {
            const values = logits.toFloat32();
            expect(rowArgmax(
              values,
              fixture.full_ids.length,
              model.glmConfig.vocabSize,
            )).toEqual(fixture.tf_pred);
            expect(model.expertRuntime?.manager.snapshot()).toMatchObject({
              working: 64,
              resident: 2,
              leased: 0,
              loading: 0,
            });
          } finally {
            logits.dispose();
          }
        } finally {
          for (const layer of cache) layer.dispose();
          model.dispose();
        }

        const metalModel = await Glm52Model.openStreamed(modelDir, {
          budgetBytes: 1024 * 1024 * 1024,
          reserveBytes: 0,
          maxSlotsPerLayer: 1,
          usagePath: false,
          libraryPath,
          decodeKernel: "metal",
        });
        const metalCache = metalModel.makeCache();
        try {
          const logits = await metalModel.forwardAsync(
            [fixture.full_ids[0]!],
            metalCache,
          );
          try {
            expect(rowArgmax(
              logits.toFloat32(),
              1,
              metalModel.glmConfig.vocabSize,
            )).toEqual([fixture.tf_pred[0]!]);
          } finally {
            logits.dispose();
          }
        } finally {
          for (const layer of metalCache) layer.dispose();
          metalModel.dispose();
        }
      } finally {
        rmSync(dir, { recursive: true, force: true });
      }
    }, 120_000);
  },
);

test("GLM-5.2 pinned teacher-forcing fixture is complete", () => {
  expect(fixture.source.commit).toBe(
    "44e489b196c9b7876b3d37a0570ebf1c6f90f54c",
  );
  expect(fixture.source.precision).toBe("int4-per-row");
  expect(fixture.source.engine_args).toEqual(["64", "4", "4"]);
  expect(fixture.source.oracle_env.IDOT).toBe("0");
  expect(fixture.source.direct_container_sha256).toBe(
    "010ff6c76e8df73e196bcfbfe5807226e155fe95899c4d28a14f229f1ddf79bc",
  );
  expect(fixture.full_ids).toHaveLength(32);
  expect(fixture.bf16_tf_pred).toHaveLength(32);
  expect(fixture.tf_pred).toHaveLength(32);
  expect(fixture.default_idot_tf_pred).toHaveLength(32);
  expect(fixture.numeric_contract.max_abs_logit_delta).toBeLessThan(2e-6);
});
