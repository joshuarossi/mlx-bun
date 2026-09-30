import type { AppModule, CoreServiceName, HttpMethod } from "@mlx-bun/app-core";

export const coreServiceNames = ["modelHost", "jobs", "catalog", "storage", "events", "registry"] as const satisfies readonly CoreServiceName[];

/** A route or socket path the host or a module answers. */
export interface RouteKey { readonly method: HttpMethod; readonly path: string }

export interface ManifestOptions {
  /** Core services the host implements; `registry` needs no entry (the loader provides it). */
  readonly provided: readonly CoreServiceName[];
  /** Routes the host itself answers; a module route on the same method and path is a collision. */
  readonly reserved?: readonly RouteKey[];
}

const idPattern = /^[a-z][a-z0-9]*(-[a-z0-9]+)*$/;

/** `/api/<id><path>` for a module-mounted route, `path` itself for `mount: "root"`. */
export function mountedPath(moduleId: string, path: string, mount: "module" | "root" = "module"): string {
  return mount === "root" ? path : `/api/${moduleId}${path === "/" ? "" : path}`;
}

/** Two paths collide when they match the same requests: parameter names do not matter, a trailing slash does not. */
function shape(path: string): string {
  const segments = path.split("/").map(segment => segment.startsWith(":") ? ":" : segment);
  const joined = segments.join("/");
  return joined.length > 1 && joined.endsWith("/") ? joined.slice(0, -1) : joined;
}

function storageSegments(path: string): string[] | undefined {
  if (!path || path.startsWith("/") || path.includes("\\")) return undefined;
  const segments = path.split("/");
  return segments.every(segment => segment !== "" && segment !== "." && segment !== "..") ? segments : undefined;
}

/**
 * Every manifest problem, or `[]`. The manifest is plain data, so this runs
 * without activating anything. Checks: ids are well formed and unique; every
 * `requires` names a core service the host implements; routes, sockets, CLI
 * verbs, job kinds and storage entries are well formed and unique across
 * modules (routes by method and path shape, storage case-insensitively and not
 * nested in another module's path, except that two modules may declare the same
 * entry, one path and kind, to share it); a panel's tag follows the id and its declared route is unique.
 */
export function checkManifests(modules: readonly AppModule[], options: ManifestOptions): string[] {
  const problems: string[] = [];
  const provided = new Set<CoreServiceName>([...options.provided, "registry"]);
  const ids = new Set<string>();
  const routes = new Map<string, string>();
  for (const route of options.reserved ?? []) routes.set(`${route.method} ${shape(route.path)}`, "the host");
  const verbs = new Map<string, string>();
  const kinds = new Map<string, string>();
  const panelPaths = new Map<string, string>();
  const stored: { readonly path: string; readonly kind: string; readonly segments: string[]; readonly owner: string }[] = [];

  for (const module of modules) {
    const id = module.id;
    const at = `module ${JSON.stringify(id)}`;
    if (typeof id !== "string" || !idPattern.test(id)) { problems.push(`${at}: id must be lowercase kebab-case`); continue; }
    if (ids.has(id)) { problems.push(`${at}: duplicate module id`); continue; }
    ids.add(id);

    for (const service of module.requires) {
      if (!(coreServiceNames as readonly string[]).includes(service)) problems.push(`${at}: requires unknown service "${service}"`);
      else if (!provided.has(service)) problems.push(`${at}: requires "${service}", which this host does not implement`);
    }
    if (new Set(module.requires).size !== module.requires.length) problems.push(`${at}: requires lists a service twice`);
    if ((module.contributes?.length ?? 0) > 0 && !module.requires.includes("registry"))
      problems.push(`${at}: contributes without requiring "registry"`);
    for (const point of module.contributes ?? [])
      if (!/^[a-z][a-z0-9-]*\.[a-z][a-z0-9-]*$/.test(point)) problems.push(`${at}: malformed extension point "${point}"`);

    const routeIds = new Set<string>();
    const claim = (method: HttpMethod, declared: string, path: string, label: string) => {
      if (!declared.startsWith("/") || /[?#]/.test(declared) || declared.includes("//")) { problems.push(`${at}: ${label} path "${declared}" must start with "/" and hold no "?", "#" or "//"`); return; }
      const key = `${method} ${shape(path)}`;
      const owner = routes.get(key);
      if (owner) problems.push(`${at}: ${label} ${method} ${path} collides with ${owner}`);
      else routes.set(key, `${label} of module ${id}`);
    };
    for (const route of module.routes ?? []) {
      if (routeIds.has(route.id)) problems.push(`${at}: duplicate route id "${route.id}"`);
      routeIds.add(route.id);
      claim(route.method, route.path, mountedPath(id, route.path, route.mount), `route "${route.id}"`);
    }
    const socketIds = new Set<string>();
    for (const socket of module.sockets ?? []) {
      if (socketIds.has(socket.id)) problems.push(`${at}: duplicate socket id "${socket.id}"`);
      socketIds.add(socket.id);
      claim("GET", socket.path, mountedPath(id, socket.path), `socket "${socket.id}"`);
    }

    for (const verb of module.verbs ?? []) {
      if (!/^[a-z][a-z0-9-]*$/.test(verb.name)) problems.push(`${at}: verb name "${verb.name}" must be lowercase kebab-case`);
      const owner = verbs.get(verb.name);
      if (owner) problems.push(`${at}: verb "${verb.name}" is already declared by module ${owner}`);
      else verbs.set(verb.name, id);
      const options = verb.options.map(option => option.name);
      if (new Set(options).size !== options.length) problems.push(`${at}: verb "${verb.name}" declares an option twice`);
    }

    for (const job of module.jobs ?? []) {
      const owner = kinds.get(job.kind);
      if (!job.kind) problems.push(`${at}: job kind is empty`);
      else if (owner) problems.push(`${at}: job kind "${job.kind}" is already declared by module ${owner}`);
      else kinds.set(job.kind, id);
    }

    const keys = new Set<string>();
    for (const entry of module.storage ?? []) {
      if (keys.has(entry.key)) problems.push(`${at}: duplicate storage key "${entry.key}"`);
      keys.add(entry.key);
      const segments = storageSegments(entry.path);
      if (!segments) { problems.push(`${at}: storage path "${entry.path}" must be relative, with no empty, "." or ".." segment`); continue; }
      const lowered = segments.map(segment => segment.toLowerCase());
      for (const other of stored) {
        const shared = Math.min(lowered.length, other.segments.length);
        const nested = lowered.slice(0, shared).join("/") === other.segments.slice(0, shared).join("/");
        // The same declaration (path and kind) in two modules is one shared entry, as models produced by quantize and by train.
        if (other.owner !== id && other.path === entry.path && other.kind === entry.kind) continue;
        if (nested && (other.owner !== id || lowered.length === other.segments.length))
          problems.push(`${at}: storage path "${entry.path}" collides with "${other.path}" of module ${other.owner}`);
      }
      stored.push({ path: entry.path, kind: entry.kind, segments: lowered, owner: id });
    }

    if (module.panel) {
      if (module.panel.tag !== `mlx-${id}-panel`) problems.push(`${at}: panel tag must be "mlx-${id}-panel"`);
      if (!/^\/[a-z][a-z0-9]*(?:-[a-z0-9]+)*$/.test(module.panel.path)) problems.push(`${at}: panel path must be one lowercase kebab-case route`);
      const owner = panelPaths.get(module.panel.path);
      if (owner) problems.push(`${at}: panel path "${module.panel.path}" collides with module ${owner}`);
      panelPaths.set(module.panel.path, id);
    }
  }
  return problems;
}
