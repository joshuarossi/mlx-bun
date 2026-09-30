import { afterEach, expect, spyOn, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { AdapterOperation, CatalogEntry } from "@mlx-bun/app-core";
import { createAdapterHandlers, type AdapterOptions } from "../src";
import { fakeCatalog, fakeHost, fakeStorage, mounted, postJson, request } from "./support";

const roots: string[] = [];
function temporary() { const root = mkdtempSync(join(tmpdir(), "mlx-models-adapters-")); roots.push(root); return root; }
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });

const onDisk = (id: string, base: string | null): CatalogEntry => ({ id, kind: "adapter", directory: "/adapter", bytes: 0, operations: [], ...(base ? { base } : {}), adapter: { rank: 2, scale: 1 } });

function setup(seams: { served?: string | undefined; options?: AdapterOptions; root?: string; operation?: Partial<AdapterOperation> } = {}) {
  const calls: string[] = [], signals: (AbortSignal | undefined)[] = [], events: string[] = [];
  let mountedNow = true;
  const operation: AdapterOperation = {
    async list(signal) { signals.push(signal); return mountedNow ? [mounted("tuned", { path: "/adapter" })] : []; },
    async mount(id, path, signal) { calls.push(`mount:${id}:${path}`); signals.push(signal); signal?.throwIfAborted(); mountedNow = true; return mounted(id, { path }); },
    async unmount(id, signal) { calls.push(`unmount:${id}`); signals.push(signal); const count = mountedNow ? 2 : 0; mountedNow = false; return count; },
    async merge() { throw new Error("unused"); },
    ...seams.operation,
  };
  const catalog = fakeCatalog([onDisk("tuned", "different/MODEL"), onDisk("other", "org/Other"), onDisk("unknown", null)]);
  const handlers = createAdapterHandlers({ catalog, modelHost: fakeHost({ served: "served" in seams ? seams.served : "org/Model", adapters: operation, events }),
    storage: fakeStorage(seams.root ?? temporary()) }, seams.options);
  return { handlers, calls, signals, events };
}

test("adapter inventory preserves wire metadata and model compatibility, holding the model resident only while it reads", async () => {
  const run = setup();
  expect(await (await run.handlers.adapters!(request("/v1/adapters"))).json()).toEqual({ adapters: [{ id: "tuned", path: "/adapter", rank: 2, scale: 1, size_bytes: 100, mounted_layers: 2, ram_bytes: 80 }] });
  const available = await (await run.handlers["adapters-available"]!(request("/v1/adapters/available"))).json();
  expect(available.adapters.map((a: { mounted: boolean; compatible: boolean }) => [a.mounted, a.compatible])).toEqual([[true, true], [false, false], [false, true]]);
  expect(available.adapters[0]).toEqual({ id: "tuned", path: "/adapter", rank: 2, scale: 1, base_model: "different/MODEL", mounted: true, compatible: true });
  expect(run.calls).toEqual([]);
  expect(run.events).toEqual(["acquire org/Model", "release org/Model", "acquire org/Model", "release org/Model"]);
});

test("mounting and unmounting run on the served model's operation and forward request cancellation", async () => {
  const run = setup(), controller = new AbortController();
  const mountedResponse = await run.handlers["adapter-mount"]!(postJson("/v1/adapters", { id: "new", path: "/new" }, controller.signal));
  expect(await mountedResponse.json()).toEqual({ id: "new", mounted_layers: 2, rank: 2, scale: 1, ram_bytes: 80 });
  expect(run.calls).toEqual(["mount:new:/new"]);
  expect(run.signals[0]?.aborted).toBe(false);
  const unmount = (id: string) => run.handlers["adapter-unmount"]!(request(`/v1/adapters/${id}`, { method: "DELETE" }));
  expect(await (await unmount("a%20b")).json()).toEqual({ id: "a b", removed_layers: 2 });
  const gone = await unmount("a%20b");
  expect([gone.status, await gone.json()]).toEqual([404, { error: { message: "adapter a b not mounted" } }]);
  const calls = run.calls.length;
  controller.abort();
  const cancelled = await run.handlers["adapter-mount"]!(postJson("/v1/adapters", { id: "new", path: "/new" }, controller.signal));
  expect([cancelled.status, await cancelled.json()]).toEqual([499, { error: { message: "Request cancelled" } }]);
  expect(run.calls).toHaveLength(calls);
});

