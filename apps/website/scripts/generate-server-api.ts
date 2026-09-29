import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import ts from "typescript";
import { sourceRevision } from "./generate-library-api";
import { installedManifests } from "./generate-reference";

const root = resolve(import.meta.dir, "../../..");
const APP = "apps/mlx-bun/src/", ANY = "(any other path)", K = ts.SyntaxKind;
export const SERVER_API_PAGE = "src/content/docs/reference/server-api.md";
const cli = (name: string) => `${APP}cli/${name}`, server = (name: string) => `${APP}server/${name}`;
/** The composition sites the server modes are read from. */
export const COMPOSITION_SOURCES = ["serve-host.ts", "serving-unit.ts", "serve-isolated.ts", "serve-state.ts", "worker-entry.ts"].map(cli);
/** The transcription-only discovery routes live in the host library both hosts share. */
export const COMPANION_SOURCE = "packages/app-services/src/companion-info-routes.ts";
const ROUTE_GLOB = `${APP}server/*.ts`, WEB_SOURCE = `${APP}web/assets.ts`, FACTORY = /^create\w*Routes$|^createWebHandler$/;
/** `createModuleRoutes(loaded.routes)`: the installed modules' routes, read from their manifests; the sockets the state serves come from the same manifests. */
const MODULE_ROUTES = "createModuleRoutes", MANIFEST = /^packages\/module-[^/]+\/src\/manifest\.ts$/;

/** Real comparisons on the request path or method that pick behavior after a
 * route matched, never a route. Each entry matches exactly one expression in
 * its top-level function; a changed or removed site fails generation. */
export const NON_ROUTE_SITES: readonly { file: string; fn: string; code: string; why: string }[] = [
  { file: "server/routes.ts", fn: "createCompletionRoutes", why: "chooses the error body format",
    code: 'url.pathname === "/v1/messages" ? anthropicError : url.pathname === "/v1/responses" ? responsesError : undefined' },
  { file: "server/proxy-routes.ts", fn: "unavailableFrame", why: "chooses the SSE error frame", code: 'pathname === "/v1/messages"' },
  { file: "server/proxy-routes.ts", fn: "unavailableFrame", why: "chooses the SSE error frame", code: 'pathname === "/v1/responses"' },
  { file: "server/proxy-routes.ts", fn: "createProxyRoutes", why: "picks the worker named by the body's model (the routed-by-model-id rows)",
    code: 'request.method === "POST" && MODEL_ROUTED.has(pathname)' },
  { file: "server/model-routes.ts", fn: "createModelRoutes", why: "a read of the current model's own routes is answered as it is; a change holds the model resident meanwhile",
    code: '["GET", "HEAD"].includes(request.method)' },
  { file: "server/finetune-routes.ts", fn: "createFinetuneRoutes", why: "sub-dispatch after the route guard", code: 'path.endsWith("/inspect-dataset")' },
  { file: "server/adapter-artifact-routes.ts", fn: "createAdapterArtifactRoutes", why: "sub-dispatch after the route guard", code: 'path.endsWith("/merge")' },
  { file: "server/discovery-routes.ts", fn: "createDiscoveryRoutes", why: "reads the optional model id", code: 'url.pathname.length > "/v1/models/".length - 1' },
];

type Kind = "req" | "url" | "method" | "path" | "route" | "segments" | "tainted";
/** A route factory, or the installed modules' routes (`MODULE_ROUTES`), which come from their manifests:
 * `state-modules` in the persistent app state (modules that require `jobs`), `modules` with the model host (the rest). */
type Group = ts.FunctionDeclaration | "modules" | "state-modules";
type Groups = ReadonlyMap<string, Group | undefined>;
interface Frame { from: ts.Node; stop: ts.Node; params: Set<ts.Node> }
interface Cond { text: string; served: boolean; node: ts.Node }
interface Fact { method: string; path: string; status: string; conds: Cond[]; node: ts.Node; declined?: boolean; except?: Set<string> }
interface Test { methods?: string[]; routes?: { method: string; path: string; node: ts.Node }[] }
export interface Route { method: string; path: string; status: string; file: string; line: number; conds: { text: string; served: boolean; file: string; line: number }[] }
export interface ServerMode { id: string; title: string; intro: string; composed: { file: string; line: number }; routes: Route[] }
export interface ServerApi { modes: ServerMode[] }

// ---- syntax helpers ----
function skip(e: ts.Expression): ts.Expression {
  while (ts.isParenthesizedExpression(e) || ts.isAsExpression(e) || ts.isSatisfiesExpression(e) || ts.isNonNullExpression(e) || ts.isAwaitExpression(e)) e = e.expression;
  return e;
}
const code = (node: ts.Node) => node.getText().replace(/\s+/g, " ").replace(/([([{]) /g, "$1").replace(/ ([)\]}])/g, "$1");
function visit(node: ts.Node, each: (node: ts.Node) => void): void { ts.forEachChild(node, child => { each(child); visit(child, each); }); }
function find<T extends ts.Node>(node: ts.Node, test: (node: ts.Node) => node is T): T[] {
  const found: T[] = [];
  visit(node, child => { if (test(child)) found.push(child); });
  return found;
}
const within = (node: ts.Node, scope: ts.Node) => node.getSourceFile() === scope.getSourceFile() && node.pos >= scope.pos && node.end <= scope.end;
const nullish = (e: ts.Expression | undefined) => !e || skip(e).kind === K.NullKeyword || skip(e).getText() === "undefined";
const returnsNull = (s: ts.Statement): boolean => ts.isReturnStatement(s) ? nullish(s.expression) : ts.isBlock(s) && s.statements.length === 1 && returnsNull(s.statements[0]!);
const firstReturn = (s: ts.Statement | undefined): ts.Expression | undefined => !s ? undefined : ts.isReturnStatement(s) ? s.expression : ts.isBlock(s) ? firstReturn(s.statements[0]) : undefined;
const servedBy = (top: ts.Node) => ts.isIfStatement(top.parent) && top.parent.expression === top ? firstReturn(top.parent.thenStatement)
  : ts.isConditionalExpression(top.parent) && top.parent.condition === top ? top.parent.whenTrue : undefined;
const called = (scope: ts.Node, name: string) => find(scope, (n): n is ts.CallExpression => ts.isCallExpression(n) && ts.isIdentifier(n.expression) && n.expression.text === name);
const props = (e: ts.Expression | undefined) => { const x = e && skip(e); return new Map(x && ts.isObjectLiteralExpression(x) ? x.properties.flatMap(p =>
  ts.isPropertyAssignment(p) ? [[p.name.getText(), p.initializer] as const] : ts.isShorthandPropertyAssignment(p) ? [[p.name.text, p.name as ts.Expression] as const] : []) : []); };
const stringList = (e: ts.Expression | undefined): [string, ts.Node][] | undefined => { const list = e && skip(e);
  return list && ts.isArrayLiteralExpression(list) && list.elements.every(ts.isStringLiteralLike) ? list.elements.map(x => [(x as ts.StringLiteralLike).text, x]) : undefined; };
