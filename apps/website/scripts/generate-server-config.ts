import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import ts from "typescript";
import { sourceRevision } from "./generate-library-api";
import { CLI_SOURCE, commandReference } from "./generate-reference";

const root = resolve(import.meta.dir, "../../..");
export const SERVER_CONFIG_PAGE = "src/content/docs/reference/server-config.md";
const APP = "apps/mlx-bun/src/", SERVE = `${APP}cli/serve.ts`, RUNTIME = "packages/inference/src/runtime/config.ts";
const GLOBS = [`${APP}**/*.ts`, "packages/*/src/**/*.ts"], KEY = /^MLX_BUN_[A-Z0-9_]+$/, K = ts.SyntaxKind;
const READERS = new Map<string, How>([["runtimeValue", "value"], ["runtimeFlag", "flag"], ["runtimeNumber", "number"]]);
/** Receivers of the RuntimeConfig methods, by name: a non-literal key there fails. */
const RUNTIME_RECEIVERS = new Set(["runtime", "#runtime", "runtimeConfig()"]), ENV = new Set(["process.env", "Bun.env"]);

/** Native library paths resolve before a runtime snapshot exists, so these read
 * the environment directly. A listed site that disappears fails too. */
export const DIRECT_ENV_READS = [
  { file: "packages/mlx/src/native.ts", key: "MLX_BUN_LIBMLXC" },
  { file: "packages/inference/src/runtime/native.ts", key: "MLX_BUN_EXPERT_IO_DYLIB" },
  { file: "packages/inference/src/runtime/native.ts", key: "MLX_BUN_FRAME_EXTRACT" },
];
/** Only what the code cannot say. Each named key or serve flag must still exist. */
export const NOTES: readonly { names: string[]; text: string }[] = [
  { names: ["MLX_BUN_NO_FUSED_SDPA", "--kv-quant"], text: "`serve` and `generate` write `0` when `--kv-quant` is `config` and `1` otherwise, replacing the environment's value (`generate` for its own run only); `1` turns off the fused quantized-KV attention tiles." },
  { names: ["MLX_BUN_RD_PREFILL_CHUNK"], text: "Unset, the model's prefill policy picks the chunk: 2048 tokens, halved for linear-attention models at long context to bound the attention workspace. The `2048` shown for its `number` read applies only to a set, non-numeric value." },
  { names: ["--prompt-cache"], text: "`--prompt-cache` is in GiB (N × 2^30 bytes), but the cap without it is 8e9 bytes (decimal 8 GB, about 7.45 GiB)." },
  { names: ["MLX_BUN_PAGED_KV", "--paged-kv"], text: "`--paged-kv` or `MLX_BUN_PAGED_KV=1` turns paging on; no flag turns an environment `1` off, and either satisfies `--paged-kv-block-size`." },
  { names: ["MLX_BUN_FILL_TRACE"], text: "`1` turns fill tracing on. Any other value except empty, `0`, and `true` is a JSONL file path and also turns it on; `true` turns on neither." },
];

type How = "value" | "flag" | "number" | "process.env";
export interface ReadSite { key: string; how: How; fallback?: string; file: string; line: number }
export interface WriteSite { key: string; flag?: string; file: string; line: number }
export interface ServeFact { flag: string; fallback?: string; accepts?: string; file: string; line: number }
export interface ConfigInventory { serve: ServeFact[]; reads: ReadSite[]; writes: WriteSite[] }

const skip = (e: ts.Expression): ts.Expression => ts.isParenthesizedExpression(e) || ts.isAsExpression(e) || ts.isNonNullExpression(e) ? skip(e.expression) : e;
const code = (node: ts.Node) => node.getText().replace(/\s+/g, " ");
function find<T extends ts.Node>(node: ts.Node, test: (node: ts.Node) => node is T, found: T[] = []): T[] {
  ts.forEachChild(node, child => { if (test(child)) found.push(child); find(child, test, found); });
  return found;
}
function where(node: ts.Node) { const file = node.getSourceFile(); return { file: file.fileName, line: file.getLineAndCharacterOfPosition(node.getStart(file)).line + 1 }; }
function fail(node: ts.Node, message: string): never { const { file, line } = where(node); throw new Error(`${file}:${line}: ${message}`); }
const receiverName = (e: ts.Expression) => ts.isCallExpression(e) ? `${e.expression.getText()}()` : ts.isPropertyAccessExpression(e) ? e.name.text : e.getText();
const literal = (e: ts.Node | undefined) => e && (ts.isStringLiteralLike(e) || ts.isNumericLiteral(e) || (ts.isPrefixUnaryExpression(e) && ts.isNumericLiteral(e.operand))) ? (ts.isStringLiteralLike(e) ? e.text : e.getText()) : undefined;
/** The outermost `a ?? b ?? …` chain above node: its last operand is the fallback. */
function nullish(node: ts.Node): ts.BinaryExpression | undefined {
  let top: ts.BinaryExpression | undefined;
  for (let n = node.parent; ts.isParenthesizedExpression(n) || (ts.isBinaryExpression(n) && n.operatorToken.kind === K.QuestionQuestionToken); n = n.parent)
    if (ts.isBinaryExpression(n)) top = n;
  return top;
}