test("a model that cannot take the adapter answers with its reason; no served model is a 503", async () => {
  const refusing = setup({ operation: { async mount() { throw new Error("adapter layers do not match this model"); } } });
  const refused = await refusing.handlers["adapter-mount"]!(postJson("/v1/adapters", { id: "x", path: "/x" }));
  expect([refused.status, await refused.json()]).toEqual([400, { error: { message: "adapter layers do not match this model" } }]);
  const down = setup({ operation: { async list() { throw Object.assign(new Error("inference engine unavailable: the worker was killed by SIGKILL"), { code: "closed" }); } } });
  const unavailable = await down.handlers.adapters!(request("/v1/adapters"));
  expect([unavailable.status, await unavailable.json()]).toEqual([503, { error: { message: "inference engine unavailable: the worker was killed by SIGKILL" } }]);
  const idle = setup({ served: undefined });
  for (const response of [await idle.handlers.adapters!(request("/v1/adapters")), await idle.handlers["adapters-available"]!(request("/v1/adapters/available")),
    await idle.handlers["adapter-unmount"]!(request("/v1/adapters/x", { method: "DELETE" }))]) expect(response.status).toBe(503);
  const merging = await idle.handlers["adapter-merge"]!(postJson("/api/finetune/merge", { adapter_a: "/a", adapter_b: "/b" }));
  expect([merging.status, (await merging.json()).ok]).toEqual([503, false]);
});

test("a model that declares no adapter operation answers that it cannot mount adapters", async () => {
  const handlers = createAdapterHandlers({ catalog: fakeCatalog(), modelHost: fakeHost(), storage: fakeStorage(temporary()) });
  const response = await handlers.adapters!(request("/v1/adapters"));
  expect([response.status, await response.json()]).toEqual([400, { error: { message: "org/served does not mount adapters" } }]);
});

test("malformed adapter requests fail before the model is leased", async () => {
  const run = setup();
  for (const body of [null, [], {}, { id: 2, path: "/a" }, { id: "a", path: false }, { id: " ", path: "/a" }, "not json"])
    expect((await run.handlers["adapter-mount"]!(postJson("/v1/adapters", body))).status).toBe(400);
  expect((await run.handlers["adapter-unmount"]!(request("/v1/adapters/%GG", { method: "DELETE" }))).status).toBe(400);
  expect((await run.handlers["adapter-unmount"]!(request("/v1/adapters/", { method: "DELETE" }))).status).toBe(400);
  expect(run.calls).toEqual([]); expect(run.events).toEqual([]);
});

// ---------------------------------------------------------------- merge and export

const stats = { layersMerged: 2, layersOnlyInOne: 1, totalKeysOut: 6, sources: ["/a", "/b"], scales: [1, -0.5] };

test("merge preserves source order, scales, the generated path under the adapters entry, and the wire response", async () => {
  const root = temporary(), args: unknown[] = [];
  const run = setup({ root, operation: { async merge(request, signal) { args.push(request, signal); return stats; } } });
  const body = await (await run.handlers["adapter-merge"]!(postJson("/api/finetune/merge", { adapter_a: "/a", adapter_b: "/b", scales: [1, -0.5] }))).json();
  const merge = args[0] as { adapters: string[]; output: string; scales?: number[] };
  expect(body).toEqual({ ok: true, merged_path: merge.output, stats });
  expect(merge.adapters).toEqual(["/a", "/b"]); expect(merge.scales).toEqual([1, -0.5]);
  expect(merge.output).toStartWith(join(root, "adapters", "merged-"));
  expect(args[1]).toBeInstanceOf(AbortSignal);
  await run.handlers["adapter-merge"]!(postJson("/api/finetune/merge", { adapter_a: "/a", adapter_b: "/b" }));
  expect((args[2] as { scales?: number[] }).scales).toBeUndefined();
  expect(run.events).toEqual(["acquire org/Model", "release org/Model", "acquire org/Model", "release org/Model"]);
});

test("a merge failure releases the model and returns the error envelope", async () => {
  const run = setup({ operation: { async merge() { throw new Error("incompatible adapters"); } } });
  const response = await run.handlers["adapter-merge"]!(postJson("/api/finetune/merge", { adapter_a: "/a", adapter_b: "/b" }));
  expect([response.status, await response.json()]).toEqual([400, { ok: false, error: "incompatible adapters" }]);
  expect(run.events).toEqual(["acquire org/Model", "release org/Model"]);
});

test("a merge whose request went away is a 499, and the model is released", async () => {
  const controller = new AbortController();
  let entered!: () => void;
  const ready = new Promise<void>(resolve => { entered = resolve; });
  const run = setup({ operation: { merge: (_request, signal) => new Promise((_resolve, reject) => { entered(); signal!.addEventListener("abort", () => reject(signal!.reason), { once: true }); }) } });
  const pending = run.handlers["adapter-merge"]!(postJson("/api/finetune/merge", { adapter_a: "/a", adapter_b: "/b" }, controller.signal));
  await ready; controller.abort();
  const response = await pending;
  expect([response.status, await response.json()]).toEqual([499, { ok: false, error: "Request cancelled" }]);
  expect(run.events).toEqual(["acquire org/Model", "release org/Model"]);
});

