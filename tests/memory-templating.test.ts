// Memory inference-path templating + batching (docs/design/memory-inference-path.md).
//
// The CORRECTNESS gate: the memory seam renders a {system, user} message array
// through the SAME chat-template path as the server and the trainer, so the
// `e4b-chunk-300` adapter (SFT'd WITH a system turn) decodes on-distribution.
//
// CPU-only parity test (needs the snapshot dir, not the GPU): assert the chunk
// render's ids are byte/id-identical to encodeSftRow's prompt-region render for a
// REAL train.jsonl row — the foundation. The batched-call test loads the model and
// is deferred to the GPU-capable parent (skipIf no e4b).

import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import {
  CHUNK_SYSTEM,
  chunkInput,
} from "../src/memory/chunk";
import { memoryMessages, memoryPromptIds } from "../src/memory/model";
import { encodeSftRow } from "../src/train/dataset";
import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";
import { SNAPSHOT_E4B, snapshotE4bAvailable } from "./paths";

const haveE4b = await snapshotE4bAvailable();
const TRAIN = `${process.env.HOME}/.cache/mlx-bun/mlx-bun-finetunes/chunk-data-le4000/train.jsonl`;
const haveTrain = existsSync(TRAIN);

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
});

describe.skipIf(!haveE4b || !haveTrain)("memory templating — training parity (CPU)", () => {
  test("chunk render is byte/id-identical to encodeSftRow's prompt region", async () => {
    const tokenizer = await loadTokenizer(SNAPSHOT_E4B);
    const template = await ChatTemplate.load(SNAPSHOT_E4B);

    const row = JSON.parse(readFileSync(TRAIN, "utf8").split("\n")[0]!) as {
      messages: { role: string; content: string }[];
    };
    const sys = row.messages[0]!.content;
    const user = row.messages[1]!.content;

    // The chunk seam renders {system: CHUNK_SYSTEM, user}. Confirm the trained
    // system is reproduced verbatim, THEN that ids match the trainer's render.
    expect(sys).toBe(CHUNK_SYSTEM);

    const ids = memoryPromptIds("chunk", { system: sys, user }, tokenizer, template);

    // Trainer prompt-region ids: encodeSftRow's full ids up to promptLen are the
    // render of [system, user] with addGenerationPrompt:true (dataset.ts:98-101).
    const ex = encodeSftRow(row as never, tokenizer, template);
    const trainerPromptIds = ex.ids.slice(0, ex.promptLen);

    expect(ids.length).toBe(trainerPromptIds.length);
    expect(ids).toEqual(trainerPromptIds);

    // And the rendered text carries the DISTINCT system block (not user-only).
    const text = template.render(memoryMessages("chunk", { system: sys, user }), {
      addGenerationPrompt: true,
    });
    expect(text.startsWith("<bos><|turn>system")).toBe(true);
  });

  test("dropping the system turn changes the ids (the off-distribution bug)", async () => {
    const tokenizer = await loadTokenizer(SNAPSHOT_E4B);
    const template = await ChatTemplate.load(SNAPSHOT_E4B);
    const withSys = memoryPromptIds("chunk", { system: CHUNK_SYSTEM, user: "BODY" }, tokenizer, template);
    const userOnly = memoryPromptIds("nostage", { user: "BODY" }, tokenizer, template);
    expect(withSys).not.toEqual(userOnly);
    expect(withSys.length).toBeGreaterThan(userOnly.length);
  });
});

// DEFERRED TO PARENT (GPU): loads the shared model + drives the BatchScheduler.
describe.skipIf(!haveE4b)("memory batching — N prompts → N ordered outputs", () => {
  test("callLocalBatch is order-preserving and matches serial greedy (base stage)", async () => {
    const { callLocal, callLocalBatch } = await import("../src/memory/model");
    const inputs = [
      { user: "Reply with the single word: alpha" },
      { user: "Reply with the single word: bravo" },
      { user: "Reply with the single word: charlie" },
    ];
    const batched = await callLocalBatch("entity", inputs, { maxTokens: 8 });
    expect(batched.length).toBe(inputs.length);

    const serial: string[] = [];
    for (const inp of inputs) serial.push(await callLocal("entity", inp, { maxTokens: 8 }));
    // Greedy on both lanes; the batched (sampler) lane may diverge on near-ties
    // past ~32 tokens, but for 8-token deterministic replies it should agree.
    expect(batched).toEqual(serial);
  });
});
