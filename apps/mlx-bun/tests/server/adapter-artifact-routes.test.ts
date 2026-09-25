import { afterEach, expect, spyOn, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir, homedir } from "node:os";
import { join } from "node:path";
import type { GenerationGateway } from "../../src/engine/generation-gateway";
import { createAdapterArtifactRoutes } from "../../src/server/adapter-artifact-routes";
import { pendingRoute } from "../../src/server/start";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
const post = (verb: string, body: unknown, signal?: AbortSignal) => new Request(`http://local/api/finetune/${verb}`,
  { method: "POST", body: JSON.stringify(body), signal });
const stats = { layersMerged: 2, layersOnlyInOne: 1, totalKeysOut: 6, sources: ["/a", "/b"], scales: [1, -0.5] };
function lock(events: string[]): Pick<GenerationGateway, "runExclusive"> {
  return { async runExclusive(work, _trace, signal) {
    signal?.throwIfAborted(); events.push("lock");
    try { return await work(); } finally { events.push("unlock"); }
  } };
}

test("merge preserves source order, scales, generated path, and wire response under the engine lock", async () => {
  const events: string[] = [];
  let args: unknown[] = [];
  const routes = createAdapterArtifactRoutes(lock(events), { merge: async (...input) => {
    args = input; events.push("merge"); return stats;
  } });
  const response = await routes.handle(post("merge", { adapter_a: "/a", adapter_b: "/b", scales: [1, -0.5] }));
  const body = await response!.json();
  expect(body).toEqual({ ok: true, merged_path: args[1], stats });
  expect(args[0]).toEqual(["/a", "/b"]); expect(args[2]).toEqual([1, -0.5]);
  expect(String(args[1])).toStartWith(join(homedir(), ".cache/mlx-bun/adapters/merged-"));
  expect(events).toEqual(["lock", "merge", "unlock"]);
  await routes.handle(post("merge", { adapter_a: "/a", adapter_b: "/b" }));
  expect(args[2]).toBeUndefined();
  expect(pendingRoute("/api/finetune/merge")).toBe(false);
});

test("merge failure releases the lock after library cleanup and returns main's error envelope", async () => {
  const events: string[] = [];
  const routes = createAdapterArtifactRoutes(lock(events), { merge: async () => {
    try { events.push("merge"); throw new Error("incompatible adapters"); }
    finally { events.push("library cleanup"); }
  } });
  const response = await routes.handle(post("merge", { adapter_a: "/a", adapter_b: "/b" }));
  expect(response!.status).toBe(400);
  expect(await response!.json()).toEqual({ ok: false, error: "incompatible adapters" });
  expect(events).toEqual(["lock", "merge", "library cleanup", "unlock"]);
});

test("cancelled admission never imports or calls merge", async () => {
  const controller = new AbortController();
  let entered = false, called = false;
  const gateway: Pick<GenerationGateway, "runExclusive"> = { async runExclusive(_work, _trace, signal) {
    entered = true;
    await new Promise<void>((_, reject) => signal!.addEventListener("abort", () => reject(signal!.reason), { once: true }));
    throw new Error("unreachable");
  } };
  const routes = createAdapterArtifactRoutes(gateway, { merge: async () => { called = true; return stats; } });
  const pending = routes.handle(post("merge", { adapter_a: "/a", adapter_b: "/b" }, controller.signal));
  while (!entered) await Bun.sleep(1);
  controller.abort();
  expect((await pending)!.status).toBe(499); expect(called).toBe(false);
});

test("already-entered merge keeps its lock until cleanup settles even after disconnect", async () => {
  const events: string[] = [], controller = new AbortController();
  let finish!: () => void;
  const done = new Promise<void>(resolve => { finish = resolve; });
  const routes = createAdapterArtifactRoutes(lock(events), { merge: async () => {
    events.push("merge"); await done; events.push("library cleanup"); return stats;
  } });
  const pending = routes.handle(post("merge", { adapter_a: "/a", adapter_b: "/b" }, controller.signal));
  while (!events.includes("merge")) await Bun.sleep(1);
  controller.abort(); expect(events).toEqual(["lock", "merge"]);
  finish(); await pending;
  expect(events).toEqual(["lock", "merge", "library cleanup", "unlock"]);
});

test("export writes the public CPU-only manifest into an injected temporary output root without a lock", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-adapter-export-")); roots.push(root);
  const events: string[] = [];
  const routes = createAdapterArtifactRoutes(lock(events), { outputRoot: root });
  const response = await routes.handle(post("export", { base_model: "org/base", adapter_path: "/trained", method: "orpo" }));
  expect(response!.status).toBe(200);
  const body = await response!.json();
  expect(body.ok).toBe(true);
  expect(body.export_path).toStartWith(join(root, "exports/export-"));
  expect(body.manifest).toMatchObject({ version: 1, base_model: "org/base", adapter_path: "/trained", method: "orpo" });
  expect(await Bun.file(join(body.export_path, "manifest.json")).json()).toEqual(body.manifest);
  expect(events).toEqual([]);
  expect(pendingRoute("/api/finetune/export")).toBe(false);
  expect(pendingRoute("/api/finetune/push")).toBe(true);
});

