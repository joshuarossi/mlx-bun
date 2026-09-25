import { parseArgs } from "node:util";

// One small source for parsing and help; no command registration framework.
const commands = {
  serve: { description: "Serve a local model with continuous batching and the web app", positional: "[query]", options: {
    model: { type: "string", description: "Model directory or cached registry query (overrides positional query)" },
    query: { type: "string", description: "Cached model query when no positional/model override is supplied" },
    host: { type: "string", description: "Bind address [default: 127.0.0.1]" },
    port: { type: "string", description: "Listen port; 0 chooses a free port [default: 8080]" },
    batch: { type: "string", description: "Continuous batching capacity, including at 1 [default: 8]" },
    "decode-concurrency": { type: "string", description: "Alias for --batch (main's spelling); the same continuous capacity" },
    "max-tokens": { type: "string", description: "Default completion cap when a request omits one" },
    thinking: { type: "string", description: "Default thinking mode: on | off; requests may override" },
    temperature: { type: "string", description: "Default sampling temperature [0..5]" },
    temp: { type: "string", description: "Alias for --temperature" },
    "top-p": { type: "string", description: "Default nucleus sampling [0..1]" },
    "top-k": { type: "string", description: "Default top-k sampling" },
    "kv-quant": { type: "string", description: "KV quantization: off | config | 4 | 8 [default: off]" },
    "kv-budget": { type: "string", description: "Aggregate batch KV budget, decimal GB; unset means no budget" },
    "prompt-cache": { type: "string", description: "RAM prompt cache cap, GiB; 0 disables [default: 8 GB]" },
    "ssd-cache": { type: "string", description: "Optional durable prompt-cache directory" },
    "ssd-cache-max": { type: "string", description: "SSD cap, GiB; 0 means unlimited" },
    "ssd-cache-verify": { type: "boolean", description: "Verify tensor hashes on SSD restores" },
    "ssd-demote-idle": { type: "string", description: "Idle seconds before SSD demotion; 0 disables [default: 300]" },
    "generation-checkpoint": { type: "string", description: "Checkpoint every N generated tokens; requires --ssd-cache" },
    "memory-budget": { type: "string", description: "Admission-control memory budget, decimal GB; requests that cannot fit are rejected instead of crashing the GPU" },
    "context-length": { type: "string", description: "GLM-5.2 resource-plan context reservation [default: 4096]; other families ignore it" },
    "force-wire": { type: "boolean", description: "Wire weights into memory at load" },
    "expert-offload": { type: "boolean", description: "MoE only: serve experts from a page-aligned file mmap built on first use" },
    "allow-private-media": { type: "boolean", description: "Let image_url/audio_url parts fetch from private, loopback, and link-local hosts" },
    "hlg-sampling": { type: "string", description: "Piecewise tone-curve (HLG) sampling: on | off [default: off]" },
    "hlg-width": { type: "string", description: "HLG mid-region half-width, nats [default: 4]" },
    "hlg-shoulder": { type: "string", description: "HLG highlight rolloff scale, nats [default: 4]" },
    "hlg-toe": { type: "string", description: "HLG shadow rolloff scale, nats [default: 6]" },
    "hlg-pivot-offset": { type: "string", description: "HLG pivot: nats below the top token [default: 6]" },
    "draft-model": { type: "string", description: "Speculative decoding draft: a path or cached query resolved like the main model; kind auto-detected" },
    "draft-kind": { type: "string", description: "Draft kind override: two-model | assistant | dspark | deepspec | mtp | ngram (ngram is model-free; mtp alone mounts <model>/mtp/)" },
    "num-draft-tokens": { type: "string", description: "Drafts per verify round, integer >= 1 [default: 3; ngram: 10]" },
    "ngram-max": { type: "string", description: "Prompt-lookup longest k-gram, integer >= 1 (ngram only) [default: 3]" },
    "ngram-min": { type: "string", description: "Prompt-lookup shortest k-gram, integer >= 1 (ngram only) [default: 1]" },
    mtp: { type: "string", description: "GLM-5.2 native MTP drafter: on | off [default: on]; other families ignore it" },
    "paged-kv": { type: "boolean", description: "Paged KV cache (Gemma4 family; env mirror MLX_BUN_PAGED_KV=1); other families answer the typed capability error" },
    "paged-kv-block-size": { type: "string", description: "Tokens per KV block with --paged-kv, integer >= 1 [default: 256]" },
    adapter: { type: "string", description: "Mount a LoRA adapter directory at startup as the default for requests without an adapter field" },
    "adapter-path": { type: "string", description: "Alias for --adapter (mlx_lm spelling)" },
    "no-open": { type: "boolean", description: "Do not open the web app in an interactive terminal" },
  } },
  generate: { description: "Generate text once from a local model", positional: "[query] [prompt]", options: {
    query: { type: "string", description: "Cached model query when no positional query is supplied" },
    prompt: { type: "string", description: "Prompt text (or second positional argument)" },
    raw: { type: "boolean", description: "Skip the chat template and tokenize the prompt verbatim" },
    "max-tokens": { type: "string", description: "Completion cap [default: 256]" },
    temperature: { type: "string", description: "Sampling temperature [default: 0]" },
    temp: { type: "string", description: "Alias for --temperature" },
    "top-p": { type: "string", description: "Nucleus sampling" },
    "top-k": { type: "string", description: "Top-k sampling" },
    seed: { type: "string", description: "Sampler seed" },
    "kv-quant": { type: "string", description: "KV quantization: off | config | 4 | 8 [default: off]" },
  } },
  embed: { description: "Embed local text and print vectors", positional: "[query] [text]", options: {
    query: { type: "string", description: "Cached model query; defaults to the first downloaded embedding model" },
    text: { type: "string", description: "Text to embed; otherwise second positional or nonempty stdin lines" },
    instruct: { type: "string", description: "Query instruction; omit for document embeddings" },
    json: { type: "boolean", description: "Print one OpenAI-style embedding list instead of one vector per line" },
  } },
  get: { description: "Download a model from Hugging Face (resumable, verified)", positional: "<org/repo | substring>", options: {
    revision: { type: "string", description: "Git revision [default: main]" },
  } },
  ls: { description: "List downloaded models (one canonical revision per repo)", positional: "[query]", options: {
    vision: { type: "boolean", description: "Only vision-capable models" },
    "max-size": { type: "string", description: "Filter by weight size, e.g. 10GB or 800MB" },
    "all-revisions": { type: "boolean", description: "Show each snapshot; canonical revision marked *" },
  } },
  scan: { description: "Re-index the Hugging Face cache without reading tensor bytes", positional: "", options: {} },
  fit: { description: "Estimate model memory and decode speed on this machine", positional: "<query>", options: {
    ctx: { type: "string", description: "Context tokens [default: 8192; GLM-5.2: 4096]" },
    "kv-quant": { type: "string", description: "KV estimate: 4 | 8 | config | off [default: off]" },
    skus: { type: "boolean", description: "Print the Apple Silicon SKU matrix" },
  } },
  gc: { description: "Reclaim superseded snapshots and dead blobs (preview by default)", positional: "", options: {
    yes: { type: "boolean", description: "Actually delete the planned snapshots and blobs" },
    "dry-run": { type: "boolean", description: "Never delete, even with --yes" },
    force: { type: "boolean", description: "Also prune superseded snapshots with otherwise unique files" },
  } },
  upload: { description: "Push a local model directory to the Hugging Face Hub (mlx_lm.upload counterpart)", positional: "",
    usage: "usage: mlx-bun upload --path <model-dir> --upload-repo <org/repo> [--private]", options: {
    path: { type: "string", description: "Local model directory to upload [default: mlx_model]" },
    "upload-repo": { type: "string", description: "Hub repo id, org/name or bare name (required)" },
    private: { type: "boolean", description: "Create the repo as private (mlx-bun extension)" },
  } },
  convert: { description: "Quantize an HF model into a local MLX snapshot (mlx_lm.convert counterpart)", positional: "[repo-or-path]", options: {
    "hf-path": { type: "string", description: "Source model: local path, downloaded model, or HF repo id (fetched first); --model and the positional are aliases" },
    model: { type: "string", description: "Alias for --hf-path" },
    "mlx-path": { type: "string", description: "Output directory; must not already exist [default: mlx_model]" },
    quantize: { type: "boolean", short: "q", description: "Quantize the model (uniform affine)" },
    "q-bits": { type: "string", description: "Bits per weight: 4 or 8 [default: 4]" },
    "q-group-size": { type: "string", description: "Quantization group size: 32 or 64 [default: 64]" },
    "upload-repo": { type: "string", description: "Push the converted model to this Hugging Face repo afterwards (write token checked first)" },
    "target-bpw": { type: "string", description: "Mixed precision target bits-per-weight, e.g. 4.5: OptiQ sensitivity sweep + per-layer knapsack; implies -q" },
    "candidate-bits": { type: "string", description: "Comma list the knapsack may pick from [default: 4,8]" },
    "calibration-mix": { type: "string", description: "\"optiq\" or a JSONL path [default: optiq]" },
    "n-calibration": { type: "string", description: "Calibration samples [default: 2]" },
    "rotate-weights": { type: "boolean", description: "Fold the model's offline TurboQuant rotation before quantization (auto-detects Llama/Qwen3.5/Qwen MTP)" },
    "rotation-seed": { type: "string", description: "Deterministic rotation seed [default: 42]" },
    "q-mode": { type: "string", description: "Quantization mode; only affine is supported [default: affine]" },
    dtype: { type: "string", description: "Not supported (mlx_lm.convert flag); exits with an error" },
    dequantize: { type: "boolean", short: "d", description: "Not supported (mlx_lm.convert flag); exits with an error" },
    "quant-predicate": { type: "string", description: "Not supported (mlx-lm recipe); use --target-bpw for mixed precision" },
  } },
  train: { description: "Fine-tune a LoRA adapter on your data (sft | dpo | orpo)", positional: "[model]", options: {
    query: { type: "string", description: "Model to fine-tune when no positional query is supplied (auto-picks the default model if omitted)" },
    data: { type: "string", description: "Dataset dir with train.jsonl (+ optional valid.jsonl); rows are {prompt, chosen, rejected} for dpo/orpo, {messages|text} for sft  (required)" },
    method: { type: "string", description: "sft | dpo | orpo  [default: orpo]" },
    adapter: { type: "string", description: "Output adapter dir  [default: ~/.cache/mlx-bun/mlx-bun-finetunes/<method>-<model>]" },
    iters: { type: "string", description: "Training iterations  [default: 100]" },
    lr: { type: "string", description: "Learning rate  [default: orpo 1e-5 · dpo 5e-5 · sft 2e-4]" },
    rank: { type: "string", description: "LoRA rank  [default: orpo 16 · else 8]" },
    scale: { type: "string", description: "LoRA scale  [default: orpo 2.0 · else 1.0]" },
    seq: { type: "string", description: "Max sequence length  [default: gemma 8192 · else 4096]" },
    batch: { type: "string", description: "Batch size  [default: 1]" },
    "grad-accum": { type: "string", description: "Gradient accumulation steps (effective batch = batch × grad-accum at batch-size-1 memory)  [default: 1]" },
    "grad-clip": { type: "string", description: "Gradient-norm clip (0 = off)  [default: 1.0]" },
    seed: { type: "string", description: "Data-shuffle / init seed  [default: 0]" },
    "val-size": { type: "string", description: "Max validation examples per eval  [default: 256]" },
    lambda: { type: "string", description: "ORPO odds-ratio weight  [default: 0.1]" },
    "sft-scope": { type: "string", description: "ORPO chosen-NLL scope: full (paper/TRL-faithful, prompt+response) | response (pre-2026-07 runs, bit-exact)  [default: full]" },
    seg: { type: "string", description: "Layers per segment (segmented backward; orpo default 2)" },
    "save-every": { type: "string", description: "Crash-safe mountable checkpoint every n steps" },
    resume: { type: "string", description: "Warm-start LoRA weights from a checkpoint/adapter dir" },
    "no-flash": { type: "boolean", description: "Disable the flash-CCE Metal head (use the MLX fused head)" },
    "no-prefix": { type: "boolean", description: "Disable prefix-sharing (two-forward branches)" },
    "no-segment": { type: "boolean", description: "Disable the segmented backward (hold all activations)" },
    "dry-run": { type: "boolean", description: "Inspect the dataset + print the resolved plan, don't train" },
  } },
  "train-watch": { description: "Live dashboard for a training run (tails <adapter-dir>/metrics.jsonl)", positional: "[adapter-dir]", options: {
    adapter: { type: "string", description: "Adapter directory to watch; accepted for the positional  [default: ~/.cache/mlx-bun/mlx-bun-finetunes/orpo-cpm5]" },
  } },
  fuse: { description: "Merge a LoRA adapter into the base weights (writes a standalone snapshot)", positional: "[model]", options: {
    model: { type: "string", description: "Base model (registry query or a snapshot path); the mlx_lm.fuse spelling of the positional" },
    adapter: { type: "string", description: "Adapter directory (adapters.safetensors + adapter_config.json)  [default: adapters]" },
    "adapter-path": { type: "string", description: "mlx_lm.fuse alias for --adapter" },
    "save-path": { type: "string", description: "Output model directory  [default: fused_model]" },
    "de-quantize": { type: "boolean", description: "Not supported (mlx_lm.fuse flag); the command exits with an error" },
    dequantize: { type: "boolean", description: "Not supported (mlx_lm.fuse flag); the command exits with an error" },
    "export-gguf": { type: "boolean", description: "Not supported (mlx_lm.fuse flag); the command exits with an error" },
    "gguf-path": { type: "string", description: "Not supported (mlx_lm.fuse flag); the command exits with an error" },
    "upload-repo": { type: "string", description: "Not supported (mlx_lm.fuse flag); the command exits with an error" },
  } },
} satisfies Record<string, { description: string; positional: string; usage?: string; options: Record<string, { type: "string" | "boolean"; description: string; short?: string }> }>;
export type Command = keyof typeof commands;
export type CommandArgs = { values: Record<string, string | boolean | undefined>; positionals: string[] };
export function isCommand(name: string): name is Command { return Object.hasOwn(commands, name); }