const none = (e: ts.Expression | undefined) => { const x = e && skip(e); return !!x && ts.isArrowFunction(x) && !ts.isBlock(x.body) && nullish(x.body); };
/** The `&&`/`||` operands around node, through `!` and parentheses. */
function chainOf(node: ts.Node): { top: ts.Node; ops: ts.Expression[] } {
  let top = node;
  while (ts.isParenthesizedExpression(top.parent) || ts.isNonNullExpression(top.parent) || (ts.isPrefixUnaryExpression(top.parent) && top.parent.operator === K.ExclamationToken)) top = top.parent;
  const logical = (n: ts.Node, op?: ts.SyntaxKind): n is ts.BinaryExpression => ts.isBinaryExpression(n) &&
    (op ? n.operatorToken.kind === op : n.operatorToken.kind === K.AmpersandAmpersandToken || n.operatorToken.kind === K.BarBarToken);
  if (!logical(top.parent)) return { top, ops: [] };
  const op = top.parent.operatorToken.kind, ops: ts.Expression[] = [];
  for (top = top.parent; logical(top.parent, op);) top = top.parent;
  const flat = (e: ts.Expression): void => { if (logical(e, op)) { flat(e.left); flat(e.right); } else ops.push(e); };
  flat(top as ts.Expression);
  return { top, ops };
}
const names = (name: ts.BindingName): ts.Identifier[] => ts.isIdentifier(name) ? [name] : name.elements.flatMap(e => ts.isBindingElement(e) ? names(e.name) : []);
const resolved = new WeakMap<ts.Identifier, ts.Identifier | undefined>();
/** The declaring name of an identifier among parameters, constants, and functions in its lexical scopes. */
function resolveName(id: ts.Identifier): ts.Identifier | undefined {
  if (resolved.has(id)) return resolved.get(id);
  let found: ts.Identifier | undefined;
  for (let scope = id.parent; scope && !found; scope = scope.parent) found = (ts.isFunctionLike(scope) ? scope.parameters.flatMap(p => names(p.name))
    : ts.isBlock(scope) || ts.isSourceFile(scope) || ts.isCaseClause(scope) || ts.isDefaultClause(scope) ? scope.statements.flatMap(s => ts.isVariableStatement(s)
      ? s.declarationList.declarations.flatMap(d => names(d.name)) : ts.isFunctionDeclaration(s) && s.name ? [s.name] : []) : []).find(n => n.text === id.text);
  resolved.set(id, found);
  return found;
}
function localFunction(callee: ts.Identifier): ts.FunctionLikeDeclaration | undefined {
  const declaration = resolveName(callee)?.parent;
  if (declaration && ts.isFunctionDeclaration(declaration)) return declaration;
  const init = declaration && ts.isVariableDeclaration(declaration) ? declaration.initializer : undefined;
  return init && (ts.isArrowFunction(init) || ts.isFunctionExpression(init)) ? init : undefined;
}
/** Restricted route regexes: escaped literals, one `([^/]+)` parameter, literal alternations, optional literal groups. */
export function expandRoutePattern(literal: string): string[] {
  const body = /^\/\^(.*)\$\/$/s.exec(literal)?.[1];
  if (body === undefined) throw new Error(`route regex needs ^…$ and no flags: ${literal}`);
  const text = (source: string) => {
    const out = source.replace(/\\([^A-Za-z0-9])/g, "$1");
    if (/\\/.test(out) || !/^[\w/-]*$/.test(out)) throw new Error(`unsupported regex syntax "${source}" in ${literal}`);
    return out;
  };
  let params = 0;
  return (body.match(/\((?:\?:)?[^()]*\)\??|\\.|./g) ?? []).reduce((paths, token) => {
    const group = /^\((?:\?:)?([^()]*)\)(\?)?$/.exec(token);
    if (group && /^\[\^\/\]\+\??$/.test(group[1]!) && ++params > 1) throw new Error(`route regex supports one parameter: ${literal}`);
    const options = !group ? [text(token)] : /^\[\^\/\]\+\??$/.test(group[1]!) ? ["{id}"] : [...group[1]!.split("|").map(text), ...(group[2] ? [""] : [])];
    return paths.flatMap(path => options.map(option => path + option));
  }, [""]);
}
/** The literal status of a response expression, through one local helper. */
function statusOf(e: ts.Expression, depth = 0): number | undefined {
  const inner = skip(e), field = (options?: ts.Expression) => { const status = props(options).get("status"); return status && ts.isNumericLiteral(status) ? Number(status.text) : 200; };
  if (ts.isNewExpression(inner) && inner.expression.getText() === "Response") return field(inner.arguments?.[1]);
  if (!ts.isCallExpression(inner)) return undefined;
  const callee = inner.expression.getText();
  if (callee === "Response.json") return field(inner.arguments[1]);
  if (callee === "Response.redirect") { const status = inner.arguments[1]; return status && ts.isNumericLiteral(status) ? Number(status.text) : 302; }
  const fn = !depth && ts.isIdentifier(inner.expression) ? localFunction(inner.expression) : undefined;
  const body = fn?.body && (ts.isBlock(fn.body) ? fn.body.statements.find(ts.isReturnStatement)?.expression : fn.body);
  return body ? statusOf(body, 1) : undefined;
}

// ---- trace values to the request's method and path; collect every comparison on one ----
const COMPARE = new Set([K.EqualsEqualsEqualsToken, K.ExclamationEqualsEqualsToken, K.EqualsEqualsToken, K.ExclamationEqualsToken,
  K.LessThanToken, K.GreaterThanToken, K.LessThanEqualsToken, K.GreaterThanEqualsToken, K.InKeyword]);
