// In-process chunk-task eval (no server, no pi). Loads a model, runs lucien's
// 25-case frozen holdout, and scores with lucien's exact scoreChunk metric
// (json/schema/anchors/labels/nonempty). The prompt format is derived from the
// fine-tune training data itself (system + user-prefix from train.jsonl[0]) so
// baseline and fine-tuned runs see the identical format the model trained on.
//
//   bun scripts/chunk-eval.ts                 # baseline, all 25 cases
//   LIMIT=5 bun scripts/chunk-eval.ts         # quick smoke
//   ADAPTER=/path/to/adapter bun scripts/chunk-eval.ts   # fine-tuned
//
// MODEL defaults to MiniCPM5-1B-OptiQ-4bit.

import { readFileSync, readdirSync } from "node:fs";
import { generate } from "../src/generate";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";
// Imported verbatim from lucien — deterministic anchor validation/repair.
import { validateChunks } from "/Users/joshrossi/Code/lucien/scripts/chunk-validation.ts";

const HOME = process.env.HOME!;
function resolveModel(): string {
  if (process.env.MODEL) return process.env.MODEL;
  const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
  const snap = readdirSync(base)[0];
  return `${base}/${snap}`;
}
const MODEL = resolveModel();
const LUCIEN = "/Users/joshrossi/Code/lucien";
const HOLDOUT = `${LUCIEN}/benchmark/dataset/chunk.json`;
const TRAIN = process.env.TRAIN ?? `${LUCIEN}/benchmark/finetune/chunk-v3/train.jsonl`;
const LIMIT = process.env.LIMIT ? Number(process.env.LIMIT) : 25;
const MAXTOK = Number(process.env.MAXTOK ?? 1536);
const ADAPTER = process.env.ADAPTER;

