// One arm of the drafter A/B: a prompt set sent one request at a time to a
// server that mounted the drafter under test, greedy, non-streaming. Acceptance
// comes from the server's own `usage.speculation` block, so the arm measures
// the production execution path, not a harness loop.
import type { AbPromptResult } from "./stats";

/** A small on-distribution chat mix (instructions, QA, code, math, writing). */
export const DEFAULT_PROMPTS = [
  "Summarize how speculative decoding works in two sentences.",
  "What is 17 times 23? Show your reasoning briefly.",
  "Write a Python function that reverses a linked list.",
  "Name three primary colors and one thing each is associated with.",
  "Explain the difference between a process and a thread.",
  "Translate to French: 'The weather is beautiful today.'",
  "Write a haiku about mountains.",
  "What causes tides on Earth?",
  "Give me a one-paragraph plot for a mystery novel set in Lisbon.",
  "How do I revert the last git commit but keep the changes staged?",
  "List five capital cities in South America.",
  "What is the time complexity of binary search and why?",
  "Draft a polite email declining a meeting invitation.",
  "Explain recursion to a ten-year-old.",
  "What's the difference between TCP and UDP?",
  "Write a SQL query that finds duplicate emails in a users table.",
  "Why is the sky blue?",
  "Suggest three names for a coffee shop near a university.",
  "What does the Big-O notation O(n log n) mean?",
  "Convert 98.6 degrees Fahrenheit to Celsius.",
  "Write a short limerick about a cat who codes.",
  "What are the main differences between HTTP/1.1 and HTTP/2?",
  "Give a step-by-step plan to learn the guitar in three months.",
  "What is photosynthesis? Answer in one sentence.",
  "Write a JavaScript one-liner that removes falsy values from an array.",
  "Explain what a hash map is and when to use one.",
  "What year did the Berlin Wall fall, and why was it significant?",
  "Describe the taste of fresh bread to someone who has never eaten it.",
  "How does a refrigerator keep food cold?",
  "Write a regex that matches ISO-8601 dates (YYYY-MM-DD).",
  "What are two pros and two cons of remote work?",
  "Explain the birthday paradox briefly.",
] as const;

export interface ArmOptions {
  /** `http://127.0.0.1:<port>`. */
  base: string;
  /** The served model's name in the request. */
  model: string;
  prompts: readonly string[];
  maxTokens: number;
  timeoutMs?: number;
  onPrompt?: (index: number, result: AbPromptResult) => void;
  signal?: AbortSignal;
}

type Json = Record<string, unknown>;
const record = (value: unknown): Json | null => value && typeof value === "object" && !Array.isArray(value) ? value as Json : null;
const count = (value: unknown, what: string): number => {
  if (typeof value === "number" && Number.isFinite(value) && value >= 0) return value;
  throw new Error(`usage.speculation.${what} is missing or invalid: ${JSON.stringify(value)}`);
};
const counts = (value: unknown, what: string): number[] => {
  if (Array.isArray(value) && value.every(v => typeof v === "number" && Number.isFinite(v) && v >= 0)) return value as number[];
  throw new Error(`usage.speculation.${what} is missing or invalid: ${JSON.stringify(value)}`);
};

/** The A/B counters of one response; an arm that did not speculate is refused, never read as zero acceptance. */
export function speculationOf(prompt: string, body: unknown, wallMs: number): AbPromptResult {
  const usage = record(record(body)?.usage);
  const speculation = record(usage?.speculation);
  if (!speculation) throw new Error("the response has no usage.speculation: no drafter was mounted for this request, so there is nothing to compare");
  return {
    prompt, wallMs,
    generatedTokens: count(usage!.completion_tokens, "completion_tokens (usage)"),
    drafted: count(speculation.drafted, "drafted"), accepted: count(speculation.accepted, "accepted"),
    targetCalls: count(speculation.targetCalls, "targetCalls"),
    draftedByPos: counts(speculation.draftedByPos, "draftedByPos"), acceptedByPos: counts(speculation.acceptedByPos, "acceptedByPos"),
  };
}

export async function runArm(o: ArmOptions): Promise<AbPromptResult[]> {
  const results: AbPromptResult[] = [];
  for (const [index, prompt] of o.prompts.entries()) {
    o.signal?.throwIfAborted();
    const budget = AbortSignal.timeout(o.timeoutMs ?? 600_000);
    const t0 = performance.now();
    const response = await fetch(`${o.base}/v1/chat/completions`, {
      method: "POST", headers: { "content-type": "application/json" }, signal: o.signal ? AbortSignal.any([budget, o.signal]) : budget,
      body: JSON.stringify({ model: o.model, messages: [{ role: "user", content: prompt }], temperature: 0, max_tokens: o.maxTokens, stream: false }),
    });
    const text = await response.text();
    const wallMs = performance.now() - t0;
    if (!response.ok) throw new Error(`prompt ${index + 1}: HTTP ${response.status}: ${text.slice(0, 300)}`);
    let body: unknown;
    try { body = JSON.parse(text); } catch { throw new Error(`prompt ${index + 1}: invalid JSON response: ${text.slice(0, 300)}`); }
    let result: AbPromptResult;
    try { result = speculationOf(prompt, body, wallMs); } catch (error) { throw new Error(`prompt ${index + 1}: ${(error as Error).message}`); }
    results.push(result);
    o.onPrompt?.(index, result);
  }
  return results;
}
