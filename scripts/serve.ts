// Run the OpenAI-compatible server (Josh runs this, not agent sessions):
//
//   bun scripts/serve.ts [--model <dir>] [--port 8080]
//                        [--adapter id=dir]...   (mount LoRA adapters)
//                        [--kv-config]           (per-layer mixed KV, kv_config.json)
//                        [--no-kv-quant]         (bf16 KV — the default, explicit)
//                        [--kv-bits N]           (uniform override)
//                        [--memory-budget GB]    (admission control)
//
// bf16 KV is the DEFAULT (naked = L1, decided 2026-07-05: quantized KV
// measured 5-20% slower decode at ≤16k and pays only in memory headroom).
// --kv-config opts into the per-layer mixed scheme (optiq serve's
// headline behavior; full-attention layers only — sliding layers stay
// bf16 either way).
//
// --memory-budget refuses to load models whose weights can't serve
// within the budget, rejects requests whose prompt + max_tokens exceed
// the budget's max safe context (HTTP 400, type "memory_admission"),
// and caps the mlx allocator. The GPU OOM it prevents is UNCATCHABLE
// (it killed optiq serve loading the 26B — Phase 15 finding).

import { SNAPSHOT } from "../tests/paths";
import { createServer, loadContext } from "../src/server";

const arg = (name: string, dflt: string) => {
  const i = process.argv.indexOf(`--${name}`);
  return i > -1 ? process.argv[i + 1]! : dflt;
};

const modelDir = arg("model", SNAPSHOT);
const port = Number(arg("port", "8080"));
const budgetGB = Number(arg("memory-budget", "0"));
const memoryBudgetBytes = budgetGB > 0 ? budgetGB * 1e9 : undefined;

console.log(`loading ${modelDir} ...`);
const t0 = performance.now();
const ctx = await loadContext(modelDir, undefined, { memoryBudgetBytes });

for (let i = 0; i < process.argv.length; i++) {
  if (process.argv[i] !== "--adapter") continue;
  const spec = process.argv[i + 1] ?? "";
  const eq = spec.indexOf("=");
  if (eq < 1) throw new Error(`--adapter expects id=dir, got ${JSON.stringify(spec)}`);
  const info = await ctx.adapters.mount(spec.slice(0, eq), spec.slice(eq + 1));
  console.log(`mounted adapter ${info.id} (${info.mountedLayers} layers, rank ${info.rank}, scale ${info.scale})`);
}

const kvQuant = process.argv.includes("--no-kv-quant")
  ? ("off" as const)
  : process.argv.includes("--kv-config")
    ? ("config" as const)
    : process.argv.includes("--kv-bits")
      ? Number(arg("kv-bits", "8"))
      : undefined; // server default = bf16 (L1)

const server = createServer(ctx, port, { kvQuant, memoryBudgetBytes });
const kvDesc = kvQuant === "config"
  ? (ctx.kvConfig?.length ? "mixed (kv_config.json)" : "bf16 (no kv_config in repo)")
  : typeof kvQuant === "number" ? `uniform kv${kvQuant}`
  : "bf16";
console.log(`KV cache: ${kvDesc}`);
if (memoryBudgetBytes) console.log(`memory budget: ${budgetGB} GB (admission control on)`);
console.log(`mlx-bun serving ${ctx.modelId} at http://localhost:${server.port}/v1 (ready in ${(performance.now() - t0).toFixed(0)} ms)`);
