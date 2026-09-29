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
const appDomains: Record<string, string[]> = { cli: ["engine", "server", "chat", "web", "jobs", "finetune", "publishing", "memory", "hub", "storage", "modules.ts"], "modules.ts": [], engine: [], chat: ["storage"], server: ["engine", "chat", "memory", "jobs", "finetune", "publishing", "hub", "storage"], memory: ["storage"], finetune: ["jobs"], publishing: ["storage"], jobs: ["storage"], hub: [], storage: [], web: ["chat", "jobs"] };
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
/** The family registry lists one record per family (`models/families.ts`); the role predicates of
 * `models/support.ts` (`supportTier`, `isSupportedModelRecord`, `is<Role>ModelType`) are the only
 * ones consumers may use, and a per-family structural predicate must not reappear as an export. */
const familyPredicate = /^is(Gemma|Qwen|MiniCPM|Llama|Glm|Diffusion|Whisper|Universal)\w*Config$/i;
const familyWord = /(gemma|qwen|minicpm|llama|glm|diffusion|universal)/i;

// Modular application (ARCHITECTURE.md): `app-core` holds the contracts, `app-host`
// (and later service implementations) the host side, `module-<id>` the features.
const coreName = "@mlx-bun/app-core";
const isModulePackage = (name: string) => name.startsWith("@mlx-bun/module-");
/** The web shell: browser code every host's UI reuses. It depends on no workspace package; modules never depend on it. */
const webShellName = "@mlx-bun/web-shell";
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

/** Concrete cache classes: the classes under `state/` that declare `signature()` (the Cache
 * contract's identity) or extend one, with the file each lives in. */
function cacheClasses(sources: ReadonlyMap<string, ts.SourceFile>, stateRoot: string): { name: string; file: string }[] {
  const classes: { name: string; file: string; signature: boolean; base: string | undefined }[] = [];
  for (const [file, source] of sources) {
    if (!file.startsWith(stateRoot + "/")) continue;
    for (const node of source.statements) {
      if (!ts.isClassDeclaration(node) || !node.name) continue;
      const base = node.heritageClauses?.find(clause => clause.token === ts.SyntaxKind.ExtendsKeyword)?.types[0]?.expression;
      classes.push({ name: node.name.text, file, base: base && ts.isIdentifier(base) ? base.text : undefined,
        signature: node.members.some(member => ts.isMethodDeclaration(member) && ts.isIdentifier(member.name) && member.name.text === "signature") });
    }
  }
  const caches = new Set(classes.filter(item => item.signature).map(item => item.name));
  for (let grown = true; grown;) {
    grown = false;
    for (const item of classes) if (item.base && caches.has(item.base) && !caches.has(item.name)) { caches.add(item.name); grown = true; }
  }
  return classes.filter(item => caches.has(item.name)).map(({ name, file }) => ({ name, file }));
}

/** Concrete cache modules: the files under `state/` that export a cache class. Scheduling moves
 * rows through the row-layout port (`state/layout`) and never names a storage family. */
function cacheModules(sources: ReadonlyMap<string, ts.SourceFile>, stateRoot: string): Set<string> {
  return new Set(cacheClasses(sources, stateRoot).map(item => item.file));
}

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

/** What "which family is this?" looks like in code: comparing or pattern-matching a config's
 * model type, or importing a per-family predicate. */
function familyIdentityChecks(source: ts.SourceFile): { text: string; line: number }[] {
  return identityChecks(source).filter(({ text }) => text === "comparing a model type" || text === "matching a model type" ||
    text.startsWith("family predicate"));
}

/** The only inference source that may decide which family a config is: the family registry and the
 * families' own directories (their records and their graphs), and the artifact readers that
 * spell how a `model_type`'s `config.json` is laid out. Everything else asks the registry. */
