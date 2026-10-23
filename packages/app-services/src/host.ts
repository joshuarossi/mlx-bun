// What every host composes around the installed modules: the core services it
// implements (the companion model hosts, the registry-backed catalog, storage),
// module activation, and running a module's CLI verb. A host adds its own
// execution lock and serving; this is the part a second host would copy.
import type { ModelCatalog, ModelId, ModelOperation } from "@mlx-bun/app-core";
import type { ServiceBindings } from "@mlx-bun/app-host";
import { createRegistryCatalog, type CatalogHub } from "./catalog";
import { createCompanionModelHost, type CompanionModelHost } from "./companion-model-host";
import { createEventHub, type EventHub } from "./events";
import type { ImageBackend } from "./image-backend";
import { createImageModelHost, type ImageModelHost } from "./image-model-host";
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

/** The text-to-image companion: its checkpoint and residency. */
export interface ImageServing {
  /** The explicit snapshot; else the first downloaded image model is found on the first request. */
  modelDir?: string;
  modelId?: string;
  idleUnloadSec?: number;
  resident?: boolean;
  /** Bytes a pipeline's stages may hold together before each run releases them one by one; default a share of physical memory. */
  stageBudgetBytes?: number;
}

export interface HostServicesOptions {
  whisper?: WhisperServing;
  image?: ImageServing;
  /** The host's exclusive lock around decoding and image runs; without one they run at once. */
  exclusive?: Exclusive;
  /** Makes room for a companion about to load; see `WhisperModelHostOptions.admit`. */
  admit?: (bytes: number) => Promise<void>;
  /** Test seams. */
  backend?: WhisperBackend;
  imageBackend?: ImageBackend;
  catalog?: ModelCatalog;
  /** Downloads and publishing behind the default catalog; a host without them cannot fetch or push models. */
  hub?: CatalogHub;
  /** Where declared storage entries live; default `MLX_BUN_HOME`. */
  storageRoot?: () => string;
  /** The host's event bus, shared with whatever else publishes (the engine adapter); default a new one. */
  events?: EventHub;
  /** Lifecycle lines of the model hosts (`[transcription] X loaded in 60 ms`); default the console, which a verb printing to stdout must silence. */
  log?: (line: string) => void;
}

export interface HostServices {
  readonly whisper: WhisperModelHost;
  readonly image: ImageModelHost;
  /** Both hosts as the `modelHost` binding: each call goes to the host of the operation the model declares. `close` releases both. */
  readonly companions: CompanionModelHost;
  readonly catalog: ModelCatalog;
  readonly events: EventHub;
  readonly bindings: ServiceBindings;
}

/** The core services a host that serves companion models implements: `modelHost` (Whisper for `transcribe`, the image host for
 * `image`), `catalog`, `storage` and `events`. Nothing loads until a module leases a model. */
export function createHostServices(options: HostServicesOptions = {}): HostServices {
  const catalog = options.catalog ?? createRegistryCatalog(options.hub ? { hub: options.hub } : {});
  const events = options.events ?? createEventHub();
  const shared = { catalog, ...(options.exclusive ? { exclusive: options.exclusive } : {}), ...(options.admit ? { admit: options.admit } : {}),
    ...(options.log ? { log: options.log } : {}), events };
  const configured = (policy: { modelDir?: string; modelId?: string } | undefined) =>
    policy?.modelDir ? { configured: { id: policy.modelId ?? policy.modelDir, directory: policy.modelDir } } : {};
  const policy = options.whisper;
  const whisper = createWhisperModelHost({
    ...shared,
    ...configured(policy),
    ...(policy?.idleUnloadSec !== undefined ? { idleUnloadSec: policy.idleUnloadSec } : {}),
    ...(policy?.resident ? { resident: true } : {}),
    ...(options.backend ? { backend: options.backend } : {}),
  });
  const imagePolicy = options.image;
  const image = createImageModelHost({
    ...shared,
    ...configured(imagePolicy),
    ...(imagePolicy?.idleUnloadSec !== undefined ? { idleUnloadSec: imagePolicy.idleUnloadSec } : {}),
    ...(imagePolicy?.resident ? { resident: true } : {}),
    ...(imagePolicy?.stageBudgetBytes !== undefined ? { stageBudgetBytes: imagePolicy.stageBudgetBytes } : {}),
    ...(options.imageBackend ? { backend: options.imageBackend } : {}),
  });
  // A configured checkpoint need not be in the catalog: its operation is the one it was configured for.
  const known: Record<ModelId, ModelOperation> = {};
  for (const [operation, served] of [["transcribe", configured(policy).configured], ["image", configured(imagePolicy).configured]] as const)
    if (served) known[served.id] = operation;
  const companions = createCompanionModelHost({ hosts: { transcribe: whisper, image }, catalog, known });
  return { whisper, image, companions, catalog, events, bindings: { modelHost: () => companions, catalog: () => catalog, storage: createStorage(options.storageRoot),
    events: scope => events.scoped(scope) } };
}