/** The read site's own fallback: a flag or number literal, `?? literal`, or one string comparison. */
function fallback(read: ts.CallExpression, how: How): string | undefined {
  const second = read.arguments[1], quote = (text?: string) => text === undefined ? undefined : `\`${text}\``;
  if (how === "flag") return second?.kind === K.TrueKeyword ? "on" : second?.kind === K.FalseKeyword ? "off" : undefined;
  if (how === "number") return quote(literal(second));
  let node: ts.Node = read;
  while (ts.isParenthesizedExpression(node.parent) || ts.isNonNullExpression(node.parent)) node = node.parent;
  const parent = node.parent;
  if (!ts.isBinaryExpression(parent)) return undefined;
  const op = parent.operatorToken.kind, other = parent.left === node ? parent.right : parent.left;
  if (op === K.QuestionQuestionToken) return parent.left === node ? quote(literal(other)) : undefined;
  return (op === K.EqualsEqualsEqualsToken || op === K.ExclamationEqualsEqualsToken) && ts.isStringLiteralLike(other) ? `unset (only \`${other.text}\` changes it)` : undefined;
}

/** `configureRuntime({ KEY: … options.field … })`: the serve flag named by the option it derives from. */
function serveFlag(property: ts.PropertyAssignment, call: ts.Node, flags: Map<string, unknown>): string {
  const inputs: ts.Node[] = [property.initializer];
  for (let n: ts.Node = property; n !== call; n = n.parent) if (ts.isConditionalExpression(n)) inputs.push(n.condition);
  const option = inputs.flatMap(e => [e, ...find(e, ts.isPropertyAccessExpression)]).find((e): e is ts.PropertyAccessExpression => ts.isPropertyAccessExpression(e) && e.getText().startsWith("options."));
  const flag = option?.name.text.replace(/[A-Z]/g, c => `-${c.toLowerCase()}`);
  return flag && flags.has(flag) ? flag : fail(property, `${property.name.getText()} is written from \`${code(option ?? property)}\`, which names no serve flag`);
}

