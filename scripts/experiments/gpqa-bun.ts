// GPQA Diamond runner for mlx-bun serve — batch-of-K HTTP client.
//
//   bun scripts/experiments/gpqa-bun.ts --base http://localhost:8080 \
//        [--model <served-id>] [--n 198] [--workers 4] [--seed N]
//        [--dataset <gpqa_diamond.csv>] [--out runs/gpqa-bun/progress.jsonl]
//
// Methodology (official Qwen3.8 model-card eval):
//   - verbatim prompt: "<question>\n\nA) ..\nB) ..\nC) ..\nD) ..\n\nPlease
//     reason step by step, and put your final answer within \boxed{}."
//   - sampling: temperature 1.0, top_p 0.95, top_k 20 (thinking mode)
//   - NO generation cap: max_tokens is sent as the model's remaining
//     context window; the server's admission clamps to what physically fits.
//     Generation ends at EOS or context — never an artificial ceiling.
//   - options shuffled per-question with a fixed-seed MT19937 (deterministic
//     across reruns; matches python `random.Random(1000+i)` ordering).
//
// Batching: keeps `--workers` requests in flight; the server's unified
// engine merges in-flight rows automatically. NOTE: omitting `--seed`
// keeps rows on the batch lane — a user-fixed seed routes each request
// serial (reproducibility policy, mirrors mlx-lm _is_batchable).
//
// Resume: one JSONL row per finished question ({i, ok, pred, out_len,
// gen_tokens}); finished ids are skipped on restart.

import { appendFileSync, existsSync, readFileSync, writeFileSync } from "node:fs";

const arg = (name: string, def: string) => {
  const i = process.argv.indexOf(name);
  return i > -1 ? process.argv[i + 1]! : def;
};
const BASE = arg("--base", "http://localhost:8080").replace(/\/$/, "");
const MODEL = arg("--model", "gpqa");
const N = Number(arg("--n", "198"));
const WORKERS = Number(arg("--workers", "4"));
const SEED_ARG = process.argv.indexOf("--seed");
const SEED = SEED_ARG > -1 ? Number(process.argv[SEED_ARG + 1]) : null;
const OUT = arg("--out", "runs/gpqa-bun/progress.jsonl");
const TIMEOUT_HOURS = Number(arg("--timeout-h", "6"));

// ---------- dataset ----------

function findDataset(): string {
  if (process.argv.includes("--dataset")) return arg("--dataset", "");
  const home = process.env.HOME ?? "";
  const hub = `${home}/.cache/huggingface/hub`;
  const dir = `${hub}/datasets--Idavidrein--gpqa/snapshots`;
  if (existsSync(dir)) {
    const snap = readFileSync(`${dir}/refs/main`, "utf8").trim();
    const p = `${dir}/${snap}/gpqa_diamond.csv`;
    if (existsSync(p)) return p;
    // fallback: first snapshot dir containing the csv
    for (const d of require("node:fs").readdirSync(dir)) {
      const cand = `${dir}/${d}/gpqa_diamond.csv`;
      if (existsSync(cand)) return cand;
    }
  }
  throw new Error("gpqa_diamond.csv not found — pass --dataset <path>");
}

interface Row { question: string; options: [string, string, string, string]; goldLetter: string }

/** Minimal MT19937 (parity with python random.Random seeding + shuffle). */
class MT19937 {
  #mt = new Uint32Array(624);
  #idx = 625;
  constructor(seed: number) {
    this.#mt[0] = seed >>> 0;
    for (let i = 1; i < 624; i++)
      this.#mt[i] = (1812433253 * (this.#mt[i - 1]! ^ (this.#mt[i - 1]! >>> 30)) + i) >>> 0;
  }
  #gen(): void {
    for (let i = 0; i < 624; i++) {
      const y = (this.#mt[i]! & 0x80000000) | (this.#mt[(i + 1) % 624]! & 0x7fffffff);
      this.#mt[i] = this.#mt[(i + 397) % 624]! ^ (y >>> 1) ^ ((y & 1) ? 0x9908b0df : 0);
    }
    this.#idx = 0;
  }
  next(): number { // [0,1)
    if (this.#idx >= 624) this.#gen();
    let y = this.#mt[this.#idx++]!;
    y ^= y >>> 11; y ^= (y << 7) & 0x9d2c5680; y ^= (y << 15) & 0xefc60000; y ^= y >>> 18;
    return y / 4294967296;
  }
  /** python random.shuffle fisher-yates (from the END, like CPython). */
  shuffle<T>(a: T[]): T[] {
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(this.next() * (i + 1));
      [a[i], a[j]] = [a[j]!, a[i]!];
    }
    return a;
  }
}

