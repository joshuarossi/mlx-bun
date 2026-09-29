import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import ts from "typescript";

const root = resolve(import.meta.dir, "../../..");
export const CLI_SOURCE = "apps/mlx-bun/src/cli/args.ts";
/** The one file that names the app's installed modules; their manifests declare their verbs. */
export const MODULES_SOURCE = "apps/mlx-bun/src/modules.ts";
export const INSTALLER_SOURCE = "scripts/install.sh";
export interface CommandReference {
  name: string;
  description: string;
  positional: string;
  options: { name: string; type: string; description: string; short?: string }[];
}

function object(expression: ts.Expression): ts.ObjectLiteralExpression {
  while (ts.isSatisfiesExpression(expression) || ts.isAsExpression(expression) || ts.isParenthesizedExpression(expression))
    expression = expression.expression;
  if (!ts.isObjectLiteralExpression(expression)) throw new Error("CLI reference needs a literal command table");
  return expression;
}
function properties(expression: ts.Expression): Map<string, ts.Expression> {
  return new Map(object(expression).properties.map(property => {
    if (!ts.isPropertyAssignment(property) || !(ts.isIdentifier(property.name) || ts.isStringLiteral(property.name)))
      throw new Error("Unsupported CLI table property; update the reference generator");
    return [property.name.text, property.initializer];
  }));
}
function literal(fields: Map<string, ts.Expression>, key: string): string {
  const value = fields.get(key);
  if (!value || !ts.isStringLiteralLike(value)) throw new Error(`CLI reference needs a string ${key}`);
  return value.text;
}

/** Read syntax, never execute the app or import its native dependencies. Fail
 * on a changed table shape rather than quietly omit an unsupported entry. */
export function commandReference(source: string): CommandReference[] {
  const file = ts.createSourceFile(CLI_SOURCE, source, ts.ScriptTarget.Latest, true);
  let table: ts.Expression | undefined;
  for (const statement of file.statements) if (ts.isVariableStatement(statement)) {
    for (const declaration of statement.declarationList.declarations)
      if (ts.isIdentifier(declaration.name) && declaration.name.text === "commands") table = declaration.initializer;
  }
  if (!table) throw new Error("CLI command table was not found");
  return [...properties(table)].map(([name, expression]) => {
    const fields = properties(expression), options = fields.get("options");
    if (!options) throw new Error(`CLI command ${name} has no options`);
    return { name, description: literal(fields, "description"), positional: literal(fields, "positional"),
      options: [...properties(options)].map(([name, option]) => {
        const fields = properties(option);
        return { name, type: literal(fields, "type"), description: literal(fields, "description"),
          ...(fields.has("short") ? { short: literal(fields, "short") } : {}) };
      }) };
  });
}

/** A manifest's verbs as command entries. `number` options render like `string` ones: both take a value; a `short` spelling is listed. */
export function moduleCommandReference(source: string, path: string): CommandReference[] {
  const file = ts.createSourceFile(path, source, ts.ScriptTarget.Latest, true);
  let manifest: ts.Expression | undefined;
  for (const statement of file.statements) if (ts.isVariableStatement(statement)) {
    for (const declaration of statement.declarationList.declarations)
      if (ts.isIdentifier(declaration.name) && declaration.name.text === "manifest") manifest = declaration.initializer;
  }
  if (!manifest) throw new Error(`${path}: the module manifest was not found`);
  const list = (fields: Map<string, ts.Expression>, key: string): ts.Expression[] => {
    let value = fields.get(key);
    if (!value) return [];
    while (ts.isSatisfiesExpression(value) || ts.isAsExpression(value) || ts.isParenthesizedExpression(value)) value = value.expression;
    if (!ts.isArrayLiteralExpression(value)) throw new Error(`${path}: manifest ${key} must be a literal array`);
    return [...value.elements];
  };
  return list(properties(manifest), "verbs").map(verb => {
    const fields = properties(verb), name = literal(fields, "name");
    const positional = list(fields, "positional").map(item => { const parts = properties(item); return { name: literal(parts, "name"), required: parts.get("required")?.getText() === "true" }; });
    return { name, description: literal(fields, "summary"), positional: positional.map(item => item.required ? `<${item.name}>` : `[${item.name}]`).join(" "),
      options: list(fields, "options").map(option => {
        const parts = properties(option), type = literal(parts, "type");
        return { name: literal(parts, "name"), type: type === "number" ? "string" : type, description: literal(parts, "summary"),
          ...(parts.has("short") ? { short: literal(parts, "short") } : {}) };
      }) };
  });
}

