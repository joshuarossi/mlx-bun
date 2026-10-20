// Realistic, model-free fixtures for every backend surface the browser app reads. The fake backend
// (`fake-backend.ts`) serves them, the preview script shows the app over them, and the browser tests
// stub `fetch` from them, so one description of the wire keeps the three in agreement.
//
// Plain data on purpose: the shapes mirror the routes' JSON (the models module's `HubLocalRow`,
// `LibraryRow`, the metrics module's `MetricsSnapshot`, the chat module's `ServerMessage` frames)
// without importing module code into the app's test fixtures.

const GB = 2 ** 30;
const MB = 2 ** 20;

export const SERVED_MODEL = "mlx-bun/Qwen3.8-27B-Trellis-3.2bpw";
export const STARTER_MODEL = "mlx-community/Qwen2.5-0.5B-Instruct-4bit";
export const DOWNLOADING_MODEL = "mlx-community/Qwen3-30B-A3B-4bit";

export const models = {
  object: "list",
  data: [
    { id: SERVED_MODEL, object: "model", owned_by: "local", context_window: 32_768, current: true },
    { id: STARTER_MODEL, object: "model", owned_by: "local", context_window: 32_768, current: false },
  ],
};

export const downloads = {
  downloads: [
    { repoId: DOWNLOADING_MODEL, state: "active", currentFile: "model-00002-of-00004.safetensors", receivedBytes: 7.3 * GB, totalBytes: 17.2 * GB, bytesPerSec: 48 * MB, filesDone: 1, filesTotal: 4, startedAt: Date.now() - 180_000 },
    { repoId: STARTER_MODEL, state: "done", currentFile: null, receivedBytes: 0.33 * GB, totalBytes: 0.33 * GB, filesDone: 3, filesTotal: 3, startedAt: Date.now() - 3_600_000 },
  ],
};

export const stats = {
  server: { started_at: Date.now() - 5_412_000 },
  admission: { weights_bytes: 12.25 * GB, usable_bytes: 51.2 * GB, memory_budget_bytes: 48 * GB, max_safe_context: 24_576 },
  prompt_cache: { hits: 184, misses: 42, entries: 19, bytes: 612 * MB, max_bytes: 2 * GB },
  response_store: { entries: 37, bytes: 1.4 * MB, max_bytes: 64 * MB, ttl_ms: 600_000 },
  kv_quant: { mode: "q8 (global) · fp16 (sliding)", layers: { global: 24, sliding: 40 }, attention: { global: 24, sliding_window: 40 } },
};

export const fit = {
  report: { fits: true, weights_bytes: 12.25 * GB, kv_bytes: 6.1 * GB, transient_bytes: 2.2 * GB, total_bytes: 20.55 * GB, usable_bytes: 51.2 * GB, predicted_decode_tps: 31.4 },
  measured_decode_tps: 34.8,
  typical_decode_tps: 36.1,
  typical_context_tokens: 4_096,
  context_tokens: 32_768,
  machine: { ram_bytes: 64 * GB, bandwidth_gbs: 400, chip: "Apple M1 Max" },
  sku_matrix_ctx: 32_768,
  sku_matrix: [
    { sku: "Apple M1", ram_gb: 16, fits: false, max_context: 0, decode_tps: 0 },
    { sku: "Apple M1 Pro", ram_gb: 32, fits: true, max_context: 8_192, decode_tps: 17.2 },
    { sku: "Apple M1 Max", ram_gb: 64, fits: true, max_context: 32_768, decode_tps: 34.8 },
    { sku: "Apple M2 Ultra", ram_gb: 192, fits: true, max_context: 32_768, decode_tps: 61.5 },
    { sku: "Apple M4 Pro", ram_gb: 48, fits: true, max_context: 24_576, decode_tps: 24.9 },
  ],
};

