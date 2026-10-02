// `mlx-bun-transcribe serve`: the transcription module's audio routes and the
// four read-only discovery surfaces over one Whisper checkpoint. No chat model,
// no jobs, no web app: the process idles at a few tens of MB with the weights
// paged out, and the first request pages them in.
import type { AppModule, CliVerbSpec, ModelCatalog } from "@mlx-bun/app-core";
import type { LoadedModules } from "@mlx-bun/app-host";
import {
  activateModules, createCompanionInfoRoutes, createHostServices, createModuleRoutes, createRegistryCatalog, parseVerb, type HostServices, type WhisperBackend,
} from "@mlx-bun/app-services";
import pkg from "../../package.json" with { type: "json" };
import { installedModules } from "../modules";

export const PROGRAM = "mlx-bun-transcribe";

/** This host's own verb: everything else comes from the installed module's manifest. */
export const serveVerb: CliVerbSpec = {
  name: "serve", summary: "Serve the audio routes with a local Whisper model",
  positional: [{ name: "query", summary: "The Whisper checkpoint (a directory or a cached query)" }],
  options: [
    { name: "model", type: "string", summary: "Whisper model directory or cached query (overrides the positional query) [default: the first downloaded whisper checkpoint]" },
    { name: "host", type: "string", summary: "Bind address [default: 127.0.0.1]" },
    { name: "port", type: "number", summary: "Listen port; 0 chooses a free port [default: 8080]" },
    { name: "whisper-idle-unload", type: "number", summary: "Seconds the Whisper weights stay loaded after a take; 0 releases them right after every take [default: 0]" },
    { name: "whisper-resident", type: "boolean", summary: "Never release the Whisper weights" },
    { name: "preload", type: "boolean", summary: "Load the Whisper weights before listening instead of on the first request" },
  ],
};

export interface ServeInput {
  /** The checkpoint: a directory or a cached query; omitted, the first downloaded Whisper. */
  query?: string;
  hostname?: string;
  port?: number;
  idleUnloadSec?: number;
  resident?: boolean;
  preload?: boolean;
  /** Test seams. */
  catalog?: ModelCatalog;
  backend?: WhisperBackend;
  modules?: () => Promise<readonly AppModule[]>;
}

export interface RunningTranscribeServer {
  readonly port: number;
  readonly modelId: string;
  /** Stops admission and joins takes in flight, then releases the weights. Idempotent. */
  close(): Promise<void>;
}

/** Resolve the checkpoint, activate the modules over this host's services and listen. */
export async function startTranscribeServer(input: ServeInput = {}): Promise<RunningTranscribeServer> {
  const catalog = input.catalog ?? createRegistryCatalog();
  const entry = input.query ? await catalog.find(input.query)
    : (await catalog.list({ kind: "model" })).find(model => model.operations.includes("transcribe"))
      ?? (() => { throw new Error("no Whisper model downloaded — try: mlx-bun get mlx-community/whisper-large-v3-turbo"); })();
  if (!entry.operations.includes("transcribe")) throw new Error(`${entry.id} is not a speech-to-text model`);
  const services: HostServices = createHostServices({ catalog, ...(input.backend ? { backend: input.backend } : {}),
    whisper: { modelDir: entry.directory, modelId: entry.id, idleUnloadSec: input.idleUnloadSec, resident: input.resident } });
  let loaded: LoadedModules | undefined, closing: Promise<void> | undefined, stopped = false;
  // The module stops first (takes in flight are joined), then the weights release.
  const closeServices = async () => {
    const errors: unknown[] = [];
    try { await loaded?.stop(); } catch (error) { errors.push(error); }
    try { await services.whisper.close(); } catch (error) { errors.push(error); }
    if (errors.length) throw new AggregateError(errors, "transcription cleanup failed");
  };
  try {
    loaded = await activateModules(await (input.modules ?? installedModules)(), services);
    if (input.preload) await services.whisper.preload(entry.id);
    const active = loaded, audio = createModuleRoutes(active.routes);
    const info = createCompanionInfoRoutes({ modelId: entry.id, models: services.whisper, counters: () => active.status("transcription"), name: PROGRAM,
      version: pkg.version, startedAt: Date.now(),
      endpoints: [...active.routes.map(route => `${route.spec.method} ${route.path}`), "GET /v1/models", "GET /health", "GET /stats"] });
    const server = Bun.serve({ port: input.port ?? 8080, hostname: input.hostname ?? "127.0.0.1", idleTimeout: 0,
      async fetch(request) {
        if (stopped) return Response.json({ error: { message: "server is shutting down" } }, { status: 503 });
        return await audio.handle(request) ?? await info.handle(request) ?? Response.json({ error: { message: "Not found" } }, { status: 404 });
      } });
    const close = () => closing ??= (async () => {
      stopped = true;
      const errors: unknown[] = [];
      try { await closeServices(); } catch (error) { errors.push(error); }
      try { await server.stop(false); } catch (error) { errors.push(error); }
      if (errors.length) throw new AggregateError(errors, "server cleanup failed");
    })();
    return { port: server.port!, modelId: entry.id, close };
  } catch (error) {
    try { await closeServices(); } catch (cleanup) { throw new AggregateError([error, cleanup], "startup and cleanup failed"); }
    throw error;
  }
}

/** The `serve` verb: listen, announce, and stop on SIGINT or SIGTERM. Resolves to the exit code. */
export async function runServe(argv: readonly string[], log: (line: string) => void = line => console.log(line)): Promise<number> {
  const { values, positionals } = parseVerb(PROGRAM, serveVerb, argv);
  const text = (name: string) => typeof values[name] === "string" ? values[name] as string : undefined;
  const number = (name: string) => typeof values[name] === "number" ? values[name] as number : undefined;
  const port = number("port"), idle = number("whisper-idle-unload");
  if (port !== undefined && (!Number.isInteger(port) || port < 0 || port > 65535)) throw new Error(`invalid --port: ${port}`);
  if (idle !== undefined && idle < 0) throw new Error(`--whisper-idle-unload expects seconds >= 0 (got "${idle}")`);
  const query = text("model") ?? positionals[0];
  const running = await startTranscribeServer({ ...(query ? { query } : {}), ...(text("host") ? { hostname: text("host") } : {}), ...(port !== undefined ? { port } : {}),
    ...(idle !== undefined ? { idleUnloadSec: idle } : {}), resident: values["whisper-resident"] === true, preload: values.preload === true });
  const residency = values["whisper-resident"] === true ? "always resident" : !idle ? "released after every take" : `idle unload ${idle}s`;
  log(`Serving ${running.modelId} as a transcription-only server\nPOST http://${text("host") ?? "127.0.0.1"}:${running.port}/v1/audio/transcriptions (${residency}; ${values.preload === true ? "loaded" : "loads on first request"})\nStop: Ctrl+C`);
  return new Promise<number>(resolve => {
    let stopping = false;
    const stop = () => {
      if (stopping) return;
      stopping = true;
      process.off("SIGINT", stop); process.off("SIGTERM", stop);
      running.close().then(() => resolve(0), error => { console.error(error instanceof Error ? error.message : String(error)); resolve(1); });
    };
    process.on("SIGINT", stop); process.on("SIGTERM", stop);
  });
}
