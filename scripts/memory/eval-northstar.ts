// The Dreaming — P9-T2 NORTH-STAR ACCEPTANCE HARNESS.
//
// Runs the six frozen north-star queries (northstar-queries.json: Q1 lens-reach,
// Q2 camera-why, Q3 M42-adaptable, Q4 anamorphic-best, Q5 list-every-lens [the
// 150 KB killer], Q6 astrophotography negative control) through the READ PATH
// ONLY against the smoke vault, and grades the model's ANSWER with the cloud
// judge (scripts/memory/judge-answer.ts).
//
// The read path is deliberately trivial: FIND the article (memory_resolve a name
// / memory_category a type) -> READ small (memory_read TOC, memory_section the one
// relevant section). The model then GENERATES the answer from those small reads
// via loadTaskModel(MODEL_ID)/generateText — never re-implementing prompt->ids.
// There is NO vector search and NO infobox-field filter anywhere on this path.
//
// FIVE GATES per query:
//   1. correctness   — the cloud judge grades the answer correct + un-confabulated
//   2. context_budget — no single read > 2 KB, query context within the 8 KB ceiling
//   3. no_vector      — the read-path embedding tripwire stayed at 0 (src/embed.ts)
//   4. local_only     — no network call escaped during retrieve+generate
//   5. silent         — no "per the wiki…" retrieval-report leak (regex + judge)
//
// Suite gates (PLAN P9-T2): >=5/6 correctness (Q6 MUST pass), mean_context_kb < 5,
// max_read_kb < 2, hot_path_embed_calls == 0.
//
// Run modes:
//   bun scripts/memory/eval-northstar.ts --dry      # structural run, stub answerer, no GPU/judge
//   ANTHROPIC_API_KEY=… bun scripts/memory/eval-northstar.ts   # full GPU + cloud-judge run (RunJudge)
//
// The build-machine FINAL numbers come AFTER Josh runs the full-corpus bootstrap
// (P6-T5, USER-ACTION); here the harness is proved on the smoke vault.

import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

import { getEmbedCounter, resetEmbedCounter } from "../../src/embed";
import { generateText, loadTaskModel, type TaskModel } from "../../src/eval/runner";
import { MODEL_ID } from "../../src/memory/model";
import { createMemoryTools } from "../../src/memory/tools";
import {
  detectSilentViolation,
  gradeAnswer,
  type AnswerCase,
  type AnswerVerdict,
} from "./judge-answer";

// ---- frozen query set --------------------------------------------------

export interface ToolStep {
  tool: string;
  params: Record<string, unknown>;
}
export interface NorthstarQuery {
  id: string;
  label: string;
  question: string;
  intent: string;
  expected_points: string[];
  gold_answer: string;
  negative_control: boolean;
  retrieval: { find: ToolStep[]; read: ToolStep[] };
}
export interface NorthstarQuerySet {
  version: string;
  frozen: boolean;
  vault: string;
  note: string;
  queries: NorthstarQuery[];
}

const QUERIES_PATH = join(import.meta.dir, "northstar-queries.json");

/** Load the frozen Q1-Q6 set. Pure read of the committed JSON. */
export function loadQueries(): NorthstarQuerySet {
  return JSON.parse(readFileSync(QUERIES_PATH, "utf8")) as NorthstarQuerySet;
}

/** Smoke vault the read path points at (MLX_BUN_WIKI override honored by vault.ts). */
export function smokeVaultRoot(): string {
  return process.env.MLX_BUN_WIKI ?? `${process.env.HOME}/.mlx-bun/wiki-smoke`;
}

// ---- budgets + gate names ---------------------------------------------

/** No single memory_read / memory_section may exceed this (R4 anti-blob). */
export const MAX_READ_BYTES = 2 * 1024;
/** Hard per-query context ceiling (PLAN: 8 KB ceiling, < 5 KB mean). */
export const MAX_CONTEXT_BYTES = 8 * 1024;
/** Suite mean-context target. */
export const MEAN_CONTEXT_TARGET_BYTES = 5 * 1024;

export const GATE_NAMES = [
  "correctness",
  "context_budget",
  "no_vector",
  "local_only",
  "silent",
] as const;
export type GateName = (typeof GATE_NAMES)[number];

// ---- silent-colleague leak detector -----------------------------------

