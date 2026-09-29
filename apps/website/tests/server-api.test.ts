import { expect, test } from "bun:test";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import { SERVER_API_PAGE, expandRoutePattern, generateServerApi, renderServerApi, serverApiReference, serverSources, type ServerApi } from "../scripts/generate-server-api";

const root = resolve(import.meta.dir, "../../..");
const APP = "apps/mlx-bun/src/", sources = await serverSources(), baseline = serverApiReference(sources);
/** The real sources with one exact edit, which must apply. */
function mutate(file: string, from: string, to: string): Map<string, string> {
  const text = sources.get(`${APP}${file}`)!;
  expect(text).toContain(from);
  return new Map(sources).set(`${APP}${file}`, text.replace(from, to));
}
const rows = (api: ServerApi, id: string) => api.modes.find(mode => mode.id === id)!.routes
  .map(r => `${r.method} ${r.path} ${r.status}${r.conds.map(c => ` [${c.served ? "served" : "falls through"} if ${c.text}]`).join("")}`);

test("each server mode lists its composed routes, statuses, and conditions", () => {
  expect(baseline.modes.map(mode => mode.id)).toEqual(["serve", "isolate", "worker", "app-worker", "transcription"]);
  const serve = rows(baseline, "serve");
  for (const row of ["GET /ws/chat WebSocket upgrade (Pi chat)", "GET / implemented", "GET /status 302 redirect", "POST /v1/chat/completions implemented",
    "GET /v1/models/{id} implemented", "DELETE /v1/adapters/{id} implemented", "GET /api/jobs/{id}/stream implemented", "POST /api/dataset/push implemented",
    "POST /api/hub/download implemented [falls through if !options.downloads]", "GET /v1/memory/synthesize implemented [served if options.synthesize]",
    "POST /v1/audio/sessions/{id}/finish implemented [falls through if !host]"]) expect(serve).toContain(row);
  // Routes no serve composition mounts have no row: lease, drain and /engine are unknown paths (404) here.
  expect(serve.filter(row => /^\S+ \/(admin\/(lease|drain)|engine)\b/.test(row))).toEqual([]);
  const isolate = rows(baseline, "isolate");
  for (const row of ["* /admin/lease served by parent", "* /admin/memory/complete served by parent", "GET /engine implemented", "POST /v1/responses routed by model id", "POST /v1/embeddings routed by model id",
    "* (any other path) forwarded to the worker"]) expect(isolate).toContain(row);
  expect(isolate).not.toContain("POST /v1/chat/completions implemented");
  const worker = rows(baseline, "worker");
  for (const row of ["GET /health implemented", "* /health 405 method not allowed", "POST /admin/lease implemented [served if options.acquireExecutionLease]",
    "POST /admin/memory/complete implemented [served if options.memoryTaskModel] [served if options.acquireExecutionLease]",
    "* /admin/memory/complete 405 method not allowed [served if options.memoryTaskModel] [served if options.acquireExecutionLease]", "POST /v1/chat/completions implemented"]) expect(worker).toContain(row);
  // The admin routes answer first: discovery's /health is unreachable here.
  expect(worker.filter(row => row.includes(" /health "))).toEqual(["GET /health implemented", "* /health 405 method not allowed"]);
  // The worker state stands in for the persistent groups with ones that serve nothing.
  expect(worker.some(row => /^\S+ \/api\/(hub|jobs|memory|sessions|quantize|dataset)\b/.test(row))).toBe(false);
  // The app launch form: the Server app, web and chat included, with the same admin routes ahead of its groups.
  const appWorker = rows(baseline, "app-worker");
  expect(appWorker).toEqual([...serve.slice(0, 13), ...worker.slice(1, 9), ...serve.slice(13).filter(row => !/^GET \/health/.test(row))]);
  expect(baseline.modes.find(mode => mode.id === "app-worker")!.intro).toContain("A Whisper checkpoint gets the transcription-only routes behind the same admin routes, without the execution lease.");
  const transcription = rows(baseline, "transcription");
  expect(transcription).toContain("GET /ws/chat WebSocket upgrade (no chat model)");
  expect(transcription).toContain("DELETE /v1/audio/sessions/{id} implemented [falls through if !host]");
  expect(transcription.some(row => row.startsWith("GET / "))).toBe(false);
  for (const mode of baseline.modes) for (const route of mode.routes) expect(route.file.startsWith(APP) && route.line > 0).toBe(true);
});

