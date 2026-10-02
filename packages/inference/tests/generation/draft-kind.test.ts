import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { detectDraftKind } from "../../src/generation/speculative/draft-kind";

test("draft detection preserves explicit artifact conventions without loading MLX", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-draft-kind-"));
  try {
    for (const [config, expected] of [
      [{ architectures: ["Gemma4DSparkModel"] }, "deepspec"],
      [{ model_type: "gemma4_assistant" }, "assistant"],
      [{ model_type: "qwen3_5_mtp" }, "mtp"],
      [{ model_type: "qwen3" }, "two-model"],
    ] as const) {
      writeFileSync(join(dir, "config.json"), JSON.stringify(config));
      expect(await detectDraftKind(dir)).toBe(expected);
    }
    writeFileSync(join(dir, "dspark.json"), "{}"); expect(await detectDraftKind(dir)).toBe("dspark");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
