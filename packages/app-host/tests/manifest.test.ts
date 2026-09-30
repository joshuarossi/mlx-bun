import { expect, test } from "bun:test";
import { checkManifests } from "@mlx-bun/app-host";
import { module } from "./fixtures";

const options = { provided: ["events", "storage"] as const };
const route = (id: string, path: string, extra: object = {}) => ({ id, method: "GET" as const, path, summary: id, response: "json" as const, ...extra });
const verb = (name: string) => ({ name, summary: name, options: [] });
const job = (kind: string) => ({ kind, isolation: "task" as const, gpu: "none" as const });
const entry = (key: string, path: string) => ({ key, path, kind: "file" as const, purpose: key });

test("a well-formed set of modules has no problems", () => {
  expect(checkManifests([
    module("alpha", { requires: ["events", "storage"], routes: [route("a", "/a")], verbs: [verb("alpha-run")], jobs: [job("alpha.run")],
      storage: [entry("state", "alpha/state.json"), entry("cache", "alpha/cache")], panel: { tag: "mlx-alpha-panel", entry: "x", title: "A", path: "/alpha" } }),
    module("beta-two", { routes: [route("a", "/a"), route("wire", "/v1/beta", { mount: "root" })], verbs: [verb("beta")], jobs: [job("beta.run")], storage: [entry("state", "beta/state.json")] }),
  ], options)).toEqual([]);
});

test("duplicate module ids are rejected", () => {
  expect(checkManifests([module("alpha"), module("alpha")], options)).toEqual(['module "alpha": duplicate module id']);
});

test("module ids must be kebab-case, so they are safe route prefixes", () => {
  expect(checkManifests([module("Alpha"), module("a/b"), module("a_b")], options)).toHaveLength(3);
});

test("duplicate routes are rejected across modules by method and path shape, and against the host's own routes", () => {
  const problems = checkManifests([
    module("alpha", { routes: [route("x", "/items/:id")] }),
    module("beta", { routes: [route("x", "/x"), route("y", "/x/"), route("z", "/v1/thing", { mount: "root" })] }),
    module("gamma", { routes: [route("z", "/v1/thing", { mount: "root" }), route("host", "/health", { mount: "root" })] }),
    module("delta", { routes: [route("m", "/x", { method: "POST" }), route("n", "/w")], sockets: [{ id: "s", path: "/w", summary: "s" }] }),
  ], { ...options, reserved: [{ method: "GET", path: "/health" }] });
  expect(problems).toEqual([
    'module "beta": route "y" GET /api/beta/x/ collides with route "x" of module beta',
    'module "gamma": route "z" GET /v1/thing collides with route "z" of module beta',
    'module "gamma": route "host" GET /health collides with the host',
    'module "delta": socket "s" GET /api/delta/w collides with route "n" of module delta',
  ]);
});

test("the same relative path in different modules does not collide, and a parameter name does not distinguish two routes", () => {
  expect(checkManifests([module("alpha", { routes: [route("x", "/x")] }), module("beta", { routes: [route("x", "/x")] })], options)).toEqual([]);
  expect(checkManifests([module("alpha", { routes: [route("a", "/i/:id"), route("b", "/i/:name")] })], options))
    .toEqual(['module "alpha": route "b" GET /api/alpha/i/:name collides with route "a" of module alpha']);
});

test("a module route whose full path equals another module's root route collides", () => {
  expect(checkManifests([
    module("alpha", { routes: [route("x", "/items")] }),
    module("beta", { routes: [route("y", "/api/alpha/items", { mount: "root" })] }),
  ], options)).toHaveLength(1);
});

test("route paths must start with a slash and hold no query or empty segment", () => {
  expect(checkManifests([module("alpha", { routes: [route("a", "x"), route("b", "/x?y"), route("c", "/x//y")] })], options)).toHaveLength(3);
});

test("duplicate route and socket ids within a module are rejected", () => {
  expect(checkManifests([module("alpha", { routes: [route("a", "/a"), route("a", "/b")] })], options)).toEqual(['module "alpha": duplicate route id "a"']);
  expect(checkManifests([module("alpha", { sockets: [{ id: "s", path: "/a", summary: "" }, { id: "s", path: "/b", summary: "" }] })], options))
    .toEqual(['module "alpha": duplicate socket id "s"']);
});

test("duplicate verbs across modules and duplicate options within a verb are rejected", () => {
  expect(checkManifests([module("alpha", { verbs: [verb("run")] }), module("beta", { verbs: [verb("run")] })], options))
    .toEqual(['module "beta": verb "run" is already declared by module alpha']);
  expect(checkManifests([module("alpha", { verbs: [{ name: "run", summary: "", options: [
    { name: "x", type: "string", summary: "" }, { name: "x", type: "boolean", summary: "" }] }] })], options))
    .toEqual(['module "alpha": verb "run" declares an option twice']);
});

