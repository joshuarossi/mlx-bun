import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { checkManifests, loadModules } from "@mlx-bun/app-host";
import { createModuleRoutes, createStorage } from "@mlx-bun/app-services";
import memory, { createMemoryModule } from "../src";

const get = (path: string) => new Request("http://test" + path);
test("the complete memory module needs only storage and registry", () => {
  expect(checkManifests([memory], { provided: ["storage", "registry"] })).toEqual([]);
  expect(memory.panel?.overlay).toBe(true);
});
for (const override of [false, true]) test(`activation and status preserve an absent ${override ? "explicit" : "default"} vault until init`, async () => {
  const home = mkdtempSync(join(tmpdir(), "memory-module-"));
  const vault = join(home, override ? "elsewhere/wiki" : "wiki");
  let calls = 0;
  const loaded = await loadModules([createMemoryModule({ client: () => { calls++; throw new Error("unused"); } })], {
    services: { storage: createStorage(() => home, override ? { "memory.vault": vault } : {}) },
  });
  const routes = createModuleRoutes(loaded.routes);
  try {
    expect(existsSync(vault)).toBe(false);
    expect(existsSync(join(home, "skills"))).toBe(false);
    expect(existsSync(join(home, "db"))).toBe(false);
    const status = await (await routes.handle(get("/api/memory/status")))!.json();
    expect(status).toMatchObject({ ok: false, enabled: false, root: vault });
    expect(existsSync(vault)).toBe(false);
    expect(loaded.registry.list("chat.tool")).toHaveLength(12);
    const tool = loaded.registry.list("chat.tool")[0]!.contribution;
    expect(await tool.available?.()).toBe(false);
    const init = await (await routes.handle(new Request("http://test/api/memory/init", { method: "POST" })))!.json();
    expect(init.ok).toBe(true);
    expect(existsSync(vault)).toBe(true);
    expect(await tool.available?.()).toBe(true);
    expect(calls).toBe(0);
    expect(existsSync(join(home, "db"))).toBe(false);
  } finally { await loaded.stop(); rmSync(home, { recursive: true, force: true }); }
});
