// Product-level head-to-head benchmark — REAL SERVERS, REAL PATHS.
//
// The 2026-07-05 harness redesign (Josh: "ensure the benchmark is actually
// running the correct things in the correct ways"). Principles:
//
// 1. THE CORRECT PATH: the mlx-bun arms spawn the REAL CLI
//    (`bun src/cli.ts serve …`) at its REAL DEFAULTS — not a bench-local
//    wrapper (scripts/serve.ts, now deleted, called createServer directly
//    and silently diverged from what users run). mlx-lm and optiq arms run
//    their real servers. Every number comes over HTTP exactly as a user
//    would see it.
// 2. ONE SERVER PER CELL, MANY METRICS PER SERVER: the old harness spawned
//    a fresh child (full model reload) per run and re-prefilled long
//    contexts per run per stack. Here each cell starts its server ONCE and
//    a measurement session extracts everything: decode tok/s (with the
//    spread/stability policy), cold TTFT + prefill rate (~1k, nonce-busted
//    so no stack's prompt cache helps), warm/cached TTFT (repeat prompt —
//    the prompt-cache story, fair to every stack's own cache), long-context
//    prefill/TTFT/decode (ONE prefill; decode measured on 64 tokens after
//    it — never "generate 16k tokens to measure 16k context"), aggregate
//    throughput at 4 concurrent streams, and load→ready time.
// 3. HONEST LABELS: context lengths are recorded from usage.prompt_tokens
//    (measured), not requested; unstable cells carry tags; failures render
//    as a footer instead of silently vanishing from the matrix.
//
//   bun scripts/bench-serve.ts all [--models cpm5,e4b,12B] [--context 16384]
//                                  [--tokens 192] [--with-serial] [--skip-context]
//                                  [--arms mlx-bun,mlx-lm,...] [--out report.md]
//
// Engine-level legs (in-process kernels, gen-peak memory, kill-switch A/Bs)
// remain in bench-h2h.ts / benchmark.sh --engine — different question
// (kernel parity), different tool.

import { existsSync } from "node:fs";
import { EvalDB, gitCommit } from "../src/evaldb";

const VENV = `${process.env.HOME}/Code/mlx-lm/.venv/bin`;
// The venv's console scripts carry STALE SHEBANGS (the venv was moved from
// mlx-lm-example/ — found 2026-07-05: posix_spawn ENOENT on every script).
// Invoke through the venv python instead; immune to relocation.
const PY = `${VENV}/python`;
const CLI = new URL("../src/cli.ts", import.meta.url).pathname;

const argv = process.argv.slice(2);
const opt = (name: string, dflt: string): string => {
  const i = argv.indexOf(`--${name}`);
  return i > -1 ? argv[i + 1]! : dflt;
};
const flag = (n: string): boolean => argv.includes(`--${n}`);

const DECODE_TOKENS = Number(opt("tokens", "192"));
const CTX_TOKENS = Number(opt("context", "16384"));
const DECODE_RUNS = 4;
const TTFT_RUNS = 3;
const AGG_STREAMS = 4;
const SPREAD_TOL = 1.15;
const STABLE_TOL = 1.05;
const MAX_EXTRA = 4;

// ---- model registry (paths mirror tests/paths.ts conventions) -------------
const HF = `${process.env.HOME}/.cache/huggingface/hub`;
const MODELS: Record<string, { path: string; label: string }> = {
  cpm5: {
    path: `${HF}/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78`,
    label: "MiniCPM5-1B",
  },
  e4b: {
    path: snapshotOf("models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"),
    label: "gemma-4-e4b",
  },
  "12B": {
    path: `${HF}/models--mlx-community--gemma-4-12B-it-OptiQ-4bit/snapshots/5b1101065d2094c8f12aa87fee80e0afa5b292b7`,
    label: "gemma-4-12B",
  },
};
function snapshotOf(repoDir: string): string {
  const base = `${HF}/${repoDir}/snapshots`;
  try {
    const revs = [...new Bun.Glob("*").scanSync({ cwd: base, onlyFiles: false })];
    return `${base}/${revs[0] ?? "missing"}`;
  } catch {
    return `${base}/missing`;
  }
}

type Arm = "mlx-bun" | "mlx-bun-serial" | "mlx-bun-mixed" | "mlx-lm" | "optiq-mixed";
interface Cell { model: string; arm: Arm }

