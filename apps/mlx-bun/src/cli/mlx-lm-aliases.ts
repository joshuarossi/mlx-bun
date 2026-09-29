// `mlx-bun.<cmd>`: mlx-lm's console commands (mlx_lm.<cmd>) under mlx-bun's own
// names. Each alias runs the matching mlx-bun verb with mlx_lm's argument
// spellings translated; the verb's own options stay accepted, so an alias is a
// superset of the mlx_lm command. Defaults, output locations (~/.mlx-bun) and
// behavior are the verb's; an explicit path behaves exactly as in mlx-lm.
// Flags mlx-bun cannot honor exit with an error naming the mlx_lm flag.
import { readFileSync } from "node:fs";
import { basename, dirname } from "node:path";
import { checkPositionals, commandOptions, help, type Command, type CommandArgs } from "./args";

type Value = string | boolean;
export type AliasValues = Record<string, Value | undefined>;

interface MlxLmFlag {
  kind: "string" | "boolean" | "list";
  /** Single-dash spelling, without the dash (`p` for -p, `qa` for -qa). */
  short?: string;
  /** The verb's option that receives the value (default: the same name). */
  to?: string;
  /** Accepted with no effect; the reason is shown in help. */
  ignored?: string;
  /** Not supported; the reason follows the error. */
  unsupported?: string;
  /** Custom translation of the parsed value into the verb's values. */
  set?(value: Value | string[], values: AliasValues): void;
}
interface Alias {
  verb: Command;
  /** mlx_lm's flags that need translation, refusal, or acceptance; every other mlx_lm flag is the verb's own option. */
  flags: Record<string, MlxLmFlag>;
  /** Final adjustments once every flag (and the config file) is applied. */
  finish?(values: AliasValues, given: ReadonlySet<string>): void;
}

const no = (kind: MlxLmFlag["kind"], unsupported: string, extra: Partial<MlxLmFlag> = {}): MlxLmFlag => ({ kind, unsupported, ...extra });
const trustRemoteCode: MlxLmFlag = { kind: "boolean", ignored: "mlx-bun never executes code from a model repository" };

const ONE_SHOT = "mlx-bun's one-shot generate has no such option";
const GENERATE: Alias = {
  verb: "generate",
  flags: {
    model: { kind: "string", to: "query" },
    "trust-remote-code": trustRemoteCode,
    prompt: { kind: "string", short: "p", set: (value, values) => {
      // mlx_lm.generate reads the escapes \n and \t as characters; `-` (stdin) passes through.
      values.prompt = String(value).replaceAll("\\n", "\n").replaceAll("\\t", "\t");
    } },
    "max-tokens": { kind: "string", short: "m" },
    "ignore-chat-template": { kind: "boolean", to: "raw" },
    verbose: { kind: "string", ignored: "mlx-bun prints only the generated text" },
    "kv-bits": { kind: "string", set: (value, values) => {
      if (value !== "4" && value !== "8") throw new Error(`--kv-bits ${value}: mlx-bun's affine KV cache supports 4 or 8 bits`);
      values["kv-quant"] = value;
      // mlx_lm starts quantizing at token 5000 unless told otherwise; mlx-bun's own --kv-quant starts at 0.
      values["quantized-kv-start"] ??= "5000";
    } },
    "kv-group-size": { kind: "string", set: value => {
      if (value !== "64") throw new Error(`--kv-group-size ${value}: mlx-bun's affine KV cache uses group size 64`);
    } },
    "extra-eos-token": no("list", "the model's own end-of-sequence tokens stop generation"),
    "prefill-response": no("string", ONE_SHOT),
    "use-default-chat-template": no("boolean", "the model's own chat template is always used"),
    "chat-template-config": no("string", "chat template arguments are not configurable here"),
    "max-kv-size": no("string", "mlx-bun has no rotating KV size cap flag"),
    "prompt-cache-file": no("string", "saved prompt caches are not supported; `serve` caches prompts itself"),
    "quantize-activations": no("boolean", "activation quantization is not supported", { short: "qa" }),
    "draft-model": no("string", "speculative decoding runs in `serve` (--draft-model)"),
    "num-draft-tokens": no("string", "speculative decoding runs in `serve` (--num-draft-tokens)"),
  },
};

