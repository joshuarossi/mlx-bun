// Main's capability tasks (scripts/eval.ts at 02d723a) as HTTP requests to an
// OpenAI-compatible server. Datasets, selection, prompts, token limits,
// extraction and scoring are main's (scoring.ts, ifeval.ts, bfcl.ts); only
// generation moves from main's in-process engine to the server:
//
// - generateText(body, {useChat}) becomes a chat request with one user turn
//   when the model has a chat template (the server renders it), otherwise a
//   raw /v1/completions request, exactly main's template/no-template split.
// - Greedy decoding with no logits processors: temperature 0 and
//   repetition_penalty 0 (disabled) on every request, so a server's
//   generation_config penalty never applies, as it never did in main's eval.
// - Scores read the server's final answer (`content`); reasoning the server
//   split off is recorded, not scored (main dropped text up to `</think>`).
// - MMLU: main took the argmax of the " A".." D" token logits after the raw
//   5-shot prompt with its BOS stripped. Over HTTP the prompt is tokenized by
//   the server (with the tokenizer's own BOS), and the argmax is taken over the
//   letters present in the first position's top logprobs; a letter outside
//   them ranks below every listed token. No listed letter is unscorable.
// - BFCL with a chat template sends `tools` to the server's template (main
//   rendered the same template in-process); a server-parsed tool call is
//   scored, else main's extractor reads the content.
// - HumanEval executes only through the injected Docker verifier.
//
// Main's in-process runner decoded with a raw-forward argmax loop; this runner
// measures each server's served greedy path, so its scores compare servers
// under one runner rather than reproduce main's historical in-process numbers.
import { aggregateIfevalScores, scoreIfevalInstance, unscoredIfevalInstance, type IfevalInstance, type IfevalInstanceScore } from "./ifeval";
import { buildPrompt as bfclTextPrompt, callsMatch, extractToolCall, gtName, parseGroundTruth, toolCallFromJsonObject, userText,
  wrapToolsForChat, type BfclFrozenRow, type ToolCall } from "./bfcl";
import { buildProgram, extractAnswer, extractPred, groundTruth, gsm8kPrompt, LETTERS, mmluPrompt, sampleIndices, toNum,
  truncateCompletion, type MmluRow, type TaskName } from "./scoring";

export type TaskId = "gsm8k" | "mmlu" | "ifeval" | "bfcl" | "humaneval" | "hashhop" | "gsm8k-50";
/** Main's capability suite in its run order (scripts/eval.ts GEN_TASKS). */
export const CAPABILITY: readonly TaskId[] = ["gsm8k", "mmlu", "ifeval", "bfcl", "humaneval", "hashhop"];
/** Main's smoketest without KL (in-process logits have no HTTP equivalent). */
export const SMOKETEST: readonly TaskId[] = ["gsm8k-50"];
export const ALL_TASKS: readonly TaskId[] = [...CAPABILITY, ...SMOKETEST];

// ---- requests -------------------------------------------------------------------
export interface ChatRequest {
  route: "chat/completions";
  body: { messages: Array<{ role: "user"; content: string }>; max_tokens: number;
    chat_template_kwargs: { enable_thinking: boolean }; tools?: unknown[] };
}
export interface TextRequest {
  route: "completions";
  body: { prompt: string; max_tokens: number; logprobs?: true; top_logprobs?: number };
}
export type EvalRequest = ChatRequest | TextRequest;
export interface EvalResponse {
  /** Chat `message.content` ("" when null) or the completion `text`. */
  text: string;
  reasoning: string | null;
  toolCalls: Array<{ name: string; arguments: string }>;
  finishReason: string | null;
  promptTokens: number | null;
  completionTokens: number | null;
  /** The first generated position's top logprobs, when requested. */
  topLogprobs: Array<{ token: string; logprob: number }> | null;
}
export type Send = (request: EvalRequest, signal?: AbortSignal) => Promise<EvalResponse>;