test("merges started in the same millisecond keep separate artifacts", async () => {
  const outputs: string[] = [];
  const clock = spyOn(Date, "now").mockReturnValue(123456789);
  try {
    const run = setup({ root: temporary(), operation: { async merge(request) { outputs.push(request.output); mkdirSync(request.output, { recursive: true }); return stats; } } });
    const bodies = await Promise.all(["first", "second"].map(async name => (await run.handlers["adapter-merge"]!(postJson("/api/finetune/merge", { adapter_a: `/${name}/a`, adapter_b: `/${name}/b` }))).json()));
    expect(bodies[0].merged_path).not.toBe(bodies[1].merged_path);
    for (const body of bodies) expect(body.merged_path).toContain("/adapters/merged-123456789-");
    expect(new Set(outputs).size).toBe(2);
  } finally { clock.mockRestore(); }
});

test("export writes the CPU-only manifest under the exports entry without leasing the model", async () => {
  const root = temporary();
  const run = setup({ root });
  const response = await run.handlers["adapter-export"]!(postJson("/api/finetune/export", { base_model: "org/base", adapter_path: "/trained", method: "orpo" }));
  expect(response.status).toBe(200);
  const body = await response.json();
  expect(body.ok).toBe(true);
  expect(body.export_path).toStartWith(join(root, "exports/export-"));
  expect(body.manifest).toMatchObject({ version: 1, base_model: "org/base", adapter_path: "/trained", method: "orpo" });
  expect(await Bun.file(join(body.export_path, "manifest.json")).json()).toEqual(body.manifest);
  expect(run.events).toEqual([]);
});

test("export preserves the omitted method and the generated path, and reports write failures", async () => {
  const root = temporary(), args: unknown[][] = [];
  const run = setup({ root, options: { export: async (...input) => { args.push(input); throw new Error("output is read-only"); } } });
  const response = await run.handlers["adapter-export"]!(postJson("/api/finetune/export", { base_model: "org/base", adapter_path: "/trained" }));
  expect(await response.json()).toEqual({ ok: false, error: "output is read-only" });
  expect(args[0]![0]).toStartWith(join(root, "exports", "export-"));
  expect(args[0]!.slice(1)).toEqual(["org/base", "/trained", undefined]);
});

test("exports started in the same millisecond keep separate manifests", async () => {
  const clock = spyOn(Date, "now").mockReturnValue(123456789);
  try {
    const run = setup({ root: temporary() });
    const bodies = await Promise.all(["first", "second"].map(async name => (await run.handlers["adapter-export"]!(postJson("/api/finetune/export", { base_model: `org/${name}`, adapter_path: `/trained/${name}` }))).json()));
    expect(bodies[0].export_path).not.toBe(bodies[1].export_path);
    for (const [index, body] of bodies.entries()) {
      expect(body.export_path).toContain("/exports/export-123456789-");
      expect(body.manifest.base_model).toBe(`org/${index === 0 ? "first" : "second"}`);
      expect(await Bun.file(join(body.export_path, "manifest.json")).json()).toEqual(body.manifest);
    }
  } finally { clock.mockRestore(); }
});

test("invalid and pre-cancelled artifact requests fail before the model is leased or anything is written", async () => {
  const unexpected = async (): Promise<never> => { throw new Error("unexpected call"); };
  const run = setup({ operation: { merge: unexpected }, options: { export: unexpected } });
  for (const body of [null, [], {}, { adapter_a: "/a", adapter_b: 7 }, { adapter_a: "/a", adapter_b: "/b", scales: [] }, { adapter_a: "/a", adapter_b: "/b", scales: [1, "2"] }])
    expect((await run.handlers["adapter-merge"]!(postJson("/api/finetune/merge", body))).status).toBe(400);
  for (const body of [{}, { base_model: "org/base", adapter_path: 4 }, { base_model: "org/base", adapter_path: "/a", method: [] }])
    expect((await run.handlers["adapter-export"]!(postJson("/api/finetune/export", body))).status).toBe(400);
  const abort = new AbortController(); abort.abort();
  expect((await run.handlers["adapter-merge"]!(postJson("/api/finetune/merge", { adapter_a: "/a", adapter_b: "/b" }, abort.signal))).status).toBe(499);
  expect((await run.handlers["adapter-export"]!(postJson("/api/finetune/export", { base_model: "org/base", adapter_path: "/a" }, abort.signal))).status).toBe(499);
  expect(run.events).toEqual([]);
});