/** The manifest source of each module the app installs: `modules.ts` names each imported manifest, each package exports it. */
export async function installedManifests(repository = root): Promise<{ path: string; source: string }[]> {
  const modulesSource = await readFile(resolve(repository, MODULES_SOURCE), "utf8");
  const file = ts.createSourceFile(MODULES_SOURCE, modulesSource, ts.ScriptTarget.Latest, true);
  const imports = new Map<string, string>();
  for (const statement of file.statements) if (ts.isImportDeclaration(statement) && ts.isStringLiteral(statement.moduleSpecifier)) {
    const named = statement.importClause?.namedBindings;
    if (named && ts.isNamedImports(named)) for (const item of named.elements) imports.set(item.name.text, statement.moduleSpecifier.text);
  }
  let manifests: ts.Expression | undefined;
  for (const statement of file.statements) if (ts.isVariableStatement(statement)) {
    for (const declaration of statement.declarationList.declarations)
      if (ts.isIdentifier(declaration.name) && declaration.name.text === "manifests") manifests = declaration.initializer;
  }
  while (manifests && (ts.isSatisfiesExpression(manifests) || ts.isAsExpression(manifests))) manifests = manifests.expression;
  const elements = manifests && ts.isArrayLiteralExpression(manifests) ? [...manifests.elements] : undefined;
  if (!elements || !elements.every(ts.isIdentifier))
    throw new Error(`${MODULES_SOURCE}: manifests must be a literal list of imported manifests`);
  const packages = new Map<string, { directory: string; exports: Record<string, string> }>();
  for await (const path of new Bun.Glob("packages/*/package.json").scan(repository)) {
    const manifest = JSON.parse(await readFile(resolve(repository, path), "utf8"));
    packages.set(manifest.name, { directory: dirname(path), exports: manifest.exports ?? {} });
  }
  const found: { path: string; source: string }[] = [];
  for (const element of elements as ts.Identifier[]) {
    const specifier = imports.get(element.text);
    const match = specifier ? /^(@mlx-bun\/module-[a-z0-9-]+)(\/[\w-]+)?$/.exec(specifier) : null;
    const owner = match ? packages.get(match[1]!) : undefined, target = match ? owner?.exports[`.${match[2] ?? ""}`] : undefined;
    if (!owner || !target) throw new Error(`${MODULES_SOURCE}: ${element.text} must be imported from a module package's manifest export`);
    const path = join(owner.directory, target);
    found.push({ path, source: await readFile(resolve(repository, path), "utf8") });
  }
  return found;
}

/** The verbs of the modules the app installs. */
export async function installedCommandReference(repository = root): Promise<CommandReference[]> {
  return (await installedManifests(repository)).flatMap(({ path, source }) => moduleCommandReference(source, path));
}

export interface HelpOption { flags: string[]; description: string }
export interface HelpReference { global: HelpOption[]; shared: HelpOption[] }

/** Extract only the literal option rows from the owning help templates.
 * Interpolations (the command table) are already covered separately. */
