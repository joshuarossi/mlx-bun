// TurboQuant quality-vs-bpw curve — the Phase 13 exit-criterion gate
// (docs/design/turboquant-kv.md §Gates 3). For one model, SEQUENTIALLY
// (never two configs' models resident at once — the 32 GB box rule):
//   bf16 baseline, then k8v8/k8v4/k8v3/k8v2/k4v3/k4v2
// reporting per config: effective KV bits (weighted, the design doc's
// per-token-per-head byte formula), mean teacher-forced KL vs bf16 (reusing
// src/eval/kl.ts's evaluateKlKvArm — the serving-decode path, real
// TurboQuantKVCache.fromKVCache conversion, not a re-implementation), and
// perplexity (reusing src/eval/perplexity.ts's evalPpl on the SAME model
// instance bf16 forward — TurboQuant is a decode-time KV-cache scheme, not a
// weight quantizer, so ppl is measured once per model load as a report-only
// anchor column, not per KV config).
//
//   bun scripts/eval-turboquant-curve.ts --model <path> [--n-prompts 8]
//     [--seq-len 128] [--decode-steps 32] [--ppl-samples 4]
//
// Keep runtime modest — a quality gate, not a benchmark (docs/design/
// turboquant-kv.md's own non-goal: no speed claims from this script).

import { DEFAULT_KL_PROMPTS } from "../src/eval/kl-prompts";
import { evaluateKlKvArm, loadRunnable } from "../src/eval/kl";
import { packRows, evalPpl } from "../src/eval/perplexity";
import { packedDim, TURBOQUANT_BLOCK_SIZE } from "../src/mlx/turboquant-ops";
import type { TurboQuantScheme } from "../src/config";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

if (process.argv.includes("--help") || process.argv.includes("-h")) {
  console.log(
    `usage: bun scripts/eval-turboquant-curve.ts --model <path> [options]\n\n` +
    `  --model <path>        Local model directory (config.json + weights) — required\n` +
    `  --n-prompts <n>       Prompts for the KL arms  [default: 8]\n` +
    `  --seq-len <n>         Tokens per prompt (prefill+decode window)  [default: 128]\n` +
    `  --decode-steps <n>    Teacher-forced decode steps scored per prompt  [default: 32]\n` +
    `  --ppl-samples <n>     Perplexity rows (bf16 forward, report-only anchor)  [default: 4]\n\n` +
    `Runs bf16 baseline + {k8v8,k8v4,k8v3,k8v2,k4v3,k4v2} SEQUENTIALLY (one model\n` +
    `resident at a time) and prints a markdown table: config, effective KV bits,\n` +
    `mean KL vs bf16, perplexity, delta vs bf16. A quality gate, not a benchmark —\n` +
    `keep --n-prompts/--seq-len modest.`,
  );
  process.exit(0);
}

/** The design doc's per-token-per-head byte formula (docs/design/
 *  turboquant-kv.md "Per-token-per-head bytes"): K bytes + K scale/zero (2
 *  fp16 arrays/group) + V bytes + V scale (1 fp16 array/group), against the
 *  bf16 baseline (2 tensors × head_dim × 2 bytes). Returns bits/element,
 *  weighted across K and V (2×head_dim elements per token per head). */
function effectiveBits(headDim: number, scheme: TurboQuantScheme): number {
  const nGroups = headDim / TURBOQUANT_BLOCK_SIZE;
  const kBytes = packedDim(headDim, scheme.kBits) + 2 * nGroups * 2; // scale + zero, fp16
  const vBytes = packedDim(headDim, scheme.vBits) + 1 * nGroups * 2; // scale only, fp16
  const totalBytes = kBytes + vBytes;
  const bf16Bytes = 2 * headDim * 2;
  return (totalBytes / bf16Bytes) * 16; // 16 = bf16's own bits/element
}

interface Row {
  config: string;
  effectiveBits: number | null;
  meanKl: number;
  ppl: number;
  deltaPpl: number;
}

