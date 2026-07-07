// Feature-matrix serving benchmark — grammar-spec-batching-integration.md
// Phase E. Measures the six legal composition cells (lane × feature) in ONE
// run, with in-process short-lived servers (three configs: serial / batch=N /
// serial+draft — they die with the script).
//
//   bun scripts/bench-feature-matrix.ts --model <snapshot-dir> \
//       [--draft <snapshot-dir>] [--batch 4] [--concurrency 4] \
//       [--maxtok 128] [--repeats 3] [--cells all|serial,batch,spec,...]
//
// Cells:
//   serial          batch=1, plain            — the baseline lane
//   serial+grammar  batch=1, response_format  — grammar overhead, serial
//   batchN          batch=N, plain            — throughput lane
//   batchN+grammar  batch=N, response_format  — grammar overhead, batched
//   spec            batch=1 + draft           — speculative decode
//   spec+grammar    batch=1 + draft + schema  — the constrained verify walk
//
// Per cell: aggregate tok/s (Σ completion_tokens / round wall, best of
// --repeats), TTFT p50/p95 (SSE first content chunk, wall-clock), spec
// acceptance (usage.speculation), and — in every grammar cell — a HARD 100%
// schema-conformance gate (one nonconforming response fails the run; it's a
// correctness gate wearing a benchmark costume).
//
// Denominator discipline: read each feature cell against the SAME model+lane
// baseline from the SAME run. Loaded-machine numbers are GARBAGE for quoting
// (dirty-machine rule); quotable rows go to benchmarks/RESULTS.md
// "composition" only from a clean-machine run. For stack-vs-stack (oMLX /
// mlx-lm) comparisons use the client-only scripts/bench-serving-load.ts
// against servers you start yourself.

import { existsSync } from "node:fs";

type Args = Record<string, string>;
const args: Args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  const k = process.argv[i];
  if (k?.startsWith("--")) args[k.slice(2)] = process.argv[i + 1] ?? "";
}

const MODEL = args.model;
const DRAFT = args.draft;
const BATCH = Number(args.batch ?? 4);
const CONC = Number(args.concurrency ?? 4);
const MAXTOK = Number(args.maxtok ?? 128);
const REPEATS = Number(args.repeats ?? 3);
const CELLS = (args.cells ?? "all").split(",");

if (!MODEL || !existsSync(`${MODEL}/config.json`)) {
  console.error(
    "usage: bun scripts/bench-feature-matrix.ts --model <snapshot-dir> [--draft <dir>] " +
      "[--batch 4] [--concurrency 4] [--maxtok 128] [--repeats 3] [--cells all]",
  );
  process.exit(1);
}

const SCHEMA = {
  type: "object",
  properties: {
    name: { type: "string" },
    category: { type: "string", enum: ["tool", "toy", "food", "book"] },
    price: { type: "number" },
  },
  required: ["name", "category", "price"],
};
const GRAMMAR_BODY = {
  response_format: { type: "json_schema", json_schema: { name: "product", schema: SCHEMA } },
};
const PLAIN_PROMPT = "Write a short paragraph about mountain weather.";
const GRAMMAR_PROMPT = "Invent a product and describe it.";

interface ReqResult {
  ttftMs: number;
  wallMs: number;
  tokens: number;
  content: string;
  speculation?: { drafted: number; accepted: number; targetCalls: number };
}

/** One streaming chat request; TTFT at the first content delta (SSE, wall). */
async function oneRequest(
  port: number, prompt: string, grammar: boolean, seq: number,
): Promise<ReqResult> {
  const t0 = performance.now();
  const res = await fetch(`http://127.0.0.1:${port}/v1/chat/completions`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      // unique suffix defeats prompt-cache hits inflating repeat TTFT
      messages: [{ role: "user", content: `${prompt} (case ${seq})` }],
      max_tokens: MAXTOK,
      temperature: 0,
      stream: true,
      stream_options: { include_usage: true },
      ...(grammar ? GRAMMAR_BODY : {}),
    }),
  });
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);
  let ttftMs = -1;
  let content = "";
  let tokens = 0;
  let speculation: ReqResult["speculation"];
  const reader = res.body!.getReader();
  const dec = new TextDecoder();
  let buf = "";
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    buf += dec.decode(value, { stream: true });
    for (;;) {
      const nl = buf.indexOf("\n\n");
      if (nl < 0) break;
      const frame = buf.slice(0, nl);
      buf = buf.slice(nl + 2);
      const line = frame.split("\n").find((l) => l.startsWith("data: "));
      if (!line || line === "data: [DONE]") continue;
      const j = JSON.parse(line.slice(6));
      const delta = j.choices?.[0]?.delta?.content;
      if (delta) {
        if (ttftMs < 0) ttftMs = performance.now() - t0;
        content += delta;
      }
      if (j.usage) {
        tokens = j.usage.completion_tokens ?? 0;
        if (j.usage.speculation) speculation = j.usage.speculation;
      }
    }
  }
  return { ttftMs, wallMs: performance.now() - t0, tokens, content, speculation };
}

const pct = (xs: number[], p: number): number => {
  const s = [...xs].sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.floor((p / 100) * s.length))]!;
};

interface CellRow {
  cell: string;
  aggTps: number;
  ttftP50: number;
  ttftP95: number;
  conform: string;
  acceptance: string;
}