const TESTS = new Set(["startsWith", "endsWith", "includes", "has", "hasOwn", "test", "match", "matchAll", "exec", "search", "indexOf", "lastIndexOf", "localeCompare"]);
interface Scan { kind(e: ts.Expression): Kind | undefined; sites: ts.Node[] }
function scan(file: ts.SourceFile): Scan {
  const kinds = new Map<ts.Node, Kind>(), taint = (k?: Kind): Kind | undefined => k && k !== "req" && k !== "url" ? "tainted" : undefined;
  visit(file, n => {
    const type = ts.isParameter(n) && n.type && ts.isTypeReferenceNode(n.type) ? n.type.typeName.getText() : undefined;
    if (!ts.isParameter(n) || !ts.isIdentifier(n.name)) return;
    if (n.name.text === "request" || type === "Request") kinds.set(n.name, "req");
    else if (n.name.text === "url" || type === "URL") kinds.set(n.name, "url");
  });
  // A decoded path parameter (`decodeURIComponent(path.slice(n))`, `…(segments[i] ?? "")`) is data, not a route.
  const piece = (e?: ts.Expression) => {
    const x = e && skip(e), y = x && ts.isBinaryExpression(x) && x.operatorToken.kind === K.QuestionQuestionToken ? skip(x.left) : x;
    return !!y && (ts.isElementAccessExpression(y) || (ts.isCallExpression(y) && y.expression.getText().endsWith(".slice")));
  };
  const literalKey = (e: ts.ElementAccessExpression) => { const key = skip(e.argumentExpression); return ts.isStringLiteralLike(key) ? key.text : undefined; };
  const kind = (expression: ts.Expression): Kind | undefined => {
    const e = skip(expression);
    if (ts.isIdentifier(e)) { const name = resolveName(e); return name && kinds.get(name); }
    // `request["method"]` reads like `request.method`; a computed key on the request or its URL is an unsupported site.
    if (ts.isPropertyAccessExpression(e) || ts.isElementAccessExpression(e)) {
      const owner = kind(e.expression), name = ts.isPropertyAccessExpression(e) ? e.name.text : literalKey(e);
      if (name === undefined) return owner === "req" || owner === "url" ? "tainted" : taint(owner);
      return owner === "req" ? (name === "method" ? "method" : name === "url" ? "tainted" : undefined) : owner === "url" ? (name === "pathname" ? "path" : undefined) : taint(owner);
    }
    if (ts.isPrefixUnaryExpression(e)) return taint(kind(e.operand));
    if (ts.isCallExpression(e) && ts.isPropertyAccessExpression(e.expression)) {
      const owner = taint(kind(e.expression.expression));
      return owner && e.expression.name.text === "split" ? "segments" : owner;
    }
    if (ts.isCallExpression(e)) return e.expression.getText() === "decodeURIComponent" && !piece(e.arguments[0]) ? taint(kind(e.arguments[0]!)) : undefined;
    if (ts.isNewExpression(e)) return e.expression.getText() === "URL" && e.arguments?.some(a => kind(a)) ? "url" : undefined;
    if (ts.isTemplateExpression(e)) {
      const spans = e.templateSpans.map(s => kind(s.expression));
      return !e.head.text && spans.join() === "method,path" && e.templateSpans[0]!.literal.text === " " && !e.templateSpans[1]!.literal.text ? "route"
        : spans.some(taint) ? "tainted" : undefined;
    }
    if (ts.isBinaryExpression(e)) return taint(kind(e.left)) ?? taint(kind(e.right));
    return ts.isConditionalExpression(e) ? taint(kind(e.whenTrue)) ?? taint(kind(e.whenFalse)) : undefined;
  };
  for (let changed = true; changed;) {
    changed = false;
    const mark = (name: ts.Node, k: Kind | undefined) => { if (k && !kinds.has(name)) { kinds.set(name, k); changed = true; } };
    visit(file, n => {
      const k = ts.isVariableDeclaration(n) && n.initializer ? kind(n.initializer) : undefined;
      if (ts.isVariableDeclaration(n) && ts.isIdentifier(n.name)) mark(n.name, k);
      else if (ts.isVariableDeclaration(n) && ts.isObjectBindingPattern(n.name)) for (const el of n.name.elements) {
        const key = (el.propertyName ?? el.name).getText();
        mark(el.name, k === "url" ? (key === "pathname" ? "path" : undefined) : k === "req" ? (key === "method" ? "method" : undefined) : taint(k));
      }
      // Helpers called with the request's path or method (`matchAudioRoute(request.method, url.pathname)`).
      const fn = ts.isCallExpression(n) && ts.isIdentifier(n.expression) ? localFunction(n.expression) : undefined;
      if (fn) (n as ts.CallExpression).arguments.forEach((a, i) => { const p = fn.parameters[i]; if (p && ts.isIdentifier(p.name)) mark(p.name, kind(a)); });
    });
  }
  const value = (e: ts.Expression) => { const k = kind(e); return k === "req" || k === "url" ? undefined : k; }, sites: ts.Node[] = [];
  visit(file, n => {
    if ((ts.isElementAccessExpression(n) && literalKey(n) === undefined && (kind(n.expression) === "req" || kind(n.expression) === "url")) ||
      (ts.isBinaryExpression(n) && COMPARE.has(n.operatorToken.kind) && (value(n.left) || value(n.right))) || (ts.isSwitchStatement(n) && value(n.expression)) ||
      (ts.isCallExpression(n) && ts.isPropertyAccessExpression(n.expression) && TESTS.has(n.expression.name.text) && [n.expression.expression, ...n.arguments].some(a => value(a))))
      sites.push(n);
  });
  return { kind: value, sites };
}
/** One fact per method and path, first wins; later sites add their conditions. */
function merge(facts: Fact[]): Fact[] {
  const byKey = new Map<string, Fact>();
  for (const f of facts) {
    const seen = byKey.get(`${f.method} ${f.path}`);
    if (!seen) byKey.set(`${f.method} ${f.path}`, { ...f, conds: [...f.conds] });
    else seen.conds.push(...f.conds.filter(c => !seen.conds.some(s => s.node === c.node)));
  }
  return [...byKey.values()];
}

class Inventory {
  private readonly files = new Map<string, ts.SourceFile>();
  private readonly scans = new Map<ts.SourceFile, Scan>();
  private readonly factories = new Map<string, ts.FunctionDeclaration>();
  /** Factories composed into some mode; routing sites an extraction rule consumed; allowlisted non-route sites. */
  private readonly used = new Set<ts.FunctionDeclaration>();
  private readonly consumed = new Set<ts.Node>();
  private readonly allowed = new Set<ts.Node>();

  constructor(sources: ReadonlyMap<string, string>) {
    for (const [path, text] of sources) {
      const file = ts.createSourceFile(path, text, ts.ScriptTarget.Latest, true, ts.ScriptKind.TS);
      this.files.set(path, file);
      if (path !== WEB_SOURCE && path !== COMPANION_SOURCE && !/^apps\/mlx-bun\/src\/server\/[^/]+\.ts$/.test(path)) continue;
      this.scans.set(file, scan(file));
      for (const s of file.statements) if (ts.isFunctionDeclaration(s) && s.name && FACTORY.test(s.name.text) && s.modifiers?.some(m => m.kind === K.ExportKeyword))
        this.factories.set(s.name.text, s);
    }
    for (const entry of NON_ROUTE_SITES) {
      const scope = this.file(`${APP}${entry.file}`).statements.find(s => ts.isFunctionDeclaration(s) && s.name?.text === entry.fn);
      const matches = scope ? find(scope, (n): n is ts.Expression => ts.isExpression(n) && code(n) === entry.code) : [];
      const covered = matches.length === 1 ? this.sitesIn(matches[0]!) : [];
      if (!covered.length) throw new Error(`Allowlisted non-route site changed or disappeared: ${entry.file} ${entry.fn} \`${entry.code}\``);
      for (const site of covered) this.allowed.add(site);
    }
  }

  private file(path: string): ts.SourceFile { return this.files.get(path) ?? (() => { throw new Error(`Server API source is missing: ${path}`); })(); }
  private fn(path: string, name: string): ts.FunctionDeclaration {
    return this.file(path).statements.find((s): s is ts.FunctionDeclaration => ts.isFunctionDeclaration(s) && s.name?.text === name && !!s.body)
      ?? (() => { throw new Error(`${path.slice(APP.length)}: composition function ${name} was not found`); })();
  }
  private where(node: ts.Node) { const file = node.getSourceFile(); return { file: file.fileName, line: file.getLineAndCharacterOfPosition(node.getStart(file)).line + 1 }; }
  private fail(node: ts.Node, message: string): never { const { file, line } = this.where(node); throw new Error(`${file.startsWith(APP) ? file.slice(APP.length) : file}:${line}: ${message}`); }
  private sitesIn(scope: ts.Node): ts.Node[] { return this.scans.get(scope.getSourceFile())?.sites.filter(site => within(site, scope)) ?? []; }
  private value(e: ts.Expression) { return this.scans.get(e.getSourceFile())?.kind(e); }
  private constant(e: ts.Expression): ts.Expression | undefined {
    const d = ts.isIdentifier(skip(e)) ? resolveName(skip(e) as ts.Identifier)?.parent : undefined;
    return d && ts.isVariableDeclaration(d) && d.initializer && d.parent.flags & ts.NodeFlags.Const ? skip(d.initializer) : undefined;
  }