// ---- lucien-ported helpers -------------------------------------------------
function extractJSON(response: string): any {
  const t = response.trim();
  try { return JSON.parse(t); } catch {}
  const s = t.replace(/^```json\s*/i, "").replace(/^```\s*/i, "").replace(/```\s*$/, "");
  try { return JSON.parse(s); } catch {}
  const f = response.indexOf("{"), l = response.lastIndexOf("}");
  if (f !== -1 && l > f) { try { return JSON.parse(response.slice(f, l + 1)); } catch {} }
  throw new Error("Could not extract valid JSON from response");
}
function wordCount(s: string): number { const t = s.trim(); return t ? t.split(/\s+/).length : 0; }
const GENERIC_LABELS = ["technical discussion", "conversation", "q&a", "discussion", "chat", "general discussion"];

interface ChunkMsg { uuid: string; sender: string; text: string }
interface ChunkCase { id: string; name: string; messages: ChunkMsg[] }

function scoreChunk(c: ChunkCase, outText: string) {
  const checks: Record<string, number> = {};
  let parsed: any;
  try { parsed = extractJSON(outText); }
  catch { return { id: c.id, score: 0, jsonValid: false, checks: { json: 0 }, detail: "invalid JSON" }; }
  const arr = Array.isArray(parsed?.chunks) ? parsed.chunks : null;
  if (!arr) return { id: c.id, score: 0, jsonValid: true, checks: { json: 1, schema: 0 }, detail: "no chunks array" };
  const schemaOk = arr.length === 0 ? 1 : arr.filter((x: any) =>
    typeof x?.start_message_uuid === "string" && typeof x?.end_message_uuid === "string" && typeof x?.label === "string"
  ).length / arr.length;
  let anchors = 0; let detail = "";
  try {
    const { chunks, repairs } = validateChunks(arr, c.messages, c.id);
    anchors = chunks.length === 0 ? (arr.length === 0 ? 1 : 0) : Math.max(0, 1 - repairs.length / (2 * chunks.length));
    detail = `${chunks.length} chunks${repairs.length ? `, ${repairs.length} repairs` : ""}`;
  } catch (e: any) { anchors = 0; detail = (e.message?.slice(0, 80)) ?? "anchor error"; }
  const labels = arr.length === 0 ? 1 : arr.filter((x: any) => {
    const w = wordCount(x?.label ?? "");
    return w >= 2 && w <= 12 && !GENERIC_LABELS.includes((x?.label ?? "").toLowerCase().trim());
  }).length / arr.length;
  const nonempty = arr.length >= 1 ? 1 : 0;
  checks.json = 1; checks.schema = schemaOk; checks.anchors = anchors; checks.labels = labels; checks.nonempty = nonempty;
  const score = 100 * (0.30 * schemaOk + 0.35 * anchors + 0.15 * labels + 0.20 * nonempty);
  return { id: c.id, score, jsonValid: true, checks, detail };
}

// formatConversation — verbatim from lucien chunk-recent.ts (conv.uuid == case.id).
function formatConversation(conv: ChunkCase): string {
  const messages = conv.messages
    .filter((m) => m.text && m.text.trim())
    .map((m) => `[${m.sender}] (uuid: ${m.uuid})\n${m.text}\n`)
    .join("\n---\n");
  return `Conversation: ${conv.name} (uuid: ${conv.id})\n\n${messages}`;
}

// ---- derive the exact training prompt format -------------------------------
const trainRec0 = JSON.parse(readFileSync(TRAIN, "utf8").split("\n").find((l) => l.trim())!);
const SYSTEM: string = trainRec0.messages.find((m: any) => m.role === "system").content;
const userFull: string = trainRec0.messages.find((m: any) => m.role === "user").content;
// CHUNK_PROMPT ends with "...Here is the conversation:\n" then formatConversation
// ("Conversation: <name> ..."). Split right before the conversation block.
const convStart = userFull.indexOf("\nConversation: ");
if (convStart < 0) throw new Error("could not locate conversation marker in train user prompt");
const PREFIX: string = userFull.slice(0, convStart + 1); // include the leading \n

function buildUser(c: ChunkCase): string {
  return PREFIX + formatConversation(c);
}

// ---- run -------------------------------------------------------------------
const cases: ChunkCase[] = JSON.parse(readFileSync(HOLDOUT, "utf8")).slice(0, LIMIT);

console.log(`### chunk-eval  model=${MODEL.split("/").slice(-3, -2)[0] || MODEL}`);
console.log(`### adapter=${ADAPTER ?? "(none, baseline)"}  cases=${cases.length}  maxTok=${MAXTOK}`);
console.log(`### system=${SYSTEM.length}ch  prefix=${PREFIX.length}ch`);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const tok = await loadTokenizer(MODEL);
const tmpl = await ChatTemplate.load(MODEL);

if (ADAPTER) {
  const { AdapterManager } = await import("../src/lora");
  const mgr = new AdapterManager(model);
  await mgr.mount("eval", ADAPTER);
  model.loraState.active = ["eval"];
  console.log(`### mounted adapter from ${ADAPTER}`);
}

const scores: number[] = [];
const checkAgg: Record<string, number[]> = { json: [], schema: [], anchors: [], labels: [], nonempty: [] };
for (let i = 0; i < cases.length; i++) {
  const c = cases[i]!;
  const user = buildUser(c);
  const text = tmpl.render(
    [{ role: "system", content: SYSTEM }, { role: "user", content: user }] as any,
    { addGenerationPrompt: true },
  );
  const ids = tok.encode(text);
  const t0 = performance.now();
  const gen = generate(model, ids, { maxTokens: MAXTOK, temperature: 0 });
  const outTokens: number[] = [];
  for await (const { token } of gen) outTokens.push(token);
  const out = tok.decode(outTokens, true);
  const cs = scoreChunk(c, out);
  scores.push(cs.score);
  for (const k of Object.keys(checkAgg)) if (cs.checks[k] !== undefined) checkAgg[k]!.push(cs.checks[k]!);
  const secs = ((performance.now() - t0) / 1000).toFixed(1);
  console.log(
    `[${String(i + 1).padStart(2)}/${cases.length}] ${cs.score.toFixed(1).padStart(5)}  ` +
    `prompt=${ids.length}t gen=${outTokens.length}t ${secs}s  ${cs.detail}  (${c.name.slice(0, 40)})`,
  );
}

const mean = (xs: number[]) => (xs.length ? xs.reduce((a, b) => a + b, 0) / xs.length : NaN);
console.log(`\n### MEAN SCORE: ${mean(scores).toFixed(2)} / 100  (n=${scores.length})`);
console.log(
  `### checks: ` +
  Object.entries(checkAgg).map(([k, v]) => `${k}=${(mean(v) * 100).toFixed(0)}%`).join("  "),
);
