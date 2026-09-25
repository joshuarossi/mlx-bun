import { expect, test } from "bun:test";
import { builtinModules } from "node:module";
import { mkdtempSync, mkdirSync, realpathSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import ts from "typescript";

const workspace = resolve(import.meta.dir, "../../..");

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

function layer(path: string, owner: Library): Layer | undefined {
  if (owner.name === "@mlx-bun/mlx") return "mlx";
  if (owner.name !== "@mlx-bun/inference") return undefined;
  const name = relative(owner.source, path);
  if (name === "index.ts") return "api";
  if (name.startsWith("contracts/portable/")) return "portable";
  if (name.startsWith("contracts/mlx/")) return "mlx-contracts";
  const directory = name.split("/")[0]!;
  if (!(directory in allowed)) throw new Error(`Unclassified source: ${name}`);
  return directory as Layer;
}

// Add a domain only with its first consumer; app roots do not become a loophole.
const appDomains: Record<string, string[]> = { cli: ["engine", "server", "chat", "web", "jobs", "quantize", "dataset", "finetune", "publishing", "memory", "hub"], engine: [], chat: [], server: ["engine", "chat", "memory", "jobs", "quantize", "dataset", "finetune", "publishing", "hub"], memory: [], quantize: ["jobs"], dataset: ["jobs"], finetune: ["jobs"], publishing: [], jobs: [], hub: [], web: ["chat", "jobs"] };
const siteDomains: Record<string, string[]> = { "content.config.ts": [], content: [], styles: [] };
function domains(owner: Library): Record<string, string[]> {
  return owner.name === "mlx-bun-website" ? siteDomains : appDomains;
}
function appDomain(path: string, owner: Library): string {
  const domain = relative(owner.source, path).split("/")[0]!;
  if (!(domain in domains(owner))) throw new Error(`Unclassified app source: ${relative(owner.source, path)}`);
  return domain;
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

interface Library {
  app: boolean;
  name: string;
  source: string;
  dependencies: string[];
}

async function inspectWorkspaces(root: string): Promise<string[]> {
  root = realpathSync(root);
  const libraries: Library[] = [];
  for await (const file of new Bun.Glob("{packages,apps}/*/package.json").scan(root)) {
    const manifest = await Bun.file(resolve(root, file)).json();
    libraries.push({ app: file.startsWith("apps/"), name: manifest.name, source: resolve(root, dirname(file), "src"),
      dependencies: Object.keys({ ...manifest.dependencies, ...manifest.optionalDependencies, ...manifest.peerDependencies }) });
  }
  const violations: string[] = [];
  const names = libraries.map(item => item.name);
  if (new Set(names).size !== names.length) violations.push("Duplicate workspace package names");
  for (const owner of libraries) {
    for (const dependency of libraries.filter(item => owner.dependencies.includes(item.name))) {
      if (!owner.app && dependency.app) violations.push(`${owner.name}: libraries cannot depend on apps (${dependency.name})`);
    }
  }
  const packageGraph = new Map(libraries.map(item => [item.name, item.dependencies.filter(name => names.includes(name))]));
  violations.push(...cycles(packageGraph).map(cycle => `Package cycle: ${cycle}`));
  const ownerOf = (path: string) => libraries.find(item => path.startsWith(`${item.source}/`));
  const options: ts.CompilerOptions = { moduleResolution: ts.ModuleResolutionKind.Bundler, module: ts.ModuleKind.Preserve };
  const cache = ts.createModuleResolutionCache(root, path => path, options);
  const sources = new Map<string, ts.SourceFile>();
  for (const library of libraries) {
    for await (const file of new Bun.Glob("**/*.{ts,tsx,js,mjs,cjs}").scan(library.source)) {
      const absolute = resolve(library.source, file);
      sources.set(absolute, ts.createSourceFile(absolute, await Bun.file(absolute).text(), ts.ScriptTarget.Latest, true));
    }
  }
  const dependencies = new Map<string, string[]>();
  const external = new Set([...builtinModules, ...builtinModules.map(name => `node:${name}`), "bun", "bun:ffi", "bun:sqlite"]);
  const packageOwners: Record<string, Layer> = {
    "@huggingface/tokenizers": "input", "@huggingface/jinja": "input",
    "fast-png": "input", "@mlc-ai/web-xgrammar": "sampling",
  };
  const inferencePackage = libraries.find(item => item.name === "@mlx-bun/inference");
  if (inferencePackage) {
    const thirdParty = inferencePackage.dependencies.filter(name => !names.includes(name)).toSorted();
    if (JSON.stringify(thirdParty) !== JSON.stringify(Object.keys(packageOwners).toSorted()))
      violations.push("Inference third-party dependencies need an explicit layer owner");
  }
  for (const [file, source] of sources) {
    const owner = ownerOf(file)!;
    if (owner.app) appDomain(file, owner);
    if (owner.app && ["chat/protocol.ts", "jobs/protocol.ts"].includes(relative(owner.source, file)) && references(source).length)
      violations.push(`${relative(root, file)}: browser-shared data protocols cannot import modules`);
    const from = layer(file, owner), name = relative(root, file), edges: string[] = [];
    dependencies.set(name, edges);
    for (const { specifier, line } of references(source)) {
      const at = `${name}:${line}`;
      if (specifier === undefined) { violations.push(`${at}: nonliteral module reference`); continue; }
      // A workspace may read its own package metadata (e.g. CLI --version).
      if (specifier.startsWith(".") && resolve(dirname(file), specifier) === resolve(owner.source, "../package.json")) continue;
      const dependency = owner.dependencies.find(name => specifier === name || specifier.startsWith(`${name}/`));
      const siteContentApi = owner.name === "mlx-bun-website" && owner.dependencies.includes("astro") &&
        relative(owner.source, file) === "content.config.ts" && specifier === "astro:content";
      const isExternal = siteContentApi || external.has(specifier) || (dependency !== undefined && !names.includes(dependency));
      const browser = owner.app && relative(owner.source, file).startsWith("web/browser/");
      if (browser && isExternal) { violations.push(`${at}: browser cannot import ${specifier}`); continue; }
      if (isExternal) {
        if (from === "portable" || from === "mlx-contracts" ||
            (from !== undefined && dependency && packageOwners[dependency] !== from))
          violations.push(`${at}: ${from} cannot import ${specifier}`);
        continue;
      }
      const target = ts.resolveModuleName(specifier, file, options, ts.sys, cache).resolvedModule?.resolvedFileName;
      // Text imports resolve to a declaration file; check the actual JS module too.
      const actual = specifier.endsWith(".js") && sources.has(resolve(dirname(file), specifier))
        ? resolve(dirname(file), specifier) : target;
      if (!actual || !sources.has(actual)) { violations.push(`${at}: unresolved or unclassified import ${specifier}`); continue; }
      if (browser && !(actual.startsWith(resolve(owner.source, "web/browser") + "/") ||
          actual === resolve(owner.source, "chat/protocol.ts") || actual === resolve(owner.source, "jobs/protocol.ts")))
        violations.push(`${at}: browser may import only browser modules and data protocols (${specifier})`);
      const targetOwner = ownerOf(actual)!;
      const to = layer(actual, targetOwner);
      if (owner.app && owner === targetOwner) {
        const fromDomain = appDomain(file, owner), toDomain = appDomain(actual, owner);
        if (fromDomain !== toDomain && !domains(owner)[fromDomain]!.includes(toDomain))
          violations.push(`${at}: app ${fromDomain} -> ${toDomain}`);
      }
      if (owner !== targetOwner) {
        if (!owner.dependencies.includes(targetOwner.name))
          violations.push(`${at}: undeclared workspace dependency ${targetOwner.name}`);
        if (specifier !== targetOwner.name && !specifier.startsWith(`${targetOwner.name}/`))
          violations.push(`${at}: cross-package import must use public exports (${specifier})`);
      }
      if (from !== undefined && (to === undefined || !mayImport(from, to)))
        violations.push(`${at}: ${from} -> ${to ?? targetOwner.name} (${specifier})`);
      edges.push(relative(root, actual));
    }
  }
  if (sources.size === 0) violations.push("No workspace source files found");
  violations.push(...cycles(dependencies).map(cycle => `Module cycle: ${cycle}`));
  return violations;
}

test("all library and app workspaces follow their declared DAG and inference layer rules, including type-only dependencies", async () => {
  expect(cycles(new Map(Object.entries(allowed)))).toEqual([]);
  expect(await inspectWorkspaces(workspace)).toEqual([]);
});

test("the website has explicit source domains and rejects undeclared app dependencies", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-site-boundaries-"));
  const write = (path: string, text: string) => {
    mkdirSync(dirname(resolve(root, path)), { recursive: true }); writeFileSync(resolve(root, path), text);
  };
  try {
    write("apps/website/package.json", JSON.stringify({ name: "mlx-bun-website", type: "module", dependencies: { astro: "6", "@astrojs/starlight": "0.40" } }));
    write("apps/website/src/content.config.ts", 'import { defineCollection } from "astro:content"; import { docsLoader } from "@astrojs/starlight/loaders";');
    write("apps/mlx-bun/package.json", JSON.stringify({ name: "mlx-bun", type: "module" }));
    write("apps/mlx-bun/src/chat/backend.ts", "export const backend = true;");
    expect(await inspectWorkspaces(root)).toEqual([]);
    write("apps/website/src/content.config.ts", 'import { backend } from "../../mlx-bun/src/chat/backend";');
    expect((await inspectWorkspaces(root)).some(message => message.includes("undeclared workspace dependency mlx-bun"))).toBe(true);
    write("apps/website/src/content.config.ts", "export const collections = {};");
    write("apps/website/src/cli/hidden.ts", "export const hidden = true;");
    await expect(inspectWorkspaces(root)).rejects.toThrow("Unclassified app source: cli/hidden.ts");
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("new library packages cannot hide undeclared imports, private paths, or dependency cycles", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-library-boundaries-"));
  const write = (path: string, text: string) => {
    const target = resolve(root, path);
    mkdirSync(dirname(target), { recursive: true });
    writeFileSync(target, text);
  };
  const manifest = (name: string, dependencies: Record<string, string> = {}) =>
    write(`packages/${name}/package.json`, JSON.stringify({ name: `@example/${name}`, type: "module", dependencies,
      exports: { ".": "./src/index.ts" } }));
  try {
    for (const name of ["a", "b"]) {
      manifest(name);
      write(`packages/${name}/src/index.ts`, "export interface Value { value: number }\n");
      mkdirSync(resolve(root, "node_modules/@example"), { recursive: true });
      symlinkSync(resolve(root, `packages/${name}`), resolve(root, `node_modules/@example/${name}`));
    }
    expect(await inspectWorkspaces(root)).toEqual([]);
    write("packages/a/src/index.ts", 'import type { Value } from "@example/b"; export type A = Value;');
    expect(await inspectWorkspaces(root)).toContain("packages/a/src/index.ts:1: undeclared workspace dependency @example/b");
    manifest("a", { "@example/b": "workspace:*" });
    expect(await inspectWorkspaces(root)).toEqual([]);
    write("packages/a/src/index.ts", 'export type { Value } from "../../b/src/index";');
    expect((await inspectWorkspaces(root)).some(item => item.includes("cross-package import must use public exports"))).toBe(true);
    write("packages/b/src/private.ts", "export type Secret = number;");
    write("packages/a/src/index.ts", 'export type { Secret } from "@example/b/src/private";');
    expect((await inspectWorkspaces(root)).some(item => item.includes("unresolved or unclassified import"))).toBe(true);
    write("packages/a/src/index.ts", 'export type A = number; export type { B } from "@example/b";');
    write("packages/b/src/index.ts", 'export type B = number; export type { A } from "@example/a";');
    manifest("b", { "@example/a": "workspace:*" });
    const cyclic = await inspectWorkspaces(root);
    expect(cyclic.some(item => item.startsWith("Package cycle:"))).toBe(true);
    expect(cyclic.some(item => item.startsWith("Module cycle:"))).toBe(true);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
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

test("apps consume declared public library exports and libraries never depend on apps", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-app-boundaries-"));
  const write = (path: string, text: string) => {
    const target = resolve(root, path);
    mkdirSync(dirname(target), { recursive: true }); writeFileSync(target, text);
  };
  const app = { name: "example-app", type: "module", exports: { ".": "./src/cli/main.ts" }, dependencies: { "example-library": "workspace:*" } };
  const lib = { name: "example-library", type: "module", exports: { ".": "./src/index.ts" }, dependencies: {} };
  try {
    write("apps/example/package.json", JSON.stringify(app));
    write("packages/example/package.json", JSON.stringify(lib));
    write("packages/example/src/index.ts", "export type Value = number;");
    write("apps/example/src/cli/main.ts", 'import type { Value } from "example-library"; export type App = Value;');
    mkdirSync(resolve(root, "node_modules"));
    symlinkSync(resolve(root, "packages/example"), resolve(root, "node_modules/example-library"));
    symlinkSync(resolve(root, "apps/example"), resolve(root, "node_modules/example-app"));
    expect(await inspectWorkspaces(root)).toEqual([]);
    write("apps/example/package.json", JSON.stringify({ ...app, dependencies: {} }));
    expect((await inspectWorkspaces(root)).some(item => item.includes("undeclared workspace dependency"))).toBe(true);
    write("apps/example/package.json", JSON.stringify(app));
    write("apps/example/src/cli/main.ts", 'export type { Value } from "../../../../packages/example/src/index";');
    expect((await inspectWorkspaces(root)).some(item => item.includes("cross-package import must use public exports"))).toBe(true);
    write("apps/example/src/cli/main.ts", "export type App = number;");
    write("packages/example/package.json", JSON.stringify({ ...lib, dependencies: { "example-app": "workspace:*" } }));
    expect((await inspectWorkspaces(root)).some(item => item.includes("libraries cannot depend on apps"))).toBe(true);
    write("apps/example/src/mystery.ts", "export const hidden = true;");
    await expect(inspectWorkspaces(root)).rejects.toThrow("Unclassified app source");
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("browser code can consume data protocols but cannot reach backend modules or platform imports", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-browser-boundaries-"));
  const write = (path: string, text: string) => {
    const target = resolve(root, path); mkdirSync(dirname(target), { recursive: true }); writeFileSync(target, text);
  };
  try {
    write("apps/example/package.json", JSON.stringify({ name: "browser-example", type: "module" }));
    write("apps/example/src/chat/protocol.ts", "export type Message = string;");
    write("apps/example/src/jobs/protocol.ts", "export type Job = string;");
    write("apps/example/src/chat/backend.ts", "export const backend = true;");
    write("apps/example/src/web/assets.ts", "export const assets = true;");
    const entry = "apps/example/src/web/browser/main.ts";
    write(entry, 'import type { Message } from "../../chat/protocol"; import type { Job } from "../../jobs/protocol";');
    expect(await inspectWorkspaces(root)).toEqual([]);
    for (const specifier of ["node:fs", "bun", "../../chat/backend", "../assets"]) {
      write(entry, `import * as backend from ${JSON.stringify(specifier)};`);
      expect((await inspectWorkspaces(root)).some(item => item.includes("browser"))).toBe(true);
    }
    write(entry, 'import type { Message } from "../../chat/protocol";');
    write("apps/example/src/chat/protocol.ts", 'export type Message = string; import "./backend";');
    expect((await inspectWorkspaces(root)).some(item => item.includes("data protocols cannot import"))).toBe(true);
  } finally { rmSync(root, { recursive: true, force: true }); }
});
