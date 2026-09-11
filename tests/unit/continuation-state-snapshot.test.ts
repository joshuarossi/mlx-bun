import { expect, test } from "bun:test";
import { cloneSingleRowState } from "../../src/backends/mlx/state-views";
import { KVCache, type Cache } from "../../src/model/gemma4-base";
import { legacyCacheCodecs } from "../../src/kv-store";

function rowLayout(extract: (row: number) => Cache) {
  return Object.assign(new KVCache(), {
    makeEmptyBatch() { throw new Error("unused"); }, mergeRows() {}, filterRows() {},
    projectedBytes: () => 0, rowOffsets: [16], leftPad: [0], extractRow: extract,
    signature: () => "fixture:live-row-layout-without-persistence-codec",
  });
}

test("adopted row snapshots extract compact state and retain reuse boundary without cloning the live wrapper", () => {
  let extracts = 0;
  const row = rowLayout(index => {
    expect(index).toBe(0); extracts++;
    const result: Cache = new KVCache(); result.minimumReusableOffset = 14; return result;
  });
  const ordinary = new KVCache();
  const snapshot = cloneSingleRowState([row, ordinary], legacyCacheCodecs);
  expect(extracts).toBe(1);
  expect(snapshot).toHaveLength(2);
  expect(snapshot[0]!.minimumReusableOffset).toBe(14);
  expect(snapshot[0]).not.toBe(row);
  expect(snapshot[1]).not.toBe(ordinary);
  snapshot.forEach(cache => cache.dispose()); row.dispose(); ordinary.dispose();
});

test("later row extraction failure releases preceding snapshot ownership without disposing live inputs", () => {
  let disposedSnapshot = 0, disposedLive = 0;
  const first = rowLayout(() => Object.assign(new KVCache(), { dispose() { disposedSnapshot++; } }));
  const second = rowLayout(() => { throw new Error("extraction failed"); });
  first.dispose = second.dispose = () => { disposedLive++; };
  expect(() => cloneSingleRowState([first, second], legacyCacheCodecs)).toThrow("extraction failed");
  expect(disposedSnapshot).toBe(1);
  expect(disposedLive).toBe(0);
});