// ---- the Docker Python verifier seam ------------------------------------------------
/** Structurally the datasets module's `python-verifier.ts` contract (PR #223):
 * `verified` only for a zero exit within every limit; never host execution. */
export type PythonVerification =
  | { status: "verified" }
  | { status: "failed"; exitCode: number; error: string }
  | { status: "unverified"; reason: string; error: string };
export type VerifyPython = (source: string, signal?: AbortSignal) => Promise<PythonVerification>;
/** Unverified reasons that are the program's own outcome: main scored a program
 * that did not exit 0 within its time and memory limits as a failure. */
const PROGRAM_OUTCOMES = new Set(["timeout", "oom"]);

export interface TaskContext { chatTemplate: boolean; enableThinking: boolean }
export interface TaskEnv { send: Send; ctx: TaskContext; verify?: VerifyPython; signal?: AbortSignal }
/** "1" correct, "0" incorrect, "U" not scorable by main's rule; the runner adds "E" for a failed request. */
export type Outcome = "1" | "0" | "U";
export interface SampleResult { outcome: Outcome; detail: Record<string, unknown> }
export interface ScoredSample { outcome: Outcome | "E"; detail?: Record<string, unknown> }
export type TaskScore = Record<string, unknown> & { accuracy: number; nTotal: number };

export interface TaskDefinition<Item = unknown> {
  id: TaskId;
  /** Capability component (main's TaskName); the smoketest subset has none. */
  component: TaskName | null;
  /** Dataset files (without .jsonl) under the pinned data directory. */
  datasets: string[];
  settings(ctx: TaskContext): Record<string, unknown>;
  /** Main's selection: which rows, in which order. */
  select(rows: Record<string, unknown[]>): Item[];
  itemId(item: Item, index: number): string;
  run(item: Item, index: number, env: TaskEnv): Promise<SampleResult>;
  score(items: Item[], samples: ScoredSample[]): TaskScore;
  /** Executes generated code: skipped unless the verifier is available. */
  needsVerifier?: true;
}

/** Main's generateText routing: one templated user turn, else the raw body. */
export function generateRequest(body: string, options: { maxTokens: number; useChat: boolean }, ctx: TaskContext): EvalRequest {
  return options.useChat && ctx.chatTemplate
    ? { route: "chat/completions", body: { messages: [{ role: "user", content: body }], max_tokens: options.maxTokens,
      chat_template_kwargs: { enable_thinking: ctx.enableThinking } } }
    : { route: "completions", body: { prompt: body, max_tokens: options.maxTokens } };
}

const response = (res: EvalResponse) => ({ text: res.text, ...(res.reasoning ? { reasoning: res.reasoning } : {}),
  finishReason: res.finishReason, promptTokens: res.promptTokens, completionTokens: res.completionTokens });
const count = (samples: ScoredSample[], outcome: string) => samples.filter(s => s.outcome === outcome).length;
function accuracyScore(samples: ScoredSample[], extra: Record<string, number> = {}): TaskScore {
  const nCorrect = count(samples, "1"), nTotal = samples.length;
  return { nCorrect, nTotal, accuracy: nTotal ? nCorrect / nTotal : 0, ...extra };
}

// ---- GSM8K ---------------------------------------------------------------------------
interface Gsm8kItem { index: number; question: string; answer: string }
const GSM8K_SHOTS = 3, GSM8K_MAX_TOKENS = 256;
async function runGsm8k(item: Gsm8kItem, env: TaskEnv): Promise<SampleResult> {
  const res = await env.send(generateRequest(gsm8kPrompt(item.question, GSM8K_SHOTS), { maxTokens: GSM8K_MAX_TOKENS, useChat: true }, env.ctx), env.signal);
  const gt = toNum(groundTruth(item.answer)), pred = toNum(extractAnswer(res.text));
  const correct = gt !== null && pred !== null && Math.abs(gt - pred) < 1e-3;
  return { outcome: correct ? "1" : "0", detail: { ...response(res), groundTruth: gt, predicted: pred } };
}
const gsm8kSettings = (source: string, selection: string) => (ctx: TaskContext) =>
  ({ source, selection, nShots: GSM8K_SHOTS, maxTokens: GSM8K_MAX_TOKENS, route: ctx.chatTemplate ? "chat/completions" : "completions",
    enableThinking: ctx.enableThinking });