  /** The supported routing predicate forms. Anything else fails with its location. */
  private classify(site: ts.Node): Test {
    const unsupported = (what = "unsupported routing predicate"): never =>
      this.fail(site, `${what} \`${code(site).slice(0, 120)}\`; extend the server API generator or allowlist a non-route site`);
    const literals = (texts: [string, ts.Node][], kind: Kind | undefined): Test => {
      if (kind === "method") return { methods: texts.map(([text]) => text) };
      if (kind !== "path" && kind !== "route") return unsupported();
      return { routes: texts.map(([text, node]) => {
        const [method, path] = kind === "route" ? text.split(" ") as [string, string] : ["", text];
        if (!/^\/\S*$/.test(path ?? "") || (kind === "route" && !/^[A-Z]+$/.test(method))) this.fail(node, `routing literal "${text}" is not a path or "METHOD /path"`);
        return { method, path, node };
      }) };
    };
    const strings = (e: ts.Expression | undefined) => stringList(e) ?? unsupported("routing list needs literal strings in");
    if (ts.isSwitchStatement(site)) return literals(site.caseBlock.clauses.filter(ts.isCaseClause).map(c =>
      ts.isStringLiteralLike(c.expression) ? [c.expression.text, c] : unsupported("switch case needs a string literal in")), this.value(site.expression));
    if (ts.isBinaryExpression(site)) {
      if (site.operatorToken.kind !== K.EqualsEqualsEqualsToken && site.operatorToken.kind !== K.ExclamationEqualsEqualsToken) return unsupported();
      const [subject, other] = this.value(site.left) ? [skip(site.left), skip(site.right)] : [skip(site.right), skip(site.left)];
      if (this.value(other)) return unsupported("comparison between two request values");
      return ts.isStringLiteralLike(other) ? literals([[other.text, site]], this.value(subject)) : unsupported("routing comparison needs a string literal in");
    }
    if (!ts.isCallExpression(site)) return unsupported();
    const call = site, callee = call.expression as ts.PropertyAccessExpression;
    const name = callee.name.text, receiver = skip(callee.expression), [first, second] = call.arguments;
    if (callee.getText() === "Object.hasOwn") {
      const table = this.constant(first!);
      if (!table || !ts.isObjectLiteralExpression(table)) return unsupported("route table needs a literal object in");
      return literals(table.properties.map(p => ts.isPropertyAssignment(p) && ts.isStringLiteral(p.name) ? [p.name.text, p] : unsupported("route table needs literal keys in")), this.value(second!));
    }
    if (name === "includes" && ts.isArrayLiteralExpression(receiver)) return literals(strings(receiver), this.value(first!));
    if (name === "has") {
      const set = this.constant(receiver);
      return set && ts.isNewExpression(set) && set.expression.getText() === "Set" ? literals(strings(set.arguments?.[0]), this.value(first!)) : unsupported("set membership needs a literal Set in");
    }
    if (name === "startsWith" && this.value(receiver) === "path" && first && ts.isStringLiteralLike(first) && first.text.endsWith("/"))
      return { routes: [{ method: "", path: `${first.text}{id}`, node: site }] };
    const regex = name === "match" && this.value(receiver) === "path" ? first : (name === "test" || name === "exec") && first && this.value(first) === "path" ? receiver : undefined;
    const patterns = regex && ts.isRegularExpressionLiteral(regex) ? [regex] : regex && ts.isIdentifier(regex) ? this.regexList(regex) : undefined;
    if (!patterns) return unsupported();
    return { routes: patterns.flatMap(p => { try { return expandRoutePattern(p.text); } catch (error) { return this.fail(p, (error as Error).message); } }).map(path => ({ method: "", path, node: site })) };
  }
  /** `list.some(pattern => pattern.test(path))` over a literal regex list. */
  private regexList(id: ts.Identifier): ts.RegularExpressionLiteral[] | undefined {
    const callback = resolveName(id)?.parent.parent, call = callback?.parent;
    if (!callback || !ts.isArrowFunction(callback) || !call || !ts.isCallExpression(call) || !ts.isPropertyAccessExpression(call.expression) || call.expression.name.text !== "some") return undefined;
    const list = this.constant(call.expression.expression);
    return list && ts.isArrayLiteralExpression(list) && list.elements.every(ts.isRegularExpressionLiteral) ? list.elements as unknown as ts.RegularExpressionLiteral[] : undefined;
  }
  private list(e: ts.Expression | undefined, name: string): [string, ts.Node][] {
    return (stringList(e) ?? (() => { throw new Error(`${name} must be a literal string list`); })()).map(([text, node]) =>
      /^[A-Z]+ \/\S*$/.test(text) ? [text.replace(/:(\w+)/g, "{id}"), node] : this.fail(node, `${name} entry must be "METHOD /path"`));
  }
  private methodTest(e: ts.Expression): string[] | undefined {
    let x = skip(e);
    while (ts.isPrefixUnaryExpression(x) && x.operator === K.ExclamationToken) x = skip(x.operand);
    if (this.allowed.has(x) || this.sitesIn(x)[0] !== x) return undefined;
    const { methods } = this.classify(x);
    if (methods) this.consumed.add(x);
    return methods;
  }
  /** A guard on the factory's own inputs (`!host`, `options.synthesize`) is kept as source text. */
  private condition(e: ts.Expression, params: Set<ts.Node>, served: boolean, conds: Cond[]): void {
    const roots = (ts.isIdentifier(e) ? [e] : find(e, ts.isIdentifier)).filter(id => !(ts.isPropertyAccessExpression(id.parent) && id.parent.name === id));
    if (roots.length && !this.sitesIn(e).length && roots.every(id => params.has(resolveName(id)!)) && !conds.some(c => c.node === e)) conds.push({ text: code(e), served, node: e });
  }
  private status(e: ts.Expression | undefined): string | undefined {
    const n = e && statusOf(e);
    return n === undefined ? undefined : n < 300 ? "implemented" : n === 302 ? "302 redirect" : n === 405 ? "405 method not allowed" : String(n);
  }