export const library = {
  models: [
    { repo_id: SERVED_MODEL, model_type: "qwen3_next", size_bytes: 12.25 * GB, quant_bits: 3, vision: false, audio: false, supported: true, support_tier: "targeted", serving: true, resident: true, assessment: { fits: true, max_safe_context: 24_576, predicted_decode_tps: 31.4 } },
    { repo_id: STARTER_MODEL, model_type: "qwen2", size_bytes: 0.33 * GB, quant_bits: 4, vision: false, audio: false, supported: true, support_tier: "targeted", serving: false, resident: true, assessment: { fits: true, max_safe_context: 32_768, predicted_decode_tps: 212 } },
    { repo_id: "mlx-community/gemma-3-12b-it-4bit", model_type: "gemma3", size_bytes: 7.6 * GB, quant_bits: 4, vision: true, audio: false, supported: true, support_tier: "generic", serving: false, resident: false, assessment: { fits: true, max_safe_context: 16_384, predicted_decode_tps: 8.2 } },
    { repo_id: "mlx-community/DeepSeek-V3-4bit", model_type: "deepseek_v3", size_bytes: 371 * GB, quant_bits: 4, vision: false, audio: false, supported: true, support_tier: "generic", serving: false, resident: false, assessment: { fits: false, max_safe_context: 0, predicted_decode_tps: 0 } },
    { repo_id: "someone/mystery-arch", model_type: "mystery", size_bytes: 2.1 * GB, quant_bits: null, vision: false, audio: false, supported: false, support_tier: null, serving: false, resident: false, assessment: null },
  ],
};

export const hubLocal = {
  ok: true,
  models: library.models.map(({ serving: _serving, resident: _resident, audio: _audio, ...row }) => ({ ...row, quant_group_size: row.quant_bits ? 64 : null })),
};

export const hubSearch = {
  ok: true,
  offline: false,
  results: [
    { id: "mlx-community/Qwen3-30B-A3B-4bit", downloads: 48_120, likes: 310, size_estimate: 17.2 * GB },
    { id: "mlx-community/Llama-3.3-70B-Instruct-4bit", downloads: 22_904, likes: 188, size_estimate: 39.7 * GB },
    { id: "mlx-community/gemma-3-27b-it-4bit", downloads: 15_377, likes: 97, size_estimate: 16.9 * GB },
    { id: "mlx-community/Phi-4-mini-instruct-4bit", downloads: 9_211, likes: 44, size_estimate: 2.4 * GB },
  ],
};

export const adaptersAvailable = {
  adapters: [
    { id: "support-tone-r8", path: "/Users/josh/.mlx-bun/adapters/support-tone-r8", rank: 8, scale: 20, base_model: SERVED_MODEL, mounted: true, compatible: true },
    { id: "sql-helper-r16", path: "/Users/josh/.mlx-bun/adapters/sql-helper-r16", rank: 16, scale: 20, base_model: SERVED_MODEL, mounted: false, compatible: true },
    { id: "gemma-poetry", path: "/Users/josh/.mlx-bun/adapters/gemma-poetry", rank: 8, scale: 20, base_model: "mlx-community/gemma-3-12b-it-4bit", mounted: false, compatible: false },
  ],
};

export const adaptersMounted = {
  adapters: [
    { id: "support-tone-r8", path: "/Users/josh/.mlx-bun/adapters/support-tone-r8", rank: 8, scale: 20, size_bytes: 41 * MB, mounted_layers: 32, ram_bytes: 82 * MB },
  ],
};

export const memoryStatus = {
  ok: true,
  enabled: true,
  root: "/Users/josh/.mlx-bun/wiki",
  status: {
    root: "/Users/josh/.mlx-bun/wiki", exists: true, articleCount: 14, referenceCount: 6, isGitRepo: true,
    recentArticles: [
      { article: "Qwen3.8_quantization_notes", mtimeMs: Date.now() - 36_000_000 },
      { article: "Home_lab_network", mtimeMs: Date.now() - 2 * 86_400_000 },
      { article: "Travel_Lisbon_2026", mtimeMs: Date.now() - 9 * 86_400_000 },
    ],
  },
};

export const memoryList = {
  ok: true,
  articles: ["Qwen3.8_quantization_notes", "Home_lab_network", "Travel_Lisbon_2026", "Bread_starter_schedule", "Reading_list"],
  reference: ["Reference/Server_API", "Reference/Training"],
};

