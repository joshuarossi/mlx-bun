import { afterAll, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { sha256 } from "../bench/plan";
import { parseResponse, REQUEST_DEFAULTS } from "./client";
import { callsMatch, extractToolCall } from "./bfcl";
import { scoreIfevalInstance } from "./ifeval";
import { DATASETS, hasChatTemplate, makePlan, validatePlan, type DatasetPin, type EvalPlan } from "./plan";
import { compare, qualification, type EvalResult } from "./report";
import { buildProgram, computeCapabilityScore, extractAnswer, extractPred, gsm8kPrompt, sampleIndices, truncateCompletion } from "./scoring";
import { humanevalBody, letterFromTopLogprobs, parseTasks, TASKS, type EvalRequest, type EvalResponse, type PythonVerification,
  type VerifyPython } from "./tasks";
import type { FakeRule } from "./fixtures/fake-openai";
import { probeVerifier, resolveVerifier, run } from "../eval-serve";

const FAKE = resolve(import.meta.dir, "fixtures/fake-openai.ts");
const CLI = resolve(import.meta.dir, "../eval-serve.ts");
const scratch = realpathSync(mkdtempSync(join(tmpdir(), "eval-serve-test-")));
afterAll(() => rmSync(scratch, { recursive: true, force: true }));
let counter = 0;
const fresh = (name: string) => { const dir = join(scratch, `${name}-${counter++}`); mkdirSync(dir, { recursive: true }); return dir; };
const jsonl = (rows: unknown[]) => rows.map(row => JSON.stringify(row)).join("\n") + "\n";

// ---- synthetic inputs (generated here; no datasets are committed) ------------------------
/** A git tree whose serve command is the fake server. */
function tree(): string {
  const dir = fresh("tree");
  writeFileSync(join(dir, "serve.ts"), readFileSync(FAKE));
  for (const args of [["init", "-q"], ["add", "-A"], ["-c", "user.email=t@t", "-c", "user.name=t", "commit", "-qm", "init"]])
    expect(Bun.spawnSync(["git", "-C", dir, ...args]).exitCode).toBe(0);
  return dir;
}
function model(chatTemplate = true): string {
  const dir = fresh("model");
  writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "fake" }));
  writeFileSync(join(dir, "model.safetensors"), "weights-bytes");
  writeFileSync(join(dir, "tokenizer_config.json"), JSON.stringify(chatTemplate ? { chat_template: "{{ messages }}" } : {}));
  return dir;
}
function library(): string {
  const dir = fresh("native");
  for (const name of ["libmlxc.dylib", "libmlx.dylib", "mlx.metallib"]) writeFileSync(join(dir, name), `${name}-bytes`);
  return join(dir, "libmlxc.dylib");
}

