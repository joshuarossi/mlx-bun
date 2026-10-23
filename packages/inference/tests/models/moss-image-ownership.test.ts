// MOSS-Image composes its own layers from kernels and its graphs from those
// layers. These checks hold the parts of that a parser can see; each says what
// it checks and no more, and review reads the source beside them:
// - the family's files import no other family's modules and no shared `layers/`;
// - it binds only the kernels it added, and each (`kernels/row-projection.ts`,
//   `kernels/situ.ts`, `kernels/gated-delta-float32.ts`) is imported by one file
//   and called only inside one layer class (`MossDenseRowLinear`, `MossSitu`,
//   `MossTextDeltaRecurrence`);
// - its graph files (DiT, conditioner, VAE decoder) import neither MLX ops nor
//   kernels (an import check, not a proof that no numeric code is there);
// - no method body of its layers and graphs branches on a field fixed at
//   construction (`this.bias ? ... : ...`, `if (!this.bias)`): construction binds
//   the single-purpose form instead. Request data (a skip set, a timestep) and
//   the pipeline's open/closed stage state are runtime inputs and stay allowed.
// A family test, not a repository-wide ban: other families keep their own composition.
import { expect, test } from "bun:test";
import { readdirSync, readFileSync } from "node:fs";
import { basename, dirname, join, relative, resolve } from "node:path";
import ts from "typescript";

const source = resolve(import.meta.dir, "../../src");
const family = join(source, "models/moss-image");
const GRAPH_FILES = ["transformer.ts", "text-encoder.ts", "vae.ts"];
/** The pipeline owns stage lifetime (which stages are open): runtime state by design. */
const LIFECYCLE_FILES = new Set(["pipeline.ts"]);

const parse = (file: string, text = readFileSync(file, "utf8")) => ts.createSourceFile(file, text, ts.ScriptTarget.Latest, true);

/** Every import or re-export specifier of `file`, relative to `src/` when relative. */
function imports(file: string): string[] {
  const out: string[] = [];
  const visit = (node: ts.Node) => {
    if ((ts.isImportDeclaration(node) || ts.isExportDeclaration(node)) && node.moduleSpecifier && ts.isStringLiteral(node.moduleSpecifier)) {
      const specifier = node.moduleSpecifier.text;
      out.push(specifier.startsWith(".") ? relative(source, resolve(dirname(file), specifier)) : specifier);
    }
    ts.forEachChild(node, visit);
  };
  visit(parse(file));
  return out;
}

const familyFiles = () => readdirSync(family).filter(name => name.endsWith(".ts")).map(name => join(family, name));

const readsThis = (node: ts.Node): boolean =>
  ((ts.isPropertyAccessExpression(node) || ts.isElementAccessExpression(node)) && node.expression.kind === ts.SyntaxKind.ThisKeyword) ||
  (ts.forEachChild(node, child => readsThis(child) || undefined) ?? false);

/** Branches in a non-static method body (constructors and `dispose` excluded) whose
 * condition reads a field of `this`. */
function fixedChoiceBranches(file: ts.SourceFile): string[] {
  const found: string[] = [];
  const at = (node: ts.Node) => `${file.fileName.split("/").pop()}:${file.getLineAndCharacterOfPosition(node.getStart(file)).line + 1}: ${node.getText(file).split("\n")[0]}`;
  const inspect = (node: ts.Node) => {
    if (ts.isIfStatement(node) && readsThis(node.expression)) found.push(at(node));
    if (ts.isConditionalExpression(node) && readsThis(node.condition)) found.push(at(node));
    if (ts.isBinaryExpression(node) && [ts.SyntaxKind.QuestionQuestionToken, ts.SyntaxKind.AmpersandAmpersandToken, ts.SyntaxKind.BarBarToken]
      .includes(node.operatorToken.kind) && readsThis(node.left)) found.push(at(node));
    if ((ts.isPropertyAccessExpression(node) || ts.isCallExpression(node)) && node.questionDotToken && readsThis(node.expression)) found.push(at(node));
    ts.forEachChild(node, inspect);
  };
  const visit = (node: ts.Node) => {
    if (ts.isMethodDeclaration(node) && node.body && !node.modifiers?.some(item => item.kind === ts.SyntaxKind.StaticKeyword) &&
        node.name.getText(file) !== "dispose") inspect(node.body);
    ts.forEachChild(node, visit);
  };
  visit(file);
  return found;
}

