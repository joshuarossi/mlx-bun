// Test seams for the transcription module: a fake Whisper backend and speech
// gate in the shape the old service tests used (`load`, `vad`, `decodeAudio`),
// composed with the real Whisper model host from `@mlx-bun/app-services` so
// residency, idle unload and the execution lock are exercised through the same
// `modelHost` the module leases from.
import type { CatalogEntry, ModelCatalog, ModelHost } from "@mlx-bun/app-core";
import { createWhisperModelHost, type Exclusive, type LoadedWhisper, type WhisperModelHost } from "@mlx-bun/app-services";
import { TranscriptionService, type MediaRuntime, type TranscriptionServiceOptions } from "../src/service";

export type { LoadedWhisper, WhisperRun } from "@mlx-bun/app-services";

/** A backend and the media seam in one object, as the service tests used to inject them. */
export interface TranscriptionRuntime extends MediaRuntime {
  load(modelDir: string): Promise<LoadedWhisper>;
}

export const MODEL_ID = "org/whisper", MODEL_DIR = "/whisper";

/** A catalog that knows the given ids (id to directory) and declares them `transcribe`. */
export function fakeCatalog(models: Record<string, string> = { [MODEL_ID]: MODEL_DIR }): ModelCatalog {
  const entry = (id: string): CatalogEntry => ({ id, kind: "model", directory: models[id]!, bytes: 0, operations: ["transcribe"] });
  return {
    list: async () => Object.keys(models).map(entry),
    resolve: async id => id in models ? entry(id) : undefined,
    find: async query => { if (!(query in models)) throw new Error(`no model matching "${query}"`); return entry(query); },
    estimate: async () => ({ residentBytes: 0 }),
    register: async () => { throw new Error("unused"); },
    download: async () => { throw new Error("unused"); },
  };
}

export interface StackOptions {
  idleUnloadSec?: number;
  resident?: boolean;
  exclusive?: Exclusive;
  timers?: { setTimeout(fn: () => void, ms: number): unknown; clearTimeout(handle: unknown): void };
  now?: () => number;
  service?: Partial<TranscriptionServiceOptions>;
  media?: MediaRuntime;
}

/** The module's service over a real Whisper model host backed by the fake runtime. */
export function stack(runtime: TranscriptionRuntime, options: StackOptions = {}) {
  const host = createWhisperModelHost({ catalog: fakeCatalog(), configured: { id: MODEL_ID, directory: MODEL_DIR },
    backend: runtime, log() {}, idleUnloadSec: options.idleUnloadSec, resident: options.resident, exclusive: options.exclusive,
    ...(options.timers ? { timers: options.timers } : {}), ...(options.now ? { now: options.now } : {}) });
  const service = new TranscriptionService({ models: host, modelId: MODEL_ID, media: options.media ?? runtime,
    ...(options.now ? { now: options.now } : {}), ...options.service });
  return { host, service };
}

/** What the module gets from the host, for tests that only need the `modelHost` and `catalog` services. */
export function services(host: ModelHost & Partial<WhisperModelHost>, catalog: ModelCatalog = fakeCatalog()) {
  return { modelHost: host as ModelHost, catalog };
}
