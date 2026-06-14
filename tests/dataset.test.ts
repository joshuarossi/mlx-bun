// Unit tests for the dataset-building engine (fast tier — no model needed).
// Covers the non-LLM generators, the 90/10 split + JSONL writing, the template
// registry, and the LLM-driven generators' "requires a client" guard.

import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  TEMPLATES,
  getTemplate,
  generate,
  type Row,
} from "../src/dataset/index";
import {
  genSftQa,
  genDpoPairs,
  genFormatConversion,
  genStyleTransfer,
  genSelfInstruct,
  genPromptReconstruction,
  genMultiTurnChat,
  genToolUseTraces,
  genRagQa,
  genCotSynthesis,
  genVerifiedCode,
  genHfDatasetImport,
  parseCsv,
  parseInstructionList,
  extractPythonBlock,
} from "../src/dataset/generators";
import type { Emit } from "../src/jobs/types";

// A no-op emit sink for tests that don't assert on events.
const noopEmit: Emit = () => {};

describe("genSftQa", () => {
  test("two Q:/A: blocks → 2 messages rows", async () => {
    const pairs_text = [
      "Q: What is OptIQ?",
      "A: A mixed-precision quantizer.",
      "",
      "Q: What does mlx-bun do?",
      "A: Native MLX inference for Bun.",
    ].join("\n");
    const rows = await genSftQa({ pairs_text });
    expect(rows).toHaveLength(2);
    expect(rows[0]).toEqual({
      messages: [
        { role: "user", content: "What is OptIQ?" },
        { role: "assistant", content: "A mixed-precision quantizer." },
      ],
    });
    expect(rows[1]!.messages).toEqual([
      { role: "user", content: "What does mlx-bun do?" },
      { role: "assistant", content: "Native MLX inference for Bun." },
    ]);
  });

  test("multi-line answers are captured (DOTALL behavior)", async () => {
    const pairs_text = "Q: Explain.\nA: line one\nline two\nline three";
    const rows = await genSftQa({ pairs_text });
    expect(rows).toHaveLength(1);
    const msgs = rows[0]!.messages as Array<{ role: string; content: string }>;
    expect(msgs[1]!.content).toBe("line one\nline two\nline three");
  });

  test("empty input → no rows", async () => {
    expect(await genSftQa({ pairs_text: "   " })).toHaveLength(0);
    expect(await genSftQa({})).toHaveLength(0);
  });
});

describe("parseCsv", () => {
  test("quoted field containing a comma", () => {
    const csv = 'prompt,chosen,rejected\nhi,"yes, please","no, thanks"';
    const recs = parseCsv(csv);
    expect(recs).toHaveLength(1);
    expect(recs[0]).toEqual({ prompt: "hi", chosen: "yes, please", rejected: "no, thanks" });
  });

  test("escaped double-quote and embedded newline", () => {
    const csv = 'prompt,chosen,rejected\n"a ""quote""","line1\nline2",z';
    const recs = parseCsv(csv);
    expect(recs).toHaveLength(1);
    expect(recs[0]!.prompt).toBe('a "quote"');
    expect(recs[0]!.chosen).toBe("line1\nline2");
    expect(recs[0]!.rejected).toBe("z");
  });
});

describe("genDpoPairs", () => {
  test("valid CSV with a quoted comma field → dpo rows; malformed row rejected", async () => {
    const csv_text = [
      "prompt,chosen,rejected",
      'What is 2+2?,"4, obviously",five',
      "incomplete,onlytwo", // missing rejected → dropped
      "good,better,worse",
    ].join("\n");
    const rows = await genDpoPairs({ csv_text });
    expect(rows).toHaveLength(2);
    expect(rows[0]).toEqual({
      prompt: "What is 2+2?",
      chosen: "4, obviously",
      rejected: "five",
    });
    expect(rows[1]).toEqual({ prompt: "good", chosen: "better", rejected: "worse" });
  });

  test("empty input → no rows", async () => {
    expect(await genDpoPairs({ csv_text: "" })).toHaveLength(0);
  });
});

