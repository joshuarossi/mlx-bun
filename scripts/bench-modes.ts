// Mode-matrix benchmark — every serving mode / flag combination on ONE
// model, measuring TTFT, prefill/decode throughput, aggregate throughput,
// and peak MLX memory per cell. The companion to:
//   - scripts/bench-feature-matrix.ts (feature composition: grammar/spec)
//   - scripts/bench-serving-load.ts   (client-only, stack-vs-stack)
//   - ./benchmark.sh                  (preflight-gated h2h, quotable rows)
//
//   bun scripts/bench-modes.ts [--model <snapshot-dir>] [--draft <dir>]
//       [--repeats 3] [--maxtok 128] [--quick] [--cells <csv|all>]
//
// Default model: gemma-4-e4b (resolved from the HF cache); --model overrides.
//
// CELLS (mode axis) — each is a server/env configuration over the same
// loaded weights; env levers (compiled-decode, perf-kernel, fused-sdpa) are
// read per-generation so they flip without reloading:
//   serial-l1            bf16 KV, no fused-sdpa       (mlx-lm bit-exact composition)
//   serial-l2            config KV + fused-sdpa       (the shipped default)
//   serial-l2-nocompile  l2 with compiled-decode OFF  (isolates compile's win)
//   serial-kv4/kv8       uniform-quant KV             (memory/speed trade)
//   serial-conc4         serial lane, 4 concurrent    (the queueing baseline)
//   batch2 / batch4      bf16 compat lane at matching concurrency
//   serial-grammar       default serial + json_schema (structured-output cost)
//   batch4-grammar       batch lane + json_schema
//   spec / spec-grammar  --draft only (needs a same-tokenizer smaller model;
//                        e4b has none downloaded — the Llama 3B+1B pair works)
//
// WORKLOADS: short (~40-tok prompt, decode-dominated) and long (~2k-tok
// prompt, prefill-dominated). --quick = short only, 1 repeat.
//
// METRICS per cell×workload:
//   ttft p50/p95   SSE first content token, wall-clock (queue included)
//   prefill tok/s  prompt_tokens / ttft (client-side approx — includes
//                  template render + tokenize + queue; comparable ACROSS
//                  cells, not absolute-kernel-truth)
//   decode tok/s   (completion_tokens - 1) / (wall - ttft), p50 across reqs
//   agg tok/s      Σ completion / round wall (concurrency > 1)
//   peak mem       mlx allocator peak during the cell (reset before each
//                  cell; includes weights + KV + transients)
//   conform/accept grammar conformance (hard gate) / spec acceptance
//
// Prompt-cache hits are defeated with a per-request nonce so serial TTFT is
// honest. NOT preflight-gated: loaded-machine numbers are garbage for
// quoting (dirty-machine rule) — run the clean-machine protocol before
// promoting anything to benchmarks/RESULTS.md.

import { existsSync, readdirSync } from "node:fs";

type Args = Record<string, string | boolean>;
const args: Args = {};
for (let i = 2; i < process.argv.length; i++) {
  const k = process.argv[i]!;
  if (!k.startsWith("--")) continue;
  const next = process.argv[i + 1];
  if (next && !next.startsWith("--")) { args[k.slice(2)] = next; i++; }
  else args[k.slice(2)] = true;
}

const resolveDefaultModel = (): string | null => {
  const base = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
  try {
    for (const s of readdirSync(base))
      if (existsSync(`${base}/${s}/config.json`)) return `${base}/${s}`;
  } catch { /* not downloaded */ }
  return null;
};

const MODEL = (args.model as string) ?? resolveDefaultModel();
const DRAFT = args.draft as string | undefined;
const QUICK = args.quick === true;
const REPEATS = Number(args.repeats ?? (QUICK ? 1 : 3));
const MAXTOK = Number(args.maxtok ?? 128);
const CELLS = String(args.cells ?? "all").split(",");