/** A silent colleague answers as a continuation, never as a retrieval report
 *  ("per the wiki…", "according to your notes…", "welcome back…"). Reuses the
 *  canonical deterministic detector in judge-answer.ts — one regex, not two. */
export function violatesSilent(answer: string): boolean {
  return detectSilentViolation(answer).violation;
}

// ---- no-network interceptor (local_only gate) -------------------------

/** Run `fn` with global fetch blocked + recorded, so any escape during the
 *  retrieve+generate phase is caught. The read path + local model make ZERO
 *  network calls; the cloud judge is invoked OUTSIDE this guard. */
export async function withNetworkGuard<T>(
  fn: () => Promise<T>,
): Promise<{ result: T; attempts: string[]; error?: string }> {
  const attempts: string[] = [];
  const realFetch = globalThis.fetch;
  globalThis.fetch = ((input: unknown, _init?: unknown) => {
    const url =
      typeof input === "string"
        ? input
        : input && typeof input === "object" && "url" in input
          ? String((input as { url: unknown }).url)
          : String(input);
    attempts.push(url);
    throw new Error(`northstar local_only gate: blocked network call to ${url}`);
  }) as unknown as typeof fetch;
  try {
    const result = await fn();
    return { result, attempts };
  } catch (err) {
    return { result: undefined as T, attempts, error: err instanceof Error ? err.message : String(err) };
  } finally {
    globalThis.fetch = realFetch;
  }
}

// ---- instrumented read tools ------------------------------------------

export interface ReadTrace {
  step: string;
  tool: string;
  bytes: number;
}

/** Drives the actual pi read tools (createMemoryTools), bucketing each call into
 *  context-bearing reads (memory_read / memory_section) vs FIND navigation
 *  (memory_resolve / memory_category / memory_links) and recording byte sizes. */
export class InstrumentedReader {
  private tools = createMemoryTools();
  readonly reads: ReadTrace[] = [];
  readonly finds: ReadTrace[] = [];

  async call(step: ToolStep): Promise<string> {
    const tool = this.tools.find((t) => t.name === step.tool);
    if (!tool) throw new Error(`northstar: unknown read tool "${step.tool}"`);
    // execute(toolCallId, params, signal, onUpdate, ctx) — read tools use only params.
    const res = await tool.execute("northstar", step.params as never, undefined, undefined, undefined as never);
    const text = res.content.map((c) => ("text" in c ? c.text : "")).join("");
    const bytes = Buffer.byteLength(text, "utf8");
    const trace: ReadTrace = { step: `${step.tool}(${JSON.stringify(step.params)})`, tool: step.tool, bytes };
    if (step.tool === "memory_read" || step.tool === "memory_section") this.reads.push(trace);
    else this.finds.push(trace);
    return text;
  }

  get maxReadBytes(): number {
    return this.reads.reduce((m, r) => Math.max(m, r.bytes), 0);
  }
}

/** FIND -> READ over the smoke vault: run the query's find steps (navigation),
 *  then its read steps (TOC + the one section), returning the concatenated
 *  small reads as the CONTEXT the model answers from. */
export async function retrieveContext(
  q: NorthstarQuery,
  reader: InstrumentedReader,
): Promise<{ context: string; sections: string[] }> {
  for (const step of q.retrieval.find) await reader.call(step);
  const sections: string[] = [];
  for (const step of q.retrieval.read) sections.push(await reader.call(step));
  return { context: sections.join("\n\n---\n\n"), sections };
}

// ---- answerers ---------------------------------------------------------

export type Answerer = (input: { question: string; context: string; negativeControl: boolean }) => Promise<string>;

const READ_PATH_INSTRUCTIONS =
  "You are answering the user from THEIR personal memory. The CONTEXT below is what " +
  "you already looked up — the consolidated current position on this topic. Answer the " +
  "QUESTION directly and naturally, as a long-time colleague continuing the thread — " +
  "never narrate the lookup (no \"per the wiki\", \"according to your notes\"). Use ONLY " +
  "what the context supports; if the context is empty or does not cover the question, say " +
  "plainly that there is nothing on file about it and offer to help — do NOT invent facts, " +
  "gear, or preferences.";

