// The module as a host loads it: a valid manifest that needs only `modelHost`
// and `catalog`, its route mounted at the root, its verb dispatched with what
// the host parsed, cancellation, and a stop that cancels and joins the
// generations in flight before the host releases the models.
import { expect, test } from "bun:test";
import { checkManifests, loadModules, type RegisteredVerb } from "@mlx-bun/app-host";
import { createModuleRoutes, parseVerb, plainTerminal } from "@mlx-bun/app-services";
import images, { createImagesModule } from "../src/index";
import { manifest } from "../src/manifest";
import { fakeCatalog, fakeHost, fakeOperation, MODEL_ID } from "./support";

function bindings(input: Parameters<typeof fakeOperation>[0] = {}) {
  const { operation } = fakeOperation(input);
  const { host, events, held } = fakeHost(operation, { defaultId: MODEL_ID });
  return { events, held, services: { modelHost: () => host, catalog: () => fakeCatalog() } };
}

const invoke = (verb: RegisteredVerb, argv: string[], signal: AbortSignal, stdout: (text: string) => void = () => {}) =>
  ({ ...parseVerb("mlx-bun", verb.spec, argv), signal, stdout, stderr: () => {}, terminal: plainTerminal(() => {}) });

test("the manifest is valid for a host that implements modelHost and catalog, and declares nothing else", () => {
  expect(images.id).toBe("images");
  expect(images.requires).toEqual(["modelHost", "catalog"]);
  expect(checkManifests([images], { provided: ["modelHost", "catalog"] })).toEqual([]);
  expect(checkManifests([images], { provided: ["modelHost"] })).toEqual(['module "images": requires "catalog", which this host does not implement']);
  expect(checkManifests([images], { provided: ["modelHost", "catalog"], reserved: [{ method: "POST", path: "/v1/images/generations" }] }))
    .toEqual(['module "images": route "generations" POST /v1/images/generations collides with the host']);
  expect([images.jobs ?? [], images.storage ?? [], images.sockets ?? [], images.panel ?? null]).toEqual([[], [], [], null]);
  expect(images.placement).toBeUndefined();
  expect(manifest.verbs.map(verb => verb.name)).toEqual(["image"]);
});

test("activated, it serves its route at the root and generates through the verb", async () => {
  const { services, events, held } = bindings();
  const written: string[] = [], printed: string[] = [];
  const loaded = await loadModules([createImagesModule({ verb: { writeFile: async path => { written.push(path); } } })], { services });
  try {
    expect(loaded.routes.map(route => `${route.spec.method} ${route.path}`)).toEqual(["POST /v1/images/generations"]);
    expect([...loaded.verbs.keys()]).toEqual(["image"]);
    const verb = loaded.verbs.get("image")!;
    expect(await verb.handler(invoke(verb, ["a cat", "--out", "/tmp/cat.png", "--seed", "3"], new AbortController().signal, text => { printed.push(text); }))).toBe(0);
    expect([written, printed]).toEqual([["/tmp/cat.png"], ["/tmp/cat.png\n"]]);
    const routes = createModuleRoutes(loaded.routes);
    const response = (await routes.handle(new Request("http://localhost/v1/images/generations", { method: "POST", body: JSON.stringify({ prompt: "a cat" }) })))!;
    expect(response.status).toBe(200);
    expect((await response.json()).mlx_bun.model).toBe(MODEL_ID);
    expect(await routes.handle(new Request("http://localhost/v1/models"))).toBeNull();
    expect(events).toEqual([`acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`, `acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`]);
    expect(held()).toBe(0);
  } finally { await loaded.stop(); }
});

test("a cancelled verb rejects with its own message and releases the lease", async () => {
  const started = Promise.withResolvers<void>();
  const { services, held } = bindings({ generate: async (_request, options) => {
    started.resolve();
    return new Promise((_, reject) => options!.signal!.addEventListener("abort", () => reject(options!.signal!.reason), { once: true }));
  } });
  const loaded = await loadModules([createImagesModule({ verb: { writeFile: async () => { throw new Error("nothing is written"); } } })], { services });
  try {
    const verb = loaded.verbs.get("image")!, abort = new AbortController();
    const run = verb.handler(invoke(verb, ["a cat"], abort.signal));
    await started.promise;
    abort.abort(new Error("image cancelled"));
    await expect(run).rejects.toThrow("image generation cancelled");
    expect(held()).toBe(0);
  } finally { await loaded.stop(); }
});

test("stopping the module cancels a generation in flight and joins it, so its lease is back first", async () => {
  const started = Promise.withResolvers<void>();
  const { services, held } = bindings({ generate: async (_request, options) => {
    started.resolve();
    return new Promise((_, reject) => options!.signal!.addEventListener("abort", () => reject(options!.signal!.reason), { once: true }));
  } });
  const loaded = await loadModules([images], { services });
  const response = createModuleRoutes(loaded.routes).handle(new Request("http://localhost/v1/images/generations", { method: "POST", body: JSON.stringify({ prompt: "x" }) }));
  await started.promise;
  expect(held()).toBe(1);
  await loaded.stop();
  expect(held()).toBe(0);
  const answered = (await response)!;
  expect([answered.status, (await answered.json()).error.type]).toEqual([503, "server_closing"]);
});
