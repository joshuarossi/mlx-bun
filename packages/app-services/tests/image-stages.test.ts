// The image host's stage rule and the parent's charge from a snapshot's files: a synthetic
// pipeline snapshot (no model, no MLX) with weighted and weightless components.
import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { DEFAULT_STAGE_BUDGET_FRACTION, defaultStageBudgetBytes, pipelineComponentBytes, stageResidency } from "../src";
import * as portable from "../src/portable";

/** A pipeline snapshot whose components hold `*.safetensors` files of the given sizes (an empty list: a weightless component). */
function snapshot(components: Record<string, number[]>, extra: Record<string, unknown> = {}) {
  const root = mkdtempSync(join(tmpdir(), "mlx-image-stages-"));
  const index: Record<string, unknown> = { _class_name: "SomeImagePipeline", _diffusers_version: "0", ...extra };
  for (const [name, files] of Object.entries(components)) {
    index[name] = ["library", "Component"];
    mkdirSync(join(root, name));
    writeFileSync(join(root, name, "config.json"), "{}");
    files.forEach((bytes, at) => writeFileSync(join(root, name, `model-${at}.safetensors`), new Uint8Array(bytes)));
  }
  writeFileSync(join(root, "model_index.json"), JSON.stringify(index));
  return { root, remove: () => rmSync(root, { recursive: true, force: true }) };
}

test("a snapshot's component bytes are each declared component's safetensors files; weightless and absent components and metadata are not components", async () => {
  const { root, remove } = snapshot({ text_encoder: [200, 100], transformer: [500], vae: [100], tokenizer: [], scheduler: [] },
    { safety_checker: [null, null] });
  try {
    // A file that is not safetensors (an index, a config) counts for nothing.
    writeFileSync(join(root, "transformer", "model.safetensors.index.json"), "{".padEnd(4_000, " "));
    // An undeclared directory with weights is not a component of the pipeline.
    mkdirSync(join(root, "original"));
    writeFileSync(join(root, "original", "model.safetensors"), new Uint8Array(9_000));
    expect(await pipelineComponentBytes(root)).toEqual({ text_encoder: 300, transformer: 500, vae: 100 });
  } finally { remove(); }
  await expect(pipelineComponentBytes(join(tmpdir(), "mlx-image-stages-missing"))).rejects.toThrow();
});

test("one run holds every stage while they fit the budget together, and only the largest once they exceed it", async () => {
  const { root, remove } = snapshot({ text_encoder: [300], transformer: [500], vae: [100], tokenizer: [] });
  try {
    const stages = Object.values(await pipelineComponentBytes(root));
    // 900 bytes of stages: kept open under a 1000 or exactly 900 byte budget, so a run holds all of them.
    expect(stageResidency(stages, 1_000)).toEqual({ releaseStages: false, bytes: 900 });
    expect(stageResidency(stages, 900)).toEqual({ releaseStages: false, bytes: 900 });
    // Over the budget, each run releases every stage after its output: it holds the largest.
    expect(stageResidency(stages, 899)).toEqual({ releaseStages: true, bytes: 500 });
    expect(stageResidency([], 1)).toEqual({ releaseStages: false, bytes: 0 });
  } finally { remove(); }
  // The default budget is the share of physical memory the image host uses, and the isolated parent reaches the rule without a model host.
  expect(defaultStageBudgetBytes()).toBe(Math.floor((await import("node:os")).totalmem() * DEFAULT_STAGE_BUDGET_FRACTION));
  expect([portable.defaultStageBudgetBytes, portable.pipelineComponentBytes, portable.stageResidency]).toEqual([defaultStageBudgetBytes, pipelineComponentBytes, stageResidency]);
});
