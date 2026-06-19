// IFEval verifiable-instruction scorer — pure logic, no model. Each case is a
// response that should pass or fail a specific verifiable instruction.

import { describe, expect, test } from "bun:test";
import { scoreInstance, aggregate, SUPPORTED_INSTRUCTIONS, type IFEvalInstance } from "../src/eval/ifeval";

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

  test("unknown instruction id fails closed", () => {
    expect(scoreInstance(inst("not:a_real_instruction", {}), "anything").followedAll).toBe(false);
    expect(SUPPORTED_INSTRUCTIONS.has("keywords:existence")).toBe(true);
  });
});