/** The real read-path answerer: one cached local-model load, greedy generate. */
export function makeLocalAnswerer(): Answerer {
  let tmP: Promise<TaskModel> | null = null;
  return async ({ question, context }) => {
    if (!existsSync(`${MODEL_ID}/config.json`)) {
      throw new Error(
        `northstar: Gemma-4-e4b not downloaded (looked under ${MODEL_ID}). ` +
          `Fetch it first: HF_HUB_DISABLE_XET=1 hf download mlx-community/gemma-4-e4b-it-OptiQ-4bit`,
      );
    }
    tmP ??= loadTaskModel(MODEL_ID);
    const tm = await tmP;
    const body = `${READ_PATH_INSTRUCTIONS}\n\nCONTEXT:\n"""\n${context || "(nothing on file)"}\n"""\n\nQUESTION:\n${question}`;
    return (await generateText(tm, body, { maxTokens: 320, useChat: true })).trim();
  };
}

/** A no-GPU stub answerer for the structural dry run + unit tests: echoes a
 *  short, silent-colleague-shaped answer derived from the retrieved context (or
 *  declines when the context is empty). Exercises every gate EXCEPT correctness
 *  (which only the cloud judge decides). */
export const stubAnswerer: Answerer = async ({ context, negativeControl }) => {
  if (negativeControl || context.trim().length === 0) {
    return "I don't have anything on file about that yet — happy to help you work it out.";
  }
  const firstLine = context.split("\n").map((l) => l.trim()).find((l) => l.length > 0) ?? "";
  return `Here's where things stand: ${firstLine}`.slice(0, 400);
};

// ---- per-query run + gate evaluation ----------------------------------

export interface QueryOutcome {
  id: string;
  question: string;
  answer: string;
  context: string;
  contextBytes: number;
  maxReadBytes: number;
  reads: ReadTrace[];
  finds: ReadTrace[];
  embedCalls: number;
  networkAttempts: string[];
  error?: string;
}

export interface GateResult {
  correctness: boolean | null; // null = pending (no judge in this run)
  context_budget: boolean;
  no_vector: boolean;
  local_only: boolean;
  silent: boolean;
}

/** Retrieve + generate under the embedding tripwire and the no-network guard. */
export async function runQuery(q: NorthstarQuery, answerer: Answerer): Promise<QueryOutcome> {
  const reader = new InstrumentedReader();
  resetEmbedCounter();
  const guarded = await withNetworkGuard(async () => {
    const { context } = await retrieveContext(q, reader);
    const answer = await answerer({ question: q.question, context, negativeControl: q.negative_control });
    return { context, answer };
  });
  const embedCalls = getEmbedCounter();
  const context = guarded.result?.context ?? "";
  const answer = guarded.result?.answer ?? "";
  return {
    id: q.id,
    question: q.question,
    answer,
    context,
    contextBytes: Buffer.byteLength(context, "utf8"),
    maxReadBytes: reader.maxReadBytes,
    reads: reader.reads,
    finds: reader.finds,
    embedCalls,
    networkAttempts: guarded.attempts,
    error: guarded.error,
  };
}

/** Score the five gates for one query. `verdict` (from the cloud judge) decides
 *  correctness + reinforces silent; when absent, correctness is pending (null)
 *  and silent falls back to the deterministic regex. */
export function evaluateGates(o: QueryOutcome, verdict?: AnswerVerdict): GateResult {
  const ok = !o.error;
  const silentLeak = violatesSilent(o.answer) || (verdict?.silentViolation ?? false);
  return {
    correctness: verdict ? verdict.correct : null,
    context_budget: ok && o.maxReadBytes <= MAX_READ_BYTES && o.contextBytes <= MAX_CONTEXT_BYTES,
    no_vector: ok && o.embedCalls === 0,
    local_only: ok && o.networkAttempts.length === 0,
    silent: ok && !silentLeak,
  };
}

/** Build the EXPECTED answer the cloud judge grades against — the query's
 *  schematic gold answer plus the key points a correct answer must convey. */
export function expectedFor(q: NorthstarQuery): string {
  return `${q.gold_answer}\n\nKey points a correct answer conveys:\n${q.expected_points.map((p) => `- ${p}`).join("\n")}`;
}

/** AnswerCase contract the cloud judge consumes (scripts/memory/judge-answer.ts).
 *  The north-star answers under the silent-colleague contract (always ON). */
