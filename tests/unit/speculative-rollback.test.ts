import { expect, test } from "bun:test";
import { bindCacheRollback } from "../../src/backends/mlx/rollback";
import type { Cache } from "../../src/model/gemma4-base";

const state = (extra: Partial<Cache> = {}): Cache => ({
  offset: 10, isTrimmable: () => true, trim() {}, ...extra,
}) as Cache;

test("partial accepts resolve recurrent and trimmable layers to the same prefix", () => {
  const events: string[] = [];
  const transaction = bindCacheRollback([
    state({ trim: (n) => events.push(`trim:${n}`) }),
    state({ isTrimmable: () => false,
      specRoundBegin: () => events.push("begin"),
      specRoundCommit: () => events.push("commit"),
      specRoundRollback: (n) => events.push(`replay:${n}`),
    }),
  ]);
  expect(transaction.canBegin(3)).toBe(true);
  transaction.begin(3);
  expect(transaction.canBegin(3)).toBe(false);
  transaction.resolve(1);
  expect(events).toEqual(["begin", "trim:2", "replay:2"]);
  transaction.begin(3); transaction.resolve(3);
  expect(events.slice(3)).toEqual(["begin", "commit"]);
});

test("partial recurrent facets are refused before forward execution", () => {
  expect(() => bindCacheRollback([state({ specRoundBegin() {} })]))
    .toThrow("incomplete speculative transaction");
});

test("a failed layer invalidates the whole transaction instead of permitting reuse", () => {
  for (const phase of ["begin", "resolve"] as const) {
    const fail = () => { throw new Error("layer failure"); };
    const transaction = bindCacheRollback([state({
      specRoundBegin: phase === "begin" ? fail : () => {},
      specRoundCommit: fail, specRoundRollback: fail,
    })]);
    if (phase === "resolve") transaction.begin(2);
    expect(() => phase === "begin" ? transaction.begin(2) : transaction.resolve(1))
      .toThrow("layer failure");
    expect(() => transaction.canBegin(1)).toThrow("must be discarded");
  }
});

test("ring capacity is checked at each safe boundary using the existing strict limit", () => {
  const ring = { ...state(), maxSize: 16 };
  const transaction = bindCacheRollback([ring]);
  expect(transaction.canBegin(4)).toBe(true);
  expect(transaction.canBegin(5)).toBe(false);
  ring.offset++;
  expect(transaction.canBegin(4)).toBe(false);
  expect(() => transaction.begin(4)).toThrow("cannot begin");
});