const gsm8k: TaskDefinition<Gsm8kItem> = {
  id: "gsm8k", component: "GSM8K", datasets: ["gsm8k_optiq_frozen"],
  settings: gsm8kSettings("gsm8k_optiq_frozen", "every row in order (main's default frozen mode ignores --n)"),
  select: rows => (rows.gsm8k_optiq_frozen as Gsm8kItem[]).map((row, index) => ({ index, question: row.question, answer: row.answer })),
  itemId: item => `gsm8k_optiq_frozen/${item.index}`,
  run: (item, _index, env) => runGsm8k(item, env),
  score: (_items, samples) => accuracyScore(samples),
};

/** Main's GSM8K-50 smoketest draw: evaluateGsm8k({nSamples: 50}) honors the
 * 50 only on the full export (sampleIndices, seed 42); under main's default
 * frozen flag it silently ran all 1000 frozen questions instead. */
export const GSM8K_50 = { n: 50, seed: 42 } as const;
const gsm8k50: TaskDefinition<Gsm8kItem> = {
  id: "gsm8k-50", component: null, datasets: ["gsm8k"],
  settings: gsm8kSettings("gsm8k", `sampleIndices(rows, ${GSM8K_50.n}, seed ${GSM8K_50.seed})`),
  select: rows => {
    const all = rows.gsm8k as Array<{ question: string; answer: string }>;
    return sampleIndices(all.length, GSM8K_50.n, GSM8K_50.seed).map(index => ({ index, question: all[index]!.question, answer: all[index]!.answer }));
  },
  itemId: item => `gsm8k/${item.index}`,
  run: (item, _index, env) => runGsm8k(item, env),
  score: (_items, samples) => accuracyScore(samples),
};

// ---- MMLU ------------------------------------------------------------------------------
interface MmluItem { index: number; row: MmluRow; dev: MmluRow[] }
const MMLU_SHOTS = 5;
/** Main's server cap for top_logprobs (mlx_lm.server's validation). */
export const MMLU_TOP_LOGPROBS = 11;
/** A vocabulary piece as text: byte-level BPE writes a leading space as "Ġ",
 * SentencePiece as "▁"; servers report raw pieces. */
const pieceText = (token: string) => token.replace(/^[Ġ▁]/, " ");
/** Index 0..3 of the highest-logprob " A".." D" token among the listed top
 * logprobs (first wins ties, as main's strict `>` argmax), or null. */