const MMLU_DEV = [0, 1, 2, 3, 4, 5].map(i => ({ question: `Dev question ${i}?`, subject: "astronomy", choices: ["w", "x", "y", "z"], answer: i % 4 }));
const HUMANEVAL = [
  { task_id: "HumanEval/0", prompt: "def add(a, b):\n    \"\"\"HE-ONE add two numbers\"\"\"\n", canonical_solution: "",
    test: "def check(f):\n    assert f(1, 2) == 3\n", entry_point: "add" },
  { task_id: "HumanEval/1", prompt: "def sub(a, b):\n    \"\"\"HE-TWO subtract\"\"\"\n", canonical_solution: "",
    test: "def check(f):\n    assert f(3, 2) == 1\n", entry_point: "sub" },
];
/** Two or three rows per task; GSM8K-50 draws 50 of 52 export rows. */
function datasets(): { dir: string; pins: Record<string, DatasetPin> } {
  const dir = fresh("data");
  const files: Record<string, unknown[]> = {
    gsm8k_optiq_frozen: [
      { question: "Q-ALPHA: Tom has 2 apples and gets 3 more. How many?", answer: "2 + 3 = 5\n#### 5", rendered_prompt: "ignored" },
      { question: "Q-BETA: What is 1,000 + 234?", answer: "#### 1,234" },
    ],
    gsm8k: Array.from({ length: 52 }, (_, i) => ({ question: `G50-${i}: how many?`, answer: `#### ${i % 2 ? 8 : 7}` })),
    mmlu_optiq_frozen: [
      { question: "MMLU-ONE Which planet is largest?", subject: "astronomy", choices: ["Mars", "Venus", "Jupiter", "Earth"], answer: 2 },
      { question: "MMLU-TWO Which virus?", subject: "virology", choices: ["a", "b", "c", "d"], answer: 0 },
    ],
    mmlu_optiq_dev: MMLU_DEV,
    ifeval_optiq_frozen: [
      { key: 1, prompt: "IF-ONE answer in lowercase without commas", instruction_id_list: ["change_case:english_lowercase",
        "punctuation:no_comma", "detectable_content:unknown_check"], kwargs: [{}, {}, {}] },
      { key: 2, prompt: "IF-TWO wrap the answer in double quotes", instruction_id_list: ["startend:quotation"], kwargs: [{}] },
    ],
    bfcl_optiq_frozen: [
      { id: "simple_1", question: [[{ role: "user", content: "BFCL-ONE find a library in Boston" }]],
        function: [{ name: "lib.find", description: "Find a library", parameters: { type: "dict", properties: { location: { type: "string" } } } }],
        ground_truth: [{ "lib.find": { location: ["Boston, MA", "Boston"] } }] },
      { id: "simple_2", question: [[{ role: "user", content: "BFCL-TWO area of a circle of radius 5" }]],
        function: [{ name: "geo.area", description: "Area", parameters: { type: "dict", properties: { radius: { type: "integer" } } } }],
        ground_truth: [{ "geo.area": { radius: [5] } }] },
    ],
    humaneval_optiq_frozen: HUMANEVAL,
    hashhop_optiq_frozen: [
      { raw_problem: "HH-ONE walk the chain", query: "AAAAAAAAAAAAAAAA", expected: "abcdefghijklmnop" },
      { raw_problem: "HH-TWO walk the chain", query: "BBBBBBBBBBBBBBBB", expected: "qrstuvwxyzabcdef" },
    ],
  };
  const pins: Record<string, DatasetPin> = {};
  for (const [name, rows] of Object.entries(files)) {
    const text = jsonl(rows);
    writeFileSync(join(dir, `${name}.jsonl`), text);
    pins[name] = { sha256: sha256(Buffer.from(text)), rows: rows.length, source: "test" };
  }
  return { dir, pins };
}
const RULES: FakeRule[] = [
  { match: "Q-ALPHA", content: "Tom has 2 + 3 = 5 apples.\n#### 5" },
  { match: "Q-BETA", content: "The answer is 7." },
  { match: "G50-", content: "#### 7" },
  { match: "MMLU-ONE", topLogprobs: [{ token: "ĠC", logprob: -0.1 }, { token: "ĠA", logprob: -2.5 }, { token: "C", logprob: -3 }] },
  // Equal logprobs: the first letter wins, as in main's strict argmax.
  { match: "MMLU-TWO", topLogprobs: [{ token: "▁D", logprob: -0.7 }, { token: "▁B", logprob: -0.7 }, { token: "x", logprob: -4 }] },
  { match: "IF-ONE", content: "all lowercase and no commas here", reasoning: "hidden plan, With, Commas" },
  { match: "IF-TWO", content: "Sure, here you go.\n\"quoted answer\"" },
  { match: "BFCL-ONE", toolCall: { name: "lib.find", arguments: { location: "Boston" } } },
  { match: "BFCL-TWO", content: "<tool_call>{\"name\": \"geo.area\", \"arguments\": {\"radius\": \"6\"}}</tool_call>" },
  { match: "HE-ONE", content: "Here:\n```python\ndef add(a, b):\n    \"\"\"HE-ONE add two numbers\"\"\"\n    return a + b\n```" },
  { match: "HE-TWO", content: "```python\ndef sub(a, b):\n    while True:\n        pass\n```" },
  { match: "HH-ONE", content: "The final hash: abcdefghijklmnop" },
  { match: "HH-TWO", content: "none" },
];

interface Fixture { root: string; plan: string; planValue: EvalPlan; pins: Record<string, DatasetPin>; log: string; command: string[] }
function fixture(rules: FakeRule[] = RULES, options: { tasks?: string; chatTemplate?: boolean } = {}): Fixture {
  const root = tree(), data = datasets(), dir = fresh("plan");
  const planValue = makePlan({ model: model(options.chatTemplate ?? true), data: data.dir, native: library(), tasks: options.tasks ?? "all",
    pythonImage: `python@sha256:${"a".repeat(64)}` }, data.pins);
  const plan = join(dir, "plan.json"), script = join(dir, "rules.json"), log = join(dir, "requests.jsonl");
  writeFileSync(plan, JSON.stringify(planValue, null, 1));
  writeFileSync(script, JSON.stringify(rules));
  return { root, plan, planValue, pins: data.pins, log, command: [process.execPath, join(root, "serve.ts"), "--fake-script", script, "--fake-log", log] };
}
/** Stands in for the Docker verifier: verifies the addition, times out otherwise. */
function fakeVerifier(): { verify: VerifyPython; programs: string[] } {
  const programs: string[] = [];
  const verify: VerifyPython = async source => {
    programs.push(source);
    if (source === "pass\n") return { status: "verified" };
    return source.includes("return a + b") ? { status: "verified" } : { status: "unverified", reason: "timeout", error: "the program did not finish" };
  };
  return { verify, programs };
}
const quick = { readyTimeoutMs: 15_000, requestTimeoutMs: 15_000 };
const readResult = (out: string) => JSON.parse(readFileSync(join(out, "result.json"), "utf8")) as EvalResult;
const requests = (log: string) => readFileSync(log, "utf8").trim().split("\n").map(line => JSON.parse(line) as { path: string; body: Record<string, any> });
const task = (result: EvalResult, id: string) => result.tasks.find(t => t.task === id)!;

