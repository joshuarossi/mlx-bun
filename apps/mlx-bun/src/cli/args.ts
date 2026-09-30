import { parseArgs } from "node:util";
import { verbHelp } from "@mlx-bun/app-services/verbs";
import { PROGRAM, installedVerbs } from "./module-verbs";

// One small source for parsing and help; no command registration framework.
// `setup` is main's true alias of `memory` (`mlx-bun setup init` == `mlx-bun memory init`).
const memoryDetails = `A local, durable memory for the assistant: a wiki of Markdown articles
(~/.mlx-bun/wiki) it reads to remember your projects, people, and history
across sessions. It is yours: git-tracked, editable in any tool (Obsidian
opens it as a vault), and it never leaves the machine. Once set up, it loads
automatically into every \`mlx-bun serve\` session.

Subcommands:
  init, setup        Create the wiki + walk through setup (idempotent);
                     offers to import an existing vault and install the
                     nightly synthesis job
  status             Path, article count, git + schedule state (the default)
  open, browse [article]
                     Open the wiki, or a specific article, in Obsidian
                     (falls back to Finder / the default Markdown app)
  list               List article titles + read-only Reference docs
  search <query>     Search articles from the terminal
  toc <article>      Print an article's headings + anchors
  section <article> <anchor>
                     Print one article section
  links <article>    Show resolved outbound + inbound wikilinks
  read <article>     Print an article (stem, e.g. Archie_Project)
  synthesize         Run the FULL synthesis DAG now (--since, --model,
                     --dry-run); also: pipeline, all
  segment | extract | route | synthesize-stage
                     Run ONE decomposed stage worker (--limit N —
                     segment/extract/synthesize-stage only; --convs a,b).
                     Each pulls its eligible work from the DB by state, walks
                     oldest-conversation-first, persists, and exits — resumable,
                     and runnable as separate concurrent processes on slices.
  link               Deterministic cross-linking stage: inline-link first
                     mentions + rebuild ## See also (--limit N; no model)
  schedule           Install the nightly launchd job (--at HH:MM [03:00])
  unschedule         Remove the nightly launchd job

The read path is live: the assistant reads a wiki you set up by hand or
import during \`memory init\`. Run \`mlx-bun memory open\` to browse it in
Obsidian/Finder, or \`mlx-bun memory open <article>\` to jump to a specific
page. Synthesis (conversations -> articles) runs the full local pipeline via
\`mlx-bun memory synthesize\` (or per-stage: segment/extract/route/
synthesize-stage/link); the nightly job runs it on a schedule. These load the
memory task model on first use; --host/--port use a serving mlx-bun instead.`;

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
    "kv-quant": { type: "string", description: "KV quantization: off | config | 4 | 8 | turbo[:k<bits>v<bits>] (turbo is k8v3); config without the model's kv_config.json stays bf16, and a scheme the model's cache cannot take is refused at startup [default: off]" },
    l1: { type: "boolean", description: "Numerical preset: KV off, unfused SDPA (the default); explicit KV/kernel flags override" },
    l2: { type: "boolean", description: "Numerical preset: model-config KV, fused SDPA; wins over --l1, explicit KV/kernel flags override" },
    "fused-sdpa": { type: "string", description: "Startup SDPA override: on | off [default: on for KV config, off otherwise]" },
    "kv-budget": { type: "string", description: "Aggregate batch KV budget, decimal GB; unset means no budget" },
    "prompt-cache": { type: "string", description: "RAM prompt cache cap, GiB; 0 disables [default: 8 GB]" },
    "ssd-cache": { type: "string", description: "Saved prompt/KV state directory, or off to disable it [default: MLX_BUN_HOME/kv]; one directory per model identity, so a model returns to its saved state" },
    "ssd-cache-max": { type: "string", description: "Byte budget for the whole saved-state directory across every model, GiB; 0 means unlimited [default: 20]" },
    "ssd-cache-verify": { type: "boolean", description: "Verify tensor hashes on SSD restores" },
    "ssd-demote-idle": { type: "string", description: "Idle seconds before SSD demotion; 0 disables [default: 300]" },
    "generation-checkpoint": { type: "string", description: "Checkpoint every N generated tokens into the saved state" },
    "memory-budget": { type: "string", description: "Admission-control memory budget, decimal GB; requests that cannot fit are rejected instead of crashing the GPU" },
    "model-budget": { type: "string", description: "What all resident models may use together, decimal GB: a model that fits loads beside the others, otherwise the least recently used one is drained, its saved state flushed, and released first [default: 70% of the GPU's recommended working set]" },
    "context-length": { type: "string", description: "Context tokens a memory-planning runtime reserves [default: its preset]; models without a plan ignore it" },
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
    mtp: { type: "string", description: "Checkpoint-native multi-token-prediction draft head: on | off [default: on]; models without one ignore it" },
    "paged-kv": { type: "boolean", description: "Paged KV cache for graphs that declare paged attention (env mirror MLX_BUN_PAGED_KV=1); other graphs answer the typed capability error" },
    "paged-kv-block-size": { type: "string", description: "Tokens per KV block with --paged-kv, integer >= 1 [default: 256]" },
    adapter: { type: "string", description: "Mount a LoRA adapter directory at startup as the default for requests without an adapter field" },
    "adapter-path": { type: "string", description: "Alias for --adapter (mlx_lm spelling)" },
    "whisper-model": { type: "string", description: "Whisper checkpoint (path or cached query) for /v1/audio/* beside the chat model [default: the first downloaded whisper model, resolved on the first request]; serving a Whisper checkpoint ALONE starts a transcription-only server" },
    "whisper-idle-unload": { type: "string", description: "Seconds the Whisper weights stay loaded after a take; 0 releases them right after every take [default: 0]" },
    "whisper-resident": { type: "boolean", description: "Never release the Whisper weights" },
    preload: { type: "boolean", description: "Transcription-only server: load the Whisper weights before listening instead of on the first request" },
    "no-open": { type: "boolean", description: "Do not open the web app in an interactive terminal" },
    "in-process": { type: "boolean", description: "Load the models in this process instead of one worker process per resident model. Isolated serving is the default: this process keeps the app, web chat and jobs and loads no model, each worker is crash-isolated and respawns after a crash, and the workers are held by memory fit (--model-budget)" },
    isolate: { type: "boolean", description: "Deprecated, accepted and ignored: isolated serving is the default (see --in-process)" },
  } },
  generate: { description: "Generate text once from a local model", positional: "[query] [prompt]", options: {
    query: { type: "string", description: "Cached model query when no positional query is supplied" },
    prompt: { type: "string", description: "Prompt text (or second positional argument); - reads stdin" },
    "system-prompt": { type: "string", description: "System message placed before the prompt in the chat template (ignored with --raw)" },
    raw: { type: "boolean", description: "Skip the chat template and tokenize the prompt verbatim" },
    "max-tokens": { type: "string", description: "Completion cap [default: 256]" },
    temperature: { type: "string", description: "Sampling temperature [default: 0]" },
    temp: { type: "string", description: "Alias for --temperature" },
    "top-p": { type: "string", description: "Nucleus sampling" },
    "top-k": { type: "string", description: "Top-k sampling" },
    "min-p": { type: "string", description: "Min-p sampling: keep tokens with probability >= min-p times the top token's [0..1]" },
    "min-tokens-to-keep": { type: "string", description: "Tokens min-p never filters out, integer >= 1 [default: 1]" },
    "xtc-probability": { type: "string", description: "Probability per step of XTC (exclude top choices) sampling [0..1]" },
    "xtc-threshold": { type: "string", description: "Probability a token must exceed to be an XTC removal candidate [0..0.5]" },
    adapter: { type: "string", description: "Mount a LoRA adapter directory for this generation" },
    "adapter-path": { type: "string", description: "Alias for --adapter (mlx_lm spelling)" },
    seed: { type: "string", description: "Sampler seed" },
    "kv-quant": { type: "string", description: "KV quantization: off | config | 4 | 8 | turbo[:k<bits>v<bits>] (turbo is k8v3); config without the model's kv_config.json stays bf16, and a scheme the model's cache cannot take is refused at startup [default: off]" },
    "quantized-kv-start": { type: "string", description: "Token count at which KV quantization starts with --kv-quant 4 | 8 | turbo | config [default: 0]" },
    l1: { type: "boolean", description: "Numerical preset: KV off, unfused SDPA (the default); explicit KV/kernel flags override" },
    l2: { type: "boolean", description: "Numerical preset: model-config KV, fused SDPA; wins over --l1, explicit KV/kernel flags override" },
    "fused-sdpa": { type: "string", description: "Startup SDPA override: on | off [default: on for KV config, off otherwise]" },
  } },
  embed: { description: "Embed local text and print vectors", positional: "[query] [text]", options: {
    query: { type: "string", description: "Cached model query; defaults to the first downloaded embedding model" },
    text: { type: "string", description: "Text to embed; otherwise second positional or nonempty stdin lines" },
    instruct: { type: "string", description: "Query instruction; omit for document embeddings" },
    json: { type: "boolean", description: "Print one OpenAI-style embedding list instead of one vector per line" },
  } },
  memory: { description: "Your local AI's personal wiki: set it up, inspect it, run synthesis, schedule it", positional: "[subcommand] [args]",
    usage: "usage: mlx-bun memory <subcommand> [args] [options]", details: memoryDetails, options: {
    since: { type: "string", description: "synthesize: only conversations newer than this (parsed; the pipeline does not consume it yet)" },
    model: { type: "string", description: "synthesize: synthesis model override (parsed; reserved)" },
    "dry-run": { type: "boolean", description: "synthesize: plan the stages only, never write the vault" },
    limit: { type: "string", description: "Stage workers: cap the work processed this pass (segment, extract, synthesize-stage, link)" },
    convs: { type: "string", description: "Stage workers: comma-separated conversation ids to restrict the pass to" },
    at: { type: "string", description: "schedule: local wall-clock time for the nightly job, 24h HH:MM [default: 03:00]" },
    host: { type: "string", description: "Run the model calls on a serving mlx-bun at this host instead of loading the memory task model (127.0.0.1 when only --port is given)" },
    port: { type: "string", description: "Port of that server (8080 when only --host is given)" },
  } },
  setup: { description: "Set up your local AI's memory wiki (alias of mlx-bun memory)", positional: "[subcommand] [args]",
    usage: "usage: mlx-bun setup <subcommand> [args] [options]", details: memoryDetails, options: {
    since: { type: "string", description: "synthesize: only conversations newer than this (parsed; the pipeline does not consume it yet)" },
    model: { type: "string", description: "synthesize: synthesis model override (parsed; reserved)" },
    "dry-run": { type: "boolean", description: "synthesize: plan the stages only, never write the vault" },
    limit: { type: "string", description: "Stage workers: cap the work processed this pass (segment, extract, synthesize-stage, link)" },
    convs: { type: "string", description: "Stage workers: comma-separated conversation ids to restrict the pass to" },
    at: { type: "string", description: "schedule: local wall-clock time for the nightly job, 24h HH:MM [default: 03:00]" },
    host: { type: "string", description: "Run the model calls on a serving mlx-bun at this host instead of loading the memory task model (127.0.0.1 when only --port is given)" },
    port: { type: "string", description: "Port of that server (8080 when only --host is given)" },
  } },
} satisfies Record<string, { description: string; positional: string; usage?: string; details?: string; options: Record<string, { type: "string" | "boolean"; description: string; short?: string }> }>;
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

