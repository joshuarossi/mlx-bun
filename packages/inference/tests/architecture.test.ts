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
const appDomains: Record<string, string[]> = { cli: ["engine", "server", "chat", "web", "jobs", "quantize", "finetune", "publishing", "memory", "hub", "storage", "modules.ts"], "modules.ts": [], engine: [], chat: ["storage"], server: ["engine", "chat", "memory", "jobs", "quantize", "finetune", "publishing", "hub", "storage"], memory: ["storage"], quantize: ["jobs", "storage"], finetune: ["jobs"], publishing: ["storage"], jobs: ["storage"], hub: [], storage: [], web: ["chat", "jobs"] };
const siteDomains: Record<string, string[]> = { "content.config.ts": [], content: [], styles: [] };
function domains(owner: Library): Record<string, string[]> {
  return owner.name === "mlx-bun-website" ? siteDomains : appDomains;
}
function appDomain(path: string, owner: Library): string {
  const domain = relative(owner.source, path).split("/")[0]!;
  if (!(domain in domains(owner))) throw new Error(`Unclassified app source: ${relative(owner.source, path)}`);
  return domain;
}

// Scheduling (`execution/`), the app's engine, server and CLI, the training package,
// and module, host-library and host-app code consume graphs through their declared
// capabilities, bindings, profiles and training operations. They may name the
// graph handle, its declaration, profiles, the registry-level role predicates
// (`models/support.ts`) and shared input helpers, never a concrete model, and
// never branch on a model's class, type string, architecture list or family flag.
const graphContracts = new Set(["models/index.ts", "models/factory.ts", "models/capabilities.ts", "models/profile.ts",
  "models/implementation.ts", "models/graph.ts", "models/media-input.ts", "models/runtime.ts", "models/memory-plan.ts",
  "models/chat-template.ts", "models/support.ts"]);
/** `models/support.ts` also exports one structural predicate per family; the role predicates
 * (`supportTier`, `isSupportedModelRecord`, `is<Role>ModelType`) are the only ones consumers may use. */
const familyPredicate = /^is(Gemma|Qwen|MiniCPM|Llama|Glm|Diffusion|Whisper|Universal)\w*Config$/i;
const familyWord = /(gemma|qwen|minicpm|llama|glm|diffusion|universal)/i;

// Modular application (ARCHITECTURE.md): `app-core` holds the contracts, `app-host`
// (and later service implementations) the host side, `module-<id>` the features.
const coreName = "@mlx-bun/app-core";
const isModulePackage = (name: string) => name.startsWith("@mlx-bun/module-");
const isHostLibrary = (name: string) => name.startsWith("@mlx-bun/app-") && name !== coreName;
/** Libraries below the app: everything that is not a contract, host library, module or app. */
const belowApp = (owner: Library) => !owner.app && owner.name !== coreName && !isHostLibrary(owner.name) && !isModulePackage(owner.name);
/** A host's one composition file, the only place that names module packages. */
const isCompositionFile = (file: string, owner: Library) => owner.app && relative(owner.source, file) === "modules.ts";
const inModulePanel = (file: string, owner: Library) => isModulePackage(owner.name) && relative(owner.source, file).startsWith("panel/");
const isModuleProtocol = (file: string, owner: Library) => isModulePackage(owner.name) && relative(owner.source, file) === "protocol.ts";

function graphConsumer(file: string, owner: Library): string | undefined {
  const name = relative(owner.source, file);
  if ((owner.name === "@mlx-bun/inference" && name.startsWith("execution/")) ||
      (owner.name === "mlx-bun" && (name.startsWith("engine/") || name.startsWith("server/") || name.startsWith("cli/"))))
    return "scheduling, engine, server and CLI code";
  if (owner.name === "@mlx-bun/training") return "training code";
  return isModulePackage(owner.name) || isHostLibrary(owner.name) || (owner.app && owner.name !== "mlx-bun-website")
    ? "module and host code" : undefined;
}

/** Scheduling in `execution/` is written against the structural graph interface
 * (`MlxTokenGraph`); the model registry's closed union of classes stays out of it. */
const closedModelUnion: ReadonlySet<string> = new Set(["RuntimeModel"]);
const isScheduling = (file: string, owner: Library) =>
  owner.name === "@mlx-bun/inference" && relative(owner.source, file).startsWith("execution/");

/** Anything in a types-only package that exists at runtime: values, `export *`, non-type exports, side-effect imports. */
function runtimeCode(source: ts.SourceFile): { text: string; line: number }[] {
  const found: { text: string; line: number }[] = [];
  const add = (node: ts.Node, text: string) =>
    found.push({ text, line: source.getLineAndCharacterOfPosition(node.getStart(source)).line + 1 });
  for (const statement of source.statements) {
    if (ts.isInterfaceDeclaration(statement) || ts.isTypeAliasDeclaration(statement)) continue;
    if (ts.isImportDeclaration(statement)) {
      if (!statement.importClause) add(statement, "side-effect import");
      continue;
    }
    if (ts.isExportDeclaration(statement)) {
      if (statement.isTypeOnly) continue;
      if (!statement.exportClause || ts.isNamespaceExport(statement.exportClause)) add(statement, "export * (use export type *)");
      else for (const item of statement.exportClause.elements) if (!item.isTypeOnly) add(item, `runtime re-export ${item.name.text}`);
      continue;
    }
    add(statement, ts.isVariableStatement(statement) ? "value" : ts.isFunctionDeclaration(statement) ? "function" :
      ts.isClassDeclaration(statement) ? "class" : ts.isEnumDeclaration(statement) ? "enum" : ts.isModuleDeclaration(statement) ? "namespace" :
      ts.isExportAssignment(statement) ? "default export" : "statement");
  }
  return found;
}

