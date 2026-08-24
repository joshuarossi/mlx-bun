// NgramSource (model-free prompt-lookup drafting, src/spec/ngram-source.ts).
//
// Part 1 (model-free, always runs): the source's contract under the serve
// loop's feed/commit discipline — history reconstruction across rejected and
// all-accept rounds (mlx-lm's re-feed rule means the all-accept round's last
// draft arrives via the NEXT feed, not commit), tail-split vs legacy prefill
// shapes, and the reference matching order (longest k-gram first, first
// occurrence — Saxena / vLLM ngram proposer).
//
// Part 2 (slow tier; auto-skips without e4b): losslessness through the REAL
// verify/accept executor — serve-loop spec output TOKEN-IDENTICAL to the
// non-spec generate() baseline on the tie-free prompt (same gate + prompt as
// tests/spec-serve-assistant.test.ts), plus an echo prompt where lookup
// actually lands accepts.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { SNAPSHOT_E4B } from "../support/paths";
import { NgramProvider } from "../../src/spec/ngram-source";
import { configureRuntime } from "../../src/runtime-config";

type TestSource = ReturnType<NgramProvider["open"]> & { history: readonly number[] };

const openSource = (opts: { max?: number; min?: number } = {}): TestSource =>
  new NgramProvider(opts).open({
    sampler: () => { throw new Error("ngram never samples"); },
    target: null as never, // ignored by the source
  }) as TestSource;

describe("NgramSource contract (model-free)", () => {
  test("prefill + first feed reconstructs the full prompt (tail-split shape)", () => {
    const s = openSource();
    const prompt = [10, 20, 30, 40];
    s.prefill(prompt);
    expect([...s.history]).toEqual([10, 20, 30]); // last prompt token withheld
    s.draft([40], 5, 0); // first feed = [pending] = last prompt token
    expect([...s.history]).toEqual(prompt);
  });

  test("legacy shape (MLX_BUN_PREFILL_TAIL_SPLIT=0): full prompt at prefill", () => {
    const restore = configureRuntime({ MLX_BUN_PREFILL_TAIL_SPLIT: "0" });
    try {
      const s = openSource();
      s.prefill([10, 20, 30, 40]);
      expect([...s.history]).toEqual([10, 20, 30, 40]);
      s.draft([50], 5, 0); // legacy first feed = the sampled+emitted token0
      expect([...s.history]).toEqual([10, 20, 30, 40, 50]);
    } finally {
      restore();
    }
  });

  test("longest k-gram wins over a shorter earlier match", () => {
    // history after feed: [1, 2, 3, 9, 1, 2, 3]  (max=3)
    // k=3 tail [1,2,3] matches at i=0 → continuation [9, 1, 2, 3] — even
    // though k=1 tail [3] also matches (at i=2) with a different continuation.
    const s = openSource({ max: 3 });
    s.prefill([1, 2, 3, 9, 1, 2, 3]); // history = all but last
    expect(s.draft([3], 4, 0)).toEqual([9, 1, 2, 3]);
  });

  test("first occurrence is used when a k-gram repeats (reference order)", () => {
    // history after feed: [5, 6, 100, 5, 6, 200, 5, 6] — k=2 tail [5,6]
    // matches at i=0 first → continuation [100, 5], not the later [200, ...].
    const s = openSource({ max: 3 });
    s.prefill([5, 6, 100, 5, 6, 200, 5, 6]); // history = all but last (6)
    expect(s.draft([6], 2, 0)).toEqual([100, 5]);
  });

  test("no match → empty draft (d=0 round)", () => {
    const s = openSource();
    s.prefill([1, 2, 3, 4]);
    expect(s.draft([4], 5, 0)).toEqual([]);
  });

  test("continuation shorter than n → variable-length draft", () => {
    // history after feed: [7, 8, 42, 7, 8] — k=2 match at i=0; only 3
    // continuation tokens exist, so n=10 returns just those.
    const s = openSource({ max: 2 });
    s.prefill([7, 8, 42, 7, 8]);
    expect(s.draft([8], 10, 0)).toEqual([42, 7, 8]);
  });

  test("rejected round: accepted prefix joins history, correction via next feed", () => {
    const s = openSource({ max: 2 });
    s.prefill([1, 2, 7, 1, 2]);
    const drafts = s.draft([2], 3, 0); // history [1,2,7,1,2], k=2 [1,2]@0 → [7,1,2]
    expect(drafts).toEqual([7, 1, 2]);
    // serve loop: target accepted 1 of 3, correction token = 99
    s.commit(3, 1);
    expect([...s.history]).toEqual([1, 2, 7, 1, 2, 7]); // + accepted draft only
    s.draft([99], 3, 2); // next feed = [correction]
    expect([...s.history]).toEqual([1, 2, 7, 1, 2, 7, 99]);
  });

  test("all-accept round: last draft NOT doubled (re-feed rule)", () => {
    const s = openSource({ max: 2 });
    s.prefill([1, 2, 7, 8, 1, 2]);
    const drafts = s.draft([2], 2, 0); // history [1,2,7,8,1,2], k=2 [1,2]@0 → [7,8]
    expect(drafts).toEqual([7, 8]);
    // target accepted BOTH → serve loop re-feeds [lastDraft, bonus]
    s.commit(2, 2);
    expect([...s.history]).toEqual([1, 2, 7, 8, 1, 2, 7]); // drafts[0..d-1) only
    s.draft([8, 55], 2, 2); // feed = [drafts[1], bonus=55]
    expect([...s.history]).toEqual([1, 2, 7, 8, 1, 2, 7, 8, 55]);
  });

  test("d=0 commit is a no-op on history", () => {
    const s = openSource();
    s.prefill([1, 2, 3]);
    s.draft([3], 4, 0);
    const before = [...s.history];
    s.commit(0, 0);
    expect([...s.history]).toEqual(before);
  });

  test("provider clamps min <= max and both >= 1", () => {
    const p = new NgramProvider({ max: 2, min: 5 });
    expect(p.max).toBe(2);
    expect(p.min).toBe(2);
    const q = new NgramProvider({ max: 0, min: 0 });
    expect(q.max).toBe(1);
    expect(q.min).toBe(1);
  });
});

