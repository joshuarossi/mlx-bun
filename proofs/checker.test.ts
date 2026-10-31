import { expect, test } from "bun:test";
import { localImports } from "./build.ts";
import { moduleKeys } from "./checker.ts";
import { isFullChooser, moduleKeysFull } from "./host/load/nativeFull.ts";

const keys = (sources: Map<string, string>, base = "base") => moduleKeys(sources, localImports(sources), base);

test("a key changes with the module, its imports and the checker, and nothing else", () => {
  const sources = new Map([
    ["Joined.lean", "import Left Right\n"],
    ["Left.lean", "import Mathlib.Data.Nat.Basic\n"],
    ["Right.lean", "theorem t : True := trivial\n"],
  ]);
  const before = keys(sources);
  const left = keys(new Map([...sources, ["Left.lean", "import Mathlib.Data.Nat.Basic\n-- edit\n"]]));
  expect(left.get("Left.lean")).not.toBe(before.get("Left.lean"));
  expect(left.get("Joined.lean")).not.toBe(before.get("Joined.lean"));
  expect(left.get("Right.lean")).toBe(before.get("Right.lean"));
  const checker = keys(sources, "other");
  for (const file of sources.keys()) expect(checker.get(file)).not.toBe(before.get(file));
});

test("state choosers depend on the native chooser", () => {
  const sources = new Map([
    ["host/load/Native.lean", "def native := 0\n"],
    ["host/load/Chooser.lean", "host_stream s : x\n"],
    ["host/load/Plain.lean", "def plain := 0\n"],
  ]);
  const before = keys(sources);
  const after = keys(new Map([...sources, ["host/load/Native.lean", "def native := 1\n"]]));
  expect(after.get("host/load/Chooser.lean")).not.toBe(before.get("host/load/Chooser.lean"));
  expect(after.get("host/load/Plain.lean")).toBe(before.get("host/load/Plain.lean"));
});

test("full-world chooser selection recognizes Lean escaped options and excludes the load world", () => {
  const file = "host/sim/template/SplitStates.lean";
  for (const option of ["world := full", "«world» := full", "«world» := «full»"]) {
    expect(isFullChooser(file, `tpl_chain P from s, S : "{}" (${option})\n`)).toBe(true);
  }
  for (const option of ["world := lf", "«world» := lf", "«world» := «lf»"]) {
    expect(isFullChooser(file, `tpl_chain P from s, S : "{}" (${option})\n`)).toBe(false);
  }
  expect(isFullChooser(file, 'tpl_chain P from s, S : "{}"\n')).toBe(false);
  expect(isFullChooser("other/SplitStates.lean", 'tpl_chain P from s, S : "{}" («world» := full)\n')).toBe(false);
});

test("escaped full-world choosers and their dependents are keyed by the full native library", () => {
  const sources = new Map([
    ["host/load/NativeFull.lean", "def nativeFull := 0\n"],
    ["host/sim/SplitStates.lean", 'tpl_chain P from s, S : "{}" («world» := full)\n'],
    ["host/sim/SplitProof.lean", "import host.sim.SplitStates\n"],
    ["host/sim/LoadStates.lean", 'tpl_chain P from s, S : "{}" («world» := lf)\n'],
  ]);
  const keysFor = (s: Map<string, string>) => moduleKeysFull(s, localImports(s), "base", "builder");
  const before = keysFor(sources);
  const after = keysFor(new Map([...sources, ["host/load/NativeFull.lean", "def nativeFull := 1\n"]]));
  expect(after.get("host/sim/SplitStates.lean")).not.toBe(before.get("host/sim/SplitStates.lean"));
  expect(after.get("host/sim/SplitProof.lean")).not.toBe(before.get("host/sim/SplitProof.lean"));
  expect(after.get("host/sim/LoadStates.lean")).toBe(before.get("host/sim/LoadStates.lean"));
});
