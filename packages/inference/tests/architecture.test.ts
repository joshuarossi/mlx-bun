import { expect, test } from "bun:test";
import { builtinModules } from "node:module";
import { dirname, relative, resolve } from "node:path";
import ts from "typescript";

const workspace = resolve(import.meta.dir, "../../..");
const inference = resolve(workspace, "packages/inference/src");
const mlx = resolve(workspace, "packages/mlx/src");

// Direct dependencies, not a numeric rank: independent siblings stay independent.
// ARCHITECTURE.md describes the responsibilities behind these rules.
const allowed = {
  mlx: [],
  portable: [],
  "mlx-contracts": ["portable", "mlx"],
  contracts: ["portable", "mlx-contracts"],
  runtime: ["portable", "mlx"],
  kernels: ["portable", "mlx-contracts", "runtime", "mlx"],
  artifacts: ["portable", "mlx-contracts", "runtime", "kernels", "mlx"],
  layers: ["portable", "mlx-contracts", "runtime", "kernels", "artifacts", "mlx"],
  state: ["portable", "mlx-contracts", "runtime", "kernels", "artifacts", "layers", "mlx"],
  input: ["portable", "mlx-contracts", "runtime", "layers", "state", "mlx"],
  sampling: ["portable", "mlx-contracts", "runtime", "kernels", "input", "mlx"],
  adapters: ["artifacts", "layers", "mlx"],
  models: ["portable", "mlx-contracts", "runtime", "kernels", "artifacts", "layers", "state", "input", "sampling", "adapters", "mlx"],
  generation: ["portable", "mlx-contracts", "runtime", "kernels", "artifacts", "layers", "state", "input", "sampling", "models", "mlx"],
  scoring: ["portable", "mlx-contracts", "kernels", "state", "models", "mlx"],
  embeddings: ["artifacts", "input", "models", "mlx"],
  transcription: ["input", "models", "mlx"],
  execution: ["portable", "mlx-contracts", "runtime", "artifacts", "layers", "state", "input", "sampling", "models", "generation", "mlx"],
  api: ["contracts", "portable", "mlx-contracts", "runtime", "kernels", "artifacts", "layers", "state", "input", "sampling", "adapters", "models", "generation", "scoring", "embeddings", "transcription", "execution", "mlx"],
} satisfies Record<string, string[]>;
type Layer = keyof typeof allowed;

function layer(path: string): Layer {
  if (path.startsWith(`${mlx}/`)) return "mlx";
  if (!path.startsWith(`${inference}/`)) throw new Error(`Source outside a library: ${path}`);
  const name = relative(inference, path);
  if (name === "index.ts") return "api";
  if (name.startsWith("contracts/portable/")) return "portable";
  if (name.startsWith("contracts/mlx/")) return "mlx-contracts";
  const directory = name.split("/")[0]!;
  if (!(directory in allowed)) throw new Error(`Unclassified source: ${name}`);
  return directory as Layer;
}

function references(source: ts.SourceFile): { specifier: string | undefined; line: number }[] {
  const found: { specifier: string | undefined; line: number }[] = [];
  const inspect = (node: ts.Node, literal: ts.Node | undefined) => found.push({
    specifier: literal && ts.isStringLiteralLike(literal) ? literal.text : undefined,
    line: source.getLineAndCharacterOfPosition(node.getStart(source)).line + 1,
  });
  const visit = (node: ts.Node) => {
    if (ts.isImportDeclaration(node) || ts.isExportDeclaration(node)) {
      if (node.moduleSpecifier) inspect(node, node.moduleSpecifier);
    } else if (ts.isImportTypeNode(node)) {
      inspect(node, ts.isLiteralTypeNode(node.argument) ? node.argument.literal : undefined);
    } else if (ts.isImportEqualsDeclaration(node) && ts.isExternalModuleReference(node.moduleReference)) {
      inspect(node, node.moduleReference.expression);
    } else if (ts.isCallExpression(node) && (node.expression.kind === ts.SyntaxKind.ImportKeyword ||
        (ts.isIdentifier(node.expression) && node.expression.text === "require"))) {
      inspect(node, node.arguments[0]);
    }
    ts.forEachChild(node, visit);
  };
  visit(source);
  return found;
}

function cycles(graph: ReadonlyMap<string, readonly string[]>): string[] {
  const visited = new Set<string>(), active = new Set<string>(), path: string[] = [], found: string[] = [];
  const visit = (node: string) => {
    if (active.has(node)) { found.push([...path.slice(path.indexOf(node)), node].join(" -> ")); return; }
    if (visited.has(node)) return;
    visited.add(node); active.add(node); path.push(node);
    for (const dependency of graph.get(node) ?? []) visit(dependency);
    path.pop(); active.delete(node);
  };
  for (const node of graph.keys()) visit(node);
  return found;
}

