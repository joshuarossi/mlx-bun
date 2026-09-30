import { homedir } from "node:os";
import { join, resolve } from "node:path";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";

/** Standalone domain defaults; hosts supply explicit module storage paths. */
export const userHome = (): string => process.env.HOME || homedir();
export function mlxBunHome(home = userHome()): string {
  const configured = runtimeValue("MLX_BUN_HOME");
  return configured ? resolve(configured) : join(home, ".mlx-bun");
}
const entries = { wiki: "wiki", skills: "skills", memoryDb: "db/memory.sqlite", adapters: "adapters", logs: "logs" } as const;
export const storagePath = (entry: keyof typeof entries, root = mlxBunHome()): string => join(root, entries[entry]);
