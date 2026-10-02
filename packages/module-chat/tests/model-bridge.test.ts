// The loopback Pi talks to: only its own bearer token gets in, only chat completions go through, every request runs on a
// lease of the current model that is released when the response ends, and a model host's refusal reaches Pi as an error.
import { afterEach, expect, test } from "bun:test";
import { generateThroughHost, startModelBridge, type ModelBridge } from "../src/model-bridge";
import { scriptedModel } from "./model";

let bridge: ModelBridge | undefined;
afterEach(async () => { await bridge?.close(); bridge = undefined; });
const ask = (port: number, headers: Record<string, string> = {}, path = "/v1/chat/completions", init: RequestInit = {}) =>
  fetch(`http://127.0.0.1:${port}${path}`, { method: "POST", headers: { "content-type": "application/json", ...headers }, body: JSON.stringify({ model: "local", messages: [{ role: "user", content: "hi" }], stream: true }), ...init });

test("a request with the run's token is answered by the current model through a lease that is released when the stream ends, and the token never reaches the host", async () => {
  const model = scriptedModel();
  const finish = Promise.withResolvers<void>();
  model.script.push({ text: "Hello", gate: finish.promise });
  bridge = startModelBridge(model, "secret");
  const response = await ask(bridge.port, { authorization: "Bearer secret" });
  expect(response.status).toBe(200);
  expect(model.held).toBe(1); // held while the model is still generating
  finish.resolve();
  expect(await response.text()).toContain('"content":"Hello"');
  await Bun.sleep(5);
  expect(model.held).toBe(0);
  expect(model.requests).toHaveLength(1);
  expect(model.requests[0]!.body).toMatchObject({ model: "local", stream: true });
  expect(model.requests[0]!.headers.get("authorization")).toBeNull();
});

test("another token, no token, another method and another path are refused before any model is leased", async () => {
  const model = scriptedModel();
  bridge = startModelBridge(model, "secret");
  expect((await ask(bridge.port, { authorization: "Bearer other" })).status).toBe(401);
  expect((await ask(bridge.port)).status).toBe(401);
  expect((await ask(bridge.port, { authorization: "Bearer secret" }, "/v1/models")).status).toBe(404);
  expect((await fetch(`http://127.0.0.1:${bridge.port}/v1/chat/completions`, { headers: { authorization: "Bearer secret" } })).status).toBe(404);
  expect(model.requests).toEqual([]);
  expect(model.held).toBe(0);
});

test("a client that walks away mid-stream releases the lease", async () => {
  const model = scriptedModel();
  model.script.push({ text: "Hello", gate: new Promise(() => {}) });
  bridge = startModelBridge(model, "secret");
  const response = await ask(bridge.port, { authorization: "Bearer secret" });
  expect(model.held).toBe(1);
  await response.body!.cancel();
  await Bun.sleep(20);
  expect(model.held).toBe(0);
});

test("no served model is a 503 in the OpenAI error shape; a refusing host is a 400, a closed host a 503, a failed load a 502", async () => {
  const model = scriptedModel();
  model.current = undefined;
  const call = async (host: Parameters<typeof generateThroughHost>[0]) => generateThroughHost(host, new Request("http://x/v1/chat/completions", { method: "POST", body: "{}" }));
  const none = await call(model);
  expect([none.status, (await none.json() as { error: { type: string; message: string } }).error]).toEqual([503, { type: "model_unavailable", message: "no model is served" }]);
  model.current = "org/scripted";
  for (const [code, status] of [["does-not-fit", 400], ["closed", 503], ["load-failed", 502]] as const) {
    const refusing = { defaultFor: async () => "org/scripted", acquire: async () => { throw Object.assign(new Error(`host says ${code}`), { code }); } };
    const response = await call(refusing);
    expect([response.status, (await response.json() as { error: { message: string } }).error.message]).toEqual([status, `host says ${code}`]);
  }
  expect(model.held).toBe(0);
});

test("a lease the model cannot generate on is released, and a generate that throws is a 502 with the lease released", async () => {
  const model = scriptedModel();
  const noGenerate = { defaultFor: async () => "org/scripted", acquire: async () => { const held = await model.acquire("org/scripted"); return { ...held, operations: {} }; } };
  const refused = await generateThroughHost(noGenerate, new Request("http://x/v1/chat/completions", { method: "POST", body: "{}" }));
  expect(refused.status).toBe(400);
  expect(model.held).toBe(0);
  const throwing = { defaultFor: async () => "org/scripted", acquire: async () => { const held = await model.acquire("org/scripted");
    return { ...held, operations: { generate: async () => { throw new Error("engine fell over"); } } }; } };
  const failed = await generateThroughHost(throwing, new Request("http://x/v1/chat/completions", { method: "POST", body: "{}" }));
  expect([failed.status, (await failed.json() as { error: { message: string } }).error.message]).toEqual([502, "engine fell over"]);
  expect(model.held).toBe(0);
});
