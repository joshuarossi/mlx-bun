import { expect, test } from "bun:test";
import { SpeculativePrefixStore, type SpeculativePrefixState } from "../../src/spec/prefix-state";

const targetIdentity = {};
function entry(tokens = [1, 2, 3], namespace = "base", bytes = 100) {
  return { tokens, namespace, bytes, targetIdentity, target: [], disposed: 0,
    dispose() { this.disposed++; } } satisfies SpeculativePrefixState & { disposed: number };
}

test("an exact prefix transfers ownership without reusing it twice", () => {
  const store = new SpeculativePrefixStore<ReturnType<typeof entry>>(), state = entry();
  store.put(state, 200);
  expect(store.take([1, 2, 3, 4], targetIdentity, "base", 200)).toBe(state);
  store.dispose();
  expect(state.disposed).toBe(0);
  expect(store.take([1, 2, 3, 5], targetIdentity, "base", 200)).toBeNull();
  state.dispose();
  expect(state.disposed).toBe(1);
});

test("mismatched or non-extending history, target, namespace and budget miss safely", () => {
  for (const [prompt, identity, namespace, budget] of [
    [[1, 2, 9, 4], targetIdentity, "base", 200],
    [[1, 2, 3], targetIdentity, "base", 200],
    [[1, 2, 3, 4], {}, "base", 200],
    [[1, 2, 3, 4], targetIdentity, "adapter", 200],
    [[1, 2, 3, 4], targetIdentity, "base", 99],
  ] as const) {
    const store = new SpeculativePrefixStore<ReturnType<typeof entry>>(), state = entry();
    store.put(state, 200);
    expect(store.take(prompt, identity, namespace, budget)).toBeNull();
    store.dispose();
    expect(state.disposed).toBe(1);
  }
});

test("replacement, over-budget entry and shutdown release their own state", () => {
  const store = new SpeculativePrefixStore<ReturnType<typeof entry>>();
  const a = entry(), b = entry([1, 2, 3, 4]), c = entry([9], "base", 300);
  store.put(a, 200); store.put(b, 200);
  expect(a.disposed).toBe(1);
  store.put(c, 200);
  expect(b.disposed).toBe(1); expect(c.disposed).toBe(1);
  store.dispose(); store.dispose();
  expect(c.disposed).toBe(1);
});

test("a failed replacement destructor still releases the incoming state", () => {
  const store = new SpeculativePrefixStore<ReturnType<typeof entry>>(), next = entry();
  store.put({ ...entry(), dispose() { throw new Error("release"); } }, 200);
  expect(() => store.put(next, 200)).toThrow("release");
  expect(next.disposed).toBe(1);
});
