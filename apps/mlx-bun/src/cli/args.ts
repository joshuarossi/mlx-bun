import { parseArgs } from "node:util";

// One small source for parsing and help; no command registration framework.
const commands = {
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
  if (!command) return `mlx-bun — local AI on Apple Silicon\n\nUsage: mlx-bun <command> [options]\n\nCommands:\n${Object.entries(commands).map(([name, info]) => `  ${name.padEnd(8)} ${info.description}`).join("\n")}\n\nOptions:\n  -h, --help     Show help\n  -v, --version  Show version\n\nThe server and default startup are still being migrated on this branch.`;
  if (!isCommand(command)) throw new Error(`Unknown command: ${command}`);
  const info = commands[command];
  return `mlx-bun ${command} — ${info.description}\n\nUsage: mlx-bun ${command} ${info.positional} [options]\n\nOptions:\n${Object.entries(info.options).map(([name, option]) => `  ${(`--${name}` + (option.type === "string" ? " <value>" : "")).padEnd(24)} ${option.description}`).join("\n")}\n  -h, --help               Show help`;
}