if (!MODEL || !existsSync(`${MODEL}/config.json`)) {
  console.error("usage: bun scripts/bench-modes.ts [--model <snapshot-dir>] [--draft <dir>] [--repeats 3] [--maxtok 128] [--quick] [--cells all]");
  console.error("(default model gemma-4-e4b not found in the HF cache — pass --model)");
  process.exit(1);
}

// ---------------------------------------------------------------------------
// workloads
const LOREM =
  "The expedition kept meticulous records of the valley's weather: morning fog that burned off by ten, " +
  "katabatic winds funneling down the glacier after sunset, and the strange dry thunderstorms of late summer " +
  "that started fires no rain followed to put out. ";
const SHORT_PROMPT = "Write a short paragraph about mountain weather and how it changes with altitude.";
const LONG_PROMPT = LOREM.repeat(45) + "\n\nSummarize the key weather patterns described above.";  // ~2k tokens
const XL_PROMPT = LOREM.repeat(90) + "\n\nSummarize the key weather patterns described above.";    // ~4k tokens
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
const GRAMMAR_PROMPT = "Invent a product and describe it.";

interface ReqResult {
  ttftMs: number; wallMs: number; promptTokens: number; tokens: number;
  content: string;
  speculation?: { drafted: number; accepted: number };
}

type Msg = { role: string; content: string };
async function oneRequest(port: number, prompt: string | Msg[], grammar: boolean, maxtok: number, nonce: string): Promise<ReqResult> {
  const t0 = performance.now();
  const res = await fetch(`http://127.0.0.1:${port}/v1/chat/completions`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      messages: Array.isArray(prompt) ? prompt : [{ role: "user", content: `[ref ${nonce}] ${prompt}` }],
      max_tokens: maxtok, temperature: 0, stream: true,
      stream_options: { include_usage: true },
      ...(grammar ? GRAMMAR_BODY : {}),
    }),
  });
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);
  let ttftMs = -1, tokens = 0, promptTokens = 0;
  let content = "";
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
      const line = buf.slice(0, nl).split("\n").find((l) => l.startsWith("data: "));
      buf = buf.slice(nl + 2);
      if (!line || line === "data: [DONE]") continue;
      const j = JSON.parse(line.slice(6));
      const delta = j.choices?.[0]?.delta?.content;
      if (delta) {
        if (ttftMs < 0) ttftMs = performance.now() - t0;
        content += delta;
      }
      if (j.usage) {
        tokens = j.usage.completion_tokens ?? 0;
        promptTokens = j.usage.prompt_tokens ?? 0;
        if (j.usage.speculation) speculation = j.usage.speculation;
      }
    }
  }
  return { ttftMs, wallMs: performance.now() - t0, promptTokens, tokens, content, speculation };
}

const pct = (xs: number[], p: number): number => {
  const s = [...xs].sort((a, b) => a - b);
  return s.length ? s[Math.min(s.length - 1, Math.floor((p / 100) * s.length))]! : 0;
};

// ---------------------------------------------------------------------------
// cell definitions
interface Cell {
  name: string;
  env: Record<string, string>;           // env levers for the cell
  kvQuant?: "off" | "config" | number;   // server option
  batch: number;                          // server --batch
  concurrency: number;
  grammar?: boolean;
  needsDraft?: boolean;
  /** Cache-hit cells: "ram" = warm prompt cache (2 GB, same prompt reused);
   *  "ssd" = tiny RAM cache so the entry spills to the SSD tier, then the
   *  repeat restores from disk (zero-copy mmap + tail prefill). Both use
   *  the SAME prompt across requests (no nonce) and a populate request
   *  before measuring — TTFT here is the "respond to a cached request"
   *  number (the oMLX headline metric). Long workload only. */
  cache?: "ram" | "ssd";
}
const L1 = { MLX_BUN_COMPILED_DECODE: "1", MLX_BUN_NO_FUSED_SDPA: "1" };
const L2 = { MLX_BUN_COMPILED_DECODE: "1", MLX_BUN_NO_FUSED_SDPA: "0" };