function cmdlineFor(c: Cell, port: number): string[] | null {
  const m = MODELS[c.model]!;
  const kvCfg = `${m.path}/kv_config.json`;
  switch (c.arm) {
    case "mlx-bun": // THE drop-in arm: real CLI, real defaults
      return ["bun", CLI, "serve", "--model", m.path, "--port", String(port), "--no-open"];
    case "mlx-bun-serial":
      return ["bun", CLI, "serve", "--model", m.path, "--port", String(port), "--no-open", "--batch", "1"];
    case "mlx-bun-mixed":
      if (!existsSync(kvCfg)) return null;
      return ["bun", CLI, "serve", "--model", m.path, "--port", String(port), "--no-open", "--kv-quant", "config"];
    case "mlx-lm":
      return [PY, "-m", "mlx_lm.server", "--model", m.path, "--port", String(port)];
    case "optiq-mixed":
      if (!existsSync(kvCfg) || !existsSync(`${VENV}/optiq`)) return null;
      return [PY, "-c", "from optiq.cli import cli; cli()",
        "serve", "--model", m.path, "--port", String(port), "--kv-config", kvCfg];
  }
}

// ---- HTTP measurement primitives ------------------------------------------

interface ReqResult {
  ttftMs: number;
  decodeTps: number;
  promptTokens: number;
  cachedTokens: number;
  genTokens: number;
  usedUsage: boolean;
}

/** One streamed chat completion; timings from the byte stream, token counts
 *  from usage when the stack emits it (all three do), chunk-count fallback
 *  otherwise. `content` should be nonce-prefixed by the caller when the
 *  stack's prompt cache must not help. */