  /** One site's facts. Methods come from its `&&`/`||` chain, the uses of the
   * constant it initializes, a method ternary in what it returns, or a
   * dominating method guard; composition conditions stay source text. */
  private siteFacts(site: ts.Node, frames: Frame[]): Fact[] {
    if (this.allowed.has(site)) return [];
    const test = this.classify(site);
    if (!test.routes) return [];
    this.consumed.add(site);
    const [own, ...callers] = frames as [Frame, ...Frame[]], conds: Cond[] = [];
    let elseStatus: string | undefined;
    const guard = (e: ts.Expression, params: Set<ts.Node>, served: boolean) => { const m = this.methodTest(e); if (!m) this.condition(e, params, served, conds); return m; };
    const operands = (from: ts.Node) => {
      const { top, ops } = chainOf(from), declines = ts.isIfStatement(top.parent) && top.parent.expression === top && returnsNull(top.parent.thenStatement);
      return { top, methods: ops.map(op => guard(op, own.params, !declines)).find(Boolean) };
    };
    const first = ts.isSwitchStatement(site) ? { top: site as ts.Node, methods: undefined } : operands(site), top = first.top, declaration = top.parent;
    let methods = first.methods;
    if (!methods && ts.isVariableDeclaration(declaration) && ts.isIdentifier(declaration.name)) {
      // `const settings = path === …`: the methods come from where it is used.
      const used = new Set(find(own.stop, (n): n is ts.Identifier => ts.isIdentifier(n) && n !== declaration.name && resolveName(n) === declaration.name).flatMap(ref => operands(ref).methods ?? []));
      methods = used.size ? [...used] : undefined;
    }
    // `return request.method === "GET" ? health() : methodNotAllowed("GET")`: the method picks the response.
    let served = servedBy(top);
    const ternary = served && skip(served);
    if (ternary && ts.isConditionalExpression(ternary)) {
      const m = this.methodTest(ternary.condition);
      if (m) { methods ??= m; served = ternary.whenTrue; if (!nullish(ternary.whenFalse)) elseStatus = this.status(ternary.whenFalse) ?? "implemented"; }
    }
    for (const frame of frames) for (let n: ts.Node = frame === own ? top : frame.from; n !== frame.stop && n.parent; n = n.parent) {
      const p = n.parent;
      if (ts.isBlock(p) || ts.isCaseClause(p) || ts.isDefaultClause(p) || ts.isSourceFile(p)) for (const s of p.statements) {
        if (s === n) break;
        if (ts.isIfStatement(s) && !s.elseStatement && returnsNull(s.thenStatement)) { const m = guard(s.expression, frame.params, false); methods ??= m; }
      }
      if (ts.isIfStatement(p) && p.thenStatement === n) { const m = guard(p.expression, frame.params, true); methods ??= m; }
    }
    const status = (e: ts.Expression | undefined) => this.status(e) ?? callers.map(f => this.status(servedBy(f.from))).find(Boolean) ?? "implemented";
    const declined = top === site && ts.isIfStatement(top.parent) && returnsNull(top.parent.thenStatement) && !(ts.isBinaryExpression(site) && site.operatorToken.kind === K.ExclamationEqualsEqualsToken);
    return test.routes.flatMap(({ method, path, node }) => {
      const clauses = ts.isCaseClause(node) ? node.parent.clauses.slice(node.parent.clauses.indexOf(node)) : [];
      const base = { path, conds, node, declined, status: declined ? "served by parent" : status(clauses.length ? firstReturn(clauses.find(c => c.statements.length)?.statements[0]) : served) };
      return [...(method ? [method] : methods ?? ["*"]).map(method => ({ ...base, method })), ...(elseStatus ? [{ ...base, method: "*", status: elseStatus }] : [])];
    });
  }
  /** A route factory's facts in source order, with same-file matcher helpers and nested factories at their call. */
  private groupFacts(decl: ts.FunctionDeclaration, callers: Frame[] = []): Fact[] {
    this.used.add(decl);
    const params = new Set<ts.Node>(decl.parameters.flatMap(p => names(p.name)));
    const items: [number, () => Fact[]][] = this.sitesIn(decl).map(site => [site.pos, () => this.siteFacts(site, [{ from: site, stop: decl, params }, ...callers])]);
    for (const call of find(decl, ts.isCallExpression)) {
      const frames = [{ from: call, stop: decl, params }, ...callers], helper = ts.isIdentifier(call.expression) ? localFunction(call.expression) : undefined;
      if (helper && !within(helper, decl) && this.sitesIn(helper).length)
        items.push([call.pos, () => this.sitesIn(helper).flatMap(site => this.siteFacts(site, [{ from: site, stop: helper, params: new Set() }, ...frames]))]);
      const group = ts.isPropertyAccessExpression(call.expression) && call.expression.name.text === "handle" ? this.constant(call.expression.expression) : undefined;
      const nested = group && ts.isCallExpression(group) ? this.factories.get(group.expression.getText()) : undefined;
      if (nested) items.push([call.pos, () => this.groupFacts(nested, frames)]);
    }
    const facts = merge(items.sort((a, b) => a[0] - b[0]).flatMap(([, facts]) => facts()));
    if (decl.name!.text === "createProxyRoutes") return this.proxy(decl, facts);
    if (decl.name!.text === "createModelRoutes") return this.router(decl, facts);
    const declined = facts.find(f => f.declined);
    return declined ? this.fail(declined.node, "a route test that declines is supported only in the isolated proxy") : facts;
  }
  /** The isolated proxy: MODEL_ROUTED POSTs pick a worker by the body's model; the final forward takes the rest. */
  private proxy(decl: ts.FunctionDeclaration, facts: Fact[]): Fact[] {
    const has = [...this.allowed].find((n): n is ts.CallExpression => within(n, decl) && ts.isCallExpression(n) && code(n.expression).endsWith(".has"));
    const handle = find(decl, ts.isMethodDeclaration).find(m => m.name.getText() === "handle"), last = handle?.body?.statements.at(-1);
    if (!has || !last || !ts.isReturnStatement(last) || !last.expression || !called(last.expression, "forward").length)
      return this.fail(handle ?? decl, "unrecognized proxy shape: expected MODEL_ROUTED routing and a final forward in handle");
    const routed = this.classify(has).routes!;
    for (const f of facts) if (f.method === "POST" && routed.some(r => r.path === f.path)) f.status = "routed by model id";
    return [...merge([...facts, ...routed.map(({ path, node }) => ({ method: "POST", path, node, status: "routed by model id", conds: [] }))]),
      { method: "*", path: ANY, status: "forwarded to the worker", conds: [], node: last, except: new Set(facts.map(f => f.path)) }];
  }
  /** The model router: MODEL_ROUTED POSTs lease the model the body names (else the current one); every other path it does not
   * answer itself is answered by the current model's own route chain (`createServingUnit`'s `routes`), read from its literal composition. */
  private router(decl: ts.FunctionDeclaration, facts: Fact[]): Fact[] {
    const has = find(decl, ts.isCallExpression).find(call => code(call.expression) === "MODEL_ROUTED.has");
    if (!has) return this.fail(decl, "unrecognized router shape: expected MODEL_ROUTED routing in handle");
    const routed = this.classify(has).routes!;
    for (const f of facts) if (f.method === "POST" && routed.some(r => r.path === f.path)) f.status = "routed by model id";
    const unit = this.fn(cli("serving-unit.ts"), "createServingUnit"), routes = find(unit, ts.isVariableDeclaration).find(d => d.name.getText() === "routes")?.initializer;
    if (!routes) return this.fail(unit, "unrecognized composition shape; expected `const routes = { handle: … }` in createServingUnit");
    return [...merge([...facts, ...routed.map(({ path, node }) => ({ method: "POST", path, node, status: "routed by model id", conds: [] }))]),
      ...this.chain(routes, new Map()).groups.flatMap(group => typeof group === "string" ? [] : this.groupFacts(group))];
  }
  /** start.ts's fixed dispatch: the modules' sockets, web assets, route groups, then 404. The listener names no path itself. */
  private listener(): void {
    const start = this.fn(server("start.ts"), "startServer"), fetch = find(start, ts.isMethodDeclaration).find(m => m.name.getText() === "fetch");
    const order = (fetch?.body?.statements ?? []).map(s => {
      const text = code(s);
      return text.includes("input.sockets.upgrade(") ? "sockets" : text.includes("input.web(") ? "web" : text.includes("input.routes.handle(") ? "routes"
        : ts.isReturnStatement(s) && s.expression && statusOf(s.expression) === 404 ? "404" : "";
    }).filter(Boolean);
    if (order.join() !== "sockets,web,routes,404" || this.groupFacts(start).length !== 0) this.fail(fetch ?? start, `the listener's dispatch changed (${order.join(", ")}); update the server API generator`);
  }

