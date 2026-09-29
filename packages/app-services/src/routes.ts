// Serving what modules declare: their routes as one route group, matched by
// method and path shape (`:name` matches one segment). A request no route
// matches falls through (null) to the host's other groups.
import type { RouteHandler } from "@mlx-bun/app-core";
import type { MountedRoute } from "@mlx-bun/app-host";

export interface ModuleRoutes {
  handle(request: Request): Promise<Response | null>;
}

const segments = (path: string) => path.split("/");

export function createModuleRoutes(routes: readonly Pick<MountedRoute, "spec" | "path" | "handler">[]): ModuleRoutes {
  const table = routes.map(route => ({ method: route.spec.method, shape: segments(route.path), handler: route.handler as RouteHandler }));
  return { async handle(request) {
    const path = segments(new URL(request.url).pathname);
    for (const route of table) {
      if (route.method !== request.method || route.shape.length !== path.length) continue;
      if (route.shape.every((part, index) => part.startsWith(":") ? !!path[index] : part === path[index])) return await route.handler(request);
    }
    return null;
  } };
}