export const memoryArticles: Record<string, string> = {
  "Qwen3.8_quantization_notes":
    "# Qwen3.8 quantization notes\n\nThe 27B Trellis quant at 3.2 bits per weight fits the M1 Max with room for a 24k context.\n\n" +
    "## What worked\n\n- Group size 64 kept the perplexity gap under 0.1.\n- Mixed 4/8-bit on the attention projections cost 0.4 GB and bought nothing measurable.\n\n" +
    "## Open questions\n\n1. Does the Neural Engine path change the decode numbers?\n2. Re-run the paired benchmark on a quiet machine.\n\n```sh\nmlx-bun convert --bits 4 --group-size 64 mlx-community/Qwen3-27B-bf16\n```\n",
  Home_lab_network: "# Home lab network\n\nThe Mac Studio serves models on `10.0.0.12:8080`. The Pi runs the DNS resolver.\n\nSee [[Qwen3.8_quantization_notes]] for what it serves.\n",
};

export const memoryLinks = { ok: true, name: "Qwen3.8_quantization_notes", outbound: ["Reference/Training"], inbound: ["Home_lab_network"] };
export const memoryHistory = { ok: true, name: "Qwen3.8_quantization_notes", isGitRepo: true, entries: [
  { hash: "9f3c2a1b7e0d4c6f8a2b1c3d4e5f60718293a4b5", date: "2026-10-18", subject: "synthesis: add decode numbers" },
  { hash: "1a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d", date: "2026-10-11", subject: "synthesis: first draft" },
] };
export const memoryDiff = { ok: true, name: "Qwen3.8_quantization_notes", rev: "9f3c2a1", diff: "--- a/Qwen3.8_quantization_notes.md\n+++ b/Qwen3.8_quantization_notes.md\n@@ -3,3 +3,4 @@\n The 27B Trellis quant fits the M1 Max.\n+The 3.2 bpw build leaves room for a 24k context.\n-Context is still being measured.\n" };

export const sessions = [
  { path: "/Users/josh/.mlx-bun/sessions/2026-10-20-quantize-plan.jsonl", id: "s1", title: "Plan the Qwen3.8 quantization", modified: Date.now() - 600_000, messageCount: 6, forked: false },
  { path: "/Users/josh/.mlx-bun/sessions/2026-10-19-lisbon.jsonl", id: "s2", title: "Lisbon itinerary, three days", modified: Date.now() - 86_400_000, messageCount: 12, forked: false },
  { path: "/Users/josh/.mlx-bun/sessions/2026-10-17-sql.jsonl", id: "s3", title: "Rewrite the reporting SQL", modified: Date.now() - 3 * 86_400_000, messageCount: 4, forked: true },
];

/** A replayed transcript: a question, a tool-using answer, and a follow-up. */
export const history = [
  { role: "user", text: "Which of my local models fit on this Mac with a 16k context?", tools: [], entryId: "e1" },
  {
    role: "assistant",
    text: "Three of them fit with room to spare:\n\n| Model | Size | Decode |\n| - | - | - |\n| Qwen3.8 27B (3.2 bpw) | 12.3 GB | ~31 tok/s |\n| gemma-3-12b-it | 7.6 GB | ~8 tok/s |\n| Qwen2.5 0.5B | 0.3 GB | ~210 tok/s |\n\nDeepSeek-V3 does not: its weights alone are 371 GB.",
    thinking: "The library route reports an assessment per model. Filter to fits=true and report decode speed.",
    tools: [{ callId: "h1", name: "bash", args: { command: "curl -s localhost:8080/library | jq '.models[] | {repo_id, fits: .assessment.fits}'" }, result: '{"repo_id":"mlx-bun/Qwen3.8-27B-Trellis-3.2bpw","fits":true}\n{"repo_id":"mlx-community/gemma-3-12b-it-4bit","fits":true}' }],
  },
  { role: "user", text: "Write the convert command for a 4-bit Qwen3 27B with group size 64.", tools: [], entryId: "e2" },
  { role: "assistant", text: "```sh\nmlx-bun convert --bits 4 --group-size 64 mlx-community/Qwen3-27B-bf16\n```\n\nThe output lands in `~/.mlx-bun/models` and shows up in the library once the scan finishes.", tools: [] },
];

export const sessionSearch = {
  ok: true,
  results: [
    { sessionPath: sessions[1]!.path, sessionTitle: sessions[1]!.title, matches: [{ snippet: "…the tram to Belém leaves every 12 minutes…", ranges: [[4, 8]], role: "assistant" }] },
  ],
};

