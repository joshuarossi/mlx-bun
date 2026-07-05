// L1 kernel matrix — the faithful (compiled-activation) kernels are the DEFAULT,
// so this measures what removing each faithful kernel COSTS, all vs the mlx-lm
// oracle.
//
//   bun scripts/bench-faithful-matrix.ts [--tokens 128] [--prompt-tokens N]
//       [--models cpm5,e4b,12B]
//
// For each model it runs, back-to-back on the same machine state. Two kv groups:
//   BF16 (vs the bf16 mlx-lm oracle):
//   - mlx-lm                (the parity oracle, via bench.ts --baseline)
//   - L1 default (faithful) (compiled geglu/swiglu + compiled-decode — our default)
//   - − compiled-decode     (cost of dropping the whole-step compile; gemma)
//   - − compiled activations (cost of the uncompiled geglu/swiglu composition)
//   UNIFORM KV8 (vs STOCK mlx-lm --kv-bits 8 — a bit-exact L1 config):
//   - mlx-lm (uniform kv8)  (bench.ts --baseline-kv 8, stock mlx-lm quantized KV)
//   - L1 uniform kv8        (our --kv-quant 8 with fused-sdpa OFF → quantizedSdpaUnfused,
//     which is op-for-op identical to mlx-lm's quantized_scaled_dot_product_attention
//     in base.py — so this is a same-algorithm apples-to-apples perf comparison).
// (the fused/N-tiled quantized path is the optiq-aligned L2 — bench-modes.ts.)
// Prints decode/prefill tok-s + peak mem + the decode ratio vs the same-kv oracle.
// Uses bench.ts's DIRECT arena (spawns the mlx-lm python reference; starts no
// servers). NOT preflight-gated — treat absolutes as indicative on a loaded machine;
// the RATIOS are fair since every cell for a model runs back-to-back.

export {}; // module marker (enables top-level await)

const arg = (name: string, dflt: string): string => {
  const i = process.argv.indexOf(name);
  return i > -1 && process.argv[i + 1] ? process.argv[i + 1]! : dflt;
};
const TOKENS = arg("--tokens", "128");
const PROMPT_TOKENS = arg("--prompt-tokens", "");
const MODEL_KEYS = arg("--models", "cpm5,e4b,12B").split(",").map((s) => s.trim());

// Registry queries that resolve each model (substring match against repoId).
const MODELS: Record<string, string> = {
  cpm5: "MiniCPM5-1B-OptiQ-4bit",
  e4b: "gemma-4-e4b-it-OptiQ-4bit",
  "12B": "gemma-4-12B-it-OptiQ-4bit",
  "26B": "gemma-4-26B-A4B-it-OptiQ-4bit",
  qwen4b: "Qwen3.5-4B-OptiQ-4bit",
  qwen9b: "Qwen3.5-9B-OptiQ-4bit",
};

// gemma-only optimizations (the generated forward / compiled decode are
// gemma-scoped). For non-gemma models these cells
// equal the faithful base, so we skip them to keep the run lean + the table clean.
const GEMMA_KEYS = new Set(["e4b", "12B", "26B"]);

// mlx-bun configs. `env` overrides layer onto the default (which is now the faithful
// L1 kernel set); an explicitly-set flag ("1"/"0") always wins over the code default.
// `kv` is the KV scheme for the row's run (default "off" = bf16). Rows are grouped by
// kv: a bf16 group (vs the bf16 mlx-lm oracle) and a uniform-kv8 group (our
// --kv-quant 8 vs STOCK mlx-lm --kv-bits 8 — the L1-eligible uniform scheme; note our
// quantized decode is optiq-aligned today, so read the kv8 row as a perf comparison
// pending a stock-mlx-lm uniform-kv parity check, not a proven L1 result).
interface Cell { name: string; baseline?: boolean; env?: Record<string, string>; gemmaOnly?: boolean; kv?: string }
const CELLS: Cell[] = [
  { name: "mlx-lm (oracle)", baseline: true },
  { name: "L1 default (faithful)", env: {} },
  { name: "− compiled-decode", env: { MLX_BUN_COMPILED_DECODE: "0" }, gemmaOnly: true },
  { name: "− compiled activations", env: { MLX_BUN_COMPILED_GEGLU: "0", MLX_BUN_COMPILED_SWIGLU: "0" } },
  { name: "mlx-lm (oracle, uniform kv8)", baseline: true, kv: "8" },
  // L1 quantized config: fused-sdpa OFF → our quantizedSdpaUnfused, which is
  // op-for-op identical to mlx-lm's quantized_scaled_dot_product_attention
  // (base.py). Apples-to-apples with the --baseline-kv 8 oracle (same algorithm).
  { name: "L1 uniform kv8", env: { MLX_BUN_NO_FUSED_SDPA: "1" }, kv: "8" },
];

interface Row { cell: string; decode: number; prefill: number; peak: number; kv: string; baseline: boolean }

