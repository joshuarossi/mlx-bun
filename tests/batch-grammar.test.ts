// GATED: grammar-constrained decoding under the batch lane (B2 gates from
// docs/design/structured-output.md, executed per
// docs/design/grammar-spec-batching-integration.md Phase A).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batch-grammar.test.ts
//
// Drives the PRODUCTION path — GenerationGateway.run() with a compiled
// GrammarController → BatchScheduler #stepGrammar (read-before-build) — on
// real CPM weights. The model-free isolation unit (4 interleaved WASM
// matchers) lives in tests/grammar.test.ts; THESE gates cover the scheduler
// orchestration: row↔matcher alignment across admission/eviction/join,
// per-row termination, and the free-running mask guarantee (every emitted
// stream conforms to ITS schema, no matter what the model wanted to say).
//
// Free-running (not teacher-forced) is correct here: the gate is grammar
// CONFORMANCE (parse + schema keys), which is trajectory-independent — the
// mask makes conformance a hard invariant, so bf16 argmax flips can change
// WHICH valid JSON appears but never whether it conforms. The sibling
// byte-match test is the one place trajectories are compared, and there the
// schedule is pinned (equal maxTokens, no early termination) so both runs
// see identical shapes.

import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const CPM_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveCpm = existsSync(`${CPM_BASE}/config.json`);

