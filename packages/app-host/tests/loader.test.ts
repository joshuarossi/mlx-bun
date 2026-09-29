import { expect, test } from "bun:test";
import type { AppModule, CliInvocation } from "@mlx-bun/app-core";
import { loadModules, ManifestError } from "@mlx-bun/app-host";
import { fakeServices, module } from "./fixtures";

const ok = () => new Response("ok");
const route = (id: string, path: string, extra: object = {}) => ({ id, method: "GET" as const, path, summary: id, response: "json" as const, ...extra });

test("with no modules the loader does nothing and stops cleanly", async () => {
  const loaded = await loadModules([], { services: {} });
  expect([loaded.routes, loaded.sockets, loaded.storage, [...loaded.verbs], [...loaded.jobs]]).toEqual([[], [], [], [], []]);
  await loaded.stop();
});

test("routes mount under /api/<id>, or at the root when declared, with handlers from activate", async () => {
  const wire = () => new Response("wire");
  const loaded = await loadModules([
    module("alpha", { routes: [route("list", "/items"), route("wire", "/v1/things", { mount: "root" }), route("index", "/")] },
      { routes: { list: ok, wire, index: ok } }),
  ], { services: {} });
  expect(loaded.routes.map(mounted => [mounted.moduleId, mounted.spec.id, mounted.path])).toEqual([
    ["alpha", "list", "/api/alpha/items"], ["alpha", "wire", "/v1/things"], ["alpha", "index", "/api/alpha"],
  ]);
  expect(await (await loaded.routes[1]!.handler(new Request("http://host/v1/things"))).text()).toBe("wire");
});

test("verbs, job runners and storage entries are registered by name, kind and path", async () => {
  const verb = async (_: CliInvocation) => 0;
  const runner = async () => {};
  const loaded = await loadModules([module("alpha", {
    verbs: [{ name: "alpha-run", summary: "", options: [] }],
    jobs: [{ kind: "alpha.run", isolation: "task", gpu: "none" }],
    storage: [{ key: "state", path: "alpha/state.json", kind: "file", purpose: "state" }],
  }, { verbs: { "alpha-run": verb }, jobs: { "alpha.run": runner } })], { services: {} });
  expect(loaded.verbs.get("alpha-run")).toMatchObject({ moduleId: "alpha", handler: verb });
  expect(loaded.jobs.get("alpha.run")).toMatchObject({ moduleId: "alpha", runner, spec: { gpu: "none" } });
  expect(loaded.storage).toEqual([{ moduleId: "alpha", key: "state", path: "alpha/state.json", kind: "file", purpose: "state" }]);
});

test("invalid manifests reject before any module activates", async () => {
  let activated = 0;
  const count = { activate: () => { activated++; return {}; } };
  const promise = loadModules([module("alpha", { ...count, verbs: [{ name: "run", summary: "", options: [] }] }),
    module("beta", { ...count, verbs: [{ name: "run", summary: "", options: [] }] })], { services: {} });
  await expect(promise).rejects.toBeInstanceOf(ManifestError);
  await expect(promise).rejects.toMatchObject({ problems: ['module "beta": verb "run" is already declared by module alpha'] });
  expect(activated).toBe(0);
});

test("a module requiring a service the host does not implement is rejected", async () => {
  await expect(loadModules([module("alpha", { requires: ["jobs"] })], { services: fakeServices() }))
    .rejects.toMatchObject({ problems: ['module "alpha": requires "jobs", which this host does not implement'] });
});

test("a module receives only the services it required, built for it", async () => {
  const asked: string[] = [];
  let seen: string[] = [];
  const loaded = await loadModules([
    module("alpha", { requires: ["storage"], storage: [{ key: "state", path: "alpha/state.json", kind: "file", purpose: "" }],
      activate: context => { seen = Object.keys(context.services); return { routes: {} }; } }),
    module("beta", { requires: ["events"] }),
  ], { services: fakeServices(asked) });
  expect(seen).toEqual(["storage"]);
  expect(asked).toEqual(["storage:alpha", "events:beta"]);
  await loaded.stop();
});

test("a handler the manifest does not declare, or one that is missing, fails activation", async () => {
  await expect(loadModules([module("alpha", { routes: [route("a", "/a")] }, { routes: {} })], { services: {} }))
    .rejects.toThrow("module alpha: activate returned no route handler for a");
  await expect(loadModules([module("alpha", {}, { verbs: { extra: async () => 0 } })], { services: {} }))
    .rejects.toThrow("module alpha: activate returned verb handlers the manifest does not declare: extra");
});

test("a failed activation stops the modules already activated, in reverse order, and drops their registrations", async () => {
  const log: string[] = [];
  const contributor: AppModule<"registry"> = {
    id: "alpha", title: "", summary: "", requires: ["registry"], contributes: ["shell.nav"],
    activate: context => { context.services.registry.register("shell.nav", { label: "A", path: "/a" }); return { dispose: () => { log.push("alpha"); } }; },
  };
  const second = module("beta", {}, { dispose: () => { log.push("beta"); } });
  const failing = module("gamma", { activate: () => { throw new Error("boom"); } });
  await expect(loadModules([contributor, second, failing], { services: {} })).rejects.toThrow("boom");
  expect(log).toEqual(["beta", "alpha"]);
});

test("stop aborts each module's signal, disposes in reverse order once, and reports every failure", async () => {
  const log: string[] = [];
  const signals: AbortSignal[] = [];
  const make = (id: string, fail = false) => module(id, { activate: context => {
    signals.push(context.signal);
    return { dispose: () => { log.push(id); if (fail) throw new Error(`${id} failed`); } };
  } });
  const loaded = await loadModules([make("alpha", true), make("beta"), make("gamma", true)], { services: {} });
  expect(signals.map(signal => signal.aborted)).toEqual([false, false, false]);
  const first = loaded.stop();
  await expect(first).rejects.toMatchObject({ errors: [{ message: "gamma failed" }, { message: "alpha failed" }] });
  expect(signals.map(signal => signal.aborted)).toEqual([true, true, true]);
  expect(loaded.stop()).toBe(first);
  expect(log).toEqual(["gamma", "beta", "alpha"]);
});

test("a contributor's registration is listed by a consumer and removed when the contributor stops; neither names the other", async () => {
  const notes: AppModule<"registry"> = {
    id: "notes", title: "", summary: "", requires: ["registry"], contributes: ["chat.tool"],
    activate: context => {
      context.services.registry.register("chat.tool", { name: "note", description: "", parameters: {}, run: async () => "saved" });
      return {};
    },
  };
  let listed: () => string[] = () => [];
  const chat: AppModule<"registry"> = {
    id: "chat", title: "", summary: "", requires: ["registry"],
    // Activated first: the contributor registers after, and the consumer's view is live.
    activate: context => { listed = () => context.services.registry.list("chat.tool").map(entry => `${entry.source}:${entry.contribution.name}`); return {}; },
  };
  const loaded = await loadModules([chat, notes], { services: {} });
  expect(listed()).toEqual(["notes:note"]);
  expect(loaded.registry.list("chat.tool")).toHaveLength(1);
  await loaded.stop();
  expect(listed()).toEqual([]);
});

test("registering to a point the manifest did not declare throws", async () => {
  const module: AppModule<"registry"> = {
    id: "alpha", title: "", summary: "", requires: ["registry"], contributes: ["shell.nav"],
    activate: context => { context.services.registry.register("chat.tool", { name: "x", description: "", parameters: {}, run: async () => "" }); return {}; },
  };
  await expect(loadModules([module], { services: {} })).rejects.toThrow('module alpha did not declare "chat.tool" in contributes');
});
