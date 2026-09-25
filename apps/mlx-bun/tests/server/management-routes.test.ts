import { afterEach, expect, spyOn, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Registry } from "@mlx-bun/hub/registry";
import { isToolAlwaysAllowed, setToolAlwaysAllowed } from "../../src/chat/tool-approvals";
import { createManagementRoutes } from "../../src/server/management-routes";
import { pendingRoute } from "../../src/server/start";

const roots: string[] = [];
function temporary() {
  const root = mkdtempSync(join(tmpdir(), "mlx-management-")); roots.push(root); return root;
}
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
const request = (path: string, method = "GET", body?: unknown) => new Request(`http://local${path}`, {
  method, ...(body === undefined ? {} : { headers: { "content-type": "application/json" }, body: JSON.stringify(body) }),
});

function syntheticCache() {
  const root = temporary(), hub = join(root, "hub"), repo = join(hub, "models--example--tiny");
  mkdirSync(join(repo, "blobs"), { recursive: true });
  for (const [revision, bytes] of [["old", 3], ["current", 5], ["skipped", 7]] as const) {
    const snapshot = join(repo, "snapshots", revision);
    mkdirSync(snapshot, { recursive: true });
    writeFileSync(join(snapshot, "config.json"), JSON.stringify({ model_type: "qwen3", num_hidden_layers: 1 }));
    writeFileSync(join(repo, "blobs", revision), new Uint8Array(bytes));
    symlinkSync(`../../blobs/${revision}`, join(snapshot, "model.safetensors"));
  }
  writeFileSync(join(repo, "snapshots/skipped/extra.txt"), "keep this unique file");
  writeFileSync(join(repo, "blobs/dead"), new Uint8Array(11));
  writeFileSync(join(repo, "blobs/resume.incomplete"), new Uint8Array(13));
  writeFileSync(join(repo, "blobs/resume.lock"), new Uint8Array(17));
  mkdirSync(join(repo, "refs")); writeFileSync(join(repo, "refs/main"), "current");
  return { root, hub, repo };
}

test("tool settings list and revoke the same approval store consumed by chat", async () => {
  const root = temporary(), approvals = join(root, "settings/approvals.json"), other = join(root, "other.json");
  setToolAlwaysAllowed("write", approvals); setToolAlwaysAllowed("bash", approvals); setToolAlwaysAllowed("edit", other);
  const routes = createManagementRoutes({ toolApprovalsFile: approvals, invalidateLibrary() { throw new Error("unexpected GC"); } });
  expect(await (await routes.handle(request("/api/settings/tool-approvals")))!.json()).toEqual({ ok: true, alwaysAllow: ["bash", "write"] });
  expect(await (await routes.handle(request("/api/settings/tool-approvals", "DELETE", { tool: "bash" })))!.json())
    .toEqual({ ok: true, alwaysAllow: ["write"] });
  expect(isToolAlwaysAllowed("bash", approvals)).toBe(false);
  expect(isToolAlwaysAllowed("write", approvals)).toBe(true);
  expect(isToolAlwaysAllowed("edit", other)).toBe(true);
});

test("malformed settings and unconfirmed GC requests reject without opening storage", async () => {
  const root = temporary(), approvals = join(root, "absent/approvals.json");
  const routes = createManagementRoutes({ toolApprovalsFile: approvals, hubDirectory: join(root, "absent-hub"),
    createRegistry() { throw new Error("must not open registry"); }, invalidateLibrary() { throw new Error("must not invalidate"); } });
  for (const [path, method, bodies] of [
    ["/api/settings/tool-approvals", "DELETE", [null, [], {}, { tool: 1 }, { tool: "" }]],
    ["/api/gc/execute", "POST", [null, [], {}, { yes: false }, { yes: "true" }, { yes: 1 }]],
  ] as const) {
    for (const body of bodies) expect((await routes.handle(request(path, method, body)))!.status).toBe(400);
    expect((await routes.handle(new Request(`http://local${path}`, { method, body: "{" })))!.status).toBe(400);
  }
  expect(existsSync(approvals)).toBe(false);
});