export function letterFromTopLogprobs(top: ReadonlyArray<{ token: string; logprob: number }>): number | null {
  const found: Array<number | null> = LETTERS.map(() => null);
  for (const entry of top) {
    const i = LETTERS.findIndex(letter => pieceText(entry.token) === ` ${letter}`);
    if (i >= 0 && found[i] === null) found[i] = entry.logprob;
  }
  let best: number | null = null, bestValue = -Infinity;
  found.forEach((value, i) => { if (value !== null && value > bestValue) { bestValue = value; best = i; } });
  return best;
}
const mmlu: TaskDefinition<MmluItem> = {
  id: "mmlu", component: "MMLU", datasets: ["mmlu_optiq_frozen", "mmlu_optiq_dev"],
  settings: () => ({ source: "mmlu_optiq_frozen with mmlu_optiq_dev exemplars", selection: "every row in order (main's default frozen mode)",
    nShots: MMLU_SHOTS, route: "completions", maxTokens: 1, logprobs: true, topLogprobs: MMLU_TOP_LOGPROBS,
    scoring: "argmax of the ' A'..' D' pieces among the first position's top logprobs; none listed is unscorable" }),
  select: rows => {
    // Per-subject dev exemplars for prompt construction (main's devBySubject).
    const devBySubject = new Map<string, MmluRow[]>();
    for (const ex of rows.mmlu_optiq_dev as MmluRow[]) {
      const list = devBySubject.get(ex.subject) ?? [];
      list.push(ex);
      devBySubject.set(ex.subject, list);
    }
    return (rows.mmlu_optiq_frozen as MmluRow[]).map((row, index) => ({ index, row, dev: devBySubject.get(row.subject) ?? [] }));
  },
  itemId: item => `mmlu_optiq_frozen/${item.index}`,
  run: async (item, _index, env) => {
    const res = await env.send({ route: "completions", body: { prompt: mmluPrompt(item.row, item.dev, MMLU_SHOTS), max_tokens: 1,
      logprobs: true, top_logprobs: MMLU_TOP_LOGPROBS } }, env.signal);
    const predicted = letterFromTopLogprobs(res.topLogprobs ?? []);
    return { outcome: predicted === null ? "U" : predicted === item.row.answer ? "1" : "0",
      detail: { ...response(res), topLogprobs: res.topLogprobs, predicted, answer: item.row.answer,
        ...(predicted === null ? { unscorable: res.topLogprobs ? "no answer letter among the top logprobs" : "no top logprobs returned" } : {}) } };
  },
  score: (_items, samples) => accuracyScore(samples, { nUnscorable: count(samples, "U") }),
};

// ---- IFEval ------------------------------------------------------------------------------
interface IfevalItem { index: number; instance: IfevalInstance }
const IFEVAL_MAX_TOKENS = 512;
const ifeval: TaskDefinition<IfevalItem> = {
  id: "ifeval", component: "IFEval", datasets: ["ifeval_optiq_frozen"],
  settings: ctx => ({ source: "ifeval_optiq_frozen", selection: "every row in order (main's default frozen mode)", maxTokens: IFEVAL_MAX_TOKENS,
    route: ctx.chatTemplate ? "chat/completions" : "completions", enableThinking: ctx.enableThinking, headline: "prompt-level strict" }),
  select: rows => (rows.ifeval_optiq_frozen as Array<Partial<IfevalInstance> & { prompt: string }>).map((row, index) => {
    const iids = row.instruction_id_list ?? [];
    return { index, instance: { prompt: row.prompt, instruction_id_list: iids, kwargs: row.kwargs ?? iids.map(() => ({})) } };
  }),
  itemId: item => `ifeval_optiq_frozen/${item.index}`,
  run: async (item, _index, env) => {
    const res = await env.send(generateRequest(item.instance.prompt, { maxTokens: IFEVAL_MAX_TOKENS, useChat: true }, env.ctx), env.signal);
    const score = scoreIfevalInstance(item.instance, res.text);
    return { outcome: score.strict.pass ? "1" : "0", detail: { ...response(res), score } };
  },
  // Spread: an interface has no index signature.
  score: (items, samples) => ({ ...aggregateIfevalScores(items.map((item, i) => ({ instance: item.instance,
    score: samples[i]!.outcome === "E" ? unscoredIfevalInstance(item.instance) : samples[i]!.detail!.score as IfevalInstanceScore }))) }),
};

// ---- BFCL ----------------------------------------------------------------------------------
interface BfclItem { index: number; row: BfclFrozenRow }
const BFCL_MAX_TOKENS = 512;
/** A server-parsed call, read as main read a JSON call object. */
const serverCall = (call: { name: string; arguments: string }): ToolCall | null =>
  toolCallFromJsonObject({ name: call.name, arguments: call.arguments });
