// What other modules contribute to a chat, read back from the registry when a session is built: only tools that attest
// they read state, only while they say they are available, with the guidance that goes with them.
import { expect, test } from "bun:test";
import type { AppModule } from "@mlx-bun/app-core";
import { loadModules } from "@mlx-bun/app-host";
import { createExtensionSurface, piTool } from "../src/extensions";

const tool = (name: string, extra: object = {}) => ({ name, description: `the ${name} tool`, parameters: { type: "object", properties: { key: { type: "string" } }, required: ["key"] },
  readOnly: true as const, run: async (args: Readonly<Record<string, unknown>>) => `${name}:${String(args.key)}`, ...extra });
const contributor = (id: string, register: (registry: import("@mlx-bun/app-core").Registry) => void): AppModule<"registry"> =>
  ({ id, title: id, summary: id, requires: ["registry"], contributes: ["chat.tool", "chat.guidance"], activate: ({ services }) => { register(services.registry); return {}; } });

test("nothing contributed means no surface; tools, skills and hints appear when contributors register, in registration order", async () => {
  const loaded = await loadModules([contributor("notes", registry => {
    registry.register("chat.tool", tool("note_read")); registry.register("chat.tool", tool("note_list", { label: "List notes" }));
    registry.register("chat.guidance", { hint: () => "\nNotes are on.", skillPath: () => "/skills/notes" });
  }), contributor("other", registry => {
    registry.register("chat.tool", tool("other_get"));
    registry.register("chat.guidance", { hint: () => "\nOther is on.", skillPath: () => "/skills/notes" });
  })], { services: {} });
  try {
    expect(await createExtensionSurface({ list: () => [] })()).toBeUndefined();
    const surface = (await createExtensionSurface(loaded.registry)())!;
    expect(surface.readOnly).toBe(true);
    expect(surface.toolNames).toEqual(["note_read", "note_list", "other_get"]);
    expect(surface.customTools.map(item => [item.name, item.label])).toEqual([["note_read", "note_read"], ["note_list", "List notes"], ["other_get", "other_get"]]);
    expect(surface.skillPaths).toEqual(["/skills/notes"]); // the same skill from two contributors once
    expect(surface.hint).toBe("\nNotes are on.\nOther is on.");
  } finally { await loaded.stop(); }
});

test("a tool that is not available, one that throws asking, and guidance that is not available are left out of that session and back in the next", async () => {
  let notes = false, broken = true;
  const loaded = await loadModules([contributor("notes", registry => {
    registry.register("chat.tool", tool("note_read", { available: () => notes }));
    registry.register("chat.tool", tool("note_flaky", { available: () => { if (broken) throw new Error("vault unreadable"); return true; } }));
    registry.register("chat.tool", tool("note_always"));
    registry.register("chat.guidance", { available: async () => notes, hint: () => "\nNotes.", skillPath: () => "/skills/notes" });
  })], { services: {} });
  try {
    const surface = createExtensionSurface(loaded.registry);
    const first = (await surface())!;
    expect([first.toolNames, first.skillPaths, first.hint]).toEqual([["note_always"], [], ""]);
    notes = true; broken = false;
    const second = (await surface())!;
    expect([second.toolNames, second.skillPaths, second.hint]).toEqual([["note_read", "note_flaky", "note_always"], ["/skills/notes"], "\nNotes."]);
  } finally { await loaded.stop(); }
});

test("a tool that does not attest it only reads state is never offered", async () => {
  const registry = { list: () => [{ point: "chat.tool", source: "risky", contribution: { ...tool("risky_write"), readOnly: false } }] };
  expect(await createExtensionSurface(registry as never)()).toBeUndefined();
});

test("a contributed tool runs as a Pi tool: the same arguments in, its text out as the result, the turn's signal passed on", async () => {
  const seen: { args: unknown; aborted: boolean }[] = [];
  const definition = piTool(tool("note_read", { run: async (args: unknown, signal: AbortSignal) => { seen.push({ args, aborted: signal.aborted }); return "the note"; } }));
  const controller = new AbortController();
  const result = await definition.execute("call-1", { key: "a" } as never, controller.signal, undefined, undefined as never);
  expect(result).toEqual({ content: [{ type: "text", text: "the note" }], details: {} });
  controller.abort();
  await definition.execute("call-2", { key: "b" } as never, controller.signal, undefined, undefined as never);
  expect(seen).toEqual([{ args: { key: "a" }, aborted: false }, { args: { key: "b" }, aborted: true }]);
  // Without a signal from the SDK the tool still gets one.
  await definition.execute("call-3", { key: "c" } as never, undefined as never, undefined, undefined as never);
  expect(seen[2]).toEqual({ args: { key: "c" }, aborted: false });
});