  /** The routes (`route: "routes"`) or sockets (`"sockets"`) of the installed modules that run in a scope, in manifest order: each entry of a `manifest` literal, at its mounted path.
   * A module runs in the persistent app state when it requires `jobs` or declares sockets, else with the model host (the app's `installedModules(scope)`). */
  private moduleFacts(scope: "state" | "model", kind: "routes" | "sockets" = "routes"): Fact[] {
    const string = (e: ts.Expression | undefined, what: string, at: ts.Node): string => { const x = e && skip(e); return x && ts.isStringLiteralLike(x) ? x.text : this.fail(at, `${what} must be a string literal`); };
    return [...this.files.keys()].filter(path => MANIFEST.test(path)).flatMap(path => {
      const file = this.file(path), manifest = find(file, ts.isVariableDeclaration).find(d => d.name.getText() === "manifest")?.initializer;
      if (!manifest) return this.fail(file, "the module manifest was not found");
      const fields = props(manifest), id = string(fields.get("id"), "the module id", manifest), list = fields.get(kind) && skip(fields.get(kind)!);
      const requires = stringList(fields.get("requires")) ?? this.fail(manifest, "the module's requires must be a literal list of strings");
      const sockets = fields.get("sockets") && skip(fields.get("sockets")!);
      if ((requires.some(([name]) => name === "jobs") || (!!sockets && ts.isArrayLiteralExpression(sockets) && sockets.elements.length > 0)) !== (scope === "state")) return [];
      if (list && !ts.isArrayLiteralExpression(list)) return this.fail(list, `manifest ${kind} must be a literal array`);
      return (list?.elements ?? []).map(route => {
        const parts = props(route), method = kind === "sockets" ? "GET" : string(parts.get("method"), "a route method", route), declared = string(parts.get("path"), `a ${kind === "sockets" ? "socket" : "route"} path`, route);
        const path = parts.has("mount") && string(parts.get("mount"), "a route mount", route) === "root" ? declared : `/api/${id}${declared === "/" ? "" : declared}`;
        return { method, path: path.replace(/:(\w+)/g, "{id}"), status: kind === "sockets" ? "WebSocket upgrade" : "implemented", conds: [], node: route } satisfies Fact;
      });
    });
  }

