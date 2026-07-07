// Promotes the DSpark CPU smoke (scripts/dspark-dflash-smoke.ts — KV-injection
// forward, autograd, inference, Alg-1 pruning, multi-layer data round-trip)
// into the model-free suite: spawn it, require a clean exit. The script is
// kept runnable standalone (its console output is the debugging surface); this
// wrapper just makes CI own it. Deeper per-component gates live in
// tests/dspark-{rnn,calibration,infer-loop}.test.ts.

import { expect, test } from "bun:test";

test("dspark dflash CPU smoke exits green", async () => {
  const proc = Bun.spawn(["bun", "scripts/dspark-dflash-smoke.ts"], {
    cwd: `${import.meta.dir}/..`,
    stdout: "pipe",
    stderr: "pipe",
  });
  const [code, out] = await Promise.all([proc.exited, new Response(proc.stdout).text()]);
  expect(out).toContain("0 failed");
  expect(code).toBe(0);
}, 120_000);