async function timedRequest(
  base: string, content: string, maxTokens: number, apiKey?: string, modelId = "bench",
): Promise<ReqResult> {
  const t0 = performance.now();
  const r = await fetch(`${base}/v1/chat/completions`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      ...(apiKey ? { authorization: `Bearer ${apiKey}` } : {}),
    },
    body: JSON.stringify({
      model: modelId, stream: true, max_tokens: maxTokens, temperature: 0,
      messages: [{ role: "user", content }],
      stream_options: { include_usage: true },
    }),
  });
  if (!r.ok) throw new Error(`HTTP ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const reader = r.body!.getReader();
  const dec = new TextDecoder();
  let buf = "";
  let tFirst = 0;
  let tLast = 0;
  let chunkTokens = 0;
  interface Usage {
    prompt_tokens?: number;
    completion_tokens?: number;
    prompt_tokens_details?: { cached_tokens?: number };
  }
  let usage: Usage | null = null;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    buf += dec.decode(value, { stream: true });
    let nl: number;
    while ((nl = buf.indexOf("\n")) >= 0) {
      const line = buf.slice(0, nl).trim();
      buf = buf.slice(nl + 1);
      if (!line.startsWith("data:")) continue;
      const payload = line.slice(5).trim();
      if (payload === "[DONE]") continue;
      let j: { choices?: Array<{ delta?: { content?: string; reasoning?: string } }>; usage?: Usage | null };
      try { j = JSON.parse(payload); } catch { continue; }
      const delta = j.choices?.[0]?.delta;
      if (delta && (delta.content || delta.reasoning)) {
        const now = performance.now();
        if (!tFirst) tFirst = now;
        tLast = now;
        chunkTokens++;
      }
      if (j.usage && typeof j.usage.completion_tokens === "number") usage = j.usage;
    }
  }
  const genTokens = usage?.completion_tokens ?? chunkTokens;
  const promptTokens = usage?.prompt_tokens ?? 0;
  const cachedTokens = usage?.prompt_tokens_details?.cached_tokens ?? 0;
  const dt = tLast - tFirst;
  return {
    ttftMs: tFirst - t0,
    decodeTps: genTokens > 1 && dt > 0 ? ((genTokens - 1) * 1000) / dt : 0,
    promptTokens, cachedTokens, genTokens,
    usedUsage: usage !== null,
  };
}

async function waitReady(base: string, apiKey: string | undefined, timeoutMs: number): Promise<number> {
  const t0 = performance.now();
  while (performance.now() - t0 < timeoutMs) {
    try {
      const r = await fetch(`${base}/v1/models`, {
        headers: apiKey ? { authorization: `Bearer ${apiKey}` } : {},
        signal: AbortSignal.timeout(2000),
      });
      if (r.ok) return performance.now() - t0;
    } catch { /* not up yet */ }
    await Bun.sleep(200);
  }
  throw new Error(`server not ready after ${timeoutMs} ms`);
}

const spreadOf = (xs: number[]): number =>
  xs.length < 2 ? 1 : Math.max(...xs) / Math.min(...xs);

/** Filler sized in chars; ACTUAL length recorded from usage.prompt_tokens —
 *  the reported context is measured, never assumed. `charsPerTok` comes
 *  from the ~1k TTFT leg's measured ratio (tokenizer-dependent), so the
 *  long-context cell lands near its target without a calibration request. */
function fillerPrompt(targetTokens: number, nonce: string, charsPerTok = 3.6): string {
  const para = "Background context: the history of computation spans mechanical calculators, " +
    "vacuum tubes, transistors, integrated circuits, and modern GPU-accelerated systems " +
    "used for machine learning workloads on unified-memory architectures. ";
  let s = `Session ${nonce}. `;
  while (s.length < targetTokens * charsPerTok) s += para;
  return s + " In one short sentence, what is this text about?";
}

// ---- the per-cell measurement session --------------------------------------

interface CellResult {
  cell: Cell;
  readyMs: number;
  decodeTps: number[];
  decodeTag: string;
  ttftColdMs: number[];
  prefill1kTps: number[];
  ttftWarmMs: number;
  warmCachedTokens: number;
  ctx: null | {
    promptTokens: number; prefillTps: number; ttftMs: number;
    decodeTps: number[]; cachedRepeatTtftMs: number;
  };
  aggTps: number;
  aggPerStream: number;
}

async function runCell(c: Cell, port: number, withContext: boolean): Promise<CellResult> {
  const cmd = cmdlineFor(c, port)!;
  const apiKey = c.arm === "optiq-mixed" ? "sk-optiq-bench" : undefined;
  // mlx_lm.server LOADS the request's model field as a repo id when it
  // doesn't match — send the real path so every stack serves the model it
  // was started with (ours ignores unknown ids; theirs would download).
  const modelId = MODELS[c.model]!.path;
  const proc = Bun.spawn(cmd, { stdout: "pipe", stderr: "pipe" });
  const base = `http://127.0.0.1:${port}`;
  try {
    const readyMs = await waitReady(base, apiKey, 600_000);

    // warmup (compile/trace/page-fault-in — discarded; same for all arms)
    await timedRequest(base, "Warmup: say hello.", 32, apiKey, modelId);

    // DECODE (short prompt; nonce so no arm's prefix cache distorts ttft
    // bookkeeping — decode rate itself is cache-independent)
    const decodeTps: number[] = [];
    for (let i = 0; i < DECODE_RUNS; i++) {
      const res = await timedRequest(
        base, `Run ${crypto.randomUUID().slice(0, 8)}: write a detailed essay about the history of computing.`,
        DECODE_TOKENS, apiKey, modelId,
      );
      decodeTps.push(res.decodeTps);
    }
    for (let extra = 0; extra < MAX_EXTRA &&
      spreadOf(decodeTps) > SPREAD_TOL &&
      spreadOf([...decodeTps].sort((a, b) => b - a).slice(0, 3)) > STABLE_TOL; extra++) {
      const res = await timedRequest(
        base, `Run ${crypto.randomUUID().slice(0, 8)}: write a detailed essay about the history of computing.`,
        DECODE_TOKENS, apiKey, modelId,
      );
      decodeTps.push(res.decodeTps);
    }
    let decodeTag = "";
    let decodePicked = decodeTps;
    if (spreadOf(decodeTps) > SPREAD_TOL) {
      const top3 = [...decodeTps].sort((a, b) => b - a).slice(0, 3);
      if (spreadOf(top3) <= STABLE_TOL) { decodePicked = top3; decodeTag = `stabilized top3of${decodeTps.length}`; }
      else decodeTag = `unstable spread=${spreadOf(decodeTps).toFixed(2)}`;
    }

    // TTFT cold @~1k (fresh nonce per run = every stack's cache misses)
    const ttftColdMs: number[] = [];
    const prefill1kTps: number[] = [];
    let lastColdPrompt = "";
    let charsPerTok = 3.6;
    for (let i = 0; i < TTFT_RUNS; i++) {
      lastColdPrompt = fillerPrompt(1024, crypto.randomUUID().slice(0, 8));
      const res = await timedRequest(base, lastColdPrompt, 8, apiKey, modelId);
      ttftColdMs.push(res.ttftMs);
      if (res.promptTokens > 0) {
        prefill1kTps.push((res.promptTokens * 1000) / res.ttftMs);
        charsPerTok = lastColdPrompt.length / res.promptTokens; // measured ratio
      }
    }
    // TTFT warm: EXACT repeat of the last cold prompt — each stack's own
    // prompt cache gets its fair shot (ours restores the prefix; so can theirs).
    const warm = await timedRequest(base, lastColdPrompt, 8, apiKey, modelId);

    // LONG CONTEXT: ONE prefill (the whole point — never generate <ctx>
    // tokens to measure a context), then decode sampled on 64 tokens; two
    // cached repeats give more decode@ctx samples for the price of zero
    // additional prefills.
    let ctx: CellResult["ctx"] = null;
    if (withContext) {
      const prompt = fillerPrompt(CTX_TOKENS, crypto.randomUUID().slice(0, 8), charsPerTok);
      const cold = await timedRequest(base, prompt, 64, apiKey, modelId);
      const decodeAtCtx = [cold.decodeTps];
      let cachedRepeatTtftMs = -1;
      for (let i = 0; i < 2; i++) {
        const rep = await timedRequest(base, prompt, 64, apiKey, modelId);
        decodeAtCtx.push(rep.decodeTps);
        cachedRepeatTtftMs = rep.ttftMs;
      }
      ctx = {
        promptTokens: cold.promptTokens,
        prefillTps: cold.promptTokens > 0 ? (cold.promptTokens * 1000) / cold.ttftMs : 0,
        ttftMs: cold.ttftMs,
        decodeTps: decodeAtCtx,
        cachedRepeatTtftMs,
      };
    }

    // AGGREGATE: 4 concurrent short generations (the sub-agents number).
    // Ours batches; stacks that queue serve them serially — either way the
    // number answers "what do 4 agents experience", same for everyone.
    const aggT0 = performance.now();
    const aggResults = await Promise.all(
      Array.from({ length: AGG_STREAMS }, (_, i) =>
        timedRequest(base, `Agent ${i} ${crypto.randomUUID().slice(0, 8)}: write a detailed essay about computers.`, 128, apiKey, modelId)),
    );
    const aggWallS = (performance.now() - aggT0) / 1000;
    const aggTokens = aggResults.reduce((a, r) => a + r.genTokens, 0);

    return {
      cell: c, readyMs,
      decodeTps: decodePicked, decodeTag,
      ttftColdMs, prefill1kTps,
      ttftWarmMs: warm.ttftMs, warmCachedTokens: warm.cachedTokens,
      ctx,
      aggTps: aggTokens / aggWallS,
      aggPerStream: aggResults.reduce((a, r) => a + r.decodeTps, 0) / aggResults.length,
    };
  } finally {
    proc.kill();
    await Promise.race([proc.exited, Bun.sleep(5000)]);
    try { proc.kill(9); } catch { /* already gone */ }
    await Bun.sleep(1500); // port + GPU memory settle
  }
}

