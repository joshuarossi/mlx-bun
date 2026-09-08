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
// 2026-07-06 hardening (all four defects verified in the serve h2h):
// B1  Every request now carries an AbortSignal budget scaled to its phase
//     (Bun's implicit 300 s fetch timeout killed two 16k cells). A failed
//     phase records WHICH phase died + the child's stderr tail, keeps the
//     already-measured phases (nullable CellResult groups), drains-probes
//     the server, and retries the phase once — respawning at most once per
//     cell when the server is dead. Cold+warm TTFT live in ONE phase so a
//     respawned retry re-establishes the warm leg's premise.
// B2  Parity is TWO probes: a raw /v1/completions probe (no chat template
//     — the tokenizer-only comparison) and a chat probe with
//     enable_thinking PINNED true on every arm (mlx-lm's TokenizerWrapper
//     silently injects it for thinking models; unpinned arms rendered
//     DIFFERENT prompts and the old "diverged at char 0" verdicts were
//     template drift, not engine divergence). usage.prompt_tokens equality
//     is a HARD precondition — unequal counts verdict as drift, never a
//     char-diff between different prompts.
// B3  optiq's install_mixed_kv hooks are bypassed by mlx-lm 0.31.3's
//     BatchGenerator (all seedless text requests) — the optiq-mixed arm
//     serves bf16 KV, live-verified with runtime spies. Requests stay
//     UNSEEDED on purpose: a request-body seed routes to _serve_single
//     where quantization IS live, poisons the shared prompt cache with a
//     QuantizedKVCache, and the next batchable request crashes the worker
//     (_merge_caches ValueError — also live-verified). Cells are labeled
//     bf16; mixed-KV has no valid HTTP oracle (script-path goldens only).
//     NOTE the RSS tripwire is informative only for OUR stack — python
//     mlx KV memory does not show in `ps` RSS at all (measured).
// B4  RSS is attributed per leg (sampler max between leg boundaries +
//     idle/ready RSS) in a per-cell detail block, so "peak" stops hiding
//     WHERE the memory went.
//
//   bun scripts/bench-serve.ts all [--models cpm5,e4b,12B,qwen27b] [--context 16384]
//                                  [--tokens 192] [--no-serial] [--skip-context]
//                                  [--arms mlx-bun,mlx-lm,...] [--out report.md]
//                                  [--model-path /exact/artifact --label name]
//                                  [--workload-seed campaign-block-0] [--dry-run]
//                                  [--diagnostic] (records a non-quotable run)
// Serial experiments (--arms mlx-bun-serial only) also accept:
//   --draft-model PATH --draft-kind mtp --num-draft-tokens 2
//   --kv-quant 4 --prompt-cache 4
//
// Engine-level legs (in-process kernels, gen-peak memory, kill-switch A/Bs)
// remain in bench-h2h.ts / scripts/bench-serve.ts all --engine — different question
// (kernel parity), different tool.

import { existsSync, mkdirSync, mkdtempSync, readFileSync, realpathSync, rmSync, statSync } from "node:fs";
import { createHash } from "node:crypto";
import { tmpdir } from "node:os";
import { basename, dirname, join } from "node:path";
import { EvalDB, gitCommit } from "../src/evaldb";
import { checkMachine } from "../src/preflight";
import { ORACLE_VENV } from "../tests/support/paths";

const VENV = `${ORACLE_VENV}/bin`;
// The venv's console scripts carry STALE SHEBANGS (the venv was moved from
// mlx-lm-example/ — found 2026-07-05: posix_spawn ENOENT on every script).
// Invoke through the venv python instead; immune to relocation.
const PY = `${VENV}/python`;
const CLI = new URL("../src/cli.ts", import.meta.url).pathname;

// Explicit serial experiments keep their settings in the command manifest.
// Restrict overrides so a configured cell cannot masquerade as a default or
// same-policy oracle comparison, or replace benchmark-owned ports/models.
export function serialBenchmarkArgs(args: string[]): string[] {
  const allowed = new Set(["draft-model", "draft-kind", "num-draft-tokens", "kv-quant", "prompt-cache"]);
  const result: string[] = [];
  for (const name of allowed) {
    const key = `--${name}`, index = args.indexOf(key);
    if (index < 0) continue;
    const value = args[index + 1];
    if (!value || value.startsWith("--")) throw new Error(`${key} requires a value`);
    if (args.lastIndexOf(key) !== index) throw new Error(`${key} may only be supplied once`);
    if (["num-draft-tokens", "prompt-cache"].includes(name) &&
        (!Number.isSafeInteger(Number(value)) || Number(value) < (name === "prompt-cache" ? 0 : 1)))
      throw new Error(`${key} requires ${name === "prompt-cache" ? "a nonnegative" : "a positive"} integer`);
    result.push(key, value);
  }
  if (result.length) {
    const index = args.indexOf("--arms");
    if (index < 0 || args[index + 1] !== "mlx-bun-serial")
      throw new Error("server configuration overrides require --arms mlx-bun-serial; run controls separately");
  }
  return result;
}

function benchmarkRuntimeEnvironment(): Record<string, string> {
  const names = ["MLX_BUN_LIBMLXC", "MLX_BUN_TRELLIS", "MLX_BUN_TRELLIS_VARIANT",
    "MLX_BUN_TRELLIS_ASYNC_EXPAND", "MLX_BUN_EARLY_FIRST_TOKEN", "MLX_BUN_FILL",
    "MLX_BUN_MTP_PROMPT_CACHE", "MLX_BUN_QWEN_SPEC_KV4", "MLX_BUN_RD_CONTEXT_LIMIT",
    "MLX_BUN_RD_PREFILL_CHUNK", "MLX_BUN_PREFILL_TAIL_SPLIT"];
  return Object.fromEntries(names.flatMap((name) => process.env[name] === undefined
    ? [] : [[name, process.env[name]!]]));
}

const argv = process.argv.slice(2);
const opt = (name: string, dflt: string): string => {
  const i = argv.indexOf(`--${name}`);
  return i > -1 ? argv[i + 1]! : dflt;
};
const flag = (n: string): boolean => argv.includes(`--${n}`);
const DIAGNOSTIC = flag("diagnostic");

const DECODE_TOKENS = Number(opt("tokens", "192"));
const CTX_TOKENS = Number(opt("context", "16384"));
const DECODE_RUNS = 5;
const TTFT_RUNS = 3;
const AGG_STREAMS = 4;
const AGG_TOKENS = 128;
const SPREAD_TOL = 1.15;
const WORKLOAD_SEED = opt("workload-seed", "bench-serve-v2");

/** Independent of engine/model: paired arms must receive identical requests.
 * A retry has its own nonce so a partially completed cold phase cannot hit its
 * own previous attempt's cache. Match samples by request hash, not array index. */
export function workloadNonce(seed: string, phase: string, attempt: number, index: number): string {
  return createHash("sha256").update(JSON.stringify([seed, phase, attempt, index])).digest("hex").slice(0, 12);
}

// ---- phase budgets (B1) ----------------------------------------------------
// Bun fetch has an IMPLICIT 300 s timeout when no signal is passed — it
// killed the 12B 16k prefill mid-flight ("The operation timed out") and the
// harness read that as a cell failure. Every request now carries an
// explicit AbortSignal: fixed and generous for short legs, SCALED from the
// cell's own measured rates for the long ones (a 16k prefill on a 12B model
// legitimately takes minutes; a restart may pay the FULL re-prefill).
const FIXED_BUDGET_MS = 120_000;
const CTX_MIN_BUDGET_MS = 180_000;
const BUDGET_SAFETY = 4;
const NO_MEASUREMENT_BUDGET_MS = 600_000; // rate unknown → be generous, never infinite
const DRAIN_PROBE_BUDGET_MS = 30_000;
// Native throw backtraces can exceed 64 lines before Bun prints its crash
// footer. Keep the original exception text in bounded diagnostic reports.
const STDERR_TAIL_LINES = DIAGNOSTIC ? 160 : 30;

/** tokens/tps scaled budget with a floor; pure so the clamping is testable.
 *  tps ≤ 0 (leg that would have measured it failed) falls back generous. */
export function scaledBudgetMs(
  tokens: number, tps: number, minMs: number, safety = BUDGET_SAFETY,
): number {
  if (!(tps > 0) || !(tokens > 0)) return Math.max(minMs, NO_MEASUREMENT_BUDGET_MS);
  return Math.max(minMs, (tokens / tps) * 1000 * safety);
}

// ---- model registry (paths mirror tests/support/paths.ts conventions) -------------
const HF = `${process.env.HOME}/.cache/huggingface/hub`;
export interface BenchmarkModel {
  path: string;
  label: string;
  needsOptiqRegister?: boolean;
  packedTrellis?: boolean;
  configSha256?: string;
}

