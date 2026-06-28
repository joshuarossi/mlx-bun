// The Dreaming — P5 CLOUD-JUDGE harness for entity extraction.
//
// Headless runs require ANTHROPIC_API_KEY in the environment (pi uses OAuth, so
// the key is NOT present in an interactive session — Josh sets it for headless
// runs). The BUILD-TIME grading that produced reports/dreaming/p5-judge-
// extraction.md was done by a cloud-judge SUB-AGENT (a strong cloud model
// reading the same artifact this script feeds the API), so no key was needed to
// produce the report; this script is the durable, re-runnable equivalent.
//
// WHY a cloud judge and not bucket-F1: Lucien's `chunk_buckets`→entity mapping
// and goldens/entities.json are the topic-BIN taxonomy this project REPLACES
// (most Dreaming titles are `X_and_Y` bins). They are NOT a valid oracle for
// extraction quality — exact-match against them scored a clean correct
// extraction 0.000. The real oracle is a cloud LLM grading the ACTUAL
// extractions against the chunk text. The LoRA decision keys off THIS judge's
// precision/recall, never a bucket F1.
//
// What it does: loads reports/dreaming/p5-extract-sample.json (the deterministic
// domain-stratified slice of base Gemma-4-e4b extractions over mlx-bun's own
// ingested corpus), and for each (chunk text, extracted entities) pair asks the
// cloud judge to (a) mark each extraction good/marginal/bad and (b) list notable
// things the model MISSED. Aggregates precision = good/(good+bad) and recall =
// found/(found+missed), writes reports/dreaming/p5-judge-extraction.json.
//
//   ANTHROPIC_API_KEY=… bun scripts/memory/judge-extraction.ts

import { mkdirSync } from "node:fs";
import { join } from "node:path";

import Anthropic from "@anthropic-ai/sdk";

const ROOT = join(import.meta.dir, "..", "..");
const REPORT_DIR = join(ROOT, "reports", "dreaming");
const SAMPLE = join(REPORT_DIR, "p5-extract-sample.json");
const OUT = join(REPORT_DIR, "p5-judge-extraction.json");

const MODEL = process.env.JUDGE_MODEL ?? "claude-opus-4-8";
const MAX_TOKENS = Number(process.env.JUDGE_MAX_TOKENS ?? 2000);

// ---- shapes of the input artifact (subset we read) --------------------------
interface SampleEntry {
  chunkId: string;
  convTitle: string;
  domain: string;
  textLen: number;
  textExcerpt: string;
  extracted: string[];
}
interface SampleArtifact {
  entries: SampleEntry[];
}

// ---- the judge's verdict for one chunk --------------------------------------
type Mark = "good" | "marginal" | "bad";
interface ExtractionMark {
  name: string;
  verdict: Mark;
  reason: string;
}
interface MissedItem {
  name: string;
  reason: string;
}
export interface ChunkVerdict {
  chunkId: string;
  perExtraction: ExtractionMark[];
  missed: MissedItem[];
}

// ---- prompt (reusable) ------------------------------------------------------
export const JUDGE_SYSTEM =
  "You are a strict cloud judge grading a small local model's entity extraction " +
  "for a personal-wiki memory system. For each chunk you see the chunk TEXT and " +
  "the list of entities the local model extracted. Grade TWO things:\n" +
  "1. PRECISION — for EACH extracted entity, decide if it is a real, specific, " +
  "notable thing the chunk is genuinely ABOUT. Mark:\n" +
  "   - good: a real, specific, notable entity (a named product/person/work/tool/" +
  "concept) the chunk is actually about.\n" +
  "   - marginal: real but over-broad domain words (e.g. 'Photography', 'AI " +
  "development'), or a secondary/generic concept, or a defensible-but-weak call.\n" +
  "   - bad: a hallucination not supported by the text, an over-broad junk noun " +
  "(e.g. 'camera', 'lens'), the user himself, a CLI command, or a redundant " +
  "near-duplicate of another extraction (a canonicalization failure).\n" +
  "2. RECALL — list the notable things the chunk IS about that the model FAILED " +
  "to extract (specific proper nouns present in the text matter most; do not " +
  "invent vague concepts).\n" +
  "Reply with ONLY a JSON object, no prose, no markdown fences:\n" +
  '{"perExtraction":[{"name":"…","verdict":"good|marginal|bad","reason":"…"}],' +
  '"missed":[{"name":"…","reason":"…"}]}';