const ALL_CELLS: Cell[] = [
  { name: "serial-l1",           env: L1, kvQuant: "off",    batch: 1, concurrency: 1 },
  { name: "serial-l2",           env: L2, kvQuant: "config", batch: 1, concurrency: 1 },
  { name: "serial-l2-nocompile", env: { ...L2, MLX_BUN_COMPILED_DECODE: "0" }, kvQuant: "config", batch: 1, concurrency: 1 },
  { name: "serial-kv4",          env: L2, kvQuant: 4,        batch: 1, concurrency: 1 },
  { name: "serial-kv8",          env: L2, kvQuant: 8,        batch: 1, concurrency: 1 },
  { name: "serial-conc4",        env: L2, kvQuant: "config", batch: 1, concurrency: 4 },
  { name: "batch2",              env: L2, kvQuant: undefined, batch: 2, concurrency: 2 },
  { name: "batch4",              env: L2, kvQuant: undefined, batch: 4, concurrency: 4 },
  { name: "serial-grammar",      env: L2, kvQuant: "config", batch: 1, concurrency: 1, grammar: true },
  { name: "batch4-grammar",      env: L2, kvQuant: undefined, batch: 4, concurrency: 4, grammar: true },
  { name: "cache-ram",           env: L2, kvQuant: "config", batch: 1, concurrency: 1, cache: "ram" },
  { name: "cache-ssd",           env: L2, kvQuant: "config", batch: 1, concurrency: 1, cache: "ssd" },
  { name: "spec",                env: L2, kvQuant: "config", batch: 1, concurrency: 1, needsDraft: true },
  { name: "spec-grammar",        env: L2, kvQuant: "config", batch: 1, concurrency: 1, grammar: true, needsDraft: true },
];

interface CellRow {
  cell: string; workload: string;
  ttftP50: number; ttftP95: number;
  prefillTps: number; decodeTpsP50: number; aggTps: number;
  peakGB: number; conform: string; accept: string;
}

// ---------------------------------------------------------------------------
const { loadContext, createServer } = await import("../src/server");
const { peakMemory, resetPeakMemory, activeMemory } = await import("../src/mlx/ffi");

console.log(`loading ${MODEL} ...`);
const ctx = await loadContext(MODEL, undefined, {});
let draftProvider: import("../src/spec/source").DraftProvider | null = null;
if (DRAFT) {
  const { TwoModelProvider } = await import("../src/spec/two-model");
  draftProvider = await TwoModelProvider.load(DRAFT, ctx.model.config.text.vocabSize);
}
// weights fault in lazily (CPU-stream mmap load) — measured after the first
// warmup below, once the first forward has materialized them.
let weightsGB = 0;

const want = (c: Cell) => (CELLS.includes("all") || CELLS.includes(c.name)) && (!c.needsDraft || !!DRAFT);
const workloads: [string, string, number][] = QUICK
  ? [["short", SHORT_PROMPT, MAXTOK]]
  : [
      ["short", SHORT_PROMPT, MAXTOK],
      ["long", LONG_PROMPT, Math.min(64, MAXTOK)],   // ~2k-token prefix
      ["xl", XL_PROMPT, Math.min(64, MAXTOK)],       // ~4k-token prefix
    ];

const rows: CellRow[] = [];
let nonce = 0;

