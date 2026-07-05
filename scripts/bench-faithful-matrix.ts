// L1 kernel matrix — the faithful (compiled-activation) kernels are now the DEFAULT,
// so this measures what removing each faithful kernel COSTS, and what the L3 custom
// kernels ADD on top, all vs the mlx-lm oracle.
//
//   bun scripts/bench-faithful-matrix.ts [--tokens 128] [--prompt-tokens N]
//       [--models cpm5,e4b,12B]
//
// For each model it runs, back-to-back on the same machine state (bf16 KV throughout
// — kv-quant/perf-kernel are the separate L2/L3 axis, measured by bench-modes.ts):
//   - mlx-lm                (the parity oracle, via bench.ts --baseline)
//   - L1 default (faithful) (compiled geglu/swiglu + compiled-decode — our default)
//   - − compiled-decode     (cost of dropping the whole-step compile; gemma)
//   - − compiled activations (cost of the uncompiled geglu/swiglu composition)
//   - + custom fused-gelu    (does the L3 Metal geglu beat compiled-geglu?; gemma)
// and prints decode/prefill tok-s + peak mem + the decode ratio vs mlx-lm. Uses
// bench.ts's DIRECT arena (spawns the mlx-lm python reference; starts no servers).
// NOT preflight-gated — treat absolutes as indicative on a loaded machine; the
// RATIOS are fair since every cell for a model runs back-to-back.

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

// gemma-only optimizations (the generated forward / custom geglu / compiled
// decode / perf kernel are gemma-scoped). For non-gemma models these cells
// equal the faithful base, so we skip them to keep the run lean + the table clean.
const GEMMA_KEYS = new Set(["e4b", "12B", "26B"]);

// mlx-bun configs. `env` overrides layer onto the default (which is now the faithful
// L1 kernel set); an explicitly-set flag ("1"/"0") always wins over the code default.
interface Cell { name: string; baseline?: boolean; env?: Record<string, string>; gemmaOnly?: boolean }
const CELLS: Cell[] = [
  { name: "mlx-lm (oracle)", baseline: true },
  { name: "L1 default (faithful)", env: {} },
  { name: "− compiled-decode", env: { MLX_BUN_COMPILED_DECODE: "0" }, gemmaOnly: true },
  { name: "− compiled activations", env: { MLX_BUN_COMPILED_GEGLU: "0", MLX_BUN_COMPILED_SWIGLU: "0" } },
  { name: "+ custom fused-gelu (L3)", env: { MLX_BUN_FUSED_GELU: "1" }, gemmaOnly: true },
];

interface Row { cell: string; decode: number; prefill: number; peak: number }

async function run(model: string, cell: Cell): Promise<Row | null> {
  const args = ["bun", "scripts/bench.ts", "--model", model, "--tokens", TOKENS];
  if (PROMPT_TOKENS) args.push("--prompt-tokens", PROMPT_TOKENS);
  if (cell.baseline) args.push("--baseline");
  else args.push("--kv", "off");
  const proc = Bun.spawn(args, {
    stdout: "pipe", stderr: "pipe",
    // Start from a clean slate each cell so a prior config's env can't leak.
    env: { ...process.env, MLX_BUN_COMPILED_DECODE: "", MLX_BUN_COMPILED_GEGLU: "",
           MLX_BUN_COMPILED_SWIGLU: "", MLX_BUN_FUSED_GELU: "", MLX_BUN_PERF_KERNEL: "",
           MLX_BUN_FUSED_DECODE: "", ...(cell.env ?? {}) },
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
  return { cell: cell.name, decode: +decode, prefill: +prefill, peak: +peak };
}

const lines: string[] = [`# L1 kernel matrix (${TOKENS} decode tok${PROMPT_TOKENS ? `, ${PROMPT_TOKENS}-tok prompt` : ""})\n`];
for (const key of MODEL_KEYS) {
  const query = MODELS[key] ?? key;
  console.log(`\n=== ${key} (${query}) ===`);
  const rows: Row[] = [];
  const cells = GEMMA_KEYS.has(key) ? CELLS : CELLS.filter((c) => !c.gemmaOnly);
  for (const cell of cells) {
    console.log(`  running ${cell.name}…`);
    const r = await run(query, cell);
    if (r) { rows.push(r); console.log(`    decode ${r.decode} · prefill ${r.prefill} · peak ${r.peak} GB`); }
  }
  const oracle = rows.find((r) => r.cell.startsWith("mlx-lm"))?.decode;
  lines.push(`## ${key}\n`);
  lines.push(`| config | decode tok/s | vs mlx-lm | prefill tok/s | peak GB |`);
  lines.push(`|---|---|---|---|---|`);
  for (const r of rows) {
    const ratio = oracle ? `${(r.decode / oracle).toFixed(2)}×` : "—";
    lines.push(`| ${r.cell} | ${r.decode.toFixed(1)} | ${ratio} | ${r.prefill.toFixed(0)} | ${r.peak.toFixed(2)} |`);
  }
  lines.push("");
}
const report = lines.join("\n");
console.log("\n" + report);
const outFile = `bench-faithful-matrix-${TOKENS}tok.md`;
await Bun.write(outFile, report);
console.log(`\nwritten → ${outFile}`);