export const datasetTemplates = {
  templates: [
    { id: "sft_qa_pairs", label: "SFT from QA pairs", description: "Paste Q/A pairs or upload a .txt with Q: / A: blocks. Produces chat-format JSONL.", output_format: "messages", needs_llm: false,
      fields: [{ name: "pairs_text", type: "textarea", label: "Pairs (Q: / A: blocks)", hint: "Q: What is mlx-bun?\nA: A local inference server for Apple Silicon.", required: true }] },
    { id: "dpo_pref_pairs", label: "DPO from preference pairs", description: "Upload CSV with columns prompt, chosen, rejected. Emits DPO JSONL.", output_format: "dpo", needs_llm: false,
      fields: [{ name: "csv_text", type: "textarea", label: "CSV rows", required: true }] },
    { id: "synthetic_instructions", label: "Synthetic instructions", description: "The served model writes instruction and answer pairs about a topic you describe.", output_format: "messages", needs_llm: true,
      fields: [{ name: "topic", type: "text", label: "Topic", hint: "Bread baking at home", required: true }, { name: "count", type: "number", label: "Rows", default: 200 }] },
    { id: "code_tests", label: "Code with verified tests", description: "Generates Python functions and runs their tests in the Docker verifier before keeping a row.", output_format: "messages", needs_llm: true,
      fields: [{ name: "spec", type: "textarea", label: "What the functions should do", required: true }] },
  ],
};

export const metricsSnapshot = () => {
  const now = Date.now();
  const series = Array.from({ length: 40 }, (_, i) => ({ at: now - (40 - i) * 2_000, tokensPerSecond: 24 + 9 * Math.sin(i / 4) + (i % 3), active: 1 + (i % 2), queued: i % 5 === 0 ? 1 : 0 }));
  const dist = (p50: number, p95: number, max: number) => ({ count: 24, mean: (p50 + p95) / 2, p50, p95, max });
  return {
    at: now, startedAt: now - 5_412_000,
    models: [
      { model: SERVED_MODEL, state: "resident", loads: 1, unloads: 0, lastLoadMs: 8_420, lastUnloadMs: null, lastUnloadReason: null, lastSwapMs: null, swaps: 0, weightsBytes: 12.25 * GB, kvBytes: 1.9 * GB, prefixCacheBytes: 612 * MB, lastError: null },
      { model: STARTER_MODEL, state: "resident", loads: 2, unloads: 1, lastLoadMs: 640, lastUnloadMs: 210, lastUnloadReason: "evicted", lastSwapMs: 850, swaps: 1, weightsBytes: 0.33 * GB, kvBytes: 120 * MB, prefixCacheBytes: 40 * MB, lastError: null },
    ],
    schedulers: [{ model: SERVED_MODEL, at: now, active: 2, capacity: 8, queued: 0, tokensPerSecond: 31.2 }],
    caches: [
      { model: SERVED_MODEL, kv: { at: now, bytes: 1.9 * GB, capacityBytes: 6.1 * GB }, prefix: { at: now, bytes: 612 * MB, capacityBytes: 2 * GB, hits: 184, misses: 42, hitRate: 0.81 } },
    ],
    requests: {
      finished: 226, byFinish: { stop: 211, length: 9, cancelled: 4, error: 2 },
      window: { count: 24, queueMs: dist(3, 41, 120), ttftMs: dist(410, 1_250, 2_900), prefillTokensPerSecond: dist(820, 1_100, 1_300), decodeTokensPerSecond: dist(31.2, 34.8, 36.1), totalMs: dist(4_200, 9_800, 14_300), cachedPromptShare: 0.62 },
      recent: [],
    },
    series,
  };
};

