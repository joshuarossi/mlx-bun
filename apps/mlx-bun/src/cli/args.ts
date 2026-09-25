import { parseArgs } from "node:util";

// One small source for parsing and help; no command registration framework.
const commands = {
  serve: { description: "Serve a local model with continuous batching and the web app", positional: "[query]", options: {
    model: { type: "string", description: "Model directory or cached registry query (overrides positional query)" },
    query: { type: "string", description: "Cached model query when no positional/model override is supplied" },
    host: { type: "string", description: "Bind address [default: 127.0.0.1]" },
    port: { type: "string", description: "Listen port; 0 chooses a free port [default: 8080]" },
    batch: { type: "string", description: "Continuous batching capacity, including at 1 [default: 8]" },
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
} satisfies Record<string, { description: string; positional: string; usage?: string; options: Record<string, { type: "string" | "boolean"; description: string }> }>;
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
  const options: Record<string, { type: "string" | "boolean" }> = commands[command].options;
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
  if (!command) return `mlx-bun — local AI on Apple Silicon\n\nUsage: mlx-bun [options]\n       mlx-bun serve [query] [options]\n       mlx-bun <command> [options]\n\nCommands:\n${Object.entries(commands).map(([name, info]) => `  ${name.padEnd(8)} ${info.description}`).join("\n")}\n\nOptions:\n  -h, --help     Show help\n  -v, --version  Show version\n\nWith no command, start the server and web app using a cached model.\nRun mlx-bun serve --help for serving options.`;
  if (!isCommand(command)) throw new Error(`Unknown command: ${command}`);
  const info = commands[command];
  return `mlx-bun ${command} — ${info.description}\n\nUsage: mlx-bun ${command} ${info.positional} [options]\n\nOptions:\n${Object.entries(info.options).map(([name, option]) => `  ${(`--${name}` + (option.type === "string" ? " <value>" : "")).padEnd(24)} ${option.description}`).join("\n")}\n  -h, --help               Show help`;
}