  // ---- composition: literal route group membership per mode ----
  private local(e: ts.Expression): ts.Expression {
    const x = skip(e);
    return !ts.isIdentifier(x) ? x : this.constant(x) ?? this.fail(x, `unrecognized composition shape: ${x.text} is not a constant`);
  }
  private factoryOf(e: ts.Expression): ts.FunctionDeclaration {
    const call = skip(e), decl = ts.isCallExpression(call) ? this.factories.get(call.expression.getText()) : undefined;
    return decl ?? this.fail(e, `unrecognized composition shape: \`${code(e).slice(0, 60)}\` is not an exported route factory call`);
  }
  /** `{ handle: async request => await a.handle(request) ?? … }`, optionally behind `hooks.routes?.(x) ?? x`. */
  private chain(routes: ts.Expression, state: Groups) {
    let e = this.local(routes), wrapped = false;
    if (ts.isBinaryExpression(e) && e.operatorToken.kind === K.QuestionQuestionToken && ts.isCallExpression(e.left) && code(e.left.expression) === "hooks.routes" &&
      e.left.arguments[0]?.getText() === e.right.getText()) { e = this.local(e.right); wrapped = true; }
    const fields = props(e), handle = fields.size === 1 ? fields.get("handle") : undefined, arrow = handle && skip(handle), operands: ts.Expression[] = [];
    if (!arrow || !ts.isArrowFunction(arrow) || ts.isBlock(arrow.body)) return this.fail(e, "unrecognized composition shape; expected `{ handle: async request => await group.handle(request) ?? … }`");
    const flat = (x: ts.Expression): void => { x = skip(x); if (ts.isBinaryExpression(x) && x.operatorToken.kind === K.QuestionQuestionToken) { flat(x.left); flat(x.right); } else operands.push(x); };
    flat(arrow.body);
    const groups = operands.flatMap(operand => {
      const receiver = ts.isCallExpression(operand) && ts.isPropertyAccessExpression(operand.expression) && operand.expression.name.text === "handle" ? skip(operand.expression.expression) : undefined;
      if (receiver && ts.isIdentifier(receiver)) {
        const made = this.local(receiver);
        return [ts.isCallExpression(made) && made.expression.getText() === MODULE_ROUTES ? "modules" as const : this.factoryOf(made)];
      }
      if (receiver && ts.isPropertyAccessExpression(receiver) && code(this.local(receiver.expression)).endsWith(".routes") && state.has(receiver.name.text))
        return [state.get(receiver.name.text)].filter(group => !!group);
      return this.fail(operand, "unrecognized composition shape; expected `await group.handle(request)` over a route factory or state group");
    });
    return { groups, node: e as ts.Node, wrapped };
  }
  /** `stateSockets`: whether the state this mode composes serves its modules' sockets (the app's does; the worker's stub does not). */
  private mode(file: string, name: string, state: Groups, stateSockets: boolean, web?: ts.FunctionDeclaration) {
    const scope = this.fn(cli(file), name), starts = called(scope, "startServer"), input = props(starts[0]?.arguments[0]);
    if (starts.length !== 1 || !input.has("routes") || !input.has("web") || !input.has("sockets")) return this.fail(scope, "unrecognized composition shape; expected one startServer({ routes, web, sockets, … })");
    const page = skip(input.get("web")!), sockets = this.local(input.get("sockets")!);
    if (!none(page) && code(page) !== "state.web") this.fail(page, "unrecognized web handler in the composition");
    // The listener serves either the state's sockets (the installed modules that run in the state) or none.
    const served = code(sockets) === "state.sockets" ? stateSockets : ts.isCallExpression(sockets) && code(sockets.expression) === "createModuleSockets" &&
      sockets.arguments.length === 1 && ts.isArrayLiteralExpression(sockets.arguments[0]!) && sockets.arguments[0].elements.length === 0 ? false
      : this.fail(sockets, "unrecognized sockets in the composition");
    return { ...this.chain(input.get("routes")!, state), web: none(page) ? undefined : web, sockets: served };
  }
  private modes() {
    const appState = this.fn(cli("serve-state.ts"), "createAppState"), state = props(appState.body!.statements.find(ts.isReturnStatement)?.expression);
    const appRoutes = state.has("routes") && state.has("web") ? this.local(state.get("routes")!) : undefined;
    if (!appRoutes || !ts.isObjectLiteralExpression(appRoutes)) return this.fail(appState, "unrecognized composition shape; createAppState must return its web handler and literal routes");
    const stateGroup = (e: ts.Expression): Group => { const made = skip(e); return ts.isCallExpression(made) && made.expression.getText() === MODULE_ROUTES ? "state-modules" : this.factoryOf(e); };
    const app: Groups = new Map([...props(appRoutes)].map(([key, e]) => [key, stateGroup(e)])), web = this.factoryOf(this.local(state.get("web")!));
    // The worker's state stands in for the web app and every persistent group with one that serves nothing.
    const workerState = this.fn(cli("worker-entry.ts"), "createWorkerState"), fields = props(workerState.body!.statements.find(ts.isReturnStatement)?.expression);
    const stubs = props(fields.get("routes")), worker: Groups = new Map([...stubs.keys()].map(key => [key, undefined]));
    if (!none(fields.get("web")) || !stubs.size || [...stubs.values()].some(e => !none(props(this.local(e)).get("handle"))))
      this.fail(workerState, "unrecognized composition shape; createWorkerState must serve nothing in place of the app state's groups");
    const entry = this.fn(cli("worker-entry.ts"), "runWorkerEntry"), hosts = called(entry, "startModelHost"), first = hosts[0]?.arguments[0] && skip(hosts[0].arguments[0]);
    if (hosts.length !== 1 || !first || !ts.isCallExpression(first) || first.expression.getText() !== "createWorkerState")
      return this.fail(hosts[0] ?? entry, "unrecognized composition shape; expected startModelHost(createWorkerState(…), …)");
    const admin = this.wrapper(props(hosts[0]!.arguments[3]).get("routes"), hosts[0]!), host = this.mode("serve-host.ts", "startContextHost", worker, false);
    // The `app` launch form: runServe's own compositions on the socket, each passed `socket(model, lease)`, whose routes hook is the admin wrap.
    const runner = this.fn(cli("worker-entry.ts"), "runAppWorker"), runs = called(runner, "runServe"), callbacks = props(runs[0]?.arguments[1]);
    const leases = [["start", "startModelServer"], ["startTranscription", "startTranscriptionServer"]].map(([key, composition]) => {
      const arrow = callbacks.get(key!) && skip(callbacks.get(key!)!), call = arrow && ts.isArrowFunction(arrow) && !ts.isBlock(arrow.body) ? skip(arrow.body) : undefined;
      const hooks = call && ts.isCallExpression(call) && call.arguments[2] ? skip(call.arguments[2]) : undefined;
      const socket = hooks && ts.isObjectLiteralExpression(hooks) ? hooks.properties.find(ts.isSpreadAssignment)?.expression : hooks, made = socket && skip(socket);
      if (runs.length !== 1 || !call || !ts.isCallExpression(call) || !code(this.local(call.expression)).endsWith(`?? ${composition}`) || !made || !ts.isCallExpression(made) || code(made.expression) !== "socket")
        return this.fail(runs[0] ?? runner, `unrecognized composition shape; expected runServe's ${key} to pass socket(…) to ${composition}`);
      const helper = this.local(made.expression), returned = ts.isArrowFunction(helper) && ts.isBlock(helper.body) ? helper.body.statements.find(ts.isReturnStatement)?.expression : undefined;
      this.wrapper(props(returned).get("routes"), helper);
      return made.arguments[1]?.getText() !== "false";
    });
    const serve = this.mode("serve-host.ts", "startContextHost", app, true, web), transcription = this.mode("serve-host.ts", "startTranscriptionHost", new Map(), false);
    if (!host.wrapped || !transcription.wrapped) this.fail(host.wrapped ? transcription.node : host.node, "the host must let the worker's admin routes wrap its routes");
    const lease = (leased: boolean) => leased ? "with" : "without";
    return [
      { id: "serve", title: "Server", ...serve, intro: "`mlx-bun serve`, and `createServer` from `mlx-bun/server` over a caller's loaded context: one process owns the loaded models (residency by memory fit; a caller's context is the only model), the browser app, chat, and jobs. Model-scoped paths belong to the current model." },
      { id: "isolate", title: "Isolated server (`--isolate`)", ...this.mode("serve-isolated.ts", "startIsolatedServer", app, true, web),
        intro: "`mlx-bun serve --isolate`: this process keeps the browser app, chat, jobs, and Responses history; models run in worker processes (one per model under `--model-pool`)." },
      { id: "worker", title: "Isolation worker socket", ...host, node: hosts[0]! as ts.Node, groups: [admin, ...host.groups],
        intro: "What an `--isolate` worker answers on its private Unix socket; only its parent connects. The worker admin routes answer ahead of the model routes." },
      { id: "app-worker", title: "App worker socket (`openIsolatedHost`)", ...serve, node: runs[0]! as ts.Node, groups: [admin, ...serve.groups],
        intro: `The \`app\` worker launch form (\`mlx-bun/engine\`'s \`openIsolatedHost\`): the Server app composed by \`runServe\` on a private Unix socket, the worker admin routes ahead of its route groups, ${lease(leases[0]!)} the execution lease. ` +
          `A Whisper checkpoint gets the transcription-only routes behind the same admin routes, ${lease(leases[1]!)} the execution lease.` },
      { id: "transcription", title: "Transcription-only server", ...transcription,
        intro: "`mlx-bun serve <whisper checkpoint>`: the audio and discovery routes only, with no chat model, jobs, or browser app." },
    ];
  }
  /** `routes: model => admin.wrap(model)` over `const admin = createWorkerRoutes(…)`: the worker admin routes answer first. */
  private wrapper(hook: ts.Expression | undefined, at: ts.Node): ts.FunctionDeclaration {
    const arrow = hook && skip(hook), call = arrow && ts.isArrowFunction(arrow) && !ts.isBlock(arrow.body) ? skip(arrow.body) : undefined;
    const admin = call && ts.isCallExpression(call) && ts.isPropertyAccessExpression(call.expression) && call.expression.name.text === "wrap" &&
      call.arguments[0]?.getText() === (arrow as ts.ArrowFunction).parameters[0]?.name.getText() ? this.factoryOf(this.local(call.expression.expression)) : undefined;
    return admin?.name?.text === "createWorkerRoutes" ? admin : this.fail(hook ?? at, "unrecognized composition shape; expected `routes: model => admin.wrap(model)` over createWorkerRoutes");
  }

