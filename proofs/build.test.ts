import { expect, test } from "bun:test";
import { buildProofs } from "./build.ts";

test("imports finish before consumers while independent proofs overlap", async () => {
  const left = Promise.withResolvers<void>();
  const right = Promise.withResolvers<void>();
  const started = Promise.withResolvers<void>();
  const events: string[] = [];
  const sources = new Map([
    ["Joined.lean", "import Left Right\n"],
    ["Left.lean", "import Mathlib.Data.Nat.Basic\n"],
    ["Right.lean", "import Lean\n"],
  ]);
  const result = buildProofs(sources, 2, async file => {
    events.push("start " + file);
    if (events.length === 2) started.resolve();
    if (file === "Left.lean") await left.promise;
    if (file === "Right.lean") await right.promise;
    events.push("end " + file);
  });
  await started.promise;
  expect(events).toEqual(["start Left.lean", "start Right.lean"]);
  left.resolve(); right.resolve();
  await result;
  expect(events.indexOf("start Joined.lean")).toBeGreaterThan(events.indexOf("end Left.lean"));
  expect(events.indexOf("start Joined.lean")).toBeGreaterThan(events.indexOf("end Right.lean"));
});

test("failure blocks dependents and waits for active checks before cleanup", async () => {
  const active = Promise.withResolvers<void>();
  const started = Promise.withResolvers<void>();
  const failure = new Error("rejected proof");
  const events: string[] = [];
  let settled = false;
  const result = buildProofs(new Map([
    ["Bad.lean", ""], ["Active.lean", ""], ["Child.lean", "import Bad"],
  ]), 2, async file => {
    events.push(file);
    if (file === "Bad.lean") throw failure;
    started.resolve();
    await active.promise;
  }).then(() => { throw new Error("unexpected success"); }, error => { settled = true; return error; });
  await started.promise;
  await Promise.resolve();
  expect(settled).toBe(false);
  active.resolve();
  expect(await result).toBe(failure);
  expect(events).toEqual(["Bad.lean", "Active.lean"]);
});

test("cycles and invalid concurrency fail rather than silently skipping proofs", async () => {
  await expect(buildProofs(new Map([["A.lean", "import B"], ["B.lean", "import A"]]), 2,
    async () => { throw new Error("cycle launched"); })).rejects.toThrow("Local proof import cycle");
  await expect(buildProofs(new Map(), 0, async () => {})).rejects.toThrow("integer from 1 to 64");
});
