import { parseArgs } from "node:util";

// One small source for parsing and help; no command registration framework.
const commands = {
  serve: { description: "Serve a local model with continuous batching and the web app", positional: "[query]", options: {
    model: { type: "string", description: "Model directory or cached registry query (overrides positional query)" },
    query: { type: "string", description: "Cached model query when no positional/model override is supplied" },
    host: { type: "string", description: "Bind address [default: 127.0.0.1]" },
    port: { type: "string", description: "Listen port; 0 chooses a free port [default: 8080]" },
    batch: { type: "string", description: "Continuous batching capacity, including at 1 [default: 8]" },
    ctx: { type: "string", description: "Explicit context-token limit; otherwise use the model limit" },
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
    "read-only": { type: "boolean", description: "Disable mutating chat tools" },
    "no-open": { type: "boolean", description: "Do not open the web app in an interactive terminal" },
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
} satisfies Record<string, { description: string; positional: string; options: Record<string, { type: "string" | "boolean"; description: string }> }>;
export type Command = keyof typeof commands;
export type CommandArgs = { values: Record<string, string | boolean | undefined>; positionals: string[] };
export function isCommand(name: string): name is Command { return Object.hasOwn(commands, name); }

export function parseCommand(command: Command, args: string[]): CommandArgs {
  const options: Record<string, { type: "string" | "boolean" }> = commands[command].options;
  const parsed = parseArgs({ args, options, allowPositionals: true, strict: true });
  const max = commands[command].positional ? 1 : 0;
  if (parsed.positionals.length > max) throw new Error(`Too many arguments for ${command}`);
  if (commands[command].positional.startsWith("<") && !parsed.positionals.length)
    throw new Error(`usage: mlx-bun ${command} ${commands[command].positional}`);
  return parsed;
}

export function help(command?: string): string {
  if (!command) return `mlx-bun — local AI on Apple Silicon\n\nUsage: mlx-bun [options]\n       mlx-bun serve [query] [options]\n       mlx-bun <command> [options]\n\nCommands:\n${Object.entries(commands).map(([name, info]) => `  ${name.padEnd(8)} ${info.description}`).join("\n")}\n\nOptions:\n  -h, --help     Show help\n  -v, --version  Show version\n\nWith no command, start the server and web app using a cached model.\nRun mlx-bun serve --help for serving options.`;
  if (!isCommand(command)) throw new Error(`Unknown command: ${command}`);
  const info = commands[command];
  return `mlx-bun ${command} — ${info.description}\n\nUsage: mlx-bun ${command} ${info.positional} [options]\n\nOptions:\n${Object.entries(info.options).map(([name, option]) => `  ${(`--${name}` + (option.type === "string" ? " <value>" : "")).padEnd(24)} ${option.description}`).join("\n")}\n  -h, --help               Show help`;
}
