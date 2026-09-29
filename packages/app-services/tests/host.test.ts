import { expect, test } from "bun:test";
import type { AppModule, CatalogEntry, CoreServices, ModelCatalog } from "@mlx-bun/app-core";
import { activateModules, createHostServices, runVerb } from "../src";

const entry: CatalogEntry = { id: "org/whisper", kind: "model", directory: "/w", bytes: 1, operations: ["transcribe"] };
const catalog: ModelCatalog = { list: async () => [entry], resolve: async () => entry, find: async () => entry, estimate: async () => undefined,
  register: async () => { throw new Error("unused"); }, download: async () => { throw new Error("unused"); } };

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

test("activation refuses what these hosts do not serve yet, stopping what it activated", async () => {
  const services = createHostServices({ catalog }), events: string[] = [];
  const loaded = await activateModules([module({}, events)], services);
  await loaded.stop();
  expect(events).toEqual(["module stop"]);
  events.length = 0;
  await expect(activateModules([module({ sockets: [{ id: "live", path: "/live", summary: "" }], activate: () => ({ sockets: { live: { message() {} } }, dispose() { events.push("module stop"); } }) })],
    services)).rejects.toThrow("this host does not serve socket /api/echo/live yet");
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
