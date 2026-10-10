// One standard CLI request, MTP off, through the Trellis MLP kernels the
// loaded graph selects for this GPU. Run fresh processes in alternating order
// on an idle GPU. Write generated reports outside the checkout; --out is required.
import { parseArgs } from "node:util";
import { writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
const { values } = parseArgs({ options: { model: { type: "string" }, out: { type: "string" }, help: { type: "boolean" } }, strict: true });
if (values.help) {
  console.log("usage: bun apps/mlx-bun/scripts/bench-trellis-gateup.ts --model <local snapshot> --out <external.json>\n" +
    "One fixed prompt, 256 greedy tokens, plain KV, MTP off, with the Trellis kernels the loaded graph selects for this GPU.");
  process.exit(0);
}
if (!values.model || !values.out) throw new Error("usage: bun bench-trellis-gateup.ts --model <local snapshot> --out <external.json>");
const [{ runInference }, { parseCommand }, { loadContext }, { createAppEngine },
  { activeMemory, cacheMemory, peakMemory, deviceArchitecture }] = await Promise.all([
  import("../src/cli/inference"), import("../src/cli/args"), import("../src/engine/model-host"),
  import("../src/engine"), import("@mlx-bun/mlx/ffi"),
]);
const prompt = "You are helping a new engineer understand a local language-model inference engine on Apple Silicon. Explain the lifecycle of one request from prompt text to the final response. Cover tokenization, prompt prefill, the attention KV cache, autoregressive decoding, greedy token selection, and transfer of the selected token back to the CPU. Explain why prompt processing can handle many tokens together while response generation normally advances one token at a time. Describe how unified memory helps, why GPU work can be asynchronous, and why reading a token on the CPU may still require waiting. Finish with two practical examples of work that can happen on the CPU while the GPU is computing. Use plain language, short paragraphs, and concrete examples. Do not include code. Give a detailed explanation of approximately 400 words.";
const argv = [values.model, "--prompt", prompt, "--max-tokens", "256", "--temperature", "0", "--kv-quant", "off"];
const start = performance.now();
const tokens: { id: number; ms: number }[] = [];
let response = "", stats: unknown, generationStart = 0, loadMs = 0, engineMs = 0;
await runInference("generate", parseCommand("generate", argv), {
  async load(selected, maxTokens) {
    const t = performance.now();
    const context = await loadContext(selected.path, selected.repoId, {
      requireChatTemplate: false, runtime: { nativeDraft: false, maxGenerationTokens: maxTokens },
    });
    loadMs = performance.now() - t;
    return context;
  },
  async engine(context, scheme) {
    const t = performance.now();
    const engine = await createAppEngine(context, { capacity: 1, gateway: { kvScheme: scheme } });
    engineMs = performance.now() - t;
    return { ...engine, completion: {
      place: engine.completion.place.bind(engine.completion),
      async run(ids, options, onToken, vision, shape, placement, signal, trace) {
        generationStart = performance.now();
        const result = await engine.completion.run(ids, options, (token, ...rest) => {
          tokens.push({ id: token, ms: performance.now() - generationStart });
          return onToken(token, ...rest);
        }, vision, shape, placement, signal, trace);
        stats = result;
        return result;
      },
    } };
  },
  write(text) { response = text; },
});
const report = { model: values.model, prompt, argv, bun: Bun.version,
  source: execFileSync("git", ["rev-parse", "HEAD"], { encoding: "utf8" }).trim(),
  architecture: deviceArchitecture(),
  configuration: { capacity: 1, mtp: false, kv: "off", temperature: 0, maxTokens: 256, promptCache: "none" },
  loadMs, engineMs, totalMs: performance.now() - start,
  firstTokenMs: tokens[0]?.ms, decodeMs: tokens.at(-1)!.ms - tokens[0]!.ms,
  stats, tokens, response, memory: { activeBytes: activeMemory(), cacheBytes: cacheMemory(), peakBytes: peakMemory() } };
writeFileSync(values.out, JSON.stringify(report, null, 2) + "\n");
console.log(JSON.stringify({ firstTokenMs: report.firstTokenMs, decodeMs: report.decodeMs, totalMs: report.totalMs, tokens: tokens.length }));