/** Metadata only: selecting an artifact never loads MLX or tensor data. */
export function localBenchmarkModel(path: string, label?: string): BenchmarkModel {
  const resolved = realpathSync(path);
  const bytes = readFileSync(join(resolved, "config.json"));
  const config = JSON.parse(bytes.toString());
  const quant = config.quantization ?? config.quantization_config ?? config.text_config?.quantization ?? {};
  return {
    path: resolved,
    label: label || basename(resolved),
    configSha256: createHash("sha256").update(bytes).digest("hex"),
    packedTrellis: quant.mode === "trellis" || Object.values(quant).some((v) =>
      v !== null && typeof v === "object" && (v as { mode?: string }).mode === "trellis"),
    needsOptiqRegister: config.model_type === "gemma4_unified",
  };
}

export function unsupportedBenchmarkArm(model: BenchmarkModel, arm: string): string | null {
  if (!["mlx-bun", "mlx-bun-serial", "mlx-bun-mixed", "mlx-lm", "optiq-mixed"].includes(arm))
    return `unknown arm ${arm}`;
  if (model.packedTrellis && (arm === "mlx-lm" || arm === "optiq-mixed"))
    return "packed trellis has no stock mlx-lm/optiq loader; an expanded carrier is a separate artifact, not a same-artifact oracle";
  return null;
}

