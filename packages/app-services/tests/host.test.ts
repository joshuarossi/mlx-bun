import { expect, test } from "bun:test";
import type { AppModule, CatalogEntry, CoreServices, ModelCatalog } from "@mlx-bun/app-core";
import { activateModules, createHostServices, runVerb } from "../src";

const entry: CatalogEntry = { id: "org/whisper", kind: "model", directory: "/w", bytes: 1, operations: ["transcribe"] };
const catalog: ModelCatalog = { list: async () => [entry], resolve: async () => entry, find: async () => entry, estimate: async () => undefined,
  locate: async () => undefined, register: async () => { throw new Error("unused"); }, download: async () => { throw new Error("unused"); },
  pickDefault: async () => { throw new Error("unused"); }, rescan: async () => 0, startDownload() { throw new Error("unused"); }, downloads: () => [], canPublish: () => false, publish: async () => { throw new Error("unused"); } };

const module = (parts: Partial<AppModule>, events: string[] = []): AppModule => ({ id: "echo", title: "Echo", summary: "", requires: ["modelHost", "catalog"],
  activate: () => ({ dispose() { events.push("module stop"); } }), ...parts });

test("a host that serves Whisper implements modelHost, catalog, storage and events, with the configured checkpoint as the default", async () => {
  const services = createHostServices({ catalog, whisper: { modelDir: "/dir/whisper", modelId: "mine", idleUnloadSec: 9, resident: true } });
  expect(services.catalog).toBe(catalog);
  expect(Object.keys(services.bindings).sort()).toEqual(["catalog", "events", "modelHost", "storage"]);
  expect(await services.whisper.defaultFor("transcribe")).toBe("mine");
  expect(services.whisper.policy).toMatchObject({ idleUnloadSec: 9, pinned: ["mine"] });
  const bare = createHostServices({ catalog });
  expect(await bare.whisper.defaultFor("transcribe")).toBe("org/whisper");
  await services.whisper.close(); await bare.whisper.close();
});

test("the modelHost binding answers each companion operation from its own host: Whisper for transcribe, the image host for image", async () => {
  const image: CatalogEntry = { id: "org/picture", kind: "model", directory: "/p", bytes: 1, operations: ["image"] };
  const both: ModelCatalog = { ...catalog, list: async () => [entry, image], find: async query => [entry, image].find(item => item.id === query) ?? entry };
  const opened: string[] = [];
  const services = createHostServices({ catalog: both, log() {}, imageBackend: { async load(directory) {
    opened.push(directory);
    return { defaults: { width: 16, height: 16, steps: 1, guidance: 1, negativePrompt: "", uncondSkipLayers: [] }, pixelsPerLatent: 16,
      stageBytes: { conditioner: 1, denoiser: 1, decoder: 1 }, generate: async () => { throw new Error("unused"); }, dispose() { opened.push(`dispose ${directory}`); } };
  } } });
  const models = services.bindings.modelHost!({ moduleId: "echo" } as never) as typeof services.companions;
  expect(models).toBe(services.companions);
  expect(await models.defaultFor("transcribe")).toBe("org/whisper");
  expect(await models.defaultFor("image")).toBe("org/picture");
  const lease = await models.acquire("org/picture", { need: ["image"] });
  expect(lease.operations.image!.pixelsPerLatent).toBe(16);
  expect(services.image.resident().map(model => model.id)).toEqual(["org/picture"]);
  expect(services.whisper.resident()).toEqual([]);
  lease.release();
  // A configured snapshot is the image default and needs no catalog entry.
  const configured = createHostServices({ catalog, log() {}, image: { modelDir: "/dir/picture", modelId: "mine", resident: true } });
  expect(await configured.companions.defaultFor("image")).toBe("mine");
  expect(configured.image.policy.pinned).toEqual(["mine"]);
  await services.companions.close(); await configured.companions.close();
  expect(opened).toEqual(["/p", "dispose /p"]);
});

test("operation-scoped hosts reject image directories before a backend opens and expose only supported defaults", async () => {
  const image: CatalogEntry = { id: "/local/image", directory: "/local/image", kind: "model", bytes: 80, operations: ["image"] };
  const both: ModelCatalog = { ...catalog, list: async () => [entry, image], resolve: async id => id === image.id ? image : entry,
    find: async id => id === image.id ? image : entry };
  for (const operations of [[], ["transcribe"]] as const) {
    const services = createHostServices({ operations, catalog: both, imageBackend: { load: async () => { throw new Error("unexpected image load"); } } });
    try {
      expect(await services.companions.defaultFor("image")).toBeUndefined();
      expect(await services.catalog.resolve(image.id)).toBeUndefined();
      expect((await services.catalog.list()).map(item => item.id)).toEqual(operations.length ? [entry.id] : []);
      await expect(services.catalog.find(image.id)).rejects.toThrow("no operation served");
      await expect(services.companions.acquire(image.id, { need: ["image"] })).rejects.toThrow("no operation served");
      expect(services.image.resident()).toEqual([]);
    } finally { await services.companions.close(); services.events.close(); }
  }
});