// ---- ported scoring, against small in-test samples ------------------------------------------
test("GSM8K prompt and answer extraction follow main", () => {
  const prompt = gsm8kPrompt("How many?", 3);
  expect(prompt.startsWith("Q: There are 15 trees in the grove.")).toBe(true);
  expect(prompt.split("\n\n")).toHaveLength(4);
  expect(prompt.endsWith("\n\nQ: How many?\nA:")).toBe(true);
  expect(extractAnswer("so 12 + 3\n#### 1,215")).toBe("1215");
  expect(extractAnswer("\\boxed{42} and later 7")).toBe("42");
  expect(extractAnswer("first 3 then 9.5")).toBe("9.5");
  expect(extractAnswer("<think>#### 1</think> answer 4")).toBe("4");
  expect(extractAnswer("no digits")).toBeNull();
});

test("GSM8K-50 is main's seeded draw of the export", () => {
  // Main's runner.ts sampleIndices(1319, 50, 42), computed from main's source at 02d723a.
  const main = [2, 91, 134, 174, 202, 214, 231, 237, 256, 258, 281, 306, 311, 316, 334, 341, 342, 369, 381, 386, 395, 461, 548, 565,
    591, 594, 621, 650, 657, 714, 721, 736, 761, 766, 797, 807, 812, 858, 868, 930, 935, 957, 1077, 1098, 1140, 1150, 1182, 1255, 1305, 1313];
  expect(sampleIndices(1319, 50, 42)).toEqual(main);
  expect(sampleIndices(5, 50, 42)).toEqual([0, 1, 2, 3, 4]);
  const all = Array.from({ length: 1319 }, (_, i) => ({ question: `q${i}`, answer: "#### 1" }));
  expect(TASKS["gsm8k-50"].select({ gsm8k: all }).map((item: any) => item.index)).toEqual(main);
});

test("MMLU: 5-shot raw prompt and the letter argmax from top logprobs", async () => {
  const item = TASKS.mmlu.select({ mmlu_optiq_frozen: [{ question: " Largest? ", subject: "college_physics", choices: ["a", "b", "c", "d"], answer: 1 }],
    mmlu_optiq_dev: MMLU_DEV.map(d => ({ ...d, subject: "college_physics" })) })[0];
  const sent: EvalRequest[] = [];
  const send = async (request: EvalRequest): Promise<EvalResponse> => {
    sent.push(request);
    return { text: " B", reasoning: null, toolCalls: [], finishReason: "length", promptTokens: 9, completionTokens: 1,
      topLogprobs: [{ token: "ĠB", logprob: -0.2 }, { token: "ĠA", logprob: -1 }] };
  };
  const result = await TASKS.mmlu.run(item, 0, { send, ctx: { chatTemplate: true, enableThinking: false } });
  expect(result.outcome).toBe("1");
  const body = sent[0]!.body as Record<string, unknown>;
  expect(sent[0]!.route).toBe("completions");
  expect(body).toMatchObject({ max_tokens: 1, logprobs: true, top_logprobs: 11 });
  const demo = (i: number) => `Dev question ${i}?\nA. w\nB. x\nC. y\nD. z\nAnswer: ${"ABCD"[i % 4]}\n\n`;
  expect(body.prompt).toBe(`The following are multiple choice questions (with answers) about college physics.\n\n` +
    [0, 1, 2, 3, 4].map(demo).join("") + "Largest?\nA. a\nB. b\nC. c\nD. d\nAnswer:");
  expect(letterFromTopLogprobs([{ token: "▁D", logprob: -1 }, { token: "▁B", logprob: -1 }])).toBe(1);
  expect(letterFromTopLogprobs([{ token: "A", logprob: -0.1 }, { token: " C", logprob: -2 }])).toBe(2);
  expect(letterFromTopLogprobs([{ token: "Hello", logprob: -0.1 }])).toBeNull();
});

test("IFEval keeps main's strict/loose verifiers, unknown-ID pass and null-relation failure", () => {
  const instance = (ids: string[], kwargs: Record<string, unknown>[]) => ({ prompt: "p", instruction_id_list: ids, kwargs });
  const quoted = scoreIfevalInstance(instance(["startend:quotation"], [{}]), "Sure, here you go.\n\"quoted\"");
  expect([quoted.strict.pass, quoted.loose.pass]).toEqual([false, true]);
  const unknown = scoreIfevalInstance(instance(["punctuation:no_comma", "x:unknown"], [{}, {}]), "no commas");
  expect(unknown.strict).toMatchObject({ pass: true, instructionPasses: [true, null], unhandled: ["x:unknown"] });
  // A present-but-null relation raises in optiq, so the instruction fails.
  const nullRelation = scoreIfevalInstance(instance(["length_constraints:number_words"], [{ relation: null, num_words: 1 }]), "two words");
  expect(nullRelation.strict.pass).toBe(false);
  expect(scoreIfevalInstance(instance(["change_case:english_lowercase"], [{}]), "<think>X</think>lower").strict.pass).toBe(true);
});