test("generation writes a build-owned page with source links at the revision", async () => {
  const destination = await mkdtemp(resolve(tmpdir(), "mlx-site-server-api-")), revision = "a".repeat(40);
  try {
    await generateServerApi({ destination, revision });
    const page = await readFile(resolve(destination, SERVER_API_PAGE), "utf8");
    expect(page).toBe(renderServerApi(baseline, revision));
    expect(page).toContain("title: HTTP API reference");
    for (const title of ["## Server", "## Isolated server (`--isolate`)", "## Isolation worker socket", "## App worker socket (`openIsolatedHost`)", "## Transcription-only server"])
      expect(page).toContain(`\n${title}\n`);
    expect(page).toMatch(/\| GET \| `\/v1\/models` \| implemented \| \[server\/discovery-routes\.ts:\d+\]\(https:\/\/github\.com\/joshuarossi\/mlx-bun\/blob\/a{40}\/apps\/mlx-bun\/src\/server\/discovery-routes\.ts#L\d+\) \|/);
    expect(page).toMatch(/conditional: falls through if \[`!host`\]\(https:\/\/github\.com\/joshuarossi\/mlx-bun\/blob\/a{40}\/apps\/mlx-bun\/src\/server\/audio-routes\.ts#L\d+\)/);
  } finally { await rm(destination, { recursive: true, force: true }); }
  expect(await readFile(resolve(root, "apps/website/.gitignore"), "utf8")).toContain(SERVER_API_PAGE);
});

test("an added unsupported routing predicate fails with its location; an unrelated path does not", () => {
  expect(() => serverApiReference(mutate("server/dataset-routes.ts", '    if (request.method !== "POST" || path !== "/api/dataset/submit") return null;',
    '    if (path.endsWith("/templates")) return null;\n    if (request.method !== "POST" || path !== "/api/dataset/submit") return null;')))
    .toThrow(/^server\/dataset-routes\.ts:14: unsupported routing predicate `path\.endsWith\("\/templates"\)`/);
  expect(() => serverApiReference(mutate("server/job-routes.ts", "/^\\/api\\/jobs\\/([^/]+?)(\\/stream)?$/", "/^\\/api\\/jobs\\/(.*)$/")))
    .toThrow(/^server\/job-routes\.ts:13: unsupported regex syntax/);
  // A value named `path` that is not the request's path is not a route.
  const unrelated = mutate("server/management-routes.ts", "  const canonicalPath = (path: string) => {", '  const isRoot = (path: string) => path === "/";\n  const canonicalPath = (path: string) => {');
  expect(rows(serverApiReference(unrelated), "serve")).toEqual(rows(baseline, "serve"));
});

test("string-keyed request reads route like property reads; a computed key on the request fails with its location", () => {
  // `request["method"]` and `new URL(request["url"])["pathname"]` are the same routes as their property forms.
  expect(serverApiReference(mutate("server/status-routes.ts", 'if (request.method !== "GET") return null;', 'if (request["method"] !== "GET") return null;'))).toEqual(baseline);
  expect(serverApiReference(mutate("server/dataset-routes.ts", "const path = new URL(request.url).pathname;", 'const path = new URL(request["url"])["pathname"];'))).toEqual(baseline);
  // The reviewer's case: a new route written only with string keys is listed, not silently omitted.
  const added = serverApiReference(mutate("server/status-routes.ts", '  return { async handle(request: Request): Promise<Response | null> {\n',
    '  return { async handle(request: Request): Promise<Response | null> {\n    if (request["method"] === "GET" && new URL(request["url"]).pathname === "/new-route") return Response.json({});\n'));
  expect(rows(added, "serve")).toContain("GET /new-route implemented");
  expect(rows(added, "serve").filter(row => !row.includes("/new-route"))).toEqual(rows(baseline, "serve"));
  const cache = serverApiReference(mutate("server/cache-routes.ts", "${request.method} ${new URL(request.url).pathname}", '${request["method"]} ${new URL(request["url"]).pathname}'));
  expect(cache.modes.map(mode => rows(cache, mode.id))).toEqual(baseline.modes.map(mode => rows(baseline, mode.id)));
  expect(() => serverApiReference(mutate("server/status-routes.ts", 'if (request.method !== "GET") return null;', 'const key = "method"; if (request[key] !== "GET") return null;')))
    .toThrow(/^server\/status-routes\.ts:50: unsupported routing predicate `request\[key\] !== "GET"`/);
  expect(() => serverApiReference(mutate("server/dataset-routes.ts", "const path = new URL(request.url).pathname;", 'const key = "url"; const path = new URL(request[key]).pathname;')))
    .toThrow(/^server\/dataset-routes\.ts:\d+: unsupported routing predicate `request\[key\]`/);
});

test("removing a route removes exactly its row", () => {
  const removed = serverApiReference(mutate("server/memory-routes.ts", '        case "GET /api/memory/diff": return handleMemoryDiff(url);\n', ""));
  for (const id of ["serve", "isolate"]) {
    expect(rows(baseline, id)).toContain("GET /api/memory/diff implemented");
    expect(rows(removed, id)).toEqual(rows(baseline, id).filter(row => row !== "GET /api/memory/diff implemented"));
  }
});

test("each listed transcription session endpoint needs its sub-route guard, and each guard a listed endpoint", () => {
  expect(() => serverApiReference(mutate("server/audio-routes.ts", '    if (method === "POST" && rest[1] === "finish" && rest.length === 2) return { kind: "session-finish", id };\n', "")))
    .toThrow(/^server\/transcription-server\.ts:\d+: TRANSCRIPTION_SERVER_ENDPOINTS entry "POST \/v1\/audio\/sessions\/\{id\}\/finish" has no matching sub-route guard/);
  expect(() => serverApiReference(mutate("server/audio-routes.ts", 'rest[1] === "finish"', 'rest[1] === "close"')))
    .toThrow(/^server\/audio-routes\.ts:\d+: sub-route guard for "POST \/v1\/audio\/sessions\/\{id\}\/close" matches no TRANSCRIPTION_SERVER_ENDPOINTS entry/);
});

test("a changed or removed allowlisted non-route site fails", () => {
  expect(() => serverApiReference(mutate("server/adapter-artifact-routes.ts", 'path.endsWith("/merge")', 'path.endsWith("/merged")')))
    .toThrow("Allowlisted non-route site changed or disappeared: server/adapter-artifact-routes.ts createAdapterArtifactRoutes");
  expect(() => serverApiReference(mutate("server/proxy-routes.ts", '  if (pathname === "/v1/responses")\n', "  if (false)\n")))
    .toThrow("Allowlisted non-route site changed or disappeared: server/proxy-routes.ts unavailableFrame");
});

test("a path answered by the listener itself, not a route group, fails the dispatch check", () => {
  expect(() => serverApiReference(mutate("server/start.ts", '        return Response.json({ error: { message: "Not found" } }, { status: 404 });',
    '        if (url.pathname === "/engine") return Response.json({ error: { message: "placeholder" } }, { status: 501 });\n        return Response.json({ error: { message: "Not found" } }, { status: 404 });')))
    .toThrow(/^server\/start\.ts:\d+: the listener's dispatch changed/);
});

test("a route factory outside every server mode fails", () => {
  const extra = new Map(sources).set(`${APP}server/extra-routes.ts`,
    'export function createExtraRoutes() {\n  return { async handle(request: Request) { return new URL(request.url).pathname === "/extra" ? Response.json({}) : null; } };\n}\n');
  expect(() => serverApiReference(extra)).toThrow("server/extra-routes.ts:1: createExtraRoutes is not composed into any server mode");
});

test("an unrecognized composition shape fails", () => {
  expect(() => serverApiReference(mutate("cli/serve-isolated.ts", "?? await proxy.handle(request) };", "?? await forwardAll(request) };")))
    .toThrow(/^cli\/serve-isolated\.ts:\d+: unrecognized composition shape; expected `await group\.handle\(request\)`/);
  expect(() => serverApiReference(mutate("cli/worker-entry.ts", "routes: model => admin.wrap(model)", "routes: model => admin.guard(model)")))
    .toThrow(/^cli\/worker-entry\.ts:\d+: unrecognized composition shape/);
  // The app launch form's socket hooks: the admin wrap, passed by both runServe compositions.
  expect(() => serverApiReference(mutate("cli/worker-entry.ts", "routes: (routes: RouteGroup) => admin.wrap(routes)", "routes: (routes: RouteGroup) => routes")))
    .toThrow(/^cli\/worker-entry\.ts:\d+: unrecognized composition shape; expected `routes: model => admin\.wrap\(model\)` over createWorkerRoutes/);
  expect(() => serverApiReference(mutate("cli/worker-entry.ts", "startTranscription(model, options, socket(model, false))", "startTranscription(model, options, {})")))
    .toThrow(/^cli\/worker-entry\.ts:\d+: unrecognized composition shape; expected runServe's startTranscription to pass socket\(…\) to startTranscriptionServer/);
});

test("route regexes expand only the literal subset", () => {
  expect(expandRoutePattern("/^\\/api\\/jobs\\/([^/]+?)(\\/stream)?$/")).toEqual(["/api/jobs/{id}/stream", "/api/jobs/{id}"]);
  expect(expandRoutePattern("/^\\/admin\\/(?:lease|drain)$/")).toEqual(["/admin/lease", "/admin/drain"]);
  for (const pattern of ["/^\\/a\\/.*$/", "/^\\/a\\/(\\d+)$/", "/^\\/a\\/([^/]+)\\/([^/]+)$/", "/\\/a/i", "/^\\/a((b))$/"]) expect(() => expandRoutePattern(pattern)).toThrow();
});
