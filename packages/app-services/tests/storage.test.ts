import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { AppModule } from "@mlx-bun/app-core";
import { createStorage } from "../src";

test("a module resolves only the entries it declared, and each is created under the root on first use", () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-storage-"));
  try {
    const manifest = { id: "notes", storage: [
      { key: "dir", path: "notes/files", kind: "directory", purpose: "attachments" },
      { key: "db", path: "db/notes.sqlite", kind: "sqlite", purpose: "index" },
    ] } as unknown as AppModule;
    const storage = createStorage(() => root)({ moduleId: "notes", manifest });
    expect(existsSync(join(root, "notes"))).toBe(false);
    expect(storage.path("dir")).toBe(join(root, "notes/files"));
    expect(statSync(join(root, "notes/files")).isDirectory()).toBe(true);
    expect(storage.path("db")).toBe(join(root, "db/notes.sqlite"));
    expect(statSync(join(root, "db")).isDirectory()).toBe(true);
    expect(existsSync(join(root, "db/notes.sqlite"))).toBe(false);
    expect(() => storage.path("other")).toThrow('module notes declared no storage entry "other"');
  } finally { rmSync(root, { recursive: true, force: true }); }
});
