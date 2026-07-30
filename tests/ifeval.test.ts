// IFEval verifiable-instruction scorer — pure logic, no model. Each case is a
// response that should pass or fail a specific verifiable instruction.

import { describe, expect, test } from "bun:test";
import { scoreInstance, aggregate, SUPPORTED_INSTRUCTIONS, type IFEvalInstance } from "../src/eval/ifeval";
import { scoreIfevalPairs } from "../src/eval/tasks/ifeval";

const inst = (id: string, kw: Record<string, unknown>): IFEvalInstance => ({
  prompt: "p", instruction_id_list: [id], kwargs: [kw],
});
const pass = (id: string, kw: Record<string, unknown>, r: string) =>
  expect(scoreInstance(inst(id, kw), r).followedAll).toBe(true);
const fail = (id: string, kw: Record<string, unknown>, r: string) =>
  expect(scoreInstance(inst(id, kw), r).followedAll).toBe(false);

describe("keywords", () => {
  test("existence", () => {
    pass("keywords:existence", { keywords: ["fox", "dog"] }, "the fox and the dog");
    fail("keywords:existence", { keywords: ["fox", "cat"] }, "the fox and the dog");
  });
  test("frequency at least", () => {
    pass("keywords:frequency", { keyword: "ai", relation: "at least", frequency: 2 }, "AI and ai");
    fail("keywords:frequency", { keyword: "ai", relation: "at least", frequency: 2 }, "just ai once");
  });
  test("forbidden", () => {
    pass("keywords:forbidden_words", { forbidden_words: ["banana"] }, "apples only");
    fail("keywords:forbidden_words", { forbidden_words: ["banana"] }, "a Banana here");
  });
});

describe("length", () => {
  test("words at least / at most", () => {
    pass("length_constraints:number_words", { relation: "at least", num_words: 3 }, "one two three");
    fail("length_constraints:number_words", { relation: "at most", num_words: 2 }, "one two three");
  });
  test("sentences / paragraphs", () => {
    pass("length_constraints:number_sentences", { relation: "exactly", num_sentences: 2 }, "Hi there. Bye now.");
    pass("length_constraints:number_paragraphs", { relation: "exactly", num_paragraphs: 2 }, "para one\n\npara two");
  });
});

describe("format", () => {
  test("bullets / highlights / title / json", () => {
    pass("detectable_format:number_bullet_lists", { relation: "at least", num_bullets: 2 }, "* a\n* b");
    pass("detectable_format:number_highlighted_sections", { relation: "at least", num_highlights: 1 }, "this is *important*");
    pass("detectable_format:title", {}, "<<My Title>>\nbody");
    pass("detectable_format:json_format", {}, '```json\n{"a":1}\n```');
    fail("detectable_format:json_format", {}, "not json {");
  });
});

describe("case / startend / punctuation", () => {
  test("case", () => {
    pass("change_case:english_lowercase", {}, "all lower case");
    fail("change_case:english_lowercase", {}, "Has Caps");
    pass("change_case:english_capital", {}, "ALL UPPER");
  });
  test("end / quotation", () => {
    pass("startend:end_checker", { end_phrase: "the end" }, "... and that is the end");
    fail("startend:end_checker", { end_phrase: "the end" }, "the end is near");
    pass("startend:quotation", {}, '"wrapped fully"');
    fail("startend:quotation", {}, 'no quotes');
  });
  test("no comma", () => {
    pass("punctuation:no_comma", {}, "no commas here");
    fail("punctuation:no_comma", {}, "yes, there is");
  });
});

describe("multi-instruction + aggregate", () => {
  test("strict requires ALL; aggregate reports both accuracies", () => {
    const multi: IFEvalInstance = {
      prompt: "p",
      instruction_id_list: ["punctuation:no_comma", "change_case:english_lowercase"],
      kwargs: [{}, {}],
    };
    expect(scoreInstance(multi, "all good lowercase").followedAll).toBe(true);
    // one of two fails → not followedAll, but instruction-accuracy = 0.5
    const r = scoreInstance(multi, "Has, both problems");
    expect(r.followedAll).toBe(false);
    expect(r.perInstruction.filter(Boolean).length).toBe(0);

    const rep = aggregate([
      { instance: multi, response: "all good lowercase" }, // 2/2
      { instance: multi, response: "lower, but comma" },    // 1/2 (lowercase ok, comma fails)
    ]);
    expect(rep.promptAccuracy).toBeCloseTo(0.5, 5);
    expect(rep.instructionAccuracy).toBeCloseTo(0.75, 5);
  });

  test("unknown instruction id follows the canonical prompt policy and reports coverage", () => {
    const result = scoreInstance(inst("not:a_real_instruction", {}), "anything");
    expect(result.followedAll).toBe(true);
    expect(result.perInstruction).toEqual([true]);
    expect(result.unhandled).toEqual(["not:a_real_instruction"]);
    expect(SUPPORTED_INSTRUCTIONS.has("keywords:existence")).toBe(true);
  });
});

describe("canonical strict/loose contract", () => {
  const fixture: Array<{ instance: IFEvalInstance; response: string }> = [
    {
      instance: inst("punctuation:no_comma", {}),
      // Strict sees the boilerplate comma; loose mode removes that first line.
      response: "Sure, here is the answer:\nno commas remain",
    },
    {
      instance: {
        prompt: "p",
        instruction_id_list: [
          "keywords:existence",
          "change_case:english_lowercase",
        ],
        kwargs: [{ keywords: ["banana"] }, {}],
      },
      // Both entry points must apply the same thinking-block cleanup.
      response: "<think>hidden uppercase</think>banana",
    },
    {
      instance: inst("not:a_real_instruction", {}),
      response: "anything",
    },
  ];

  test("legacy run-ifeval facade and task evaluator report identical metrics", () => {
    const task = scoreIfevalPairs(fixture);
    const cli = aggregate(fixture);

    expect(cli.n).toBe(task.nTotal);
    expect(cli.promptAccuracy).toBe(task.strictAcc);
    expect(cli.instructionAccuracy).toBe(task.strictInstructionAcc);
    expect({
      nTotal: cli.nTotal,
      strictAcc: cli.strictAcc,
      looseAcc: cli.looseAcc,
      accuracy: cli.accuracy,
      strictInstructionAcc: cli.strictInstructionAcc,
      looseInstructionAcc: cli.looseInstructionAcc,
      coverage: cli.coverage,
    }).toEqual(task);

    expect(task.strictAcc).toBeCloseTo(2 / 3, 10);
    expect(task.looseAcc).toBe(1);
    expect(task.strictInstructionAcc).toBeCloseTo(2 / 3, 10);
    expect(task.looseInstructionAcc).toBe(1);
    expect(task.coverage).toEqual({
      fullySupportedPrompts: 2,
      promptCoverage: 2 / 3,
      supportedInstructions: 3,
      totalInstructions: 4,
      instructionCoverage: 3 / 4,
      unhandledInstructionCounts: { "not:a_real_instruction": 1 },
    });
  });
});
