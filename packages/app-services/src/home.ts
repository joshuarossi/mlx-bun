// Where mlx-bun keeps what it writes by default: one root, `MLX_BUN_HOME`
// (default `~/.mlx-bun`). Hosts add their own entries beside the model index;
// explicit user paths always win over these defaults. Nothing is resolved at
// module load: MLX_BUN_HOME comes from the runtime configuration and HOME from
// the environment on each call.
import { homedir } from "node:os";
import { join, resolve } from "node:path";
import { Registry } from "@mlx-bun/hub/registry";
import { isDrafterModelType } from "@mlx-bun/inference/models/support";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";

/** The user's home directory, from HOME when set. */
export function userHome(env: Record<string, string | undefined> = process.env): string {
  return env.HOME || homedir();
}

/** The root of everything mlx-bun writes by default: MLX_BUN_HOME, else `<home>/.mlx-bun`. */
export function mlxBunHome(home: string = userHome()): string {
  const configured = runtimeValue("MLX_BUN_HOME");
  return configured ? resolve(configured) : join(home, ".mlx-bun");
}

/** The model index's layout under the root: convert, quantize and fuse outputs, and the derived registry. */
export const MODEL_LAYOUT = {
  models: "models", // plain model directories
  registryDb: "db/registry.sqlite", // derived model index; rebuilt by scan
} as const;

/** The model index over the hub cache and the root's own model directory. */
export function openModelRegistry(root: string = mlxBunHome()): Registry {
  return new Registry(join(root, MODEL_LAYOUT.registryDb), { modelDirs: [join(root, MODEL_LAYOUT.models)], isCompanion: isDrafterModelType });
}
