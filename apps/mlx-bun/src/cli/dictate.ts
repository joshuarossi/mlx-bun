import { startMicCapture, type MicCapture } from "../engine/mic-capture";
import { TranscriptionService, type TranscriptionParams, type TranscriptionRuntime } from "../engine/transcription-service";
import { parseCommand } from "./args";
import { resolveWhisperModel } from "./model-selection";
import { style } from "./terminal";

// `mlx-bun dictate`: push-to-talk dictation from the microphone. Main's loop:
// the sidecar streams 16 kHz PCM; a take (Enter toggling, or a held key)
// feeds a transcription session while you speak, so every finished 30 s
// window is transcribed during capture; on finish the text prints, copies
// (pbcopy), or types (System Events). The backend is the in-process
// TranscriptionService (serve's seam) or a running server's /v1/audio/sessions.
// Capture, the runtime, stdin, the clipboard, and typing are injected so the
// loop runs in tests without a microphone. Stopping (q, SIGINT, the signal)
// joins the sidecar before the weights are released.

export interface DictateArgs {
  /** --model, else the positional, else --query; undefined = the first downloaded Whisper. */
  query?: string;
  server?: string;
  /** macOS virtual keycode for hold-to-talk; null = Enter toggling. */
  hotkey: number | null;
  language: string | null;
  beamSize: number | null;
  prompt?: string;
  vocabulary?: string[];
  vad: boolean;
  idleUnloadSec: number;
  resident: boolean;
  copy: boolean;
  type: boolean;
  typeDelaySec: number;
}

const message = (error: unknown) => (error instanceof Error ? error.message : String(error));

export function parseDictateArgs(argv: string[]): DictateArgs {
  // --hotkey [keycode]: the value is optional. Main read the next token and
  // fell back to 61 (Right Option) for anything that is not a keycode.
  const rest = [...argv];
  let hotkey: number | null = null;
  const at = rest.findIndex(arg => arg === "--hotkey" || arg.startsWith("--hotkey="));
  if (at >= 0) {
    const flag = rest.splice(at, 1)[0]!;
    let value = flag.includes("=") ? flag.slice("--hotkey=".length) : undefined;
    if (value === undefined && rest[at] !== undefined && !rest[at]!.startsWith("-")) value = rest.splice(at, 1)[0];
    hotkey = Number(value ?? 61) || 61;
  }
  const parsed = parseCommand("dictate", rest);
  const value = (name: string) => { const v = parsed.values[name]; return typeof v === "string" ? v : undefined; };
  const numeric = (name: string, fallback: number, input: { integer?: boolean; minimum?: number } = {}) => {
    const raw = value(name);
    if (raw === undefined) return fallback;
    const n = Number(raw);
    if (!raw.trim() || !Number.isFinite(n) || (input.integer && !Number.isSafeInteger(n)) || n < (input.minimum ?? 0)) throw new Error(`invalid --${name}: ${raw}`);
    return n;
  };
  const language = value("language") ?? "en";
  return {
    query: value("model") ?? parsed.positionals[0] ?? value("query"),
    server: value("server")?.replace(/\/$/, ""),
    hotkey,
    language: language === "auto" ? null : language,
    beamSize: value("beam-size") !== undefined ? numeric("beam-size", 0, { integer: true, minimum: 1 }) : null,
    prompt: value("prompt"),
    vocabulary: value("vocabulary")?.split(",").map(term => term.trim()).filter(Boolean),
    vad: parsed.values["no-vad"] !== true,
    idleUnloadSec: numeric("idle-unload", 30),
    resident: parsed.values.resident === true,
    copy: parsed.values.copy === true,
    type: parsed.values.type === true,
    typeDelaySec: numeric("type-delay", hotkey ? 0 : 1),
  };
}

