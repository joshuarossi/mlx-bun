import { expect, test } from "bun:test";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import { SERVER_API_PAGE, expandRoutePattern, generateServerApi, renderServerApi, serverApiReference, serverSources, type ServerApi } from "../scripts/generate-server-api";

const root = resolve(import.meta.dir, "../../..");
const APP = "apps/mlx-bun/src/", sources = await serverSources(), baseline = serverApiReference(sources);
/** The real sources with one exact edit, which must apply. A path outside the app's source is given whole. */
function mutate(file: string, from: string, to: string): Map<string, string> {
  const path = file.startsWith("packages/") ? file : `${APP}${file}`, text = sources.get(path)!;
  expect(text).toContain(from);
  return new Map(sources).set(path, text.replace(from, to));
}
const MANIFEST = "packages/module-transcription/src/manifest.ts";
const rows = (api: ServerApi, id: string) => api.modes.find(mode => mode.id === id)!.routes
  .map(r => `${r.method} ${r.path} ${r.status}${r.conds.map(c => ` [${c.served ? "served" : "falls through"} if ${c.text}]`).join("")}`);

test("each server mode lists its composed routes, statuses, and conditions", () => {
  expect(baseline.modes.map(mode => mode.id)).toEqual(["serve", "isolate", "worker", "app-worker", "transcription"]);
  const serve = rows(baseline, "serve");
  for (const row of ["GET /ws/chat WebSocket upgrade", "GET / implemented", "GET /status 302 redirect", "POST /v1/chat/completions routed by model id",
    "GET /v1/models/{id} implemented", "DELETE /v1/adapters/{id} implemented", "GET /api/jobs/{id}/stream implemented", "POST /api/dataset/push implemented",
    "POST /api/hub/download implemented", "GET /v1/memory/synthesize implemented [served if options.synthesize]",
    "POST /v1/audio/sessions/{id}/finish implemented", "GET /api/dataset/templates implemented", "POST /api/dataset/submit implemented"]) expect(serve).toContain(row);
  // The datasets module needs job runners, so it runs in the persistent state: the isolated parent serves it, the transcription-only host does not.
  expect(rows(baseline, "isolate")).toContain("POST /api/dataset/submit implemented");
  expect(rows(baseline, "transcription").some(row => row.includes("/api/dataset"))).toBe(false);
  // Routes no serve composition mounts have no row: lease, drain and /engine are unknown paths (404) here.
  expect(serve.filter(row => /^\S+ \/(admin\/(lease|drain)|engine)\b/.test(row))).toEqual([]);
  const isolate = rows(baseline, "isolate");
  for (const row of ["* /admin/lease served by parent", "* /admin/memory/complete served by parent", "GET /engine implemented", "POST /v1/responses implemented", "GET /downloads implemented",
    "* (any other path) forwarded to the worker"]) expect(isolate).toContain(row);
  // The parent holds the residency of the workers: it routes each model-scoped POST by model id and forwards the rest to the current model's worker.
  for (const row of ["POST /v1/chat/completions routed by model id", "POST /v1/embeddings routed by model id"]) expect(isolate).toContain(row);
  expect(isolate.filter(row => /^\S+ \/(v1\/(models|embeddings)|stats|health)\b/.test(row) && !row.includes("served by parent") && !row.includes("routed by model id"))).toEqual(["GET /health implemented", "GET /stats implemented"]);
  expect(isolate).not.toContain("POST /v1/chat/completions implemented");
  const worker = rows(baseline, "worker");
  for (const row of ["GET /health implemented", "* /health 405 method not allowed", "POST /admin/lease implemented [served if options.acquireExecutionLease]",
    "POST /admin/memory/complete implemented [served if options.memoryTaskModel] [served if options.acquireExecutionLease]",
    "* /admin/memory/complete 405 method not allowed [served if options.memoryTaskModel] [served if options.acquireExecutionLease]", "POST /v1/chat/completions routed by model id"]) expect(worker).toContain(row);
  // The admin routes answer first: discovery's /health is unreachable here.
  expect(worker.filter(row => row.includes(" /health "))).toEqual(["GET /health implemented", "* /health 405 method not allowed"]);
  // The worker state stands in for the persistent groups with ones that serve nothing.
  expect(worker.some(row => /^\S+ \/api\/(hub|jobs|memory|sessions|quantize|dataset)\b/.test(row))).toBe(false);
  // The app launch form: the Server app, web and chat included, with the same admin routes ahead of its groups.
  const appWorker = rows(baseline, "app-worker");
  // The admin rows are the worker's own: everything ahead of its first model route (the isolation worker serves no chat socket).
  const admin = worker.slice(0, worker.indexOf("POST /v1/chat/completions routed by model id"));
  expect(admin.length).toBeGreaterThan(8);
  expect(admin).toContain("GET /admin/events implemented [served if (options.events || options.memory)]");
  expect(admin.some(row => /\/admin\/served?\b/.test(row))).toBe(false);
  expect(appWorker).toEqual([...serve.slice(0, 13), ...admin, ...serve.slice(13).filter(row => !/^GET \/health/.test(row))]);
  expect(baseline.modes.find(mode => mode.id === "app-worker")!.intro).toContain("A Whisper checkpoint gets the transcription-only routes behind the same admin routes, without the execution lease.");
  const transcription = rows(baseline, "transcription");
  // The chat module runs in the persistent state, so the transcription-only host and the isolation worker (whose state is a stub) do not upgrade its socket.
  expect(transcription.some(row => row.includes("/ws/chat"))).toBe(false);
  expect(worker.some(row => row.includes("/ws/chat"))).toBe(false);
  expect(rows(baseline, "isolate")[0]).toBe("GET /ws/chat WebSocket upgrade");
  expect(appWorker[0]).toBe("GET /ws/chat WebSocket upgrade");
  expect(transcription).toContain("DELETE /v1/audio/sessions/{id} implemented");
  expect(transcription.some(row => row.startsWith("GET / "))).toBe(false);
  for (const mode of baseline.modes) for (const route of mode.routes) expect((route.file.startsWith(APP) || route.file.startsWith("packages/")) && route.line > 0).toBe(true);
});