function mayImport(from: Layer, to: Layer): boolean {
  return from === to || (allowed[from] as readonly string[]).includes(to);
}

test("library imports follow the layer DAG, including type-only dependencies", async () => {
  expect(cycles(new Map(Object.entries(allowed)))).toEqual([]);
  const options: ts.CompilerOptions = { moduleResolution: ts.ModuleResolutionKind.Bundler, module: ts.ModuleKind.Preserve };
  const cache = ts.createModuleResolutionCache(workspace, path => path, options);
  const sources = new Map<string, ts.SourceFile>();
  for (const root of [inference, mlx]) {
    for await (const file of new Bun.Glob("**/*.{ts,tsx,js,mjs,cjs}").scan(root)) {
      const absolute = resolve(root, file);
      sources.set(absolute, ts.createSourceFile(absolute, await Bun.file(absolute).text(), ts.ScriptTarget.Latest, true));
    }
  }
  const dependencies = new Map<string, string[]>(), violations: string[] = [];
  const external = new Set([...builtinModules, ...builtinModules.map(name => `node:${name}`), "bun", "bun:ffi"]);
  const manifest = await Bun.file(resolve(inference, "../package.json")).json();
  const packages = Object.keys(manifest.dependencies).filter(name => name !== "@mlx-bun/mlx");
  const packageOwners: Record<string, Layer> = {
    "@huggingface/tokenizers": "input", "@huggingface/jinja": "input",
    "fast-png": "input", "@mlc-ai/web-xgrammar": "sampling",
  };
  expect(packages.toSorted()).toEqual(Object.keys(packageOwners).toSorted());
  for (const [file, source] of sources) {
    const from = layer(file), name = relative(workspace, file), edges: string[] = [];
    dependencies.set(name, edges);
    for (const { specifier, line } of references(source)) {
      const at = `${name}:${line}`;
      if (specifier === undefined) { violations.push(`${at}: nonliteral module reference`); continue; }
      const dependency = packages.find(name => specifier === name || specifier.startsWith(`${name}/`));
      const isExternal = external.has(specifier) || dependency !== undefined;
      if (isExternal) {
        if (from === "portable" || from === "mlx-contracts" || (dependency && packageOwners[dependency] !== from))
          violations.push(`${at}: ${from} cannot import ${specifier}`);
        continue;
      }
      const target = ts.resolveModuleName(specifier, file, options, ts.sys, cache).resolvedModule?.resolvedFileName;
      // Text imports resolve to a declaration file; check the actual JS module too.
      const actual = specifier.endsWith(".js") && sources.has(resolve(dirname(file), specifier))
        ? resolve(dirname(file), specifier) : target;
      if (!actual || !sources.has(actual)) { violations.push(`${at}: unresolved or unclassified import ${specifier}`); continue; }
      const to = layer(actual);
      if (!mayImport(from, to)) violations.push(`${at}: ${from} -> ${to} (${specifier})`);
      edges.push(relative(workspace, actual));
    }
  }
  expect(sources.size).toBeGreaterThan(0);
  expect(violations).toEqual([]);
  expect(cycles(dependencies)).toEqual([]);
});

test("the gate sees every supported import form and rejects upward edges", () => {
  const source = ts.createSourceFile("example.ts", `
    import type { Cache } from './type';
    import { type State } from './named-type';
    export type { Graph } from './export-type';
    export * from './export';
    type Nested = import('./outer').Port<import('./inner').Tensor>;
    import alias = require('./equals');
    const a = import('./dynamic');
    const b = require('./require');
    const c = import(variable);
  `, ts.ScriptTarget.Latest, true);
  expect(references(source).map(item => item.specifier)).toEqual([
    './type', './named-type', './export-type', './export', './outer', './inner', './equals', './dynamic', './require', undefined,
  ]);
  expect(mayImport("kernels", "state")).toBe(false);
  expect(mayImport("mlx-contracts", "generation")).toBe(false);
  expect(mayImport("portable", "mlx-contracts")).toBe(false);
  expect(mayImport("models", "api")).toBe(false);
  expect(mayImport("generation", "models")).toBe(true);
  expect(cycles(new Map([["a", ["b"]], ["b", ["c"]], ["c", ["a"]]]))).toEqual(["a -> b -> c -> a"]);
});