export const benchHistory = { runs: [
  { id: "2026-10-18T21-04", profile: "m1max-qwen38", scope: "scoped", startedAt: "2026-10-18T21:04:12", finishedAt: "2026-10-18T21:31:40", durationMs: 1_648_000, complete: true, exitCode: 0, problems: [], machine: { chip: "Apple M1 Max", memoryBytes: 64 * GB, host: "studio", os: "macOS 15.6" }, runDirectory: "/Users/josh/.mlx-bun/metrics/runs/2026-10-18T21-04",
    cells: [{ key: "decode", model: SERVED_MODEL, kind: "tree", tree: "m1max", status: "measured", decodeTokensPerSecond: 34.8, ttftColdMs: 1_210, prefill1kTokensPerSecond: 1_090, contextPrefillTokensPerSecond: 980, aggregateTokensPerSecond: 61.2, coldStartMs: 8_400, peakRssMB: 14_900 }] },
  { id: "2026-10-11T19-12", profile: "m1max-qwen38", scope: "scoped", startedAt: "2026-10-11T19:12:03", finishedAt: null, durationMs: 400_000, complete: false, exitCode: 1, problems: ["machine preflight failed: GPU busy"], machine: null, runDirectory: "/Users/josh/.mlx-bun/metrics/runs/2026-10-11T19-12", cells: [] },
] };
export const benchProfiles = { profiles: [{ name: "m1max-qwen38", path: "/Users/josh/.mlx-bun/metrics/plans/m1max-qwen38.json", scope: "scoped", models: [SERVED_MODEL] }, { name: "quick-smoke", path: "/Users/josh/.mlx-bun/metrics/plans/quick-smoke.json", scope: null, models: [STARTER_MODEL] }] };
export const benchJobs = { jobs: [] as { id: string; status: string; progress: number; message: string | null }[] };

export const benchmarkTasks = {
  dataDirectory: "/Users/josh/.mlx-bun/benchmarks/data",
  tasks: [
    { id: "gsm8k", component: "reasoning", sets: ["capability", "all"], needsVerifier: false, datasets: [{ name: "gsm8k-test.jsonl", rows: 1_319, sha256: "a1", source: "hf", present: true }] },
    { id: "humaneval", component: "code", sets: ["capability", "all"], needsVerifier: true, datasets: [{ name: "humaneval.jsonl", rows: 164, sha256: "b2", source: "hf", present: true }] },
    { id: "mmlu-stem", component: "knowledge", sets: ["capability", "all"], needsVerifier: false, datasets: [{ name: "mmlu-stem.jsonl", rows: 3_100, sha256: "c3", source: "hf", present: false }] },
    { id: "smoke", component: null, sets: ["smoketest", "all"], needsVerifier: false, datasets: [{ name: "smoke.jsonl", rows: 20, sha256: "d4", source: "repo", present: true }] },
  ],
};
export const benchmarkRuns = { runs: [
  { id: "run-0042", label: "qwen38 nightly", startedAt: "2026-10-19T02:00:11", finishedAt: "2026-10-19T03:12:40", durationMs: 4_349_000, complete: true, exitCode: 0, problems: [], model: { path: "/Users/josh/.cache/huggingface/hub/models--mlx-bun--Qwen3.8", repo: SERVED_MODEL, revision: "abc1234" }, enableThinking: true, machine: { chip: "Apple M1 Max", memoryBytes: 64 * GB, host: "studio", os: "macOS 15.6" },
    tasks: [{ task: "gsm8k", status: "complete", reason: null, accuracy: 0.912, correct: 1_203, total: 1_319, wallMs: 2_100_000 }, { task: "humaneval", status: "complete", reason: null, accuracy: 0.805, correct: 132, total: 164, wallMs: 1_900_000 }],
    capability: { score: 0.86, components: { reasoning: 0.912, code: 0.805 }, excluded: ["mmlu-stem"] }, runDirectory: "/Users/josh/.mlx-bun/benchmarks/runs/run-0042" },
  { id: "run-0041", label: "qwen38 before fuse", startedAt: "2026-10-12T02:00:09", finishedAt: "2026-10-12T03:20:01", durationMs: 4_792_000, complete: true, exitCode: 0, problems: [], model: { path: "/x", repo: SERVED_MODEL, revision: "9f3c2a1" }, enableThinking: true, machine: null,
    tasks: [{ task: "gsm8k", status: "complete", reason: null, accuracy: 0.897, correct: 1_183, total: 1_319, wallMs: 2_200_000 }, { task: "humaneval", status: "complete", reason: null, accuracy: 0.793, correct: 130, total: 164, wallMs: 1_950_000 }],
    capability: { score: 0.845, components: { reasoning: 0.897, code: 0.793 }, excluded: ["mmlu-stem"] }, runDirectory: "/Users/josh/.mlx-bun/benchmarks/runs/run-0041" },
] };
export const benchmarkJobs = { jobs: [] as { id: string; status: string; progress: number; message: string | null; error: string | null; startedAt: string; endedAt: string | null }[] };
export const benchmarkComparison = {
  base: "run-0041", candidate: "run-0042", comparable: true,
  tasks: [{ task: "gsm8k", base: 0.897, candidate: 0.912, delta: 0.015 }, { task: "humaneval", base: 0.793, candidate: 0.805, delta: 0.012 }],
  markdown: "# run-0041 vs run-0042\n\nBoth runs complete; provenance matches. gsm8k +1.5 pts (18 flips to correct, 2 to wrong).",
};

