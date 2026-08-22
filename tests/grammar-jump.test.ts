// Jump-forward decoding (GrammarController.jumpForward + the generate() jump
// iteration; opt-in via MLX_BUN_GRAMMAR_JUMP=1 — see src/grammar.ts for the
// contract and the fidelity note on why it's opt-in).
//
// Part 1 (tokenizer-only, same gating as tests/grammar.test.ts): the
// controller contract — a single-choice grammar jumps its whole body and
// terminates; a compact json_schema jumps the forced object prefix; the
// matcher/emitted lockstep survives partial acceptance by construction.
//
// Part 2 (real weights; auto-skips without Llama-3.2-1B): generate() end to
// end — flag ON emits schema-valid JSON with jumpedTokens > 0 (fewer masked
// forwards), flag OFF never jumps. Output STRING equality between the two is
// deliberately NOT asserted (retokenized forced spans may legally differ from
// sampled ones — the documented reason the feature is opt-in).

import { describe, expect, test } from "bun:test";
import { existsSync, readdirSync } from "node:fs";
import { loadTokenizer } from "../src/tokenizer";
import { compileGrammarRequest, grammarEnabled } from "../src/grammar";
import { shouldUseGrammarJump } from "../src/generate";
import { configureRuntime } from "../src/runtime-config";

const SNAPSHOT = ((): string => {
  const base = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--Llama-3.2-1B-Instruct-4bit/snapshots`;
  try {
    for (const snap of readdirSync(base))
      if (existsSync(`${base}/${snap}/tokenizer.json`)) return `${base}/${snap}`;
  } catch { /* not downloaded */ }
  return `${base}/_unresolved`;
})();
const haveTokenizer = existsSync(`${SNAPSHOT}/tokenizer.json`);
const haveWeights = existsSync(`${SNAPSHOT}/model.safetensors`);

const COMPACT_SCHEMA = {
  type: "object",
  properties: { name: { type: "string" }, age: { type: "number" } },
  required: ["name", "age"],
  additionalProperties: false,
};

describe("generate() jump-forward option gate", () => {
  test("topLogprobs disables jumping just like token logprobs", () => {
    const grammar = {} as any;
    const restore = configureRuntime({ MLX_BUN_GRAMMAR_JUMP: "1" });
    try {
      expect(shouldUseGrammarJump({ grammar })).toBe(true);
      expect(shouldUseGrammarJump({ grammar, logprobs: true })).toBe(false);
      expect(shouldUseGrammarJump({ grammar, topLogprobs: 3 })).toBe(false);
      expect(shouldUseGrammarJump({ grammar, topLogprobs: 0 })).toBe(true);
    } finally {
      restore();
    }
  });
});

describe.skipIf(!haveTokenizer || !grammarEnabled())("jumpForward controller contract", () => {
  test("single-choice grammar: jumps the whole body and terminates", async () => {
    const tok = await loadTokenizer(SNAPSHOT);
    const r = await compileGrammarRequest(
      { guidedChoice: ["mlx-bun structured output"] },
      tok,
      tok.vocabSize,
    );
    expect(r).not.toBeNull();
    const c = r!.controller!;
    try {
      const ids = c.jumpForward(64);
      expect(ids).not.toBeNull();
      expect(ids!.length).toBeGreaterThanOrEqual(2);
      expect(tok.decode(ids!)).toBe("mlx-bun structured output");
      expect(c.isTerminated).toBe(true);
      expect(c.jumpedTokens).toBe(ids!.length);
    } finally {
      c.dispose();
    }
  });

  test("compact json_schema: jumps the forced object prefix", async () => {
    const tok = await loadTokenizer(SNAPSHOT);
    const r = await compileGrammarRequest(
      {
        responseFormat: {
          type: "json_schema",
          json_schema: {
            name: "person",
            schema: COMPACT_SCHEMA,
            strict: true,
            any_whitespace: false,
          },
        },
      },
      tok,
      tok.vocabSize,
    );
    expect(r).not.toBeNull();
    const c = r!.controller!;
    try {
      const ids = c.jumpForward(64);
      expect(ids).not.toBeNull();
      // any_whitespace:false compiles to a FIXED (pretty-printed) layout, so
      // the step-0 forced span is the opening punctuation + indentation +
      // first required key (measured: `{\n  "name": "`). Pin the invariants,
      // not the exact whitespace (xgrammar-version-dependent).
      const jumped = tok.decode(ids!);
      expect(jumped.startsWith("{")).toBe(true);
      expect(jumped).toContain('"name"');
      expect(c.isTerminated).toBe(false);
      // The post-jump mask must be usable (ready() resolves, not rejected).
      await c.ready();
    } finally {
      c.dispose();
    }
  });

  test("maxIds < 2 or terminated → null, matcher untouched", async () => {
    const tok = await loadTokenizer(SNAPSHOT);
    const r = await compileGrammarRequest(
      { guidedChoice: ["alpha beta gamma"] },
      tok,
      tok.vocabSize,
    );
    const c = r!.controller!;
    try {
      expect(c.jumpForward(1)).toBeNull(); // budget too small to pay off
      expect(c.jumpedTokens).toBe(0);
      const ids = c.jumpForward(64); // real jump → terminates the choice
      expect(ids).not.toBeNull();
      expect(c.isTerminated).toBe(true);
      expect(c.jumpForward(64)).toBeNull(); // terminated → null
    } finally {
      c.dispose();
    }
  });
});