test("BFCL extraction formats and the AST matcher follow main", () => {
  expect(extractToolCall("<tool_call>{\"name\": \"f\", \"arguments\": {\"x\": 1}}</tool_call>")).toEqual({ name: "f", arguments: { x: 1 } });
  expect(extractToolCall("<function=f><parameter=x>2</parameter></function>")).toEqual({ name: "f", arguments: { x: "2" } });
  expect(extractToolCall("<|tool_call>call:f{x:3,y:<|\"|>a<|\"|>}<tool_call|>")).toEqual({ name: "f", arguments: { x: 3, y: "a" } });
  // Main's bare-JSON pattern cannot span a nested object; non-object arguments read as {}.
  expect(extractToolCall("sure {\"function\": \"f\", \"args\": []}")).toEqual({ name: "f", arguments: {} });
  expect(extractToolCall("no call")).toBeNull();
  const gt = { f: { x: [1, 2], unit: ["", "cm"] } };
  expect(callsMatch({ name: "f", arguments: { x: "2" } }, gt)).toBe(true);
  expect(callsMatch({ name: "f", arguments: { x: 3 } }, gt)).toBe(false);
  expect(callsMatch({ name: "g", arguments: { x: 1 } }, gt)).toBe(false);
});

test("HumanEval completion truncation and program assembly follow main", () => {
  expect(truncateCompletion("```python\ndef f(x):\n    \"\"\"doc\"\"\"\n    return x\n```", "f")).toBe("    return x");
  expect(truncateCompletion("    return 1\n\ndef other():\n    pass", "f")).toBe("return 1\n");
  expect(truncateCompletion("<think>t</think>```py\nprint(1)\n```")).toBe("print(1)");
  expect(buildProgram("P", "C", "T", "f")).toBe("PC\n\nT\n\ncheck(f)\n");
  expect(humanevalBody("def f():\n", true)).toBe("Complete the following Python function. Output the complete function (header, docstring, body) " +
    "inside a single ```python ... ``` code block. No commentary outside the code block.\n\n```python\ndef f():\n```");
  expect(humanevalBody("def f():\n", false)).toBe("def f():\n");
  expect(extractPred("answer: abcdefghijklmnopq!")).toBe("abcdefghijklmnop");
  expect(extractPred(" none ")).toBe("none");
});

test("without a chat template, tasks complete the raw body as main did", async () => {
  const sent: EvalRequest[] = [];
  const send = async (request: EvalRequest): Promise<EvalResponse> => {
    sent.push(request);
    return { text: "#### 5", reasoning: null, toolCalls: [], finishReason: "stop", promptTokens: 1, completionTokens: 1, topLogprobs: null };
  };
  const ctx = { chatTemplate: false, enableThinking: false };
  await TASKS.gsm8k.run({ index: 0, question: "Q?", answer: "#### 5" }, 0, { send, ctx });
  await TASKS.bfcl.run({ index: 0, row: { id: "b", question: "call f", function: [{ name: "f" }], ground_truth: [{ f: {} }] } }, 0, { send, ctx });
  await TASKS.humaneval.run({ index: 0, task_id: "h", prompt: "def f():\n", test: "", entry_point: "f" }, 0,
    { send, ctx, verify: async () => ({ status: "verified" }) });
  expect(sent.map(r => r.route)).toEqual(["completions", "completions", "completions"]);
  expect((sent[0]!.body as { prompt: string }).prompt).toBe(gsm8kPrompt("Q?", 3));
  expect((sent[1]!.body as { prompt: string }).prompt.startsWith("Available tools:\n[\n  {\n    \"type\": \"function\"")).toBe(true);
  expect((sent[2]!.body as { prompt: string }).prompt).toBe("def f():\n");
});

test("task sets, capability aggregation and response parsing", () => {
  expect(parseTasks("all")).toEqual(["gsm8k", "mmlu", "ifeval", "bfcl", "humaneval", "hashhop", "gsm8k-50"]);
  expect(parseTasks("smoketest,mmlu")).toEqual(["mmlu", "gsm8k-50"]);
  expect(() => parseTasks("kl")).toThrow("unknown task kl");
  expect(computeCapabilityScore({ GSM8K: 50, MMLU: 70, HumanEval: Number.NaN }, 1.5)).toEqual({ score: 60, components: { GSM8K: 50, MMLU: 70 }, diskGb: 1.5 });
  expect(parseResponse("chat/completions", { choices: [{ message: { content: null, reasoning: "r",
    tool_calls: [{ function: { name: "f", arguments: { x: 1 } } }] }, finish_reason: "tool_calls" }], usage: { prompt_tokens: 3, completion_tokens: 2 } }))
    .toEqual({ text: "", reasoning: "r", toolCalls: [{ name: "f", arguments: "{\"x\":1}" }], finishReason: "tool_calls", promptTokens: 3,
      completionTokens: 2, topLogprobs: null });
  expect(parseResponse("completions", { choices: [{ text: " A", logprobs: { top_logprobs: [{ " A": -0.1, " B": -2 }] } }] }).topLogprobs)
    .toEqual([{ token: " A", logprob: -0.1 }, { token: " B", logprob: -2 }]);
  expect(() => parseResponse("completions", { error: "x" })).toThrow("without choices");
});

