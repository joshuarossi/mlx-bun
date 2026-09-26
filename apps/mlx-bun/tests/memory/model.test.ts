// The model-call seam (src/memory/model.ts): the {system?, user} rendering every
// stage relies on, the prompt-id render, the batch width knob, per-stage adapter
// discovery, and the client injection the composition roots use. Main's research
// suite covered the rendering half against the real e4b template; the
// template/tokenizer here are fakes, so this is the model-free contract.

import { afterEach, describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import { CHUNK_SYSTEM, chunkInput } from "../../src/memory/chunk";
import {
  adapterDirFor, callLocal, callLocalBatch, configureMemoryCompletionClient, createMemoryCalls, MAX_OUTPUT_TOKENS,
  memoryBatchSize, memoryMessages, memoryPromptIds, type MemoryCompletionClient, type MemoryCompletionRequest,
} from "../../src/memory/model";

const restores: (() => void)[] = [];
afterEach(() => { for (const restore of restores.splice(0)) restore(); });

describe("memory templating — system/user message array", () => {
  test("memoryMessages emits a system turn for the chunk stage (explicit override)", () => {
    const msgs = memoryMessages("chunk", chunkInput("USER BODY"));
    expect(msgs.length).toBe(2);
    expect(msgs[0]!.role).toBe("system");
    expect(msgs[0]!.content).toBe(CHUNK_SYSTEM);
    expect(msgs[1]!.role).toBe("user");
    expect(msgs[1]!.content).toBe("USER BODY");
  });

  test("base stage gets its DEFAULT system turn when none is supplied", () => {
    const route = memoryMessages("route", { user: "Is X the same as Y? Answer yes or no." });
    expect(route[0]!.role).toBe("system");
    expect(route[0]!.content).toBe("You answer only 'yes' or 'no'.");
    expect(route[1]!.role).toBe("user");
  });

  test("an unknown stage with no default + no system renders user-only", () => {
    const msgs = memoryMessages("no-such-stage", { user: "hi" });
    expect(msgs.length).toBe(1);
    expect(msgs[0]!.role).toBe("user");
  });

  test("an explicit system overrides the stage default", () => {
    const msgs = memoryMessages("route", { system: "CUSTOM", user: "u" });
    expect(msgs[0]!.content).toBe("CUSTOM");
  });

  test("memoryPromptIds renders with a generation prompt and strips one duplicated BOS", () => {
    const rendered: unknown[] = [];
    const template = { render: (messages: unknown, options: unknown) => { rendered.push([messages, options]); return "<bos>text"; } };
    const tokenizer = { encode: (text: string) => (text === "<bos>text" ? [1, 1, 7, 8] : []), bosTokenId: 1 };
    expect(memoryPromptIds("route", { user: "u" }, tokenizer, template)).toEqual([1, 7, 8]);
    expect(rendered).toEqual([[memoryMessages("route", { user: "u" }), { addGenerationPrompt: true }]]);
    expect(memoryPromptIds("route", { user: "u" }, { encode: () => [1, 7, 8], bosTokenId: 1 }, template)).toEqual([1, 7, 8]);
    expect(memoryPromptIds("route", { user: "u" }, { encode: () => [1, 1, 7], bosTokenId: 2 }, template)).toEqual([1, 1, 7]);
  });

  test("the output backstop is one high cap, never a per-stage budget", () => {
    expect(MAX_OUTPUT_TOKENS).toBe(64_000);
  });
});

describe("memory batch width", () => {
  test("defaults to 1 (serial) and honors MLX_BUN_MEMORY_BATCH >= 1", () => {
    expect(memoryBatchSize()).toBe(1);
    restores.push(configureRuntime({ MLX_BUN_MEMORY_BATCH: "8" }));
    expect(memoryBatchSize()).toBe(8);
    restores.push(configureRuntime({ MLX_BUN_MEMORY_BATCH: "2.9" }));
    expect(memoryBatchSize()).toBe(2);
    for (const bad of ["0", "-3", "abc", ""]) {
      restores.push(configureRuntime({ MLX_BUN_MEMORY_BATCH: bad }));
      expect(memoryBatchSize()).toBe(1);
    }
  });
});

describe("memory model seam — adapters", () => {
  test("adapterDirFor returns undefined when no adapter is symlinked, the dir once present", () => {
    const previous = process.env.HOME;
    const home = mkdtempSync(join(tmpdir(), "mlx-memory-adapters-"));
    process.env.HOME = home;
    restores.push(() => { process.env.HOME = previous; rmSync(home, { recursive: true, force: true }); });
    const stage = "p0t1-fixture", directory = join(home, ".cache", "mlx-bun", "adapters", `memory-${stage}`);
    expect(adapterDirFor("definitely-no-such-stage-xyz")).toBeUndefined();
    const before = adapterDirFor(stage) !== undefined;
    expect(before).toBe(false);
    mkdirSync(directory, { recursive: true });
    expect(adapterDirFor(stage)).toBe(directory);
    const after = adapterDirFor(stage) !== undefined;
    expect(after).toBe(true);
    expect(after).not.toBe(before);
  });
});

describe("memory model seam — client injection", () => {
  function recorder(): { client: MemoryCompletionClient; requests: MemoryCompletionRequest[][] } {
    const requests: MemoryCompletionRequest[][] = [];
    return { requests, client: {
      async complete(request) { requests.push([request]); return `one:${request.input.user}`; },
      async completeBatch(batch) { requests.push([...batch]); return batch.map((request) => `many:${request.input.user}`); },
    } };
  }

  test("createMemoryCalls binds a client with main's 256-token default and empty-batch short circuit", async () => {
    const { client, requests } = recorder();
    const calls = createMemoryCalls(client);
    expect(await calls.callLocal("route", { user: "q" })).toBe("one:q");
    expect(await calls.callLocalBatch("entity", [{ user: "a" }, { user: "b" }], { maxTokens: 9 })).toEqual(["many:a", "many:b"]);
    expect(await calls.callLocalBatch("entity", [])).toEqual([]);
    expect(requests).toEqual([
      [{ stage: "route", input: { user: "q" }, maxTokens: 256 }],
      [{ stage: "entity", input: { user: "a" }, maxTokens: 9 }, { stage: "entity", input: { user: "b" }, maxTokens: 9 }],
    ]);
  });

  test("the stage defaults reject until composition installs a client, then delegate, then restore", async () => {
    await expect(callLocal("route", { user: "q" })).rejects.toThrow(/no completion client configured.*mlx-bun serve/);
    await expect(callLocalBatch("entity", [{ user: "a" }])).rejects.toThrow("no completion client configured");
    const { client, requests } = recorder();
    const restore = configureMemoryCompletionClient(client);
    try {
      expect(await callLocal("route", { user: "q" }, { maxTokens: 4 })).toBe("one:q");
      expect(await callLocalBatch("entity", [{ user: "a" }])).toEqual(["many:a"]);
      expect(requests[0]).toEqual([{ stage: "route", input: { user: "q" }, maxTokens: 4 }]);
      const inner = recorder();
      const restoreInner = configureMemoryCompletionClient(inner.client);
      expect(await callLocal("route", { user: "z" })).toBe("one:z");
      expect(inner.requests).toHaveLength(1);
      restoreInner();
      expect(await callLocal("route", { user: "back" })).toBe("one:back");
      expect(requests).toHaveLength(3);
    } finally { restore(); }
    await expect(callLocal("route", { user: "q" })).rejects.toThrow("no completion client configured");
  });
});