describe.skipIf(!haveWeights || !grammarEnabled())("generate() jump-forward (Llama-3.2-1B)", async () => {
  if (!haveWeights) return;
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { createModel } = await import("../src/model/factory");
  const { generate } = await import("../src/generate");
  const { ChatTemplate } = await import("../src/chat-template");

  const config = await loadModelConfig(SNAPSHOT);
  const model = createModel(await Weights.open(SNAPSHOT), config);
  const tok = await loadTokenizer(SNAPSHOT);
  const template = await ChatTemplate.load(SNAPSHOT);

  const promptIds = (text: string): number[] => {
    const ids = tok.encode(template.render([{ role: "user", content: text }]));
    return ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
  };
  const PROMPT = "Describe a fictional person as JSON with their name and age.";

  const run = async (jump: boolean) => {
    const restore = configureRuntime({
      MLX_BUN_GRAMMAR_JUMP: jump ? "1" : undefined,
    });
    try {
      const r = await compileGrammarRequest(
        {
          responseFormat: {
            type: "json_schema",
            json_schema: {
              name: "person",
              schema: COMPACT_SCHEMA,
              strict: true,
              any_whitespace: false,
            },
          },
        },
        tok,
        tok.vocabSize,
      );
      expect(r).not.toBeNull();
      const controller = r!.controller!;
      const out: number[] = [];
      const gen = generate(model, promptIds(PROMPT), {
        maxTokens: 120,
        temperature: 0,
        grammar: controller,
      });
      for await (const t of gen) out.push(t.token);
      return { text: tok.decode(out), jumped: controller.jumpedTokens };
    } finally {
      restore();
    }
  };

  test("flag OFF: valid JSON, zero jumps", async () => {
    const { text, jumped } = await run(false);
    const parsed = JSON.parse(text) as { name?: unknown; age?: unknown };
    expect(typeof parsed.name).toBe("string");
    expect(typeof parsed.age).toBe("number");
    expect(jumped).toBe(0);
  }, 240_000);

  test("flag ON: valid JSON, jumps fired", async () => {
    const { text, jumped } = await run(true);
    const parsed = JSON.parse(text) as { name?: unknown; age?: unknown };
    expect(typeof parsed.name).toBe("string");
    expect(typeof parsed.age).toBe("number");
    expect(jumped).toBeGreaterThan(0);
  }, 240_000);
});