export interface DictateDependencies {
  resolveModel: typeof resolveWhisperModel;
  /** Model loading, the VAD gate, and audio decoding; undefined = real weights. */
  runtime?: TranscriptionRuntime;
  capture(options: { hotkey: number | null }): Promise<MicCapture>;
  /** --server sessions. */
  fetch(input: string, init?: RequestInit): Promise<Response>;
  /** stdin lines for Enter mode; ends on EOF or abort. */
  lines(signal: AbortSignal): AsyncIterable<string>;
  copy(text: string): Promise<void>;
  /** Rejects with the tool's diagnostic when typing fails. */
  type(text: string): Promise<void>;
  sleep(ms: number): Promise<void>;
  /** stdout. */
  write(text: string): void;
  /** stderr, verbatim. */
  note(text: string): void;
  now(): number;
}
const defaults: DictateDependencies = {
  resolveModel: resolveWhisperModel,
  capture: options => startMicCapture(options),
  fetch: (input, init) => fetch(input, init),
  async *lines(signal) {
    const reader = Bun.stdin.stream().getReader(), decoder = new TextDecoder();
    const abort = () => { void reader.cancel().catch(() => {}); };
    signal.addEventListener("abort", abort, { once: true });
    let text = "";
    try {
      for (;;) {
        const next = await reader.read();
        if (next.done || signal.aborted) return;
        text += decoder.decode(next.value, { stream: true });
        let nl: number;
        while ((nl = text.indexOf("\n")) >= 0) { yield text.slice(0, nl); text = text.slice(nl + 1); }
      }
    } finally { signal.removeEventListener("abort", abort); reader.releaseLock(); }
  },
  async copy(text) {
    const proc = Bun.spawn(["pbcopy"], { stdin: "pipe", stdout: "ignore", stderr: "ignore" });
    proc.stdin.write(text); proc.stdin.end();
    await proc.exited;
  },
  async type(text) {
    const escaped = text.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
    const proc = Bun.spawn(["osascript", "-e", `tell application "System Events" to keystroke "${escaped}"`], { stdout: "ignore", stderr: "pipe" });
    const [code, stderr] = await Promise.all([proc.exited, new Response(proc.stderr).text()]);
    if (code !== 0) throw new Error(stderr.trim());
  },
  sleep: ms => Bun.sleep(ms),
  write: text => { process.stdout.write(text); },
  note: text => { process.stderr.write(text); },
  now: () => performance.now(),
};

interface Take { feed(pcm: Float32Array): Promise<void>; finish(): Promise<{ text: string; ms: number }> }

/** Resolves when dictation ends: `q`, the signal (main exited 0 on Ctrl-C),
 * or the sidecar closing; rejects on a sidecar error. */