// ---- plan pins ---------------------------------------------------------------------------------
test("the plan pins main's datasets by content and refuses anything else", () => {
  const data = datasets(), lib = library(), dir = model();
  expect(Object.keys(DATASETS).sort()).toEqual(Object.keys(data.pins).sort());
  // The synthetic files are not main's revisions.
  expect(() => makePlan({ model: dir, data: data.dir, native: lib })).toThrow("not main's pinned revisions");
  const plan = makePlan({ model: dir, data: data.dir, native: lib, tasks: "gsm8k" }, data.pins);
  expect(plan.data.files.map(f => f.name)).toEqual(["gsm8k_optiq_frozen"]);
  expect(validatePlan(JSON.parse(JSON.stringify(plan)))).toEqual(plan);
  writeFileSync(join(data.dir, "gsm8k_optiq_frozen.jsonl"), jsonl([{ question: "changed", answer: "#### 1" }]));
  expect(() => makePlan({ model: dir, data: data.dir, native: lib, tasks: "gsm8k" }, data.pins)).toThrow("gsm8k_optiq_frozen");
  rmSync(join(data.dir, "hashhop_optiq_frozen.jsonl"));
  expect(() => makePlan({ model: dir, data: data.dir, native: lib, tasks: "hashhop" }, data.pins)).toThrow("dataset hashhop_optiq_frozen is missing");
  expect(() => makePlan({ model: dir, data: data.dir, native: lib, tasks: "gsm8k-50", pythonImage: "python:3.14" }, data.pins)).toThrow("pinned by digest");
  // Main's ChatTemplate.load: tokenizer_config's template, else chat_template.jinja; no readable config means none.
  const bare = model(false);
  expect([hasChatTemplate(dir), hasChatTemplate(bare)]).toEqual([true, false]);
  writeFileSync(join(bare, "chat_template.jinja"), "{{ x }}");
  expect(hasChatTemplate(bare)).toBe(true);
  rmSync(join(bare, "tokenizer_config.json"));
  expect(hasChatTemplate(bare)).toBe(false);
});

test("outputs are refused inside the evaluated tree and the runner's checkout", async () => {
  const f = fixture();
  await expect(run(f.plan, { root: f.root, command: f.command, out: join(f.root, "results") }, quick)).rejects.toThrow("inside source tree");
  await expect(run(f.plan, { root: f.root, command: [process.execPath, FAKE], out: join(fresh("out"), "run") }, quick))
    .rejects.toThrow("does not name a file inside");
  const inside = join(resolve(import.meta.dir, "../.."), "plan.json");
  const cli = Bun.spawnSync([process.execPath, CLI, "plan", "--out", inside, "--model", model(), "--data", fresh("data"), "--native", library()]);
  expect(cli.exitCode).not.toBe(0);
  expect(cli.stderr.toString()).toContain("inside source tree");
  expect(existsSync(inside)).toBe(false);
});

