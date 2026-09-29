import { afterEach, beforeEach, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync, utimesSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createKvBudget } from "../../src/engine/kv-budget";

let root = "";
beforeEach(() => { root = mkdtempSync(join(tmpdir(), "mlx-kv-budget-")); });
afterEach(() => rmSync(root, { recursive: true, force: true }));

/** A saved entry of `bytes` under `<root>/<model>/<ns>/`, last used `age` seconds ago. */
function entry(model: string, name: string, bytes: number, age: number): string {
  const dir = join(root, model, "base");
  mkdirSync(dir, { recursive: true });
  const path = join(dir, `${name}.mlxkv`);
  writeFileSync(path, new Uint8Array(bytes));
  const when = new Date(Date.now() - age * 1000);
  utimesSync(path, when, when);
  return path;
}

test("reclaim evicts the oldest files of idle model directories across models until the root fits, never a live store's", () => {
  const oldest = entry("a", "old", 400, 300), aNew = entry("a", "new", 400, 10);
  const bOld = entry("b", "old", 400, 200), live = entry("live", "x", 400, 1000);
  const budget = createKvBudget(root, 1_000);
  const member = budget.attach({ dir: join(root, "live"), bytes: () => 400 });
  expect(budget.usage()).toEqual({ bytes: 1_600, idleBytes: 1_200, maxBytes: 1_000 });
  // 1600 held, 1000 allowed: the two oldest idle files (300 s, then 200 s) go; the live directory's older file stays.
  expect(budget.reclaim()).toEqual({ removedFiles: 2, removedBytes: 800 });
  expect(existsSync(oldest)).toBe(false); expect(existsSync(bOld)).toBe(false);
  expect(existsSync(aNew)).toBe(true); expect(existsSync(live)).toBe(true);
  // The emptied directory is removed with its files; the live one is never pruned.
  expect(existsSync(join(root, "b"))).toBe(false); expect(existsSync(join(root, "a"))).toBe(true);
  expect(budget.usage()).toEqual({ bytes: 800, idleBytes: 400, maxBytes: 1_000 });
  member.detach();
});

test("a live store is lent what idle directories and other live stores leave, and never less than a quarter of the budget", () => {
  entry("idle", "x", 300, 5);
  const budget = createKvBudget(root, 1_000);
  let other = 200;
  const first = budget.attach({ dir: join(root, "first"), bytes: () => 0 });
  budget.attach({ dir: join(root, "second"), bytes: () => other });
  expect(first.limit()).toBe(500);
  other = 900;
  expect(first.limit()).toBe(250);
  // Detaching a store makes its directory idle: its files are counted from the next scan.
  const third = budget.attach({ dir: join(root, "third"), bytes: () => 0 });
  entry("third", "y", 100, 5);
  third.detach();
  other = 0;
  expect(first.limit()).toBe(600);
});

test("an unlimited budget lends every store Infinity and reclaims nothing", () => {
  entry("a", "x", 500, 5);
  const budget = createKvBudget(root);
  expect(budget.attach({ dir: join(root, "b"), bytes: () => 0 }).limit()).toBe(Infinity);
  expect(budget.reclaim()).toEqual({ removedFiles: 0, removedBytes: 0 });
  expect(budget.usage().bytes).toBe(500);
});

test("a missing root is empty, and a budget must be positive", () => {
  const budget = createKvBudget(join(root, "absent"), 100);
  expect(budget.reclaim()).toEqual({ removedFiles: 0, removedBytes: 0 });
  expect(budget.usage()).toEqual({ bytes: 0, idleBytes: 0, maxBytes: 100 });
  expect(() => createKvBudget(root, 0)).toThrow("positive");
});