async function runCell(port: number, name: string, grammar: boolean): Promise<CellRow> {
  const ttfts: number[] = [];
  let bestAgg = 0;
  let drafted = 0, accepted = 0;
  let checked = 0;
  for (let r = 0; r < REPEATS; r++) {
    const t0 = performance.now();
    const results = await Promise.all(
      Array.from({ length: CONC }, (_, i) =>
        oneRequest(port, grammar ? GRAMMAR_PROMPT : PLAIN_PROMPT, grammar, r * CONC + i),
      ),
    );
    const wall = performance.now() - t0;
    const toks = results.reduce((a, x) => a + x.tokens, 0);
    bestAgg = Math.max(bestAgg, (toks / wall) * 1000);
    for (const x of results) {
      ttfts.push(x.ttftMs);
      if (x.speculation) { drafted += x.speculation.drafted; accepted += x.speculation.accepted; }
      if (grammar) {
        checked++;
        try {
          const parsed = JSON.parse(x.content);
          for (const k of SCHEMA.required) if (!(k in parsed)) throw new Error(`missing "${k}"`);
        } catch (e) {
          // HARD gate: grammar cells must conform. 100%. No exceptions.
          throw new Error(`[${name}] CONFORMANCE FAILURE: ${(e as Error).message}\n${x.content}`);
        }
      }
    }
    console.log(`  [${name}] round ${r + 1}/${REPEATS}: ${((toks / wall) * 1000).toFixed(1)} tok/s agg`);
  }
  return {
    cell: name,
    aggTps: bestAgg,
    ttftP50: pct(ttfts, 50),
    ttftP95: pct(ttfts, 95),
    conform: grammar ? `${checked}/${checked}` : "—",
    acceptance: drafted ? `${((accepted / drafted) * 100).toFixed(0)}%` : "—",
  };
}

// ---------------------------------------------------------------------------
const { loadContext, createServer, detectDraftKind } = await import("../src/server");

/** Load the draft provider by artifact kind — the SAME dispatch the server
 *  runs (dspark.json → DSpark, *_assistant config → assistant, else a full
 *  two-model draft), so every drafter kind benches through its real path. */
async function loadDraftProvider(dir: string, targetVocabSize: number) {
  const kind = await detectDraftKind(dir);
  if (kind === "dspark") return (await import("../src/spec/dflash-source")).DflashProvider.load(dir);
  if (kind === "assistant") return (await import("../src/spec/assistant-source")).AssistantProvider.load(dir);
  return (await import("../src/spec/two-model")).TwoModelProvider.load(dir, targetVocabSize);
}

console.log(`loading ${MODEL} ...`);
const ctx = await loadContext(MODEL, undefined, {});
const want = (c: string) => CELLS.includes("all") || CELLS.includes(c);
const rows: CellRow[] = [];

// group 1: serial lane (batch=1, no draft)
if (want("serial") || want("serial+grammar")) {
  const server = createServer(ctx, 0, { owner: "embedded", hostname: "127.0.0.1" });
  if (want("serial")) rows.push(await runCell(server.port!, "serial", false));
  if (want("serial+grammar")) rows.push(await runCell(server.port!, "serial+grammar", true));
  server.stop(true);
}

// group 2: batch lane (batch=N, no draft)
if (want("batch") || want("batch+grammar")) {
  const server = createServer(ctx, 0, { owner: "embedded", hostname: "127.0.0.1", batch: BATCH });
  if (want("batch")) rows.push(await runCell(server.port!, `batch${BATCH}`, false));
  if (want("batch+grammar")) rows.push(await runCell(server.port!, `batch${BATCH}+grammar`, true));
  server.stop(true);
}

// group 3: spec (batch=1 + draft) — skipped without --draft
if (DRAFT && (want("spec") || want("spec+grammar"))) {
  console.log(`loading draft ${DRAFT} ...`);
  const provider = await loadDraftProvider(DRAFT, ctx.model.config.text.vocabSize);
  ctx.draft = { provider, numDraftTokens: Number(args["num-draft-tokens"] ?? 3) };
  const server = createServer(ctx, 0, { owner: "embedded", hostname: "127.0.0.1" });
  if (want("spec")) rows.push(await runCell(server.port!, "spec", false));
  if (want("spec+grammar")) rows.push(await runCell(server.port!, "spec+grammar", true));
  server.stop(true);
  ctx.draft = null;
  provider.dispose();
} else if (!DRAFT) {
  console.log("(no --draft given — spec cells skipped)");
}

// ---------------------------------------------------------------------------
const host = (await import("node:os")).hostname();
const date = new Date().toISOString().slice(0, 10);
const lines = [
  `# Feature-matrix serving benchmark — ${date} (${host})`,
  ``,
  `Model: ${MODEL}${DRAFT ? `  ·  draft: ${DRAFT}` : ""}`,
  `Concurrency ${CONC} × ${MAXTOK} tok · best-of-${REPEATS} rounds · NOT preflight-gated —`,
  `loaded-machine numbers are garbage for quoting; clean-machine protocol before RESULTS.md.`,
  ``,
  `| cell | agg tok/s | TTFT p50 | TTFT p95 | conform | acceptance |`,
  `| --- | --- | --- | --- | --- | --- |`,
  ...rows.map((r) =>
    `| ${r.cell} | ${r.aggTps.toFixed(1)} | ${r.ttftP50.toFixed(0)} ms | ${r.ttftP95.toFixed(0)} ms | ${r.conform} | ${r.acceptance} |`,
  ),
];
const out = lines.join("\n");
console.log(`\n${out}\n`);
await Bun.write(`benchmarks-feature-matrix-${date}.md`, out + "\n");
console.log(`wrote benchmarks-feature-matrix-${date}.md`);
process.exit(0);