export function buildUserPrompt(entry: SampleEntry): string {
  const list =
    entry.extracted.length === 0
      ? "(the model extracted NOTHING)"
      : entry.extracted.map((e, i) => `${i + 1}. ${e}`).join("\n");
  return (
    `CHUNK (title: ${entry.convTitle || "untitled"}; domain: ${entry.domain}; ` +
    `${entry.textLen} chars, excerpt):\n"""\n${entry.textExcerpt}\n"""\n\n` +
    `MODEL EXTRACTED:\n${list}\n\n` +
    "Grade per the rubric and return the JSON object."
  );
}

/** Strip optional ```json fences and parse the judge's JSON verdict. */
export function parseVerdict(chunkId: string, text: string): ChunkVerdict {
  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)```/);
  const raw = (fenced?.[1] ?? text).trim();
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start < 0 || end < 0) throw new Error(`no JSON object in judge reply for ${chunkId}`);
  const obj = JSON.parse(raw.slice(start, end + 1)) as {
    perExtraction?: ExtractionMark[];
    missed?: MissedItem[];
  };
  return {
    chunkId,
    perExtraction: Array.isArray(obj.perExtraction) ? obj.perExtraction : [],
    missed: Array.isArray(obj.missed) ? obj.missed : [],
  };
}

async function judgeChunk(client: Anthropic, entry: SampleEntry): Promise<ChunkVerdict> {
  const res = await client.messages.create({
    model: MODEL,
    max_tokens: MAX_TOKENS,
    system: JUDGE_SYSTEM,
    messages: [{ role: "user", content: buildUserPrompt(entry) }],
  });
  let text = "";
  for (const block of res.content) if (block.type === "text") text += block.text;
  return parseVerdict(entry.chunkId, text);
}

// ---- aggregate --------------------------------------------------------------
export interface JudgeTotals {
  judgedChunks: number;
  good: number;
  marginal: number;
  bad: number;
  missed: number;
  precision: number; // good / (good + bad)
  recall: number; // good / (good + missed)
}

export function aggregate(verdicts: ChunkVerdict[]): JudgeTotals {
  let good = 0;
  let marginal = 0;
  let bad = 0;
  let missed = 0;
  for (const v of verdicts) {
    for (const m of v.perExtraction) {
      if (m.verdict === "good") good++;
      else if (m.verdict === "marginal") marginal++;
      else bad++;
    }
    missed += v.missed.length;
  }
  const precision = good + bad === 0 ? 0 : good / (good + bad);
  const recall = good + missed === 0 ? 0 : good / (good + missed);
  return { judgedChunks: verdicts.length, good, marginal, bad, missed, precision, recall };
}

async function main(): Promise<void> {
  if (!process.env.ANTHROPIC_API_KEY)
    throw new Error("ANTHROPIC_API_KEY is required for a headless judge run (Josh sets it).");

  const artifact = (await Bun.file(SAMPLE).json()) as SampleArtifact;
  const client = new Anthropic();

  const verdicts: ChunkVerdict[] = [];
  for (let i = 0; i < artifact.entries.length; i++) {
    const entry = artifact.entries[i]!;
    verdicts.push(await judgeChunk(client, entry));
    if ((i + 1) % 5 === 0 || i + 1 === artifact.entries.length)
      console.log(`  judged ${i + 1}/${artifact.entries.length}`);
  }

  const totals = aggregate(verdicts);
  mkdirSync(REPORT_DIR, { recursive: true });
  await Bun.write(
    OUT,
    JSON.stringify({ generatedAt: new Date().toISOString(), model: MODEL, totals, verdicts }, null, 2),
  );

  console.log(
    `\njudged ${totals.judgedChunks} chunks — good ${totals.good} / marginal ${totals.marginal} / ` +
      `bad ${totals.bad} / missed ${totals.missed}`,
  );
  console.log(
    `precision ${totals.precision.toFixed(3)}  recall ${totals.recall.toFixed(3)}  → ${OUT}`,
  );
}

if (import.meta.main) await main();
