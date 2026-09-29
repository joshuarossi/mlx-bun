import { expect, test } from "bun:test";
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

// The 1MAD decode arithmetic and the launch shape are numerics-critical: every
// kernel must share one definition instead of carrying an inline copy.
const dir = join(import.meta.dir, "../../src/kernels/trellis");
const sources = readdirSync(dir).filter((f) => f.endsWith(".ts"))
  .map((file) => ({ file, text: readFileSync(join(dir, file), "utf8") }));

test("the 1MAD multiplier, offset and scale live only in the shared codebook", () => {
  for (const literal of ["34038481", "76625530", "147.800537109375"]) {
    const holders = sources.filter((s) => s.text.includes(literal)).map((s) => s.file);
    expect(holders, literal).toEqual(["codebook.ts"]);
  }
});

test("launch constants are declared once and no kernel bakes in the thread count", () => {
  const declares = sources.filter((s) => /\b(?:TRELLIS_)?(?:THREADS|SG_PER_TG)\s*=/.test(s.text)).map((s) => s.file);
  expect(declares).toEqual(["launch.ts"]);
  expect(sources.filter((s) => /\b128u\b/.test(s.text)).map((s) => s.file)).toEqual([]);
});