// ---- whole runs against the fake server ------------------------------------------------------------
let completeRun: { out: string; fixture: Fixture } | null = null;
test("a complete run: main's prompts, scoring, aggregation and provenance", async () => {
  const f = fixture(), out = join(fresh("run"), "main"), verifier = fakeVerifier();
  expect(await run(f.plan, { label: "main", root: f.root, command: f.command, out }, { ...quick, verifier: { verify: verifier.verify, image: f.planValue.pythonImage }, datasetPins: f.pins })).toBe(0);
  completeRun = { out, fixture: f };
  const result = readResult(out), q = qualification(result, f.pins);
  expect(q).toMatchObject({ complete: true, problems: [] });

  // Scores, per main's rules.
  expect(task(result, "gsm8k")).toMatchObject({ status: "complete", outcomes: "10", score: { nCorrect: 1, nTotal: 2, accuracy: 0.5 } });
  const drawn = sampleIndices(52, 50, 42), evens = drawn.filter(i => i % 2 === 0).length;
  expect(task(result, "gsm8k-50")).toMatchObject({ status: "complete", score: { nCorrect: evens, nTotal: 50 } });
  expect(task(result, "mmlu")).toMatchObject({ outcomes: "10", score: { nCorrect: 1, nTotal: 2, nUnscorable: 0 } });
  expect(task(result, "ifeval").score).toMatchObject({ nTotal: 2, strictAcc: 0.5, looseAcc: 1, strictInstructionAcc: 2 / 3,
    looseInstructionAcc: 1, coverage: { unhandledInstructionCounts: { "detectable_content:unknown_check": 1 } } });
  expect(task(result, "bfcl")).toMatchObject({ outcomes: "10", score: { nCorrect: 1, nNoCall: 0, nWrongName: 0, nWrongArgs: 1 } });
  // A timeout is the program's failure (main's rule), not an unverified sample.
  expect(task(result, "humaneval")).toMatchObject({ status: "complete", outcomes: "10", score: { nPass: 1, nTotal: 2, nUnverified: 0 } });
  expect(task(result, "hashhop").score).toMatchObject({ nCorrect: 1, accuracy: 0.5, byHops: { 1: 1 / 25, 2: 0, 3: 0, 4: 0 } });
  expect(result.capability).toMatchObject({ score: (50 + 50 + 50 + 50 + 50 + 50) / 6, excluded: [], diskGb: 13 / 1024 ** 3 });
  expect(Object.keys(result.capability!.components).sort()).toEqual(["BFCL", "GSM8K", "HashHop", "HumanEval", "IFEval", "MMLU"]);

  // Requests: greedy, no penalties, main's routes, limits and prompts.
  const log = requests(f.log);
  expect(log).toHaveLength(2 + 50 + 2 + 2 + 2 + 2 + 2);
  for (const { body } of log) expect(body).toMatchObject({ ...REQUEST_DEFAULTS, model: f.planValue.model.path });
  const by = (text: string) => log.find(({ body }) => (body.prompt ?? body.messages.at(-1).content).includes(text))!;
  expect(by("Q-ALPHA")).toMatchObject({ path: "/v1/chat/completions", body: { max_tokens: 256, chat_template_kwargs: { enable_thinking: false } } });
  expect(by("Q-ALPHA").body.messages).toEqual([{ role: "user", content: gsm8kPrompt("Q-ALPHA: Tom has 2 apples and gets 3 more. How many?", 3) }]);
  expect(by("MMLU-ONE")).toMatchObject({ path: "/v1/completions", body: { max_tokens: 1, logprobs: true, top_logprobs: 11 } });
  expect(by("MMLU-TWO").body.prompt).toBe("The following are multiple choice questions (with answers) about virology.\n\n" +
    "MMLU-TWO Which virus?\nA. a\nB. b\nC. c\nD. d\nAnswer:");
  expect(by("IF-ONE").body).toMatchObject({ max_tokens: 512, messages: [{ role: "user", content: "IF-ONE answer in lowercase without commas" }] });
  expect(by("BFCL-ONE").body).toMatchObject({ max_tokens: 512, chat_template_kwargs: { enable_thinking: false },
    messages: [{ role: "user", content: "BFCL-ONE find a library in Boston" }],
    tools: [{ type: "function", function: { name: "lib.find", description: "Find a library" } }] });
  expect(by("HE-ONE").body).toMatchObject({ max_tokens: 512, messages: [{ role: "user", content: humanevalBody(HUMANEVAL[0]!.prompt, true) }] });
  expect(by("HH-ONE").body).toMatchObject({ max_tokens: 32, messages: [{ role: "user", content: "HH-ONE walk the chain" }] });
  // HumanEval ran only through the verifier: the probe, then main's assembled programs.
  expect(verifier.programs).toEqual(["pass\n", buildProgram(HUMANEVAL[0]!.prompt, "    return a + b", HUMANEVAL[0]!.test, "add"),
    buildProgram(HUMANEVAL[1]!.prompt, "    while True:\n        pass", HUMANEVAL[1]!.test, "sub")]);

  // Provenance.
  const head = Bun.spawnSync(["git", "-C", f.root, "rev-parse", "HEAD"]).stdout.toString().trim();
  expect(result.tree.start).toMatchObject({ root: f.root, head, clean: true });
  expect(result.tree.end!.sha256).toBe(result.tree.start.sha256);
  expect(result.server.command!.slice(0, f.command.length)).toEqual(f.command);
  expect(result.server.command!.slice(f.command.length, -1)).toEqual(["--model", f.planValue.model.path, "--port"]);
  expect(result.server.runtime).toMatchObject({ executable: realpathSync(process.execPath), version: Bun.version });
  expect(result.server.models).toMatchObject({ data: [{ id: f.planValue.model.path }] });
  expect(result.server.loadedLibraries!.map(l => l.path)).toContain(f.planValue.native.files[0]!.path!);
  expect(result.server.processes.every(p => p.joined)).toBe(true);
  expect(result.plan).toMatchObject({ path: f.plan, sha256: sha256(readFileSync(f.plan)) });
  expect(result.plan.value.data.files.map(d => d.name).sort()).toEqual(Object.keys(f.pins).sort());
  for (const d of result.plan.value.data.files) expect(d.sha256).toBe(f.pins[d.name]!.sha256);
  expect(task(result, "gsm8k").datasets).toEqual([{ name: "gsm8k_optiq_frozen", sha256: f.pins.gsm8k_optiq_frozen!.sha256 }]);
  expect(task(result, "gsm8k-50").settings).toMatchObject({ selection: "sampleIndices(rows, 50, seed 42)", nShots: 3, maxTokens: 256 });
  expect(result.machine.chip).not.toBe("");
  expect(result.machine.memoryBytes).toBeGreaterThan(0);
  expect(result.machine.bun).toBe(Bun.version);
  expect(result.request).toMatchObject({ defaults: REQUEST_DEFAULTS, concurrency: 1 });
  expect(result.verifier).toEqual({ available: true, detail: `probe verified with image python@sha256:${"a".repeat(64)}` });
  expect(result.pins).toEqual({ start: [], end: [] });
  expect(task(result, "gsm8k-50").timing).toMatchObject({ requests: 50, completionTokens: 150 });
  expect(task(result, "gsm8k-50").timing.wallMs).toBeGreaterThan(0);
  // Per-sample detail beside the compact result; reasoning is recorded, not scored.
  const samples = readFileSync(join(out, "samples.jsonl"), "utf8").trim().split("\n").map(line => JSON.parse(line));
  expect(samples).toHaveLength(62);
  expect(samples.find(s => s.task === "ifeval" && s.index === 0)).toMatchObject({ outcome: "1", reasoning: "hidden plan, With, Commas",
    requests: [{ route: "chat/completions" }] });
  expect(samples.find(s => s.task === "bfcl" && s.index === 0)).toMatchObject({ id: "simple_1", kind: "correct", predicted: { name: "lib.find" } });
  expect(readFileSync(join(out, "report.md"), "utf8")).toContain("Capability_Score");
  expect(Bun.spawnSync(["git", "-C", f.root, "status", "--porcelain"]).stdout.toString()).toBe("");
}, 120_000);

