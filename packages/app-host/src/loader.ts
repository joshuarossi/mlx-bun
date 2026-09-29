import type {
  AppModule, CliVerbHandler, CliVerbSpec, CoreServiceName, CoreServices, JobRunner, JobRunnerSpec, ModuleRuntime,
  Registry, RouteHandler, RouteSpec, SocketHandler, SocketSpec, StorageEntrySpec,
} from "@mlx-bun/app-core";
import { checkManifests, mountedPath, type RouteKey } from "./manifest";
import { createRegistry } from "./registry";

/** What a host binding sees when it builds a service for one module. */
export interface ModuleScope {
  readonly moduleId: string;
  readonly manifest: AppModule;
}

/**
 * The core services this host implements, each built per module so the host can
 * scope it (a storage view of only the entries the module declared, an event
 * bus that prefixes its events). `registry` is the loader's own. A host omits
 * the services it does not implement; a module requiring one is rejected.
 */
export type ServiceBindings = {
  readonly [K in Exclude<CoreServiceName, "registry">]?: (scope: ModuleScope) => CoreServices[K];
};

export interface LoadOptions {
  readonly services: ServiceBindings;
  /** Routes the host itself answers, so a module cannot shadow them. */
  readonly reservedRoutes?: readonly RouteKey[];
}

export interface MountedRoute { readonly moduleId: string; readonly spec: RouteSpec; readonly path: string; readonly handler: RouteHandler }
export interface MountedSocket { readonly moduleId: string; readonly spec: SocketSpec; readonly path: string; readonly handler: SocketHandler }
export interface RegisteredVerb { readonly moduleId: string; readonly spec: CliVerbSpec; readonly handler: CliVerbHandler }
export interface RegisteredJob { readonly moduleId: string; readonly spec: JobRunnerSpec; readonly runner: JobRunner }
export interface StorageRegistration extends StorageEntrySpec { readonly moduleId: string }

/** The activated modules and everything they declared, for the host to serve, dispatch and create. */
export interface LoadedModules {
  readonly modules: readonly AppModule[];
  /** Full request paths (`/api/<id>/...`, or the path itself for `mount: "root"`). */
  readonly routes: readonly MountedRoute[];
  readonly sockets: readonly MountedSocket[];
  /** Keyed by verb name. */
  readonly verbs: ReadonlyMap<string, RegisteredVerb>;
  /** Keyed by job kind. */
  readonly jobs: ReadonlyMap<string, RegisteredJob>;
  readonly storage: readonly StorageRegistration[];
  readonly registry: Pick<Registry, "list" | "onChange">;
  /** A module's live counters (`ModuleRuntime.status`); undefined for a module that reports none or has stopped. */
  status(moduleId: string): ReturnType<NonNullable<ModuleRuntime["status"]>> | undefined;
  /** Aborts every module, disposes them in reverse order and drops their registrations. Idempotent; rejects with every disposal failure. */
  stop(): Promise<void>;
}

export class ManifestError extends Error {
  constructor(readonly problems: readonly string[]) {
    super(`invalid module manifests:\n- ${problems.join("\n- ")}`);
    this.name = "ManifestError";
  }
}

function handlersFor<H>(kind: string, moduleId: string, declared: readonly string[], live: Readonly<Record<string, H>> | undefined): Map<string, H> {
  const handlers = new Map(Object.entries(live ?? {}));
  const missing = declared.filter(name => !handlers.has(name));
  const undeclared = [...handlers.keys()].filter(name => !declared.includes(name));
  if (missing.length) throw new Error(`module ${moduleId}: activate returned no ${kind} handler for ${missing.join(", ")}`);
  if (undeclared.length) throw new Error(`module ${moduleId}: activate returned ${kind} handlers the manifest does not declare: ${undeclared.join(", ")}`);
  return handlers;
}