/** Model-identity branches: `instanceof <model class>`, comparing or pattern-matching
 * a model type string, and model-scoped runtime flags. */
function identityChecks(source: ts.SourceFile): { text: string; line: number }[] {
  const found: { text: string; line: number }[] = [];
  const add = (node: ts.Node, text: string) =>
    found.push({ text, line: source.getLineAndCharacterOfPosition(node.getStart(source)).line + 1 });
  const typeKey = /^(model_?[tT]ype|architectures)$/;
  const typeName = (node: ts.Node): boolean => (ts.isPropertyAccessExpression(node) && typeKey.test(node.name.text)) ||
    (ts.isElementAccessExpression(node) && ts.isStringLiteralLike(node.argumentExpression) && typeKey.test(node.argumentExpression.text)) ||
    // architectures[0]
    (ts.isElementAccessExpression(node) && typeName(node.expression));
  const visit = (node: ts.Node) => {
    if (ts.isBinaryExpression(node)) {
      const op = node.operatorToken.kind;
      if (op === ts.SyntaxKind.InstanceOfKeyword && ts.isIdentifier(node.right) && (/Model$/.test(node.right.text) || familyWord.test(node.right.text)))
        add(node, `instanceof ${node.right.text}`);
      const compares = [ts.SyntaxKind.EqualsEqualsToken, ts.SyntaxKind.EqualsEqualsEqualsToken,
        ts.SyntaxKind.ExclamationEqualsToken, ts.SyntaxKind.ExclamationEqualsEqualsToken].includes(op);
      if (compares && (typeName(node.left) || typeName(node.right))) add(node, "comparing a model type");
    }
    if (ts.isCallExpression(node) && ts.isPropertyAccessExpression(node.expression) &&
        ["startsWith", "endsWith", "includes", "match", "test"].includes(node.expression.name.text) &&
        (typeName(node.expression.expression) || (ts.isCallExpression(node.expression.expression) &&
          ts.isPropertyAccessExpression(node.expression.expression.expression) && typeName(node.expression.expression.expression.expression))))
      add(node, "matching a model type");
    if (ts.isStringLiteralLike(node) && /^MLX_BUN_(QWEN|GEMMA|MINICPM|LLAMA|GLM|DIFFUSION)/.test(node.text))
      add(node, `model-scoped flag ${node.text}`);
    if (ts.isImportSpecifier(node) && familyPredicate.test((node.propertyName ?? node.name).text))
      add(node, `family predicate ${(node.propertyName ?? node.name).text}`);
    ts.forEachChild(node, visit);
  };
  visit(source);
  return found;
}

// Draft providers are selected, detected and loaded through the library's
// registry; the app never names a concrete provider class. The classes are
// whatever the provider sources export, so a new provider is covered on arrival.
const draftProviderSources = "generation/speculative/sources/";

function exportedProviderClasses(source: ts.SourceFile): string[] {
  return source.statements.filter(ts.isClassDeclaration).filter(node => node.name && /Provider$/.test(node.name.text) &&
    node.modifiers?.some(modifier => modifier.kind === ts.SyntaxKind.ExportKeyword)).map(node => node.name!.text);
}

