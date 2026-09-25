import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import ts from "typescript";

const root = resolve(import.meta.dir, "../../..");
export const CLI_SOURCE = "apps/mlx-bun/src/cli/args.ts";
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
    `## Global options\n\nUsage: \`mlx-bun [options]\`\n\n| Option | Description |\n| --- | --- |\n${help.global.map(helpRow).join("\n")}\n\n` +
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
  const commands = commandReference(source), help = helpReference(source);
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