const SERVE: Alias = {
  verb: "serve",
  flags: {
    "trust-remote-code": trustRemoteCode,
    "allowed-origins": no("string", "CORS origins are not configurable"),
    "log-level": no("string", "the server has no log-level switch"),
    "chat-template": no("string", "the model's own chat template is always used"),
    "use-default-chat-template": no("boolean", "the model's own chat template is always used"),
    "chat-template-args": no("string", "send chat_template_kwargs with the request instead"),
    "min-p": no("string", "send min_p with the request instead"),
    "prompt-concurrency": no("string", "the scheduler decides how prompts join; --batch sets the capacity"),
    "prefill-step-size": no("string", "prefill chunking is not configurable"),
    "prompt-cache-size": no("string", "use --prompt-cache (GiB)"),
    "prompt-cache-bytes": no("string", "use --prompt-cache (GiB)"),
    pipeline: no("boolean", "distributed pipelining is not supported"),
  },
  // mlx_lm.server is headless; the web app is mlx-bun's addition, opened only on request.
  finish: (values, given) => { if (!given.has("no-open")) values["no-open"] = true; },
};

const CONVERT: Alias = { verb: "convert", flags: { "trust-remote-code": trustRemoteCode } };
const FUSE: Alias = { verb: "fuse", flags: {} };
const UPLOAD: Alias = { verb: "upload", flags: {} };

const LORA_UNSUPPORTED = (what: string) => `${what} is not supported by mlx-bun's LoRA trainer`;
const LORA: Alias = {
  verb: "train",
  flags: {
    model: { kind: "string", to: "query" },
    train: { kind: "boolean" },
    test: no("boolean", "test-set evaluation is not supported"),
    "test-batches": no("string", "test-set evaluation is not supported"),
    "fine-tune-type": { kind: "string", set: value => {
      if (value === "dora" || value === "full") throw new Error(`--fine-tune-type ${value}: ${LORA_UNSUPPORTED(value)}; only lora`);
      if (value !== "lora") throw new Error(`--fine-tune-type: invalid choice: '${value}' (choose from lora, dora, full)`);
    } },
    optimizer: { kind: "string", set: (value, values) => {
      // mlx.optimizers.Adam has no weight decay; AdamW (mlx-bun's optimizer) defaults to 0.01.
      if (value === "adam") values["optimizer-adam"] = true;
      else if (value !== "adamw") throw new Error(`--optimizer ${value}: only adam and adamw are supported`);
    } },
    "mask-prompt": { kind: "boolean", ignored: "mlx-bun's SFT always masks the prompt (loss on the response only)" },
    "batch-size": { kind: "string", to: "batch" },
    "val-batches": { kind: "string", set: (value, values) => { values["val-batches"] = String(value); } },
    "learning-rate": { kind: "string", to: "lr" },
    "grad-accumulation-steps": { kind: "string", to: "grad-accum" },
    "resume-adapter-file": { kind: "string", set: (value, values) => {
      // mlx-bun resumes from an adapter directory; mlx-lm names the weights file in it.
      const path = String(value);
      values.resume = path.endsWith(".safetensors") ? dirname(path) : path;
    } },
    "adapter-path": { kind: "string", to: "adapter" },
    "max-seq-length": { kind: "string", to: "seq" },
    config: { kind: "string", short: "c", set: (value, values) => { values["config-file"] = String(value); } },
    "clear-cache-threshold": no("string", "the allocator cache policy is not configurable"),
    "report-to": no("string", "experiment reporting is not supported"),
    "project-name": no("string", "experiment reporting is not supported"),
  },
  finish: (values, given) => {
    if (values.method === undefined) values.method = "sft"; // mlx_lm.lora is supervised fine-tuning
    if (values["optimizer-adam"] && !given.has("weight-decay")) values["weight-decay"] = "0";
    delete values["optimizer-adam"];
    const batches = values["val-batches"];
    if (typeof batches === "string") {
      // mlx-lm counts validation batches; mlx-bun caps validation examples.
      const n = Number(batches), size = Number(values.batch ?? 1);
      values["val-size"] = String(n < 0 ? Number.MAX_SAFE_INTEGER : n * size);
      delete values["val-batches"];
    }
    if (values.train !== true) throw new Error("Must provide --train (mlx-bun's LoRA trainer has no --test-only mode)");
    delete values.train;
  },
};

