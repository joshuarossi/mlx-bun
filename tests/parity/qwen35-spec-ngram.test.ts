// Serve-loop speculation on a gated-DeltaNet (qwen3_5 hybrid) target — the
// real-weights gate for the SSMCache spec-round snapshot/replay contract that
// unblocks native Qwen MTP (slow tier; auto-skips without Qwen3.5-0.8B).
//
// Before that contract, the serve loop's eligibility gate saw the 48
// non-trimmable SSM caches and refused to speculate on this family at all.
// Now every partial-reject round restores the recurrent snapshot and replays
// the accepted prefix bit-exactly, so the gate is the strongest one we have:
// spec output must be TOKEN-IDENTICAL to the non-spec greedy baseline, and
// the stats must prove rollbacks actually happened (rejected > 0 — a run
// that never rolled back wouldn't test the new machinery).
//
// The drafter is the model-free ngram source (zero weights, lossless by
// verify), so this gate needs no MTP artifact; the native-MTP pairing gate is
// tests/qwen38-mtp.test.ts.

import { describe, expect, test } from "bun:test";
import { SNAPSHOT_QWEN35_08B, snapshotQwen35_08bAvailable } from "../support/paths";
import { NgramProvider } from "../../src/spec/ngram-source";

const have = await snapshotQwen35_08bAvailable();

describe.skipIf(!have)("serve-loop spec on qwen3_5 (SSM rollback, 0.8B)", async () => {
  if (!have) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { generate } = await import("../../src/generate");
  const { specServeRun } = await import("../../src/spec/serve-loop");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");

  const config = await loadModelConfig(SNAPSHOT_QWEN35_08B);
  const model = new Qwen35Model(await Weights.open(SNAPSHOT_QWEN35_08B), config);
  const tok = await loadTokenizer(SNAPSHOT_QWEN35_08B);
  const template = await ChatTemplate.load(SNAPSHOT_QWEN35_08B);

  const MAX_TOKENS = 64;
  const promptIds = (text: string): number[] => {
    const rendered = template.render(
      [{ role: "user", content: text }],
      { enableThinking: false },
    );
    const ids = tok.encode(rendered);
    return ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
  };

  const baseline = async (ids: number[]): Promise<number[]> => {
    const gen = generate(model, ids, { maxTokens: MAX_TOKENS, temperature: 0 });
    const ref: number[] = [];
    for await (const t of gen) ref.push(t.token);
    return ref;
  };

  const serveSpec = async (ids: number[], gamma: number) => {
    const out: number[] = [];
    const stats = await specServeRun(
      model, new NgramProvider(), gamma, ids,
      { maxTokens: MAX_TOKENS, temperature: 0 },
      (token: number) => { out.push(token); },
    );
    return { out, stats };
  };

  // Tie-free prompt (spec-serve convention) — batched verify == stock greedy,
  // so any flip is a rollback/replay/history bug.
  const EXACT_PROMPT = "List the planets of the solar system in order from the Sun.";
  // Echo prompt — prompt-lookup's best case: matches land, accepts AND
  // mid-window rejects follow, which is what drives real SSM rollbacks.
  const ECHO_PROMPT =
    "Repeat the following sentence exactly, twice, nothing else: " +
    "'The quick brown fox jumps over the lazy dog.'";

  for (const gamma of [3, 10]) {
    test(`γ=${gamma}: spec == non-spec greedy on the SSM target (lossless)`, async () => {
      const ids = promptIds(EXACT_PROMPT);
      const ref = await baseline(ids);
      const { out, stats } = await serveSpec(ids, gamma);
      expect(out).toEqual(ref);
      expect(stats.spec!.accepted).toBeLessThanOrEqual(stats.spec!.drafted);
    }, 600_000);
  }

  test("echo prompt: lossless with real accepts AND real rollbacks", async () => {
    const ids = promptIds(ECHO_PROMPT);
    const ref = await baseline(ids);
    const { out, stats } = await serveSpec(ids, 10);
    expect(out).toEqual(ref);
    const spec = stats.spec!;
    expect(spec.drafted).toBeGreaterThan(0);
    expect(spec.accepted).toBeGreaterThan(0);
    // The point of this gate: at least one round rejected a drafted suffix,
    // i.e. the SSM caches restored their snapshot and replayed the kept
    // prefix — and the stream still matched the baseline exactly.
    expect(spec.rejected).toBeGreaterThan(0);
  }, 600_000);

  test("the bound speculative method preserves output and acceptance trace through a portable session", async () => {
    const { createInferenceEngine } = await import("../../src/engine/engine");
    const { createSpeculativeMethod } = await import("../../src/backends/mlx/methods");
    const { bindLegacySpeculativeModel } = await import("../../src/backends/mlx/speculative");
    const ids = promptIds(ECHO_PROMPT);
    const expected = await serveSpec(ids, 10);
    const method = createSpeculativeMethod(bindLegacySpeculativeModel(model, new NgramProvider()),
      10, ids, { maxTokens: MAX_TOKENS, temperature: 0 });
    const engine = createInferenceEngine({ async plan() {
      return { id: "qwen-spec", outputTokenLimit: MAX_TOKENS, method };
    } }, { timer: { after(ms, callback) { const id = setTimeout(callback, ms); return () => clearTimeout(id); } } });
    try {
      const result = await (await engine.open({}, { output: "collect" })).result;
      expect(result.status).toBe("completed");
      if (result.status !== "completed") throw new Error(JSON.stringify(result));
      expect([...result.output!]).toEqual(expected.out);
      expect(result.result.metrics.spec).toEqual(expected.stats.spec);
    } finally { await engine.close(); }
  }, 180_000);
});
