// What the chat reports about the served model comes from the model host's own wire: the discovery row and the enforced
// context, whichever model is current and wherever it runs.
import { expect, test } from "bun:test";
import { describeModel } from "../src/describe";
import { scriptedModel } from "./model";

test("the discovery row and the enforced context describe the current model, and every lease is released", async () => {
  const model = scriptedModel("org/current");
  Object.assign(model.row, { vision: true, audio: true, reasoning: true, capabilities: { transcription: true }, gen_defaults: { temperature: 0.2, top_p: null, top_k: 40 } });
  expect(await describeModel(model)).toEqual({ modelId: "org/current", contextWindow: 2048, vision: true, audio: true, thinking: true, transcription: true,
    genDefaults: { temperature: 0.2, topP: null, topK: 40 } });
  expect(model.held).toBe(0);
});

test("the context window falls back to the model's when the server enforces none, and a model that declares nothing describes as plain text", async () => {
  const model = scriptedModel();
  model.serverStats = {};
  expect(await describeModel(model)).toMatchObject({ contextWindow: 4096, vision: false, audio: false, thinking: false, transcription: false });
  model.row = {};
  model.serverStats = { admission: { enforced_context_tokens: "n/a" } };
  expect(await describeModel(model)).toEqual({ modelId: "org/scripted", contextWindow: undefined, vision: false, audio: false, thinking: false, transcription: false,
    genDefaults: { temperature: null, topP: null, topK: null } });
});

test("a model switch is followed: the description is of whichever model is current when asked", async () => {
  const model = scriptedModel("org/first");
  expect((await describeModel(model)).modelId).toBe("org/first");
  model.current = "org/second";
  expect((await describeModel(model)).modelId).toBe("org/second");
});

test("no served model, or a wire that answers with an error, rejects and holds nothing", async () => {
  const model = scriptedModel();
  model.current = undefined;
  await expect(describeModel(model)).rejects.toThrow("no model is served");
  model.current = "org/scripted";
  const failing = { ...model, acquire: async (id: string) => { const lease = await model.acquire(id);
    return { ...lease, operations: { generate: async () => new Response("boom", { status: 500 }) } }; } };
  await expect(describeModel(failing as never)).rejects.toThrow("answered 500 on /v1/models");
  expect(model.held).toBe(0);
});
