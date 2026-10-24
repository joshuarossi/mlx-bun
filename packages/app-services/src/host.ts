// What every host composes around the installed modules: the core services it
// implements (the companion model hosts, the registry-backed catalog, storage),
// module activation, and running a module's CLI verb. A host adds its own
// execution lock and serving; this is the part a second host would copy.
import type { ModelCatalog, ModelId, ModelOperation, ReserveModel } from "@mlx-bun/app-core";
import type { ServiceBindings } from "@mlx-bun/app-host";
import { createRegistryCatalog, type CatalogHub } from "./catalog";
import { createCompanionModelHost, type CompanionModelHost } from "./companion-model-host";
import { createEventHub, type EventHub } from "./events";
import type { ImageBackend } from "./image-backend";
import { createImageModelHost, type ImageModelHost } from "./image-model-host";
import type { StageRule } from "./image-stages";
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
  /** How the image host decides whether each run releases a pipeline's stages one by one; default the budget rule over a share of physical memory. */
  stages?: StageRule;
}

export interface HostServicesOptions {
  /** Companion operations this composition serves. A worker supplies only its own operations. */
  operations?: readonly ModelOperation[];
  whisper?: WhisperServing;
  image?: ImageServing;
  /** The host's exclusive lock around decoding and image runs; without one they run at once. */
  exclusive?: Exclusive;
  /** Coordinates lazy companion weight loads as well as decode through the host's execution lease. */
  loadExclusive?: Exclusive;
  /** Makes room for Whisper before it loads; see `WhisperModelHostOptions.admit`. */
  admit?: (bytes: number) => Promise<void>;
  /** Owns pending and resident bytes for every companion sharing the host's memory budget. */
  reserve?: ReserveModel;
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
  const operations = options.operations ?? ["transcribe", "image"];
  const source = options.catalog ?? createRegistryCatalog(options.hub ? { hub: options.hub } : {});
  const supports = (entry: { operations: readonly ModelOperation[] }) => entry.operations.some(operation => operations.includes(operation));
  // A model-scoped catalog cannot open a different operation through an explicit directory.
  const catalog: ModelCatalog = options.operations === undefined ? source : { ...source,
    list: async filter => (await source.list(filter)).filter(supports),
    resolve: async id => { const entry = await source.resolve(id); return entry && supports(entry) ? entry : undefined; },
    find: async query => {
      const entry = await source.find(query);
      if (!supports(entry)) throw new Error(`${query} declares no operation served by this host`);
      return entry;
    } };
  const events = options.events ?? createEventHub();
  const shared = { catalog, ...(options.exclusive ? { exclusive: options.exclusive } : {}),
    ...(options.reserve ? { reserve: options.reserve } : {}),
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
    ...(options.admit ? { admit: options.admit } : {}),
    ...(options.loadExclusive ? { loadExclusive: options.loadExclusive } : {}),
  });
  const imagePolicy = options.image;
  const image = createImageModelHost({
    ...shared,
    ...configured(imagePolicy),
    ...(imagePolicy?.idleUnloadSec !== undefined ? { idleUnloadSec: imagePolicy.idleUnloadSec } : {}),
    ...(imagePolicy?.resident ? { resident: true } : {}),
    ...(imagePolicy?.stages ? { stages: imagePolicy.stages } : {}),
    ...(options.imageBackend ? { backend: options.imageBackend } : {}),
  });
  // A configured checkpoint need not be in the catalog: its operation is the one it was configured for.
  const known: Record<ModelId, ModelOperation> = {};
  for (const [operation, served] of [["transcribe", configured(policy).configured], ["image", configured(imagePolicy).configured]] as const)
    if (served) known[served.id] = operation;
  const companions = createCompanionModelHost({ hosts: { ...(operations.includes("transcribe") ? { transcribe: whisper } : {}),
    ...(operations.includes("image") ? { image } : {}) }, catalog, known });
  return { whisper, image, companions, catalog, events, bindings: { modelHost: () => companions, catalog: () => catalog, storage: createStorage(options.storageRoot),
    events: scope => events.scoped(scope) } };
}