export function helpReference(source: string): HelpReference {
  const file = ts.createSourceFile(CLI_SOURCE, source, ts.ScriptTarget.Latest, true);
  const help = file.statements.find((node): node is ts.FunctionDeclaration =>
    ts.isFunctionDeclaration(node) && node.name?.text === "help");
  if (!help?.body) throw new Error("CLI help function was not found");
  const root = help.body.statements.find((node): node is ts.IfStatement =>
    ts.isIfStatement(node) && ts.isPrefixUnaryExpression(node.expression) &&
    node.expression.operator === ts.SyntaxKind.ExclamationToken &&
    ts.isIdentifier(node.expression.operand) && node.expression.operand.text === "command");
  const shared = help.body.statements.find(ts.isReturnStatement);
  function rows(statement: ts.Statement | undefined): HelpOption[] {
    if (!statement || !ts.isReturnStatement(statement) || !statement.expression)
      throw new Error("Unsupported CLI help return; update the reference generator");
    const expression = statement.expression;
    const text = ts.isTemplateExpression(expression)
      ? expression.head.text + expression.templateSpans.map(span => `\n${span.literal.text}`).join("")
      : ts.isNoSubstitutionTemplateLiteral(expression) ? expression.text : undefined;
    if (!text) throw new Error("CLI help needs a literal template");
    const options = [...text.matchAll(/^  ((?:-[a-z], )?--[a-z][a-z-]*) +([^\n]+)$/gm)]
      .map(match => ({ flags: match[1]!.split(", "), description: match[2]! }));
    if (!options.length) throw new Error("CLI help template has no literal options");
    return options;
  }
  return { global: rows(root?.thenStatement), shared: rows(shared) };
}

const cell = (value: string) => value.replaceAll("|", "\\|").replaceAll("\n", " ");
const helpRow = (option: HelpOption) => `| ${option.flags.map(flag => `\`${flag}\``).join(", ")} | ${cell(option.description)} |`;
export function renderCommandReference(commands: CommandReference[], help: HelpReference): string {
  return `---\ntitle: CLI reference\ndescription: Commands and options generated from the application's parser table and help.\n---\n\n` +
    `Generated at build time from [the CLI command table and help](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/${CLI_SOURCE}). ` +
    `These are the refactor's current commands. Released versions can differ; use the installed command's \`--help\`.\n\n` +
    `## Global options\n\nUsage: \`mlx-bun [options]\`\n\nAn option-first invocation starts the server; use the serve options below.\n\n| Option | Description |\n| --- | --- |\n${help.global.map(helpRow).join("\n")}\n\n` +
    commands.map(command => `## ${command.name}\n\n${command.description}\n\n` +
      `Usage: \`mlx-bun ${command.name}${command.positional ? ` ${command.positional}` : ""} [options]\`\n\n` +
      `| Option | Description |\n| --- | --- |\n` + [...command.options.map(option =>
        `| ${option.short ? `\`-${option.short}\`, ` : ""}\`--${option.name}${option.type === "string" ? " <value>" : ""}\` | ${cell(option.description)} |`),
        ...help.shared.map(helpRow)].join("\n") + "\n\n" +
      `Use \`mlx-bun ${command.name} --help\` for terminal help.\n`).join("\n");
}

export async function generateReference(options: { repository?: string; destination?: string } = {}): Promise<void> {
  const repository = options.repository ?? root, destination = options.destination ?? resolve(import.meta.dir, "..");
  const source = await readFile(resolve(repository, CLI_SOURCE), "utf8");
  const commands = [...commandReference(source), ...await installedCommandReference(repository)], help = helpReference(source);
  // Read both required inputs before writing any generated output.
  const installer = await readFile(resolve(repository, INSTALLER_SOURCE));
  const cli = resolve(destination, "src/content/docs/reference/cli.md"), install = resolve(destination, "public/install.sh");
  await mkdir(dirname(cli), { recursive: true }); await mkdir(dirname(install), { recursive: true });
  await writeFile(cli, renderCommandReference(commands, help)); await writeFile(install, installer);
}

if (import.meta.main) {
  if (process.argv.includes("--help")) console.log(`Usage: bun scripts/generate-reference.ts\nGenerate CLI reference from ${CLI_SOURCE} and copy ${INSTALLER_SOURCE}.`);
  else await generateReference();
}