/** What parseServeOptions knows: literal `??` defaults, `number(name, lo, hi)` ranges, and `!list.includes(read)` values. */
function serveFacts(file: ts.SourceFile, help: Map<string, string | undefined>): ServeFact[] {
  const fn = file.statements.find((s): s is ts.FunctionDeclaration => ts.isFunctionDeclaration(s) && s.name?.text === "parseServeOptions");
  if (!fn?.body) throw new Error(`${SERVE}: parseServeOptions was not found`);
  const decls = find(fn.body, ts.isVariableDeclaration), local = (name: string) => decls.find(d => d.name.getText() === name)?.initializer;
  const number = local("number");
  if (!number || !ts.isArrowFunction(number) || !local("value")) return fail(fn, "parseServeOptions needs its local value and number readers");
  const [lo, hi] = number.parameters.slice(1, 3).map(p => p.initializer?.getText());
  const facts = new Map<string, ServeFact>(), fact = (flag: string, node: ts.Node) => facts.get(flag) ?? facts.set(flag, { flag, ...where(node) }).get(flag)!;
  const reads: ts.CallExpression[] = [], helpers = find(fn.body, ts.isArrowFunction);
  for (const call of find(fn.body, (n): n is ts.CallExpression => ts.isCallExpression(n) && ["value", "number"].includes(n.expression.getText()))) {
    const arg = call.arguments[0];
    // The helpers forward their own parameter: `const raw = value(name)`.
    if (arg && ts.isIdentifier(arg) && helpers.some(f => f.parameters.some(p => p.name.getText() === arg.text) && call.pos >= f.pos && call.end <= f.end)) continue;
    if (!arg || !ts.isStringLiteralLike(arg)) return fail(call, `serve flag name must be a literal in \`${code(call)}\``);
    if (!help.has(arg.text)) fail(arg, `--${arg.text} is not a serve option`);
    reads.push(call);
    const f = fact(arg.text, call), top = nullish(call), text = top && literal(skip(top.right));
    if (text !== undefined) f.fallback = text;
    if (call.expression.getText() !== "number") continue;
    const [min = lo, max = hi, integer] = call.arguments.slice(1).map(a => ts.isNumericLiteral(a) ? a.text : a.getText());
    f.accepts = `${integer === "true" ? "integer" : "number"} ${/^(Infinity|Number\.MAX_SAFE_INTEGER)$/.test(max ?? "") ? `≥ ${min}` : `in [${min}, ${max}]`}`;
  }
  for (const not of find(fn.body, ts.isPrefixUnaryExpression)) {
    const call = not.operator === K.ExclamationToken ? skip(not.operand) : undefined;
    if (!call || !ts.isCallExpression(call) || !ts.isPropertyAccessExpression(call.expression) || call.expression.name.text !== "includes") continue;
    const list = skip(call.expression.expression), values = ts.isIdentifier(list) ? local(list.text) : list, subject = call.arguments[0] && skip(call.arguments[0]);
    const init = subject && ts.isIdentifier(subject) ? local(subject.text) : undefined, read = init && reads.find(r => r.pos >= init.pos && r.end <= init.end);
    if (!values || !ts.isArrayLiteralExpression(values) || !values.elements.every(ts.isStringLiteralLike) || !read) return fail(not, `unsupported allowed-values check \`${code(not)}\``);
    fact((read.arguments[0] as ts.StringLiteralLike).text, read).accepts = values.elements.map(e => `\`${(e as ts.StringLiteralLike).text}\``).join(" \\| ");
  }
  for (const f of facts.values()) if (help.get(f.flag) !== undefined && f.fallback !== undefined && help.get(f.flag) !== f.fallback)
    throw new Error(`${f.file}:${f.line}: --${f.flag} help says [default: ${help.get(f.flag)}] but the parser defaults to ${f.fallback}`);
  return [...facts.values()].filter(f => f.fallback !== undefined || f.accepts);
}

