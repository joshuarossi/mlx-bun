// The Whisper model host's contract: leases, lazy load, idle policy, pinning,
// the execution lock around decode calls, and the failures a consumer sees.
import { expect, test } from "bun:test";
import type { CatalogEntry, CoreEvent, ModelCatalog, ModelHostError } from "@mlx-bun/app-core";
import { createWhisperModelHost, type LoadedWhisper, type WhisperBackend } from "../src";

const entry = (id: string, directory = `/models/${id}`, operations: CatalogEntry["operations"] = ["transcribe"]): CatalogEntry =>
  ({ id, kind: "model", directory, bytes: 100, operations });
const catalog = (entries: CatalogEntry[]): ModelCatalog => ({
  list: async () => entries, resolve: async id => entries.find(item => item.id === id),
  find: async query => entries.find(item => item.id === query) ?? (() => { throw new Error(`no model matching "${query}"`); })(),
  estimate: async () => undefined, register: async () => { throw new Error("unused"); }, download: async () => { throw new Error("unused"); },
});

function setup(options: Partial<Parameters<typeof createWhisperModelHost>[0]> = {}, entries = [entry("org/whisper"), entry("org/chat", "/models/chat", ["generate"])]) {
  const events: string[] = [], seen: unknown[] = [];
  const clock = { now: 0 }, timers: { ms: number; fn: () => void }[] = [];
  const backend: WhisperBackend = { async load(dir) {
    events.push(`load ${dir}`); clock.now += 250;
    const loaded: LoadedWhisper = {
      promptTokenBudget: 7, encode: text => [...text].map((_, index) => index),
      async transcribe(samples, opts) { seen.push(opts); events.push(`transcribe ${samples.length}`); return { text: " hi", segments: [], language: opts.language ?? "en" }; },
      start(opts) { seen.push(opts); return { segments: [], feedSilent() {}, async feed(samples) { events.push(`feed ${samples.length}`); }, async finish() { return { text: "", segments: [], language: "en" }; } }; },
      dispose() { events.push(`dispose ${dir}`); },
    };
    return loaded;
  } };
  const host = createWhisperModelHost({ catalog: catalog(entries), backend, log() {}, now: () => clock.now,
    timers: { setTimeout: (fn, ms) => { const timer = { ms, fn }; timers.push(timer); return timer; }, clearTimeout: handle => { const at = timers.indexOf(handle as never); if (at >= 0) timers.splice(at, 1); } },
    ...options });
  return { host, events, seen, timers, clock };
}

test("a lease loads on first use, reports what loading cost, and the default policy releases right after it", async () => {
  const { host, events } = setup();
  const first = await host.acquire("org/whisper", { need: ["transcribe"] });
  expect(first.loadMs).toBe(250);
  expect(first.model).toMatchObject({ id: "org/whisper", role: "companion", operations: ["transcribe"], leases: 1, pinned: false });
  expect(host.resident().map(model => model.id)).toEqual(["org/whisper"]);
  first.release(); first.release();
  expect(host.resident()).toEqual([]);
  expect(host.stats("org/whisper")).toEqual({ resident: false, loads: 1, unloads: 1, lastLoadMs: 250, idleUnloadSec: 0 });
  expect((await host.acquire("org/whisper")).loadMs).toBe(250);
  expect(events).toEqual(["load /models/org/whisper", "dispose /models/org/whisper", "load /models/org/whisper"]);
});

test("the idle policy and a per-lease keep-alive delay the release; a new lease cancels it and pinning removes it", async () => {
  const { host, timers, events } = setup({ idleUnloadSec: 5 });
  (await host.acquire("org/whisper")).release();
  expect(timers.map(timer => timer.ms)).toEqual([5000]);
  const warm = await host.acquire("org/whisper");
  expect(warm.loadMs).toBe(0); expect(timers).toEqual([]);
  warm.release();
  timers.shift()!.fn();
  expect(host.resident()).toEqual([]);
  // keepAliveSec overrides the policy for that lease.
  (await host.acquire("org/whisper", { keepAliveSec: 30 })).release();
  expect(timers.map(timer => timer.ms)).toEqual([30_000]);
  host.pin("org/whisper");
  expect(timers).toEqual([]);
  (await host.acquire("org/whisper")).release();
  expect(timers).toEqual([]);
  expect(host.resident()[0]).toMatchObject({ pinned: true });
  expect(host.stats("org/whisper").idleUnloadSec).toBeNull();
  expect(host.policy.pinned).toEqual(["org/whisper"]);
  host.unpin("org/whisper");
  (await host.acquire("org/whisper", { keepAliveSec: 0 })).release();
  expect(host.resident()).toEqual([]);
  expect(events.filter(event => event.startsWith("load"))).toHaveLength(2);
});

