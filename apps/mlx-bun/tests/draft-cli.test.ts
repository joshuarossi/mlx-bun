import { expect, test } from "bun:test";
import { join } from "node:path";

// A trained drafter directory is what `serve --draft-model <dir>` resolves: the app scans a
// directory only when it has a config.json, so the producer must write one. Native (a tiny
// drafter is initialized and saved with MLX); opt in with MLX_BUN_TEST_NATIVE=1.
test.skipIf(process.env.MLX_BUN_TEST_NATIVE !== "1")("a saved drafter directory resolves like a model path and is marked a companion", async () => {
  const [{ DflashDrafter, DEFAULT_DFLASH_CONFIG }, { saveDrafter }, { resolveModelAuto }, { mkdtempSync, rmSync }, { tmpdir }] = await Promise.all([
    import("@mlx-bun/inference/generation/speculative/loader"), import("@mlx-bun/training/dspark"), import("../src/cli/model-selection"), import("node:fs"), import("node:os")]);
  const dir = mkdtempSync(join(tmpdir(), "mlx-draft-dir-"));
  try {
    const drafter = DflashDrafter.initFromDims({ hiddenSize: 16, vocabSize: 32, eps: 1e-6 }, { ...DEFAULT_DFLASH_CONFIG, gamma: 3, dDraft: 32, nLayers: 1, nHeads: 4, markovRank: 8, tapLayers: [1, 2] }, "t");
    saveDrafter(drafter, join(dir, "d")); drafter.dispose();
    const { m, picked } = await resolveModelAuto(join(dir, "d"));
    expect(picked).toBe(false);
    expect(m).toMatchObject({ repoId: "d", modelType: "dspark_assistant", hiddenSize: 32, vocabSize: 32 });
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