test("activation refuses what these hosts do not serve yet, stopping what it activated", async () => {
  const services = createHostServices({ catalog }), events: string[] = [];
  const loaded = await activateModules([module({}, events)], services);
  await loaded.stop();
  expect(events).toEqual(["module stop"]);
  events.length = 0;
  await expect(activateModules([module({ sockets: [{ id: "live", path: "/live", summary: "" }], activate: () => ({ sockets: { live: { message() {} } }, dispose() { events.push("module stop"); } }) })],
    services)).rejects.toThrow("this host does not serve socket /api/echo/live yet");
  // A host that serves sockets (`createModuleSockets`) says so.
  const serving = await activateModules([module({ sockets: [{ id: "live", path: "/live", summary: "" }], activate: () => ({ sockets: { live: { message() {} } } }) })],
    { bindings: services.bindings, sockets: true });
  expect(serving.sockets.map(socket => socket.path)).toEqual(["/api/echo/live"]);
  await serving.stop();
  await expect(activateModules([module({ jobs: [{ kind: "echo.run", isolation: "task", gpu: "none" }], activate: () => ({ jobs: { "echo.run": async () => {} }, dispose() { events.push("module stop"); } }) })],
    services)).rejects.toThrow("this host does not serve job kind echo.run yet");
  expect(events).toEqual(["module stop", "module stop"]);
  // A host that binds the `jobs` service serves job runners.
  const jobs = {} as CoreServices["jobs"];
  const running = await activateModules([module({ requires: ["jobs"], jobs: [{ kind: "echo.run", isolation: "task", gpu: "none" }], activate: () => ({ jobs: { "echo.run": async () => {} } }) })],
    { bindings: { ...services.bindings, jobs: () => jobs } });
  expect([...running.jobs.keys()]).toEqual(["echo.run"]);
  await running.stop();
  await services.whisper.close();
});

test("running a verb parses it against the manifest, hands over the streams, and stops the module before the model host", async () => {
  const services = createHostServices({ catalog }), events: string[] = [], written: string[] = [];
  const verb = { name: "echo", summary: "Echo", positional: [{ name: "word", summary: "", required: true }], options: [{ name: "times", type: "number" as const, summary: "" }] };
  const closing = services.whisper.close.bind(services.whisper);
  services.whisper.close = () => { events.push("host close"); return closing(); };
  const original = process.stdout.write.bind(process.stdout);
  process.stdout.write = ((text: string) => { written.push(text); return true; }) as typeof process.stdout.write;
  let code: number;
  try {
    code = await runVerb({ program: "prog", spec: verb, argv: ["hi", "--times", "3"], services, modules: async () => [module({ verbs: [verb],
      activate: () => ({ verbs: { echo: async invocation => { invocation.stdout(`${invocation.positionals[0]!.repeat(Number(invocation.values.times))}\n`); return 7; } },
        dispose() { events.push("module stop"); } }) })] });
  } finally { process.stdout.write = original; }
  expect(code).toBe(7);
  expect(written.join("")).toBe("hihihi\n");
  expect(events).toEqual(["module stop", "host close"]);
  // A bad invocation never activates anything.
  await expect(runVerb({ program: "prog", spec: verb, argv: [], services, modules: async () => { throw new Error("must not load"); } })).rejects.toThrow("usage: prog echo <word>");
});

test("a verb reached through another spelling of it gets the parsed values checked, the host's terminal, and the loaded modules before it runs", async () => {
  const services = createHostServices({ catalog }), seen: unknown[] = [], events: string[] = [];
  const verb = { name: "echo", summary: "Echo", options: [{ name: "times", type: "number" as const, summary: "" }] };
  const terminal = { step: () => ({ update() {}, done() {}, fail() {} }), box() {}, heading() {}, table() {}, style: { dim: (t: string) => t, bold: (t: string) => t, green: (t: string) => t, accent: (t: string) => t, url: (t: string) => t, gradient: (t: string) => t } };
  const code = await runVerb({ program: "prog", spec: verb, values: { times: "3" }, positionals: [], services, terminal,
    activated: loaded => { events.push(`activated ${[...loaded.verbs.keys()]}`); },
    modules: async () => [module({ verbs: [verb], activate: () => ({ verbs: { echo: async invocation => { seen.push(invocation.values, invocation.terminal === terminal); return 0; } } }) })] });
  expect(code).toBe(0);
  expect(seen).toEqual([{ times: 3 }, true]);
  expect(events).toEqual(["activated echo"]);
  await expect(runVerb({ program: "prog", spec: verb, values: { times: "x" }, positionals: [], services, modules: async () => { throw new Error("must not load"); } })).rejects.toThrow("invalid --times: x");
});
