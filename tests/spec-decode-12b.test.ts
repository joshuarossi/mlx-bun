// Speculative-decoding parity on the 12B target (gemma-4-12B-it-OptiQ-4bit
// + its -assistant-bf16 drafter). Own file (not spec-decode.test.ts) so
// the two ~7 GB targets never co-reside in one process — the suite is
// sharded for exactly this reason, and the repo keeps one model family
// per parity file. Auto-skips until the 12B drafter is downloaded (a
// deliberate ~846 MB pull, normally absent).
//
// This is the SLOWER-TARGET regime where speculation may finally pay —
// e4b was a net loss (too-fast target). Plan + hypothesis:
// docs/design/spec-decode-larger-targets.md.
//
// Gate = long-prefix agreement between greedy spec and greedy non-spec.
// A mis-wired drafter does NOT corrupt output — the target verifies and
// replaces every rejected draft, so wrong KV borrowing shows up as low
// ACCEPTANCE (a perf signal, measured by spec-bench), not bad tokens.
// What this gate actually guards is the shared accept/reject/ROLLBACK +
// cache-trim machinery against 12B's distinct layer/cache shapes (a trim
// bug WOULD corrupt output, shortly after the first rejection). Exact
// toEqual (the e4b tier) + a knife-edge divergence-class check are
// promoted only after a tie-free prompt is calibrated ON-DEVICE for this
// model — knife-edge positions are model-specific (see spec-decode.test.ts).

import { describe, expect, test } from "bun:test";
import { existsSync, readdirSync } from "node:fs";

const T_BASE = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-12B-it-OptiQ-4bit/snapshots`;
const D_BASE = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-12B-it-assistant-bf16/snapshots`;
const have = existsSync(T_BASE) && existsSync(D_BASE);

describe.skipIf(!have)("speculative decoding parity (12B)", async () => {
  if (!have) return;
  const T = `${T_BASE}/${readdirSync(T_BASE)[0]}`;
  const D = `${D_BASE}/${readdirSync(D_BASE)[0]}`;

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model } = await import("../src/model/gemma4");
  const { generate } = await import("../src/generate");
  const { specGenerate } = await import("../src/spec/generate");
  const { GemmaAssistantDrafter } = await import("../src/spec/drafter");
  const { loadTokenizer } = await import("../src/tokenizer");
  const { ChatTemplate } = await import("../src/chat-template");

  const config = await loadModelConfig(T);
  const model = new Gemma4Model(await Weights.open(T), config);
  const drafter = await GemmaAssistantDrafter.load(D);
  const tok = await loadTokenizer(T);
  const template = await ChatTemplate.load(T);

  const promptIds = (text: string): number[] => {
    const ids = tok.encode(template.render([{ role: "user", content: text }]));
    return ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
  };

  for (const gamma of [1, 2, 3]) {
    test(`γ=${gamma} long-prefix agreement (rollback/trim gate)`, async () => {
      const ids = promptIds("List the planets of the solar system in order from the Sun.");
      const gen = generate(model, ids, { maxTokens: 80, temperature: 0 });
      const ref: number[] = [];
      for await (const t of gen) ref.push(t.token);

      const spec = specGenerate(model, drafter, ids, { gamma, maxTokens: 80 });
      let prefix = 0;
      while (prefix < Math.min(ref.length, spec.tokens.length) && ref[prefix] === spec.tokens[prefix]) prefix++;
      // conservative pre-calibration bar; promote to toEqual once a
      // tie-free prompt is confirmed on-device for 12B.
      expect(prefix).toBeGreaterThanOrEqual(30);
    }, 240_000);
  }
});