/**
 * Validates every manifest, then activates the modules in the order given, each
 * with only the services it required, and collects their declared parts. A
 * module is never activated when any manifest is invalid. If an activation
 * fails, the modules already activated are stopped and the error is rethrown.
 * Nothing here mounts an HTTP server or parses argv: the host serves
 * `routes`, dispatches `verbs`, hands `jobs` to its job service and creates
 * `storage`. With no modules it does nothing.
 */
export async function loadModules(modules: readonly AppModule[], options: LoadOptions): Promise<LoadedModules> {
  const provided = (Object.keys(options.services) as (keyof ServiceBindings)[]).filter(name => options.services[name]);
  const problems = checkManifests(modules, { provided, reserved: options.reservedRoutes });
  if (problems.length) throw new ManifestError(problems);

  const registry = createRegistry();
  const routes: MountedRoute[] = [], sockets: MountedSocket[] = [], storage: StorageRegistration[] = [];
  const verbs = new Map<string, RegisteredVerb>(), jobs = new Map<string, RegisteredJob>();
  const active: { readonly id: string; readonly abort: AbortController; readonly runtime: ModuleRuntime }[] = [];

  let stopping: Promise<void> | undefined;
  const stop = () => stopping ??= (async () => {
    const errors: unknown[] = [];
    for (const module of active.toReversed()) {
      module.abort.abort();
      try { await module.runtime.dispose?.(); } catch (error) { errors.push(error); }
      registry.removeSource(module.id);
    }
    active.length = 0;
    if (errors.length) throw new AggregateError(errors, "module disposal failed");
  })();

  for (const module of modules) {
    const scope: ModuleScope = { moduleId: module.id, manifest: module };
    const services: Partial<CoreServices> = {};
    for (const name of module.requires) {
      if (name === "registry") (services as Record<string, unknown>).registry = registry.scoped(module.id, module.contributes ?? []);
      else (services as Record<string, unknown>)[name] = options.services[name]!(scope);
    }
    const abort = new AbortController();
    let runtime: ModuleRuntime;
    try {
      runtime = await module.activate({ moduleId: module.id, services: services as CoreServices, signal: abort.signal });
      active.push({ id: module.id, abort, runtime });
      const live = {
        routes: handlersFor("route", module.id, (module.routes ?? []).map(spec => spec.id), runtime.routes),
        sockets: handlersFor("socket", module.id, (module.sockets ?? []).map(spec => spec.id), runtime.sockets),
        verbs: handlersFor("verb", module.id, (module.verbs ?? []).map(spec => spec.name), runtime.verbs),
        jobs: handlersFor("job", module.id, (module.jobs ?? []).map(spec => spec.kind), runtime.jobs),
      };
      for (const spec of module.routes ?? [])
        routes.push({ moduleId: module.id, spec, path: mountedPath(module.id, spec.path, spec.mount), handler: live.routes.get(spec.id)! });
      for (const spec of module.sockets ?? [])
        sockets.push({ moduleId: module.id, spec, path: mountedPath(module.id, spec.path), handler: live.sockets.get(spec.id)! });
      for (const spec of module.verbs ?? []) verbs.set(spec.name, { moduleId: module.id, spec, handler: live.verbs.get(spec.name)! });
      for (const spec of module.jobs ?? []) jobs.set(spec.kind, { moduleId: module.id, spec, runner: live.jobs.get(spec.kind)! });
      for (const entry of module.storage ?? []) storage.push({ ...entry, moduleId: module.id });
    } catch (error) {
      abort.abort();
      if (!active.some(item => item.abort === abort)) registry.removeSource(module.id);
      try { await stop(); } catch (cleanup) { throw new AggregateError([error, cleanup], `module ${module.id} failed and cleanup failed`); }
      throw error;
    }
  }
  const status = (moduleId: string) => active.find(module => module.id === moduleId)?.runtime.status?.();
  return { modules, routes, sockets, verbs, jobs, storage, registry: registry.reader, status, stop };
}