test("generation writes a build-owned page with source links at the revision", async () => {
  const destination = await mkdtemp(resolve(tmpdir(), "mlx-site-server-api-")), revision = "a".repeat(40);
  try {
    await generateServerApi({ destination, revision });
    const page = await readFile(resolve(destination, SERVER_API_PAGE), "utf8");
    expect(page).toBe(renderServerApi(baseline, revision));
    expect(page).toContain("title: HTTP API reference");
    for (const title of ["## In-process server (`--in-process`)", "## Isolated server (the default)", "## Isolation worker socket", "## App worker socket (`openIsolatedHost`)", "## Transcription-only server"])
      expect(page).toContain(`\n${title}\n`);
    expect(page).toMatch(/\| GET \| `\/v1\/models` \| implemented \| \[server\/model-routes\.ts:\d+\]\(https:\/\/github\.com\/joshuarossi\/mlx-bun\/blob\/a{40}\/apps\/mlx-bun\/src\/server\/model-routes\.ts#L\d+\) \|/);
    // A module's routes cite its manifest, and the shared discovery routes their library file.
    expect(page).toMatch(/\| POST \| `\/v1\/audio\/transcriptions` \| implemented \| \[module-transcription\/src\/manifest\.ts:\d+\]\(https:\/\/github\.com\/joshuarossi\/mlx-bun\/blob\/a{40}\/packages\/module-transcription\/src\/manifest\.ts#L\d+\) \|/);
    expect(page).toMatch(/\| GET \| `\/health` \| implemented \| \[app-services\/src\/companion-info-routes\.ts:\d+\]/);
    expect(page).toMatch(/\| POST \| `\/v1\/embeddings` \| routed by model id \| \[server\/model-routes\.ts:\d+\]/);
  } finally { await rm(destination, { recursive: true, force: true }); }
  expect(await readFile(resolve(root, "apps/website/.gitignore"), "utf8")).toContain(SERVER_API_PAGE);
});

test("an added unsupported routing predicate fails with its location; an unrelated path does not", () => {
  const guard = '    if (!(settings && ["GET", "POST"].includes(request.method)) && !(push && request.method === "POST")) return null;';
  expect(() => serverApiReference(mutate("server/publishing-routes.ts", guard, `    if (path.endsWith("/templates")) return null;\n${guard}`)))
    .toThrow(/^server\/publishing-routes\.ts:\d+: unsupported routing predicate `path\.endsWith\("\/templates"\)`/);
  expect(() => serverApiReference(mutate("server/job-routes.ts", "/^\\/api\\/jobs\\/([^/]+?)(\\/stream)?$/", "/^\\/api\\/jobs\\/(.*)$/")))
    .toThrow(/^server\/job-routes\.ts:13: unsupported regex syntax/);
  // A value named `path` that is not the request's path is not a route.
  const unrelated = mutate("server/job-routes.ts", "  return { async handle(request: Request): Promise<Response | null> {", '  const isRoot = (path: string) => path === "/";\n  return { async handle(request: Request): Promise<Response | null> {');
  expect(rows(serverApiReference(unrelated), "serve")).toEqual(rows(baseline, "serve"));
});

test("string-keyed request reads route like property reads; a computed key on the request fails with its location", () => {
  // `request["method"]` and `new URL(request["url"])["pathname"]` are the same routes as their property forms.
  expect(serverApiReference(mutate("server/status-routes.ts", 'if (request.method !== "GET") return null;', 'if (request["method"] !== "GET") return null;'))).toEqual(baseline);
  expect(serverApiReference(mutate("server/publishing-routes.ts", "const path = new URL(request.url).pathname;", 'const path = new URL(request["url"])["pathname"];'))).toEqual(baseline);
  // The reviewer's case: a new route written only with string keys is listed, not silently omitted.
  const added = serverApiReference(mutate("server/status-routes.ts", '  return { async handle(request: Request): Promise<Response | null> {\n',
    '  return { async handle(request: Request): Promise<Response | null> {\n    if (request["method"] === "GET" && new URL(request["url"]).pathname === "/new-route") return Response.json({});\n'));
  expect(rows(added, "serve")).toContain("GET /new-route implemented");
  expect(rows(added, "serve").filter(row => !row.includes("/new-route"))).toEqual(rows(baseline, "serve"));
  const cache = serverApiReference(mutate("server/cache-routes.ts", "${request.method} ${new URL(request.url).pathname}", '${request["method"]} ${new URL(request["url"]).pathname}'));
  expect(cache.modes.map(mode => rows(cache, mode.id))).toEqual(baseline.modes.map(mode => rows(baseline, mode.id)));
  expect(() => serverApiReference(mutate("server/status-routes.ts", 'if (request.method !== "GET") return null;', 'const key = "method"; if (request[key] !== "GET") return null;')))
    .toThrow(/^server\/status-routes\.ts:50: unsupported routing predicate `request\[key\] !== "GET"`/);
  expect(() => serverApiReference(mutate("server/publishing-routes.ts", "const path = new URL(request.url).pathname;", 'const key = "url"; const path = new URL(request[key]).pathname;')))
    .toThrow(/^server\/publishing-routes\.ts:\d+: unsupported routing predicate `request\[key\]`/);
});

test("removing a route removes exactly its row", () => {
  const removed = serverApiReference(mutate("server/memory-routes.ts", '        case "GET /api/memory/diff": return handleMemoryDiff(url);\n', ""));
  for (const id of ["serve", "isolate"]) {
    expect(rows(baseline, id)).toContain("GET /api/memory/diff implemented");
    expect(rows(removed, id)).toEqual(rows(baseline, id).filter(row => row !== "GET /api/memory/diff implemented"));
  }
});

test("an installed module's routes come from its manifest at their mounted paths, in manifest order, wherever the composition mounts modules", () => {
  const audio = (id: string) => rows(baseline, id).filter(row => /^\S+ \/(v1\/audio|admin\/transcription)\//.test(row));
  for (const id of ["serve", "isolate", "worker", "app-worker", "transcription"].filter(id => id !== "isolate")) {
    expect(audio(id).map(row => row.split(" ")[0] + " " + row.split(" ")[1])).toEqual(["POST /v1/audio/transcriptions", "POST /v1/audio/translations", "POST /admin/transcription/unload",
      "POST /v1/audio/sessions", "POST /v1/audio/sessions/{id}/audio", "POST /v1/audio/sessions/{id}/finish", "DELETE /v1/audio/sessions/{id}"]);
  }
  // The isolated parent forwards them to its worker instead of serving them.
  expect(audio("isolate")).toEqual([]);
  // Removing a manifest route removes exactly its row in every mode that mounts modules.
  const removed = serverApiReference(mutate(MANIFEST, '    { id: "unload", method: "POST", path: "/admin/transcription/unload", summary: "Page the Whisper weights out now; reports the residency counters", response: "json", mount: "root" },\n', ""));
  for (const id of ["serve", "worker", "app-worker", "transcription"])
    expect(rows(removed, id)).toEqual(rows(baseline, id).filter(row => !row.startsWith("POST /admin/transcription/unload")));
  // A route without `mount: "root"` is served under its module's `/api/<id>`, so the path the /v1 index advertises is no longer served.
  const unmounted = 'path: "/v1/audio/translations", summary: "Translate an uploaded clip to English", response: "json"';
  expect(() => serverApiReference(mutate(MANIFEST, `${unmounted}, mount: "root"`, unmounted)))
    .toThrow('advertised endpoint "POST /v1/audio/translations" is not an extracted serve route');
  const status = serverApiReference(mutate(MANIFEST, '    { id: "session-delete"', '    { id: "status", method: "GET", path: "/status", summary: "State", response: "json" },\n    { id: "session-delete"'));
  expect(rows(status, "serve")).toContain("GET /api/transcription/status implemented");
});

test("a changed module manifest shape or module route group fails instead of omitting routes", () => {
  expect(() => serverApiReference(mutate(MANIFEST, "  routes: [", "  routes: buildRoutes(["))).toThrow(/^packages\/module-transcription\/src\/manifest\.ts:\d+: manifest routes must be a literal array/);
  expect(() => serverApiReference(mutate(MANIFEST, 'method: "POST", path: "/v1/audio/sessions", summary', 'method: verb, path: "/v1/audio/sessions", summary')))
    .toThrow(/^packages\/module-transcription\/src\/manifest\.ts:\d+: a route method must be a string literal/);
  expect(() => serverApiReference(mutate("cli/serve-host.ts", "createModuleRoutes(modules.routes)", "createMountedRoutes(modules.routes)")))
    .toThrow(/^cli\/serve-host\.ts:\d+: unrecognized composition shape: `createMountedRoutes\(modules\.routes\)` is not an exported route factory call/);
});

test("the model router lists its own rows first, then the current model's route chain read from its composition; a changed shape fails", () => {
  const serve = rows(baseline, "serve");
  // The router answers discovery and the wire; the unit's own groups follow at their file order.
  expect(serve.indexOf("GET /v1/models implemented")).toBeLessThan(serve.indexOf("GET /fit implemented"));
  for (const path of ["/v1/chat/completions", "/v1/completions", "/v1/messages", "/v1/responses", "/v1/embeddings"]) expect(serve).toContain(`POST ${path} routed by model id`);
  // The wire routes appear once: the router's row wins over the unit's completions group.
  expect(serve.filter(row => row.startsWith("POST /v1/chat/completions "))).toHaveLength(1);
  expect(() => serverApiReference(mutate("server/model-routes.ts", "MODEL_ROUTED.has(pathname)", "isRouted(pathname)")))
    .toThrow(/unrecognized router shape: expected MODEL_ROUTED routing in handle/);
  expect(() => serverApiReference(mutate("cli/serving-unit.ts", "const routes: RouteGroup = {", "const chain: RouteGroup = {")))
    .toThrow(/unrecognized composition shape; expected `const routes = \{ handle: … \}` in createServingUnit/);
});

test("a changed or removed allowlisted non-route site fails", () => {
  expect(() => serverApiReference(mutate("server/discovery-routes.ts", 'url.pathname.length > "/v1/models/".length - 1', 'url.pathname.length > "/v1/models/".length')))
    .toThrow("Allowlisted non-route site changed or disappeared: server/discovery-routes.ts createDiscoveryRoutes");
  expect(() => serverApiReference(mutate("server/proxy-routes.ts", '  if (pathname === "/v1/responses")\n', "  if (false)\n")))
    .toThrow("Allowlisted non-route site changed or disappeared: server/proxy-routes.ts unavailableFrame");
});

test("a path answered by the listener itself, not a route group, fails the dispatch check", () => {
  expect(() => serverApiReference(mutate("server/start.ts", '        return Response.json({ error: { message: "Not found" } }, { status: 404 });',
    '        if (new URL(request.url).pathname === "/engine") return Response.json({ error: { message: "placeholder" } }, { status: 501 });\n        return Response.json({ error: { message: "Not found" } }, { status: 404 });')))
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