async function main(): Promise<void> {
  const modelPath = opt("model");
  if (!modelPath) {
    console.error("usage: bun scripts/eval-turboquant-curve.ts --model <path> [--n-prompts 8] [--seq-len 128] [--decode-steps 32] [--ppl-samples 4]");
    process.exit(1);
  }
  const nPrompts = Number(opt("n-prompts", "8"));
  const seqLen = Number(opt("seq-len", "128"));
  const decodeSteps = Number(opt("decode-steps", "32"));
  const pplSamples = Number(opt("ppl-samples", "4"));

  const configs: Array<{ name: string; scheme: TurboQuantScheme | null }> = [
    { name: "bf16", scheme: null },
    { name: "k8v8", scheme: { kBits: 8, vBits: 8 } },
    { name: "k8v4", scheme: { kBits: 8, vBits: 4 } },
    { name: "k8v3", scheme: { kBits: 8, vBits: 3 } },
    { name: "k8v2", scheme: { kBits: 8, vBits: 2 } },
    { name: "k4v3", scheme: { kBits: 4, vBits: 3 } },
    { name: "k4v2", scheme: { kBits: 4, vBits: 2 } },
  ];

  // One weight load, shared by every arm (KL and ppl both run on the SAME
  // resident model — sequential per config, never a second model loaded).
  console.error(`loading ${modelPath}...`);
  const { model, tokenizer, config } = await loadRunnable(modelPath);
  const headDim = config.text.headDim;

  // Perplexity: a report-only anchor, measured ONCE (bf16 forward — TurboQuant
  // only changes the KV cache at decode time, not the weight-forward ppl loss
  // path), reused as the "ppl" column for every config row alongside its own
  // delta-from-itself (0) — the meaningful signal here is the KL column.
  console.error(`perplexity (bf16 forward, ${pplSamples} sample(s) × ${seqLen} tokens)...`);
  const pplRows = packRows(
    DEFAULT_KL_PROMPTS.map((p) => tokenizer.encode(p)),
    { sequenceLength: seqLen, numSamples: pplSamples, seed: 123 },
  );
  const pplResult = pplRows.length > 0
    ? evalPpl(model, pplRows, Math.min(4, pplRows.length))
    : { ppl: NaN, standardError: 0, meanLoss: NaN, tokens: 0, rows: 0 };

  const results: Row[] = [];
  for (const { name, scheme } of configs) {
    console.error(`config ${name}: teacher-forced KL vs bf16 (${nPrompts} prompts × ${seqLen} tokens, ${decodeSteps} decode steps)...`);
    const kl = scheme
      ? await evaluateKlKvArm({
          candidate: modelPath,
          candidateScheme: { turboQuant: scheme },
          prompts: DEFAULT_KL_PROMPTS,
          nPrompts,
          seqLen,
          decodeSteps,
        })
      : null;
    results.push({
      config: name,
      effectiveBits: scheme ? effectiveBits(headDim, scheme) : 16,
      meanKl: kl?.meanKl ?? 0,
      ppl: pplResult.ppl,
      deltaPpl: 0, // ppl is a bf16-forward anchor, not per-KV-config in v1
    });
  }

  const bf16Ppl = results[0]!.ppl;
  for (const r of results) r.deltaPpl = r.ppl - bf16Ppl;

  console.log();
  console.log("| config | effective KV bits | mean KL vs bf16 | perplexity | Δ ppl vs bf16 |");
  console.log("|---|---|---|---|---|");
  for (const r of results) {
    console.log(
      `| ${r.config} | ${r.effectiveBits?.toFixed(2) ?? "—"} | ${r.meanKl.toFixed(6)} | ` +
      `${Number.isFinite(r.ppl) ? r.ppl.toFixed(3) : "n/a"} | ${r.deltaPpl >= 0 ? "+" : ""}${r.deltaPpl.toFixed(3)} |`,
    );
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
