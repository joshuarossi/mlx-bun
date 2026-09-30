import { afterEach, expect, spyOn, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { CatalogFailure, createRegistryCatalog } from "@mlx-bun/app-services";
import { Registry } from "@mlx-bun/hub/registry";
import { createHubHandlers, type HubOptions } from "../src";
import { fakeCatalog, fakeHost, postJson, request } from "./support";

const roots: string[] = [];
const previous = process.env.HF_HUB_CACHE;
afterEach(() => {
  for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true });
  if (previous === undefined) delete process.env.HF_HUB_CACHE; else process.env.HF_HUB_CACHE = previous;
});
function temporary() { const root = mkdtempSync(join(tmpdir(), "mlx-models-hub-")); roots.push(root); return root; }
const fakeFetch = (fn: (url: string, init?: RequestInit) => Promise<Response>) => fn as unknown as typeof fetch;
const coded = (code: string, message: string) => Object.assign(new Error(message), { code });

function handlers(services: Parameters<typeof createHubHandlers>[0] = { catalog: fakeCatalog(), modelHost: fakeHost() }, options: HubOptions = {}) {
  return createHubHandlers(services, options);
}

test("hub local re-indexes the cache, lists canonical snapshots with their fit and closes its registry", async () => {
  const root = temporary();
  const repo = join(root, "models--test--tiny");
  for (const revision of ["old", "current"]) {
    const snapshot = join(repo, "snapshots", revision);
    mkdirSync(snapshot, { recursive: true });
    writeFileSync(join(snapshot, "config.json"), JSON.stringify({ model_type: "llama",
      quantization: { bits: 4, group_size: 64, mode: "affine" }, num_hidden_layers: 4,
      hidden_size: 256, vocab_size: 1000, num_attention_heads: 8, num_key_value_heads: 8,
      head_dim: 32, max_position_embeddings: 8192 }));
    writeFileSync(join(snapshot, "model.safetensors"), new Uint8Array(revision === "old" ? 512 : 1024));
  }
  mkdirSync(join(repo, "refs")); writeFileSync(join(repo, "refs/main"), "current");
  process.env.HF_HUB_CACHE = root;
  let closed = 0;
  const catalog = createRegistryCatalog({ registry: () => { const registry = new Registry(":memory:"); const close = registry.close.bind(registry); registry.close = () => { closed++; close(); }; return registry; } });
  const response = await handlers({ catalog, modelHost: fakeHost() })["hub-local"]!(request("/api/hub/local"));
  const body = await response.json();
  expect(response.status).toBe(200);
  expect(body.models).toHaveLength(1);
  expect(body.models[0]).toMatchObject({ repo_id: "test/tiny", size_bytes: 1024, quant_bits: 4, quant_group_size: 64, supported: true, vision: false });
  expect(Number.isFinite(body.models[0].assessment.predicted_decode_tps)).toBe(true);
  expect(closed).toBe(1);
});

test("hub local closes its registry after a scan failure", async () => {
  let closed = 0;
  const catalog = createRegistryCatalog({ registry: () => ({ list: () => [], listCanonical: () => [], resolve: () => { throw new Error("unused"); },
    scan: async () => { throw new Error("scan failed"); }, close: () => { closed++; } }) });
  const log = spyOn(console, "error").mockImplementation(() => {});
  try { expect((await handlers({ catalog, modelHost: fakeHost() })["hub-local"]!(request("/api/hub/local"))).status).toBe(500); }
  finally { log.mockRestore(); }
  expect(closed).toBe(1);
});

test("cancellation during a scan returns 499 and closes the registry", async () => {
  const controller = new AbortController();
  let closed = 0;
  const catalog = createRegistryCatalog({ registry: () => ({ list: () => [], listCanonical: () => [], resolve: () => { throw new Error("unused"); },
    scan: async () => { controller.abort(); return 0; }, close: () => { closed++; } }) });
  expect((await handlers({ catalog, modelHost: fakeHost() })["hub-local"]!(request("/api/hub/local", { signal: controller.signal }))).status).toBe(499);
  expect(closed).toBe(1);
});

test("hub search preserves query, ordering, MLX filter, explicit token and normalized rows", async () => {
  const search = handlers(undefined, { token: () => "test-token", endpoint: "http://test.invalid", fetch: fakeFetch(async (url, init) => {
    const parsed = new URL(url);
    expect(parsed.origin).toBe("http://test.invalid");
    expect(Object.fromEntries(parsed.searchParams)).toEqual({ search: "qwen & gemma", filter: "mlx", sort: "downloads", direction: "-1", limit: "30" });
    expect(new Headers(init?.headers).get("authorization")).toBe("Bearer test-token");
    expect(init?.signal).toBeInstanceOf(AbortSignal);
    return Response.json([{ id: "org/mlx", downloads: 5, likes: 2, tags: ["mlx"] },
      { id: "org/other", tags: ["pytorch"] }, { modelId: "org/legacy" }, null, 7, {}, []]);
  }) })["hub-search"]!;
  expect(await (await search(request("/api/hub/search?q=%20qwen%20%26%20gemma%20"))).json()).toEqual({
    ok: true, offline: false, results: [{ id: "org/mlx", downloads: 5, likes: 2, size_estimate: null },
      { id: "org/legacy", downloads: 0, likes: 0, size_estimate: null }],
  });
});

for (const failure of ["network", "status", "json"] as const) test(`hub search reports ${failure} failure as offline`, async () => {
  const search = handlers(undefined, { token: () => null, fetch: fakeFetch(async (_url, init) => {
    expect(new Headers(init?.headers).has("authorization")).toBe(false);
    if (failure === "network") throw new Error("offline");
    if (failure === "status") return new Response("no", { status: 503 });
    return new Response("invalid json");
  }) })["hub-search"]!;
  const response = await search(request("/api/hub/search?q=gemma"));
  expect(response.status).toBe(200);
  expect(await response.json()).toMatchObject({ ok: true, offline: true, results: [] });
});