describe("genFormatConversion", () => {
  test("3-line JSONL mapped via default input/output keys → messages", async () => {
    const input_jsonl = [
      JSON.stringify({ input: "q1", output: "a1" }),
      JSON.stringify({ input: "q2", output: "a2" }),
      JSON.stringify({ input: "q3", output: "a3" }),
    ].join("\n");
    const rows = await genFormatConversion({ input_jsonl });
    expect(rows).toHaveLength(3);
    expect(rows[1]).toEqual({
      messages: [
        { role: "user", content: "q2" },
        { role: "assistant", content: "a2" },
      ],
    });
  });

  test("custom keys + non-string values coerced; rows missing a key dropped", async () => {
    const input_jsonl = [
      JSON.stringify({ q: "hello", a: 42 }),
      JSON.stringify({ q: "only-q" }), // missing `a` → dropped
      "not json", // unparseable → dropped
    ].join("\n");
    const rows = await genFormatConversion({
      input_jsonl,
      user_key: "q",
      assistant_key: "a",
    });
    expect(rows).toHaveLength(1);
    expect((rows[0]!.messages as any)[1].content).toBe("42");
  });
});

describe("parseInstructionList", () => {
  test("strict JSON array", () => {
    expect(parseInstructionList('["one", "two", "three"]', 5)).toEqual([
      "one",
      "two",
      "three",
    ]);
  });

  test("comma-split fallback for unquoted brackets", () => {
    expect(parseInstructionList("[apple, banana, cherry]", 2)).toEqual(["apple", "banana"]);
  });

  test("numbered lines fallback", () => {
    expect(parseInstructionList("1. first\n2. second\n- third", 5)).toEqual([
      "first",
      "second",
      "third",
    ]);
  });
});

describe("extractPythonBlock", () => {
  test("pulls fenced python", () => {
    expect(extractPythonBlock("blah\n```python\nx = 1\n```\nmore")).toBe("x = 1");
  });
  test("returns whole text when no fence", () => {
    expect(extractPythonBlock("just code")).toBe("just code");
  });
});

describe("generate() 90/10 split + JSONL writing", () => {
  let dir: string;
  beforeAll(() => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-dataset-"));
  });
  afterAll(() => {
    rmSync(dir, { recursive: true, force: true });
  });

  test("10 Q:/A: blocks → train.jsonl 9 rows, valid.jsonl 1 row, valid JSON per line", async () => {
    const blocks: string[] = [];
    for (let i = 0; i < 10; i++) blocks.push(`Q: q${i}\nA: a${i}`);
    const out = join(dir, "run-split");
    const events: Array<Record<string, unknown>> = [];
    const emit: Emit = (e) => events.push(e as Record<string, unknown>);

    const res = await generate("sft_qa_pairs", { pairs_text: blocks.join("\n\n") }, out, emit);
    expect(res.n_train).toBe(9);
    expect(res.n_valid).toBe(1);
    expect(res.output_dir).toBe(out);

    const trainText = await Bun.file(join(out, "train.jsonl")).text();
    const validText = await Bun.file(join(out, "valid.jsonl")).text();
    const trainLines = trainText.trimEnd().split("\n");
    const validLines = validText.trimEnd().split("\n");
    expect(trainLines).toHaveLength(9);
    expect(validLines).toHaveLength(1);

    // every line parses as JSON and has the messages shape
    for (const line of [...trainLines, ...validLines]) {
      const obj = JSON.parse(line) as Row;
      expect(Array.isArray(obj.messages)).toBe(true);
    }
    // the valid row is the 10th block
    expect((JSON.parse(validLines[0]!).messages as any)[0].content).toBe("q9");

    // a final done-style stage event with counts was emitted
    const done = events.find((e) => e.type === "stage" && e.stage === "done");
    expect(done).toBeDefined();
    expect(done!.n_train).toBe(9);
    expect(done!.n_valid).toBe(1);
  });

  test("output dir is created if missing", async () => {
    const out = join(dir, "nested", "deep", "run");
    const res = await generate(
      "sft_qa_pairs",
      { pairs_text: "Q: a\nA: b\n\nQ: c\nA: d" },
      out,
      noopEmit,
    );
    expect(res.n_train).toBeGreaterThanOrEqual(1);
    expect(await Bun.file(join(out, "train.jsonl")).exists()).toBe(true);
    expect(await Bun.file(join(out, "valid.jsonl")).exists()).toBe(true);
  });

  test("single row → train has 1, valid falls back to last row", async () => {
    const out = join(dir, "run-single");
    const res = await generate("sft_qa_pairs", { pairs_text: "Q: a\nA: b" }, out, noopEmit);
    expect(res.n_train).toBe(1);
    expect(res.n_valid).toBe(1);
    const validLines = (await Bun.file(join(out, "valid.jsonl")).text()).trimEnd().split("\n");
    expect(validLines).toHaveLength(1);
  });

  test("zero rows throws", async () => {
    const out = join(dir, "run-empty");
    await expect(generate("sft_qa_pairs", { pairs_text: "" }, out, noopEmit)).rejects.toThrow(
      /0 rows/,
    );
  });

  test("unknown template throws", async () => {
    await expect(generate("nope", {}, join(dir, "x"), noopEmit)).rejects.toThrow(/unknown template/);
  });
});

