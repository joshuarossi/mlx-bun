// The module as a host loads it: a valid manifest that needs only `modelHost`
// and `catalog`, routes mounted at their shipped root paths, verbs dispatched
// with what the host parsed, and live counters for the host's health surface.
import { expect, test } from "bun:test";
import { checkManifests, loadModules } from "@mlx-bun/app-host";
import { createModuleRoutes, createWhisperModelHost, parseVerb } from "@mlx-bun/app-services";
import transcription, { createTranscriptionModule } from "../src/index";
import { manifest } from "../src/manifest";
import { fakeCatalog, MODEL_ID, type TranscriptionRuntime } from "./support";

const runtime: TranscriptionRuntime = {
  async load() {
    return {
      promptTokenBudget: 223, encode: text => text.split(/\s+/).filter(Boolean).map((_, index) => index),
      transcribe: async (samples, options) => ({ text: " hello", segments: [{ id: 0, seek: 0, start: 0, end: 1, text: " hello", tokens: [1], temperature: 0,
        avgLogprob: -0.1, compressionRatio: 1, noSpeechProb: 0 }], language: options.language ?? "en" }),
      start() { throw new Error("no streaming here"); },
      dispose() {},
    };
  },
  async vad() { throw new Error("no gate here"); },
  async decodeAudio(bytes) { return new Float32Array(bytes.length); },
};

function bindings() {
  const host = createWhisperModelHost({ catalog: fakeCatalog(), configured: { id: MODEL_ID, directory: "/whisper" }, backend: runtime, log() {} });
  return { host, services: { modelHost: () => host, catalog: () => fakeCatalog() } };
}

test("the manifest is valid for a host that implements modelHost and catalog, and needs nothing else", () => {
  expect(transcription.requires).toEqual(["modelHost", "catalog"]);
  expect(checkManifests([transcription], { provided: ["modelHost", "catalog"] })).toEqual([]);
  expect(checkManifests([transcription], { provided: ["modelHost"] })).toEqual(['module "transcription": requires "catalog", which this host does not implement']);
  expect(transcription.jobs ?? []).toEqual([]);
  expect(transcription.storage ?? []).toEqual([]);
  expect(transcription.sockets ?? []).toEqual([]);
});

test("the verbs declare exactly the options the parser accepts", () => {
  const dictate = manifest.verbs.find(verb => verb.name === "dictate")!;
  expect(dictate.options.filter(option => "optionalValue" in option).map(option => option.name)).toEqual(["hotkey"]);
  expect(parseVerb("mlx-bun", dictate, ["--hotkey", "--copy"]).values).toMatchObject({ hotkey: 61, copy: true });
});

test("activated, it serves its routes at the root, transcribes through the verb, and reports its counters", async () => {
  const { host, services } = bindings();
  const written: string[] = [];
  const module = createTranscriptionModule({ transcribe: { read: async () => new Uint8Array(32_000), media: runtime } });
  const loaded = await loadModules([module], { services });
  try {
    expect(loaded.routes.map(route => `${route.spec.method} ${route.path}`)).toEqual(manifest.routes.map(route => `${route.method} ${route.path}`));
    expect([...loaded.verbs.keys()]).toEqual(["transcribe", "dictate"]);
    const verb = loaded.verbs.get("transcribe")!;
    const code = await verb.handler({ ...parseVerb("mlx-bun", verb.spec, ["clip.wav", "--format", "json"]), signal: new AbortController().signal,
      stdout: text => { written.push(text); }, stderr: () => {} });
    expect(code).toBe(0);
    expect(written).toEqual(['{"text":"hello"}\n']);
    // The routes answer through the same module: an unload of nothing resident reports it.
    const routes = createModuleRoutes(loaded.routes);
    const unloaded = await routes.handle(new Request("http://localhost/admin/transcription/unload", { method: "POST" }));
    expect(await unloaded!.json()).toMatchObject({ unloaded: false, resident: false, loads: 1, unloads: 1, idle_unload_sec: 0 });
    expect(loaded.status("transcription")).toEqual({ requests: 0, sessions: 0 });
    expect(await routes.handle(new Request("http://localhost/v1/models"))).toBeNull();
  } finally {
    await loaded.stop();
    await host.close();
  }
});

test("a cancelled transcribe verb rejects with its own message", async () => {
  const { host, services } = bindings();
  const module = createTranscriptionModule({ transcribe: { read: async () => new Uint8Array(32_000), media: runtime } });
  const loaded = await loadModules([module], { services });
  try {
    const verb = loaded.verbs.get("transcribe")!, abort = new AbortController();
    abort.abort(new Error("transcribe cancelled"));
    await expect(verb.handler({ ...parseVerb("mlx-bun", verb.spec, ["clip.wav"]), signal: abort.signal, stdout: () => {}, stderr: () => {} }))
      .rejects.toThrow("transcription cancelled");
  } finally { await loaded.stop(); await host.close(); }
});
