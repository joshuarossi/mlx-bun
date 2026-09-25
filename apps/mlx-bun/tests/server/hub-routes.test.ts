import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { Registry } from "@mlx-bun/hub/registry";
import { createHubRoutes } from "../../src/server/hub-routes";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
function temporary() { const root = mkdtempSync(join(tmpdir(), "mlx-web-hub-")); roots.push(root); return root; }
const request = (path: string, init?: RequestInit) => new Request(`http://localhost${path}`, init);
const fakeFetch = (fn: (url: string, init?: RequestInit) => Promise<Response>) => fn as unknown as typeof fetch;

test("hub local scans canonical snapshots, reports fit and closes its registry", async () => {
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
  const registry = new Registry(":memory:");
  let closed = 0;
  const routes = createHubRoutes({ hubDirectory: root, createRegistry: () => ({
    scan: directory => registry.scan(directory), listCanonical: () => registry.listCanonical(),
    close: () => { closed++; registry.close(); },
  }) });
  const response = (await routes.handle(request("/api/hub/local")))!;
  const body = await response.json();
  expect(response.status).toBe(200);
  expect(body.models).toHaveLength(1);
  expect(body.models[0]).toMatchObject({ repo_id: "test/tiny", size_bytes: 1024, quant_bits: 4,
    quant_group_size: 64, supported: true, vision: false });
  expect(Number.isFinite(body.models[0].assessment.predicted_decode_tps)).toBe(true);
  expect(closed).toBe(1);
});

test("hub local closes its registry after scan failure", async () => {
  let closed = 0;
  const routes = createHubRoutes({ createRegistry: () => ({ scan: async () => { throw new Error("scan failed"); },
    listCanonical: () => [], close: () => { closed++; } }) });
  expect((await routes.handle(request("/api/hub/local")))!.status).toBe(500);
  expect(closed).toBe(1);
});

test("hub search preserves query, ordering, MLX filter, explicit token and normalized rows", async () => {
  const routes = createHubRoutes({ token: () => "test-token", endpoint: "http://test.invalid", fetch: fakeFetch(async (url, init) => {
    const parsed = new URL(url);
    expect(parsed.origin).toBe("http://test.invalid");
    expect(Object.fromEntries(parsed.searchParams)).toEqual({ search: "qwen & gemma", filter: "mlx",
      sort: "downloads", direction: "-1", limit: "30" });
    expect(new Headers(init?.headers).get("authorization")).toBe("Bearer test-token");
    expect(init?.signal).toBeInstanceOf(AbortSignal);
    return Response.json([{ id: "org/mlx", downloads: 5, likes: 2, tags: ["mlx"] },
      { id: "org/other", tags: ["pytorch"] }, { modelId: "org/legacy" }, null, 7, {}, []]);
  }) });
  expect(await (await routes.handle(request("/api/hub/search?q=%20qwen%20%26%20gemma%20")))!.json()).toEqual({
    ok: true, offline: false, results: [{ id: "org/mlx", downloads: 5, likes: 2, size_estimate: null },
      { id: "org/legacy", downloads: 0, likes: 0, size_estimate: null }],
  });
});

for (const failure of ["network", "status", "json"] as const) test(`hub search reports ${failure} failure as offline`, async () => {
  const routes = createHubRoutes({ token: () => null, fetch: fakeFetch(async (_url, init) => {
    expect(new Headers(init?.headers).has("authorization")).toBe(false);
    if (failure === "network") throw new Error("offline");
    if (failure === "status") return new Response("no", { status: 503 });
    return new Response("invalid json");
  }) });
  const response = (await routes.handle(request("/api/hub/search?q=gemma")))!;
  expect(response.status).toBe(200);
  expect(await response.json()).toMatchObject({ ok: true, offline: true, results: [] });
});

test("search cancellation aborts fetch and returns 499 rather than an offline result", async () => {
  const controller = new AbortController();
  let entered!: () => void;
  const ready = new Promise<void>(resolve => { entered = resolve; });
  const routes = createHubRoutes({ token: () => null, fetch: fakeFetch(async (_url, init) => {
    entered();
    return new Promise((_resolve, reject) => init!.signal!.addEventListener("abort", () => reject(init!.signal!.reason), { once: true }));
  }) });
  const result = routes.handle(request("/api/hub/search?q=gemma", { signal: controller.signal }));
  await ready; controller.abort();
  expect((await result)!.status).toBe(499);
});

test("missing queries and malformed model requests return 400 without network work", async () => {
  const routes = createHubRoutes({ token: () => { throw new Error("must not read credentials"); } });
  expect((await routes.handle(request("/api/hub/search?q=%20")))!.status).toBe(400);
  for (const body of ["null", "[]", "{}", '{"model":12}', '{"model":" "}', "bad"]) {
    expect((await routes.handle(request("/api/hub/serve", { method: "POST", body })))!.status).toBe(400);
  }
});

test("model selection preserves main's restart answer and never claims a loaded model", async () => {
  const routes = createHubRoutes();
  expect(await (await routes.handle(request("/api/hub/serve", { method: "POST",
    body: JSON.stringify({ model: " mlx-community/tiny " }) })))!.json()).toEqual({
    ok: false, restart_required: true, command: "mlx-bun serve mlx-community/tiny",
  });
  expect(await routes.handle(request("/api/hub/download", { method: "POST" }))).toBeNull();
  expect(await routes.handle(request("/api/hub/local", { method: "POST" }))).toBeNull();
});
