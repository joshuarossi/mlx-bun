// What every host composes around the installed modules: the core services it
// implements (the Whisper model host, the registry-backed catalog, storage),
// module activation, and running a module's CLI verb. A host adds its own
// execution lock and serving; this is the part a second host would copy.
import type { ModelCatalog } from "@mlx-bun/app-core";
import type { ServiceBindings } from "@mlx-bun/app-host";
import { createRegistryCatalog } from "./catalog";
import { createEventHub, type EventHub } from "./events";
import { createStorage } from "./storage";
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
  /** The host's event bus, shared with whatever else publishes (the engine adapter); default a new one. */
  events?: EventHub;
  /** Lifecycle lines of the model host (`[transcription] X loaded in 60 ms`); default the console, which a verb printing to stdout must silence. */
  log?: (line: string) => void;
}

export interface HostServices {
  readonly whisper: WhisperModelHost;
  readonly catalog: ModelCatalog;
  readonly events: EventHub;
  readonly bindings: ServiceBindings;
}

/** The core services a host that serves Whisper implements: `modelHost`, `catalog`, `storage` and `events`. */
export function createHostServices(options: HostServicesOptions = {}): HostServices {
  const catalog = options.catalog ?? createRegistryCatalog();
  const events = options.events ?? createEventHub();
  const policy = options.whisper;
  const whisper = createWhisperModelHost({
    catalog,
    ...(policy?.modelDir ? { configured: { id: policy.modelId ?? policy.modelDir, directory: policy.modelDir } } : {}),
    ...(policy?.idleUnloadSec !== undefined ? { idleUnloadSec: policy.idleUnloadSec } : {}),
    ...(policy?.resident ? { resident: true } : {}),
    ...(options.exclusive ? { exclusive: options.exclusive } : {}),
    ...(options.backend ? { backend: options.backend } : {}),
    ...(options.log ? { log: options.log } : {}),
    events,
  });
  return { whisper, catalog, events, bindings: { modelHost: () => whisper, catalog: () => catalog, storage: createStorage(options.storageRoot),
    events: scope => events.scoped(scope) } };
}