test("duplicate job kinds across modules are rejected", () => {
  expect(checkManifests([module("alpha", { jobs: [job("run")] }), module("beta", { jobs: [job("run")] })], options))
    .toEqual(['module "beta": job kind "run" is already declared by module alpha']);
});

test("storage paths are unique across modules regardless of case and never nested in another module's path", () => {
  expect(checkManifests([module("alpha", { storage: [entry("a", "shared/data")] }), module("beta", { storage: [entry("b", "Shared/Data")] })], options))
    .toEqual(['module "beta": storage path "Shared/Data" collides with "shared/data" of module alpha']);
  expect(checkManifests([module("alpha", { storage: [entry("a", "alpha")] }), module("beta", { storage: [entry("b", "alpha/inside")] })], options))
    .toHaveLength(1);
  expect(checkManifests([module("alpha", { storage: [entry("a", "alpha/inside")] }), module("beta", { storage: [entry("b", "alpha")] })], options))
    .toHaveLength(1);
  // A module may nest its own entries, but two keys cannot share one path.
  expect(checkManifests([module("alpha", { storage: [entry("dir", "alpha"), entry("file", "alpha/state.json")] })], options)).toEqual([]);
  expect(checkManifests([module("alpha", { storage: [entry("a", "alpha/x"), entry("b", "alpha/x")] })], options)).toHaveLength(1);
});

test("two modules may share an entry by declaring the same path and kind; anything else on that path still collides", () => {
  const directory = (key: string, path: string) => ({ key, path, kind: "directory" as const, purpose: key });
  expect(checkManifests([module("alpha", { storage: [directory("models", "models")] }), module("beta", { storage: [directory("out", "models")] })], options)).toEqual([]);
  // A different kind on the same path, or a path nested in the shared one, is a collision.
  expect(checkManifests([module("alpha", { storage: [directory("models", "models")] }), module("beta", { storage: [entry("out", "models")] })], options)).toHaveLength(1);
  expect(checkManifests([module("alpha", { storage: [directory("models", "models")] }), module("beta", { storage: [directory("out", "models/fused")] })], options)).toHaveLength(1);
  expect(checkManifests([module("alpha", { storage: [directory("models", "models")] }), module("beta", { storage: [directory("out", "Models")] })], options)).toHaveLength(1);
});

test("storage paths cannot escape the storage root and keys are unique within a module", () => {
  for (const path of ["/etc/passwd", "../out", "a/../../out", "a//b", "./a", "a\\b", ""])
    expect(checkManifests([module("alpha", { storage: [entry("a", path)] })], options)).toHaveLength(1);
  expect(checkManifests([module("alpha", { storage: [entry("a", "alpha/1"), entry("a", "alpha/2")] })], options))
    .toEqual(['module "alpha": duplicate storage key "a"']);
});

test("an unmet or unknown requires is rejected", () => {
  expect(checkManifests([module("alpha", { requires: ["jobs", "catalog"] })], options)).toEqual([
    'module "alpha": requires "jobs", which this host does not implement',
    'module "alpha": requires "catalog", which this host does not implement',
  ]);
  expect(checkManifests([module("alpha", { requires: ["gpu" as never] })], options)).toEqual(['module "alpha": requires unknown service "gpu"']);
});

test("the registry is always available, and contributing to it requires it", () => {
  expect(checkManifests([module("alpha", { requires: ["registry"], contributes: ["chat.tool"] })], options)).toEqual([]);
  expect(checkManifests([module("alpha", { contributes: ["chat.tool"] })], options)).toEqual(['module "alpha": contributes without requiring "registry"']);
});

test("a panel's tag follows the module id and its declared path is safe and unique", () => {
  expect(checkManifests([module("alpha", { panel: { tag: "alpha-panel", entry: "x", title: "A", path: "/../a" } })], options)).toHaveLength(2);
});

test("panels preserve shipped paths while rejecting unsafe and colliding routes", () => {
 const panel = (id: string, path: string) => module(id, { panel: { tag: `mlx-${id}-panel`, entry: "x", title: id, path } });
 expect(checkManifests([panel("train", "/finetune"), panel("datasets", "/dataset")], options)).toEqual([]);
 for (const path of ["/", "/a/b", "/../a", "/A", "/a?b", "/a#b", "/a%2fb"]) expect(checkManifests([panel("alpha", path)], options)).toContain('module "alpha": panel path must be one lowercase kebab-case route');
 expect(checkManifests([panel("alpha", "/shared"), panel("beta", "/shared")], options)).toContain('module "beta": panel path "/shared" collides with module alpha');
});

test("a module's placement is app or model, and nothing else", () => {
  expect(checkManifests([module("alpha", { placement: "app" }), module("beta", { placement: "model" }), module("gamma")], options)).toEqual([]);
  expect(checkManifests([module("alpha", { placement: "everywhere" as never })], options)).toEqual(['module "alpha": placement must be "app" or "model"']);
});
