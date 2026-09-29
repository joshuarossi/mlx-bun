// The generated Gemma4 graphs are compiled from a model description by
// scripts/gen-gemma4.ts. This regenerates every registered graph from the
// committed hub-layout inputs (tests/fixtures/gemma4-graphs: config.json,
// kv_config.json, and the index names the generator reads; no weights) into a
// temp directory and fails when a committed file differs, so a change to the
// generator or to the graph it transcribes cannot leave a stale specialization.
// Whether a regenerated graph is numerically identical is the real-weight
// tests/parity/gemma4-generated.test.ts.
import { expect, test } from "bun:test";
import { cpSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { GEMMA4_GRAPHS, GENERATED_DIR, type Gemma4GraphStem } from "../../scripts/gen-gemma4";
import { GENERATED } from "../../src/models/gemma4/generated";

const FIXTURES = join(import.meta.dir, "../fixtures/gemma4-graphs");
const SCRIPT = join(import.meta.dir, "../../scripts/gen-gemma4.ts");
const stems = Object.keys(GEMMA4_GRAPHS) as Gemma4GraphStem[];
const REPO = { "gemma4-12b": "gemma-4-12B-it-OptiQ-4bit", "gemma4-e4b": "gemma-4-e4b-it-OptiQ-4bit", "gemma4-26b": "gemma-4-26B-A4B-it-OptiQ-4bit" } as const;

/** The hub-layout snapshot directory holding a stem's inputs. */
function snapshot(stem: Gemma4GraphStem, root = FIXTURES): string {
  const repo = join(root, `models--mlx-community--${REPO[stem]}`, "snapshots");
  const [hash] = readdirSync(repo);
  return join(repo, hash!);
}

async function run(...args: string[]) {
  const child = Bun.spawn([process.execPath, SCRIPT, ...args], { stdout: "pipe", stderr: "pipe" });
  const [stdout, stderr, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
  return { stdout, stderr, code };
}

test("every registered generated graph equals what the generator emits from its committed inputs", async () => {
  const out = mkdtempSync(join(tmpdir(), "gen-gemma4-"));
  try {
    for (const stem of stems) {
      const result = await run(snapshot(stem), stem, "--out", out);
      expect({ stem, code: result.code, stderr: result.stderr }).toEqual({ stem, code: 0, stderr: "" });
      const committed = readFileSync(join(GENERATED_DIR, `${stem}.ts`), "utf8");
      const regenerated = readFileSync(join(out, `${stem}.ts`), "utf8");
      // A diff here means: run `bun packages/inference/scripts/gen-gemma4.ts <snapshot> ${stem}` (the
      // fixture snapshot works) and re-run tests/parity/gemma4-generated.test.ts on real weights.
      expect({ stem, current: regenerated === committed }).toEqual({ stem, current: true });
    }
  } finally { rmSync(out, { recursive: true, force: true }); }
});

test("the registry serves exactly the generated files, each keyed by the fingerprint it declares", async () => {
  expect(readdirSync(GENERATED_DIR).filter(file => file !== "index.ts").sort()).toEqual(stems.map(stem => `${stem}.ts`).sort());
  const { GENERATED_GEMMA_FINGERPRINTS } = await import("../../src/models/profile");
  expect([...GENERATED.keys()].sort()).toEqual(Object.values(GENERATED_GEMMA_FINGERPRINTS).sort());
  for (const stem of stems) {
    const module = await import(`../../src/models/gemma4/generated/${stem}`);
    expect(module.FINGERPRINT).toBe(GENERATED_GEMMA_FINGERPRINTS[GEMMA4_GRAPHS[stem]]);
    expect(GENERATED.get(module.FINGERPRINT)).toBe(module.GeneratedGemma4);
    // Capabilities are declared once, by Gemma4Model; a specialization only overrides its forward pass.
    expect(Object.getOwnPropertyNames(module.GeneratedGemma4.prototype).sort()).toEqual(["constructor", "forwardLayers"]);
  }
});

test("a description whose fingerprint is not the registered one is refused", async () => {
  const root = mkdtempSync(join(tmpdir(), "gen-gemma4-drift-"));
  try {
    cpSync(FIXTURES, root, { recursive: true });
    const dir = snapshot("gemma4-e4b", root);
    const kv = JSON.parse(readFileSync(join(dir, "kv_config.json"), "utf8"));
    kv[0].bits = kv[0].bits === 4 ? 8 : 4;
    writeFileSync(join(dir, "kv_config.json"), JSON.stringify(kv));
    const result = await run(dir, "gemma4-e4b", "--out", root);
    expect(result.code).not.toBe(0);
    expect(result.stderr).toContain("is not the registered");
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("--help prints usage without a model; unknown stems and missing arguments exit non-zero", async () => {
  const help = await run("--help");
  expect(help.code).toBe(0);
  expect(help.stdout).toContain("Usage: bun packages/inference/scripts/gen-gemma4.ts <model-dir>");
  for (const args of [[], [snapshot("gemma4-12b")], [snapshot("gemma4-12b"), "gemma4-nope"]]) {
    const result = await run(...args);
    expect({ args: args.length, code: result.code }).toEqual({ args: args.length, code: 1 });
    expect(result.stderr).toContain("Usage:");
  }
});