test("unload refuses while a lease is held, resolves when nothing is resident, and force releases anyway", async () => {
  const { host } = setup({ idleUnloadSec: 60 });
  await host.unload("org/whisper");
  const lease = await host.acquire("org/whisper");
  await expect(host.unload("org/whisper")).rejects.toMatchObject({ code: "in-use" } satisfies Partial<ModelHostError>);
  expect(host.resident()).toHaveLength(1);
  lease.release();
  await host.unload("org/whisper");
  expect(host.resident()).toEqual([]);
  const held = await host.acquire("org/whisper");
  await host.unload("org/whisper", { force: true });
  expect(host.resident()).toEqual([]);
  held.release();
});

test("acquire rejects a model that does not declare transcribe and an id the catalog lacks; a configured model needs no catalog", async () => {
  const { host } = setup({ configured: { id: "test-whisper", directory: "/dir/whisper" } });
  await expect(host.acquire("org/chat")).rejects.toMatchObject({ code: "does-not-fit" });
  await expect(host.acquire("org/unknown")).rejects.toThrow('no model matching "org/unknown"');
  expect((await host.acquire("test-whisper")).model.id).toBe("test-whisper");
  expect(await host.defaultFor("transcribe")).toBe("test-whisper");
});

test("the default is the configured checkpoint, else the first that declares transcribe, resolved once; other operations have none", async () => {
  let listed = 0;
  const entries = [entry("org/chat", "/c", ["generate"]), entry("org/whisper-a"), entry("org/whisper-b")];
  const counting = { ...catalog(entries), list: async () => { listed++; return entries; } };
  const { host } = setup({ catalog: counting });
  expect(await host.defaultFor("transcribe")).toBe("org/whisper-a");
  expect(await host.defaultFor("transcribe")).toBe("org/whisper-a");
  expect(listed).toBe(1);
  expect(await host.defaultFor("generate")).toBeUndefined();
  const none = setup({ catalog: { ...catalog([]), list: async () => { throw new Error("no registry"); } } });
  expect(await none.host.defaultFor("transcribe")).toBeUndefined();
});

test("decode calls run under the execution lock and carry the portable options to the library's names", async () => {
  const locks: string[] = [];
  const { host, seen } = setup({ exclusive: async (fn, signal) => { locks.push(signal?.aborted ? "aborted" : "lock"); return fn(); } });
  const lease = await host.acquire("org/whisper");
  const model = lease.operations.transcribe!;
  expect(model.promptTokenBudget).toBe(7); expect(model.encode("abc")).toEqual([0, 1, 2]);
  await model.transcribe(new Float32Array(10), { language: "auto", prompt: "p", faithful: true, temperature: 0, onSegment: undefined });
  expect(seen[0]).toMatchObject({ task: "transcribe", language: null, initialPrompt: "p", beamSize: null, temperature: 0, conditionOnPreviousText: true,
    withoutTimestamps: false, wordTimestamps: false, fast: false, audioCtx: null });
  await model.transcribe(new Float32Array(10));
  expect(seen[1]).toMatchObject({ language: null, initialPrompt: null, fast: true });
  expect(seen[1]).not.toHaveProperty("temperature");
  const run = model.start({ language: "de" });
  await run.feed(new Float32Array(5)); await run.finish();
  expect(locks).toEqual(["lock", "lock", "lock", "lock"]);
  const abort = new AbortController(); abort.abort(new Error("gone"));
  await expect(run.feed(new Float32Array(1), abort.signal)).rejects.toThrow("gone");
  lease.release();
});

test("a load failure surfaces with the library's message; close stops admission and releases a load that was in flight", async () => {
  const failing = setup({ backend: { load: async () => { throw new Error("no tokenizer"); } } });
  await expect(failing.host.acquire("org/whisper")).rejects.toMatchObject({ code: "load-failed", message: "no tokenizer" });
  expect(failing.host.stats("org/whisper").loads).toBe(0);
  const gate = Promise.withResolvers<void>(), started = Promise.withResolvers<void>(), disposed: string[] = [];
  const slow = setup({ backend: { async load(dir) { started.resolve(); await gate.promise; return { promptTokenBudget: 1, encode: () => [], transcribe: async () => ({ text: "", segments: [], language: "en" }),
    start: () => { throw new Error("unused"); }, dispose: () => { disposed.push(dir); } }; } } });
  const pending = slow.host.acquire("org/whisper");
  await started.promise;
  const closing = slow.host.close();
  gate.resolve();
  await expect(pending).rejects.toMatchObject({ code: "closed" });
  await closing;
  expect(disposed).toEqual(["/models/org/whisper"]);
  await expect(slow.host.acquire("org/whisper")).rejects.toMatchObject({ code: "closed" });
  await slow.host.close();
});

