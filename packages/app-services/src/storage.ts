// A module's declared storage entries under the home root. The host creates an
// entry on first use; nothing else is written by default, and explicit user
// paths always win over these defaults.
import { mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import type { StorageService } from "@mlx-bun/app-core";
import type { ModuleScope } from "@mlx-bun/app-host";
import { mlxBunHome } from "./home";

/** Bindings' `storage` factory: each module sees only the entries its manifest declared. */
export function createStorage(root: () => string = () => mlxBunHome()): (scope: ModuleScope) => StorageService {
  return scope => ({
    path(key) {
      const entry = scope.manifest.storage?.find(item => item.key === key);
      if (!entry) throw new Error(`module ${scope.moduleId} declared no storage entry "${key}"`);
      const path = join(root(), entry.path);
      mkdirSync(entry.kind === "directory" ? path : dirname(path), { recursive: true });
      return path;
    },
  });
}
