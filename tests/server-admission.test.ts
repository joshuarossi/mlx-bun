import { describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  admitRequestContext,
  detectDraftKind,
  loadContext,
  QWEN_MTP_UNSUPPORTED_REASON,
} from "../src/server";

describe("request context admission", () => {
  test("fixed-context GLM clamps a broad client completion cap", () => {
    expect(admitRequestContext(2_788, 8_192, 4_096, true)).toEqual({
      maxTokens: 1_308,
      clamped: true,
    });
  });

  test("generic memory-budget serving preserves fail-fast admission", () => {
    expect(admitRequestContext(2_788, 8_192, 4_096, false)).toBeNull();
  });

  test("a prompt that fills the fixed context is still rejected", () => {
    expect(admitRequestContext(4_096, 1, 4_096, true)).toBeNull();
  });

  test("an already-fitting request is unchanged", () => {
    expect(admitRequestContext(2_788, 128, 4_096, true)).toEqual({
      maxTokens: 128,
      clamped: false,
    });
  });
});

describe("Qwen MTP release guard", () => {
  test("detects the companion artifact for a precise fail-fast refusal", async () => {
    const root = mkdtempSync(join(tmpdir(), "mlx-bun-qwen-mtp-"));
    const target = join(root, "target");
    const draft = join(root, "draft");
    mkdirSync(target);
    mkdirSync(draft);
    try {
      writeFileSync(
        join(draft, "config.json"),
        JSON.stringify({ model_type: "qwen3_5_mtp" }),
      );
      writeFileSync(join(target, "config.json"), JSON.stringify({
        model_type: "qwen3_5",
        hidden_size: 8,
        num_hidden_layers: 1,
        num_attention_heads: 1,
        num_key_value_heads: 1,
        head_dim: 8,
        intermediate_size: 16,
        rms_norm_eps: 1e-6,
        vocab_size: 32,
        max_position_embeddings: 32,
        linear_num_value_heads: 1,
        full_attention_interval: 1,
        eos_token_id: 2,
      }));
      expect(await detectDraftKind(draft)).toBe("mtp");
      expect(QWEN_MTP_UNSUPPORTED_REASON).toContain("cannot roll back");
      await expect(loadContext(target, undefined, { draftModelDir: draft }))
        .rejects.toThrow(QWEN_MTP_UNSUPPORTED_REASON);
    } finally {
      rmSync(root, { recursive: true });
    }
  });
});