/** mlx_lm.lora's YAML config keys that are not plain flag spellings. */
const LORA_CONFIG_UNSUPPORTED = ["lr_schedule"];

export const ALIASES: Record<string, Alias> = { server: SERVE, generate: GENERATE, convert: CONVERT, fuse: FUSE, lora: LORA, upload: UPLOAD };

/** mlx-lm's other console scripts (0.31.3): no mlx-bun counterpart, so no alias. */
export const ALIAS_GAPS: Record<string, string> = {
  chat: "no interactive terminal chat; use the web app (`mlx-bun`) or `mlx-bun.server`",
  benchmark: "no benchmark verb; the repository's scripts/bench-serve.ts measures a running server",
  cache_prompt: "no saved prompt-cache files; `serve` keeps its own prompt cache",
  evaluate: "no lm-evaluation-harness runner; the repository's scripts/eval-serve.ts scores a running server",
  perplexity: "no perplexity verb",
  manage: "no cache-management verb with mlx_lm.manage's semantics; see `mlx-bun ls` and `mlx-bun gc`",
  share: "no distributed file sharing",
  awq: "no AWQ quantization; `mlx-bun convert --target-bpw` is the mixed-precision path",
  dwq: "no DWQ quantization; `mlx-bun convert --target-bpw` is the mixed-precision path",
  dynamic_quant: "no dynamic quantization; `mlx-bun convert --target-bpw` is the mixed-precision path",
  gptq: "no GPTQ quantization; `mlx-bun convert --target-bpw` is the mixed-precision path",
};

const PREFIX = "mlx-bun.";

/** The alias an invocation asked for, from the name the command was started as:
 * the executable's own name in the standalone binary, the launcher file's name
 * (bin/mlx-bun.<cmd>.mjs) when run from source. Null for plain `mlx-bun`. */
export function invokedAlias(input: { argv0?: string; argv1?: string; main?: string } = {}): string | null {
  const main = input.main ?? Bun.main;
  const name = basename(main.startsWith("/$bunfs/") ? input.argv0 ?? process.argv0 : input.argv1 ?? process.argv[1] ?? "").replace(/\.mjs$/, "");
  return name.startsWith(PREFIX) ? name.slice(PREFIX.length) : null;
}

