// Parsing and help for CLI verbs a module declares. A verb's manifest is data,
// so a host builds argument parsing, `--help` and its command list from it
// without activating the module. The rules match the built-in verbs': strict
// options, a usage line for a missing required positional or a valueless
// option, and no more positionals than declared.
import { parseArgs } from "node:util";
import type { CliInvocation, CliOptionSpec, CliVerbSpec } from "@mlx-bun/app-core";

export type VerbArguments = Pick<CliInvocation, "values" | "positionals">;

/** `<audio-file> [query]`: required positionals in angle brackets, optional in square ones. */
export function positionalUsage(spec: CliVerbSpec): string {
  return (spec.positional ?? []).map(item => {
    const name = item.repeatable ? `${item.name}...` : item.name;
    return item.required ? `<${name}>` : `[${name}]`;
  }).join(" ");
}

export function verbUsage(program: string, spec: CliVerbSpec): string {
  return spec.usage ?? `usage: ${program} ${spec.name} ${positionalUsage(spec)}`.trimEnd();
}

const isValue = (option: CliOptionSpec) => option.type !== "boolean";

/** Parse argv against a verb's declared options and positionals. */
export function parseVerb(program: string, spec: CliVerbSpec, argv: readonly string[]): VerbArguments {
  const rest = [...argv];
  // A flag with an optional value (`--hotkey [keycode]`): the next token is its value unless it looks like a flag.
  const optional = new Map<string, unknown>();
  for (const option of spec.options.filter(item => item.optionalValue)) {
    const at = rest.findIndex(arg => arg === `--${option.name}` || arg.startsWith(`--${option.name}=`));
    if (at < 0) continue;
    const flag = rest.splice(at, 1)[0]!;
    let raw = flag.includes("=") ? flag.slice(flag.indexOf("=") + 1) : undefined;
    if (raw === undefined && rest[at] !== undefined && !rest[at]!.startsWith("-")) raw = rest.splice(at, 1)[0];
    optional.set(option.name, option.type === "number" ? Number(raw ?? option.default) || option.default : raw ?? option.default);
  }
  const table = Object.fromEntries(spec.options.filter(item => !item.optionalValue).map(option =>
    [option.name, { type: option.type === "boolean" ? "boolean" as const : "string" as const, ...(option.repeatable ? { multiple: true } : {}),
      ...(option.short ? { short: option.short } : {}) }]));
  let parsed: ReturnType<typeof parseArgs>;
  try { parsed = parseArgs({ args: rest, options: table, allowPositionals: true, strict: true }); }
  catch (error) {
    if ((error as { code?: string }).code === "ERR_PARSE_ARGS_INVALID_OPTION_VALUE") {
      const named = spec.options.find(option => option.missingValue && String((error as Error).message).includes(`'--${option.name}`));
      if (named) throw new Error(named.missingValue);
      if (spec.usage) throw new Error(spec.usage);
    }
    throw error;
  }
  const raw: Record<string, unknown> = {};
  for (const option of spec.options) {
    const value = optional.has(option.name) ? optional.get(option.name) : (parsed.values as Record<string, unknown>)[option.name];
    if (value !== undefined) raw[option.name] = value;
  }
  return verbArguments(program, spec, raw, parsed.positionals);
}

/** Check already-parsed values and positionals against a verb's manifest: the same positional rules and number coercion as `parseVerb`.
 * A host that translates another spelling of the verb (`mlx-bun.convert`) reaches the verb through this. */
export function verbArguments(program: string, spec: CliVerbSpec, raw: Readonly<Record<string, unknown>>, positionals: readonly string[]): VerbArguments {
  const declared = spec.positional ?? [];
  const max = declared.some(item => item.repeatable) ? Infinity : declared.length;
  if (positionals.length > max) throw new Error(`Too many arguments for ${spec.name}`);
  if (declared.some(item => item.required) && positionals.length < declared.filter(item => item.required).length) throw new Error(verbUsage(program, spec));
  const values: Record<string, string | number | boolean | readonly string[] | undefined> = {};
  for (const option of spec.options) {
    const value = raw[option.name];
    if (value === undefined) continue;
    if (option.type === "number" && typeof value === "string") {
      const number = Number(value);
      if (!value.trim() || !Number.isFinite(number)) throw new Error(`invalid --${option.name}: ${value}`);
      values[option.name] = number;
    } else values[option.name] = value as string | number | boolean | readonly string[];
  }
  return { values, positionals: [...positionals] };
}

/** The verb's `--help`: a description, usage, and one row per option. */
export function verbHelp(program: string, spec: CliVerbSpec): string {
  const positional = positionalUsage(spec);
  const rows = spec.options.map(option => {
    const flag = (option.short ? `-${option.short}, ` : "") + `--${option.name}` + (isValue(option) ? " <value>" : "");
    return `  ${flag.padEnd(24)} ${option.summary}`;
  });
  return `${program} ${spec.name} — ${spec.summary}\n\nUsage: ${program} ${spec.name}${positional ? ` ${positional}` : ""} [options]\n${spec.details ? `\n${spec.details}\n` : ""}\nOptions:\n${rows.join("\n")}\n  -h, --help               Show help`;
}