function namedIdentifiers(source: ts.SourceFile, names: ReadonlySet<string>): { text: string; line: number }[] {
  const found: { text: string; line: number }[] = [];
  const visit = (node: ts.Node) => {
    if (ts.isIdentifier(node) && names.has(node.text))
      found.push({ text: node.text, line: source.getLineAndCharacterOfPosition(node.getStart(source)).line + 1 });
    ts.forEachChild(node, visit);
  };
  visit(source);
  return found;
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
  for (const owner of libraries) {
    const workspaceDependencies = libraries.filter(item => owner.dependencies.includes(item.name));
    if (owner.name === coreName && workspaceDependencies.length)
      violations.push(`${owner.name}: app-core has no workspace dependencies (${workspaceDependencies.map(item => item.name).join(", ")})`);
    if (belowApp(owner) && owner.dependencies.includes(coreName))
      violations.push(`${owner.name}: libraries below the app never depend on app-core`);
    if (owner.app) for (const dependency of workspaceDependencies.filter(item => item.app))
      violations.push(`${owner.name}: hosts never depend on hosts (${dependency.name})`);
    if (isModulePackage(owner.name)) for (const dependency of workspaceDependencies)
      if (dependency.name !== coreName && (dependency.app || isModulePackage(dependency.name) || isHostLibrary(dependency.name)))
        violations.push(`${owner.name}: a module depends only on app-core and domain libraries (${dependency.name})`);
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
  const draftProviders = new Set<string>();
  for (const [file, source] of sources)
    if (inferencePackage && relative(inferencePackage.source, file).startsWith(draftProviderSources))
      for (const name of exportedProviderClasses(source)) draftProviders.add(name);
  const named = new Map<Library, Set<string>>(libraries.map(item => [item, new Set()]));
  for (const [file, source] of sources) {
    const owner = ownerOf(file)!;
    if (owner.app) appDomain(file, owner);
    if (owner.app)
      for (const { text, line } of namedIdentifiers(source, draftProviders))
        violations.push(`${relative(root, file)}:${line}: the app cannot name a concrete draft provider (${text}); select and load through the draft provider registry`);
    if (owner.name === coreName)
      for (const { text, line } of runtimeCode(source))
        violations.push(`${relative(root, file)}:${line}: app-core has no runtime exports (${text})`);
    if (isModuleProtocol(file, owner) && references(source).length)
      violations.push(`${relative(root, file)}: a module's data protocol imports nothing`);
    if (owner.app && ["chat/protocol.ts", "jobs/protocol.ts"].includes(relative(owner.source, file)) && references(source).length)
      violations.push(`${relative(root, file)}: browser-shared data protocols cannot import modules`);
    const from = layer(file, owner), name = relative(root, file), edges: string[] = [];
    dependencies.set(name, edges);
    const consumer = graphConsumer(file, owner);
    if (isScheduling(file, owner))
      for (const { text, line } of namedIdentifiers(source, closedModelUnion))
        violations.push(`${name}:${line}: scheduling takes the structural graph interface (MlxTokenGraph), not the closed ${text} union of concrete models`);
    if (consumer)
      for (const { text, line } of identityChecks(source))
        violations.push(`${name}:${line}: ${consumer} cannot branch on model identity (${text}); read a declared capability`);
    for (const { specifier, line } of references(source)) {
      const at = `${name}:${line}`;
      if (specifier === undefined) { violations.push(`${at}: nonliteral module reference`); continue; }
      // A workspace may read its own package metadata (e.g. CLI --version).
      if (specifier.startsWith(".") && resolve(dirname(file), specifier) === resolve(owner.source, "../package.json")) continue;
      const dependency = owner.dependencies.find(name => specifier === name || specifier.startsWith(`${name}/`));
      const siteContentApi = owner.name === "mlx-bun-website" && owner.dependencies.includes("astro") &&
        relative(owner.source, file) === "content.config.ts" && specifier === "astro:content";
      const isExternal = siteContentApi || external.has(specifier) || (dependency !== undefined && !names.includes(dependency));
      if (inModulePanel(file, owner) && (external.has(specifier) || (dependency !== undefined && !names.includes(dependency)))) {
        violations.push(`${at}: panel code imports only panel files and its protocol.ts (${specifier})`); continue;
      }
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
      if (inModulePanel(file, owner) && !(targetOwner === owner &&
          (actual.startsWith(resolve(owner.source, "panel") + "/") || actual === resolve(owner.source, "protocol.ts"))))
        violations.push(`${at}: panel code imports only panel files and its protocol.ts (${specifier})`);
      if (owner.name === coreName && targetOwner !== owner) violations.push(`${at}: app-core has no workspace imports (${specifier})`);
      if (targetOwner.name === coreName && belowApp(owner)) violations.push(`${at}: libraries below the app never import app-core`);
      if (isModulePackage(owner.name) && targetOwner !== owner && targetOwner.name !== coreName &&
          (targetOwner.app || isModulePackage(targetOwner.name) || isHostLibrary(targetOwner.name)))
        violations.push(`${at}: a module imports only app-core, domain libraries and its own files, not ${
          targetOwner.app ? "an app" : isModulePackage(targetOwner.name) ? "another module" : "a core-service implementation"} (${specifier})`);
      if (isModulePackage(targetOwner.name) && targetOwner !== owner && !isModulePackage(owner.name)) {
        if (isCompositionFile(file, owner)) named.get(owner)!.add(targetOwner.name);
        else violations.push(`${at}: only a host's src/modules.ts imports module packages (${specifier})`);
      }
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
      if (consumer && targetOwner.name === "@mlx-bun/inference" &&
          relative(targetOwner.source, actual).startsWith("models/") && !graphContracts.has(relative(targetOwner.source, actual)))
        violations.push(`${at}: ${consumer} cannot import a concrete model (${specifier}); consume its declared capabilities`);
      edges.push(relative(root, actual));
    }
  }
  for (const owner of libraries.filter(item => item.app)) {
    const listed = owner.dependencies.filter(isModulePackage).toSorted(), imported = [...named.get(owner)!].toSorted();
    if (JSON.stringify(listed) !== JSON.stringify(imported))
      violations.push(`${owner.name}: package.json lists modules [${listed}] but src/modules.ts names [${imported}]`);
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

test("the app cannot name concrete draft providers", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-draft-provider-boundaries-"));
  const write = (path: string, text: string) => {
    const target = resolve(root, path);
    mkdirSync(dirname(target), { recursive: true }); writeFileSync(target, text);
  };
  try {
    write("packages/mlx/package.json", JSON.stringify({ name: "@mlx-bun/mlx", type: "module", exports: { ".": "./src/index.ts" } }));
    write("packages/mlx/src/index.ts", "export const mlx = true;");
    write("packages/inference/package.json", JSON.stringify({ name: "@mlx-bun/inference", type: "module", dependencies: { "@mlx-bun/mlx": "workspace:*",
      "@huggingface/tokenizers": "1", "@huggingface/jinja": "1", "fast-png": "1", "@mlc-ai/web-xgrammar": "1" },
    exports: { ".": "./src/index.ts", "./generation/speculative": "./src/generation/speculative/index.ts" } }));
    write("packages/inference/src/index.ts", "export const api = true;");
    write("packages/inference/src/generation/speculative/index.ts",
      'export * from "./sources/example-source"; export * from "./draft-registry";');
    write("packages/inference/src/generation/speculative/sources/example-source.ts", "export class ExampleProvider { static load() { return new ExampleProvider(); } }");
    write("packages/inference/src/generation/speculative/draft-registry.ts", "export class DraftProviderRegistry {}");
    write("apps/mlx-bun/package.json", JSON.stringify({ name: "mlx-bun", type: "module", dependencies: { "@mlx-bun/inference": "workspace:*" } }));
    mkdirSync(resolve(root, "node_modules/@mlx-bun"), { recursive: true });
    symlinkSync(resolve(root, "packages/inference"), resolve(root, "node_modules/@mlx-bun/inference"));
    symlinkSync(resolve(root, "packages/mlx"), resolve(root, "node_modules/@mlx-bun/mlx"));
    const engine = "apps/mlx-bun/src/engine/host.ts";
    write(engine, 'import { DraftProviderRegistry } from "@mlx-bun/inference/generation/speculative"; export const registry = new DraftProviderRegistry();');
    expect(await inspectWorkspaces(root)).toEqual([]);
    write(engine, 'export const load = async () => { const { ExampleProvider } = await import("@mlx-bun/inference/generation/speculative"); return ExampleProvider.load(); };');
    const named = await inspectWorkspaces(root);
    expect(named.filter(item => item.includes("the app cannot name a concrete draft provider (ExampleProvider)")).length).toBe(2);
    // The library's own modules, and the registry class, are unaffected.
    write(engine, "export const engine = 1;");
    expect(await inspectWorkspaces(root)).toEqual([]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("scheduling, engine, server, CLI and training code cannot import concrete models or branch on model identity", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-scheduling-boundaries-"));
  const write = (path: string, text: string) => {
    const target = resolve(root, path);
    mkdirSync(dirname(target), { recursive: true }); writeFileSync(target, text);
  };
  const inference = { name: "@mlx-bun/inference", type: "module", exports: { ".": "./src/index.ts", "./models": "./src/models/index.ts",
    "./models/gemma4": "./src/models/gemma4/model.ts" }, dependencies: { "@mlx-bun/mlx": "workspace:*",
    "@huggingface/tokenizers": "1", "@huggingface/jinja": "1", "fast-png": "1", "@mlc-ai/web-xgrammar": "1" } };
  try {
    write("packages/mlx/package.json", JSON.stringify({ name: "@mlx-bun/mlx", type: "module", exports: { ".": "./src/index.ts" } }));
    write("packages/mlx/src/index.ts", "export const mlx = true;");
    write("packages/inference/package.json", JSON.stringify(inference));
    write("packages/inference/src/index.ts", "export const api = true;");
    write("packages/inference/src/models/index.ts", 'export * from "./factory"; export * from "./capabilities";');
    write("packages/inference/src/models/factory.ts", 'import { Gemma4Model } from "./gemma4/model"; export type RuntimeModel = Gemma4Model;');
    write("packages/inference/src/models/capabilities.ts", "export const declaredGraph = (model: object) => model;");
    write("packages/inference/src/models/gemma4/model.ts", "export class Gemma4Model { modelType = 'gemma4'; }");
    write("apps/mlx-bun/package.json", JSON.stringify({ name: "mlx-bun", type: "module", dependencies: { "@mlx-bun/inference": "workspace:*" } }));
    write("packages/training/package.json", JSON.stringify({ name: "@mlx-bun/training", type: "module", exports: { ".": "./src/index.ts" },
      dependencies: { "@mlx-bun/inference": "workspace:*" } }));
    write("packages/training/src/index.ts", "export const training = true;");
    mkdirSync(resolve(root, "node_modules/@mlx-bun"), { recursive: true });
    symlinkSync(resolve(root, "packages/inference"), resolve(root, "node_modules/@mlx-bun/inference"));
    symlinkSync(resolve(root, "packages/mlx"), resolve(root, "node_modules/@mlx-bun/mlx"));
    const scheduler = "packages/inference/src/execution/plan.ts", engine = "apps/mlx-bun/src/engine/host.ts";
    write(scheduler, 'import { declaredGraph } from "../models/capabilities"; export const plan = (m: object) => declaredGraph(m);');
    write(engine, 'import { declaredGraph, type RuntimeModel } from "@mlx-bun/inference/models"; export const host = (m: RuntimeModel) => declaredGraph(m);');
    expect(await inspectWorkspaces(root)).toEqual([]);
    // Scheduling takes the structural graph interface, not the closed union of model classes.
    write(scheduler, 'import type { RuntimeModel } from "../models/factory"; export const plan = (m: RuntimeModel) => m;');
    expect((await inspectWorkspaces(root)).some(item => item.includes("execution/plan.ts:1: scheduling takes the structural graph interface (MlxTokenGraph), not the closed RuntimeModel union"))).toBe(true);
    write(scheduler, 'import { Gemma4Model } from "../models/gemma4/model"; export const paged = (m: object) => m instanceof Gemma4Model;');
    const scheduled = await inspectWorkspaces(root);
    expect(scheduled.some(item => item.includes("cannot import a concrete model (../models/gemma4/model)"))).toBe(true);
    expect(scheduled.some(item => item.includes("branch on model identity (instanceof Gemma4Model)"))).toBe(true);
    write(engine, 'import { Gemma4Model } from "@mlx-bun/inference/models/gemma4"; export const kind = (m: object) => m instanceof Gemma4Model;');
    expect((await inspectWorkspaces(root)).some(item => item.includes("apps/mlx-bun/src/engine/host.ts:1: scheduling, engine, server and CLI code cannot import a concrete model"))).toBe(true);
    write(scheduler, "export const plan = 1;");
    write(engine, 'export const gemma = (m: { config: { modelType: string } }) => m.config.modelType.startsWith("gemma4") || m.config.modelType === "qwen3";');
    const typed = await inspectWorkspaces(root);
    expect(typed.filter(item => item.includes("matching a model type")).length).toBe(1);
    expect(typed.filter(item => item.includes("comparing a model type")).length).toBe(1);
    write(engine, 'export const flag = (r: { flag(name: string): boolean }) => r.flag("MLX_BUN_QWEN_SPEC_KV4");');
    expect((await inspectWorkspaces(root)).some(item => item.includes("model-scoped flag MLX_BUN_QWEN_SPEC_KV4"))).toBe(true);
    // Training consumes a graph's declared training operations the same way.
    write(engine, "export const engine = 1;");
    const trainer = "packages/training/src/trainer.ts";
    write(trainer, 'import type { RuntimeModel } from "@mlx-bun/inference/models"; export const train = (m: RuntimeModel) => m;');
    write("packages/training/src/index.ts", 'export * from "./trainer";');
    expect(await inspectWorkspaces(root)).toEqual([]);
    write(trainer, 'import { Gemma4Model } from "@mlx-bun/inference/models/gemma4"; export const segmented = (m: object) => m instanceof Gemma4Model;');
    const trained = await inspectWorkspaces(root);
    expect(trained.some(item => item.includes("packages/training/src/trainer.ts:1: training code cannot import a concrete model (@mlx-bun/inference/models/gemma4)"))).toBe(true);
    expect(trained.some(item => item.includes("training code cannot branch on model identity (instanceof Gemma4Model)"))).toBe(true);
    write(trainer, "export const train = 1;");
    // The same code outside scheduling, engine and training (a model's own binding) is unaffected.
    write("packages/inference/src/models/gemma4/binding.ts", 'import { Gemma4Model } from "./model"; export const own = (m: object) => m instanceof Gemma4Model;');
    expect(await inspectWorkspaces(root)).toEqual([]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("the server and CLI read declared facts: no model type, architecture, family predicate or concrete model", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-app-boundaries-"));
  const write = (path: string, text: string) => {
    const target = resolve(root, path);
    mkdirSync(dirname(target), { recursive: true }); writeFileSync(target, text);
  };
  const inference = { name: "@mlx-bun/inference", type: "module", exports: { ".": "./src/index.ts", "./models": "./src/models/index.ts",
    "./models/support": "./src/models/support.ts", "./models/gemma4": "./src/models/gemma4/model.ts" },
  dependencies: { "@mlx-bun/mlx": "workspace:*", "@huggingface/tokenizers": "1", "@huggingface/jinja": "1", "fast-png": "1", "@mlc-ai/web-xgrammar": "1" } };
  try {
    write("packages/mlx/package.json", JSON.stringify({ name: "@mlx-bun/mlx", type: "module", exports: { ".": "./src/index.ts" } }));
    write("packages/mlx/src/index.ts", "export const mlx = true;");
    write("packages/inference/package.json", JSON.stringify(inference));
    write("packages/inference/src/index.ts", "export const api = true;");
    write("packages/inference/src/models/index.ts", 'export * from "./support";');
    write("packages/inference/src/models/support.ts",
      "export const supportTier = (type: string) => type; export const isMiniCPM5Config = (config: object) => !!config; export const isTranscriptionModelType = (type: string) => !!type;");
    write("packages/inference/src/models/gemma4/model.ts", "export class Gemma4Model { modelType = 'gemma4'; }");
    write("apps/mlx-bun/package.json", JSON.stringify({ name: "mlx-bun", type: "module", dependencies: { "@mlx-bun/inference": "workspace:*" } }));
    mkdirSync(resolve(root, "node_modules/@mlx-bun"), { recursive: true });
    symlinkSync(resolve(root, "packages/inference"), resolve(root, "node_modules/@mlx-bun/inference"));
    symlinkSync(resolve(root, "packages/mlx"), resolve(root, "node_modules/@mlx-bun/mlx"));
    const server = "apps/mlx-bun/src/server/prep.ts", cli = "apps/mlx-bun/src/cli/pick.ts";
    write(server, 'import { supportTier, isTranscriptionModelType } from "@mlx-bun/inference/models/support"; export const tier = (t: string) => supportTier(t) && isTranscriptionModelType(t);');
    write(cli, "export const cli = 1;");
    expect(await inspectWorkspaces(root)).toEqual([]);
    write(server, 'export const tools = (m: { config: { modelType: string } }) => m.config.modelType.startsWith("gemma4");');
    expect((await inspectWorkspaces(root)).some(item => item.includes("apps/mlx-bun/src/server/prep.ts:1: scheduling, engine, server and CLI code cannot branch on model identity (matching a model type)"))).toBe(true);
    write(cli, 'export const speech = (m: { modelType: string }) => m.modelType === "whisper";');
    expect((await inspectWorkspaces(root)).some(item => item.includes("apps/mlx-bun/src/cli/pick.ts:1:") && item.includes("comparing a model type"))).toBe(true);
    write(cli, 'export const first = (c: { architectures: string[] }) => c.architectures[0] === "X" || c.architectures.includes("Y");');
    const architectures = (await inspectWorkspaces(root)).filter(item => item.includes("apps/mlx-bun/src/cli/pick.ts:1:"));
    expect(architectures.some(item => item.includes("comparing a model type"))).toBe(true);
    expect(architectures.some(item => item.includes("matching a model type"))).toBe(true);
    write(server, 'import { isMiniCPM5Config } from "@mlx-bun/inference/models/support"; export const off = isMiniCPM5Config;');
    expect((await inspectWorkspaces(root)).some(item => item.includes("family predicate isMiniCPM5Config"))).toBe(true);
    write(server, 'import { Gemma4Model } from "@mlx-bun/inference/models/gemma4"; export const kind = (m: object) => m instanceof Gemma4Model;');
    const concrete = await inspectWorkspaces(root);
    expect(concrete.some(item => item.includes("cannot import a concrete model"))).toBe(true);
    expect(concrete.some(item => item.includes("instanceof Gemma4Model"))).toBe(true);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

/** A workspace with the modular-application packages: contracts, host library, a domain library, two modules and a host. */
function moduleWorkspace() {
  const root = mkdtempSync(join(tmpdir(), "mlx-module-boundaries-"));
  const write = (path: string, text: string) => {
    const target = resolve(root, path);
    mkdirSync(dirname(target), { recursive: true }); writeFileSync(target, text);
  };
  const manifest = (path: string, name: string, dependencies: Record<string, string> = {}) =>
    write(`${path}/package.json`, JSON.stringify({ name, type: "module", exports: { ".": path.startsWith("apps/") ? "./src/cli/main.ts" : "./src/index.ts", "./panel": "./src/panel/index.ts" },
      dependencies: Object.fromEntries(Object.keys(dependencies).map(dependency => [dependency, "workspace:*"])) }));
  const link = (name: string, path: string) => {
    mkdirSync(dirname(resolve(root, "node_modules", name)), { recursive: true });
    symlinkSync(resolve(root, path), resolve(root, "node_modules", name));
  };
  const packages: [string, string, Record<string, string>][] = [
    ["packages/app-core", "@mlx-bun/app-core", {}],
    ["packages/app-host", "@mlx-bun/app-host", { "@mlx-bun/app-core": "" }],
    ["packages/hub", "@mlx-bun/hub", {}],
    ["packages/module-a", "@mlx-bun/module-a", { "@mlx-bun/app-core": "", "@mlx-bun/hub": "" }],
    ["packages/module-b", "@mlx-bun/module-b", { "@mlx-bun/app-core": "" }],
    ["apps/example", "example-host", { "@mlx-bun/app-core": "", "@mlx-bun/app-host": "", "@mlx-bun/module-a": "" }],
  ];
  for (const [path, name, dependencies] of packages) { manifest(path, name, dependencies); link(name, path); }
  write("packages/app-core/src/index.ts", 'export type * from "./module"; export type { Thing as Renamed } from "./module";');
  write("packages/app-core/src/module.ts", "export interface Thing { id: string }\nexport type Id = string;");
  write("packages/app-host/src/index.ts", 'import type { Thing } from "@mlx-bun/app-core"; export const load = (thing: Thing) => thing.id;');
  write("packages/hub/src/index.ts", "export const hub = 1;");
  write("packages/module-a/src/index.ts", 'import type { Thing } from "@mlx-bun/app-core"; import { hub } from "@mlx-bun/hub"; import { own } from "./own"; export default { id: "a", hub, own } satisfies Thing | object;');
  write("packages/module-a/src/own.ts", "export const own = 1;");
  write("packages/module-a/src/protocol.ts", "export interface Progress { done: number }");
  write("packages/module-a/src/panel/index.ts", 'import type { Progress } from "../protocol"; import { helper } from "./helper"; export const panel = (p: Progress) => helper(p.done);');
  write("packages/module-a/src/panel/helper.ts", "export const helper = (n: number) => n;");
  write("packages/module-b/src/index.ts", "export default { id: \"b\" };");
  write("apps/example/src/modules.ts", 'import a from "@mlx-bun/module-a"; import type { Thing } from "@mlx-bun/app-core"; export const modules: readonly unknown[] = [a]; export type T = Thing;');
  write("apps/example/src/cli/main.ts", 'import { modules } from "../modules"; import { load } from "@mlx-bun/app-host"; export const main = () => [modules, load];');
  return { root, write, manifest, packages, cleanup: () => rmSync(root, { recursive: true, force: true }) };
}
const mentions = (violations: string[], text: string) => violations.some(item => item.includes(text));

test("app-core is types only: no runtime export, value, side-effect import or workspace dependency", async () => {
  const { root, write, manifest, cleanup } = moduleWorkspace();
  try {
    expect(await inspectWorkspaces(root)).toEqual([]);
    for (const [code, expected] of [
      ["export const value = 1;", "value"], ["export function run() {}", "function"],
      ["export enum Mode { A }", "enum"], ['export * from "./module";', "export * (use export type *)"],
      ['export { Thing } from "./module";', "runtime re-export Thing"], ['import "./module";', "side-effect import"],
      ["export default 1;", "default export"],
    ] as const) {
      write("packages/app-core/src/index.ts", code);
      expect(mentions(await inspectWorkspaces(root), `app-core has no runtime exports (${expected})`)).toBe(true);
    }
    write("packages/app-core/src/index.ts", 'export type { Thing } from "./module"; export interface Extra { id: string }');
    expect(await inspectWorkspaces(root)).toEqual([]);
    write("packages/app-core/src/index.ts", 'import type { Progress } from "@mlx-bun/module-a"; export type P = Progress;');
    manifest("packages/app-core", "@mlx-bun/app-core", { "@mlx-bun/hub": "" });
    const violations = await inspectWorkspaces(root);
    expect(mentions(violations, "app-core has no workspace dependencies (@mlx-bun/hub)")).toBe(true);
    expect(mentions(violations, "app-core has no workspace imports")).toBe(true);
  } finally { cleanup(); }
});

test("a module imports only app-core, declared domain libraries and its own files", async () => {
  const { root, write, manifest, cleanup } = moduleWorkspace();
  try {
    for (const [code, expected] of [
      ['import b from "@mlx-bun/module-b"; export default b;', "not another module"],
      ['import { load } from "@mlx-bun/app-host"; export default load;', "not a core-service implementation"],
      ['import { main } from "example-host"; export default main;', "not an app"],
    ] as const) {
      write("packages/module-a/src/index.ts", code);
      manifest("packages/module-a", "@mlx-bun/module-a", { "@mlx-bun/app-core": "", "@mlx-bun/hub": "", "@mlx-bun/module-b": "", "@mlx-bun/app-host": "", "example-host": "" });
      const violations = await inspectWorkspaces(root);
      expect(mentions(violations, `packages/module-a/src/index.ts:1: a module imports only app-core, domain libraries and its own files, ${expected}`)).toBe(true);
    }
    // The declaration itself is a violation, even before any import uses it.
    write("packages/module-a/src/index.ts", "export default 1;");
    const declared = await inspectWorkspaces(root);
    for (const name of ["@mlx-bun/module-b", "@mlx-bun/app-host", "example-host"])
      expect(mentions(declared, `a module depends only on app-core and domain libraries (${name})`)).toBe(true);
    // Reaching into a sibling package's files is rejected as a private path.
    manifest("packages/module-a", "@mlx-bun/module-a", { "@mlx-bun/app-core": "" });
    write("packages/module-a/src/index.ts", 'export { default } from "../../module-b/src/index";');
    expect(mentions(await inspectWorkspaces(root), "not another module")).toBe(true);
  } finally { cleanup(); }
});

test("libraries below the app never import or depend on app-core", async () => {
  const { root, write, manifest, cleanup } = moduleWorkspace();
  try {
    write("packages/hub/src/index.ts", 'import type { Thing } from "@mlx-bun/app-core"; export type Hub = Thing;');
    expect(mentions(await inspectWorkspaces(root), "packages/hub/src/index.ts:1: libraries below the app never import app-core")).toBe(true);
    manifest("packages/hub", "@mlx-bun/hub", { "@mlx-bun/app-core": "" });
    expect(mentions(await inspectWorkspaces(root), "@mlx-bun/hub: libraries below the app never depend on app-core")).toBe(true);
    write("packages/hub/src/index.ts", "export const hub = 1;");
    manifest("packages/hub", "@mlx-bun/hub");
    expect(await inspectWorkspaces(root)).toEqual([]);
  } finally { cleanup(); }
});

test("only a host's src/modules.ts imports module packages, and package.json lists exactly the modules it names", async () => {
  const { root, write, manifest, cleanup } = moduleWorkspace();
  try {
    write("apps/example/src/cli/main.ts", 'import b from "@mlx-bun/module-b"; export const main = b;');
    manifest("apps/example", "example-host", { "@mlx-bun/app-core": "", "@mlx-bun/app-host": "", "@mlx-bun/module-a": "", "@mlx-bun/module-b": "" });
    const other = await inspectWorkspaces(root);
    expect(mentions(other, "apps/example/src/cli/main.ts:1: only a host's src/modules.ts imports module packages")).toBe(true);
    expect(mentions(other, "package.json lists modules [@mlx-bun/module-a,@mlx-bun/module-b] but src/modules.ts names [@mlx-bun/module-a]")).toBe(true);
    write("apps/example/src/cli/main.ts", "export const main = 1;");
    write("apps/example/src/modules.ts", 'import a from "@mlx-bun/module-a"; import b from "@mlx-bun/module-b"; export const modules = [a, b];');
    expect(await inspectWorkspaces(root)).toEqual([]);
    // Naming a module without listing it, and listing one without naming it.
    manifest("apps/example", "example-host", { "@mlx-bun/app-core": "", "@mlx-bun/app-host": "", "@mlx-bun/module-a": "" });
    expect(mentions(await inspectWorkspaces(root), "lists modules [@mlx-bun/module-a] but src/modules.ts names [@mlx-bun/module-a,@mlx-bun/module-b]")).toBe(true);
    write("apps/example/src/modules.ts", "export const modules = [];");
    expect(mentions(await inspectWorkspaces(root), "lists modules [@mlx-bun/module-a] but src/modules.ts names []")).toBe(true);
    // A host with no modules lists none.
    manifest("apps/example", "example-host", { "@mlx-bun/app-core": "", "@mlx-bun/app-host": "" });
    expect(await inspectWorkspaces(root)).toEqual([]);
    // A library, including the host library, never names a module either.
    write("packages/app-host/src/index.ts", 'import a from "@mlx-bun/module-a"; export const load = a;');
    manifest("packages/app-host", "@mlx-bun/app-host", { "@mlx-bun/app-core": "", "@mlx-bun/module-a": "" });
    expect(mentions(await inspectWorkspaces(root), "packages/app-host/src/index.ts:1: only a host's src/modules.ts imports module packages")).toBe(true);
  } finally { cleanup(); }
});

test("hosts never depend on hosts", async () => {
  const { root, write, manifest, cleanup } = moduleWorkspace();
  try {
    manifest("apps/other", "other-host", { "example-host": "" });
    write("apps/other/src/modules.ts", "export const modules = [];");
    expect(mentions(await inspectWorkspaces(root), "other-host: hosts never depend on hosts (example-host)")).toBe(true);
  } finally { cleanup(); }
});

test("module, host-library and host code cannot branch on model identity or import a concrete model", async () => {
  const { root, write, manifest, cleanup } = moduleWorkspace();
  try {
    write("packages/inference/package.json", JSON.stringify({ name: "@mlx-bun/inference", type: "module", exports: { ".": "./src/index.ts", "./models/gemma4": "./src/models/gemma4/model.ts" },
      dependencies: { "@mlx-bun/mlx": "workspace:*", "@huggingface/tokenizers": "1", "@huggingface/jinja": "1", "fast-png": "1", "@mlc-ai/web-xgrammar": "1" } }));
    write("packages/mlx/package.json", JSON.stringify({ name: "@mlx-bun/mlx", type: "module", exports: { ".": "./src/index.ts" } }));
    write("packages/mlx/src/index.ts", "export const mlx = 1;");
    write("packages/inference/src/index.ts", "export const api = 1;");
    write("packages/inference/src/models/gemma4/model.ts", "export class Gemma4Model {}");
    symlinkSync(resolve(root, "packages/inference"), resolve(root, "node_modules/@mlx-bun/inference"));
    symlinkSync(resolve(root, "packages/mlx"), resolve(root, "node_modules/@mlx-bun/mlx"));
    const identity = 'export const kind = (m: { config: { modelType: string } }, x: object) => m.config.modelType === "gemma4" || x instanceof Object;';
    const concrete = 'import { Gemma4Model } from "@mlx-bun/inference/models/gemma4"; export const kind = (x: object) => x instanceof Gemma4Model;';
    for (const [file, deps] of [
      ["packages/module-a/src/index.ts", { "@mlx-bun/app-core": "", "@mlx-bun/inference": "" }],
      ["packages/app-host/src/index.ts", { "@mlx-bun/app-core": "", "@mlx-bun/inference": "" }],
      ["apps/example/src/modules.ts", { "@mlx-bun/app-core": "", "@mlx-bun/app-host": "", "@mlx-bun/inference": "" }],
      ["apps/example/src/chat/anything.ts", { "@mlx-bun/app-core": "", "@mlx-bun/app-host": "", "@mlx-bun/inference": "" }],
    ] as const) {
      const [path] = file.split("/src/");
      const name = path!.startsWith("apps/") ? "example-host" : path!.endsWith("app-host") ? "@mlx-bun/app-host" : "@mlx-bun/module-a";
      manifest(path!, name, deps);
      if (path === "apps/example") manifest(path, name, { ...deps, "@mlx-bun/module-a": "" });
      write(file, identity);
      const branched = await inspectWorkspaces(root);
      expect(mentions(branched, `${file}:1: module and host code cannot branch on model identity (comparing a model type)`)).toBe(true);
      write(file, concrete);
      const imported = await inspectWorkspaces(root);
      expect(mentions(imported, `${file}:1: module and host code cannot import a concrete model`)).toBe(true);
      expect(mentions(imported, "instanceof Gemma4Model")).toBe(true);
      // Restore the fixture file.
      write(file, "export const restored = 1;");
    }
  } finally { cleanup(); }
});

test("panel code imports only panel files and its protocol.ts, and the protocol imports nothing", async () => {
  const { root, write, cleanup } = moduleWorkspace();
  try {
    expect(await inspectWorkspaces(root)).toEqual([]);
    const panel = "packages/module-a/src/panel/index.ts";
    for (const specifier of ["../own", "@mlx-bun/app-core", "@mlx-bun/hub", "node:fs", "bun", "../index"]) {
      write(panel, `import * as x from ${JSON.stringify(specifier)}; export const y = x;`);
      expect(mentions(await inspectWorkspaces(root), `${panel}:1: panel code imports only panel files and its protocol.ts (${specifier})`)).toBe(true);
    }
    write(panel, 'import type { Progress } from "../protocol"; import { helper } from "./helper"; export const p = (x: Progress) => helper(x.done);');
    expect(await inspectWorkspaces(root)).toEqual([]);
    write("packages/module-a/src/protocol.ts", 'import type { Thing } from "@mlx-bun/app-core"; export type Progress = Thing;');
    expect(mentions(await inspectWorkspaces(root), "packages/module-a/src/protocol.ts: a module's data protocol imports nothing")).toBe(true);
    write("packages/module-a/src/protocol.ts", 'export type Progress = { done: number }; import "./own";');
    expect(mentions(await inspectWorkspaces(root), "a module's data protocol imports nothing")).toBe(true);
    // Only panel and protocol files are held to this: module server code may import the module's own files.
    write("packages/module-a/src/protocol.ts", "export interface Progress { done: number }");
    write("packages/module-a/src/index.ts", 'import { own } from "./own"; import type { Progress } from "./protocol"; export default { own } satisfies object; export type P = Progress;');
    expect(await inspectWorkspaces(root)).toEqual([]);
  } finally { cleanup(); }
});