test("an unavailable verifier skips HumanEval: nothing executes, capability names the exclusion", async () => {
  // The verifier module is resolved from a checkout; without it there is no execution path at all.
  const empty = fresh("checkout");
  const missing = await resolveVerifier(empty, null);
  expect(missing).toBe(`verifier unavailable: packages/module-datasets/src/python-verifier.ts is not in ${empty}`);
  // With the module present, its factory gets the plan's image; an unpinned image fails the probe.
  const stub = join(fresh("checkout"), "packages/module-datasets/src");
  mkdirSync(stub, { recursive: true });
  writeFileSync(join(stub, "python-verifier.ts"), `export const createPythonVerifier = (options) => async () =>
    ({ status: "unverified", reason: "image-unpinned", error: "image " + JSON.stringify(options.image ?? null) });`);
  const resolved = await resolveVerifier(resolve(stub, "../../.."), `python@sha256:${"b".repeat(64)}`);
  if (typeof resolved === "string") throw new Error(resolved);
  expect(resolved.image).toBe(`python@sha256:${"b".repeat(64)}`);
  expect(await probeVerifier(resolved.verify)).toContain(`probe unverified (image-unpinned): image "python@sha256:${"b".repeat(64)}"`);
  expect(await probeVerifier(async () => { throw new Error("broken module"); })).toContain("probe threw Error: broken module");

  const f = fixture(RULES, { tasks: "capability" }), out = join(fresh("run"), "run");
  const calls: string[] = [];
  const unpinned: VerifyPython = async (source): Promise<PythonVerification> => {
    calls.push(source);
    return { status: "unverified", reason: "image-unpinned", error: "no digest-pinned verifier image is configured" };
  };
  expect(await run(f.plan, { root: f.root, command: f.command, out }, { ...quick, verifier: { verify: unpinned, image: null }, datasetPins: f.pins })).toBe(1);
  expect(calls).toEqual(["pass\n"]);
  const result = readResult(out);
  expect(task(result, "humaneval")).toMatchObject({ status: "skipped", outcomes: "", score: null,
    reason: "verifier unavailable: probe unverified (image-unpinned): no digest-pinned verifier image is configured" });
  expect(requests(f.log).some(({ body }) => JSON.stringify(body).includes("HE-ONE"))).toBe(false);
  expect(result.capability!.excluded).toEqual([`HumanEval: skipped (${task(result, "humaneval").reason})`]);
  expect(Object.keys(result.capability!.components)).not.toContain("HumanEval");
  expect(qualification(result, f.pins).problems).toContain(`humaneval: skipped — ${task(result, "humaneval").reason}`);
  // The default resolution with no module in the checkout skips the same way.
  const g = fixture(RULES, { tasks: "humaneval" }), out2 = join(fresh("run"), "run");
  expect(await run(g.plan, { root: g.root, command: g.command, out: out2 }, { ...quick, verifier: missing as string, datasetPins: g.pins })).toBe(1);
  expect(task(readResult(out2), "humaneval")).toMatchObject({ status: "skipped", reason: missing });
}, 120_000);