async function run(model: string, cell: Cell): Promise<Row | null> {
  const kv = cell.kv ?? "off";
  const args = ["bun", "scripts/bench.ts", "--model", model, "--tokens", TOKENS];
  if (PROMPT_TOKENS) args.push("--prompt-tokens", PROMPT_TOKENS);
  if (cell.baseline) {
    args.push("--baseline");
    if (kv !== "off") args.push("--baseline-kv", kv); // stock mlx-lm uniform kv-bits
  } else {
    args.push("--kv", kv);
  }
  const proc = Bun.spawn(args, {
    stdout: "pipe", stderr: "pipe",
    // Start from a clean slate each cell so a prior config's env can't leak.
    env: { ...process.env, MLX_BUN_COMPILED_DECODE: "", MLX_BUN_COMPILED_GEGLU: "",
           MLX_BUN_COMPILED_SWIGLU: "", MLX_BUN_NO_FUSED_SDPA: "", ...(cell.env ?? {}) },
  });
  const [out, err, code] = await Promise.all([
    new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited,
  ]);
  if (code !== 0) {
    console.log(`  [FAIL] ${model}/${cell.name}: ${err.slice(-300).trim()}`);
    return null;
  }
  const decode = out.match(/decode: \d+ tok @ ([\d.]+) tok\/s/)?.[1];
  const prefill = out.match(/prompt: \d+ tok @ ([\d.]+) tok\/s/)?.[1];
  const peak = out.match(/peak mem: ([\d.]+) GB/)?.[1];
  if (!decode || !prefill || !peak) {
    console.log(`  [PARSE FAIL] ${model}/${cell.name}: ${out.slice(-200).trim()}`);
    return null;
  }
  return { cell: cell.name, decode: +decode, prefill: +prefill, peak: +peak, kv, baseline: !!cell.baseline };
}

// Rows land in the eval DB too (stack=mlx-bun for our cells, mlx-lm for the
// oracle cells) so bench-h2h.ts `table` renders this matrix as Comparison 0
// in the unified report — before 2026-07-05 these results lived only in
// stdout + a loose md, invisible in the report benchmark.sh promises.
const { EvalDB, gitCommit } = await import("../src/evaldb");
const { checkMachine, machineStateJson } = await import("../src/preflight");
const { Registry } = await import("../src/registry");
const evalDb = new EvalDB();
const commitSha = gitCommit();
const machineState = machineStateJson(checkMachine());
const registry = new Registry();
if (registry.list().length === 0) await registry.scan();

const lines: string[] = [`# L1 kernel matrix (${TOKENS} decode tok${PROMPT_TOKENS ? `, ${PROMPT_TOKENS}-tok prompt` : ""})\n`];
for (const key of MODEL_KEYS) {
  const query = MODELS[key] ?? key;
  console.log(`\n=== ${key} (${query}) ===`);
  const rows: Row[] = [];
  const cells = GEMMA_KEYS.has(key) ? CELLS : CELLS.filter((c) => !c.gemmaOnly);
  for (const cell of cells) {
    console.log(`  running ${cell.name}…`);
    const r = await run(query, cell);
    if (r) {
      rows.push(r);
      console.log(`    decode ${r.decode} · prefill ${r.prefill} · peak ${r.peak} GB`);
      evalDb.record({
        modelPath: registry.resolve(query).path, commitSha, stack: cell.baseline ? "mlx-lm" : "mlx-bun",
        promptTokens: Number(PROMPT_TOKENS) || 0, generatedTokens: Number(TOKENS),
        prefillTps: r.prefill, decodeTps: r.decode, peakBytes: Math.round(r.peak * 1e9),
        machineState,
        // cell= LAST (names contain spaces) — bench-h2h parses
        // /model=(\S+) kv=(\S+) baseline=(\d) cell=(.+)$/
        notes: `bench-faithful-matrix model=${key} kv=${r.kv} baseline=${cell.baseline ? 1 : 0} cell=${cell.name}`,
      });
    }
  }
  lines.push(`## ${key}\n`);
  lines.push(`| config | kv | decode tok/s | vs mlx-lm | prefill tok/s | peak GB |`);
  lines.push(`|---|---|---|---|---|---|`);
  for (const r of rows) {
    // ratio vs the mlx-lm oracle of the SAME kv scheme (bf16 rows vs the bf16
    // oracle, uniform-kv8 rows vs the kv8 oracle).
    const oracle = rows.find((o) => o.baseline && o.kv === r.kv)?.decode;
    const ratio = oracle ? `${(r.decode / oracle).toFixed(2)}×` : "—";
    lines.push(`| ${r.cell} | ${r.kv === "off" ? "bf16" : `q${r.kv}`} | ${r.decode.toFixed(1)} | ${ratio} | ${r.prefill.toFixed(0)} | ${r.peak.toFixed(2)} |`);
  }
  lines.push("");
}
const report = lines.join("\n");
console.log("\n" + report);
const outFile = `bench-faithful-matrix-${TOKENS}tok.md`;
await Bun.write(outFile, report);
console.log(`\nwritten → ${outFile}`);