export function toAnswerCase(q: NorthstarQuery, o: QueryOutcome): AnswerCase {
  return { id: o.id, question: o.question, answer: o.answer, expected: expectedFor(q), silentContract: true };
}

// ---- CLI ---------------------------------------------------------------

function fmtGate(v: boolean | null): string {
  return v === null ? "PEND" : v ? "PASS" : "FAIL";
}

async function main(): Promise<void> {
  const dry = process.argv.includes("--dry") || process.env.NORTHSTAR_DRY === "1";
  if (!process.env.MLX_BUN_WIKI) process.env.MLX_BUN_WIKI = `${process.env.HOME}/.mlx-bun/wiki-smoke`;
  const set = loadQueries();
  console.log(`# north-star acceptance — ${set.queries.length} queries over ${smokeVaultRoot()}${dry ? " (DRY: stub answerer, no judge)" : ""}`);

  const answerer = dry ? stubAnswerer : makeLocalAnswerer();
  const useJudge = !dry && !!process.env.ANTHROPIC_API_KEY;
  let client: Awaited<ReturnType<typeof makeJudgeClient>> | null = null;
  if (useJudge) client = await makeJudgeClient();

  const outcomes: QueryOutcome[] = [];
  const gates: GateResult[] = [];
  for (const q of set.queries) {
    const o = await runQuery(q, answerer);
    outcomes.push(o);
    let verdict: AnswerVerdict | undefined;
    if (client) verdict = await gradeAnswer(client, toAnswerCase(q, o));
    const g = evaluateGates(o, verdict);
    gates.push(g);
    console.log(
      `${o.id} ${q.label.padEnd(28)} ` +
        `correct=${fmtGate(g.correctness)} budget=${fmtGate(g.context_budget)} ` +
        `no_vector=${fmtGate(g.no_vector)} local=${fmtGate(g.local_only)} silent=${fmtGate(g.silent)} ` +
        `| ctx=${(o.contextBytes / 1024).toFixed(2)}KB maxRead=${(o.maxReadBytes / 1024).toFixed(2)}KB embeds=${o.embedCalls}` +
        (o.error ? ` ERROR=${o.error}` : ""),
    );
  }

  // ---- suite metrics ----
  const meanContextKb = outcomes.reduce((a, o) => a + o.contextBytes, 0) / outcomes.length / 1024;
  const maxReadKb = Math.max(...outcomes.map((o) => o.maxReadBytes)) / 1024;
  const hotPathEmbedCalls = outcomes.reduce((a, o) => a + o.embedCalls, 0);
  const correctnessPassed = gates.filter((g) => g.correctness === true).length;
  const q6 = gates[set.queries.findIndex((q) => q.id === "Q6")];
  const nonCorrectnessClean = gates.every((g) => g.context_budget && g.no_vector && g.local_only && g.silent);

  console.log("=".repeat(72));
  console.log(`mean_context_kb=${meanContextKb.toFixed(2)} (target < 5)`);
  console.log(`max_read_kb=${maxReadKb.toFixed(2)} (gate < 2)`);
  console.log(`hot_path_embed_calls=${hotPathEmbedCalls} (gate == 0)`);
  console.log(`correctness=${correctnessPassed}/${outcomes.length} (gate >= 5/6, Q6 must pass)`);
  console.log("=".repeat(72));

  const budgetsOk = meanContextKb < 5 && maxReadKb < 2 && hotPathEmbedCalls === 0 && nonCorrectnessClean;
  if (dry || !useJudge) {
    console.log(
      dry
        ? `DRY structural run: read-path + gate plumbing ${budgetsOk ? "PASS" : "FAIL"} (correctness deferred to the cloud-judge run).`
        : "No ANTHROPIC_API_KEY — ran the local read path but skipped the correctness judge (set the key for the full RunJudge run).",
    );
    if (!budgetsOk) process.exit(1);
    return;
  }

  const accept = correctnessPassed >= 5 && q6?.correctness === true && budgetsOk;
  console.log(accept ? "NORTH-STAR ACCEPTANCE: PASSED" : "NORTH-STAR ACCEPTANCE: FAILED");
  if (!accept) process.exit(1);
}

/** Build the Anthropic client only when a headless judge run is requested. */
async function makeJudgeClient() {
  const { default: Anthropic } = await import("@anthropic-ai/sdk");
  return new Anthropic();
}

if (import.meta.main) await main();
