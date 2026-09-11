import { expect, test } from "bun:test";
import { NgramProvider } from "../../src/spec/ngram-source";
import { disposeAttachments } from "../../src/backends/mlx/checkpoint-state";
import { attachmentBytes } from "../../src/backends/mlx/checkpoint-state";
import { configureRuntime } from "../../src/runtime-config";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { saveKvCacheAsync, loadKvCache } from "../../src/kv-store";

test("integer history uses the streamed checkpoint writer and survives restoration", async () => {
  const directory = mkdtempSync(join(tmpdir(), "ngram-state-"));
  const provider = new NgramProvider({ max: 2 });
  const source = provider.open({ sampler: null as never, target: null as never });
  const tokens = [1, 2, 7, 8, 1];
  source.prefill(tokens, undefined, tokens.length);
  const attachment = source.checkpoint!.capture(tokens.length);
  try {
    await saveKvCacheAsync(join(directory, "state.kv"), tokens, [], { attachments: [attachment] });
    const restored = loadKvCache(join(directory, "state.kv"), { makeCache: () => [] });
    try {
      expect(restored.tokens).toEqual(tokens);
      expect(restored.attachments![0]!.tensors[0]!.toIntTokens()).toEqual(tokens);
      const group = provider.grouped.open({ target: null as never, sampling: null as never,
        checkpoints: [{ processedTokens: tokens.length, attachment: restored.attachments![0]! }] });
      try { expect(group.draft([2], 3, [0])).toEqual([[7, 8, 1]]); }
      finally { group.dispose(); }
    } finally { disposeAttachments(restored.attachments); }
  } finally {
    disposeAttachments([attachment]); source.dispose(); provider.dispose();
    rmSync(directory, { recursive: true, force: true });
  }
});

test("prompt lookup owns exact row histories through commit, reorder and checkpoint re-admission", () => {
  const provider = new NgramProvider({ max: 2 });
  const seed = (tokens: number[]) => {
    const source = provider.open({ sampler: null as never, target: null as never });
    source.prefill(tokens, undefined, tokens.length);
    const checkpoint = { processedTokens: tokens.length, attachment: source.checkpoint!.capture(tokens.length) };
    source.dispose(); return checkpoint;
  };
  const seeds = [[1, 2, 7, 8, 1], [10, 11], [5, 6, 9, 5]].map(seed);
  const group = provider.grouped.open({ target: null as never, sampling: null as never, checkpoints: seeds });
  disposeAttachments(seeds.map(seed => seed.attachment));
  const original = group.capture(0);
  try {
    expect(group.rowCount).toBe(3);
    expect(group.draft([2, 12, 6], 3, [0, 0, 0])).toEqual([[7, 8, 1], [], [9, 5, 6]]);
    group.commit([2, 0, 1], null as never);
    const expected = [[1, 2, 7, 8, 1, 2, 7, 8], [10, 11, 12], [5, 6, 9, 5, 6, 9]];
    for (let row = 0; row < 3; row++) {
      const state = group.capture(row);
      try {
        expect(state.processedTokens).toBe(expected[row]!.length);
        expect(state.attachment.tensors[0]!.toIntTokens()).toEqual(expected[row]!);
        expect(attachmentBytes([state.attachment])).toBe(4 * expected[row]!.length);
      } finally { disposeAttachments([state.attachment]); }
    }
    expect(original.attachment.tensors[0]!.toIntTokens()).toEqual([1, 2, 7, 8, 1]);
    group.filterRows([2, 0]);
    const held = [group.capture(0), group.capture(1)];
    try {
      group.filterRows([]); expect(group.rowCount).toBe(0);
      group.append(held); expect(group.rowCount).toBe(2);
      expect(group.draft([5, 1], 2, [0, 0])).toEqual([[6, 9], [2, 7]]);
      group.commit([0, 1], null as never);
      expect(held.map(state => state.attachment.tensors[0]!.toIntTokens())).toEqual([expected[2]!, expected[0]!]);
      const pending = seed([20, 21]);
      try {
        const change = group.prepareAppend([pending]);
        change.dispose(); expect(group.rowCount).toBe(2);
      } finally { disposeAttachments([pending.attachment]); }
    } finally { disposeAttachments(held.map(state => state.attachment)); }
  } finally { disposeAttachments([original.attachment]); group.dispose(); provider.dispose(); }
});

test("prompt lookup captures request prefill policy and accepts explicit processed coverage", () => {
  const provider = new NgramProvider();
  const original = configureRuntime({ MLX_BUN_PREFILL_TAIL_SPLIT: "1" });
  try {
    const source = provider.open({ sampler: null as never, target: null as never });
    const changed = configureRuntime({ MLX_BUN_PREFILL_TAIL_SPLIT: "0" });
    try {
      source.prefill([1, 2, 3]);
      const tail = source.checkpoint!.capture(2);
      try { expect(tail.tensors[0]!.toIntTokens()).toEqual([1, 2]); }
      finally { disposeAttachments([tail]); }
      source.prefill([1, 2, 3], undefined, 3);
      const full = source.checkpoint!.capture(3);
      try { expect(full.tensors[0]!.toIntTokens()).toEqual([1, 2, 3]); }
      finally { disposeAttachments([full]); }
    } finally { changed(); source.dispose(); }
  } finally { original(); provider.dispose(); }
});
