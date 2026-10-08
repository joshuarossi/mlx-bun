// Test support: the module's routes as a host serves them (its manifest's table over its handlers), so a test
// exercises the declared paths and methods and not only the handler functions.
import { join } from "node:path";
import { mountedPath } from "@mlx-bun/app-host";
import { createModuleRoutes } from "@mlx-bun/app-services";
import { createChatHandlers } from "../src/routes";
import { manifest } from "../src/manifest";

export function chatRoutes(paths: { sessionDir: string; toolApprovalsFile?: string }) {
  const handlers = createChatHandlers({ sessionDir: () => paths.sessionDir, approvalsFile: () => paths.toolApprovalsFile ?? join(paths.sessionDir, "..", "tool-approvals.json") });
  return createModuleRoutes(manifest.routes.map(spec => ({ spec, path: mountedPath(manifest.id, spec.path, spec.mount), handler: handlers[spec.id] })));
}