const NEGATIVE_NUMBER = /^-(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?$/;
const looksLikeFlag = (token: string) => token.startsWith("-") && token !== "-" && !NEGATIVE_NUMBER.test(token);

export type AliasResult = { help: string } | { command: Command; parsed: CommandArgs };

function requireAlias(name: string): Alias {
  const alias = Object.hasOwn(ALIASES, name) ? ALIASES[name] : undefined;
  if (alias) return alias;
  const gap = Object.hasOwn(ALIAS_GAPS, name) ? ALIAS_GAPS[name] : undefined;
  throw new Error(gap ? `${PREFIX}${name}: mlx_lm.${name} has no mlx-bun counterpart (${gap})`
    : `${PREFIX}${name}: unknown mlx-lm alias; available: ${Object.keys(ALIASES).map(key => PREFIX + key).join(", ")}`);
}

/** Translate `mlx-bun.<name> <argv>`: mlx_lm's spellings first, then the verb's own options. */
export function translateAlias(name: string, argv: string[], readConfig: (path: string) => unknown = readYaml): AliasResult {
  const alias = requireAlias(name), tag = `${PREFIX}${name}`;
  if (argv.includes("--help") || argv.includes("-h")) return { help: aliasHelp(name) };
  const own = commandOptions(alias.verb);
  const lookup = (token: string): { key: string; flag: MlxLmFlag } | undefined => {
    const long = token.startsWith("--");
    const bare = token.slice(long ? 2 : 1);
    if (long) {
      const mapped = alias.flags[bare];
      if (mapped) return { key: bare, flag: mapped };
      const option = own[bare];
      return option ? { key: bare, flag: { kind: option.type } } : undefined;
    }
    for (const [key, flag] of Object.entries(alias.flags)) if (flag.short === bare) return { key, flag };
    for (const [key, option] of Object.entries(own)) if (option.short === bare) return { key, flag: { kind: option.type } };
    return undefined;
  };

  const values: AliasValues = {}, given = new Set<string>(), positionals: string[] = [];
  /** A translation's own refusal reads as the alias's. */
  const tagged = <T>(work: () => T): T => {
    try { return work(); }
    catch (error) { throw new Error(error instanceof Error && !error.message.startsWith(tag) ? `${tag}: ${error.message}` : String(error)); }
  };
  const apply = (key: string, flag: MlxLmFlag, value: Value | string[]) => {
    if (flag.unsupported) throw new Error(`${tag}: --${key} is an mlx_lm.${name} option mlx-bun does not support: ${flag.unsupported}`);
    given.add(flag.to ?? key);
    if (flag.ignored) return;
    if (flag.set) return tagged(() => flag.set!(value, values));
    values[flag.to ?? key] = Array.isArray(value) ? value.join(" ") : value;
  };
  for (let index = 0; index < argv.length; index++) {
    const token = argv[index]!;
    if (token === "--") { positionals.push(...argv.slice(index + 1)); break; }
    if (!looksLikeFlag(token)) { positionals.push(token); continue; }
    const equals = token.startsWith("--") ? token.indexOf("=") : -1;
    const spelled = equals === -1 ? token : token.slice(0, equals);
    const found = lookup(spelled);
    if (!found) throw new Error(`${tag}: unrecognized argument: ${spelled}`);
    const { key, flag } = found;
    if (flag.kind === "boolean") {
      if (equals !== -1) throw new Error(`${tag}: argument ${spelled}: ignored explicit argument '${token.slice(equals + 1)}'`);
      apply(key, flag, true);
    } else if (flag.kind === "list") {
      const items: string[] = equals === -1 ? [] : [token.slice(equals + 1)];
      while (equals === -1 && index + 1 < argv.length && !looksLikeFlag(argv[index + 1]!)) items.push(argv[++index]!);
      if (!items.length) throw new Error(`${tag}: argument ${spelled}: expected at least one argument`);
      apply(key, flag, items);
    } else {
      const next = equals === -1 ? argv[index + 1] : token.slice(equals + 1);
      if (next === undefined || (equals === -1 && looksLikeFlag(next))) throw new Error(`${tag}: argument ${spelled}: expected one argument`);
      if (equals === -1) index++;
      apply(key, flag, next);
    }
  }
  if (name === "lora" && values["config-file"] !== undefined) applyLoraConfig(values, given, String(values["config-file"]), readConfig, tag, lookup, apply);
  delete values["config-file"];
  tagged(() => alias.finish?.(values, given));
  // Positionals belong to the verb (`generate [query] [prompt]`); mlx_lm's commands take none.
  const parsed: CommandArgs = { values, positionals };
  checkPositionals(alias.verb, parsed);
  return { command: alias.verb, parsed };
}

function readYaml(path: string): unknown { return Bun.YAML.parse(readFileSync(path, "utf8")); }

/** mlx_lm.lora's `-c/--config`: the file's keys are the flags' names with underscores; a flag on the command line wins. */
function applyLoraConfig(values: AliasValues, given: Set<string>, path: string, read: (path: string) => unknown, tag: string,
  lookup: (token: string) => { key: string; flag: MlxLmFlag } | undefined, apply: (key: string, flag: MlxLmFlag, value: Value | string[]) => void): void {
  let config: unknown;
  try { config = read(path); }
  catch (error) { throw new Error(`${tag}: cannot read config ${path}: ${error instanceof Error ? error.message : String(error)}`); }
  if (config === null || typeof config !== "object" || Array.isArray(config)) throw new Error(`${tag}: config ${path} must be a YAML mapping`);
  const entries = config as Record<string, unknown>;
  const set = (name: string, value: unknown) => {
    if (value === null || value === undefined) return;
    const found = lookup(`--${name}`);
    if (!found) throw new Error(`${tag}: config ${path}: unrecognized key ${name.replaceAll("-", "_")}`);
    if (given.has(found.flag.to ?? found.key)) return; // the command line wins
    if (found.flag.kind === "boolean") { if (value === true) apply(found.key, found.flag, true); return; }
    apply(found.key, found.flag, String(value));
  };
  for (const [rawKey, value] of Object.entries(entries)) {
    const key = rawKey.replaceAll("_", "-");
    if (LORA_CONFIG_UNSUPPORTED.includes(rawKey) && value !== null) throw new Error(`${tag}: config ${path}: ${rawKey} is not supported`);
    if (rawKey === "lora_parameters") {
      const parameters = value as Record<string, unknown> | null;
      for (const [parameter, parameterValue] of Object.entries(parameters ?? {})) {
        if (parameterValue === null) continue;
        if (!["rank", "scale", "dropout"].includes(parameter)) throw new Error(`${tag}: config ${path}: lora_parameters.${parameter} is not supported`);
        set(parameter, parameterValue);
      }
    } else if (rawKey === "optimizer_config") {
      const chosen = (value as Record<string, Record<string, unknown> | null> | null)?.[String(entries.optimizer ?? "adam")];
      for (const [option, optionValue] of Object.entries(chosen ?? {})) {
        if (optionValue === null) continue;
        if (option !== "weight_decay") throw new Error(`${tag}: config ${path}: optimizer_config.${option} is not supported`);
        set("weight-decay", optionValue);
      }
    } else set(key, value);
  }
}

/** `mlx-bun.<cmd> --help`: what the alias translates, then the verb's own help. */
export function aliasHelp(name: string): string {
  const alias = requireAlias(name), verb = alias.verb;
  const group = (pick: (flag: MlxLmFlag) => string | undefined) => Object.entries(alias.flags)
    .flatMap(([key, flag]) => { const detail = pick(flag); return detail === undefined ? [] : [`  ${flag.short ? `-${flag.short}, ` : ""}--${key}${detail ? `  ${detail}` : ""}`]; });
  const mapped = group(flag => flag.to ? `→ --${flag.to}` : flag.set && !flag.ignored && !flag.unsupported ? "(translated)" : undefined);
  const ignored = group(flag => flag.ignored);
  const unsupported = group(flag => flag.unsupported);
  const section = (title: string, rows: string[]) => rows.length ? `\n${title}:\n${rows.join("\n")}\n` : "";
  return `${PREFIX}${name} — mlx_lm.${name}-compatible alias of \`mlx-bun ${verb}\`\n\nUsage: ${PREFIX}${name} [options]\n\n` +
    `Accepts mlx_lm.${name}'s arguments and every \`mlx-bun ${verb}\` option. Defaults and output locations (~/.mlx-bun) are\n` +
    `mlx-bun's; an explicit path behaves as in mlx-lm.\n` +
    section("mlx_lm spellings mapped", mapped) + section("Accepted, no effect", ignored) + section("mlx_lm options not supported", unsupported) +
    `\nOptions of \`mlx-bun ${verb}\`:\n${help(verb).split("\nOptions:\n")[1]}`;
}
