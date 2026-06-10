// KV-cache persistence (slow tier): save → load (zero-copy mmap) →
// continuation must be token-identical; loading + first token must meet
// the Phase 5 cold-start criterion (< 1s for a cached-prefix prompt).

import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();
const haveGoldens = await Bun.file("goldens/parity.json").exists();

describe.skipIf(!haveWeights || !haveGoldens)("kv-cache persistence", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await Bun.file("goldens/parity.json").json()) as {
    prompt_ids: number[];
    greedy_ids: number[];
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model } = await import("../src/model/gemma4");
  const { generate } = await import("../src/generate");
  const { saveKvCache, loadKvCache, readKvHeader } = await import("../src/kv-store");
  const ops = await import("../src/mlx/ops");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new Gemma4Model(weights, config);
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-kv-"));

  test("save → load → continuation is token-identical; TTFT < 1s", async () => {
    // prefill the prompt and persist the caches
    const caches = model.makeCache();
    const ids = ops.fromInt32(golden.prompt_ids, [1, golden.prompt_ids.length]);
    const h = model.forwardHidden(ids, caches);
    ops.evalAll(caches.flatMap((c) => c.state()));
    h.dispose();
    ids.dispose();
    const file = join(dir, "prefix.mlxkv");
    saveKvCache(file, golden.prompt_ids, caches);
    for (const c of caches) c.dispose();

    const header = readKvHeader(file);
    expect(header.tokens).toEqual(golden.prompt_ids);
    expect(header.caches).toHaveLength(48);

    // reload zero-copy and continue with one extra token (the harness
    // prompt + first greedy token) — must match the golden sequence
    const t0 = performance.now();
    const loaded = loadKvCache(file, model);
    const prompt = [...golden.prompt_ids, golden.greedy_ids[0]!];
    const gen = generate(model, prompt, {
      maxTokens: 12, temperature: 0, cache: loaded.caches,
    });
    const out: number[] = [];
    let ttftMs = 0;
    for await (const t of gen) {
      if (out.length === 0) ttftMs = performance.now() - t0;
      out.push(t.token);
    }
    expect(gen.stats!.cachedTokens).toBe(golden.prompt_ids.length);
    expect(out).toEqual(golden.greedy_ids.slice(1, 13));

    console.log(`    cold cache-load → first token: ${ttftMs.toFixed(0)} ms`);
    // in-suite bound is loose (GPU pressure from prior tests inflates it);
    // the real criterion harness is scripts/cold-start.ts in a fresh process
    expect(ttftMs).toBeLessThan(3000);

    for (const c of loaded.caches) c.dispose();
    loaded.mmap.unmap();
    rmSync(dir, { recursive: true, force: true });
  }, 240_000);
});