test("unscorable samples, failed requests and a server exit make the run incomplete", async () => {
  const rules: FakeRule[] = [{ match: "MMLU-ONE", topLogprobs: [{ token: "Hello", logprob: -0.1 }] }, { match: "MMLU-TWO", status: 500 },
    { match: "IF-TWO", exit: true }, ...RULES];
  const f = fixture(rules, { tasks: "mmlu,ifeval,hashhop" }), out = join(fresh("run"), "run");
  expect(await run(f.plan, { root: f.root, command: f.command, out }, { ...quick, datasetPins: f.pins })).toBe(1);
  const result = readResult(out);
  expect(task(result, "mmlu")).toMatchObject({ status: "incomplete", outcomes: "UE", score: { nCorrect: 0, nTotal: 2, nUnscorable: 1 } });
  expect(task(result, "mmlu").errors[0]).toMatchObject({ index: 1, id: "mmlu_optiq_frozen/1" });
  expect(task(result, "mmlu").errors[0]!.error).toContain("HTTP 500");
  expect(task(result, "ifeval")).toMatchObject({ status: "incomplete", outcomes: "1E" });
  // The failed IFEval sample fails every supported instruction instead of vanishing.
  expect(task(result, "ifeval").score).toMatchObject({ nTotal: 2, strictAcc: 0.5, strictInstructionAcc: 2 / 3 });
  expect(result.fatal).toContain("server exited (code 3");
  expect(task(result, "hashhop")).toMatchObject({ status: "skipped", reason: `not run: ${result.fatal}` });
  expect(result.capability!.excluded).toHaveLength(3);
  expect(result.server.processes.every(p => p.joined)).toBe(true);
  expect(qualification(result, f.pins).problems.join("\n")).toContain("provenance incomplete");
}, 120_000);

test("a parent SIGTERM stops and joins the server, saves the result and exits 130", async () => {
  const f = fixture([{ match: "HH-ONE", delayMs: 60_000, content: "late" }, ...RULES], { tasks: "hashhop" }), out = join(fresh("run"), "run");
  const child = Bun.spawn([process.execPath, CLI, "run", "--plan", f.plan, "--root", f.root, "--command", JSON.stringify(f.command),
    "--out", out], { stdout: "pipe", stderr: "pipe" });
  for (let i = 0; i < 150 && !(existsSync(f.log) && readFileSync(f.log, "utf8").includes("HH-ONE")); i++) await Bun.sleep(100);
  child.kill("SIGTERM");
  expect(await child.exited).toBe(130);
  const result = readResult(out);
  expect(result).toMatchObject({ interrupted: "SIGTERM" });
  expect(task(result, "hashhop")).toMatchObject({ status: "incomplete", outcomes: "--", errors: [] });
  expect(result.server.processes.length).toBeGreaterThan(0);
  expect(result.server.processes.every(p => p.joined)).toBe(true);
  expect(qualification(result, f.pins).problems).toContain("interrupted (SIGTERM)");
  expect(Bun.spawnSync(["pgrep", "-f", f.command[3]!]).stdout.toString().trim()).toBe("");
}, 60_000);

// ---- paired comparison ----------------------------------------------------------------------------
test("compare flags every score difference, sample flip, skip and provenance mismatch", () => {
  expect(completeRun).not.toBeNull();
  const { out, fixture: f } = completeRun!;
  const base = readResult(out);
  const same = compare(base, { ...structuredClone(base), label: "candidate" }, f.pins);
  expect(same).toMatchObject({ problems: [], differences: 0 });
  expect(same.markdown).toContain("comparable: yes");

  const candidate = structuredClone(base);
  candidate.label = "candidate";
  const gsm = task(candidate, "gsm8k");
  gsm.outcomes = "11";
  gsm.score = { ...gsm.score!, nCorrect: 2, accuracy: 1 };
  candidate.capability!.score += 50 / 6;
  const humaneval = task(candidate, "humaneval");
  Object.assign(humaneval, { status: "skipped", reason: "verifier unavailable: docker-missing", outcomes: "", score: null });
  const result = compare(base, candidate, f.pins);
  expect(result.problems).toEqual(["candidate: humaneval: skipped — verifier unavailable: docker-missing"]);
  expect(result.markdown).toContain("| gsm8k | accuracy | 50.00% | 100.00% | **⚠ differs** |");
  expect(result.markdown).toContain("| gsm8k | nCorrect | 1 | 2 | **⚠ differs** |");
  expect(result.markdown).toContain("| gsm8k | nTotal | 2 | 2 | equal |");
  expect(result.markdown).toContain("- gsm8k: 1 of 2 samples differ: 1 (0→1)");
  expect(result.markdown).toContain("| humaneval | status | complete | skipped: verifier unavailable: docker-missing | **⚠ skipped** |");
  expect(result.markdown).toContain("| capability | Capability_Score |");
  expect(result.differences).toBeGreaterThanOrEqual(6);

  // Different inputs are incomparable, whatever the scores say.
  const other = structuredClone(base);
  other.plan = { ...other.plan, sha256: "0".repeat(64), value: { ...other.plan.value, enableThinking: true } };
  other.machine = { ...other.machine, chip: "Other chip" };
  const mismatch = compare(base, other, f.pins);
  expect(mismatch.problems.join("\n")).toContain("different plans (");
  expect(mismatch.problems.join("\n")).toContain("enableThinking differ");
  expect(mismatch.markdown).toContain("flag: machine chip differs");
  // Against the real pins, synthetic datasets are never main's revisions.
  expect(compare(base, base).problems.join("\n")).toContain("is not the pinned revision");
});