test("search cancellation aborts fetch and returns 499 rather than an offline result", async () => {
  const controller = new AbortController();
  let entered!: () => void;
  const ready = new Promise<void>(resolve => { entered = resolve; });
  const search = handlers(undefined, { token: () => null, fetch: fakeFetch(async (_url, init) => {
    entered();
    return new Promise((_resolve, reject) => init!.signal!.addEventListener("abort", () => reject(init!.signal!.reason), { once: true }));
  }) })["hub-search"]!;
  const result = search(request("/api/hub/search?q=gemma", { signal: controller.signal }));
  await ready; controller.abort();
  expect((await result).status).toBe(499);
});

test("missing queries and malformed model requests return 400 without network work or a switch", async () => {
  const routes = handlers({ catalog: fakeCatalog(), modelHost: fakeHost({ overrides: { serve: async () => { throw new Error("must not switch"); } } }) },
    { token: () => { throw new Error("must not read credentials"); } });
  expect((await routes["hub-search"]!(request("/api/hub/search?q=%20"))).status).toBe(400);
  for (const body of ["null", "[]", "{}", '{"model":12}', '{"model":" "}', "bad"])
    expect((await routes["hub-serve"]!(request("/api/hub/serve", { method: "POST", body }))).status).toBe(400);
});

test("a host that switches answers with the model it now serves; each refusal keeps its status; a host that cannot switch says restart", async () => {
  const seen: { model: string; aborted: boolean }[] = [];
  const serve = handlers({ catalog: fakeCatalog(), modelHost: fakeHost({ overrides: { async serve(model, options) {
    seen.push({ model, aborted: options?.signal?.aborted ?? false });
    if (model === "org/missing") throw coded("not-found", "org/missing is not a local model; download it first");
    if (model === "org/one-model-host") throw coded("not-switchable", "this host serves one model");
    if (model === "org/too-big") throw coded("does-not-fit", "org/too-big does not fit");
    if (model === "org/unloadable") throw coded("load-failed", "weights are corrupt");
    if (model === "org/broken") throw new Error("boom");
  } } }) })["hub-serve"]!;
  const post = (model: string) => serve(postJson("/api/hub/serve", { model }));
  const served = await post(" org/model ");
  expect(served.status).toBe(200);
  expect(await served.json()).toEqual({ ok: true, model: "org/model" });
  expect(seen).toEqual([{ model: "org/model", aborted: false }]);
  const refused = await post("org/missing");
  expect(refused.status).toBe(404);
  expect(await refused.json()).toEqual({ ok: false, error: "org/missing is not a local model; download it first" });
  expect(await (await post("org/one-model-host")).json()).toEqual({ ok: false, restart_required: true, command: "mlx-bun serve org/one-model-host" });
  const tooBig = await post("org/too-big");
  expect([tooBig.status, await tooBig.json()]).toEqual([400, { ok: false, error: "org/too-big does not fit" }]);
  const unloadable = await post("org/unloadable");
  expect([unloadable.status, await unloadable.json()]).toEqual([502, { ok: false, error: "weights are corrupt" }]);
  const log = spyOn(console, "error").mockImplementation(() => {});
  try { expect((await post("org/broken")).status).toBe(500); } finally { log.mockRestore(); }
});

test("a request that went away while the model loaded is a 499, not a refusal", async () => {
  const controller = new AbortController();
  const serve = handlers({ catalog: fakeCatalog(), modelHost: fakeHost({ overrides: { async serve() { controller.abort(); throw coded("aborted", "aborted"); } } }) })["hub-serve"]!;
  expect((await serve(postJson("/api/hub/serve", { model: "org/model" }, controller.signal))).status).toBe(499);
});

test("hub download validates the repo, admits it once, and reports a duplicate as 409 and a host without downloads as 404", async () => {
  const started: string[] = [];
  const download = handlers({ catalog: fakeCatalog([], { startDownload(repo) {
    if (started.includes(repo)) throw new CatalogFailure("duplicate-download", `a download for ${repo} is already in progress`);
    started.push(repo);
  } }), modelHost: fakeHost() })["hub-download"]!;
  const post = (body: unknown) => download(postJson("/api/hub/download", body));
  const missing = await post({});
  expect(missing.status).toBe(400); expect(await missing.json()).toEqual({ ok: false, error: 'missing "repo"' });
  expect((await post("not json")).status).toBe(400);
  for (const repo of ["../x", "org/..", "org", "org/name/extra", "org/na me", "/org/name"]) {
    const invalid = await post({ repo });
    expect(invalid.status).toBe(400); expect(await invalid.json()).toEqual({ ok: false, error: 'invalid "repo": expected org/name' });
  }
  const ok = await post({ repo: " mlx-community/tiny " });
  expect(ok.status).toBe(200); expect(await ok.json()).toEqual({ ok: true, repo: "mlx-community/tiny", started: true });
  const duplicate = await post({ repo: "mlx-community/tiny" });
  expect(duplicate.status).toBe(409);
  expect(await duplicate.json()).toEqual({ ok: false, error: "a download for mlx-community/tiny is already in progress" });
  expect(started).toEqual(["mlx-community/tiny"]);
  const none = await handlers({ catalog: fakeCatalog([], { startDownload() { throw new CatalogFailure("not-supported", "this host does not download models"); } }), modelHost: fakeHost() })["hub-download"]!(postJson("/api/hub/download", { repo: "org/x" }));
  expect([none.status, await none.json()]).toEqual([404, { ok: false, error: "this host does not download models" }]);
});