/** The streamed reply the fake chat answers every prompt with: thinking, a memory lookup, a shell tool, then markdown. */
export const scriptedReply = {
  thinking: ["Checking what the library says about the served model ", "before answering. ", "The memory vault has notes on the quantization too."],
  memoryTool: { callId: "m1", tool: "memory_search", args: { query: "Qwen3.8 quantization" }, result: "Qwen3.8_quantization_notes: the 3.2 bpw build leaves room for a 24k context." },
  shellTool: { callId: "b1", tool: "bash", args: { command: "curl -s localhost:8080/stats | jq .admission" }, result: '{\n  "weights_bytes": 13153337344,\n  "max_safe_context": 24576\n}' },
  text:
    "The served model is **Qwen3.8 27B** in the 3.2 bits-per-weight Trellis format.\n\n" +
    "## Memory on this Mac\n\n- Weights: 12.3 GB resident\n- KV cache at 24k context: about 6 GB\n- Headroom: roughly 30 GB of the 51 GB the engine may use\n\n" +
    "You can push the context to 24,576 tokens before admission starts refusing requests. To check from a terminal:\n\n" +
    "```sh\ncurl -s localhost:8080/stats | jq .admission.max_safe_context\n```\n\n" +
    "Your notes from last week agree: the quant was chosen to leave room for exactly this.",
};

/** Job events for a quantize, fine-tune or dataset job, as the SSE stream replays them. */
export function jobEvents(jobId: string): object[] {
  const kind = jobId.split("-")[0];
  const ts = Date.now();
  const events: object[] = [{ type: "started", ts }];
  if (kind === "finetune") {
    events.push({ type: "stage", stage: "load", progress: 0.02, message: "Loading base model" }, { type: "log", line: "loaded 27B weights in 8.4s" });
    for (let step = 10; step <= 500; step += 10) {
      const loss = 2.3 * Math.exp(-step / 180) + 0.42 + 0.03 * Math.sin(step / 7);
      events.push({ type: "metric", kind: "train", step, loss, learning_rate: 2e-4 * (1 - step / 520), tokens_per_sec: 1_480 + (step % 50), progress: step / 500, message: `step ${step} of 500` });
      if (step % 100 === 0) events.push({ type: "metric", kind: "val", step, loss: loss + 0.08 }, { type: "log", line: `step ${step}: train ${loss.toFixed(3)}, val ${(loss + 0.08).toFixed(3)}` });
    }
    events.push({ type: "stage", stage: "done", progress: 1, message: "Adapter saved", adapter_path: "/Users/josh/.mlx-bun/adapters/run-2026-10-20" }, { type: "done", ts: ts + 1, adapter_path: "/Users/josh/.mlx-bun/adapters/run-2026-10-20" });
    return events;
  }
  const stages = kind === "dataset"
    ? [["parse", "Parsing the input"], ["generate", "Writing rows"], ["split", "Splitting train and valid"], ["write", "Writing JSONL"]]
    : [["load", "Loading weights"], ["calibrate", "Measuring layer sensitivity"], ["quantize", "Quantizing 64 layers"], ["write", "Writing safetensors"]];
  stages.forEach(([stage, message], index) => {
    events.push({ type: "stage", stage, progress: index / stages.length, message }, { type: "log", line: `[${stage}] ${message!.toLowerCase()}` });
    for (let i = 1; i <= 3; i++) events.push({ type: "log", line: `[${stage}] ${i * 33}% done` }, { type: "stage", stage, progress: (index + i / 3) / stages.length, message });
  });
  const output_dir = kind === "dataset" ? "/Users/josh/.mlx-bun/datasets/job-2026-10-20" : "/Users/josh/.mlx-bun/models/Qwen3-27B-4bit-g64";
  events.push({ type: "stage", stage: "done", progress: 1, message: "Finished", output_dir, n_train: 180, n_valid: 20 }, { type: "done", ts: ts + 1, output_dir, n_train: 180, n_valid: 20 });
  return events;
}