/** A verb's option table (name → type, short); the alias parser reads the same one. A module's verb reads from its manifest. */
export function commandOptions(command: string): Record<string, { type: "string" | "boolean"; short?: string }> {
  if (isCommand(command)) return commands[command].options;
  const spec = installedVerbs().get(command);
  if (!spec) throw new Error(`Unknown command: ${command}`);
  return Object.fromEntries(spec.options.map(option => [option.name, { type: option.type === "boolean" ? "boolean" as const : "string" as const,
    ...(option.short ? { short: option.short } : {}) }]));
}

/** The positional-count and required-positional rules shared by every way of building a verb's arguments. */
export function checkPositionals(command: Command, parsed: CommandArgs): void {
  const max = command === "memory" || command === "setup" ? Infinity : command === "generate" || command === "embed" ? 2 : commands[command].positional ? 1 : 0;
  if (parsed.positionals.length > max) throw new Error(`Too many arguments for ${command}`);
  if (commands[command].positional.startsWith("<") && !parsed.positionals.length) throw new Error(usage(command));
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
  checkPositionals(command, parsed);
  return parsed;
}

export function help(command?: string): string {
  if (command === "gen") command = "generate";
  // The built-in verbs, then the installed modules' (`src/modules.ts`).
  const verbs = installedVerbs(), listed = [...Object.entries(commands).map(([name, info]) => [name, info.description] as const),
    ...[...verbs].map(([name, spec]) => [name, spec.summary] as const)];
  const column = Math.max(...listed.map(([name]) => name.length));
  if (!command) return `mlx-bun — local AI on Apple Silicon\n\nUsage: mlx-bun [options]\n       mlx-bun serve [query] [options]\n       mlx-bun <command> [options]\n\nCommands:\n${listed.map(([name, description]) => `  ${name.padEnd(column)} ${description}`).join("\n")}\n\nOptions:\n  -h, --help     Show help\n  -v, --version  Show version\n\nWith no command, start the server and web app using a cached model.\nRun mlx-bun serve --help for serving options.`;
  const verb = verbs.get(command);
  if (verb) return verbHelp(PROGRAM, verb);
  if (!isCommand(command)) throw new Error(`Unknown command: ${command}`);
  const info = commands[command];
  const details = (info as { details?: string }).details;
  return `mlx-bun ${command} — ${info.description}\n\nUsage: mlx-bun ${command} ${info.positional} [options]\n${details ? `\n${details}\n` : ""}\nOptions:\n${Object.entries(info.options).map(([name, option]: [string, { type: string; description: string; short?: string }]) => `  ${((option.short ? `-${option.short}, ` : "") + `--${name}` + (option.type === "string" ? " <value>" : "")).padEnd(24)} ${option.description}`).join("\n")}\n  -h, --help               Show help`;
}