describe("TEMPLATES registry", () => {
  test("all 13 templates present", () => {
    expect(TEMPLATES).toHaveLength(13);
    const ids = TEMPLATES.map((t) => t.id);
    expect(new Set(ids).size).toBe(13);
    for (const id of [
      "sft_qa_pairs",
      "dpo_pref_pairs",
      "code_completion",
      "hf_dataset_import",
      "format_conversion",
      "style_transfer",
      "self_instruct",
      "prompt_reconstruction",
      "multi_turn_chat",
      "tool_use_traces",
      "rag_qa",
      "cot_synthesis",
      "verified_code",
    ]) {
      expect(ids).toContain(id);
    }
  });

  test("every template has a label, description and non-empty fields", () => {
    for (const t of TEMPLATES) {
      expect(t.label.length).toBeGreaterThan(0);
      expect(t.description.length).toBeGreaterThan(0);
      expect(t.fields.length).toBeGreaterThan(0);
      for (const f of t.fields) {
        expect(f.name.length).toBeGreaterThan(0);
        expect(["text", "textarea", "number"]).toContain(f.type);
      }
    }
  });

  test("the 5 non-LLM templates have needs_llm:false", () => {
    const nonLlm = ["sft_qa_pairs", "dpo_pref_pairs", "code_completion", "hf_dataset_import", "format_conversion"];
    for (const id of nonLlm) {
      expect(getTemplate(id)!.needs_llm).toBe(false);
    }
    const llm = TEMPLATES.filter((t) => t.needs_llm).map((t) => t.id);
    expect(llm).toHaveLength(8);
  });

  test("getTemplate returns undefined for unknown id", () => {
    expect(getTemplate("does-not-exist")).toBeUndefined();
  });
});

describe("LLM-driven generators require a client", () => {
  // Minimal valid inputs so we get past the early empty-input return and reach
  // the requireLlm guard. (rag_qa / cot etc. require the llm before reading.)
  const cases: Array<[string, (i: any, e: Emit, l?: any) => Promise<Row[]>, Record<string, unknown>]> = [
    ["style_transfer", genStyleTransfer, { reference_samples: "ref", raw_text: "para" }],
    ["self_instruct", genSelfInstruct, { seeds: "do a thing" }],
    ["prompt_reconstruction", genPromptReconstruction, { target_text: "a paragraph" }],
    ["multi_turn_chat", genMultiTurnChat, { seeds: "hi" }],
    ["tool_use_traces", genToolUseTraces, { tools_json: "[{}]", scenarios: "s", mock_results: "m" }],
    ["rag_qa", genRagQa, { documents: "doc" }],
    ["cot_synthesis", genCotSynthesis, { questions: "why?" }],
    ["verified_code", genVerifiedCode, { specs: "fib" }],
  ];

  for (const [name, fn, inputs] of cases) {
    test(`${name} throws a clear error without an llm client`, async () => {
      await expect(fn(inputs, noopEmit, undefined)).rejects.toThrow(/LLM-driven|requires a served model/);
    });
  }

  test("hf_dataset_import resolves (no-op for a missing hf_id) — now a real generator", async () => {
    await expect(genHfDatasetImport({}, noopEmit)).resolves.toEqual([]);
  });
});