test("the family imports no other family's modules and no shared layer implementation", () => {
  const foreign: string[] = [];
  for (const file of familyFiles())
    for (const target of imports(file))
      if ((target.startsWith("models/") && !target.startsWith("models/moss-image/") && target !== "models/family") || target.startsWith("layers/"))
        foreign.push(`${relative(source, file)} -> ${target}`);
  expect(foreign).toEqual([]);
});

/** The kernels the family added, each one file bound by exactly one of its layers (ARCHITECTURE: "Add a kernel as one file in
 * `kernels/` bound by exactly one layer"). */
const OWNED_KERNELS = [
  { kernel: "kernels/row-projection", file: "models/moss-image/layers.ts", call: "rowProjection", layer: "MossDenseRowLinear" },
  { kernel: "kernels/situ", file: "models/moss-image/layers.ts", call: "situFor", layer: "MossSitu" },
  { kernel: "kernels/gated-delta-float32", file: "models/moss-image/text-layers.ts", call: "gatedDeltaFloat32", layer: "MossTextDeltaRecurrence" },
] as const;

/** Every `.ts` file under `src/`. */
function sourceFiles(dir = source): string[] {
  return readdirSync(dir, { withFileTypes: true }).flatMap(entry =>
    entry.isDirectory() ? sourceFiles(join(dir, entry.name)) : entry.name.endsWith(".ts") ? [join(dir, entry.name)] : []);
}

test("the family binds only the kernels it owns, never one another layer binds", () => {
  const bound = readdirSync(family).filter(name => name.endsWith(".ts"))
    .flatMap(name => imports(join(family, name)).filter(target => target.startsWith("kernels/")).map(target => `${name} -> ${target}`));
  expect(bound.sort()).toEqual(OWNED_KERNELS.map(owned => `${basename(owned.file)} -> ${owned.kernel}`).sort());
});

for (const owned of OWNED_KERNELS) {
  test(`${owned.kernel}.ts is imported by one file and called only inside ${owned.layer}`, () => {
    const importers = sourceFiles().filter(path => imports(path).includes(owned.kernel)).map(path => relative(source, path));
    expect(importers).toEqual([owned.file]);
    const callers: string[] = [];
    const visit = (node: ts.Node, owner: string | undefined) => {
      const next = ts.isClassDeclaration(node) && node.name ? node.name.text : owner;
      if (ts.isCallExpression(node) && ts.isIdentifier(node.expression) && node.expression.text === owned.call) callers.push(owner ?? "(module scope)");
      ts.forEachChild(node, child => visit(child, next));
    };
    visit(parse(join(source, owned.file)), undefined);
    expect(callers).toEqual([owned.layer]);
  });
}

test("the graph files import neither MLX ops nor kernels", () => {
  const numeric = GRAPH_FILES.flatMap(name => imports(join(family, name))
    .filter(target => target === "@mlx-bun/mlx/ops" || target.startsWith("kernels/"))
    .map(target => `${name} -> ${target}`));
  expect(numeric).toEqual([]);
});

test("no layer or graph method branches on a field fixed at construction", () => {
  // The check itself: the projection and embedding patterns the first cut had are found; request data is not.
  const fixture = parse("fixture.ts", [
    "class DenseLinear { forward(x: unknown) { return this.bias ? ops.addmm(this.bias, x, this.wT) : ops.matmul(x, this.wT); } }",
    "class QuantizedLinear { forward(x: unknown) { const out = x; if (!this.bias) return out; return out; } }",
    "class Embedding { forward(ids: unknown) { using biasRows = this.biases ? ops.takeAxis(this.biases, ids, 0) : null; return biasRows; } }",
    "class Graph { velocity(skip: Set<number>) { for (let i = 0; i < 2; i++) if (skip.has(i)) continue; } dispose() { if (this.open) close(); } }",
  ].join("\n"));
  expect(fixedChoiceBranches(fixture).map(item => item.split(":")[1])).toEqual(["1", "2", "3"]);
  const found = familyFiles().filter(file => !LIFECYCLE_FILES.has(file.split("/").pop()!)).flatMap(file => fixedChoiceBranches(parse(file)));
  expect(found).toEqual([]);
});