const MODELS: Record<string, BenchmarkModel> = {
  cpm5: {
    path: `${HF}/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78`,
    label: "MiniCPM5-1B",
  },
  e4b: {
    path: snapshotOf("models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"),
    label: "gemma-4-e4b",
  },
  "12B": {
    // model_type gemma4_unified: PLAIN mlx-lm cannot load it ("Model type
    // gemma4_unified not supported" — the worker thread dies and
    // mlx_lm.server zombies, which is what silently killed this arm on
    // both 2026-07-06 runs). The bf16 baseline launches via optiq serve
    // WITHOUT --kv-config: optiq register()s the architecture and its
    // default is fp16 KV — same mlx-lm server engine, no quant hooks.
    path: `${HF}/models--mlx-community--gemma-4-12B-it-OptiQ-4bit/snapshots/5b1101065d2094c8f12aa87fee80e0afa5b292b7`,
    label: "gemma-4-12B",
    needsOptiqRegister: true,
  },
  qwen27b: {
    // The shipped 4.79-bpw rotation + sensitivity winner. The bundle carries
    // the same-architecture Qwen3.6 OptiQ mixed-KV policy; unlike the weight
    // quantization, that KV policy has no Qwen3.8-specific oracle yet.
    path: snapshotOf("models--mjriii--Qwen3.8-27B"),
    label: "Qwen3.8-27B winner (4/8-bit)",
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

type Arm = "mlx-bun" | "mlx-bun-isolated" | "mlx-bun-serial" | "mlx-bun-mixed" | "mlx-lm" | "optiq-mixed";
interface Cell { model: string; arm: Arm }

function cmdlineFor(c: Cell, port: number, ssdDir?: string): string[] | null {
  const m = MODELS[c.model]!;
  if (unsupportedBenchmarkArm(m, c.arm)) return null;
  const kvCfg = `${m.path}/kv_config.json`;
  const ssd = ssdDir ? ["--ssd-cache", ssdDir] : [];
  switch (c.arm) {
    case "mlx-bun": // THE drop-in arm: real CLI, real defaults (+ SSD tier for the restart leg)
      return [process.execPath, CLI, "serve", "--model", m.path, "--port", String(port), "--no-open", ...ssd];
    case "mlx-bun-isolated":
      return [process.execPath, CLI, "serve", "--model", m.path, "--port", String(port), "--no-open", "--isolate", ...ssd];
    case "mlx-bun-serial":
      return [process.execPath, CLI, "serve", "--model", m.path, "--port", String(port), "--no-open", "--batch", "1", ...ssd, ...serialBenchmarkArgs(argv)];
    case "mlx-bun-mixed":
      if (!existsSync(kvCfg)) return null;
      return [process.execPath, CLI, "serve", "--model", m.path, "--port", String(port), "--no-open", "--kv-quant", "config", ...ssd];
    case "mlx-lm":
      // Architectures plain mlx-lm lacks go through optiq's register()
      // (bf16 KV — optiq serve's default; the kv-quant hooks never run).
      if (m.needsOptiqRegister) {
        if (!existsSync(`${VENV}/optiq`)) return null;
        return [PY, "-c", "from optiq.cli import cli; cli()",
          "serve", "--model", m.path, "--port", String(port)];
      }
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
  headersMs: number;
  firstByteMs: number;
  firstEventMs: number;
  /** Arrival times of content, reasoning or tool-call output events, not tokens. */
  outputEventTimesMs: number[];
  toolCallChunks: number;
  doneSeen: boolean;
  /** Observed content-stream interval; SSE chunks need not be single tokens. */
  decodeTps: number;
  wallMs: number;
  endToEndTps: number;
  contentChunks: number;
  finishReason: string | null;
  promptTokens: number;
  cachedTokens: number;
  genTokens: number;
  usedUsage: boolean;
  text: string;
}

interface ReqOpts {
  apiKey?: string;
  modelId?: string;
  bodyExtra?: Record<string, unknown>;
  /** Phase budget (B1) — ALWAYS set by callers; the default only guards
   *  against a forgotten call site (never rely on Bun's implicit 300 s). */
  timeoutMs?: number;
}

/** One streamed chat completion. Token counts require usage: a chunk can
 * contain a burst of tokens, so counting chunks is not an admissible fallback.
 * Record total request wall time separately from the visible stream interval. */
export async function measureChatRequest(
  base: string, content: string, maxTokens: number, o: ReqOpts = {},
): Promise<ReqResult> {
  return measureStreamRequest(base, "chat/completions", {
    messages: [{ role: "user", content }], chat_template_kwargs: { enable_thinking: true },
  }, maxTokens, o);
}

/** Raw completion timing uses the same framing and usage checks as chat. */
export async function measureCompletionRequest(
  base: string, prompt: string, maxTokens: number, o: ReqOpts = {},
): Promise<ReqResult> {
  return measureStreamRequest(base, "completions", { prompt }, maxTokens, o);
}

async function measureStreamRequest(base: string, route: "chat/completions" | "completions",
  input: Record<string, unknown>, maxTokens: number, o: ReqOpts): Promise<ReqResult> {
  const t0 = performance.now();
  // The signal covers headers AND body streaming — one budget for the leg.
  const signal = AbortSignal.timeout(o.timeoutMs ?? FIXED_BUDGET_MS);
  const r = await fetch(`${base}/v1/${route}`, {
    method: "POST",
    signal,
    headers: {
      "content-type": "application/json",
      ...(o.apiKey ? { authorization: `Bearer ${o.apiKey}` } : {}),
    },
    body: JSON.stringify({
      model: o.modelId ?? "bench", stream: true, max_tokens: maxTokens, temperature: 0,
      ...input,
      stream_options: { include_usage: true },
      ...(o.bodyExtra ?? {}),
    }),
  });
  if (!r.ok) throw new Error(`HTTP ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const headersMs = performance.now() - t0;
  const reader = r.body!.getReader();
  const dec = new TextDecoder();
  let buf = "";
  let tFirst = 0;
  let tLast = 0;
  let chunkTokens = 0;
  let toolCallChunks = 0;
  let firstByteMs = 0;
  let firstEventMs = 0;
  let doneSeen = false;
  const outputEventTimesMs: number[] = [];
  let text = "";
  let finishReason: string | null = null;
  interface Usage {
    prompt_tokens?: number;
    completion_tokens?: number;
    prompt_tokens_details?: { cached_tokens?: number };
  }
  let usage: Usage | null = null;
  const parseLine = (line: string) => {
      if (!line.startsWith("data:")) return;
      const now = performance.now();
      if (!firstEventMs) firstEventMs = now - t0;
      const payload = line.slice(5).trim();
      if (payload === "[DONE]") { doneSeen = true; return; }
      let j: {
        choices?: Array<{ text?: string; delta?: { content?: string; reasoning?: string; reasoning_content?: string;
          tool_calls?: Array<{ function?: { name?: string; arguments?: string } }> }; finish_reason?: string | null }>;
        usage?: Usage | null;
        error?: unknown;
      };
      try { j = JSON.parse(payload); } catch { throw new Error(`malformed SSE JSON: ${payload.slice(0, 120)}`); }
      if (j.error) throw new Error(`SSE error: ${JSON.stringify(j.error).slice(0, 300)}`);
      if (j.choices?.[0]?.finish_reason) finishReason = j.choices[0].finish_reason;
      const delta = j.choices?.[0]?.delta;
      // CONCATENATE both fields (B2): a chunk can carry content AND
      // reasoning; `content ?? reasoning` half-dropped it. mlx-lm streams
      // reasoning as `reasoning`; some builds use `reasoning_content`.
      const piece = route === "completions" ? (j.choices?.[0]?.text ?? "") :
        (delta?.content ?? "") + (delta?.reasoning ?? delta?.reasoning_content ?? "");
      const toolOutput = delta?.tool_calls?.some((call) => call.function?.name || call.function?.arguments);
      if (piece || toolOutput) {
        if (!tFirst) tFirst = now;
        tLast = now;
        outputEventTimesMs.push(now - t0);
        if (piece) chunkTokens++;
        if (toolOutput) toolCallChunks++;
        text += piece;
      }
      if (j.usage && typeof j.usage.completion_tokens === "number") usage = j.usage;
  };
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) { buf += dec.decode(); if (buf.trim()) parseLine(buf.trim()); break; }
      if (value.byteLength && !firstByteMs) firstByteMs = performance.now() - t0;
      buf += dec.decode(value, { stream: true });
      let nl: number;
      while ((nl = buf.indexOf("\n")) >= 0) {
        const line = buf.slice(0, nl).trim();
        buf = buf.slice(nl + 1);
        parseLine(line);
      }
    }
  } catch (error) { await reader.cancel(error).catch(() => {}); throw error; }
  finally { reader.releaseLock(); }
  const wallMs = performance.now() - t0;
  // Assignments occur inside the stream parser callback.
  const finalUsage = usage as Usage | null;
  if (!finalUsage || !Number.isInteger(finalUsage.completion_tokens) || finalUsage.completion_tokens! < 0 ||
      !Number.isInteger(finalUsage.prompt_tokens) || finalUsage.prompt_tokens! < 0)
    throw new Error("missing/invalid token usage; SSE chunk counts cannot measure token throughput");
  if (!doneSeen || !finishReason) throw new Error("incomplete SSE response: finish reason and [DONE] are required");
  if (!tFirst) throw new Error(`no output; TTFT undefined (completion_tokens=${finalUsage.completion_tokens}, finish_reason=${finishReason})`);
  const genTokens = finalUsage.completion_tokens!;
  const promptTokens = finalUsage.prompt_tokens!;
  const cachedTokens = finalUsage.prompt_tokens_details?.cached_tokens ?? 0;
  const dt = tLast - tFirst;
  return {
    ttftMs: tFirst - t0,
    headersMs, firstByteMs, firstEventMs, outputEventTimesMs, toolCallChunks, doneSeen,
    decodeTps: genTokens > 1 && dt > 0 ? ((genTokens - 1) * 1000) / dt : 0,
    wallMs, endToEndTps: genTokens * 1000 / wallMs, contentChunks: chunkTokens, finishReason,
    promptTokens, cachedTokens, genTokens,
    usedUsage: true,
    text,
  };
}

export interface ProbeOut { text: string; promptTokens: number }

/** Raw /v1/completions probe (B2): NO chat template, NO thinking toggle —
 *  the same prompt string hits every stack's tokenizer directly, so
 *  prompt_tokens inequality here is TOKENIZER drift, full stop. All three
 *  stacks route /v1/completions (ours: src/server.ts; mlx_lm.server:
 *  handle_text_completions; optiq serve wraps mlx-lm's server). */
async function completionProbe(base: string, prompt: string, o: ReqOpts): Promise<ProbeOut> {
  const r = await fetch(`${base}/v1/completions`, {
    method: "POST",
    signal: AbortSignal.timeout(o.timeoutMs ?? FIXED_BUDGET_MS),
    headers: {
      "content-type": "application/json",
      ...(o.apiKey ? { authorization: `Bearer ${o.apiKey}` } : {}),
    },
    body: JSON.stringify({
      model: o.modelId ?? "bench", prompt, max_tokens: 64, temperature: 0, stream: false,
      ...(o.bodyExtra ?? {}),
    }),
  });
  if (!r.ok) throw new Error(`HTTP ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const j = (await r.json()) as {
    choices?: Array<{ text?: string }>;
    usage?: { prompt_tokens?: number };
  };
  return { text: j.choices?.[0]?.text ?? "", promptTokens: j.usage?.prompt_tokens ?? 0 };
}

async function waitReady(base: string, apiKey: string | undefined, timeoutMs: number, assertAlive?: () => void): Promise<number> {
  const t0 = performance.now();
  while (performance.now() - t0 < timeoutMs) {
    assertAlive?.();
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

/** Filler sized in chars; ACTUAL length recorded from usage.prompt_tokens.
 * The fixed estimate keeps the exact input identical across stacks even if
 * tokenizers drift. Do not calibrate each engine to a different prompt. */
function fillerPrompt(targetTokens: number, nonce: string, charsPerTok = 3.6): string {
  const para = "Background context: the history of computation spans mechanical calculators, " +
    "vacuum tubes, transistors, integrated circuits, and modern GPU-accelerated systems " +
    "used for machine learning workloads on unified-memory architectures. ";
  let s = `Session ${nonce}. `;
  while (s.length < targetTokens * charsPerTok) s += para;
  return s + " In one short sentence, what is this text about?";
}

// ---- parity verdicts (B2, pure — tested in tests/unit/bench-serve-verdict.test.ts)

/** One verdict line for one probe of one arm pair. prompt_tokens equality
 *  is the HARD precondition: unequal counts mean the stacks tokenized (or
 *  templated) DIFFERENT prompts, so a char-diff would compare outputs of
 *  different inputs — the exact 2026-07-06 false-"diverged at char 0"
 *  failure. Only equal-token probes get the text comparison. */
export function probeVerdict(
  probe: "completion" | "chat", label: string,
  a: ProbeOut | null | undefined, b: ProbeOut | null | undefined,
): string {
  const tag = `${label} [${probe}-probe]`;
  if (!a || !b)
    return `- **parity ?** ${tag}: probe missing on ${!a && !b ? "both arms" : !a ? "first arm" : "second arm"} — not attempted`;
  if (a.promptTokens !== b.promptTokens) {
    const kind = probe === "completion" ? "TOKENIZER DRIFT" : "TEMPLATE/TOKENIZER DRIFT";
    return `- **parity ✗** ${tag}: ${kind} (${a.promptTokens} vs ${b.promptTokens}) — parity not attempted`;
  }
  if (!(a.promptTokens > 0))
    return `- **parity ?** ${tag}: prompt token counts UNVERIFIED; matching text cannot certify parity`;
  if (a.text === b.text)
    return `- **parity ✓** ${tag}: observed greedy text identical (prompt_tokens ${a.promptTokens} both); token-ID/logit oracle still required`;
  let i = 0;
  while (i < Math.min(a.text.length, b.text.length) && a.text[i] === b.text[i]) i++;
  return `- **parity ✗** ${tag}: equal prompt token counts (prompt_tokens ${a.promptTokens} both), ` +
    `diverged at char ${i}: …\`${a.text.slice(Math.max(0, i - 20), i + 20)}\` vs …\`${b.text.slice(Math.max(0, i - 20), i + 20)}\``;
}

// ---- the per-cell measurement session --------------------------------------

interface PhaseFailure { phase: string; error: string; stderrTail: string[] }

interface RawRequest {
  cell: Cell;
  phase: string;
  attempt: number;
  index: number;
  request: { content: string; maxTokens: number; bodyExtra: Record<string, unknown> };
  requestSha256: string;
  result?: ReqResult;
  error?: string;
  stderrTail?: string[];
  processAtFailure?: { pid: number; exitCode: number | null; signal: string | null };
}

interface RestartDurability {
  durable: boolean;
  flushMs: number;
  pendingSnapshots: number;
  pendingSpills: number;
  droppedSpills: number;
  failedSpills: number;
  longestDurablePrefixTokens: number;
  entries: number;
}

interface CellResult {
  cell: Cell;
  readyMs: number;
  /** RSS right after the server answers /v1/models — the loaded-but-idle
   *  baseline every later leg's growth is read against (B4). */
  idleRssMB: number;
  /** Cross-arm BIT-PARITY probes (B2). completion = raw /v1/completions
   *  (no template — tokenizer-only comparison); chat = chat completion
   *  with enable_thinking PINNED true on EVERY arm (mlx-lm silently
   *  injects it for thinking models; unpinned arms render different
   *  prompts). Null = the parity phase failed (see phaseFailures). */
  parity: { completion: ProbeOut; chat: ProbeOut } | null;
  /** Peak resident-set of the SERVER PROCESS sampled over the whole cell
   *  (MB). RSS undercounts GPU-shared allocations — comparable across
   *  arms, labeled, and the growth/leak signal. */
  peakRssMB: number;
  /** Per-leg peak RSS (B4): sampler max between leg boundaries, in leg
   *  order — attributes WHERE the memory went instead of one blind peak. */
  rssByLeg: Array<[string, number]>;
  /** COLD START: launch → FIRST generated token (ready + the first
   *  request's TTFT, which pays page fault-in / trace warmup — the number
   *  a user launching the server actually feels). Null = warmup failed. */
  coldStartMs: number | null;
  /** RESTART STORY (ctx leg only): kill the server, respawn, re-send the
   *  long-context prompt ONCE. Ours restores the prefix from the SSD tier
   *  (Layer 0); stacks without persistence re-prefill from scratch. */
  restart: null | {
    readyMs: number;
    ctxTtftMs: number;
    cachedTokens: number;
    durability: RestartDurability | null;
  };
  decodeTps: number[] | null;
  decodeTag: string;
  ttft: null | {
    coldMs: number[]; prefill1kTps: number[];
    warmMs: number; warmCachedTokens: number;
  };
  ctx: null | {
    promptTokens: number; prefillTps: number; ttftMs: number;
    decodeTps: number[]; cachedRepeatTtftMs: number;
  };
  agg: null | { tps: number; perStream: number };
  /** Phases that failed even after the drain-probe/retry policy — the
   *  cell KEEPS its measured phases and these render as footnoted "—". */
  phaseFailures: PhaseFailure[];
}

/** Ring-buffered stderr tail (B1): the old harness piped stderr and never
 *  read it, so a dying child's last words were lost (and a chatty one
 *  could block on a full pipe). Last N lines ride along in failure records. */
function pumpStderr(stream: ReadableStream<Uint8Array>, ring: string[]): void {
  void (async () => {
    const reader = stream.getReader();
    const dec = new TextDecoder();
    let buf = "";
    try {
      for (;;) {
        const { done, value } = await reader.read();
        if (done) break;
        buf += dec.decode(value, { stream: true });
        let nl: number;
        while ((nl = buf.indexOf("\n")) >= 0) {
          const line = buf.slice(0, nl);
          buf = buf.slice(nl + 1);
          if (line.trim()) {
            ring.push(line);
            if (ring.length > STDERR_TAIL_LINES) ring.shift();
          }
        }
      }
    } catch { /* child killed mid-read */ }
  })();
}

async function runCell(c: Cell, port: number, withContext: boolean, ssdDir: string | undefined, raw: RawRequest[]): Promise<CellResult> {
  const cmd = cmdlineFor(c, port, ssdDir)!;
  const apiKey = c.arm === "optiq-mixed" ? "sk-optiq-bench" : undefined;
  // mlx_lm.server LOADS the request's model field as a repo id when it
  // doesn't match — send the real path so every stack serves the model it
  // was started with (ours ignores unknown ids; theirs would download).
  const modelId = MODELS[c.model]!.path;
  // B3 (revised after LIVE verification, 2026-07-06): mlx-lm 0.31.3 routes
  // seedless requests through BatchGenerator, which bypasses optiq's
  // install_mixed_kv hooks — the optiq-mixed arm serves bf16 KV. Runtime-
  // proven with spies on the real quantization call sites: zero quantize
  // calls across an 11.9k seedless request. Do NOT "fix" this by seeding:
  // a request-body `seed` routes to _serve_single where quantization IS
  // live, the quantized entry lands in the server's shared prompt cache,
  // and the NEXT batchable request crashes the worker ("QuantizedKVCache
  // does not yet support batching with history" in _merge_caches) — also
  // live-verified. So the arm runs unseeded and its cells are labeled
  // bf16-KV; mixed-KV has NO valid HTTP oracle on this mlx-lm — per-layer
  // parity stays on the script-driven optiq path (goldens).
  const singleStreamExtra: Record<string, unknown> = {};
  let activePhase = "startup";
  let phaseAttempt = 0;
  let phaseRequest = 0;
  const nonce = (index = 0) => workloadNonce(WORKLOAD_SEED, activePhase, phaseAttempt, index);
  const timedRequest = async (base: string, content: string, maxTokens: number, o: ReqOpts = {}): Promise<ReqResult> => {
    const request = { content, maxTokens, bodyExtra: {
      temperature: 0, chat_template_kwargs: { enable_thinking: true }, ...o.bodyExtra,
    } };
    const sample: RawRequest = {
      cell: c, phase: activePhase, attempt: phaseAttempt, index: phaseRequest++, request,
      requestSha256: createHash("sha256").update(JSON.stringify(request)).digest("hex"),
    };
    raw.push(sample); // retain failed requests and retries too
    try {
      sample.result = await measureChatRequest(base, content, maxTokens, o);
      if (DIAGNOSTIC) sample.stderrTail = [...stderrTail];
      return sample.result;
    }
    catch (e) {
      sample.error = String(e);
      sample.stderrTail = [...stderrTail];
      sample.processAtFailure = { pid: proc.pid, exitCode: proc.exitCode, signal: proc.signalCode ?? null };
      throw e;
    }
  };

  const stderrTail: string[] = [];
  // stdout "ignore": we never read it, and an unread pipe can block a
  // chatty server. stderr is pumped into the ring buffer above.
  let proc = Bun.spawn(cmd, { stdout: "ignore", stderr: "pipe" });
  let pid = proc.pid;
  pumpStderr(proc.stderr, stderrTail);
  const base = `http://127.0.0.1:${port}`;
  const assertAlive = () => {
    if (proc.exitCode !== null || proc.signalCode)
      throw new Error(`server exited before ready: code=${proc.exitCode} signal=${proc.signalCode}; ${stderrTail.join("\n").slice(-2000)}`);
  };

  // Peak-RSS sampler: cell-lifetime max PLUS a per-leg max that markLeg()
  // snapshots and re-seeds at each boundary (B4).
  const sampleRss = (p: number): number => {
    if (c.arm === "mlx-bun-isolated") {
      // The parent deliberately has no model. Account for its complete process
      // tree; reporting parent RSS alone would invent a memory improvement.
      const all = Bun.spawnSync(["ps", "-axo", "pid=,ppid=,rss="]);
      if (all.exitCode !== 0) return 0;
      const rows = all.stdout.toString().trim().split("\n").map((line) => line.trim().split(/\s+/).map(Number));
      const owned = new Set([p]);
      let changed = true;
      while (changed) {
        changed = false;
        for (const [pid, parent] of rows) if (owned.has(parent!) && !owned.has(pid!)) {
          owned.add(pid!); changed = true;
        }
      }
      return rows.reduce((sum, [pid, , rss]) => sum + (owned.has(pid!) ? rss! : 0), 0) / 1024;
    }
    const r = Bun.spawnSync(["ps", "-o", "rss=", "-p", String(p)]);
    return r.exitCode === 0 ? Number(r.stdout.toString().trim()) / 1024 : 0;
  };
  let peakRssMB = 0;
  let legPeakMB = 0;
  const rssByLeg: Array<[string, number]> = [];
  const rssTimer = setInterval(() => {
    const mb = sampleRss(pid);
    if (mb > peakRssMB) peakRssMB = mb;
    if (mb > legPeakMB) legPeakMB = mb;
  }, 500);
  const markLeg = (name: string): void => {
    rssByLeg.push([name, legPeakMB]);
    legPeakMB = sampleRss(pid); // re-seed with the current residency
  };

  const phaseFailures: PhaseFailure[] = [];
  let respawnUsed = false;

  const killProc = async (graceMs = 5_000): Promise<void> => {
    try { proc.kill(); } catch { return; }
    let timer: ReturnType<typeof setTimeout> | null = null;
    const grace = new Promise<void>((resolve) => {
      timer = setTimeout(resolve, graceMs);
      timer.unref?.();
    });
    await Promise.race([proc.exited.then(() => {}), grace]);
    if (timer) clearTimeout(timer);
    try { proc.kill(9); } catch { /* gone */ }
  };
  const spawnProc = (): void => {
    proc = Bun.spawn(cmd, { stdout: "ignore", stderr: "pipe" });
    pid = proc.pid;
    pumpStderr(proc.stderr, stderrTail);
  };
  /** Cheap 1-token request: is the server still answering at all? */
  const drainProbe = async (): Promise<boolean> => {
    try {
      await measureChatRequest(base, "ok", 1, { apiKey, modelId, timeoutMs: DRAIN_PROBE_BUDGET_MS });
      return true;
    } catch { return false; }
  };
  /** B1 phase policy: on failure, drain-probe; server alive → retry the
   *  phase once; dead → respawn ONCE per cell, then retry. A phase that
   *  still fails is recorded (name + error + stderr tail) and returns
   *  null — every already-measured phase survives. Multi-request phases
   *  (cold+warm TTFT, ctx cold+repeats) retry AS A UNIT so intra-phase
   *  premises (warm follows cold on the same server) still hold. */
  // Once the drain probe finds the server dead AND the respawn is spent,
  // the cell is unrecoverable — later phases skip IMMEDIATELY instead of
  // each burning a full timeout budget against a known-zombie server
  // (the 2026-07-06b 12B/mlx-lm cell wasted ~15 min of dead waiting).
  let serverDeclaredDead = false;
  const runPhase = async <T>(name: string, fn: () => Promise<T>): Promise<T | null> => {
    activePhase = name;
    phaseAttempt = 0;
    phaseRequest = 0;
    const errStr = (e: unknown): string => `${(e as Error).name}: ${(e as Error).message}`.slice(0, 300);
    const record = (msg: string): void => {
      console.log(`  [phase ${name}] FAILED: ${msg.slice(0, 160)}`);
      phaseFailures.push({ phase: name, error: msg.slice(0, 500), stderrTail: [...stderrTail] });
    };
    if (serverDeclaredDead) { record("skipped — server dead, respawn already used"); return null; }
    try { return await fn(); } catch (e1) {
      const firstFailureStderr = [...stderrTail];
      if (!(await drainProbe())) {
        if (respawnUsed) {
          serverDeclaredDead = true;
          record(`${errStr(e1)} — server unresponsive, respawn already used`);
          return null;
        }
        respawnUsed = true;
        try {
          await killProc();
          await Bun.sleep(1000);
          spawnProc();
          await waitReady(base, apiKey, 600_000, assertAlive);
        } catch (e2) {
          record(`${errStr(e1)} — respawn failed: ${errStr(e2)}`);
          return null;
        }
      }
      phaseAttempt = 1;
      phaseRequest = 0;
      try {
        const result = await fn();
        const error = `${errStr(e1)}; recovered on retry. Compare only matching attempts and request hashes.`;
        console.log(`  [phase ${name}] RECOVERED: ${error.slice(0, 220)}`);
        phaseFailures.push({ phase: name, error, stderrTail: firstFailureStderr });
        return result;
      } catch (e2) {
        record(`${errStr(e1)} — retry: ${errStr(e2)}`);
        return null;
      }
    }
  };

  try {
    const readyMs = await waitReady(base, apiKey, 600_000, assertAlive);
    const idleRssMB = sampleRss(pid);
    legPeakMB = idleRssMB;

    // First request = the true cold-start tail (page fault-in, compile
    // traces): its TTFT is RECORDED (launch→first-token = ready + this),
    // then it doubles as the warmup for the steady-state legs.
    // Warmup gets the waitReady-class budget, NOT the fixed one: stacks
    // that defer model load to the first request (mlx_lm.server) pay the
    // whole multi-GB load + first prefill here, and 12B blew the 120 s
    // budget twice on 2026-07-06 — losing the entire baseline cell for
    // the sake of a "timeout" that was really a slow cold start. The
    // budget exists to catch HANGS; 600 s still does.
    const coldStartMs = await runPhase("warmup", async () => {
      const first = await timedRequest(base, "Warmup: say hello.", 32,
        { apiKey, modelId, timeoutMs: 600_000, bodyExtra: singleStreamExtra });
      return readyMs + first.ttftMs;
    });
    markLeg("warmup");

    // PARITY PROBES (B2): raw completion (same prompt string → every
    // stack's tokenizer, no template) + chat with enable_thinking pinned
    // true on ALL arms (mlx-lm passes chat_template_kwargs through;
    // ours honors it). Deterministic greedy on the same model ⇒ stacks of
    // the same KV scheme must emit IDENTICAL text. Verdicts at report time.
    const parity = await runPhase("parity", async () => {
      const completion = await completionProbe(base, "The first eight prime numbers are",
        { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS, bodyExtra: singleStreamExtra });
      const chatRes = await timedRequest(base,
        "List the first eight prime numbers, then briefly explain what makes a number prime.", 64,
        { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS,
          bodyExtra: { ...singleStreamExtra, chat_template_kwargs: { enable_thinking: true } } });
      return {
        completion,
        chat: { text: chatRes.text, promptTokens: chatRes.promptTokens },
      };
    });
    markLeg("parity");

    // Fixed-count decode sampling. Retain slow samples and mark instability;
    // selecting the fastest subset biases comparisons upward.
    const decode = await runPhase("decode", async () => {
      const tps: number[] = [];
      const one = async (i: number): Promise<void> => {
        const res = await timedRequest(
          base, `Run ${nonce(i)}: write a detailed essay about the history of computing.`,
          DECODE_TOKENS, { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS, bodyExtra: singleStreamExtra });
        tps.push(res.decodeTps);
      };
      for (let i = 0; i < DECODE_RUNS; i++) await one(i);
      return { picked: tps, tag: spreadOf(tps) > SPREAD_TOL ? `unstable spread=${spreadOf(tps).toFixed(2)}` : "" };
    });
    markLeg("decode");
    const decodeMedianTps = decode ? median(decode.picked) : 0;

    // TTFT cold @~1k (fresh nonce per run = every stack's cache misses) +
    // warm (EXACT repeat of the last cold prompt — each stack's own prompt
    // cache gets its fair shot). ONE phase: a respawned retry re-runs
    // cold+warm together, so warm always follows its cold on ONE server.
    const ttft = await runPhase("ttft1k", async () => {
      const coldMs: number[] = [];
      const prefill1kTps: number[] = [];
      let lastColdPrompt = "";
      for (let i = 0; i < TTFT_RUNS; i++) {
        lastColdPrompt = fillerPrompt(1024, nonce(i));
        const res = await timedRequest(base, lastColdPrompt, 8,
          { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS, bodyExtra: singleStreamExtra });
        coldMs.push(res.ttftMs);
        if (res.promptTokens > 0) {
          prefill1kTps.push((res.promptTokens * 1000) / res.ttftMs);
        }
      }
      const warm = await timedRequest(base, lastColdPrompt, 8,
        { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS, bodyExtra: singleStreamExtra });
      return { coldMs, prefill1kTps, warmMs: warm.ttftMs, warmCachedTokens: warm.cachedTokens };
    });
    markLeg("ttft1k");

    // LONG CONTEXT: ONE prefill (the whole point — never generate <ctx>
    // tokens to measure a context), then decode sampled on 64 tokens; two
    // cached repeats give more decode@ctx samples for the price of zero
    // additional prefills. Cold budget scales from the MEASURED prefill@1k
    // rate (safety 6: long-context prefill runs slower than the 1k rate it
    // is extrapolated from); repeat budgets from the measured ctx rate.
    let ctxPrompt = "";
    const ctx = withContext ? await runPhase("ctx", async () => {
      ctxPrompt = fillerPrompt(CTX_TOKENS, nonce());
      const coldBudget = scaledBudgetMs(
        CTX_TOKENS, ttft ? median(ttft.prefill1kTps) : 0, CTX_MIN_BUDGET_MS, 6);
      const cold = await timedRequest(base, ctxPrompt, 64,
        { apiKey, modelId, timeoutMs: coldBudget, bodyExtra: singleStreamExtra });
      const prefillTps = cold.promptTokens > 0 ? (cold.promptTokens * 1000) / cold.ttftMs : 0;
      // Repeats SHOULD hit the cache, but budget for a full re-prefill —
      // a stack whose cache silently missed must time out honestly late.
      const repBudget = scaledBudgetMs(cold.promptTokens || CTX_TOKENS, prefillTps, CTX_MIN_BUDGET_MS);
      const decodeTpsCtx = [cold.decodeTps];
      let cachedRepeatTtftMs = -1;
      for (let i = 0; i < 2; i++) {
        const rep = await timedRequest(base, ctxPrompt, 64,
          { apiKey, modelId, timeoutMs: repBudget, bodyExtra: singleStreamExtra });
        decodeTpsCtx.push(rep.decodeTps);
        cachedRepeatTtftMs = rep.ttftMs;
      }
      return {
        promptTokens: cold.promptTokens, prefillTps, ttftMs: cold.ttftMs,
        decodeTps: decodeTpsCtx, cachedRepeatTtftMs,
      };
    }) : null;
    markLeg("ctx");

    // RESTART STORY: kill + respawn the SAME server, re-send the same
    // long-context prompt once. mlx-bun restores the prefix from the SSD
    // tier (Layer 0, --ssd-cache); stacks without persistence pay the FULL
    // re-prefill — so the request budget assumes a full re-prefill at the
    // measured ctx rate. mlx-bun exposes an explicit durability boundary;
    // wait for it instead of guessing how long a large SSD write needs.
    const restart = ctx ? await runPhase("restart", async () => {
      let durability: RestartDurability | null = null;
      if (c.arm.startsWith("mlx-bun")) {
        const flushStarted = performance.now();
        const flushResponse = await fetch(`${base}/admin/cache/flush`, {
          method: "POST",
          signal: AbortSignal.timeout(600_000),
        });
        const flush = await flushResponse.json() as {
          durable?: boolean;
          pendingSnapshots?: number;
          pendingSpills?: number;
          droppedSpills?: number;
          failedSpills?: number;
          entries?: number;
          longest_durable_prefix_tokens?: number;
        };
        if (!flushResponse.ok || !flush.durable)
          throw new Error(`cache durability flush failed: ${JSON.stringify(flush).slice(0, 300)}`);
        durability = {
          durable: true,
          flushMs: performance.now() - flushStarted,
          pendingSnapshots: flush.pendingSnapshots ?? -1,
          pendingSpills: flush.pendingSpills ?? -1,
          droppedSpills: flush.droppedSpills ?? -1,
          failedSpills: flush.failedSpills ?? -1,
          longestDurablePrefixTokens: flush.longest_durable_prefix_tokens ?? -1,
          entries: flush.entries ?? -1,
        };
      }
      await killProc(c.arm.startsWith("mlx-bun") ? 180_000 : 5_000);
      await Bun.sleep(1000);
      spawnProc();
      const readyMs2 = await waitReady(base, apiKey, 600_000, assertAlive);
      const budget = scaledBudgetMs(ctx.promptTokens, ctx.prefillTps, CTX_MIN_BUDGET_MS);
      const afterRestart = await timedRequest(base, ctxPrompt, 8,
        { apiKey, modelId, timeoutMs: budget, bodyExtra: singleStreamExtra });
      return {
        readyMs: readyMs2,
        ctxTtftMs: afterRestart.ttftMs,
        cachedTokens: afterRestart.cachedTokens,
        durability,
      };
    }) : null;
    markLeg("restart");

    // AGGREGATE: 4 concurrent short generations (the sub-agents number).
    // Ours batches; stacks that queue serve them serially — either way the
    // number answers "what do 4 agents experience", same for everyone.
    // Budget = serial worst case at the measured decode rate. NO seed here
    // even for optiq-mixed (seeding forces their non-batched path and
    // would serialize the very thing this leg measures) — footnoted as
    // batched-bf16 in the report.
    const agg = await runPhase("agg", async () => {
      const aggBudget = scaledBudgetMs(AGG_TOKENS * AGG_STREAMS, decodeMedianTps, FIXED_BUDGET_MS);
      const t0 = performance.now();
      const rs = await Promise.all(
        Array.from({ length: AGG_STREAMS }, (_, i) =>
          timedRequest(base, `Agent ${i} ${nonce(i)}: write a detailed essay about computers.`,
            AGG_TOKENS, { apiKey, modelId, timeoutMs: aggBudget })),
      );
      const wallS = (performance.now() - t0) / 1000;
      return {
        tps: rs.reduce((a, r) => a + r.genTokens, 0) / wallS,
        perStream: rs.reduce((a, r) => a + r.decodeTps, 0) / rs.length,
      };
    });
    markLeg("agg");

    return {
      cell: c, readyMs, idleRssMB, coldStartMs, restart,
      parity,
      peakRssMB, rssByLeg,
      decodeTps: decode?.picked ?? null, decodeTag: decode?.tag ?? "",
      ttft: ttft ? {
        coldMs: ttft.coldMs, prefill1kTps: ttft.prefill1kTps,
        warmMs: ttft.warmMs, warmCachedTokens: ttft.warmCachedTokens,
      } : null,
      ctx, agg, phaseFailures,
    };
  } finally {
    clearInterval(rssTimer);
    await killProc();
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
  serialBenchmarkArgs(argv); // fail before preflight or any server process
  if (argv[0] !== "all" && !DIAGNOSTIC && !flag("dry-run"))
    throw new Error("use all for the quiet benchmark, or --diagnostic for an explicitly non-quotable run");
  if (![DECODE_TOKENS, CTX_TOKENS].every((n) => Number.isSafeInteger(n) && n > 0))
    throw new Error("--tokens and --context must be positive integers");
  if (!WORKLOAD_SEED || WORKLOAD_SEED.startsWith("--")) throw new Error("--workload-seed requires a value");
  const localPath = opt("model-path", "");
  if (localPath && argv.includes("--models"))
    throw new Error("use --model-path for one exact artifact, or --models for registry entries");
  if (argv.includes("--model-path") && (!localPath || localPath.startsWith("--")))
    throw new Error("--model-path requires a local model directory");
  if (localPath) MODELS.local = localBenchmarkModel(localPath, opt("label", ""));
  const models = (localPath ? "local" : opt("models", "cpm5,e4b,12B,qwen27b")).split(",").filter((m) => {
    if (!MODELS[m] || !existsSync(`${MODELS[m]!.path}/config.json`)) {
      console.log(`[skip] unknown/missing model ${m}`);
      return false;
    }
    return true;
  });
  if (!models.length) throw new Error("no benchmark models available");
  // mlx-bun-serial (--batch 1) is the CONTROL arm — it anchors both the
  // pure serial-vs-serial column against mlx-lm and the unified-engine-
  // vs-pinned-serial consistency check (perf + bit parity) that validates
  // the batch-8 default. Controls run by default; --no-serial skips it.
  // optiq-mixed is OFF the default set: with install_mixed_kv inert on
  // mlx-lm 0.31.3's batch path (lab/repro/optiq-mixed-kv-inert), the arm
  // is mlx-lm bf16 wearing a different banner — running it benchmarks
  // mlx-lm twice. The mixed scheme's perf question is answered by
  // mlx-bun-mixed vs mlx-bun (same engine, scheme on/off); its
  // correctness oracle is the script-driven optiq goldens. Resurrect via
  // `--arms ...,optiq-mixed` once upstream fixes serve.
  let arms: Arm[] = ["mlx-bun", "mlx-bun-serial", "mlx-lm", "mlx-bun-mixed"];
  if (flag("no-serial")) arms = arms.filter((a) => a !== "mlx-bun-serial");
  const armsRaw = opt("arms", "");
  if (armsRaw) arms = armsRaw.split(",") as Arm[];
  const withContext = !flag("skip-context");
  for (const model of models) {
    for (const arm of arms) {
      const reason = unsupportedBenchmarkArm(MODELS[model]!, arm);
      if (reason && (armsRaw || reason.startsWith("unknown arm")))
        throw new Error(`${model}/${arm}: ${reason}`);
      if (armsRaw && !cmdlineFor({ model, arm }, 8971))
        throw new Error(`${model}/${arm}: required KV config or oracle executable missing`);
    }
  }
  if (flag("dry-run")) {
    console.log(JSON.stringify({
      measurement: false, diagnostic: DIAGNOSTIC,
      runtimeEnvironment: benchmarkRuntimeEnvironment(),
      workload: { seed: WORKLOAD_SEED, decodeTokens: DECODE_TOKENS, contextTarget: CTX_TOKENS, withContext, decodeRuns: DECODE_RUNS, enableThinking: true },
      models: models.map((id) => ({ id, ...MODELS[id]! })),
      cells: models.flatMap((model) => arms.map((arm) => ({
        model, arm, command: cmdlineFor({ model, arm }, 8971, "<temporary-ssd-cache>"),
        skipReason: unsupportedBenchmarkArm(MODELS[model]!, arm) ??
          (cmdlineFor({ model, arm }, 8971) ? null : "required KV config or oracle executable missing"),
      }))),
    }, null, 2));
    return;
  }
  // Validate and allow CPU-only inspection before the quotable-run preflight.
  const machineBefore = checkMachine();
  if (!DIAGNOSTIC) {
    const pre = Bun.spawnSync([process.execPath, new URL("./bench-h2h.ts", import.meta.url).pathname, "preflight"], { stdio: ["inherit", "inherit", "inherit"] });
    if (pre.exitCode !== 0) process.exit(pre.exitCode ?? 1);
    Bun.spawn(["caffeinate", "-dimsu", "-w", String(process.pid)], { stdio: ["ignore", "ignore", "ignore"] }).unref();
  }

  const db = new EvalDB();
  const commit = gitCommit();
  const machine = machineHeader();
  console.log(`bench-serve · ${machine}\n`);
  const results: CellResult[] = [];
  const failures: { cell: string; error: string; stderrTail?: string[] }[] = [];
  const requests: RawRequest[] = [];
  const out = opt("out", `reports/benchmarks-serve-${new Date().toISOString().slice(0, 10)}-${Bun.spawnSync(["hostname", "-s"]).stdout.toString().trim()}.md`);
  mkdirSync(dirname(out), { recursive: true });
  const rawPath = `${out}.json`;
  const sourceDiff = () => createHash("sha256").update(Bun.spawnSync([
    "git", "diff", "HEAD", "--", "src", "native", "scripts",
  ]).stdout).digest("hex");
  const sourceDiffStart = sourceDiff();
  const sourceSnapshotStart = benchmarkSourceSnapshot();
  const saveRaw = () => Bun.write(rawPath, JSON.stringify({
    schemaVersion: 4, measurement: true, diagnostic: DIAGNOSTIC, canonical: false,
    runtimeEnvironment: benchmarkRuntimeEnvironment(),
    qualification: DIAGNOSTIC ? "diagnostic; not eligible for canonical results" : "quiet preflight passed; paired stability and correctness review still required",
    machine, machineBefore, machineAtSave: checkMachine(), commit, bun: Bun.version,
    sourceDiffStart, sourceDiffAtSave: sourceDiff(),
    sourceSnapshotStart, sourceSnapshotAtSaveSha256: benchmarkSourceSnapshot().sha256,
    identityNote: "Snapshot hashes tracked and untracked, non-ignored src/native/scripts plus package.json and bun.lock. External native binaries, oracle packages and weight content hashes belong in the campaign manifest.",
    workload: { seed: WORKLOAD_SEED, decodeTokens: DECODE_TOKENS, contextTarget: CTX_TOKENS, withContext, decodeRuns: DECODE_RUNS, enableThinking: true },
    models: models.map((id) => ({ id, ...MODELS[id]! })),
    commands: models.flatMap((model) => arms.map((arm) => ({ model, arm, command: cmdlineFor({ model, arm }, 8971, "<temporary-ssd-cache>") }))),
    results, failures, requests,
  }, null, 2));

  for (const model of models) {
    for (const arm of arms) {
      const c: Cell = { model, arm };
      if (!cmdlineFor(c, 0)) {
        console.log(`[skip] ${model}/${arm}: ${unsupportedBenchmarkArm(MODELS[model]!, arm) ?? "required KV config or oracle executable missing"}`);
        continue;
      }
      const key = `${model}/${arm}`;
      console.log(`=== ${key} ===`);
      const ssdDir = arm.startsWith("mlx-bun")
        ? mkdtempSync(join(tmpdir(), "mlxbun-bench-ssd-"))
        : undefined;
      try {
        const res = await runCell(c, 8971, withContext, ssdDir, requests);
        results.push(res);
        // Phase failures are cell-survivable (B1) but still land in the
        // report's failures section with the child's stderr tail.
        for (const pf of res.phaseFailures)
          failures.push({ cell: `${key} [phase ${pf.phase}]`, error: pf.error, stderrTail: pf.stderrTail });
        const decodeMed = res.decodeTps ? median(res.decodeTps) : null;
        const actualOutputCounts = requests.filter((s) =>
          s.cell.model === model && s.cell.arm === arm && s.phase === "decode" && s.result,
        ).map((s) => s.result!.genTokens);
        console.log(
          `  ready ${(res.readyMs / 1000).toFixed(1)}s · coldStart ${res.coldStartMs != null ? (res.coldStartMs / 1000).toFixed(1) : "—"}s · rssPeak ${res.peakRssMB.toFixed(0)}MB · decode ${decodeMed?.toFixed(1) ?? "—"} tok/s ${res.decodeTag} · ` +
          (res.restart ? `restartCtxTtft ${res.restart.ctxTtftMs.toFixed(0)}ms (cached ${res.restart.cachedTokens}) · ` : "") +
          (res.ttft ? `ttft ${median(res.ttft.coldMs).toFixed(0)}ms cold / ${res.ttft.warmMs.toFixed(0)}ms warm (cached ${res.ttft.warmCachedTokens}) · ` : "ttft — · ") +
          (res.ctx ? `ctx@${res.ctx.promptTokens} prefill ${res.ctx.prefillTps.toFixed(0)} tok/s decode ${median(res.ctx.decodeTps).toFixed(1)} tok/s · ` : "") +
          (res.agg ? `agg×${AGG_STREAMS} ${res.agg.tps.toFixed(1)} tok/s` : "agg —"),
        );
        db.record({
          modelPath: MODELS[model]!.path,
          commitSha: commit,
          promptTokens: res.ctx?.promptTokens ?? 0,
          generatedTokens: actualOutputCounts.length ? median(actualOutputCounts) : 0,
          prefillTps: res.ctx?.prefillTps ?? (res.ttft ? median(res.ttft.prefill1kTps) : 0),
          decodeTps: decodeMed ?? 0,
          peakBytes: 0,
          stack: (arm.startsWith("mlx-bun") ? "mlx-bun" : arm === "mlx-lm" ? "mlx-lm" : "optiq") + (DIAGNOSTIC ? "-serve-diagnostic" : ""),
          machineState: machine,
          notes: `serve-h2h diagnostic=${DIAGNOSTIC} arm=${arm} seed=${WORKLOAD_SEED} raw=${rawPath} decode_metric=SSE-window output_count=median_actual requested=${DECODE_TOKENS} ` +
            (res.ttft ? `ttft_cold=${median(res.ttft.coldMs).toFixed(0)} ttft_warm=${res.ttft.warmMs.toFixed(0)} warm_cached=${res.ttft.warmCachedTokens} ` : "") +
            (res.agg ? `agg${AGG_STREAMS}=${res.agg.tps.toFixed(1)} agg_per=${res.agg.perStream.toFixed(1)} ` : "") +
            (res.ctx ? `ctx=${res.ctx.promptTokens} ctx_ttft=${res.ctx.ttftMs.toFixed(0)} ctx_decode=${median(res.ctx.decodeTps).toFixed(1)} ctx_rep_ttft=${res.ctx.cachedRepeatTtftMs.toFixed(0)} ` : "") +
            `ready_ms=${res.readyMs.toFixed(0)} ` +
            (res.coldStartMs != null ? `cold_start_ms=${res.coldStartMs.toFixed(0)} ` : "") +
            `rss_peak_mb=${res.peakRssMB.toFixed(0)} rss_idle_mb=${res.idleRssMB.toFixed(0)} ` +
            (res.restart ? `restart_ctx_ttft=${res.restart.ctxTtftMs.toFixed(0)} restart_cached=${res.restart.cachedTokens} ` : "") +
            (res.restart?.durability
              ? `cache_flush_ms=${res.restart.durability.flushMs.toFixed(0)} ` +
                `cache_durable=${res.restart.durability.durable} ` +
                `durable_prefix=${res.restart.durability.longestDurablePrefixTokens} `
              : "") +
            (res.phaseFailures.length ? `failed_phases=${res.phaseFailures.map((f) => f.phase).join("+")} ` : "") +
            `${res.decodeTag}`.trim(),
        });
      } catch (e) {
        console.log(`  FAILED: ${(e as Error).message.slice(0, 200)}`);
        failures.push({ cell: key, error: (e as Error).message.slice(0, 300) });
      } finally {
        if (ssdDir) rmSync(ssdDir, { recursive: true, force: true });
        await saveRaw();
      }
    }
  }

  // ---- markdown report ----
  const lines: string[] = [];
  lines.push(`# serve h2h — ${new Date().toISOString().slice(0, 10)}`);
  if (DIAGNOSTIC) lines.push("", "Diagnostic run. These results are not eligible for canonical performance claims.");
  lines.push(``, `machine: ${machine}`, `commit: ${commit}`, `toolchain: Bun ${Bun.version}`, ``);
  lines.push(`raw requests, counts, finish reasons, timings and retries: ${rawPath}`);
  const serverArgs = serialBenchmarkArgs(argv);
  if (serverArgs.length) lines.push(`Configured serial experiment: ${JSON.stringify(serverArgs)}. Compare separately recorded controls with matching policy.`);
  lines.push(`Runtime overrides: ${JSON.stringify(benchmarkRuntimeEnvironment())}`);
  lines.push(`workload seed: ${WORKLOAD_SEED}; five fixed decode samples, all retained.`);
  lines.push(`All numbers over HTTP against REAL servers (mlx-bun = the actual CLI).`);
  lines.push(`Requests pin enable_thinking=true on every arm. ttft cold = nonce-busted ~1k prompt;`);
  lines.push(`warm = exact repeat (each stack's own prompt cache). ctx figures from`);
  lines.push(`ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.`);
  lines.push(`Decode columns measure the visible SSE interval, not GPU time; chunk batching can distort them.`);
  lines.push(`End-to-end throughput uses actual completion tokens divided by total request wall time.`);
  lines.push(`Pair raw samples by phase/attempt/index and request hash; check cache state, prompt/output counts, finish reasons and output identity.`);
  if (sourceDiffStart !== sourceDiff()) lines.push(`WARNING: tracked inference/benchmark source changed during this run; re-establish the baseline before quoting it.`);
  if (arms.includes("optiq-mixed")) {
    lines.push(`optiq-mixed cells are effectively **bf16 KV** (live-verified 2026-07-06,`);
    lines.push(`lab/repro/optiq-mixed-kv-inert): mlx-lm 0.31.3 routes all seedless text`);
    lines.push(`requests through BatchGenerator, bypassing optiq's kv-quant hooks. Seeding`);
    lines.push(`is NOT a workaround — a seeded request quantizes into the shared prompt`);
    lines.push(`cache and the next batchable request CRASHES the server worker. Mixed-KV`);
    lines.push(`has no valid HTTP oracle on this mlx-lm; per-layer parity remains on the`);
    lines.push(`script-driven optiq path (goldens).`, ``);
  } else {
    lines.push(`mixed-KV: perf = mlx-bun-mixed vs mlx-bun (same engine, scheme on/off);`);
    lines.push(`correctness = script-driven optiq goldens. No optiq-mixed HTTP arm —`);
    lines.push(`optiq serve's kv-quant is inert on this mlx-lm (lab/repro/`);
    lines.push(`optiq-mixed-kv-inert), so that arm would just re-benchmark mlx-lm bf16.`, ``);
  }
  for (const model of models) {
    const rows = results.filter((r) => r.cell.model === model);
    if (!rows.length) continue;
    lines.push(`## ${MODELS[model]!.label}`, ``);
    lines.push(`artifact: ${MODELS[model]!.path}`);
    if (MODELS[model]!.configSha256) lines.push(`config sha256: ${MODELS[model]!.configSha256}`);
    if (MODELS[model]!.packedTrellis)
      lines.push(`Packed trellis is a Lab artifact. No stock mlx-lm/optiq same-artifact comparison; carrier quality checks do not establish packed-decode parity.`);
    lines.push(``);
    const decodeSamples = requests.filter((s) => s.cell.model === model && s.phase === "decode" && s.result);
    lines.push(`short-prompt request wall time (includes prefill and stream completion):`, ``);
    for (const arm of arms) {
      const samples = decodeSamples.filter((s) => s.cell.arm === arm);
      if (samples.length) lines.push(`- ${arm}: median ${median(samples.map((s) => s.result!.wallMs)).toFixed(0)} ms; median ${median(samples.map((s) => s.result!.endToEndTps)).toFixed(2)} tok/s; actual output counts ${samples.map((s) => s.result!.genTokens).join(",")}`);
    }
    lines.push(``);
    lines.push(`| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×${AGG_STREAMS} tok/s | peak RSS MB | cold start s | ready s |`);
    lines.push(`|---|---|---|---|---|---|---|---|---|---|---|---|---|---|`);
    for (const r of rows) {
      const failMark = r.phaseFailures.length ? " †" : "";
      lines.push(`| ${r.cell.arm}${r.decodeTag ? ` (${r.decodeTag})` : ""}${failMark} | ${r.decodeTps ? median(r.decodeTps).toFixed(1) : "—"} | ${r.ttft ? median(r.ttft.coldMs).toFixed(0) : "—"} | ${r.ttft ? `${r.ttft.warmMs.toFixed(0)} (${r.ttft.warmCachedTokens})` : "—"} | ${r.ttft ? median(r.ttft.prefill1kTps).toFixed(0) : "—"} | ${r.ctx?.promptTokens ?? "—"} | ${r.ctx ? r.ctx.prefillTps.toFixed(0) : "—"} | ${r.ctx ? median(r.ctx.decodeTps).toFixed(1) : "—"} | ${r.ctx ? r.ctx.cachedRepeatTtftMs.toFixed(0) : "—"} | ${r.restart ? `${r.restart.ctxTtftMs.toFixed(0)} (${r.restart.cachedTokens})` : "—"} | ${r.agg ? r.agg.tps.toFixed(1) : "—"} | ${r.peakRssMB.toFixed(0)} | ${r.coldStartMs != null ? (r.coldStartMs / 1000).toFixed(1) : "—"} | ${(r.readyMs / 1000).toFixed(1)} |`);
    }
    lines.push(``);
    // † footnotes: which phase produced each "—" (the measured phases in
    // the same row are real numbers — a dead phase no longer voids a cell).
    for (const r of rows) {
      for (const pf of r.phaseFailures)
        lines.push(`- † ${r.cell.arm}: **${pf.phase}** phase failed (${pf.error.slice(0, 160)}) — "—" cells above; stderr tail in failures section`);
    }
    if (rows.some((r) => r.phaseFailures.length)) lines.push(``);
    const durableRows = rows.filter((r) => r.restart?.durability);
    if (durableRows.length) {
      lines.push(`cache durability before restart:`);
      for (const r of durableRows) {
        const d = r.restart!.durability!;
        lines.push(
          `- ${r.cell.arm}: durable=${d.durable} · flush ${d.flushMs.toFixed(0)} ms · ` +
          `longest prefix ${d.longestDurablePrefixTokens} tok · entries ${d.entries} · ` +
          `pending snapshots/spills ${d.pendingSnapshots}/${d.pendingSpills} · ` +
          `dropped/failed ${d.droppedSpills}/${d.failedSpills}`,
        );
      }
      lines.push(``);
    }
    // Per-leg RSS attribution (B4). Two standing caveats (2026-07-07 A7
    // closure): (1) leg boundary: the explicit durability flush runs in the
    // RESTART leg, so its cost lands in that window; (2) accounting: ps RSS
    // only counts
    // unified-memory KV pages once the CPU touches them, which the
    // write-behind's hash+write does to the (already-allocated) live
    // entry, while python arms' KV never shows in RSS at all. An elevated
    // ctx/restart leg on an --ssd-cache arm is therefore VISIBILITY of
    // existing KV, not duplication (the real duplications — JS-heap copy
    // pile-up in the writer, pinned restore mmap + whole-entry regrow —
    // were fixed 2026-07-07; kv-store.ts).
    lines.push(`per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):`);
    for (const r of rows) {
      const legs = r.rssByLeg.map(([n, v]) => `${n} ${v.toFixed(0)}`).join(" · ");
      lines.push(`- ${r.cell.arm}: idle ${r.idleRssMB.toFixed(0)} · ${legs} · peak ${r.peakRssMB.toFixed(0)}`);
    }
    lines.push(`- note: --ssd-cache arms' ctx/restart legs read high because the write-behind's hash+write makes the live KV entry's unified-memory pages VISIBLE to ps RSS (python arms' KV never shows) — accounting, not duplication`, ``);
    // BIT-PARITY verdicts (B2): per-probe lines. The completion probe is
    // template-free (tokenizer comparison); the chat probe pins
    // enable_thinking on every arm so all stacks render the SAME prompt.
    const arm = (a: Arm) => rows.find((r) => r.cell.arm === a);
    const pairs: Array<[Arm, Arm, string]> = [
      ["mlx-bun", "mlx-lm", "bf16 drop-in (vs mlx-lm)"],
      ["mlx-bun-serial", "mlx-lm", "serial control (vs mlx-lm)"],
      ["mlx-bun", "mlx-bun-serial", "unified engine vs --batch 1 pin"],
      ["mlx-bun", "mlx-bun-isolated", "direct vs isolated host"],
      ["mlx-bun-mixed", "optiq-mixed", "mixed-KV (vs optiq)"],
    ];
    const verdicts: string[] = [];
    for (const [a, b, label] of pairs) {
      const ra = arm(a), rb = arm(b);
      if (!ra || !rb) continue;
      verdicts.push(probeVerdict("completion", label, ra.parity?.completion, rb.parity?.completion));
      verdicts.push(probeVerdict("chat", label, ra.parity?.chat, rb.parity?.chat));
    }
    if (verdicts.length) lines.push(...verdicts, ``);
    // QUANTIZATION-ACTIVE check (B3): a mixed-KV arm whose ctx-leg RSS is
    // not BELOW its same-stack bf16 arm's is suspect — quantized KV holds
    // strictly fewer bytes than bf16 at the same context. This is the
    // tripwire that would have caught the 2026-07-06 silent-bf16 optiq arm.
    const legRss = (r: CellResult | undefined, leg: string): number | null => {
      const hit = r?.rssByLeg.find(([n]) => n === leg);
      return hit ? hit[1] : null;
    };
    const mixedChecks: Array<[Arm, Arm]> = [["mlx-bun-mixed", "mlx-bun"], ["optiq-mixed", "mlx-lm"]];
    for (const [mixed, bf16] of mixedChecks) {
      const rm = arm(mixed), rb = arm(bf16);
      if (!rm) continue;
      // Compare LIFETIME PEAK, not the ctx leg: on small models the ctx-leg
      // KV delta hides inside allocator pooling (cpm5 false-⚠, 2026-07-06b
      // — quantization was provably active: prefill cost + decode@ctx win),
      // while peak spans the restart leg where the full entry materializes.
      const mixedPeak = rm.peakRssMB, bf16Peak = rb?.peakRssMB ?? null;
      if (!rm.ctx || !(mixedPeak > 0)) {
        lines.push(`- kv-quant check — ${mixed}: no ctx leg measured; expected quantized KV bytes ≈ ctx_tokens × layers × 2 × heads × head_dim × (bits/8) vs bf16 ×2B/elt — VERIFY MANUALLY (a silent bf16 arm is invisible without it)`);
        continue;
      }
      if (rb?.ctx && bf16Peak != null && bf16Peak > 0) {
        const ok = mixedPeak < bf16Peak;
        lines.push(`- kv-quant check ${ok ? "✓" : "⚠"} — ${mixed} peak RSS ${mixedPeak.toFixed(0)} MB vs ${bf16} ${bf16Peak.toFixed(0)} MB (expect mixed < bf16${ok ? "" : " — SUSPECT SILENT BF16: quantization hooks may not be live on the measured path"})`);
      } else {
        lines.push(`- kv-quant check — ${mixed}: same-stack bf16 arm not in this run; peak RSS ${mixedPeak.toFixed(0)} MB @ ${rm.ctx.promptTokens} tok recorded for manual expected-vs-actual KV-bytes comparison`);
      }
    }
    lines.push(``);
  }
  if (failures.length) {
    lines.push(`## failures`, ``);
    for (const f of failures) {
      lines.push(`- ${f.cell}: ${f.error}`);
      if (f.stderrTail?.length) {
        lines.push(`  stderr tail (last ${f.stderrTail.length} lines):`, `  \`\`\``);
        for (const l of f.stderrTail) lines.push(`  ${l}`);
        lines.push(`  \`\`\``);
      }
    }
    lines.push(``);
  }
  await saveRaw();
  await Bun.write(out, lines.join("\n"));
  console.log(`\nreport → ${out}`);
}

/** Include new kernels before they are staged; git diff alone cannot identify them. */
export function benchmarkSourceSnapshot(cwd = process.cwd()): {
  sha256: string; files: { path: string; sha256: string }[];
} {
  const listed = Bun.spawnSync(["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard",
    "--", "src", "native", "scripts", "package.json", "bun.lock"], { cwd });
  if (listed.exitCode !== 0) throw new Error("cannot identify benchmark source files");
  const files = [...new Set(listed.stdout.toString().split("\0").filter(Boolean))].sort()
    .filter((path) => existsSync(join(cwd, path)) && statSync(join(cwd, path)).isFile())
    .map((path) => ({ path, sha256: createHash("sha256").update(readFileSync(join(cwd, path))).digest("hex") }));
  return { sha256: createHash("sha256").update(JSON.stringify(files)).digest("hex"), files };
}

// Import-safe: tests import helpers without running a bench.
if (import.meta.main) await main();
