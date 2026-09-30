import { afterEach, expect, spyOn, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createGcHandlers, type GcOptions } from "../src";
import { entry, fakeCatalog, fakeHost, postJson, request, resident } from "./support";

const roots: string[] = [];
function temporary() { const root = mkdtempSync(join(tmpdir(), "mlx-models-gc-")); roots.push(root); return root; }
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });

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

function routes(hub: string, seams: { events?: string[]; residents?: ReturnType<typeof resident>[]; rescan?: () => Promise<number>; entries?: ReturnType<typeof entry>[] } = {}, options: GcOptions = {}) {
  const events = seams.events ?? [];
  const catalog = fakeCatalog(seams.entries ?? [], { rescan: seams.rescan ?? (async () => { events.push("rescan"); return 0; }) });
  return createGcHandlers({ catalog, modelHost: fakeHost({ residents: seams.residents ?? [] }) }, { hubDirectory: hub, ...options });
}

test("malformed and unconfirmed cleanup requests reject without touching the cache or the index", async () => {
  const handlers = createGcHandlers({ catalog: fakeCatalog([], { rescan: async () => { throw new Error("must not rescan"); } }), modelHost: fakeHost() }, { hubDirectory: join(temporary(), "absent-hub") });
  for (const body of [null, [], {}, { yes: false }, { yes: "true" }, { yes: 1 }])
    expect((await handlers["gc-execute"]!(postJson("/api/gc/execute", body))).status).toBe(400);
  expect((await handlers["gc-execute"]!(new Request("http://local/api/gc/execute", { method: "POST", body: "{" }))).status).toBe(400);
});

test("the preview is read-only and a confirmed cleanup deletes what the plan lists, re-indexes, and keeps everything else", async () => {
  const { hub, repo } = syntheticCache(), events: string[] = [];
  const handlers = routes(hub, { events });
  expect(await (await handlers["gc-plan"]!(request("/api/gc/plan"))).json()).toEqual({ ok: true, reclaim_bytes: 14,
    superseded: [{ repo_id: "example/tiny", prune_snapshots: 1, skipped_snapshots: 1, dead_blobs: 2, reclaim_bytes: 14 }] });
  expect(events).toEqual([]); expect(existsSync(join(repo, "snapshots/old"))).toBe(true);
  expect(await (await handlers["gc-execute"]!(postJson("/api/gc/execute", { yes: true }))).json()).toEqual({ ok: true, snapshots: 1, blobs: 2, reclaimed_bytes: 14 });
  expect(events).toEqual(["rescan"]);
  expect(existsSync(join(repo, "snapshots/old"))).toBe(false);
  for (const retained of ["snapshots/current", "snapshots/skipped", "blobs/current", "blobs/skipped", "blobs/resume.incomplete", "blobs/resume.lock"])
    expect(existsSync(join(repo, retained))).toBe(true);
});

test("a failed re-index after the deletion is the request's error, and the deletion stands", async () => {
  const { hub, repo } = syntheticCache();
  const handlers = routes(hub, { rescan: async () => { throw new Error("rescan failed"); } });
  const log = spyOn(console, "error").mockImplementation(() => {});
  try {
    const response = await handlers["gc-execute"]!(postJson("/api/gc/execute", { yes: true }));
    expect(response.status).toBe(500);
    expect(response.headers.get("content-type")).toContain("application/json");
    expect(await response.json()).toEqual({ ok: false, error: "rescan failed" });
  } finally { log.mockRestore(); }
  expect(existsSync(join(repo, "snapshots/old"))).toBe(false);
});

test("cleanup refuses to prune a snapshot a resident model reads, including through a symlink or an extra directory the host reports", async () => {
  const { root, hub, repo } = syntheticCache();
  const snapshot = join(repo, "snapshots/old"), alias = join(root, "active-model");
  symlinkSync(snapshot, alias);
  const cases: ReturnType<typeof resident>[][] = [
    [resident("a", { uses: [snapshot] })], [resident("a", { uses: [alias] })],
    // Several models; one of them reading the snapshot is enough, and so is a directory it holds besides its own.
    [resident("a", { uses: [join(repo, "snapshots/current")] }), resident("b", { uses: [alias] })],
    [resident("a", { uses: [join(repo, "snapshots/current"), snapshot] })],
  ];
  for (const residents of cases) {
    const handlers = routes(hub, { residents, rescan: async () => { throw new Error("must not rescan a rejected deletion"); } });
    const response = await handlers["gc-execute"]!(postJson("/api/gc/execute", { yes: true }));
    expect(response.status).toBe(409);
    expect(await response.json()).toMatchObject({ ok: false, error: expect.stringContaining("active model snapshot") });
    for (const retained of ["snapshots/old", "blobs/old", "blobs/dead"]) expect(existsSync(join(repo, retained))).toBe(true);
  }
});

test("a resident model that reports no directories is protected through the snapshot its id resolves to", async () => {
  const { hub, repo } = syntheticCache();
  const handlers = routes(hub, { residents: [resident("example/tiny")], entries: [entry("example/tiny", { directory: join(repo, "snapshots/old") })], rescan: async () => 0 });
  expect((await handlers["gc-execute"]!(postJson("/api/gc/execute", { yes: true }))).status).toBe(409);
  expect(existsSync(join(repo, "snapshots/old"))).toBe(true);
});

test("planning failures use the JSON error shape", async () => {
  const hub = join(temporary(), "not-a-directory"); writeFileSync(hub, "invalid cache root");
  const handlers = routes(hub);
  const log = spyOn(console, "error").mockImplementation(() => {});
  try {
    for (const [handler, req] of [[handlers["gc-plan"]!, request("/api/gc/plan")], [handlers["gc-execute"]!, postJson("/api/gc/execute", { yes: true })]] as const) {
      const response = await handler(req);
      expect(response.status).toBe(500);
      expect(response.headers.get("content-type")).toContain("application/json");
      expect(await response.json()).toMatchObject({ ok: false, error: expect.stringContaining("ENOTDIR") });
    }
  } finally { log.mockRestore(); }
});
