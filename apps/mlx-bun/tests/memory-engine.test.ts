// The `memory` verb's in-process task-model client over a fake engine: lazy,
// shared initialization; safe close before, during and after it; main's prompt,
// adapter and greedy policy; and bounded, ordered, cancellable batches. No model
// or native library is loaded.
import { afterEach, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import type { KvScheme } from "@mlx-bun/inference/state/kv-scheme";
import type { GenerateOptions } from "@mlx-bun/inference/generation";
import type { LoadedModelContext } from "../src/engine/model-host";
import { CHUNK_ADAPTER, createInProcessMemoryClient, locateTaskModel, type MemoryEngine, type MemoryEngineDependencies } from "../src/cli/memory-engine";
import { MEMORY_TASK_MODEL, memoryPromptIds, type MemoryCompletionRequest } from "../src/memory/model";

let restoreRuntime: (() => void) | undefined;
afterEach(() => { restoreRuntime?.(); restoreRuntime = undefined; });
const batchWidth = (width: number) => { restoreRuntime = configureRuntime({ MLX_BUN_MEMORY_BATCH: String(width) }); };

interface Call { promptIds: number[]; options: GenerateOptions & { adapters?: string[] }; signal?: AbortSignal }
type RunImpl = (call: Call, emit: (token: number) => void) => Promise<void>;

const tokenizer = {
  encode: (text: string) => [1, 1, ...[...text].map(char => char.charCodeAt(0))],
  decode: (tokens: number[], skip: boolean) => `${skip ? "" : "!"}${tokens.map(token => String.fromCharCode(token)).join("")}`,
  bosTokenId: 1, eosTokenId: 2, idToToken: () => "",
};
const template = { render: (messages: { role: string; content: string }[], options: { addGenerationPrompt: boolean }) =>
  messages.map(message => `${message.role}:${message.content}`).join("|") + (options.addGenerationPrompt ? "|>" : "") };

function harness(options: { adapterDir?: string; run?: RunImpl; locate?: () => Promise<string>;
  load?: () => Promise<LoadedModelContext> } = {}) {
  const events: string[] = [];
  const calls: Call[] = [];
  let scheme: KvScheme | undefined, capacity = 0;
  const context = () => ({
    tokenizer, template, kvConfig: null, glmMemoryPlan: null,
    adapters: { async mount(id: string, dir: string) { events.push(`mount ${id} ${dir}`); } },
    dispose() { events.push("dispose"); },
  }) as unknown as LoadedModelContext;
  const run: RunImpl = options.run ?? (async (call, emit) => { for (const id of call.promptIds.slice(-2)) emit(id); });
  const deps: MemoryEngineDependencies = {
    async locate(repoId) { events.push(`locate ${repoId}`); return options.locate ? options.locate() : "/cache/e4b"; },
    async load(path, repoId) { events.push(`load ${path} ${repoId}`); return options.load ? options.load() : context(); },
    async engine(loaded, kv, width) {
      scheme = kv; capacity = width; events.push("engine");
      const engine: MemoryEngine = {
        context: loaded,
        completion: {
          place: () => ({ mechanism: "continuous" }),
          async run(promptIds: number[], generate: GenerateOptions, onToken: (token: number) => void, _vision: unknown, _shape: unknown, _placement: unknown, signal?: AbortSignal) {
            const call = { promptIds, options: generate, signal };
            calls.push(call);
            await run(call, token => onToken(token));
            return { promptTokens: promptIds.length, cachedTokens: 0, generatedTokens: 0, prefillTps: 0, decodeTps: 0, prefillMs: 0, decodeMs: 0 };
          },
        } as unknown as MemoryEngine["completion"],
        gateway: { async runExclusive(work: () => Promise<unknown>) { events.push("exclusive"); return work(); } } as MemoryEngine["gateway"],
        async close() { events.push("engine close"); loaded.dispose(); },
      };
      return engine;
    },
    adapterDir: stage => stage === "chunk" ? options.adapterDir : undefined,
  };
  return { deps, events, calls, scheme: () => scheme, capacity: () => capacity };
}
const request = (stage: string, user: string, maxTokens = 16): MemoryCompletionRequest => ({ stage, input: { user }, maxTokens });

test("nothing loads until a completion is requested, and concurrent callers share one initialization", async () => {
  const idle = harness();
  await createInProcessMemoryClient(idle.deps).close();
  expect(idle.events).toEqual([]);

  const h = harness({ adapterDir: "/adapters/memory-chunk" });
  const memory = createInProcessMemoryClient(h.deps);
  expect(h.events).toEqual([]);
  const answers = await Promise.all([memory.client.complete(request("route", "a")), memory.client.complete(request("chunk", "b"))]);
  expect(answers).toEqual(["|>", "|>"]);
  expect(h.events).toEqual([`locate ${MEMORY_TASK_MODEL}`, `load /cache/e4b ${MEMORY_TASK_MODEL}`, "engine", "exclusive",
    `mount ${CHUNK_ADAPTER} /adapters/memory-chunk`]);
  // Close is memoized: concurrent and repeated calls release the engine and model once.
  await Promise.all([memory.close(), memory.close()]);
  await memory.close();
  expect(h.events.filter(event => event === "engine close")).toHaveLength(1);
  expect(h.events.filter(event => event === "dispose")).toHaveLength(1);
  await expect(memory.client.complete(request("route", "c"))).rejects.toThrow("closed");
});

test("main's policy: rendered prompt ids, greedy with no stop strings, full-precision KV, the chunk adapter only on chunk", async () => {
  const h = harness({ adapterDir: "/adapters/memory-chunk" });
  const memory = createInProcessMemoryClient(h.deps);
  try {
    for (const stage of ["chunk", "entity", "route", "synthesis", "section", "editor"])
      await memory.client.complete(request(stage, `input for ${stage}`, 32));
    expect(h.scheme()!.kind).toBe("bf16");
    for (const [index, stage] of ["chunk", "entity", "route", "synthesis", "section", "editor"].entries()) {
      const call = h.calls[index]!;
      expect(call.promptIds).toEqual(memoryPromptIds(stage, { user: `input for ${stage}` }, tokenizer, template as never));
      expect(call.options).toMatchObject({ maxTokens: 32, temperature: 0, stopSequences: [] });
      expect(call.options.adapters ?? []).toEqual(stage === "chunk" ? [CHUNK_ADAPTER] : []);
    }
  } finally { await memory.close(); }
  // Without an adapter on disk nothing is mounted and chunk runs the base model.
  const bare = harness();
  const plain = createInProcessMemoryClient(bare.deps);
  try {
    await plain.client.complete(request("chunk", "x"));
    expect(bare.events.some(event => event.startsWith("mount"))).toBe(false);
    expect(bare.calls[0]!.options.adapters ?? []).toEqual([]);
  } finally { await plain.close(); }
});

test("a failed initialization stays failed, is not retried, and closes cleanly", async () => {
  const h = harness({ locate: async () => { throw new Error("memory: Gemma-4-e4b is not downloaded"); } });
  const memory = createInProcessMemoryClient(h.deps);
  await expect(memory.client.complete(request("route", "a"))).rejects.toThrow("not downloaded");
  await expect(memory.client.completeBatch([request("entity", "a"), request("entity", "b")])).rejects.toThrow("not downloaded");
  expect(h.events.filter(event => event.startsWith("locate"))).toHaveLength(1);
  await memory.close();
  expect(h.events.some(event => event.startsWith("load"))).toBe(false);
});

test("closing during initialization releases the model and refuses later work", async () => {
  const gate = Promise.withResolvers<void>();
  const h = harness();
  const loading = harness({ load: async () => { await gate.promise; return (await h.deps.load("/x", "y")); } });
  const memory = createInProcessMemoryClient(loading.deps);
  const pending = memory.client.complete(request("route", "a"));
  await Bun.sleep(1);
  const closing = memory.close();
  gate.resolve();
  await expect(pending).rejects.toThrow("closed");
  await closing;
  expect(h.events).toContain("dispose");
  expect(loading.events).not.toContain("engine");
  await expect(memory.client.complete(request("route", "b"))).rejects.toThrow("closed");
});

test("a batch keeps at most the configured width in flight over a large list and returns input order", async () => {
  batchWidth(3);
  let inFlight = 0, peak = 0;
  const h = harness({ run: async (call, emit) => {
    inFlight++; peak = Math.max(peak, inFlight);
    await Bun.sleep(1 + (call.promptIds.length % 3));
    emit(call.promptIds.at(-3)!); // the user text's last character, before the "|>" generation prompt
    inFlight--;
  } });
  const memory = createInProcessMemoryClient(h.deps);
  try {
    const requests = Array.from({ length: 40 }, (_, index) => request("entity", `row ${String(index).padStart(2, "0")}`));
    const results = await memory.client.completeBatch(requests);
    expect(h.capacity()).toBe(3);
    expect(peak).toBe(3);
    expect(h.calls).toHaveLength(40);
    expect(results).toEqual(requests.map(row => row.input.user.at(-1)!));
    // Mixed stages or budgets run one row at a time, still in input order.
    peak = 0;
    const mixed = [request("entity", "a1"), request("route", "b2"), request("entity", "c3", 8)];
    expect(await memory.client.completeBatch(mixed)).toEqual(["1", "2", "3"]);
    expect(peak).toBe(1);
  } finally { await memory.close(); }
});

test("a failed row cancels its siblings, starts no new rows, and every started row settles before the batch rejects", async () => {
  batchWidth(3);
  const started: number[] = [], settled: number[] = [], aborted: number[] = [];
  const h = harness({ run: async (call) => {
    const row = Number(String.fromCharCode(...call.promptIds.slice(-4, -2))); // the two-digit user text before "|>"
    started.push(row);
    try {
      if (row === 1) { await Bun.sleep(5); throw new Error("row 1 failed"); }
      await new Promise<void>((resolve, reject) => {
        const timer = setTimeout(resolve, 5_000);
        call.signal!.addEventListener("abort", () => { clearTimeout(timer); aborted.push(row); reject(call.signal!.reason); }, { once: true });
      });
    } finally { await Bun.sleep(2); settled.push(row); }
  } });
  const memory = createInProcessMemoryClient(h.deps);
  try {
    const requests = Array.from({ length: 12 }, (_, index) => request("entity", String(index).padStart(2, "0")));
    const failure = await memory.client.completeBatch(requests).then(() => null, (error: Error) => error);
    expect(failure?.message).toBe("row 1 failed");
    expect(started.toSorted()).toEqual([0, 1, 2]);
    expect(settled.toSorted()).toEqual([0, 1, 2]);
    expect(aborted.toSorted()).toEqual([0, 2]);
  } finally { await memory.close(); }
});

test("the task model resolves from the Hugging Face cache and is never downloaded", async () => {
  const hub = mkdtempSync(join(tmpdir(), "mlx-memory-hub-"));
  try {
    const snapshots = join(hub, "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit", "snapshots");
    await expect(locateTaskModel(MEMORY_TASK_MODEL, hub)).rejects.toThrow(
      `memory: Gemma-4-e4b is not downloaded (looked under ${snapshots}). Fetch it first: HF_HUB_DISABLE_XET=1 hf download ${MEMORY_TASK_MODEL}`);
    // A snapshot directory without config.json and weights is not a model either.
    mkdirSync(join(snapshots, "incomplete"), { recursive: true });
    await expect(locateTaskModel(MEMORY_TASK_MODEL, hub)).rejects.toThrow("is not downloaded");
    const complete = join(snapshots, "0123abc");
    mkdirSync(complete, { recursive: true });
    writeFileSync(join(complete, "config.json"), JSON.stringify({ model_type: "gemma4" }));
    writeFileSync(join(complete, "model.safetensors"), new Uint8Array(64));
    expect(await locateTaskModel(MEMORY_TASK_MODEL, hub)).toBe(complete);
  } finally { rmSync(hub, { recursive: true, force: true }); }
});
