#!/usr/bin/env bun
// A B=1 consumer of the production grouped method. No server, private model
// loop, prefix reuse, EOS shortening, or extra barriers in throughput runs.
import { strict as assert } from "node:assert";
import { appendFileSync, mkdirSync, readFileSync, readdirSync, realpathSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { cpus, freemem, loadavg, totalmem } from "node:os";
import { parseArgs } from "node:util";
import { fileSha } from "./bench/plan";
import { mtpMetrics, pairedMtpComparison, parseMtpPlan, type MtpPlan, type MtpSample } from "./bench/mtp";

const HELP = `Usage: bun --no-env-file scripts/bench-mtp.ts --plan plan.json --out /external/run

Plan (local artifacts only; first variant is the baseline):
{"target":"/weights/Qwen3.8-27B-Trellis-3.2bpw","draft":"/weights/Qwen3.8-27B-Trellis-3.2bpw/mtp",
 "artifactRevision":"local upload source; file hashes recorded",
 "prompts":["Write a Python LRU cache.","Explain speculative decoding."],
 "variants":[{"id":"mtp2","depth":2},{"id":"mtp4","depth":4},{"id":"mtp8","depth":8}],
 "maxTokens":192,"warmupTokens":32,"repetitions":4}

Each repetition runs every variant in a fresh process; odd repetitions reverse
the order (two arms give ABBA). Each process warms every prompt at its depth.
Throughput runs precede separate diagnostic runs (--throughput-only skips them). Diagnostics force state
evaluation and disable draft/verify overlap; never use them to rank candidates.
Accepted = matched draft proposals only (0..depth). Emitted = actual delivered
tokens, including correction/bonus, excluding the token produced by prefill.
Rank by sum(emitted)/sum(total step wall time), with accepted/step time alongside.
Step time includes draft, verify, sampling, output and commit. Request, TTFT,
decode, peak MLX memory, per-position acceptance and token IDs are retained too.
Phases are synchronized wall times, not GPU command-buffer timings. This is a
plain-KV, greedy, batch-one kernel/MTP screen, not HTTP or oracle qualification.
Check that training is inactive and the machine is quiet before invoking.
No downloads or persistent servers are started. Outputs must be outside Git.
`;

function command(argv: string[]): string {
  const r = Bun.spawnSync(argv, { stdout: "pipe", stderr: "pipe" });
  assert(r.exitCode === 0, `${argv[0]} failed: ${r.stderr}`); return r.stdout.toString().trim();
}
function artifactFiles(dir: string): Record<string, string> {
  return Object.fromEntries(readdirSync(dir).filter(n => /\.(json|jinja|safetensors|txt)$/.test(n))
    .sort().map(n => [n, fileSha(join(dir, n))]));
}
function checkTraining() {
  const lines = command(["ps", "-axo", "pid=,command="]).split("\n");
  const active = lines.filter(line => /(?:bun|python|mlx-bun)/i.test(line) &&
    /(?:\s(?:train|finetune|lora)(?:\s|$)|mlx_lm\.lora|training\/.*\.py)/i.test(line));
  assert(!active.length, `training may be active; refusing GPU work:\n${active.join("\n")}`);
}

async function worker(plan: MtpPlan, variantIndex: number, mode: MtpSample["mode"], repetition: number, output: string) {
  checkTraining();
  const v = plan.variants[variantIndex]!;
  // Imports happen only after the parent has set the arm's environment.
  const { loadModelConfig, loadTokenizer, ChatTemplate, Weights, createModel } = await import("@mlx-bun/inference");
  const { QwenMtpProvider, Dflash2Provider, detectDraftKind } = await import("@mlx-bun/inference/generation/speculative");
  const { bindMlxGateway } = await import("@mlx-bun/inference/execution");
  const { resetPeakMemory, peakMemory, clearCache, synchronize, deviceArchitecture, MLX_VERSION } = await import("@mlx-bun/mlx/ffi");
  const { gpuStream } = await import("@mlx-bun/mlx/array");
  const weights = await Weights.open(plan.target);
  const model = createModel(weights, await loadModelConfig(plan.target));
  const draftDir = v.draft ?? plan.draft;
  const provider = await detectDraftKind(draftDir) === "dflash2"
    ? await Dflash2Provider.load(draftDir, { bits: 4 }) : await QwenMtpProvider.load(draftDir);
  const tokenizer = await loadTokenizer(plan.target), template = await ChatTemplate.load(plan.target);
  const prompts = plan.prompts.map(text => {
    const ids = tokenizer.encode(template.render([{ role: "user", content: text }], { enableThinking: plan.thinking ?? false }));
    return ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId ? ids.slice(1) : ids;
  });
  const binding = bindMlxGateway(model, { provider, numDraftTokens: v.depth, adaptiveDepth: v.adaptiveDepth ?? false });
  const run = async (prompt: number, maxTokens: number): Promise<MtpSample> => {
    const options = { ...(plan.sampling ?? { temperature: 0 }), ...(plan.kv ?? {}), maxTokens };
    const execution = binding.plan({ hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: !!plan.sampling,
      kvQuant: !!plan.kv, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: true },
      options, { continuous: true, quantizedBatch: false, checkpoints: false });
    assert(execution.method === "speculative", "requested MTP did not bind");
    const request = binding.methodRequest!(execution, options)!;
    const tokens: number[] = [], steps: MtpSample["steps"] = [];
    const method = { ...request, open: (host: Parameters<typeof request.open>[0]) => {
      const m = request.open(host), advance = m.advance.bind(m);
      m.advance = async work => {
        const before = tokens.length, start = performance.now();
        await advance(work);
        steps.push({ ms: performance.now() - start, emitted: tokens.length - before });
      };
      return m;
    } };
    synchronize(gpuStream); resetPeakMemory();
    const start = performance.now(), group = binding.createBatchGroup({ maxBatch: 1 });
    try {
      const stats = await group.submit({ method, promptIds: prompts[prompt]!, maxTokens, eosTokenIds: [],
        onToken(token) { tokens.push(token); } });
      await group.close(); // joins the final advance before reading its timings
      synchronize(gpuStream);
      assert(tokens.length === maxTokens, `short output: ${tokens.length}/${maxTokens}`);
      assert(stats.spec, "no speculation counters");
      return { variant: v.id, mode, repetition, prompt, tokens, steps, spec: stats.spec,
        promptTokens: prompts[prompt]!.length, requestMs: performance.now() - start,
        prefillMs: stats.prefillMs, decodeMs: stats.decodeMs, peakBytes: peakMemory() };
    } finally { await group.close(); clearCache(); }
  };
  try {
    for (let p = 0; p < prompts.length; p++) await run(p, Math.max(v.depth + 1, plan.warmupTokens));
    appendFileSync(output, JSON.stringify({ kind: "runtime", variant: v.id, mode, repetition,
      mlx: MLX_VERSION, architecture: deviceArchitecture(), bun: Bun.version, machine: cpus()[0]?.model,
      totalMemory: totalmem(), freeMemory: freemem(), load: loadavg(), promptIds: prompts }) + "\n");
    for (let p = 0; p < prompts.length; p++) {
      const sample = await run(p, plan.maxTokens);
      mtpMetrics([sample]);
      appendFileSync(output, JSON.stringify({ kind: "sample", ...sample }) + "\n");
      console.error(`${mode} ${v.id} rep=${repetition} prompt=${p}: ${mtpMetrics([sample]).emittedPerSecond.toFixed(2)} emitted tok/s`);
    }
  } finally {
    synchronize(gpuStream); provider.dispose(); weights.dispose();
    for (const file of weights.shards.files.values()) file.mmap.unmap();
    clearCache();
  }
}

async function main() {
  const { values } = parseArgs({ options: { plan: { type: "string" }, out: { type: "string" }, help: { type: "boolean" },
    worker: { type: "string" }, mode: { type: "string" }, repetition: { type: "string" },
    "throughput-only": { type: "boolean" } }, strict: true });
  if (values.help) { console.log(HELP); return; }
  assert(values.plan && values.out, HELP);
  const plan = parseMtpPlan(JSON.parse(readFileSync(values.plan, "utf8")));
  if (values.worker !== undefined) {
    assert(values.mode === "throughput" || values.mode === "diagnostic", "invalid mode");
    await worker(plan, Number(values.worker), values.mode, Number(values.repetition), values.out); return;
  }
  const root = realpathSync(join(import.meta.dir, "..")), out = resolve(values.out);
  assert(out !== root && !out.startsWith(root + "/"), "reports must live outside the checkout");
  mkdirSync(out, { recursive: true });
  assert(readdirSync(out).length === 0, "output directory must be empty");
  assert(!realpathSync(out).startsWith(root + "/"), "output symlink resolves into checkout");
  checkTraining();
  const native = (await import("@mlx-bun/mlx/native")).resolveLibmlxc();
  const pins = { target: artifactFiles(plan.target), draft: artifactFiles(plan.draft),
    native: Object.fromEntries(["libmlxc.dylib", "libmlx.dylib", "mlx.metallib"].map(n => [n, fileSha(join(dirname(native), n))])) };
  const metadata = { plan, pins, created: new Date().toISOString(), command: process.argv,
    commit: command(["git", "rev-parse", "HEAD"]), diff: command(["git", "diff", "HEAD"]),
    harness: { runner: fileSha(import.meta.filename), metrics: fileSha(join(import.meta.dir, "bench/mtp.ts")) },
    os: command(["sw_vers"]), machine: cpus()[0]?.model, totalMemory: totalmem(), bun: Bun.version,
    env: Object.fromEntries(Object.entries(process.env).filter(([k]) => k.startsWith("MLX_BUN_") && !/(API_KEY|SECRET|PASSWORD|ACCESS_TOKEN)/.test(k))) };
  writeFileSync(join(out, "manifest.json"), JSON.stringify(metadata, null, 2));
  const planPath = join(out, "plan.json"), raw = join(out, "samples.jsonl");
  writeFileSync(planPath, JSON.stringify(plan, null, 2));
  try {
    const modes = values["throughput-only"] ? ["throughput"] as const : ["throughput", "diagnostic"] as const;
    for (const mode of modes) {
      for (let rep = 0; rep < plan.repetitions; rep++) {
        const order = plan.variants.map((_, i) => i); if (rep % 2) order.reverse();
        for (const index of order) {
          checkTraining();
          const child = Bun.spawn([process.execPath, "--no-env-file", import.meta.filename, "--plan", planPath,
            "--out", raw, "--worker", String(index), "--mode", mode, "--repetition", String(rep)], {
            env: { ...process.env, ...plan.variants[index]!.env, MLX_BUN_SPEC_PHASE_TIMING: mode === "diagnostic" ? "1" : "0",
              MLX_BUN_SPEC_LAYER_PROFILE: "0", MLX_BUN_SPEC_OP_INVENTORY: "0" }, stdout: "inherit", stderr: "inherit" });
          const stop = () => child.kill("SIGTERM"); process.once("SIGINT", stop); process.once("SIGTERM", stop);
          const code = await child.exited; process.off("SIGINT", stop); process.off("SIGTERM", stop);
          assert(code === 0, `${mode}/${plan.variants[index]!.id}/${rep} exited ${code}`);
        }
      }
    }
    assert.deepEqual(artifactFiles(plan.target), pins.target, "target changed during campaign");
    assert.deepEqual(artifactFiles(plan.draft), pins.draft, "draft changed during campaign");
    const samples = readFileSync(raw, "utf8").trim().split("\n").map(s => JSON.parse(s)).filter(s => s.kind === "sample") as MtpSample[];
    const select = (id: string, mode: string) => samples.filter(s => s.variant === id && s.mode === mode);
    const summary = plan.variants.map(v => ({ variant: v,
      throughput: mtpMetrics(select(v.id, "throughput")),
      diagnostic: select(v.id, "diagnostic").length ? mtpMetrics(select(v.id, "diagnostic")) : null,
      comparison: pairedMtpComparison(select(plan.variants[0]!.id, "throughput"), select(v.id, "throughput")) }));
    writeFileSync(join(out, "summary.json"), JSON.stringify(summary, null, 2));
    console.log(JSON.stringify(summary, null, 2));
  } catch (error) { writeFileSync(join(out, "failure.json"), JSON.stringify({ error: String(error) })); throw error; }
}
if (import.meta.main) await main();