const bfcl: TaskDefinition<BfclItem> = {
  id: "bfcl", component: "BFCL", datasets: ["bfcl_optiq_frozen"],
  settings: ctx => ({ source: "bfcl_optiq_frozen", selection: "every row in order (main's default frozen mode)", maxTokens: BFCL_MAX_TOKENS,
    prompt: ctx.chatTemplate ? "user turn with tools through the server's chat template, thinking off" : "main's textual-fallback prompt, raw completion",
    route: ctx.chatTemplate ? "chat/completions" : "completions", enableThinking: false }),
  select: rows => (rows.bfcl_optiq_frozen as BfclFrozenRow[]).map((row, index) => ({ index, row })),
  itemId: item => item.row.id ?? `bfcl_optiq_frozen/${item.index}`,
  run: async (item, _index, env) => {
    const text = userText(item.row.question), tools = wrapToolsForChat(item.row.function);
    // Main: tools through the chat template (thinking off), else the textual fallback.
    const request: EvalRequest = env.ctx.chatTemplate
      ? { route: "chat/completions", body: { messages: [{ role: "user", content: text }], max_tokens: BFCL_MAX_TOKENS,
        chat_template_kwargs: { enable_thinking: false }, tools } }
      : generateRequest(bfclTextPrompt(text, tools), { maxTokens: BFCL_MAX_TOKENS, useChat: true }, env.ctx);
    const res = await env.send(request, env.signal);
    const predicted = res.toolCalls.length ? serverCall(res.toolCalls[0]!) : extractToolCall(res.text);
    const gt = parseGroundTruth(item.row.ground_truth);
    const kind = predicted === null ? "noCall" : !callsMatch(predicted, gt)
      ? (String(predicted.name ?? "").trim() !== gtName(gt).trim() ? "wrongName" : "wrongArgs") : "correct";
    return { outcome: kind === "correct" ? "1" : "0", detail: { ...response(res), toolCalls: res.toolCalls, predicted, kind } };
  },
  score: (_items, samples) => {
    const kinds = samples.map(s => s.outcome === "E" ? "error" : s.detail!.kind);
    const n = (kind: string) => kinds.filter(k => k === kind).length;
    return accuracyScore(samples, { nNoCall: n("noCall"), nWrongName: n("wrongName"), nWrongArgs: n("wrongArgs") });
  },
};

// ---- HumanEval ---------------------------------------------------------------------------------
interface HumanevalItem { index: number; task_id: string; prompt: string; test: string; entry_point: string }
const HUMANEVAL_MAX_TOKENS = 512;
/** Main's instruct body for templated models (humaneval.py's use_chat path). */
export function humanevalBody(prompt: string, useChat: boolean): string {
  return useChat
    ? "Complete the following Python function. Output the " +
      "complete function (header, docstring, body) inside a " +
      "single ```python ... ``` code block. No commentary " +
      "outside the code block.\n\n" +
      "```python\n" + prompt + "```"
    : prompt;
}
const humaneval: TaskDefinition<HumanevalItem> = {
  id: "humaneval", component: "HumanEval", datasets: ["humaneval_optiq_frozen"], needsVerifier: true,
  settings: ctx => ({ source: "humaneval_optiq_frozen", selection: "every row in order (main's default frozen mode)",
    maxTokens: HUMANEVAL_MAX_TOKENS, useChat: ctx.chatTemplate, route: ctx.chatTemplate ? "chat/completions" : "completions",
    enableThinking: ctx.enableThinking, execution: "injected Docker verifyPython(program); pass = verified; failed, timeout and OOM fail",
    program: "prompt + completion + test + check(entry_point), without main's host-sandbox preamble" }),
  select: rows => (rows.humaneval_optiq_frozen as Omit<HumanevalItem, "index">[]).map((row, index) =>
    ({ index, task_id: row.task_id, prompt: row.prompt, test: row.test, entry_point: row.entry_point })),
  itemId: item => item.task_id,
  run: async (item, _index, env) => {
    if (!env.verify) throw new Error("HumanEval requires the Docker Python verifier");
    // Main: the chat path exactly when the model has a chat template.
    const useChat = env.ctx.chatTemplate;
    const res = await env.send(generateRequest(humanevalBody(item.prompt, useChat), { maxTokens: HUMANEVAL_MAX_TOKENS, useChat }, env.ctx), env.signal);
    const completion = truncateCompletion(res.text, item.entry_point);
    const verification = await env.verify(buildProgram(item.prompt, completion, item.test, item.entry_point), env.signal);
    const outcome: Outcome = verification.status === "verified" ? "1" : verification.status === "failed" ? "0"
      : PROGRAM_OUTCOMES.has(verification.reason) ? "0" : "U";
    return { outcome, detail: { ...response(res), completion, verification } };
  },
  score: (_items, samples) => {
    const nPass = count(samples, "1"), nTotal = samples.length;
    return { nPass, nTotal, accuracy: nTotal ? nPass / nTotal : 0, nUnverified: count(samples, "U") };
  },
};

