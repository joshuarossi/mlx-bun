// What every host composes around the installed modules: the core services it
// implements (the Whisper model host, the registry-backed catalog, storage),
// module activation, and running a module's CLI verb. A host adds its own
// execution lock and serving; this is the part a second host would copy.
import type { AppModule, CliVerbSpec, ModelCatalog } from "@mlx-bun/app-core";
import { loadModules, type LoadedModules, type ServiceBindings } from "@mlx-bun/app-host";
import { createRegistryCatalog } from "./catalog";
import { createStorage } from "./storage";
import { parseVerb } from "./verbs";
import type { WhisperBackend } from "./whisper-backend";
import { createWhisperModelHost, type Exclusive, type WhisperModelHost } from "./whisper-model-host";

/** `--whisper-*`, by their programmatic names: the checkpoint served for audio requests and its residency. */
export interface WhisperServing {
  /** The explicit checkpoint (`--whisper-model`, resolved); else the first downloaded Whisper is found on the first request. */
  modelDir?: string;
  modelId?: string;
  idleUnloadSec?: number;
  resident?: boolean;
}

export interface HostServicesOptions {
  whisper?: WhisperServing;
  /** The host's exclusive lock around decoding; without one decoding runs at once. */
  exclusive?: Exclusive;
  /** Test seams. */
  backend?: WhisperBackend;
  catalog?: ModelCatalog;
  /** Where declared storage entries live; default `MLX_BUN_HOME`. */
  storageRoot?: () => string;
  /** Lifecycle lines of the model host (`[transcription] X loaded in 60 ms`); default the console, which a verb printing to stdout must silence. */
  log?: (line: string) => void;
}

export interface HostServices {
  readonly whisper: WhisperModelHost;
  readonly catalog: ModelCatalog;
  readonly bindings: ServiceBindings;
}

/** The core services a host that serves Whisper implements: `modelHost`, `catalog` and `storage`. */
export function createHostServices(options: HostServicesOptions = {}): HostServices {
  const catalog = options.catalog ?? createRegistryCatalog();
  const policy = options.whisper;
  const whisper = createWhisperModelHost({
    catalog,
    ...(policy?.modelDir ? { configured: { id: policy.modelId ?? policy.modelDir, directory: policy.modelDir } } : {}),
    ...(policy?.idleUnloadSec !== undefined ? { idleUnloadSec: policy.idleUnloadSec } : {}),
    ...(policy?.resident ? { resident: true } : {}),
    ...(options.exclusive ? { exclusive: options.exclusive } : {}),
    ...(options.backend ? { backend: options.backend } : {}),
    ...(options.log ? { log: options.log } : {}),
  });
  return { whisper, catalog, bindings: { modelHost: () => whisper, catalog: () => catalog, storage: createStorage(options.storageRoot) } };
}

/** Activate modules over a host's services. Fails on what these hosts do not serve yet: sockets and job runners. */
export async function activateModules(modules: readonly AppModule[], services: Pick<HostServices, "bindings">): Promise<LoadedModules> {
  const loaded = await loadModules(modules, { services: services.bindings });
  const unserved = [...loaded.sockets.map(socket => `socket ${socket.path}`), ...[...loaded.jobs.keys()].map(kind => `job kind ${kind}`)];
  if (unserved.length) {
    await loaded.stop();
    throw new Error(`this host does not serve ${unserved.join(", ")} yet`);
  }
  return loaded;
}

/**
 * Parse `argv` against the verb's manifest, activate the modules over `services`
 * and run it; resolves to the exit code. SIGINT and SIGTERM abort the verb's
 * signal and the verb decides how to stop. The modules stop first, then the
 * model host releases what it loaded.
 */
export async function runVerb(input: { program: string; spec: CliVerbSpec; argv: readonly string[]; modules: () => Promise<readonly AppModule[]>;
  services: HostServices }): Promise<number> {
  const parsed = parseVerb(input.program, input.spec, input.argv);
  const loaded = await activateModules(await input.modules(), input.services);
  const cancellation = new AbortController();
  const stop = () => cancellation.abort(new Error(`${input.spec.name} cancelled`));
  process.on("SIGINT", stop); process.on("SIGTERM", stop);
  try {
    return await loaded.verbs.get(input.spec.name)!.handler({ ...parsed, signal: cancellation.signal,
      stdout: text => { process.stdout.write(text); }, stderr: text => { process.stderr.write(text); } });
  } finally {
    process.off("SIGINT", stop); process.off("SIGTERM", stop);
    try { await loaded.stop(); } finally { await input.services.whisper.close(); }
  }
}