/** Parse the sources without running them. Fails on a key form it cannot inventory. */
export function configInventory(sources: ReadonlyMap<string, string>): ConfigInventory {
  const serve = commandReference(sources.get(CLI_SOURCE) ?? "").find(c => c.name === "serve");
  if (!serve) throw new Error(`${CLI_SOURCE}: the serve command was not found`);
  const help = new Map(serve.options.map(o => [o.name, /\[default: ([^\];]+)/.exec(o.description)?.[1]]));
  const reads: ReadSite[] = [], writes: WriteSite[] = [], files = [...sources].map(([path, text]) => ts.createSourceFile(path, text, ts.ScriptTarget.Latest, true, ts.ScriptKind.TS));
  for (const file of files) {
  // A reader imported under another name (`import { runtimeValue as value }`) reads like the reader.
  const readers = new Map(READERS);
  for (const spec of find(file, ts.isImportSpecifier)) { const how = READERS.get((spec.propertyName ?? spec.name).text); if (how) readers.set(spec.name.text, how); }
  find(file, (n): n is ts.Node => true).forEach(node => {
    if (ts.isVariableDeclaration(node) && ts.isObjectBindingPattern(node.name) && node.initializer && ENV.has(code(skip(node.initializer)))) {
      for (const element of node.name.elements) {
        const name = element.propertyName ?? element.name;
        const key = element.dotDotDotToken ? undefined : ts.isIdentifier(name) || ts.isStringLiteralLike(name) ? name.text : ts.isComputedPropertyName(name) ? literal(name.expression) : undefined;
        if (key === undefined) fail(element, `computed environment read \`${code(node)}\`; use a literal key`);
        if (!KEY.test(key!)) continue;
        if (!DIRECT_ENV_READS.some(s => s.file === file.fileName && s.key === key)) fail(element, `direct environment read \`${code(node)}\`; read ${key} through ${RUNTIME}`);
        reads.push({ key: key!, how: "process.env", ...where(element) });
      }
    } else if ((ts.isPropertyAccessExpression(node) || ts.isElementAccessExpression(node)) && ENV.has(code(node.expression))) {
      const key = ts.isPropertyAccessExpression(node) ? node.name.text : literal(node.argumentExpression) ?? fail(node, `computed environment read \`${code(node)}\`; use a literal key`);
      if (!KEY.test(key)) return;
      if (!DIRECT_ENV_READS.some(s => s.file === file.fileName && s.key === key)) fail(node, `direct environment read \`${code(node)}\`; read ${key} through ${RUNTIME}`);
      reads.push({ key, how: "process.env", ...where(node) });
    } else if (ts.isCallExpression(node)) {
      const callee = node.expression, arg = node.arguments[0];
      // `runtimeConfig()["value"](…)` reads like `runtimeConfig().value(…)`; `config.runtimeValue(…)` like `runtimeValue(…)`.
      const member = ts.isPropertyAccessExpression(callee) ? callee.name.text : ts.isElementAccessExpression(callee) ? literal(callee.argumentExpression) : undefined;
      if (ts.isElementAccessExpression(callee) && member === undefined && RUNTIME_RECEIVERS.has(receiverName(skip(callee.expression))))
        fail(node, `computed runtime reader \`${code(node)}\`; call value, flag or number by name`);
      const how = ts.isIdentifier(callee) ? readers.get(callee.text) : member === undefined ? undefined
        : READERS.get(member) ?? (["value", "flag", "number"].includes(member) ? member as How : undefined);
      if (!how) return;
      if (arg && ts.isStringLiteralLike(arg)) { if (KEY.test(arg.text)) reads.push({ key: arg.text, how, fallback: fallback(node, how), ...where(node) }); return; }
      const receiver = ts.isPropertyAccessExpression(callee) || ts.isElementAccessExpression(callee) ? skip(callee.expression) : undefined;
      const named = !receiver || READERS.has(member!) || RUNTIME_RECEIVERS.has(receiverName(receiver));
      if (named && file.fileName !== RUNTIME) fail(node, `non-literal runtime key \`${code(node)}\`; pass a literal MLX_BUN_* key`);
    } else if (ts.isPropertyAssignment(node) && (ts.isIdentifier(node.name) || ts.isStringLiteral(node.name)) && KEY.test(node.name.text)) {
      let call: ts.Node | undefined = node.parent;
      while (call && !(ts.isCallExpression(call) && call.expression.getText() === "configureRuntime")) call = call.parent;
      writes.push({ key: node.name.text, ...(call ? { flag: serveFlag(node, call, help) } : {}), ...where(node) });
    }
  });
  }
  for (const site of DIRECT_ENV_READS) if (!reads.some(r => r.how === "process.env" && r.file === site.file && r.key === site.key))
    throw new Error(`${site.file}: the listed direct read of ${site.key} disappeared; update DIRECT_ENV_READS`);
  for (const name of NOTES.flatMap(n => n.names)) if (name.startsWith("--") ? !help.has(name.slice(2)) : !reads.some(r => r.key === name))
    throw new Error(`A configuration note names ${name}, which ${name.startsWith("--") ? "is not a serve flag" : "no source reads"}`);
  const order = (a: { file: string; line: number }, b: typeof a) => a.file.localeCompare(b.file) || a.line - b.line;
  const serveFile = files.find(f => f.fileName === SERVE) ?? (() => { throw new Error(`${SERVE} is missing`); })();
  return { serve: serveFacts(serveFile, help), reads: reads.sort((a, b) => a.key.localeCompare(b.key) || order(a, b)), writes: writes.sort(order) };
}

export async function configSources(repository = root): Promise<Map<string, string>> {
  const paths: string[] = [];
  for (const glob of GLOBS) for await (const path of new Bun.Glob(glob).scan(repository)) paths.push(path);
  return new Map(await Promise.all(paths.sort().map(async path => [path, await readFile(resolve(repository, path), "utf8")] as const)));
}