// ---- orchestration + report -------------------------------------------------

function machineHeader(): string {
  const chip = Bun.spawnSync(["sysctl", "-n", "machdep.cpu.brand_string"]).stdout.toString().trim();
  const mem = Number(Bun.spawnSync(["sysctl", "-n", "hw.memsize"]).stdout.toString().trim()) / 2 ** 30;
  const load = Bun.spawnSync(["sysctl", "-n", "vm.loadavg"]).stdout.toString().trim();
  return `${chip} · ${mem.toFixed(0)} GB · loadavg ${load} · ${new Date().toISOString()}`;
}

const median = (xs: number[]): number => {
  const s = [...xs].sort((a, b) => a - b);
  return s.length ? (s.length % 2 ? s[s.length >> 1]! : (s[(s.length >> 1) - 1]! + s[s.length >> 1]!) / 2) : 0;
};

async function main(): Promise<void> {
  const models = opt("models", "cpm5,e4b,12B").split(",").filter((m) => {
    if (!MODELS[m] || !existsSync(`${MODELS[m]!.path}/config.json`)) {
      console.log(`[skip] unknown/missing model ${m}`);
      return false;
    }
    return true;
  });
  let arms: Arm[] = ["mlx-bun", "mlx-lm", "mlx-bun-mixed", "optiq-mixed"];
  if (flag("with-serial")) arms.splice(1, 0, "mlx-bun-serial");
  const armsRaw = opt("arms", "");
  if (armsRaw) arms = armsRaw.split(",") as Arm[];
  const withContext = !flag("skip-context");

  const db = new EvalDB();
  const commit = gitCommit();
  const machine = machineHeader();
  console.log(`bench-serve · ${machine}\n`);
  const results: CellResult[] = [];
  const failures: { cell: string; error: string }[] = [];

  for (const model of models) {
    for (const arm of arms) {
      const c: Cell = { model, arm };
      if (!cmdlineFor(c, 0)) { console.log(`[skip] ${model}/${arm} — not applicable`); continue; }
      const key = `${model}/${arm}`;
      console.log(`=== ${key} ===`);
      try {
        const res = await runCell(c, 8971, withContext);
        results.push(res);
        console.log(
          `  ready ${(res.readyMs / 1000).toFixed(1)}s · decode ${median(res.decodeTps).toFixed(1)} tok/s ${res.decodeTag} · ` +
          `ttft ${median(res.ttftColdMs).toFixed(0)}ms cold / ${res.ttftWarmMs.toFixed(0)}ms warm (cached ${res.warmCachedTokens}) · ` +
          (res.ctx ? `ctx@${res.ctx.promptTokens} prefill ${res.ctx.prefillTps.toFixed(0)} tok/s decode ${median(res.ctx.decodeTps).toFixed(1)} tok/s · ` : "") +
          `agg×${AGG_STREAMS} ${res.aggTps.toFixed(1)} tok/s`,
        );
        db.record({
          modelPath: MODELS[model]!.path,
          commitSha: commit,
          promptTokens: res.ctx?.promptTokens ?? 0,
          generatedTokens: DECODE_TOKENS,
          prefillTps: res.ctx?.prefillTps ?? median(res.prefill1kTps),
          decodeTps: median(res.decodeTps),
          peakBytes: 0,
          stack: arm.startsWith("mlx-bun") ? "mlx-bun" : arm === "mlx-lm" ? "mlx-lm" : "optiq",
          machineState: machine,
          notes: `serve-h2h arm=${arm} ttft_cold=${median(res.ttftColdMs).toFixed(0)} ttft_warm=${res.ttftWarmMs.toFixed(0)} ` +
            `warm_cached=${res.warmCachedTokens} agg${AGG_STREAMS}=${res.aggTps.toFixed(1)} agg_per=${res.aggPerStream.toFixed(1)} ` +
            (res.ctx ? `ctx=${res.ctx.promptTokens} ctx_ttft=${res.ctx.ttftMs.toFixed(0)} ctx_decode=${median(res.ctx.decodeTps).toFixed(1)} ctx_rep_ttft=${res.ctx.cachedRepeatTtftMs.toFixed(0)} ` : "") +
            `ready_ms=${res.readyMs.toFixed(0)} ${res.decodeTag}`.trim(),
        });
      } catch (e) {
        console.log(`  FAILED: ${(e as Error).message.slice(0, 200)}`);
        failures.push({ cell: key, error: (e as Error).message.slice(0, 300) });
      }
    }
  }

  // ---- markdown report ----
  const lines: string[] = [];
  lines.push(`# serve h2h — ${new Date().toISOString().slice(0, 10)}`);
  lines.push(``, `machine: ${machine}`, `commit: ${commit}`, ``);
  lines.push(`All numbers over HTTP against REAL servers at their real defaults`);
  lines.push(`(mlx-bun arm = the actual CLI). ttft cold = nonce-busted ~1k prompt;`);
  lines.push(`warm = exact repeat (each stack's own prompt cache). ctx figures from`);
  lines.push(`ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.`, ``);
  for (const model of models) {
    const rows = results.filter((r) => r.cell.model === model);
    if (!rows.length) continue;
    lines.push(`## ${MODELS[model]!.label}`, ``);
    lines.push(`| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | agg×${AGG_STREAMS} tok/s | ready s |`);
    lines.push(`|---|---|---|---|---|---|---|---|---|---|---|`);
    for (const r of rows) {
      lines.push(`| ${r.cell.arm}${r.decodeTag ? ` (${r.decodeTag})` : ""} | ${median(r.decodeTps).toFixed(1)} | ${median(r.ttftColdMs).toFixed(0)} | ${r.ttftWarmMs.toFixed(0)} (${r.warmCachedTokens}) | ${median(r.prefill1kTps).toFixed(0)} | ${r.ctx?.promptTokens ?? "—"} | ${r.ctx ? r.ctx.prefillTps.toFixed(0) : "—"} | ${r.ctx ? median(r.ctx.decodeTps).toFixed(1) : "—"} | ${r.ctx ? r.ctx.cachedRepeatTtftMs.toFixed(0) : "—"} | ${r.aggTps.toFixed(1)} | ${(r.readyMs / 1000).toFixed(1)} |`);
    }
    lines.push(``);
  }
  if (failures.length) {
    lines.push(`## failures`, ``);
    for (const f of failures) lines.push(`- ${f.cell}: ${f.error}`);
    lines.push(``);
  }
  const out = opt("out", `benchmarks-serve-${new Date().toISOString().slice(0, 10)}-${Bun.spawnSync(["hostname", "-s"]).stdout.toString().trim()}.md`);
  await Bun.write(out, lines.join("\n"));
  console.log(`\nreport → ${out}`);
}

await main();
