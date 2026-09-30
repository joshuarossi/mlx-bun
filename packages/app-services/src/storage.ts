// A module's declared storage entries under the home root. The host creates an
// entry on first use; nothing else is written by default, and explicit user
// paths always win over these defaults.
import { mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import type { StorageService } from "@mlx-bun/app-core";
import type { ModuleScope } from "@mlx-bun/app-host";
import { mlxBunHome } from "./home";

/** Bindings' `storage` factory: each module sees only the entries its manifest declared. `root` is the directory a module's
 * entries live under (default `MLX_BUN_HOME`; a host may choose it per module). `explicit` names the entries a user or
 * embedder placed elsewhere (`<module id>.<key>` to an absolute path): an explicit path always wins, and the host neither
 * creates nor moves it. */
export function createStorage(root: (moduleId: string) => string = () => mlxBunHome(), explicit: Readonly<Record<string, string>> = {}): (scope: ModuleScope) => StorageService {
  return scope => ({
    path(key, options) {
      const entry = scope.manifest.storage?.find(item => item.key === key);
      if (!entry) throw new Error(`module ${scope.moduleId} declared no storage entry "${key}"`);
      const chosen = explicit[`${scope.moduleId}.${key}`];
      if (chosen !== undefined) return chosen;
      const path = join(root(scope.moduleId), entry.path);
      if (options?.create !== false) mkdirSync(entry.kind === "directory" ? path : dirname(path), { recursive: true });
      return path;
    },
  });
}