for (const cell of ALL_CELLS.filter(want)) {
  // env levers for this cell (read per-generation by the runtime)
  for (const [k, v] of Object.entries(cell.env)) process.env[k] = v;
  // spec cells mount the draft; others run without
  ctx.draft = cell.needsDraft && draftProvider ? { provider: draftProvider, numDraftTokens: 3 } : null;
  const ssdDir = `/tmp/mlx-bun-bench-ssd-${process.pid}`;
  const server = createServer(ctx, 0, {
    owner: "embedded", hostname: "127.0.0.1", batch: cell.batch,
    ...(cell.kvQuant !== undefined ? { kvQuant: cell.kvQuant } : {}),
    // cache cells NEED the cache; everything else measures cold TTFT
    ...(cell.cache === "ram"
      ? {}
      : cell.cache === "ssd"
        ? { promptCacheBytes: 1, ssdCacheDir: ssdDir } // ~zero RAM cap → put spills to SSD
        : { promptCacheBytes: 0 }),
  });
  const port = server.port!;

  for (const [wname, prompt, maxtok] of workloads) {
    if (cell.cache && wname === "short" && !QUICK) continue; // cache pays on long prefixes
    const useGrammar = cell.grammar === true;
    // grammar cells embed the workload's context so "long" stays long
    const p = useGrammar
      ? (wname === "long" ? LOREM.repeat(45) + "\n\n" + GRAMMAR_PROMPT
        : wname === "xl" ? LOREM.repeat(90) + "\n\n" + GRAMMAR_PROMPT
        : GRAMMAR_PROMPT)
      : prompt;
    // cache cells reuse ONE prompt (a fixed nonce) so repeats HIT the cache
    const fixedNonce = cell.cache ? `cached${cell.name}` : null;
    try {
      // warmup (kernel compilation, template caches) — not measured
      await oneRequest(port, p, useGrammar, 8, `warm${nonce++}`);
      if (weightsGB === 0) weightsGB = activeMemory() / 1e9;
      resetPeakMemory();
      const ttfts: number[] = [];
      const decodes: number[] = [];
      let prefillSum = 0, prefillN = 0;
      let bestAgg = 0;
      let drafted = 0, accepted = 0, checked = 0;
      if (cell.cache) {
        // The agent pattern the caches exist for: a sequential conversation
        // where every turn's prompt EXTENDS the cached prefix (prefix hit,
        // no trimming — quantized entries can't trim mid-group and never
        // need to here). Turn 1 (cold, populates) is not measured; each
        // measured turn appends the last reply + a new user line, so TTFT =
        // cache restore + new-suffix prefill. cache-ssd's ~zero RAM cap
        // evicts+spills the entry after every turn, so each measured turn
        // restores from DISK (zero-copy mmap) — the restart-survival number.
        const convo: Msg[] = [{ role: "user", content: `[c ${fixedNonce}] ${p}` }];
        const first = await oneRequest(port, convo, useGrammar, maxtok, fixedNonce!);
        convo.push({ role: "assistant", content: first.content });
        if (cell.cache === "ssd") await new Promise((r) => setTimeout(r, 2000));
        for (let r = 0; r < REPEATS; r++) {
          convo.push({ role: "user", content: `Add one more short sentence (${r}).` });
          const t0 = performance.now();
          const x = await oneRequest(port, convo, useGrammar, Math.min(32, maxtok), "unused");
          const wall = performance.now() - t0;
          convo.push({ role: "assistant", content: x.content });
          ttfts.push(x.ttftMs);
          if (x.tokens > 1 && x.wallMs > x.ttftMs) decodes.push(((x.tokens - 1) / (x.wallMs - x.ttftMs)) * 1000);
          if (x.promptTokens > 0 && x.ttftMs > 0) { prefillSum += (x.promptTokens / x.ttftMs) * 1000; prefillN++; }
          bestAgg = Math.max(bestAgg, (x.tokens / wall) * 1000);
          if (cell.cache === "ssd") await new Promise((r) => setTimeout(r, 1200));
        }
      } else
      for (let r = 0; r < REPEATS; r++) {
        const t0 = performance.now();
        const results = await Promise.all(
          Array.from({ length: cell.concurrency }, () =>
            oneRequest(port, p, useGrammar, maxtok, fixedNonce ?? `n${nonce++}`)),
        );
        const wall = performance.now() - t0;
        const toks = results.reduce((a, x) => a + x.tokens, 0);
        bestAgg = Math.max(bestAgg, (toks / wall) * 1000);
        for (const x of results) {
          ttfts.push(x.ttftMs);
          if (x.tokens > 1 && x.wallMs > x.ttftMs) decodes.push(((x.tokens - 1) / (x.wallMs - x.ttftMs)) * 1000);
          if (x.promptTokens > 0 && x.ttftMs > 0) { prefillSum += (x.promptTokens / x.ttftMs) * 1000; prefillN++; }
          if (x.speculation) { drafted += x.speculation.drafted; accepted += x.speculation.accepted; }
          if (useGrammar) {
            checked++;
            try {
              const parsed = JSON.parse(x.content);
              for (const k of SCHEMA.required) if (!(k in parsed)) throw new Error(`missing ${k}`);
            } catch (e) {
              throw new Error(`[${cell.name}/${wname}] CONFORMANCE FAILURE: ${(e as Error).message}\n${x.content}`);
            }
          }
        }
      }
      rows.push({
        cell: cell.name, workload: wname,
        ttftP50: pct(ttfts, 50), ttftP95: pct(ttfts, 95),
        prefillTps: prefillN ? prefillSum / prefillN : 0,
        decodeTpsP50: pct(decodes, 50),
        aggTps: bestAgg,
        peakGB: peakMemory() / 1e9,
        conform: useGrammar ? `${checked}/${checked}` : "—",
        accept: drafted ? `${((accepted / drafted) * 100).toFixed(0)}%` : "—",
      });
      const r = rows[rows.length - 1]!;
      console.log(
        `  [${cell.name}/${wname}] ttft p50 ${r.ttftP50.toFixed(0)}ms · prefill ~${r.prefillTps.toFixed(0)} t/s · ` +
        `decode ${r.decodeTpsP50.toFixed(1)} t/s · agg ${r.aggTps.toFixed(1)} t/s · peak ${r.peakGB.toFixed(2)} GB`,
      );
    } catch (e) {
      console.error(`  [${cell.name}/${wname}] FAILED: ${(e as Error).message}`);
      rows.push({
        cell: cell.name, workload: wname, ttftP50: -1, ttftP95: -1,
        prefillTps: 0, decodeTpsP50: 0, aggTps: 0, peakGB: peakMemory() / 1e9,
        conform: "FAIL", accept: "—",
      });
    }
  }
  server.stop(true);
}
ctx.draft = null;