export async function runDictate(args: DictateArgs, supplied: Partial<DictateDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...defaults, ...supplied };
  const params: TranscriptionParams = {
    language: args.language, beamSize: args.beamSize, temperature: 0, prompt: args.prompt, vocabulary: args.vocabulary,
    vad: args.vad ? { threshold: 0.5, minSpeechMs: 120 } : null,
  };
  signal?.throwIfAborted();
  let service: TranscriptionService | null = null;
  if (!args.server) {
    const model = await deps.resolveModel(args.query);
    signal?.throwIfAborted();
    service = new TranscriptionService({ modelDir: model.path, modelId: model.repoId, idleUnloadSec: args.idleUnloadSec,
      resident: args.resident, log() {}, ...(deps.runtime ? { runtime: deps.runtime } : {}) });
  }
  try {
    if (service) {
      deps.note(style.dim("loading whisper… "));
      await service.ensureLoaded();
      // Warm the gate before the first take; --no-vad never needs its weights.
      if (args.vad) await service.vad();
      deps.note(style.dim("ready\n"));
      signal?.throwIfAborted();
    }
    const startTake = async (): Promise<Take> => {
      if (service) {
        const session = await service.createSession(params);
        return {
          feed: async pcm => { await session.append(pcm); },
          finish: async () => { const t0 = deps.now(); const outcome = await session.finish(); return { text: outcome.result.text.trim(), ms: deps.now() - t0 }; },
        };
      }
      const base = args.server!;
      const created = await deps.fetch(`${base}/v1/audio/sessions`, { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ language: params.language, beam_size: params.beamSize, temperature: 0, prompt: params.prompt,
          vocabulary: args.vocabulary, vad: !!params.vad, vad_min_speech_ms: 120 }) });
      if (!created.ok) throw new Error(`session create failed: ${created.status} ${await created.text()}`);
      const { id } = await created.json() as { id: string };
      return {
        feed: async pcm => {
          await deps.fetch(`${base}/v1/audio/sessions/${id}/audio`, { method: "POST", headers: { "content-type": "audio/pcm;rate=16000" },
            body: new Uint8Array(pcm.buffer.slice(pcm.byteOffset, pcm.byteOffset + pcm.byteLength) as ArrayBuffer) });
        },
        finish: async () => {
          const t0 = deps.now();
          const finished = await deps.fetch(`${base}/v1/audio/sessions/${id}/finish`, { method: "POST" });
          const body = await finished.json() as { text?: string };
          return { text: (body.text ?? "").trim(), ms: deps.now() - t0 };
        },
      };
    };
    const deliver = async (text: string) => {
      if (!text) { deps.write(style.dim("(no speech)") + "\n"); return; }
      deps.write(text + "\n");
      if (args.copy) await deps.copy(text);
      if (args.type) {
        if (args.typeDelaySec > 0) await deps.sleep(args.typeDelaySec * 1000);
        try { await deps.type(text); }
        catch (error) { deps.note(style.dim(`typing failed (grant Accessibility to your terminal): ${message(error)}`) + "\n"); }
      }
    };

    const mic = await deps.capture({ hotkey: args.hotkey });
    let take: Take | null = null;
    let pending: Float32Array[] = [], pendingLen = 0;
    let feeding: Promise<void> = Promise.resolve();
    const flush = () => {
      if (!take || pendingLen === 0) return;
      const buffer = new Float32Array(pendingLen);
      let offset = 0;
      for (const part of pending) { buffer.set(part, offset); offset += part.length; }
      pending = []; pendingLen = 0;
      const current = take;
      feeding = feeding.then(() => current.feed(buffer)).catch(error => { deps.note(style.dim(`feed failed: ${message(error)}`) + "\n"); });
    };
    const begin = async () => {
      if (take) return;
      take = await startTake();
      pending = []; pendingLen = 0;
      deps.note(style.bold("● recording") + style.dim(args.hotkey ? " (release to stop)\n" : " (Enter to stop)\n"));
    };
    const end = async () => {
      if (!take) return;
      flush();
      await feeding;
      const current = take; take = null;
      deps.note(style.dim("transcribing… "));
      try {
        const { text, ms } = await current.finish();
        deps.note(style.dim(`${ms.toFixed(0)} ms\n`));
        await deliver(text);
      } catch (error) { deps.note(`transcription failed: ${message(error)}\n`); }
    };

    const input = new AbortController();
    let quit = false, failure: string | null = null;
    const stop = () => { quit = true; return mic.stop(); };
    const onAbort = () => { void stop(); };
    if (signal?.aborted) void stop(); else signal?.addEventListener("abort", onAbort, { once: true });
    let keys: Promise<void> = Promise.resolve();
    if (!args.hotkey) {
      deps.note(style.dim("Enter: start/stop a take · q: quit") + "\n");
      keys = (async () => {
        try {
          for await (const line of deps.lines(input.signal)) {
            if (quit) return;
            if (line.trim() === "q") { await stop(); return; }
            if (take) await end(); else await begin();
          }
        } catch (error) {
          if (input.signal.aborted) return;
          failure ??= message(error);
          await stop();
        }
      })();
      keys.catch(() => {});
    }
    try {
      for await (const event of mic.events) {
        if (quit) continue;
        if (event.kind === "ready") { if (args.hotkey) deps.note(style.dim(`hold key ${args.hotkey} to talk · Ctrl-C quits · mic ${event.info}`) + "\n"); }
        else if (event.kind === "error") { failure ??= event.message; await stop(); }
        else if (event.kind === "hotkey") { if (event.down) await begin(); else await end(); }
        else if (event.kind === "pcm" && take) {
          pending.push(event.samples); pendingLen += event.samples.length;
          if (pendingLen >= 16_000 / 4) flush(); // every 250 ms of audio
        }
      }
    } finally {
      signal?.removeEventListener("abort", onAbort);
      input.abort();
      await stop();
      try { await keys; } catch (error) { failure ??= message(error); }
    }
    if (failure !== null) throw new Error(failure);
  } finally { service?.close(); }
}