test("preload loads without leasing and does not arm the idle policy; close releases the weights without counting an unload", async () => {
  const { host, timers, events } = setup({ idleUnloadSec: 5 });
  await host.preload("org/whisper");
  expect(host.resident()).toHaveLength(1); expect(timers).toEqual([]);
  await host.preload();
  expect(events).toEqual(["load /models/org/whisper"]);
  await host.close(); await host.close();
  expect(events).toEqual(["load /models/org/whisper", "dispose /models/org/whisper"]);
  expect(host.stats("org/whisper")).toMatchObject({ loads: 1, unloads: 0 });
});

test("plan reports the model's size and no eviction, since this host has no memory budget", async () => {
  const { host } = setup();
  expect(await host.plan("org/whisper")).toEqual({ fits: true, requiredBytes: 100, freeBytes: Number.POSITIVE_INFINITY, evict: [] });
  expect(host.policy.budgetBytes).toBe(Number.POSITIVE_INFINITY);
});

test("loads, unloads and memory are published with their durations, and a bus that throws never reaches a decode", async () => {
  const published: CoreEvent[] = [];
  const { host } = setup({ events: { publish: event => { published.push(event as CoreEvent); } } });
  const lease = await host.acquire("org/whisper");
  lease.release();
  await (await host.acquire("org/whisper")).operations.transcribe!.transcribe(new Float32Array(1));
  await host.unload("org/whisper", { force: true });
  await host.close();
  const summary = published.map(event => event.type === "model.load" ? `load ${event.phase}${event.ms !== undefined ? ` ${event.ms}` : ""}`
    : event.type === "model.unload" ? `unload ${event.reason}` : event.type === "model.memory" ? `memory ${event.weightsBytes}` : event.type);
  expect(summary).toEqual(["load started", "load finished 250", "memory 100", "unload idle", "load started", "load finished 250", "memory 100", "unload requested"]);
  expect(published.find(event => event.type === "model.load" && event.phase === "finished")).toMatchObject({ model: "org/whisper", weightsBytes: 100 });
  const failing = setup({ backend: { load: async () => { throw new Error("no tokenizer"); } }, events: { publish: event => { published.push(event as CoreEvent); } } });
  published.length = 0;
  await expect(failing.host.acquire("org/whisper")).rejects.toMatchObject({ code: "load-failed" });
  expect(published.map(event => event.type === "model.load" ? event.phase : event.type)).toEqual(["started", "failed"]);
  expect(published[1]).toMatchObject({ error: "no tokenizer" });
  const throwing = setup({ events: { publish() { throw new Error("bus down"); } } });
  expect((await throwing.host.acquire("org/whisper")).loadMs).toBe(250);
});

test("a host that also generates is asked to make room for the bytes before a checkpoint loads, and a refusal is a load failure", async () => {
  const admitted: number[] = [];
  const { host, events } = setup({ admit: async bytes => { events.push(`admit ${bytes}`); admitted.push(bytes); } });
  (await host.acquire("org/whisper")).release();
  expect(events).toEqual(["admit 100", "load /models/org/whisper", "dispose /models/org/whisper"]);
  expect(admitted).toEqual([100]);
  // A warm lease loads nothing, so nothing is asked.
  host.pin("org/whisper");
  (await host.acquire("org/whisper")).release(); (await host.acquire("org/whisper")).release();
  expect(admitted).toEqual([100, 100]);
  const refusing = setup({ admit: async () => { throw new Error("no room"); } });
  const error = await refusing.host.acquire("org/whisper").catch(failure => failure as ModelHostError);
  expect(error).toMatchObject({ code: "load-failed", message: "no room" });
  expect(refusing.events).toEqual([]);
});

test("an explicitly configured checkpoint is sized from its files, so residency can count it", async () => {
  const { mkdtempSync, writeFileSync, rmSync } = await import("node:fs");
  const { join } = await import("node:path");
  const { tmpdir } = await import("node:os");
  const directory = mkdtempSync(join(tmpdir(), "mlx-whisper-size-"));
  try {
    writeFileSync(join(directory, "weights.safetensors"), new Uint8Array(4096));
    writeFileSync(join(directory, "config.json"), "{}");
    const { host } = setup({ configured: { id: "local-whisper", directory } }, []);
    const lease = await host.acquire("local-whisper");
    expect(lease.model.bytes).toBe(4098);
    lease.release();
  } finally { rmSync(directory, { recursive: true, force: true }); }
});