describe.skipIf(!optIn || !haveCpm)("batch lane × grammar (B2 gates, CPM)", () => {
  let model: import("../src/model/factory").RuntimeModel;
  let weights: import("../src/weights").Weights;
  let tok: import("../src/tokenizer").LoadedTokenizer;
  let makeGateway: () => import("../src/serve/generation-gateway").GenerationGateway;
  let compileFor: (
    req: import("../src/grammar").GrammarRequest,
  ) => Promise<import("../src/grammar").GrammarController>;

  beforeAll(async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { GenerationGateway } = await import("../src/serve/generation-gateway");
    const { compileGrammarRequest } = await import("../src/grammar");

    const config = await loadModelConfig(CPM_BASE);
    weights = await Weights.open(CPM_BASE);
    model = createModel(weights, config);
    tok = await loadTokenizer(CPM_BASE);

    // Batch-lane-only harness: grammar requests must batch (B1); a serial
    // fallback here would mean willBatch routing broke — fail loudly.
    makeGateway = () =>
      new GenerationGateway(model, 4, async () => {
        throw new Error("serial lane reached — batch routing broke");
      });
    compileFor = async (req) => {
      const r = await compileGrammarRequest(req, tok, model.config.text.vocabSize);
      if (!r) throw new Error("grammar compile failed in test setup");
      return r.controller;
    };
  });

  afterAll(() => {
    weights?.dispose();
  });

  const SHAPE = {
    hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
    userSeed: false, kvQuant: false, turboQuant: false, hasLogitsExtras: false,
    wantsLogprobs: false, hasDraft: false,
  };

  /** Run one request through the gateway's batch lane; collect the stream. */
  const runOne = async (
    gw: import("../src/serve/generation-gateway").GenerationGateway,
    promptText: string,
    opts: {
      grammar?: import("../src/grammar").GrammarController;
      maxTokens: number;
    },
  ) => {
    const got: number[] = [];
    const st = await gw.run(
      tok.encode(promptText),
      {
        maxTokens: opts.maxTokens,
        temperature: 0,
        ...(opts.grammar ? { grammar: opts.grammar } : {}),
      },
      (t) => { got.push(t); },
      undefined,
      { ...SHAPE, hasGrammar: !!opts.grammar },
    );
    return { tokens: got, text: tok.decode(got, true), stats: st };
  };

  const schemaFor = (key: string, type: object) => ({
    type: "object",
    properties: { [key]: type },
    required: [key],
  });
  // any_whitespace:false (compact separators) throughout this file: these
  // gates cover SCHEDULER orchestration (row↔matcher alignment, eviction,
  // joins), and unlimited-whitespace schemas sit on a machine-specific greedy
  // knife-edge — CPM base + raw prompt can tab-loop after a key until
  // max_tokens (whitespace-stall mode, structured-output.md known gaps;
  // reproduced on M1 Max 2026-07-07: 96/96 tabs after `"beta"`). Compact
  // grammars have no whitespace choice points, making conformance genuinely
  // trajectory-independent as the header claims. Default-whitespace masks
  // stay covered by the serial-lane grammar suites.
  const jsonSchemaReq = (name: string, schema: object) => ({
    responseFormat: {
      type: "json_schema",
      json_schema: { name, schema, any_whitespace: false },
    },
  });

  // THE bug-class gate: four rows, four DIFFERENT schemas, decoding
  // concurrently. Row↔matcher misalignment after admission/merge would
  // cross-bleed masks — an output conforming to a SIBLING's schema (or not
  // parsing at all) is the failure signature.
  test("all-grammar B=4, four different schemas — each row conforms to ITS schema", async () => {
    const gw = makeGateway();
    // Value types are enum/bounded so every row can CLOSE its JSON within the
    // budget (a free string/array can ramble past max_tokens → truncation,
    // which is a different gate, tested below). Distinctness lives in the
    // required KEY names + enums, which is what a cross-bled mask would break.
    const cells: Array<[string, object]> = [
      ["alpha", { type: "string", enum: ["red", "green", "blue"] }],
      ["beta", { type: "number" }],
      ["gamma", { type: "string", enum: ["on", "off"] }],
      ["delta", { type: "string", enum: ["north", "south"] }],
    ];
    const results = await Promise.all(
      cells.map(async ([key, type], i) => {
        const g = await compileFor(jsonSchemaReq(key, schemaFor(key, type)));
        return runOne(gw, `Describe item ${i} of the dataset.`, {
          grammar: g, maxTokens: 96,
        });
      }),
    );
    const allKeys = cells.map(([k]) => k);
    for (let i = 0; i < cells.length; i++) {
      const own = allKeys[i]!;
      const parsed = JSON.parse(results[i]!.text); // throws = gate fails
      expect(Object.keys(parsed)).toContain(own);
      for (const other of allKeys) {
        if (other !== own) expect(Object.keys(parsed)).not.toContain(other);
      }
    }
    // enum values are the sharpest cross-bleed signal: alpha's mask admits
    // ONLY red/green/blue where delta's admits ONLY north/south — a swapped
    // matcher produces the other row's vocabulary.
    expect(["red", "green", "blue"]).toContain(JSON.parse(results[0]!.text).alpha);
    expect(typeof JSON.parse(results[1]!.text).beta).toBe("number");
    expect(["on", "off"]).toContain(JSON.parse(results[2]!.text).gamma);
    expect(["north", "south"]).toContain(JSON.parse(results[3]!.text).delta);
  }, 240_000);

  // Mask isolation: a grammar row must not perturb its siblings. The schedule
  // is pinned (all rows maxTokens=12; the person schema can't complete in 12
  // tokens so the grammar row runs to length like everyone else) → run A
  // (grammar + 2 plain) and run B (plain + same 2 plain) see identical batch
  // shapes, and rows are independent in the B axis — sibling streams must be
  // token-identical. This also exercises #stepGrammar's claim of "same math,
  // scheduling only" vs the pipelined step.
  test("mixed batch: grammar row leaves siblings byte-identical", async () => {
    const N = 12;
    const sib1 = "The sea was calm that morning, and";
    const sib2 = "In the beginning the universe was";
    const gPrompt = "Produce a person record.";
    const schema = {
      type: "object",
      properties: {
        name: { type: "string" }, age: { type: "number" },
        hobbies: { type: "array", items: { type: "string" } },
      },
      required: ["name", "age", "hobbies"],
    };

    const gwA = makeGateway();
    const g = await compileFor(jsonSchemaReq("person", schema));
    const [ga, a1, a2] = await Promise.all([
      runOne(gwA, gPrompt, { grammar: g, maxTokens: N }),
      runOne(gwA, sib1, { maxTokens: N }),
      runOne(gwA, sib2, { maxTokens: N }),
    ]);

    const gwB = makeGateway();
    const [, b1, b2] = await Promise.all([
      runOne(gwB, gPrompt, { maxTokens: N }), // same prompt, NO grammar
      runOne(gwB, sib1, { maxTokens: N }),
      runOne(gwB, sib2, { maxTokens: N }),
    ]);

    expect(a1.tokens).toEqual(b1.tokens);
    expect(a2.tokens).toEqual(b2.tokens);
    // the grammar row itself: truncated JSON prefix, exactly N real tokens
    expect(ga.tokens.length).toBe(N);
    expect(ga.text.trimStart().startsWith("{")).toBe(true);
  }, 240_000);

  // Early termination + churn: a tight grammar terminates mid-batch while
  // siblings keep decoding, then a joiner admits AFTER the eviction. The
  // all--inf guarantee per row: the terminated row is finished/evicted before
  // its slot is ever sampled again (a violation shows up as garbage tokens
  // appended after the completed grammar, or a crash on the evicted slot).
  test("early termination mid-batch + joiner after eviction", async () => {
    const gw = makeGateway();
    const g = await compileFor({ guidedChoice: ["affirmative", "negative"] });
    const [choice, s1, s2] = await Promise.all([
      runOne(gw, "Is the sky blue? Answer:", { grammar: g, maxTokens: 16 }),
      runOne(gw, "The mountain path wound upward through", { maxTokens: 20 }),
      runOne(gw, "Long ago, in a village by the river,", { maxTokens: 20 }),
    ]);
    expect(["affirmative", "negative"]).toContain(choice.text.trim());
    expect(choice.stats.generatedTokens).toBeLessThan(16); // terminated early
    expect(choice.stats.generatedTokens).toBe(choice.tokens.length);
    expect(s1.stats.generatedTokens).toBe(20);
    expect(s2.stats.generatedTokens).toBe(20);

    // churn: a joiner admitted after the grammar row evicted — batch still sane
    const j = await runOne(gw, "The recipe calls for", { maxTokens: 8 });
    expect(j.stats.generatedTokens).toBe(8);
  }, 240_000);

  // F1's regression, batch flavor: max_tokens lands mid-JSON. The truncated
  // stream must be exactly maxTokens REAL tokens (the serial-lane F1 bug was
  // a stale/garbage final token at the boundary), forming a valid JSON prefix.
  test("max_tokens truncation mid-JSON under batch", async () => {
    const gw = makeGateway();
    const schema = {
      type: "object",
      properties: {
        title: { type: "string" }, pages: { type: "number" },
        tags: { type: "array", items: { type: "string" } },
      },
      required: ["title", "pages", "tags"],
    };
    const g = await compileFor(jsonSchemaReq("book", schema));
    const [cut, sib] = await Promise.all([
      runOne(gw, "Describe a book.", { grammar: g, maxTokens: 4 }),
      runOne(gw, "The library was quiet except for", { maxTokens: 10 }),
    ]);
    expect(cut.tokens.length).toBe(4);
    expect(cut.stats.generatedTokens).toBe(4);
    for (const t of cut.tokens) {
      expect(t).toBeGreaterThanOrEqual(0);
      expect(t).toBeLessThan(model.config.text.vocabSize);
    }
    expect(cut.text.trimStart().startsWith("{")).toBe(true);
    expect(sib.stats.generatedTokens).toBe(10);
  }, 240_000);

  // REGRESSION (found by the feature-matrix conformance gate, 2026-07-03): a
  // grammar row joining while another grammar row is MID-DECODE triggers
  // #mergeJoiner → #flushPipeline, which emitted the pending tokens without
  // advancing the matchers — the running row's mask went one token stale and
  // its output turned invalid (e.g. `{ " "name": ...`). The B=4 test above
  // misses it because simultaneous submits all admit before stepping begins;
  // the stagger below forces the mid-decode join.
  test("grammar joiner mid-decode keeps the running grammar row conformant", async () => {
    const gw = makeGateway();
    const schemaA = {
      type: "object",
      properties: { title: { type: "string" }, year: { type: "number" } },
      required: ["title", "year"],
    };
    const gA = await compileFor(jsonSchemaReq("a", schemaA));
    const pA = runOne(gw, "Describe a film.", { grammar: gA, maxTokens: 48 });
    await new Promise((r) => setTimeout(r, 150)); // A is decoding now
    // Joiner uses guided_choice — a whitespace-free grammar, so CPM's
    // whitespace-stall mode (structured-output.md known gaps) can't muddy
    // the regression signal. It still joins as a live grammar row.
    const gB = await compileFor({ guidedChoice: ["paris", "tokyo"] });
    const pB = runOne(gw, "Pick a city:", { grammar: gB, maxTokens: 48 });
    const [a, b] = await Promise.all([pA, pB]);
    const pa = JSON.parse(a.text); // throws = the stale-mask bug is back
    expect(typeof pa.title).toBe("string");
    expect(typeof pa.year).toBe("number");
    expect(["paris", "tokyo"]).toContain(b.text.trim());
  }, 240_000);

  // Prefill-terminated row: single-char choices mean ANY valid first token
  // completes the grammar — the row must emit its one token and finish
  // without ever merging into the running batch (the scheduler's
  // prefill-termination path), leaving live siblings untouched.
  test("grammar satisfied at token 0 finishes without merging", async () => {
    const gw = makeGateway();
    const g = await compileFor({ guidedChoice: ["0", "1"] });
    const [bit, sib] = await Promise.all([
      runOne(gw, "Emit a single binary digit:", { grammar: g, maxTokens: 8 }),
      runOne(gw, "Meanwhile, across the valley,", { maxTokens: 12 }),
    ]);
    expect(bit.stats.generatedTokens).toBe(1);
    expect(["0", "1"]).toContain(bit.text.trim());
    expect(sib.stats.generatedTokens).toBe(12);
  }, 240_000);
});