function loadRows(): Row[] {
  const csv = readFileSync(findDataset(), "utf8");
  // minimal CSV parse (quoted fields with embedded commas/newlines)
  const records: string[][] = [];
  let field = "", rec: string[] = [], inQ = false;
  for (let i = 0; i < csv.length; i++) {
    const c = csv[i]!;
    if (inQ) {
      if (c === '"' && csv[i + 1] === '"') { field += '"'; i++; }
      else if (c === '"') inQ = false;
      else field += c;
    } else if (c === '"') inQ = true;
    else if (c === ",") { rec.push(field); field = ""; }
    else if (c === "\n") { rec.push(field.replace(/\r$/, "")); records.push(rec); field = ""; rec = []; }
    else field += c;
  }
  if (field || rec.length) { rec.push(field); records.push(rec); }
  const header = records[0]!;
  const col = (name: string) => header.indexOf(name);
  const cQ = col("Question"), cC = col("Correct Answer"),
    cI1 = col("Incorrect Answer 1"), cI2 = col("Incorrect Answer 2"), cI3 = col("Incorrect Answer 3");
  const letters = ["A", "B", "C", "D"];
  return records.slice(1, 1 + N).map((r) => {
    const opts = [r[cC]!, r[cI1]!, r[cI2]!, r[cI3]!];
    const rng = new MT19937(1000 + records.indexOf(r) - 1);
    const order = rng.shuffle([0, 1, 2, 3]);
    const goldLetter = letters[order.indexOf(0)];
    if (goldLetter === undefined) throw new Error("shuffled options lost the correct answer");
    return {
      question: r[cQ]!.trim(),
      options: order.map((oi) => opts[oi]!.trim()) as [string, string, string, string],
      goldLetter,
    };
  });
}

// ---------- request ----------

async function ask(i: number, row: Row): Promise<{ pred: string | null; outChars: number; genTokens: number }> {
  const letters = ["A", "B", "C", "D"];
  let body = `${row.question}\n\n`;
  row.options.forEach((o, li) => { body += `${letters[li]}) ${o}\n`; });
  body += "\nPlease reason step by step, and put your final answer within \\boxed{}.";

  // No artificial cap: express the model's full context room; server
  // admission clamps to what fits (Qwen3.8: 262144 positions).
  const maxTokens = 200000;

  const res = await fetch(`${BASE}/v1/chat/completions`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    signal: AbortSignal.timeout(TIMEOUT_HOURS * 3600 * 1000),
    body: JSON.stringify({
      model: MODEL,
      messages: [{ role: "user", content: body }],
      temperature: 1.0,
      top_p: 0.95,
      top_k: 20,
      max_tokens: maxTokens,
      ...(SEED !== null ? { seed: SEED } : {}),
    }),
  });
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${(await res.text()).slice(0, 300)}`);
  const j: {
    choices: Array<{ message: { content?: string; reasoning?: string } }>;
    usage?: { completion_tokens?: number };
  } = await res.json();
  const msg = j.choices?.[0]?.message ?? {};
  const out = (msg.reasoning ? `${msg.reasoning}</think>` : "") + (msg.content ?? "");
  const tail = out.split("</think>").at(-1) ?? "";
  const m = /boxed\{+\s*\\?(?:text\{)?\(?([ABCD])/.exec(tail)
    ?? /Answer:\s*\(?([ABCD])/.exec(tail)
    ?? /\b([ABCD])\)?\s*$/.exec(tail.trim());
  return { pred: m?.[1] ?? null, outChars: out.length, genTokens: j.usage?.completion_tokens ?? 0 };
}

// ---------- main ----------

const rows = loadRows();
console.log(`GPQA Diamond: ${rows.length} questions | workers=${WORKERS} base=${BASE} seed=${SEED ?? "server-default"}`);

type Done = { i: number; ok: boolean; pred: string | null; out_len: number; gen_tokens: number };
const done = new Map<number, Done>();
if (existsSync(OUT)) {
  for (const line of readFileSync(OUT, "utf8").split("\n")) {
    if (!line.trim()) continue;
    try { const r = JSON.parse(line) as Done; done.set(r.i, r); } catch { /* partial line */ }
  }
}
writeFileSync(OUT + ".tmp", "");

let cursor = 0, correct = 0, answered = 0, finished = done.size;
const t0 = Date.now();

function persist(r: Done): void {
  appendFileSync(OUT, JSON.stringify(r) + "\n");
}

async function worker(wid: number): Promise<void> {
  for (;;) {
    const i = cursor++;
    if (i >= rows.length) return;
    const prev = done.get(i);
    if (prev) {
      correct += prev.ok ? 1 : 0;
      answered += prev.pred ? 1 : 0;
      continue;
    }
    for (;;) { // retry network blips; hard-fail rows stay unrecorded
      try {
        const { pred, outChars, genTokens } = await ask(i, rows[i]!);
        const ok = pred !== null && pred === rows[i]!.goldLetter;
        correct += ok ? 1 : 0;
        answered += pred ? 1 : 0;
        finished++;
        const rec: Done = { i, ok, pred, out_len: outChars, gen_tokens: genTokens };
        done.set(i, rec);
        persist(rec);
        const elapsedMin = ((Date.now() - t0) / 60000).toFixed(0);
        console.log(
          `[w${wid}] ${finished}/${rows.length} ${ok ? "OK" : pred ? "MISS" : "NO-ANSWER"}`
          + ` (acc ${correct}/${answered || 1} answered=${answered}, ${elapsedMin} min)`
          + ` [${genTokens} gen tok]`,
        );
        break;
      } catch (e) {
        console.error(`[w${wid}] q${i} retry: ${(e as Error).message.slice(0, 160)}`);
        await new Promise((r) => setTimeout(r, 5000));
      }
    }
  }
}

await Promise.all(Array.from({ length: WORKERS }, (_, w) => worker(w)));
const pct = ((correct / Math.max(1, rows.length)) * 100).toFixed(1);
console.log(`RESULT gpqa-diamond n=${rows.length}: ${correct}/${rows.length} = ${pct}% (answered ${answered})`);
