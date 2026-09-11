import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const enabled = Bun.env.MLX_BUN_TEST_DFLASH_GROUP_FIXTURE === "1";

test.skipIf(!enabled)("DSpark Markov/RNN serving and persisted context with a real Gemma target", async () => {
  const { DflashDrafter, DEFAULT_DFLASH_CONFIG } = await import("../../src/spec/dspark/module-dflash");
  const target = Bun.env.MLX_BUN_TEST_MTP_TARGET!;
  const config = await Bun.file(join(target, "config.json")).json();
  const text = config.text_config ?? config;
  const directory = mkdtempSync(join(tmpdir(), "dflash-serving-"));
  try {
    for (const seqHead of ["markov", "rnn"] as const) {
      const checkpoint = join(directory, seqHead);
      const drafter = DflashDrafter.initFromDims({
        hiddenSize: text.hidden_size, vocabSize: text.vocab_size, eps: text.rms_norm_eps,
      }, { ...DEFAULT_DFLASH_CONFIG, gamma: 3, dDraft: 32, nLayers: 2, nHeads: 4,
        markovRank: 8, tapLayers: [1, 2, 3], seqHead }, target, 17);
      try { drafter.save(checkpoint); } finally { drafter.dispose(); }
      // Seeded weights exercise execution/state contracts, not trained acceptance or quality.
      for (const name of ["qwen-mtp-serving-group", "qwen-mtp-generated-prefix",
        ...(Number(Bun.env.MLX_BUN_TEST_MTP_KV_START ?? 0) > 0 && Bun.env.MLX_BUN_TEST_MTP_TURBO !== "1"
          ? ["qwen-delayed-quantized-serving"] : [])]) {
        const child = Bun.spawn([process.execPath, "test", `tests/parity/${name}.test.ts`], {
          env: { ...Bun.env, MLX_BUN_TEST_BATCH_SPEC_REPLAY: "1", MLX_BUN_TEST_MTP_PREFIX: "1",
            MLX_BUN_TEST_GROUP_DFLASH: "1", MLX_BUN_TEST_GROUP_DEEPSPEC: "0",
            MLX_BUN_TEST_GROUP_ASSISTANT: "0", MLX_BUN_TEST_GROUP_TWO_MODEL: "0",
            MLX_BUN_TEST_MTP_DRAFT: checkpoint, MLX_BUN_TEST_MTP_DEPTH: "3" },
          stdout: "inherit", stderr: "inherit",
        });
        expect(await child.exited).toBe(0);
      }
    }
  } finally { rmSync(directory, { recursive: true, force: true }); }
}, 1_800_000);
