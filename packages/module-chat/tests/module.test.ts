// The module as a host loads it: a valid manifest, its routes, storage entries and root-mounted socket, and a real chat
// end to end on a real listener with the real Pi SDK: the model is scripted behind a scripted model host, and a tool
// another module contributes through the registry is called and answered. Nothing here loads a model or native code.
import { afterEach, beforeEach, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { AppModule } from "@mlx-bun/app-core";
import { checkManifests, loadModules, type LoadedModules } from "@mlx-bun/app-host";
import { createModuleRoutes, createModuleSockets, createStorage, type ModuleSocketData } from "@mlx-bun/app-services";
import chat, { createChatModule } from "../src/index";
import { manifest } from "../src/manifest";
import type { ClientMessage, ServerMessage } from "../src/protocol";
import { scriptedModel, type ScriptedModel } from "./model";

let home = "", cwd = "";
beforeEach(() => { home = mkdtempSync(join(tmpdir(), "mlx-chat-module-")); cwd = join(home, "project"); mkdirSync(cwd); });
afterEach(() => { rmSync(home, { recursive: true, force: true }); });

const notes: AppModule<"registry"> = {
  id: "notes", title: "Notes", summary: "Offers a chat tool.", requires: ["registry"], contributes: ["chat.tool", "chat.guidance"],
  activate({ services }) {
    services.registry.register("chat.tool", { name: "note_read", description: "Read a note by key", parameters: { type: "object", properties: { key: { type: "string" } }, required: ["key"] },
      readOnly: true, run: async args => `value of ${String(args.key)}` });
    services.registry.register("chat.guidance", { hint: () => "\nThe user keeps notes; read them with note_read." });
    return {};
  },
};

async function host(model: ScriptedModel, options: Parameters<typeof createChatModule>[0] = {}) {
  const loaded = await loadModules([createChatModule({ cwd, ...options }), notes], { services: { modelHost: () => model, storage: createStorage(() => home) } });
  const sockets = createModuleSockets(loaded.sockets), routes = createModuleRoutes(loaded.routes);
  const server = Bun.serve<ModuleSocketData>({ hostname: "127.0.0.1", port: 0, websocket: sockets.websocket,
    async fetch(request, listener) { return sockets.upgrade(request, listener) ?? await routes.handle(request) ?? new Response("not found", { status: 404 }); } });
  return { loaded, server, url: (path: string) => new URL(path, server.url).href };
}

/** A browser tab: frames received, and helpers to wait on them. */
function tab(base: string) {
  const frames: ServerMessage[] = [];
  const socket = new WebSocket(new URL("/ws/chat", base).href.replace("http:", "ws:"));
  const observers = new Set<() => void>();
  socket.onmessage = event => { frames.push(JSON.parse(event.data)); for (const check of [...observers]) check(); };
  const closed = new Promise<{ code: number }>(resolve => { socket.onclose = event => resolve({ code: event.code }); });
  return { frames, socket, closed,
    send: (message: ClientMessage) => socket.send(JSON.stringify(message)),
    waitFor: (predicate: () => boolean, what: string) => new Promise<void>((resolve, reject) => {
      const timer = setTimeout(() => { observers.delete(check); reject(new Error(`timed out waiting for ${what}`)); }, 15_000);
      const check = () => { if (predicate()) { clearTimeout(timer); observers.delete(check); resolve(); } };
      observers.add(check); check();
    }),
    of: <T extends ServerMessage["type"]>(type: T) => frames.filter((frame): frame is Extract<ServerMessage, { type: T }> => frame.type === type) };
}

test("the manifest is valid for a host that implements modelHost and storage, and says what it mounts, stores and shows", () => {
  expect(chat.requires).toEqual(["modelHost", "storage", "registry"]);
  expect(checkManifests([chat], { provided: ["modelHost", "storage"] })).toEqual([]);
  expect(checkManifests([chat], { provided: ["modelHost"] })).toEqual(['module "chat": requires "storage", which this host does not implement']);
  expect(manifest.routes.map(route => `${route.method} ${route.path}`)).toEqual(["GET /api/sessions/search", "GET /api/sessions/export", "GET /api/settings/tool-approvals", "DELETE /api/settings/tool-approvals"]);
  expect(manifest.sockets).toEqual([{ id: "chat", path: "/ws/chat", summary: expect.any(String), mount: "root" }]);
  expect(manifest.storage.map(entry => [entry.key, entry.path, entry.kind])).toEqual([["sessions", "sessions", "directory"], ["agent", "pi-sessions", "directory"], ["approvals", "tool-approvals.json", "file"]]);
  expect(chat.panel).toEqual({ tag: "mlx-chat-panel", entry: "@mlx-bun/module-chat/panel", title: "Chat", path: "/chat", workspace: true });
});

test("activation mounts the declared routes and socket at their shipped paths and touches no storage until something uses it", async () => {
  const asked: string[] = [];
  const storage = createStorage(() => home);
  const loaded = await loadModules([chat], { services: { modelHost: () => scriptedModel(),
    storage: scope => { const service = storage(scope); return { path: key => { asked.push(key); return service.path(key); } }; } } });
  try {
    expect(loaded.routes.map(route => [route.spec.method, route.path])).toEqual([["GET", "/api/sessions/search"], ["GET", "/api/sessions/export"], ["GET", "/api/settings/tool-approvals"], ["DELETE", "/api/settings/tool-approvals"]]);
    expect(loaded.sockets.map(socket => socket.path)).toEqual(["/ws/chat"]);
    expect(loaded.storage.map(entry => entry.path)).toEqual(["sessions", "pi-sessions", "tool-approvals.json"]);
    expect(asked).toEqual([]);
    expect(readdirSync(home)).toEqual(["project"]);
  } finally { await loaded.stop(); }
});

test("a chat round trip: ready from the model host's wire, a prompt, a read-only tool another module contributed, its answer streamed, and the saved chat reopened with the same transcript", async () => {
  const model = scriptedModel("org/scripted");
  Object.assign(model.row, { thinking: undefined, reasoning: true, capabilities: { transcription: true } });
  model.script.push({ tool: { name: "note_read", args: { key: "a" } } }, { text: "The note says: value of a" });
  const { loaded, server, url } = await host(model);
  const first = tab(server.url.href);
  try {
    await first.waitFor(() => first.of("sessions").length > 0, "the first chat's start-up frames");
    expect(first.of("ready")[0]).toEqual({ type: "ready", model: "org/scripted", vision: false, audio: false, thinking: true, transcription: true,
      genDefaults: { temperature: 0.7, topP: 0.9, topK: null } });
    first.send({ type: "prompt", text: "What does note a say?" });
    await first.waitFor(() => first.of("turn_end").length === 2, "both turns (the tool call, then the answer)");
    // The tool ran without asking (it attested it only reads), with the arguments the model chose.
    expect(first.of("tool_approval_request")).toEqual([]);
    expect(first.of("tool_start").map(frame => [frame.tool, frame.args])).toEqual([["note_read", { key: "a" }]]);
    expect(first.of("tool_end")).toMatchObject([{ ok: true, result: { content: [{ type: "text", text: "value of a" }] } }]);
    expect(first.of("text_delta").map(frame => frame.delta).join("")).toBe("The note says: value of a");
    expect(first.of("error")).toEqual([]);
    // The model saw its own alias, the contributed tool and its guidance in the prompt; the second request carries the tool's result.
    expect(model.requests).toHaveLength(2);
    const request = model.requests[0]!.body as { model: string; messages: { role: string; content: unknown }[]; tools: { function: { name: string } }[] };
    expect(request.model).toBe("local");
    expect(request.tools.map(item => item.function.name)).toContain("note_read");
    expect(JSON.stringify(request.messages)).toContain("The user keeps notes; read them with note_read.");
    expect(JSON.stringify(request.messages)).toContain("`org/scripted`");
    expect(JSON.stringify((model.requests[1]!.body as { messages: unknown[] }).messages)).toContain("value of a");
    expect(model.held).toBe(0);

    // The saved chat is on disk under the module's storage entry and the routes read it.
    const path = first.of("sessions").at(-1)!.activePath!;
    expect(path.startsWith(join(home, "sessions"))).toBe(true);
    expect(existsSync(join(home, "pi-sessions"))).toBe(true);
    const exported = await (await fetch(url(`/api/sessions/export?${new URLSearchParams({ path })}`))).json() as { ok: boolean; entries: unknown[] };
    expect(exported.ok).toBe(true); expect(JSON.stringify(exported.entries)).toContain("value of a");
    const found = await (await fetch(url("/api/sessions/search?q=note"))).json() as { results: { sessionPath: string }[] };
    expect(found.results.map(result => result.sessionPath)).toEqual([path]);

    // A second tab starts its own chat, lists the first, and reopening it replays the same transcript.
    const second = tab(server.url.href);
    await second.waitFor(() => second.of("sessions").length > 0, "the second chat's start-up frames");
    expect(second.of("sessions")[0]!.items.map(item => item.path)).toContain(path);
    second.send({ type: "open_session", path });
    await second.waitFor(() => second.of("history").length === 2, "the reopened history");
    expect(second.of("history")[1]!.items).toMatchObject([
      { role: "user", text: "What does note a say?", tools: [] },
      { role: "assistant", tools: [{ name: "note_read", args: { key: "a" }, result: "value of a" }] },
      { role: "assistant", text: "The note says: value of a", tools: [] },
    ]);
    second.socket.close(); first.socket.close();
  } finally {
    await loaded.stop(); await server.stop(true);
  }
  expect(model.held).toBe(0);
}, 30_000);

test("stopping the module closes its sockets with 1001 and the loopback the Pi SDK used, and a chat that cannot start reports why and closes", async () => {
  const model = scriptedModel();
  const { loaded, server } = await host(model);
  const open = tab(server.url.href);
  try {
    expect(loaded.status("chat")).toEqual({ chats: 0, loopback: false }); // the loopback starts with the first chat
    await open.waitFor(() => open.of("ready").length > 0, "ready");
    expect(loaded.status("chat")).toEqual({ chats: 1, loopback: true });
    const closing = loaded.stop();
    expect((await open.closed).code).toBe(1001);
    await closing;
    expect(loaded.status("chat")).toBeUndefined();
    // With no model served, a new chat fails at start-up: the error frame, then a 1011 close.
    model.current = undefined;
    const { loaded: again, server: other } = await host(model);
    const failing = tab(other.url.href);
    await failing.waitFor(() => failing.of("error").length > 0, "the start-up error");
    expect(failing.of("error")[0]!.message).toBe("no model is served");
    expect((await failing.closed).code).toBe(1011);
    await again.stop(); await other.stop(true);
  } finally { await loaded.stop(); await server.stop(true); }
});

test("a read-only host: the chat starts with the policy on and denies what would change state", async () => {
  const model = scriptedModel();
  model.script.push({ tool: { name: "bash", args: { command: "touch x" } } }, { text: "done" });
  const { loaded, server } = await host(model, { readOnly: true });
  const client = tab(server.url.href);
  try {
    await client.waitFor(() => client.of("ready").length > 0, "ready");
    client.send({ type: "set_coding_tools", enabled: true });
    client.send({ type: "prompt", text: "make a file" });
    await client.waitFor(() => client.of("turn_end").length >= 1, "a turn");
    // A read-only server never advertises file-changing tools, so the model has none of them to call.
    expect((model.requests[0]!.body as { tools?: { function: { name: string } }[] }).tools?.map(tool => tool.function.name) ?? []).not.toContain("bash");
    expect(client.of("tool_approval_request")).toEqual([]);
    client.socket.close();
  } finally { await loaded.stop(); await server.stop(true); }
}, 30_000);

export type { LoadedModules };
