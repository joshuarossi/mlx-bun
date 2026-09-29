import { expect, test } from "bun:test";
import type { AppEvent, AppModule, CliInvocation, EventBus, ExtensionPointId, ModuleContext, ModuleRuntime, Registration, Registry, StorageService } from "@mlx-bun/app-core";

// A module reaches the host only through its context, so a fake context that
// implements two core services is enough to run a module end to end.
const manifest = {
  id: "echo",
  title: "Echo",
  summary: "Counts pings.",
  requires: ["events", "storage"],
  routes: [{ id: "count", method: "GET", path: "/count", summary: "Pings seen", response: "json" }],
  verbs: [{ name: "echo-ping", summary: "Publish one ping", options: [] }],
  storage: [{ key: "state", path: "echo/state.json", kind: "file", purpose: "Last count" }],
  panel: { tag: "mlx-echo-panel", entry: "@mlx-bun/module-echo/panel", title: "Echo", path: "/echo" },
  activate(context) {
    let pings = 0;
    context.services.events.subscribe(["echo.ping"], () => { pings++; });
    // @ts-expect-error a module cannot reach a service it did not require
    void context.services.jobs;
    return {
      routes: { count: () => Response.json({ pings, state: context.services.storage.path("state") }) },
      verbs: {
        "echo-ping": async (invocation: CliInvocation) => {
          context.services.events.publish({ type: "echo.ping", at: 0 });
          invocation.stdout("pinged\n");
          return 0;
        },
      },
    };
  },
} satisfies AppModule<"events" | "storage">;

function fakeEvents(): EventBus {
  const handlers: ((event: AppEvent) => void)[] = [];
  return {
    publish: event => { for (const handler of handlers) handler(event); },
    subscribe: (types, handler) => {
      const filtered = (event: AppEvent) => { if (types === "*" || types.includes(event.type)) handler(event); };
      handlers.push(filtered);
      return () => { handlers.splice(handlers.indexOf(filtered), 1); };
    },
  };
}

test("a manifest activates against only its required services and serves its declared route and verb", async () => {
  const storage: StorageService = { path: key => `/home/${key}` };
  const context: ModuleContext<"events" | "storage"> = {
    moduleId: manifest.id, services: { events: fakeEvents(), storage }, signal: new AbortController().signal,
  };
  const runtime: ModuleRuntime = await manifest.activate(context);
  expect(Object.keys(runtime.routes!)).toEqual(manifest.routes.map(route => route.id));
  expect(Object.keys(runtime.verbs!)).toEqual(manifest.verbs.map(verb => verb.name));
  let output = "";
  const invocation: CliInvocation = { values: {}, stdout: text => { output += text; }, stderr: () => {}, signal: context.signal };
  expect(await runtime.verbs!["echo-ping"]!(invocation)).toBe(0);
  expect(output).toBe("pinged\n");
  const response = await runtime.routes!.count!(new Request("http://host/api/echo/count"));
  expect(await response.json()).toEqual({ pings: 1, state: "/home/state" });
});

function fakeRegistry(source: string): Registry {
  const entries: Registration[] = [];
  return {
    register: (point, contribution) => {
      const entry = { point, source, contribution } as Registration;
      entries.push(entry);
      return () => { entries.splice(entries.indexOf(entry), 1); };
    },
    list: <P extends ExtensionPointId>(point: P) => entries.filter((entry): entry is Registration<P> => entry.point === point),
    onChange: () => () => {},
  };
}

// A contributor and a consumer share only the registry; neither names the other.
const contributor = {
  id: "notes", title: "Notes", summary: "Offers a chat tool.", requires: ["registry"], contributes: ["chat.tool"],
  activate(context) {
    context.services.registry.register("chat.tool", { name: "note", description: "Save a note", parameters: { type: "object" }, run: async () => "saved" });
    return {};
  },
} satisfies AppModule<"registry">;

/** Compile-time checks: a contribution must match its point, and only declared points exist. */
export function typedPoints(registry: Registry) {
  // @ts-expect-error a chat tool's shape is not a navigation entry's
  registry.register("chat.tool", { label: "Notes", path: "/notes" });
  // @ts-expect-error only declared extension points exist
  registry.register("chat.unknown", {});
  // @ts-expect-error a listed contribution has its point's type
  return registry.list("shell.nav").map(entry => entry.contribution.name);
}

test("a contribution registered through the registry is listed by a consumer that never names the contributor", async () => {
  const registry = fakeRegistry(contributor.id);
  const signal = new AbortController().signal;
  await contributor.activate({ moduleId: "notes", services: { registry }, signal });
  const consumer: AppModule<"registry"> = {
    id: "chat", title: "Chat", summary: "Lists tools.", requires: ["registry"],
    activate: (context: ModuleContext<"registry">) => ({
      routes: { tools: () => Response.json(context.services.registry.list("chat.tool").map(entry => [entry.source, entry.contribution.name])) },
    }),
  };
  const runtime = await consumer.activate({ moduleId: "chat", services: { registry }, signal });
  const response = await runtime.routes!.tools!(new Request("http://host/api/chat/tools"));
  expect(await response.json()).toEqual([["notes", "note"]]);
});