export function renderServerConfig(inventory: ConfigInventory, revision: string): string {
  const link = (file: string, line: number) => `[${file.replace(/^(apps\/mlx-bun|packages\/[^/]+)\/src\//, "")}:${line}](https://github.com/joshuarossi/mlx-bun/blob/${revision}/${file}#L${line})`;
  const noted = new Set(NOTES.flatMap(n => n.names)), set = new Map<string, string>();
  for (const w of inventory.writes) set.set(w.key, [set.get(w.key), w.flag ? `set by \`serve\` from \`--${w.flag}\` (${link(w.file, w.line)})` : `set at ${link(w.file, w.line)}`].filter(Boolean).join("; "));
  const table = (reads: ReadSite[]) => {
    const rows = new Map<string, { read: ReadSite; label: string; links: string[] }>();
    for (const read of reads) {
      const label = set.get(read.key) ?? read.fallback ?? "computed", id = `${read.key} ${read.how} ${label}`;
      rows.get(id)?.links.push(link(read.file, read.line)) ?? rows.set(id, { read, label, links: [link(read.file, read.line)] });
    }
    return `| Key | Read | Default | Source |\n| --- | --- | --- | --- |\n` + [...rows.values()].map(({ read, label, links }) =>
      `| \`${read.key}\`${noted.has(read.key) ? " ([note](#notes))" : ""} | ${read.how} | ${label} | ${links.join(", ")} |`).join("\n") + "\n";
  };
  const packages = [...new Set(inventory.reads.filter(r => !r.file.startsWith(APP)).map(r => r.file.split("/")[1]!))].sort();
  const page = `---\ntitle: Configuration reference\ndescription: Serve option checks and MLX_BUN_* runtime keys, generated from the application and library sources.\n---\n\n` +
    `Generated at build time from \`apps/mlx-bun/src\` and \`packages/*/src\` without running them; tests and scripts are not scanned. ` +
    `These are the refactor's current settings; released versions can differ.\n\n` +
    `**Read**: \`value\` is the raw string; \`flag\` treats \`1\` as on, \`0\` as off, and anything else as the default; \`number\` takes a finite number, else the fallback; ` +
    `\`process.env\` is read directly rather than through the runtime configuration. **Default** is the fallback at each read site, so a key read at several sites lists each; ` +
    `**computed** means the code at the source link decides.\n\n` +
    `## Serve options\n\nThe \`serve\` flags and their descriptions are in the [CLI reference](/reference/cli/#serve). ` +
    `This table adds what the parser enforces: literal defaults, numeric ranges, and accepted values.\n\n| Flag | Default | Accepts | Source |\n| --- | --- | --- | --- |\n` +
    inventory.serve.map(f => `| \`--${f.flag}\`${noted.has(`--${f.flag}`) ? " ([note](#notes))" : ""} | ${f.fallback === undefined ? "" : `\`${f.fallback}\``} | ${f.accepts ?? ""} | ${link(f.file, f.line)} |`).join("\n") + "\n\n" +
    `### Keys set by \`serve\`\n\nWhen \`serve\` starts a model host it writes these keys from its flags; a written value replaces the environment's.\n\n| Key | From | Source |\n| --- | --- | --- |\n` +
    inventory.writes.filter(w => w.flag).map(w => `| \`${w.key}\`${noted.has(w.key) ? " ([note](#notes))" : ""} | \`--${w.flag}\` | ${link(w.file, w.line)} |`).join("\n") + "\n\n" +
    `### App keys\n\n\`MLX_BUN_*\` keys read under \`apps/mlx-bun/src\`, including environment mirrors of flags.\n\n${table(inventory.reads.filter(r => r.file.startsWith(APP)))}\n` +
    `## Library tuning\n\nThese keys are library tuning and diagnostics, not app options; none is promoted to a flag. Grouped by the package that reads them.\n\n` +
    packages.map(name => `### @mlx-bun/${name}\n\n${table(inventory.reads.filter(r => r.file.startsWith(`packages/${name}/`)))}`).join("\n") +
    `\n## Notes\n\n${NOTES.map(n => `- ${n.names.map(name => `**\`${name}\`**`).join(", ")}: ${n.text}`).join("\n")}\n`;
  for (const key of new Set([...inventory.reads, ...inventory.writes].map(s => s.key))) if (!page.includes(`\`${key}\``)) throw new Error(`${key} was extracted but not rendered`);
  return page;
}

export async function generateServerConfig(options: { repository?: string; destination?: string; revision?: string } = {}): Promise<ConfigInventory> {
  const repository = options.repository ?? root, destination = options.destination ?? resolve(import.meta.dir, "..");
  const inventory = configInventory(await configSources(repository)), page = resolve(destination, SERVER_CONFIG_PAGE);
  await mkdir(dirname(page), { recursive: true });
  await writeFile(page, renderServerConfig(inventory, options.revision ?? sourceRevision(repository)));
  return inventory;
}

if (import.meta.main) {
  if (process.argv.includes("--help")) console.log(`Usage: bun scripts/generate-server-config.ts\nGenerate the configuration inventory from ${SERVE} and the MLX_BUN_* reads under ${GLOBS.join(" and ")} without running them.`);
  else {
    const { serve, reads } = await generateServerConfig(), keys = (app: boolean) => new Set(reads.filter(r => r.file.startsWith(APP) === app).map(r => r.key)).size;
    console.log(`Verified ${serve.length} serve options, ${keys(true)} app keys, and ${keys(false)} library keys.`);
  }
}
