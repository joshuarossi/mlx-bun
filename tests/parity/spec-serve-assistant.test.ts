// Serve-loop AssistantSource validation (slow tier; auto-skips without the
// e4b + assistant-drafter pair). Exercises the Phase-1 seam extension end to
// end: AssistantProvider → the shared verify/accept executor (specServeRun)
// with the KV-borrowing Gemma drafter reading target donor-KV + anchor hidden
// through the extended DraftSource seam.
//
// Gate: on a TIE-FREE prompt the batched verify == stock greedy, so serve-loop
// spec output must be TOKEN-IDENTICAL to the non-spec generate() baseline
// (losslessness — a flip here is an accept/reject/rollback bug, never
// rounding). Same tie-free reasoning as tests/spec-decode.test.ts. Also
// asserts the `usage.speculation` telemetry populates (drafts proposed, a
// sane accept count). In-process only — no server is started.

import { describe, expect, test } from "bun:test";
import { existsSync, readdirSync } from "node:fs";

const E4B_BASE = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const DR_BASE = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-assistant-bf16/snapshots`;
const have = existsSync(E4B_BASE) && existsSync(DR_BASE);

describe.skipIf(!have)("serve-loop AssistantSource (e4b + assistant drafter)", async () => {
  if (!have) return;
  const E4B = `${E4B_BASE}/${readdirSync(E4B_BASE)[0]}`;
  const DR = `${DR_BASE}/${readdirSync(DR_BASE)[0]}`;

  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { Gemma4Model } = await import("../../src/model/gemma4");
  const { generate } = await import("../../src/generate");
  const { specServeRun } = await import("../../src/spec/serve-loop");
  const { AssistantProvider } = await import("../../src/spec/assistant-source");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");

  const config = await loadModelConfig(E4B);
  const model = new Gemma4Model(await Weights.open(E4B), config);
  const provider = await AssistantProvider.load(DR);
  const tok = await loadTokenizer(E4B);
  const template = await ChatTemplate.load(E4B);

  const promptIds = (text: string): number[] => {
    const ids = tok.encode(template.render([{ role: "user", content: text }]));
    return ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
  };

  // Tie-free prompt (same as spec-decode.test.ts) — batched verify == stock.
  const EXACT_PROMPT = "List the planets of the solar system in order from the Sun.";

  const baseline = async (ids: number[]): Promise<number[]> => {
    const gen = generate(model, ids, { maxTokens: 80, temperature: 0 });
    const ref: number[] = [];
    for await (const t of gen) ref.push(t.token);
    return ref;
  };

  const serveSpec = async (ids: number[], gamma: number) => {
    const out: number[] = [];
    const stats = await specServeRun(
      model, provider, gamma, ids,
      { maxTokens: 80, temperature: 0 },
      (token: number) => { out.push(token); },
    );
    return { out, stats };
  };

  for (const gamma of [1, 2, 3]) {
    test(`γ=${gamma}: serve-loop spec == non-spec greedy (lossless, tie-free)`, async () => {
      const ids = promptIds(EXACT_PROMPT);
      const ref = await baseline(ids);
      const { out, stats } = await serveSpec(ids, gamma);
      expect(out).toEqual(ref);
      // Telemetry: the drafter actually proposed, and accepts are in range.
      expect(stats.spec!.drafted).toBeGreaterThan(0);
      expect(stats.spec!.accepted).toBeGreaterThanOrEqual(0);
      expect(stats.spec!.accepted).toBeLessThanOrEqual(stats.spec!.drafted);
      // A working drafter clears at least one target forward via a bonus/accept:
      // targetCalls (prefill + verify rounds) is fewer than emitting one token
      // per forward would require.
      expect(stats.spec!.targetCalls).toBeLessThan(out.length + 2);
    }, 240_000);
  }
});