function ownsFamilyIdentity(name: string): boolean {
  return name === "models/families.ts" || name === "models/family.ts" || /^models\/[^/]+\//.test(name) ||
    name === "artifacts/config-dialects.ts" || name === "artifacts/glm52-config.ts";
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

async function readLibraries(root: string): Promise<Library[]> {
  const libraries: Library[] = [];
  for await (const file of new Bun.Glob("{packages,apps}/*/package.json").scan(root)) {
    const manifest = await Bun.file(resolve(root, file)).json();
    libraries.push({ app: file.startsWith("apps/"), name: manifest.name, source: resolve(root, dirname(file), "src"),
      dependencies: Object.keys({ ...manifest.dependencies, ...manifest.optionalDependencies, ...manifest.peerDependencies }) });
  }
  return libraries;
}

async function readSources(libraries: readonly Library[]): Promise<Map<string, ts.SourceFile>> {
  const sources = new Map<string, ts.SourceFile>();
  for (const library of libraries) {
    for await (const file of new Bun.Glob("**/*.{ts,tsx,js,mjs,cjs}").scan(library.source)) {
      const absolute = resolve(library.source, file);
      sources.set(absolute, ts.createSourceFile(absolute, await Bun.file(absolute).text(), ts.ScriptTarget.Latest, true));
    }
  }
  return sources;
}

async function inspectWorkspaces(root: string): Promise<string[]> {
  root = realpathSync(root);
  const libraries = await readLibraries(root);
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
      if (dependency.name !== coreName && (dependency.app || isModulePackage(dependency.name) || isHostLibrary(dependency.name) || dependency.name === webShellName))
        violations.push(`${owner.name}: a module depends only on app-core and domain libraries (${dependency.name})`);
    if (owner.name === webShellName && workspaceDependencies.length)
      violations.push(`${owner.name}: the web shell has no workspace dependencies (${workspaceDependencies.map(item => item.name).join(", ")})`);
  }
  const packageGraph = new Map(libraries.map(item => [item.name, item.dependencies.filter(name => names.includes(name))]));
  violations.push(...cycles(packageGraph).map(cycle => `Package cycle: ${cycle}`));
  const ownerOf = (path: string) => libraries.find(item => path.startsWith(`${item.source}/`));
  const options: ts.CompilerOptions = { moduleResolution: ts.ModuleResolutionKind.Bundler, module: ts.ModuleKind.Preserve };
  const cache = ts.createModuleResolutionCache(root, path => path, options);
  const sources = await readSources(libraries);
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
  const cacheFiles = inferencePackage ? cacheModules(sources, resolve(inferencePackage.source, "state")) : new Set<string>();
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
    else if (owner.name === "@mlx-bun/inference" && !ownsFamilyIdentity(relative(owner.source, file)))
      for (const { text, line } of familyIdentityChecks(source))
        violations.push(`${name}:${line}: only the family registry decides which family a model is (${text}); resolve the family or read its declaration`);
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
      if (owner.name === webShellName && isExternal) {
        violations.push(`${at}: the web shell is browser code and imports only its own files (${specifier})`); continue;
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
      const targetOwner = ownerOf(actual)!;
      if (browser && !(actual.startsWith(resolve(owner.source, "web/browser") + "/") || targetOwner.name === webShellName ||
          actual === resolve(owner.source, "chat/protocol.ts") || actual === resolve(owner.source, "jobs/protocol.ts")))
        violations.push(`${at}: browser may import only browser modules, the web shell and data protocols (${specifier})`);
      if (owner.name === webShellName && targetOwner !== owner)
        violations.push(`${at}: the web shell is browser code and imports only its own files (${specifier})`);
      const to = layer(actual, targetOwner);
      if (inModulePanel(file, owner) && !(targetOwner === owner &&
          (actual.startsWith(resolve(owner.source, "panel") + "/") || actual === resolve(owner.source, "protocol.ts"))))
        violations.push(`${at}: panel code imports only panel files and its protocol.ts (${specifier})`);
      if (owner.name === coreName && targetOwner !== owner) violations.push(`${at}: app-core has no workspace imports (${specifier})`);
      if (targetOwner.name === coreName && belowApp(owner)) violations.push(`${at}: libraries below the app never import app-core`);
      if (isModulePackage(owner.name) && targetOwner !== owner && targetOwner.name !== coreName &&
          (targetOwner.app || isModulePackage(targetOwner.name) || isHostLibrary(targetOwner.name) || targetOwner.name === webShellName))
        violations.push(`${at}: a module imports only app-core, domain libraries and its own files, not ${
          targetOwner.app ? "an app" : isModulePackage(targetOwner.name) ? "another module" : targetOwner.name === webShellName ? "the web shell" : "a core-service implementation"} (${specifier})`);
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
      if (isScheduling(file, owner) && cacheFiles.has(actual))
        violations.push(`${at}: scheduling reaches storage through the row-layout port (state/layout), not the concrete cache module (${specifier})`);
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

// ---------------------------------------------------------------------------------------------
// Repo-wide seam ratchet. The rules above are hard: a violation fails the gate outright. The
// rules below hold for every remaining source file too, but the code that already breaks them is
// listed per file with its current count (`seamRatchet`). A count may only go down: a new file, or
// a count that rises, fails; a count that drops prints a reminder to lower the entry, so each
// cleanup PR shrinks the table until it is empty.
//
//   model-class      `instanceof <X>Model` and imports of concrete model modules (`models/<family>/...`,
//                    anything under `models/` that is not a graph contract) outside `models/`.
//   family-subpath   the same imports from any other workspace package (training, apps, modules,
//                    quantize, hub, ...): `@mlx-bun/inference/models/<family>` subpaths.
//   family-identity  comparing or matching a config's `model_type`/`architectures`, importing a
//                    per-family predicate, and repo-id or name checks (`id.includes("qwen")`,
//                    `/gemma/i.test(name)`), outside the family registry and the artifact readers.
//   cache-class      `instanceof <concrete cache class>` outside `state/` and the graphs in `models/`.
//   model-env-flag   an env flag whose name holds a family name, read outside `models/`.
//   scheduler-core   scheduler core files import only contracts, runtime and each other.
// ---------------------------------------------------------------------------------------------
type RatchetRule = "model-class" | "family-subpath" | "family-identity" | "cache-class" | "model-env-flag" | "scheduler-core";
interface Finding { rule: RatchetRule; file: string; line: number; text: string }
type RatchetTable = Partial<Record<RatchetRule, Record<string, number>>>;

/** The scheduler core: lifecycle, admission, cancellation, task and plan resolution. Everything
 * model- or storage-shaped reaches it through a contract. */
const schedulerCore = new Set(["scheduler", "coordinator", "engine", "session", "admission", "cancellation", "tasks", "plan"]
  .map(name => `execution/${name}.ts`));
const modelEnvFlag = /^MLX_BUN_\w*(GEMMA|QWEN|MINICPM|LLAMA|GLM|DIFFUSION|UNIVERSAL)/;
const equality = [ts.SyntaxKind.EqualsEqualsToken, ts.SyntaxKind.EqualsEqualsEqualsToken, ts.SyntaxKind.ExclamationEqualsToken, ts.SyntaxKind.ExclamationEqualsEqualsToken];
const familyName = /^(gemma|qwen|minicpm|llama|glm|diffusion|universal)/i;
const nameChecks = ["startsWith", "endsWith", "includes", "match", "test", "indexOf", "search", "exec"];

/** `instanceof X` for every identifier X, and the calls that test a repo id or a display name for a family word. */
function nameAndClassChecks(source: ts.SourceFile): { instances: { name: string; node: ts.Node }[]; names: { text: string; node: ts.Node }[]; flags: { text: string; node: ts.Node }[] } {
  const instances: { name: string; node: ts.Node }[] = [], names: { text: string; node: ts.Node }[] = [], flags: { text: string; node: ts.Node }[] = [];
  const familyLiteral = (node: ts.Node) => (ts.isStringLiteralLike(node) && familyWord.test(node.text)) ||
    (ts.isRegularExpressionLiteral(node) && familyWord.test(node.text));
  const visit = (node: ts.Node) => {
    if (ts.isBinaryExpression(node) && node.operatorToken.kind === ts.SyntaxKind.InstanceOfKeyword && ts.isIdentifier(node.right))
      instances.push({ name: node.right.text, node });
    if (ts.isCallExpression(node) && ts.isPropertyAccessExpression(node.expression) && nameChecks.includes(node.expression.name.text) &&
        (node.arguments.some(familyLiteral) || familyLiteral(node.expression.expression)))
      names.push({ text: `${node.expression.name.text} with a family name`, node });
    if (ts.isBinaryExpression(node) && equality.includes(node.operatorToken.kind) &&
        (familyName.test(ts.isStringLiteralLike(node.left) ? node.left.text : "") || familyName.test(ts.isStringLiteralLike(node.right) ? node.right.text : "")))
      names.push({ text: "comparing to a family name", node });
    if (ts.isCaseClause(node) && ts.isStringLiteralLike(node.expression) && familyName.test(node.expression.text))
      names.push({ text: "switching on a family name", node });
    if ((ts.isStringLiteralLike(node) || ts.isIdentifier(node)) && modelEnvFlag.test(node.text)) flags.push({ text: node.text, node });
    ts.forEachChild(node, visit);
  };
  visit(source);
  return { instances, names, flags };
}

const nodeModules = new Set([...builtinModules, ...builtinModules.map(name => `node:${name}`), "bun", "bun:ffi", "bun:sqlite"]);

/** Every ratchet finding in the workspace at `root`, with paths relative to it. */
async function seamFindings(root: string): Promise<Finding[]> {
  root = realpathSync(root);
  const libraries = await readLibraries(root), sources = await readSources(libraries);
  const options: ts.CompilerOptions = { moduleResolution: ts.ModuleResolutionKind.Bundler, module: ts.ModuleKind.Preserve };
  const cache = ts.createModuleResolutionCache(root, path => path, options);
  const inference = libraries.find(item => item.name === "@mlx-bun/inference");
  const cacheNames = new Set(inference ? cacheClasses(sources, resolve(inference.source, "state")).map(item => item.name) : []);
  const found: Finding[] = [];
  for (const [file, source] of sources) {
    const owner = libraries.find(item => file.startsWith(`${item.source}/`))!;
    if (owner.name === "mlx-bun-website" || owner.name === "@mlx-bun/mlx") continue;
    const inInference = owner === inference, name = relative(owner.source, file), at = relative(root, file);
    const inModels = inInference && name.startsWith("models/");
    const add = (rule: RatchetRule, node: ts.Node | undefined, text: string) =>
      found.push({ rule, file: at, line: node ? source.getLineAndCharacterOfPosition(node.getStart(source)).line + 1 : 0, text });
    const { instances, names, flags } = nameAndClassChecks(source);
    if (!inModels) {
      for (const { name: klass, node } of instances) {
        if (/Model$/.test(klass) || familyWord.test(klass)) add("model-class", node, `instanceof ${klass}`);
        if (cacheNames.has(klass) && !(inInference && name.startsWith("state/"))) add("cache-class", node, `instanceof ${klass}`);
      }
      for (const { text, node } of flags) add("model-env-flag", node, text);
    }
    if (!(inInference && ownsFamilyIdentity(name))) {
      for (const { text, line } of familyIdentityChecks(source)) found.push({ rule: "family-identity", file: at, line, text });
      const typed = new Set(familyIdentityChecks(source).map(item => item.line));
      for (const { text, node } of names)
        if (!(text.endsWith("family name") && !text.includes("with") && typed.has(source.getLineAndCharacterOfPosition(node.getStart(source)).line + 1)))
          add("family-identity", node, text);
    }
    if (inInference && schedulerCore.has(name)) {
      for (const { specifier, line } of references(source)) {
        const target = specifier?.startsWith(".") ? relative(inference!.source, resolve(dirname(file), specifier)) : specifier;
        if (target === undefined || !(target.startsWith("contracts/") || target.startsWith("runtime/") ||
            schedulerCore.has(`${target}.ts`)))
          found.push({ rule: "scheduler-core", file: at, line, text: `imports ${specifier ?? "a non-literal module"}` });
      }
    }
    if (inModels || !inference) continue;
    for (const { specifier, line } of references(source)) {
      if (!specifier || nodeModules.has(specifier)) continue;
      const actual = ts.resolveModuleName(specifier, file, options, ts.sys, cache).resolvedModule?.resolvedFileName;
      if (!actual || !sources.has(actual) || !actual.startsWith(`${inference.source}/`)) continue;
      const target = relative(inference.source, actual);
      if (target.startsWith("models/") && !graphContracts.has(target))
        found.push({ rule: owner === inference ? "model-class" : "family-subpath", file: at, line, text: `imports ${specifier}` });
    }
  }
  return found;
}

/** Compare findings with the allowlist: anything above it fails, anything below it is a reminder to lower it. */
function checkRatchet(findings: readonly Finding[], table: RatchetTable): { failures: string[]; reminders: string[] } {
  const seen = new Map<string, Finding[]>();
  for (const item of findings) {
    const key = `${item.rule}\0${item.file}`;
    seen.set(key, [...seen.get(key) ?? [], item]);
  }
  const failures: string[] = [], reminders: string[] = [];
  for (const [key, items] of seen) {
    const [rule, file] = key.split("\0") as [RatchetRule, string];
    const allowed = table[rule]?.[file] ?? 0;
    if (items.length > allowed)
      failures.push(`${rule} ${file}: ${items.length} violations, ${allowed} allowed${allowed ? "" : " (a new file)"}: ` +
        items.map(item => `${item.line}: ${item.text}`).join("; "));
    else if (items.length < allowed) reminders.push(`${rule} ${file}: ${items.length} now, lower the allowlist from ${allowed}`);
  }
  for (const [rule, files] of Object.entries(table) as [RatchetRule, Record<string, number>][])
    for (const [file, allowed] of Object.entries(files))
      if (!seen.has(`${rule}\0${file}`)) reminders.push(`${rule} ${file}: 0 now, delete the allowlist entry (was ${allowed})`);
  return { failures, reminders };
}

/** The current violations, per rule and file. Lower a count, or delete a line, when a cleanup lands; never raise one. */
const seamRatchet: RatchetTable = {
  "model-class": {
    "packages/inference/src/generation/bindings/denoising.ts": 1,
    "packages/inference/src/generation/diffusion.ts": 1,
    "packages/inference/src/generation/speculative/bindings/assistant-rows.ts": 1,
    "packages/inference/src/generation/speculative/bindings/deepspec-rows.ts": 1,
    "packages/inference/src/generation/speculative/bindings/glm52-mtp-rows.ts": 1,
    "packages/inference/src/generation/speculative/bindings/qwen-mtp-rows.ts": 1,
    "packages/inference/src/generation/speculative/draft-kind.ts": 2,
    "packages/inference/src/generation/speculative/dspark/loader.ts": 3,
    "packages/inference/src/generation/speculative/sources/assistant-source.ts": 1,
    "packages/inference/src/generation/speculative/sources/deepspec-source.ts": 1,
    "packages/inference/src/generation/speculative/sources/dflash-source.ts": 1,
    "packages/inference/src/generation/speculative/sources/glm52-mtp-source.ts": 3,
    "packages/inference/src/generation/speculative/sources/qwen-mtp-source.ts": 1,
    "packages/inference/src/state/glm52-cache.ts": 1,
    "packages/inference/src/state/target-layout.ts": 1,
    "packages/inference/src/transcription/index.ts": 1,
    "packages/inference/src/transcription/whisper/decode.ts": 2,
    "packages/inference/src/transcription/whisper/timing.ts": 1,
    "packages/inference/src/transcription/whisper/transcribe.ts": 1,
  },
  "family-subpath": {
    "packages/quantize/src/drafter.ts": 1,
  },
  "family-identity": {
    "packages/inference/src/generation/speculative/bindings/assistant-rows.ts": 1,
    "packages/inference/src/generation/speculative/draft-kind.ts": 1,
    "packages/inference/src/layers/rope.ts": 1,
    "packages/inference/src/models/profile.ts": 1,
    "packages/inference/src/state/speculative/glm52-mtp-state.ts": 1,
    "packages/inference/src/state/speculative/qwen-mtp-state.ts": 1,
    "packages/quantize/src/drafter.ts": 1,
    "packages/quantize/src/weight-transform.ts": 6,
  },
  "cache-class": {
    "packages/inference/src/generation/autoregressive.ts": 2,
    "packages/inference/src/scoring/full-sequence.ts": 2,
  },
  "model-env-flag": {},
  "scheduler-core": {},
};

test("the seam ratchet: no new violation, no file above its allowlisted count", async () => {
  const { failures, reminders } = checkRatchet(await seamFindings(workspace), seamRatchet);
  if (reminders.length) console.warn(`Seam ratchet: lower the allowlist in architecture.test.ts:\n  ${reminders.join("\n  ")}`);
  expect(failures).toEqual([]);
});

test("the ratchet fires for each seam rule, ignores the owners, and only ever tightens", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-seam-ratchet-"));
  const write = (path: string, text: string) => {
    const target = resolve(root, path);
    mkdirSync(dirname(target), { recursive: true }); writeFileSync(target, text);
  };
  const inference = { name: "@mlx-bun/inference", type: "module", exports: { ".": "./src/index.ts", "./models": "./src/models/index.ts",
    "./models/gemma4": "./src/models/gemma4/model.ts" }, dependencies: { "@mlx-bun/mlx": "workspace:*",
    "@huggingface/tokenizers": "1", "@huggingface/jinja": "1", "fast-png": "1", "@mlc-ai/web-xgrammar": "1" } };
  const rules = async (file: string) => (await seamFindings(root)).filter(item => item.file === file).map(item => item.rule);
  try {
    write("packages/mlx/package.json", JSON.stringify({ name: "@mlx-bun/mlx", type: "module", exports: { ".": "./src/index.ts" } }));
    write("packages/mlx/src/index.ts", "export const mlx = true;");
    write("packages/inference/package.json", JSON.stringify(inference));
    write("packages/inference/src/index.ts", "export const api = true;");
    write("packages/inference/src/models/index.ts", "export const graphs = 1;");
    write("packages/inference/src/models/gemma4/model.ts", "export class Gemma4Model { modelType = 'gemma4'; }");
    write("packages/inference/src/state/kv.ts", "export class KVCache { signature() { return 'kv'; } }");
    write("packages/inference/src/state/rotating.ts", 'import { KVCache } from "./kv"; export class Rotating extends KVCache {}');
    write("packages/quantize/package.json", JSON.stringify({ name: "@mlx-bun/quantize", type: "module", exports: { ".": "./src/index.ts" },
      dependencies: { "@mlx-bun/inference": "workspace:*" } }));
    write("packages/quantize/src/index.ts", "export const quantize = 1;");
    mkdirSync(resolve(root, "node_modules/@mlx-bun"), { recursive: true });
    for (const name of ["inference", "mlx"]) symlinkSync(resolve(root, `packages/${name}`), resolve(root, `node_modules/@mlx-bun/${name}`));
    // The owners are free: a graph's own binding, the family registry, the artifact readers, state, the row-layout port.
    write("packages/inference/src/models/gemma4/binding.ts", 'import { Gemma4Model } from "./model"; import { KVCache } from "../../state/kv";\n' +
      'export const own = (m: object, c: object) => [m instanceof Gemma4Model, c instanceof KVCache, process.env.MLX_BUN_GEMMA4_FAST, (m as { modelType: string }).modelType === "gemma4"];');
    write("packages/inference/src/models/families.ts", 'export const is = (n: string) => n.includes("gemma");');
    write("packages/inference/src/artifacts/config-dialects.ts", 'export const dialect = (t: string) => t === "qwen3";');
    write("packages/inference/src/state/uses.ts", 'import { KVCache } from "./kv"; export const kv = (c: object) => c instanceof KVCache;');
    write("packages/inference/src/execution/scheduler.ts",
      'import type { Group } from "../contracts/portable/scheduling"; import { free } from "../runtime/resources"; import { admit } from "./admission"; export const s = [free, admit];');
    write("packages/inference/src/execution/admission.ts", "export const admit = 1;");
    write("packages/inference/src/contracts/portable/scheduling.ts", "export interface Group { id: string }");
    write("packages/inference/src/runtime/resources.ts", "export const free = 1;");
    expect(await seamFindings(root)).toEqual([]);

    // model-class: `instanceof <X>Model` and concrete model imports, outside models/.
    write("packages/inference/src/generation/plan.ts",
      'import { Gemma4Model } from "../models/gemma4/model"; export const paged = (m: object) => m instanceof Gemma4Model;');
    expect(await rules("packages/inference/src/generation/plan.ts")).toEqual(["model-class", "model-class"]);
    rmSync(resolve(root, "packages/inference/src/generation/plan.ts"));

    // family-subpath: another workspace package importing `@mlx-bun/inference/models/<family>`.
    write("packages/quantize/src/drafter.ts", 'import { Gemma4Model } from "@mlx-bun/inference/models/gemma4"; export const kind = Gemma4Model;');
    expect(await rules("packages/quantize/src/drafter.ts")).toEqual(["family-subpath"]);
    write("packages/quantize/src/drafter.ts", 'import { graphs } from "@mlx-bun/inference/models"; export const kind = graphs;');
    expect(await rules("packages/quantize/src/drafter.ts")).toEqual([]);
    rmSync(resolve(root, "packages/quantize/src/drafter.ts"));

    // family-identity: model type, architectures, family predicates, repo-id and name checks, literal comparisons.
    const identity = {
      type: 'export const a = (c: { modelType: string }) => c.modelType === "qwen3";',
      architectures: 'export const a = (c: { architectures: string[] }) => c.architectures.includes("X");',
      substring: 'export const a = (id: string) => id.toLowerCase().includes("gemma");',
      regex: 'export const a = (id: string) => /qwen/i.test(id);',
      path: 'export const a = (id: string) => id.startsWith("mlx-community/Llama");',
      comparison: 'export const a = (kind: string) => kind !== "glm52";',
      switch: 'export const a = (k: string) => { switch (k) { case "minicpm5": return 1; default: return 0; } };',
    };
    for (const [label, code] of Object.entries(identity)) {
      write("packages/quantize/src/kind.ts", code);
      expect(await rules("packages/quantize/src/kind.ts"), label).toEqual(["family-identity"]);
      write("packages/inference/src/generation/kind.ts", code);
      expect(await rules("packages/inference/src/generation/kind.ts"), label).toEqual(["family-identity"]);
      rmSync(resolve(root, "packages/inference/src/generation/kind.ts"));
    }
    // Ordinary strings and comparisons are untouched.
    write("packages/quantize/src/kind.ts", 'export const a = (id: string, c: { name: string }) => id.includes("llm") || c.name === "small";');
    expect(await rules("packages/quantize/src/kind.ts")).toEqual([]);
    rmSync(resolve(root, "packages/quantize/src/kind.ts"));

    // cache-class: the classes are whatever `state/` declares, subclasses included; owners are state/ and models/.
    for (const klass of ["KVCache", "Rotating"]) {
      write("packages/inference/src/scoring/full.ts", `export const a = (c: object) => c instanceof ${klass};`);
      expect(await rules("packages/inference/src/scoring/full.ts")).toEqual(["cache-class"]);
      write("packages/quantize/src/full.ts", `export const a = (c: object) => c instanceof ${klass};`);
      expect(await rules("packages/quantize/src/full.ts")).toEqual(["cache-class"]);
    }
    write("packages/inference/src/scoring/full.ts", "export const a = (c: object) => c instanceof Map;");
    expect(await rules("packages/inference/src/scoring/full.ts")).toEqual([]);
    rmSync(resolve(root, "packages/inference/src/scoring/full.ts")); rmSync(resolve(root, "packages/quantize/src/full.ts"));

    // model-env-flag: any flag whose name holds a family name, string or property.
    write("packages/quantize/src/flags.ts", 'export const a = [process.env.MLX_BUN_SPEC_QWEN_KV4, process.env["MLX_BUN_GLM52_PIN"], process.env.MLX_BUN_KV_SCHEME];');
    expect(await rules("packages/quantize/src/flags.ts")).toEqual(["model-env-flag", "model-env-flag"]);
    rmSync(resolve(root, "packages/quantize/src/flags.ts"));

    // scheduler-core: contracts, runtime and core siblings only.
    for (const bad of ["../state/layout", "../models/capabilities", "../generation/index", "./batch-group", "external-package"]) {
      write("packages/inference/src/execution/coordinator.ts", `import { x } from "${bad}"; export const c = x;`);
      const found = (await seamFindings(root)).filter(item => item.file === "packages/inference/src/execution/coordinator.ts");
      expect(found.map(item => item.rule), bad).toEqual(["scheduler-core"]);
      expect(found[0]!.text).toBe(`imports ${bad}`);
    }
    write("packages/inference/src/execution/coordinator.ts", 'import { admit } from "./admission"; export const c = admit;');
    expect(await seamFindings(root)).toEqual([]);
    // Files outside the core may import whatever the layer rules allow.
    write("packages/inference/src/execution/batch-group.ts", 'import { KVCache } from "../state/kv"; export const b = KVCache;');
    expect(await seamFindings(root)).toEqual([]);

    // The ratchet: a new file and a rising count fail, a falling count reminds, an exact match is quiet.
    write("packages/quantize/src/kind.ts", 'export const a = (id: string) => id.includes("gemma") || id.includes("qwen");');
    const findings = await seamFindings(root);
    const table: RatchetTable = { "family-identity": { "packages/quantize/src/kind.ts": 2 } };
    expect(checkRatchet(findings, table)).toEqual({ failures: [], reminders: [] });
    const fresh = checkRatchet(findings, {});
    expect(fresh.failures).toHaveLength(1);
    expect(fresh.failures[0]).toContain("family-identity packages/quantize/src/kind.ts: 2 violations, 0 allowed (a new file)");
    const risen = checkRatchet(findings, { "family-identity": { "packages/quantize/src/kind.ts": 1 } });
    expect(risen.failures[0]).toContain("2 violations, 1 allowed");
    const dropped = checkRatchet(findings, { "family-identity": { "packages/quantize/src/kind.ts": 3 } });
    expect(dropped).toEqual({ failures: [], reminders: ["family-identity packages/quantize/src/kind.ts: 2 now, lower the allowlist from 3"] });
    const gone = checkRatchet([], { "cache-class": { "packages/inference/src/scoring/full.ts": 1 } });
    expect(gone.reminders).toEqual(["cache-class packages/inference/src/scoring/full.ts: 0 now, delete the allowlist entry (was 1)"]);
    expect(gone.failures).toEqual([]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

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
    // Storage is reached through the row-layout port, never a concrete cache module (or its subclasses).
    write("packages/inference/src/state/kv.ts", "export class KVCache { signature() { return 'kv'; } }");
    write("packages/inference/src/state/batched.ts", 'import { KVCache } from "./kv"; export class Batched extends KVCache {}');
    write("packages/inference/src/state/layout.ts", 'import { Batched } from "./batched"; export const layout = () => new Batched();');
    write(scheduler, 'import { layout } from "../state/layout"; export const plan = () => layout();');
    expect(await inspectWorkspaces(root)).toEqual([]);
    write(scheduler, 'import { KVCache } from "../state/kv"; import { Batched } from "../state/batched"; export const plan = () => [KVCache, Batched];');
    const stored = await inspectWorkspaces(root);
    for (const module of ["../state/kv", "../state/batched"])
      expect(stored.some(item => item.includes(`scheduling reaches storage through the row-layout port (state/layout), not the concrete cache module (${module})`))).toBe(true);
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

test("inference decides which family a model is only in the family registry, the families' directories and the artifact readers", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-family-boundaries-"));
  const write = (path: string, text: string) => {
    const target = resolve(root, path);
    mkdirSync(dirname(target), { recursive: true }); writeFileSync(target, text);
  };
  const inference = { name: "@mlx-bun/inference", type: "module", exports: { ".": "./src/index.ts" },
    dependencies: { "@mlx-bun/mlx": "workspace:*", "@huggingface/tokenizers": "1", "@huggingface/jinja": "1", "fast-png": "1", "@mlc-ai/web-xgrammar": "1" } };
  const identity = 'export const is = (c: { modelType: string }) => c.modelType === "qwen3" || c.modelType.startsWith("gemma4");';
  try {
    write("packages/mlx/package.json", JSON.stringify({ name: "@mlx-bun/mlx", type: "module", exports: { ".": "./src/index.ts" } }));
    write("packages/mlx/src/index.ts", "export const mlx = true;");
    write("packages/inference/package.json", JSON.stringify(inference));
    write("packages/inference/src/index.ts", "export const api = true;");
    write("packages/inference/src/models/families.ts", identity);
    write("packages/inference/src/models/qwen/family.ts", identity);
    write("packages/inference/src/artifacts/config-dialects.ts", identity);
    write("packages/inference/src/state/geometry.ts", "export const layers = 1;");
    mkdirSync(resolve(root, "node_modules/@mlx-bun"), { recursive: true });
    symlinkSync(resolve(root, "packages/mlx"), resolve(root, "node_modules/@mlx-bun/mlx"));
    expect(await inspectWorkspaces(root)).toEqual([]);
    for (const file of ["state/geometry.ts", "generation/plan.ts", "models/factory.ts", "models/support.ts", "artifacts/config.ts"]) {
      write(`packages/inference/src/${file}`, identity);
      const found = (await inspectWorkspaces(root)).filter(item => item.includes(`src/${file}:1:`));
      expect(found.length, file).toBe(2);
      expect(found.every(item => item.includes("only the family registry decides which family a model is")), file).toBe(true);
      rmSync(resolve(root, `packages/inference/src/${file}`));
    }
    write("packages/inference/src/generation/plan.ts", 'import { isQwen3Config } from "../models/families"; export const is = isQwen3Config;');
    write("packages/inference/src/models/families.ts", "export const isQwen3Config = (c: object) => !!c;");
    expect((await inspectWorkspaces(root)).some(item => item.includes("family predicate isQwen3Config"))).toBe(true);
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
    ["packages/web-shell", "@mlx-bun/web-shell", {}],
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
  write("packages/web-shell/src/index.ts", "export const shell = 1;");
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

test("the web shell is browser code that imports only its own files; modules cannot use it and an app's browser code can", async () => {
  const { root, write, manifest, cleanup } = moduleWorkspace();
  try {
    expect(await inspectWorkspaces(root)).toEqual([]);
    const host = { "@mlx-bun/app-core": "", "@mlx-bun/app-host": "", "@mlx-bun/module-a": "" };
    const shell = "packages/web-shell/src/index.ts";
    for (const specifier of ["node:fs", "bun", "@mlx-bun/app-core", "@mlx-bun/hub", "@mlx-bun/module-a"]) {
      write(shell, `import * as x from ${JSON.stringify(specifier)}; export const y = x;`);
      expect(mentions(await inspectWorkspaces(root), `${shell}:1: the web shell is browser code and imports only its own files (${specifier})`)).toBe(true);
    }
    write(shell, 'import { own } from "./own"; export const y = own;');
    write("packages/web-shell/src/own.ts", "export const own = 1;");
    expect(await inspectWorkspaces(root)).toEqual([]);
    manifest("packages/web-shell", "@mlx-bun/web-shell", { "@mlx-bun/app-core": "" });
    expect(mentions(await inspectWorkspaces(root), "@mlx-bun/web-shell: the web shell has no workspace dependencies (@mlx-bun/app-core)")).toBe(true);
    manifest("packages/web-shell", "@mlx-bun/web-shell");
    expect(await inspectWorkspaces(root)).toEqual([]);
    // A module is handed its connection by the shell; it never imports the shell.
    manifest("packages/module-b", "@mlx-bun/module-b", { "@mlx-bun/app-core": "", "@mlx-bun/web-shell": "" });
    write("packages/module-b/src/index.ts", 'import { shell } from "@mlx-bun/web-shell"; export default { id: "b", shell };');
    const found = await inspectWorkspaces(root);
    expect(mentions(found, "@mlx-bun/module-b: a module depends only on app-core and domain libraries (@mlx-bun/web-shell)")).toBe(true);
    expect(mentions(found, "packages/module-b/src/index.ts:1: a module imports only app-core, domain libraries and its own files, not the web shell")).toBe(true);
    // The app's browser code may import it (declared), and nothing else outside the browser.
    write("packages/module-b/src/index.ts", 'export default { id: "b" };');
    manifest("packages/module-b", "@mlx-bun/module-b", { "@mlx-bun/app-core": "" });
    manifest("apps/example", "example-host", { ...host, "@mlx-bun/web-shell": "" });
    write("apps/example/src/web/browser/main.ts", 'import { shell } from "@mlx-bun/web-shell"; export const start = () => shell;');
    expect(await inspectWorkspaces(root)).toEqual([]);
    write("apps/example/src/web/browser/main.ts", 'import a from "@mlx-bun/module-a";');
    expect(mentions(await inspectWorkspaces(root), "browser may import only browser modules, the web shell and data protocols")).toBe(true);
  } finally { cleanup(); }
});

test("panel code imports only panel files and its protocol.ts, and the protocol imports nothing", async () => {
  const { root, write, cleanup } = moduleWorkspace();
  try {
    expect(await inspectWorkspaces(root)).toEqual([]);
    const panel = "packages/module-a/src/panel/index.ts";
    for (const specifier of ["../own", "@mlx-bun/app-core", "@mlx-bun/hub", "@mlx-bun/web-shell", "node:fs", "bun", "../index"]) {
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
