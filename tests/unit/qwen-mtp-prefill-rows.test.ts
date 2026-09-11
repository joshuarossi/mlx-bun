import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { QwenMtpRows, type MtpRowState } from "../../src/spec/qwen-mtp-rows";
import type { MtpModule } from "../../src/spec/qwen-mtp-module";
import type { Cache } from "../../src/model/gemma4-base";

function fixture() {
  const forwards: number[][] = [];
  const target = { hiddenSize: 1, layerCount: 1,
    embed(ids: MlxArray) {
      using floats = ids.astype(Dtype.float32);
      return ops.reshape(floats, [...ids.shape, 1]);
    },
    logitsFromHidden(): MlxArray { throw new Error("prefill must not sample or project logits"); },
  };
  const module = { forward(embeds: MlxArray, hidden: MlxArray, cache: Cache) {
    forwards.push([...embeds.shape]);
    const [B, N] = embeds.shape;
    using k = ops.reshape(embeds, [B!, 1, N!, 1]);
    using v = ops.reshape(hidden, [B!, 1, N!, 1]);
    for (const view of cache.updateAndFetch(k, v)) view.dispose();
    return ops.copyOf(hidden);
  } } as MtpModule;
  const rows = new QwenMtpRows(target, module, null, []);
  const feed = (tokens: number[][], hiddens = tokens.map(row => row.map(token => token * 10))) => {
    using ids = ops.fromInt32(tokens.flat(), [tokens.length, tokens[0]!.length]);
    using context = MlxArray.fromFloat32(Float32Array.from(hiddens.flat()), [tokens.length, tokens[0]!.length, 1]);
    rows.prefill(ids, context);
    expect(ids.toIntTokens()).toEqual(tokens.flat());
    expect([...context.toFloat32Host()]).toEqual(hiddens.flat());
  };
  const inspect = (row: number, tokens: number[], hidden: number[], pending: number) => {
    const state = rows.extractRow(row);
    try {
      expect(state.cache.offset).toBe(tokens.length);
      using k = state.cache.keys?.slice([0, 0, 0, 0], [1, 1, tokens.length, 1]) ?? null;
      using v = state.cache.values?.slice([0, 0, 0, 0], [1, 1, tokens.length, 1]) ?? null;
      expect(k ? [...k.toFloat32Host()] : []).toEqual(tokens);
      expect(v ? [...v.toFloat32Host()] : []).toEqual(hidden);
      expect([...state.hidden.toFloat32Host()]).toEqual([pending]);
    } finally { state.cache.dispose(); state.hidden.dispose(); }
  };
  return { rows, feed, inspect, forwards };
}

test("MTP prefill shares the graph at B1/B3 and keeps the last true hidden outside companion KV", () => {
  for (const B of [1, 3]) {
    const { rows, feed, inspect, forwards } = fixture();
    try {
      rows.append(Array.from({ length: B }, () => null));
      feed(Array.from({ length: B }, (_, row) => [1, 2, 3].map(token => token + row * 10)));
      for (let row = 0; row < B; row++) inspect(row,
        [2, 3].map(token => token + row * 10), [10, 20].map(h => h + row * 100), 30 + row * 100);
      expect(forwards).toEqual([[B, 2, 1]]);
      feed(Array.from({ length: B }, (_, row) => [4 + row * 10]));
      for (let row = 0; row < B; row++) inspect(row,
        [2, 3, 4].map(token => token + row * 10), [10, 20, 30].map(h => h + row * 100), 40 + row * 100);
      expect(forwards.at(-1)).toEqual([B, 1, 1]);
    } finally { rows.dispose(); }
  }
});

test("cold late arrivals retain no bridge row; checkpoints survive retirement, reorder and resume", () => {
  const { rows, feed, inspect, forwards } = fixture();
  let donor: MtpRowState | undefined;
  try {
    rows.append([null]); feed([[1, 2, 3]]);
    donor = rows.extractRow(0);
    rows.append([null, donor]);
    feed([[4, 5], [11, 12], [4, 5]]);
    inspect(0, [2, 3, 4, 5], [10, 20, 30, 40], 50);
    inspect(1, [12], [110], 120);
    inspect(2, [2, 3, 4, 5], [10, 20, 30, 40], 50);
    expect(forwards.slice(-2)).toEqual([[3, 1, 1], [3, 1, 1]]);
    rows.filterRows([1, 0]); feed([[13], [6]]);
    inspect(0, [12, 13], [110, 120], 130);
    inspect(1, [2, 3, 4, 5, 6], [10, 20, 30, 40, 50], 60);
    expect([...donor.hidden.toFloat32Host()]).toEqual([30]);
    expect(donor.cache.offset).toBe(2);
    rows.filterRows([]); rows.append([donor]); feed([[4]]);
    inspect(0, [2, 3, 4], [10, 20, 30], 40);
  } finally { rows.dispose(); donor?.cache.dispose(); donor?.hidden.dispose(); }
});

test("a one-token cold prefix has only a hidden row and can retire before any draft KV allocation", () => {
  const { rows, feed, inspect, forwards } = fixture();
  try {
    rows.append([null, null]); rows.filterRows([1]); feed([[7]]);
    inspect(0, [], [], 70); expect(forwards).toEqual([]);
    rows.append([null]); feed([[8], [9]]);
    inspect(0, [8], [70], 80); inspect(1, [], [], 90);
    rows.filterRows([1]); feed([[10]]); inspect(0, [10], [90], 100);
  } finally { rows.dispose(); }
});

test("discarding a prepared cold join leaves committed membership and hidden state intact", () => {
  const { rows, feed, inspect } = fixture();
  try {
    rows.append([null]); feed([[1, 2]]);
    const change = rows.prepareAppend([null, null]); change.dispose();
    expect(rows.rowCount).toBe(1); inspect(0, [2], [10], 20);
    feed([[3]]); inspect(0, [2, 3], [10, 20], 30);
  } finally { rows.dispose(); }
});
