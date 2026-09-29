import type { AppModule, CliInvocation, CliVerbHandler, ModuleRuntime, RouteHandler } from "@mlx-bun/app-core";
import { runDictate, parseDictateArgs, type DictateDependencies } from "./dictate";
import { manifest } from "./manifest";
import { createAudioHandlers } from "./routes";
import { TranscriptionService, type MediaRuntime } from "./service";
import { parseTranscribeArgs, runTranscribe, type TranscribeDependencies } from "./transcribe";

export { manifest } from "./manifest";
export { createAudioHandlers, parseAudioRequest, transcriptionResponse, UNAVAILABLE_MESSAGE } from "./routes";
export type { AudioService, ParsedAudioRequest } from "./routes";
export { nativeMedia, TranscriptionError, TranscriptionService, TranscriptionSession } from "./service";
export type {
  MediaRuntime, ModelHold, TranscriptionOutcome, TranscriptionParams, TranscriptionServiceOptions, TranscriptionStats, VadGate, VocabularyUsage,
} from "./service";
export { parseTranscribeArgs, resolveWhisperModel, runTranscribe } from "./transcribe";
export type { TranscribeArgs, TranscribeDependencies, VoiceServices } from "./transcribe";
export { parseDictateArgs, runDictate } from "./dictate";
export type { DictateArgs, DictateDependencies } from "./dictate";

/** Test seams: the speech gate and audio decoding, and the verbs' file, clipboard and microphone dependencies. */
export interface TranscriptionModuleOptions {
  media?: MediaRuntime;
  transcribe?: Partial<TranscribeDependencies>;
  dictate?: Partial<DictateDependencies>;
}

/** The transcription module. The host implements `modelHost` (the Whisper lease, its residency policy and the execution lock) and `catalog`. */
export function createTranscriptionModule(options: TranscriptionModuleOptions = {}): AppModule<"modelHost" | "catalog"> {
  return {
    ...manifest,
    activate({ services }): ModuleRuntime {
      // HTTP requests share one service: FIFO takes, sessions, the speech gate. The host's policy applies to its leases.
      const service = new TranscriptionService({ models: services.modelHost, ...(options.media ? { media: options.media } : {}) });
      const handlers = createAudioHandlers(service) as Record<(typeof manifest.routes)[number]["id"], RouteHandler>;
      // A verb runs one operation with its own service, so its residency options never reach the routes'.
      const transcribe: CliVerbHandler = async (invocation: CliInvocation) => {
        const dependencies: Partial<TranscribeDependencies> = { write: invocation.stdout, note: line => invocation.stderr(line + "\n"),
          ...(options.media ? { media: options.media } : {}), ...(options.transcribe ?? {}) };
        try { await runTranscribe(services, parseTranscribeArgs(invocation), dependencies, invocation.signal); }
        catch (error) { if (invocation.signal.aborted) throw new Error("transcription cancelled"); throw error; }
        return 0;
      };
      const dictate: CliVerbHandler = async (invocation: CliInvocation) => {
        const dependencies: Partial<DictateDependencies> = { write: invocation.stdout, note: invocation.stderr,
          ...(options.media ? { media: options.media } : {}), ...(options.dictate ?? {}) };
        await runDictate(services, parseDictateArgs(invocation), dependencies, invocation.signal);
        return 0;
      };
      return {
        routes: handlers,
        verbs: { transcribe, dictate },
        status: () => ({ requests: service.stats.requests, sessions: service.sessionCount }),
        dispose: () => service.close(),
      };
    },
  };
}

export default createTranscriptionModule();