// ---------------------------------------------------------------------------
const host = (await import("node:os")).hostname();
const date = new Date().toISOString().slice(0, 10);
const fmt = (r: CellRow) =>
  `| ${r.cell} | ${r.ttftP50 < 0 ? "FAIL" : r.ttftP50.toFixed(0) + " ms"} | ${r.ttftP95.toFixed(0)} ms | ` +
  `${r.prefillTps.toFixed(0)} | ${r.decodeTpsP50.toFixed(1)} | ${r.aggTps.toFixed(1)} | ` +
  `${r.peakGB.toFixed(2)} GB | ${r.conform} | ${r.accept} |`;
const lines: string[] = [
  `# Mode-matrix benchmark — ${date} (${host})`, ``,
  `Model: ${MODEL}${DRAFT ? `  ·  draft: ${DRAFT}` : ""}`,
  `Weights resident: ${weightsGB.toFixed(2)} GB · repeats ${REPEATS} · max_tokens ${MAXTOK} · prompt cache OFF (cold TTFT)`,
  `NOT preflight-gated — loaded-machine numbers are garbage for quoting; clean-machine protocol before RESULTS.md.`,
  `prefill tok/s is prompt_tokens/TTFT (client-side; comparable across cells, not kernel-absolute).`, ``,
];
for (const [wname] of workloads) {
  lines.push(`## ${wname}`, ``,
    `| cell | TTFT p50 | TTFT p95 | prefill t/s | decode t/s p50 | agg t/s | peak mem | conform | accept |`,
    `| --- | --- | --- | --- | --- | --- | --- | --- | --- |`,
    ...rows.filter((r) => r.workload === wname).map(fmt), ``);
}
const out = lines.join("\n");
console.log(`\n${out}`);
await Bun.write(`benchmarks-modes-${date}.md`, out + "\n");
await Bun.write(`benchmarks-modes-${date}.json`, JSON.stringify({ model: MODEL, draft: DRAFT ?? null, weightsGB, repeats: REPEATS, rows }, null, 2));
console.log(`wrote benchmarks-modes-${date}.md + .json`);
process.exit(0);