// ---- Part 2: real-weights losslessness through the serve loop ----

const have = existsSync(`${SNAPSHOT_E4B}/config.json`);

describe.skipIf(!have)("serve-loop NgramSource (e4b, model-free)", async () => {
  if (!have) return;
  const E4B = SNAPSHOT_E4B;

  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { Gemma4Model } = await import("../../src/model/gemma4");
  const { generate } = await import("../../src/generate");
  const { specServeRun } = await import("../../src/spec/serve-loop");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");

  const config = await loadModelConfig(E4B);
  const model = new Gemma4Model(await Weights.open(E4B), config);
  const tok = await loadTokenizer(E4B);
  const template = await ChatTemplate.load(E4B);

  const promptIds = (text: string): number[] => {
    const ids = tok.encode(template.render([{ role: "user", content: text }]));
    return ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
  };

  const baseline = async (ids: number[]): Promise<number[]> => {
    const gen = generate(model, ids, { maxTokens: 80, temperature: 0 });
    const ref: number[] = [];
    for await (const t of gen) ref.push(t.token);
    return ref;
  };

  const serveSpec = async (ids: number[], gamma: number) => {
    const out: number[] = [];
    const stats = await specServeRun(
      model, new NgramProvider(), gamma, ids,
      { maxTokens: 80, temperature: 0 },
      (token: number) => { out.push(token); },
    );
    return { out, stats };
  };

  // Tie-free prompt (same as spec-serve-assistant.test.ts) — batched verify
  // == stock greedy, so any flip is an accept/reject/history bug.
  const EXACT_PROMPT = "List the planets of the solar system in order from the Sun.";
  // Echo prompt — prompt-lookup's best case; the copied span guarantees
  // matches land and accepts follow.
  const ECHO_PROMPT =
    "Repeat the following sentence exactly, twice, nothing else: " +
    "'The quick brown fox jumps over the lazy dog.'";

  for (const gamma of [3, 10]) {
    test(`γ=${gamma}: serve-loop ngram spec == non-spec greedy (lossless, tie-free)`, async () => {
      const ids = promptIds(EXACT_PROMPT);
      const ref = await baseline(ids);
      const { out, stats } = await serveSpec(ids, gamma);
      expect(out).toEqual(ref);
      expect(stats.spec!.accepted).toBeLessThanOrEqual(stats.spec!.drafted);
    }, 240_000);
  }

  test("echo prompt: lossless AND lookup lands accepts", async () => {
    const ids = promptIds(ECHO_PROMPT);
    const ref = await baseline(ids);
    const { out, stats } = await serveSpec(ids, 10);
    expect(out).toEqual(ref);
    expect(stats.spec!.drafted).toBeGreaterThan(0);
    expect(stats.spec!.accepted).toBeGreaterThan(0);
  }, 240_000);
});