/** Bare and option-first invocations start the app; explicit verbs keep their arguments. */
export function commandInvocation(argv: string[]): { command: string; args: string[] } {
  const [first, ...rest] = argv;
  const command = !first || (first.startsWith("--") && !["--help", "--version"].includes(first)) ? "serve" : first;
  return { command: command === "gen" ? "generate" : command, args: command === "serve" && first !== "serve" ? argv : rest };
}

/** The verb's usage line: table-supplied, else derived from its positional. */
export function usage(command: Command): string {
  return (commands[command] as { usage?: string }).usage ?? `usage: mlx-bun ${command} ${commands[command].positional}`;
}

export function parseCommand(command: Command, args: string[]): CommandArgs {
  const options: Record<string, { type: "string" | "boolean"; short?: string }> = commands[command].options;
  let parsed: CommandArgs;
  try { parsed = parseArgs({ args, options, allowPositionals: true, strict: true }); }
  catch (error) {
    // A verb with its own usage line answers a valueless option the way main did.
    if ("usage" in commands[command] && (error as { code?: string }).code === "ERR_PARSE_ARGS_INVALID_OPTION_VALUE")
      throw new Error(usage(command));
    throw error;
  }
  const max = command === "generate" || command === "embed" ? 2 : commands[command].positional ? 1 : 0;
  if (parsed.positionals.length > max) throw new Error(`Too many arguments for ${command}`);
  if (commands[command].positional.startsWith("<") && !parsed.positionals.length) throw new Error(usage(command));
  return parsed;
}

export function help(command?: string): string {
  if (command === "gen") command = "generate";
  const column = Math.max(...Object.keys(commands).map(name => name.length));
  if (!command) return `mlx-bun — local AI on Apple Silicon\n\nUsage: mlx-bun [options]\n       mlx-bun serve [query] [options]\n       mlx-bun <command> [options]\n\nCommands:\n${Object.entries(commands).map(([name, info]) => `  ${name.padEnd(column)} ${info.description}`).join("\n")}\n\nOptions:\n  -h, --help     Show help\n  -v, --version  Show version\n\nWith no command, start the server and web app using a cached model.\nRun mlx-bun serve --help for serving options.`;
  if (!isCommand(command)) throw new Error(`Unknown command: ${command}`);
  const info = commands[command];
  return `mlx-bun ${command} — ${info.description}\n\nUsage: mlx-bun ${command} ${info.positional} [options]\n\nOptions:\n${Object.entries(info.options).map(([name, option]: [string, { type: string; description: string; short?: string }]) => `  ${((option.short ? `-${option.short}, ` : "") + `--${name}` + (option.type === "string" ? " <value>" : "")).padEnd(24)} ${option.description}`).join("\n")}\n  -h, --help               Show help`;
}