test("GC preview is read-only and confirmed execution rescans, closes, and invalidates discovery", async () => {
  const { root, hub, repo } = syntheticCache(), events: string[] = [];
  const db = join(root, "registry.sqlite");
  const before = new Registry(db); await before.scan(hub); expect(before.list()).toHaveLength(3); before.close();
  const routes = createManagementRoutes({ hubDirectory: hub, servedModelPath: join(repo, "snapshots/current"),
    createRegistry() {
      events.push("open"); const registry = new Registry(db);
      return { async scan(directory) { events.push("scan"); expect(directory).toBe(hub); return registry.scan(directory); },
        close() { events.push("close"); registry.close(); } };
    }, invalidateLibrary() { events.push("invalidate"); } });
  expect(await (await routes.handle(request("/api/gc/plan")))!.json()).toEqual({ ok: true, reclaim_bytes: 14,
    superseded: [{ repo_id: "example/tiny", prune_snapshots: 1, skipped_snapshots: 1, dead_blobs: 2, reclaim_bytes: 14 }] });
  expect(events).toEqual([]); expect(existsSync(join(repo, "snapshots/old"))).toBe(true);
  expect(await (await routes.handle(request("/api/gc/execute", "POST", { yes: true })))!.json())
    .toEqual({ ok: true, snapshots: 1, blobs: 2, reclaimed_bytes: 14 });
  expect(events).toEqual(["open", "scan", "close", "invalidate"]);
  expect(existsSync(join(repo, "snapshots/old"))).toBe(false);
  for (const retained of ["snapshots/current", "snapshots/skipped", "blobs/current", "blobs/skipped", "blobs/resume.incomplete", "blobs/resume.lock"])
    expect(existsSync(join(repo, retained))).toBe(true);
  const after = new Registry(db); try { expect(after.list()).toHaveLength(2); } finally { after.close(); }
});

test("a failed post-deletion registry scan still closes and invalidates discovery", async () => {
  const { hub, repo } = syntheticCache(), events: string[] = [];
  const routes = createManagementRoutes({ hubDirectory: hub,
    createRegistry: () => ({ async scan() { events.push("scan"); throw new Error("rescan failed"); }, close() { events.push("close"); } }),
    invalidateLibrary() { events.push("invalidate"); } });
  const log = spyOn(console, "error").mockImplementation(() => {});
  try {
    const response = (await routes.handle(request("/api/gc/execute", "POST", { yes: true })))!;
    expect(response.status).toBe(500);
    expect(response.headers.get("content-type")).toContain("application/json");
    expect(await response.json()).toEqual({ ok: false, error: "rescan failed" });
  } finally { log.mockRestore(); }
  expect(events).toEqual(["scan", "close", "invalidate"]);
  expect(existsSync(join(repo, "snapshots/old"))).toBe(false);
});

test("GC refuses to prune an active superseded model, including a symlinked model path", async () => {
  const { root, hub, repo } = syntheticCache();
  const snapshot = join(repo, "snapshots/old"), alias = join(root, "active-model");
  symlinkSync(snapshot, alias);
  for (const servedModelPath of [snapshot, alias]) {
    const routes = createManagementRoutes({ hubDirectory: hub, servedModelPath,
      createRegistry() { throw new Error("must not rescan a rejected deletion"); },
      invalidateLibrary() { throw new Error("must not invalidate without deletion"); } });
    const response = (await routes.handle(request("/api/gc/execute", "POST", { yes: true })))!;
    expect(response.status).toBe(409);
    expect(await response.json()).toMatchObject({ ok: false, error: expect.stringContaining("active model snapshot") });
    for (const retained of ["snapshots/old", "blobs/old", "blobs/dead"])
      expect(existsSync(join(repo, retained))).toBe(true);
  }
});

test("GC planning failures use the management JSON error shape", async () => {
  const hub = join(temporary(), "not-a-directory"); writeFileSync(hub, "invalid cache root");
  const routes = createManagementRoutes({ hubDirectory: hub, invalidateLibrary() {} });
  const log = spyOn(console, "error").mockImplementation(() => {});
  try {
    for (const req of [request("/api/gc/plan"), request("/api/gc/execute", "POST", { yes: true })]) {
      const response = (await routes.handle(req))!;
      expect(response.status).toBe(500);
      expect(response.headers.get("content-type")).toContain("application/json");
      expect(await response.json()).toMatchObject({ ok: false, error: expect.stringContaining("ENOTDIR") });
    }
  } finally { log.mockRestore(); }
});

test("management matches only its owned methods and leaves HF credentials and uploads deferred", async () => {
  const routes = createManagementRoutes({ toolApprovalsFile: join(temporary(), "approvals.json"), invalidateLibrary() {} });
  for (const [path, method] of [["/api/settings/tool-approvals", "POST"], ["/api/gc/plan", "POST"],
    ["/api/gc/execute", "GET"], ["/api/settings/hf-token", "GET"], ["/api/quantize/push", "POST"]])
    expect(await routes.handle(request(path!, method))).toBeNull();
  expect(pendingRoute("/api/settings/hf-token")).toBe(true);
  expect(pendingRoute("/api/quantize/push")).toBe(true);
  expect(pendingRoute("/api/settings/tool-approvals")).toBe(false);
  expect(pendingRoute("/api/gc/execute")).toBe(false);
});
