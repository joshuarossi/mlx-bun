// Same-B media continuation: independent CPU position construction versus the
// request-owned device position path, including padding and row retirement.
import { afterAll, describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import type { MlxArray } from "../../src/mlx/array";
import type { Cache } from "../../src/model/gemma4-base";
import type { MlxDecodeState } from "../../src/backends/mlx/prompt-input";
import type { MropeRequestState } from "../../src/model/qwen3-mrope";

const path = process.env.MLX_BUN_TEST_QWEN_MEDIA_MODEL;
describe.skipIf(!path)("Qwen request-owned media positions", async () => {
  if (!path) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindQwenMediaInput } = await import("../../src/backends/mlx/qwen-prompt-input");
  const { bindEmbeddingsInput } = await import("../../src/backends/mlx/prompt-input");
  const { resolveKvScheme } = await import("../../src/kv-scheme");
  const { createRuntimeConfig } = await import("../../src/runtime-config");
  const { mropePositionIds } = await import("../../src/model/qwen3-mrope");
  const ops = await import("../../src/mlx/ops");
  const weights = await Weights.open(path), model = new Qwen35Model(weights, await loadModelConfig(path));
  afterAll(() => weights.dispose());
  const hash = (value: MlxArray) => {
    using contiguous = ops.contiguous(value);
    return { shape: value.shape, dtype: value.dtype,
      sha256: createHash("sha256").update(contiguous.rawBytes()).digest("hex") };
  };
  function state(length: number, row: number): MropeRequestState {
    return { delta: -2 - row, positions: [0, 1, 2].map(axis =>
      Int32Array.from({ length }, (_, i) => i < 2 ? i : i < 5 ? 2 + (axis + row + i) % 2 : i - 2 - row)) as MropeRequestState["positions"] };
  }
  type ReferenceState = MlxDecodeState & { delta: number };
  function referenceDecode(delta: number): ReferenceState {
    return { key: "qwen-cpu-position-reference", delta,
      forward(ids: MlxArray, caches: Cache[], rows: readonly MlxDecodeState[]) {
        const B = rows.length, L = ids.shape[1]!, cache = caches[model.faIdx]!;
        const offsetArray = (cache as Cache & { ropeOffsetArr?: MlxArray }).ropeOffsetArr;
        const offsets = offsetArray?.toIntTokens() ?? Array(B).fill(cache.offset);
        const joint: number[] = [];
        for (let axis = 0; axis < 3; axis++) for (let row = 0; row < B; row++)
          for (let i = 0; i < L; i++) joint.push(offsets[row]! + (rows[row] as ReferenceState).delta + i);
        using positions = ops.fromInt32(joint, [3, B, L]);
        return model.forwardHiddenAtPositions(ids, caches, positions);
      },
    };
  }
  for (const B of [1, 2, 4]) for (const format of ["bf16", "kv4-delayed", "k8v3-delayed"] as const) {
    test(`${format} B${B} unequal prompts and retirement preserve every logit vector`, async () => {
      const scheme = resolveKvScheme(format === "kv4-delayed" ? { override: 4, quantizedKvStart: 12 }
        : format === "k8v3-delayed" ? { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 12 } : {});
      const arms: unknown[] = [];
      for (const reference of [true, false]) {
        let held = true;
        const group = new MlxBatchExecutionGroup(model, { maxBatch: B, kvScheme: scheme,
          kvBatchCapabilities: { delayedAffine: true }, admissionHeld: () => held,
          runtime: createRuntimeConfig({ MLX_BUN_COMPILED_DECODE: "0" }) });
        const owned: MlxArray[] = [], widths: number[] = [];
        const original = model.forwardHiddenAtPositions.bind(model);
        model.forwardHiddenAtPositions = (ids, caches, positions) => {
          widths.push(ids.shape[0]!); return original(ids, caches, positions);
        };
        const logits = Array.from({ length: B }, () => [] as ReturnType<typeof hash>[]);
        const tokens = Array.from({ length: B }, () => [] as number[]);
        try {
          const requests = tokens.map((output, row) => {
            const length = [7, 17, 9, 19][row]!;
            const prompt = Array.from({ length }, (_, i) => 40 + row + i), positions = state(length, row);
            using ids = ops.fromInt32(prompt, [1, length]);
            const embeddings = model.embed.encode(ids); owned.push(embeddings);
            const input = reference ? { ...bindEmbeddingsInput((ids, caches) => {
              using nativePositions = mropePositionIds(positions, 0, ids.shape[1]!);
              return model.forwardEmbeddingsAtPositions(embeddings, caches, nativePositions);
            }), decodeState: referenceDecode(positions.delta) } : bindQwenMediaInput(model, embeddings, positions);
            return group.submit({ promptIds: prompt, promptInput: input,
              maxTokens: [12, 8, 10, 9][row]!, eosTokenIds: [],
              sample(value, step) { logits[row]!.push(hash(value)); return ops.fromInt32([123 + row * 20 + step], [1]); },
              onToken(token) { output.push(token); },
            });
          });
          held = false; group.kick();
          await Promise.all(requests);
          expect(Math.max(...widths)).toBe(B);
          expect(widths.at(-1)).toBe(1);
          expect(model.mrope).toBeNull();
          arms.push({ logits, tokens, widths });
        } finally {
          await group.close(); model.forwardHiddenAtPositions = original;
          for (const value of owned) value.dispose();
        }
      }
      expect(arms[1]).toEqual(arms[0]);
    }, 120_000);
  }
});
