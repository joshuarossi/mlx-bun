// Every default location the app writes. Everything lives under one root,
// `MLX_BUN_HOME` (default `~/.mlx-bun`); the Hugging Face hub cache holds
// downloads only. Explicit user paths (flags, request fields, composition
// options) always win over these defaults. Nothing is resolved at module load:
// MLX_BUN_HOME comes from the runtime configuration and HOME from the
// environment on each call (Bun's os.homedir() keeps the startup HOME).
import { homedir } from "node:os";
import { basename, join, resolve } from "node:path";
import { Registry } from "@mlx-bun/hub/registry";
import { isDrafterModelType } from "@mlx-bun/inference/models/support";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";

/** The layout under the root, one entry per owner. */
const LAYOUT = {
  models: "models", // convert, web quantize and fuse outputs: plain model directories
  adapters: "adapters", // train, web fine-tune, merge, memory-stage adapters
  exports: "exports", // adapter export manifests
  datasets: "datasets",
  jobsDb: "db/jobs.sqlite",
  registryDb: "db/registry.sqlite", // derived model index; rebuilt by scan
  memoryDb: "db/memory.sqlite",
  jobLogs: "jobs",
  wiki: "wiki",
  sessions: "sessions",
  piSessions: "pi-sessions",
  skills: "skills",
  logs: "logs",
  credentials: "hf.json",
  toolApprovals: "tool-approvals.json",
} as const;
export type StorageEntry = keyof typeof LAYOUT;

/** The user's home directory, from HOME when set. */
export function userHome(env: Record<string, string | undefined> = process.env): string {
  return env.HOME || homedir();
}

/** The root of everything mlx-bun writes by default: MLX_BUN_HOME, else `<home>/.mlx-bun`. */
export function mlxBunHome(home: string = userHome()): string {
  const configured = runtimeValue("MLX_BUN_HOME");
  return configured ? resolve(configured) : join(home, ".mlx-bun");
}

/** A default location under `root` (the app's home unless a composition supplies one). */
export function storagePath(entry: StorageEntry, root: string = mlxBunHome()): string {
  return join(root, LAYOUT[entry]);
}

/** Adapter stores earlier versions wrote; listed read-only, never written or moved. */
export function legacyAdapterDirs(home: string = userHome()): string[] {
  return [join(home, ".cache/mlx-bun/adapters"), join(home, ".cache/mlx-bun/mlx-bun-finetunes"), join(home, ".cache/mlx-bun-finetunes")];
}

/** A model's short name for derived output directories: the repo name of an
 * `org/name` id or a hub snapshot path, else the directory's basename. */
export function modelShortName(model: string): string {
  const snapshot = /models--[^/]+?--([^/]+)\/snapshots\//.exec(model);
  const name = snapshot ? snapshot[1]! : basename(model.replace(/\/+$/, ""));
  return name.replace(/[^\w.-]/g, "") || "model";
}

/** The model index over the hub cache and the app's own model directory. */
export function openRegistry(root: string = mlxBunHome()): Registry {
  return new Registry(storagePath("registryDb", root),
    { modelDirs: [storagePath("models", root)], isCompanion: isDrafterModelType });
}