test("export preserves omitted method and generated default path, and reports write failures", async () => {
  const events: string[] = [], args: unknown[][] = [];
  const routes = createAdapterArtifactRoutes(lock(events), { export: async (...input) => {
    args.push(input); throw new Error("output is read-only");
  } });
  const response = await routes.handle(post("export", { base_model: "org/base", adapter_path: "/trained" }));
  expect(await response!.json()).toEqual({ ok: false, error: "output is read-only" });
  expect(args[0]![0]).toStartWith(join(homedir(), ".cache/mlx-bun/exports/export-"));
  expect(args[0]!.slice(1)).toEqual(["org/base", "/trained", undefined]);
  expect(events).toEqual([]);
});

test("exports in the same millisecond retain separate manifests", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-adapter-export-")); roots.push(root);
  const clock = spyOn(Date, "now").mockReturnValue(123456789);
  try {
    const routes = createAdapterArtifactRoutes(lock([]), { outputRoot: root });
    const responses = await Promise.all(["first", "second"].map(name => routes.handle(post("export", {
      base_model: `org/${name}`, adapter_path: `/trained/${name}`,
    }))));
    const bodies = await Promise.all(responses.map(response => {
      expect(response!.status).toBe(200);
      return response!.json();
    }));
    expect(bodies[0].export_path).not.toBe(bodies[1].export_path);
    for (const [index, body] of bodies.entries()) {
      expect(body.export_path).toStartWith(join(root, "exports/export-123456789-"));
      expect(body.manifest.base_model).toBe(`org/${index === 0 ? "first" : "second"}`);
      expect(await Bun.file(join(body.export_path, "manifest.json")).json()).toEqual(body.manifest);
    }
  } finally { clock.mockRestore(); }
});

test("merges queued in the same millisecond retain separate artifacts after serial admission", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-adapter-merge-")); roots.push(root);
  const clock = spyOn(Date, "now").mockReturnValue(123456789);
  let release!: () => void, allQueued!: () => void;
  let tail = new Promise<void>(resolve => { release = resolve; });
  const queued = new Promise<void>(resolve => { allQueued = resolve; });
  let admissions = 0, calls = 0;
  const gateway: Pick<GenerationGateway, "runExclusive"> = { runExclusive(work) {
    const result = tail.then(work);
    tail = result.then(() => {}, () => {});
    if (++admissions === 2) allQueued();
    return result;
  } };
  const routes = createAdapterArtifactRoutes(gateway, { outputRoot: root, merge: async (sources, output) => {
    calls++;
    mkdirSync(output, { recursive: true });
    await Bun.write(join(output, "sources.json"), JSON.stringify(sources));
    return { ...stats, sources };
  } });
  const pending = ["first", "second"].map(name => routes.handle(post("merge", {
    adapter_a: `/${name}/a`, adapter_b: `/${name}/b`,
  })));
  try {
    await queued;
    expect(calls).toBe(0);
    release();
    const responses = await Promise.all(pending);
    const bodies = await Promise.all(responses.map(response => {
      expect(response!.status).toBe(200);
      return response!.json();
    }));
    expect(calls).toBe(2);
    expect(bodies[0].merged_path).not.toBe(bodies[1].merged_path);
    for (const [index, body] of bodies.entries()) {
      const name = index === 0 ? "first" : "second";
      expect(body.merged_path).toStartWith(join(root, "adapters/merged-123456789-"));
      expect(await Bun.file(join(body.merged_path, "sources.json")).json()).toEqual([`/${name}/a`, `/${name}/b`]);
    }
  } finally {
    release();
    await Promise.allSettled(pending);
    clock.mockRestore();
  }
});

test("invalid and pre-cancelled requests fail before lock acquisition or artifact writes", async () => {
  const events: string[] = [];
  const unexpected = async (): Promise<never> => { throw new Error("unexpected library call"); };
  const routes = createAdapterArtifactRoutes(lock(events), { merge: unexpected, export: unexpected });
  for (const body of [null, [], {}, { adapter_a: "/a", adapter_b: 7 }, { adapter_a: "/a", adapter_b: "/b", scales: [] },
    { adapter_a: "/a", adapter_b: "/b", scales: [1, "2"] }])
    expect((await routes.handle(post("merge", body)))!.status).toBe(400);
  for (const body of [{}, { base_model: "org/base", adapter_path: 4 }, { base_model: "org/base", adapter_path: "/a", method: [] }])
    expect((await routes.handle(post("export", body)))!.status).toBe(400);
  const abort = new AbortController(); abort.abort();
  expect((await routes.handle(post("merge", { adapter_a: "/a", adapter_b: "/b" }, abort.signal)))!.status).toBe(499);
  expect((await routes.handle(post("export", { base_model: "org/base", adapter_path: "/a" }, abort.signal)))!.status).toBe(499);
  expect(events).toEqual([]);
  expect(await routes.handle(new Request("http://local/api/finetune/merge"))).toBeNull();
  expect(await routes.handle(post("push", {}))).toBeNull();
});