// ---- HashHop -------------------------------------------------------------------------------------
interface HashhopItem { index: number; raw_problem: string; expected: string }
const HASHHOP = { maxTokens: 32, nPerHop: 25, hopsList: [1, 2, 3, 4] } as const;
/** Main labels frozen rows by position: optiq emitted 25 per hop count, in hop order. */
const hopsOf = (k: number) => HASHHOP.hopsList[Math.floor(k / HASHHOP.nPerHop)] ?? 0;
const hashhop: TaskDefinition<HashhopItem> = {
  id: "hashhop", component: "HashHop", datasets: ["hashhop_optiq_frozen"],
  settings: ctx => ({ source: "hashhop_optiq_frozen (~12k-character dictionaries)", selection: "every row in order (main's default frozen mode)",
    maxTokens: HASHHOP.maxTokens, nPerHop: HASHHOP.nPerHop, hopsList: HASHHOP.hopsList,
    route: ctx.chatTemplate ? "chat/completions" : "completions", enableThinking: ctx.enableThinking }),
  select: rows => (rows.hashhop_optiq_frozen as Omit<HashhopItem, "index">[]).map((row, index) =>
    ({ index, raw_problem: row.raw_problem, expected: row.expected })),
  itemId: item => `hashhop_optiq_frozen/${item.index}`,
  run: async (item, index, env) => {
    const res = await env.send(generateRequest(item.raw_problem, { maxTokens: HASHHOP.maxTokens, useChat: true }, env.ctx), env.signal);
    const predicted = extractPred(res.text);
    return { outcome: predicted === item.expected ? "1" : "0", detail: { ...response(res), predicted, expected: item.expected, hops: hopsOf(index) } };
  },
  score: (_items, samples) => {
    const hopCorrect: Record<number, number> = {};
    samples.forEach((sample, k) => { if (sample.outcome === "1") hopCorrect[hopsOf(k)] = (hopCorrect[hopsOf(k)] ?? 0) + 1; });
    const byHops: Record<number, number> = {};
    for (const h of HASHHOP.hopsList) byHops[h] = (hopCorrect[h] ?? 0) / HASHHOP.nPerHop;
    return { ...accuracyScore(samples), byHops };
  },
};

export const TASKS: Record<TaskId, TaskDefinition<any>> = { gsm8k, mmlu, ifeval, bfcl, humaneval, hashhop, "gsm8k-50": gsm8k50 };

/** `capability`, `smoketest`, `all`, or a comma list of task ids, in main's order. */
export function parseTasks(spec: string): TaskId[] {
  const chosen = new Set<TaskId>();
  for (const part of spec.split(",").map(s => s.trim()).filter(Boolean)) {
    if (part === "all") ALL_TASKS.forEach(t => chosen.add(t));
    else if (part === "capability") CAPABILITY.forEach(t => chosen.add(t));
    else if (part === "smoketest") SMOKETEST.forEach(t => chosen.add(t));
    else if (part in TASKS) chosen.add(part as TaskId);
    else throw new Error(`unknown task ${part}; tasks: ${ALL_TASKS.join(", ")}, capability, smoketest, all`);
  }
  if (!chosen.size) throw new Error("no tasks selected");
  return ALL_TASKS.filter(t => chosen.has(t));
}
