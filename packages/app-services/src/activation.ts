// Module activation and verb running, over any host's core-service bindings.
// CPU only: nothing here loads a model or native code, so a process without
// the MLX library (the persistent app state) can activate modules with it.
import type { AppModule, CliTerminal, CliVerbSpec } from "@mlx-bun/app-core";
import { loadModules, type LoadedModules, type ServiceBindings } from "@mlx-bun/app-host";
import type { HostServices } from "./host";
import { plainTerminal } from "./terminal";
import { parseVerb, verbArguments } from "./verbs";

/** Activate modules over a host's services. Fails on what the host does not serve: sockets unless it says it does (`sockets`, served with `createModuleSockets`),
 * and job runners unless it binds the `jobs` service (which then runs them). */
export async function activateModules(modules: readonly AppModule[], services: { readonly bindings: ServiceBindings; readonly sockets?: boolean }): Promise<LoadedModules> {
  const loaded = await loadModules(modules, { services: services.bindings });
  const unserved = [...(services.sockets ? [] : loaded.sockets.map(socket => `socket ${socket.path}`)),
    ...(services.bindings.jobs ? [] : [...loaded.jobs.keys()].map(kind => `job kind ${kind}`))];
  if (unserved.length) {
    await loaded.stop();
    throw new Error(`this host does not serve ${unserved.join(", ")} yet`);
  }
  return loaded;
}

/**
 * Parse `argv` against the verb's manifest (or check the `values` a caller
 * already parsed from another spelling of it), activate the modules over
 * `services` and run it; resolves to the exit code. SIGINT and SIGTERM abort
 * the verb's signal and the verb decides how to stop. The modules stop first,
 * then the model host releases what it loaded. `terminal` is the host's
 * presentation (default: plain lines); `activated` sees the loaded modules
 * before the verb runs (a host that runs their job kinds takes them here).
 */
export async function runVerb(input: { program: string; spec: CliVerbSpec; modules: () => Promise<readonly AppModule[]>; services: HostServices;
  terminal?: CliTerminal; activated?: (loaded: LoadedModules) => void } &
  ({ argv: readonly string[] } | { values: Readonly<Record<string, unknown>>; positionals: readonly string[] })): Promise<number> {
  const parsed = "argv" in input ? parseVerb(input.program, input.spec, input.argv) : verbArguments(input.program, input.spec, input.values, input.positionals);
  const loaded = await activateModules(await input.modules(), input.services);
  input.activated?.(loaded);
  const cancellation = new AbortController();
  const stop = () => cancellation.abort(new Error(`${input.spec.name} cancelled`));
  process.on("SIGINT", stop); process.on("SIGTERM", stop);
  try {
    return await loaded.verbs.get(input.spec.name)!.handler({ ...parsed, signal: cancellation.signal, terminal: input.terminal ?? plainTerminal(),
      stdout: text => { process.stdout.write(text); }, stderr: text => { process.stderr.write(text); } });
  } finally {
    process.off("SIGINT", stop); process.off("SIGTERM", stop);
    try { await loaded.stop(); } finally { try { await input.services.whisper.close(); } finally { input.services.events.close(); } }
  }
}
