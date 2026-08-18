import { describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  admitRequestContext,
  detectDraftKind,
  loadContext,
} from "../src/server";

describe("request context admission", () => {
  test("a broad client completion cap is clamped to the remaining context", () => {
    expect(admitRequestContext(2_788, 8_192, 4_096)).toEqual({
      maxTokens: 1_308,
      clamped: true,
    });
  });

  test("regression 2026-08-18: 17-token overshoot with 8k of room is clamped, not rejected", () => {
    // The reported failure: prompt 8213 + max_tokens 8192 vs safe context
    // 16388 — the pre-fix generic path 400'd despite 8175 tokens of room.
    expect(admitRequestContext(8_213, 8_192, 16_388)).toEqual({
      maxTokens: 8_175,
      clamped: true,
    });
  });

  test("a prompt that fills the safe context is still rejected", () => {
    expect(admitRequestContext(4_096, 1, 4_096)).toBeNull();
  });

  test("an already-fitting request is unchanged", () => {
    expect(admitRequestContext(2_788, 128, 4_096)).toEqual({
      maxTokens: 128,
      clamped: false,
    });
  });
});

describe("Qwen MTP admission", () => {
  test("detects the companion artifact and no longer refuses it up front", async () => {
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
      // The DeltaNet rollback contract (SSMCache spec rounds) unblocked
      // native MTP: the artifact is detected as "mtp" and load PROCEEDS —
      // this synthetic dir then fails on its missing weights, not on the
      // retired up-front refusal.
      expect(await detectDraftKind(draft)).toBe("mtp");
      await expect(loadContext(target, undefined, { draftModelDir: draft }))
        .rejects.toThrow(/safetensors|weights|shard|tensor/i);
    } finally {
      rmSync(root, { recursive: true });
    }
  });
});