  evaluate(): ServerApi {
    this.listener();
    const modes = this.modes().map(spec => {
      const facts = [...(spec.sockets ? this.moduleFacts("state", "sockets") : []), ...(spec.web ? this.groupFacts(spec.web) : []),
        ...spec.groups.flatMap(group => group === "modules" ? this.moduleFacts("model") : group === "state-modules" ? this.moduleFacts("state") : this.groupFacts(group))];
      // The first unconditional match answers; the proxy's forward takes every path it did not name.
      const kept: Fact[] = [];
      for (const f of facts) if (!kept.some(k => !k.declined && !k.conds.length && (k.method === "*" || k.method === f.method) &&
        (k.path === f.path || (k.path === ANY && !k.except!.has(f.path))))) kept.push(f);
      return { spec, facts: kept };
    });
    for (const [name, decl] of this.factories) if (!this.used.has(decl)) this.fail(decl, `${name} is not composed into any server mode (cli/serve-host.ts, cli/serve-isolated.ts, cli/worker-entry.ts)`);
    for (const { sites } of this.scans.values()) for (const site of sites) if (!this.consumed.has(site) && !this.allowed.has(site))
      this.fail(site, `unsupported routing predicate \`${code(site).slice(0, 120)}\`; extend the server API generator or allowlist a non-route site`);
    // The advertised endpoint lists are independent claims about the served surface.
    const advertised = find(this.file(server("discovery-routes.ts")), ts.isPropertyAssignment).find(p => p.name.getText() === "endpoints");
    for (const [id, entries] of [["serve", this.list(advertised?.initializer, "server/discovery-routes.ts: the /v1 endpoint list")]] as const) {
      const { facts } = modes.find(m => m.spec.id === id)!;
      for (const [entry, node] of entries) {
        const [method, path] = entry.split(" ");
        if (!facts.some(f => f.path === path && (f.method === "*" || f.method === method))) this.fail(node, `advertised endpoint "${entry}" is not an extracted ${id} route`);
      }
    }
    return { modes: modes.map(({ spec, facts }) => ({ id: spec.id, title: spec.title, intro: spec.intro, composed: this.where(spec.node),
      routes: facts.map(f => ({ method: f.method, path: f.path, status: f.status, ...this.where(f.node), conds: f.conds.map(c => ({ text: c.text, served: c.served, ...this.where(c.node) })) })) })) };
  }
}

/** Parse the route handlers and their composition without executing either.
 * Fails on an unsupported routing predicate rather than omit a route. */
export function serverApiReference(sources: ReadonlyMap<string, string>): ServerApi { return new Inventory(sources).evaluate(); }

export async function serverSources(repository = root): Promise<Map<string, string>> {
  const paths = [...COMPOSITION_SOURCES, WEB_SOURCE, COMPANION_SOURCE];
  for await (const path of new Bun.Glob(ROUTE_GLOB).scan(repository)) paths.push(path);
  const sources = new Map(await Promise.all(paths.sort().map(async path => [path, await readFile(resolve(repository, path), "utf8")] as const)));
  for (const { path, source } of await installedManifests(repository)) sources.set(path, source);
  return sources;
}

export function renderServerApi(api: ServerApi, revision: string): string {
  const short = (file: string) => file.startsWith(APP) ? file.slice(APP.length) : file.replace(/^packages\//, "");
  const link = (file: string, line: number, text = `${short(file)}:${line}`) => `[${text}](https://github.com/joshuarossi/mlx-bun/blob/${revision}/${file}#L${line})`;
  const status = (r: Route) => !r.conds.length ? r.status : `${r.status === "implemented" ? "" : `${r.status}; `}conditional: ${r.conds
    .map(c => `${c.served ? "served" : "falls through"} if ${link(c.file, c.line, `\`${c.text}\``)}`).join("; ")}`;
  const order = ["GET", "POST", "PUT", "PATCH", "DELETE", "*"], table = (routes: Route[]) => {
    const rows = new Map<string, { methods: string[]; route: Route; status: string }>();
    for (const route of routes) {
      const text = status(route), key = `${route.file}:${route.line} ${route.path} ${text}`;
      rows.get(key)?.methods.push(route.method) ?? rows.set(key, { methods: [route.method], route, status: text });
    }
    return [...rows.values()].map(({ methods, route, status }) => `| ${methods.sort((a, b) => order.indexOf(a) - order.indexOf(b)).join(", ")} | \`${route.path}\` | ` +
      `${status.replaceAll("|", "\\|")} | ${link(route.file, route.line)} |`).join("\n");
  };
  return `---\ntitle: HTTP API reference\ndescription: Routes each server mode answers, generated from the application's route handlers.\n---\n\n` +
    `Generated at build time from the route handlers in \`apps/mlx-bun/src/server\` and their composition in \`apps/mlx-bun/src/cli\`, and from the manifests of the modules the app installs, without running the app. ` +
    `These are the refactor's current routes; released versions can differ.\n\n` +
    `Each table lists what one kind of server process answers, in dispatch order: the first matching row answers, and a request no row matches gets 404. ` +
    `\`*\` means every method not listed in an earlier row for the same path; path parameters appear as \`{id}\`. The source link is the check that selects the route.\n\n` +
    `- **implemented**: the handler answers.\n` +
    `- **conditional**: the row depends on the quoted composition input; when it does not apply, the request falls through to later rows.\n` +
    `- **WebSocket upgrade**: a socket an installed module declares in its manifest (\`GET /ws/chat\` opens the browser's chat session with the Pi agent, served by \`@mlx-bun/module-chat\`); the listener upgrades it before any other row, and a server whose state runs no such module answers the path like any other.\n` +
    `- **routed by model id**: the request goes to the local model the JSON body's \`model\` names (loaded on demand, another drained first when it does not fit), else to the current model.\n` +
    `- Under \`--isolate\`: **served by parent** paths are never forwarded; **routed by model id** requests go to the worker serving the JSON body's \`model\`, else the default worker; ` +
    `**forwarded to the worker** requests stream to the default worker unchanged.\n\n` +
    api.modes.map(mode => `## ${mode.title}\n\n${mode.intro} Composed at ${link(mode.composed.file, mode.composed.line)}.\n\n` +
      `| Method | Path | Status | Source |\n| --- | --- | --- | --- |\n${table(mode.routes)}\n`).join("\n");
}

export async function generateServerApi(options: { repository?: string; destination?: string; revision?: string } = {}): Promise<ServerApi> {
  const repository = options.repository ?? root, destination = options.destination ?? resolve(import.meta.dir, "..");
  const api = serverApiReference(await serverSources(repository)), page = resolve(destination, SERVER_API_PAGE);
  await mkdir(dirname(page), { recursive: true });
  await writeFile(page, renderServerApi(api, options.revision ?? sourceRevision(repository)));
  return api;
}

if (import.meta.main) {
  if (process.argv.includes("--help")) console.log(`Usage: bun scripts/generate-server-api.ts\nGenerate the HTTP route inventory from ${ROUTE_GLOB} and the serve composition without running the app.`);
  else console.log(`Verified ${(await generateServerApi()).modes.map(mode => `${mode.routes.length} ${mode.id}`).join(", ")} routes.`);
}
