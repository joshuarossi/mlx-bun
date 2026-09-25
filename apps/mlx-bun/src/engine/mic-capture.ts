// Microphone capture for `mlx-bun dictate`: spawns the AVAudioEngine sidecar
// (native/mic-capture.swift → `mlx-bun-mic-capture`), yields 16 kHz float32
// PCM chunks and hotkey down/up events. Main's `src/audio/mic-capture.ts`.
// Resolution mirrors the library's frame extractor: env override → beside the
// standalone executable → the app's staged dist/native. Stopping ends the
// sidecar's stdin, terminates it, and joins it, so no capture process outlives
// the verb.

import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";

export const MIC_CAPTURE_BINARY = "mlx-bun-mic-capture";
const APP_ROOT = join(import.meta.dir, "..", "..");
export const MIC_CAPTURE_STAGED = join(APP_ROOT, "dist", "native", MIC_CAPTURE_BINARY);

export interface MicCaptureCandidates {
  /** MLX_BUN_MIC_CAPTURE: used as given, like the library's native overrides. */
  explicit?: string;
  /** Beside the executable; only meaningful for the standalone binary. */
  sibling: string | null;
  /** Published package asset, staged explicitly by `build:native`. */
  staged: string;
}

export function defaultMicCaptureCandidates(): MicCaptureCandidates {
  return {
    explicit: runtimeValue("MLX_BUN_MIC_CAPTURE"),
    sibling: import.meta.filename.startsWith("/$bunfs/") ? join(dirname(process.execPath), MIC_CAPTURE_BINARY) : null,
    staged: MIC_CAPTURE_STAGED,
  };
}

export async function resolveMicCapture(candidates: MicCaptureCandidates = defaultMicCaptureCandidates()): Promise<string | null> {
  if (candidates.explicit) return candidates.explicit;
  if (candidates.sibling && existsSync(candidates.sibling)) return candidates.sibling;
  if (existsSync(candidates.staged)) return candidates.staged;
  return null;
}

export type MicEvent =
  | { kind: "ready"; info: string }
  | { kind: "pcm"; samples: Float32Array }
  | { kind: "hotkey"; down: boolean }
  | { kind: "error"; message: string };

export interface MicCapture {
  /** Ends once the sidecar's stdout closes (after `stop`, or when it exits on its own). */
  events: AsyncIterable<MicEvent>;
  /** End stdin, terminate, and join the sidecar; idempotent. */
  stop(): Promise<void>;
  /** The sidecar's exit code. */
  exited: Promise<number>;
}

export interface MicCaptureOptions {
  /** macOS virtual keycode for hold-to-talk (61 = Right Option); null = no key tap. */
  hotkey?: number | null;
  resolve?: () => Promise<string | null>;
  /** SIGKILL a sidecar that ignores SIGTERM after this long. */
  killGraceMs?: number;
}

export async function startMicCapture(options: MicCaptureOptions = {}): Promise<MicCapture> {
  const bin = await (options.resolve ?? resolveMicCapture)();
  if (!bin) throw new Error(`microphone capture needs the ${MIC_CAPTURE_BINARY} sidecar (reinstall the app, or in a source checkout run: bun run --filter mlx-bun build:native)`);
  const args = [bin, "--rate", "16000"];
  if (options.hotkey != null) args.push("--hotkey", String(options.hotkey));
  const proc = Bun.spawn(args, { stdin: "pipe", stdout: "pipe", stderr: "pipe" });
  const queue: MicEvent[] = [];
  let wake: (() => void) | null = null;
  let done = false;
  const notify = () => { const w = wake; wake = null; w?.(); };
  const push = (event: MicEvent) => { queue.push(event); notify(); };
  void (async () => {
    // Little-endian float32 frames; a chunk boundary inside a sample carries over.
    let carry = new Uint8Array(0);
    for await (const chunk of proc.stdout) {
      const buf = new Uint8Array(carry.length + chunk.length);
      buf.set(carry); buf.set(chunk, carry.length);
      const usable = buf.length - (buf.length % 4);
      if (usable > 0) push({ kind: "pcm", samples: new Float32Array(buf.buffer.slice(0, usable)) });
      carry = buf.subarray(usable);
    }
    done = true; notify();
  })();
  void (async () => {
    let text = "";
    const decoder = new TextDecoder();
    for await (const chunk of proc.stderr) {
      text += decoder.decode(chunk, { stream: true });
      let nl: number;
      while ((nl = text.indexOf("\n")) >= 0) {
        const line = text.slice(0, nl).trim(); text = text.slice(nl + 1);
        if (line.startsWith("ready")) push({ kind: "ready", info: line.slice(5).trim() });
        else if (line === "hotkey down") push({ kind: "hotkey", down: true });
        else if (line === "hotkey up") push({ kind: "hotkey", down: false });
        else if (line.startsWith("error:")) push({ kind: "error", message: line.slice(6).trim() });
      }
    }
  })();
  const events: AsyncIterable<MicEvent> = {
    async *[Symbol.asyncIterator]() {
      while (!done || queue.length) {
        if (queue.length) { yield queue.shift()!; continue; }
        await new Promise<void>(resolve => { wake = resolve; });
      }
    },
  };
  let stopping: Promise<void> | undefined;
  const stop = () => stopping ??= (async () => {
    try { proc.stdin.end(); } catch { /* gone */ }
    try { proc.kill(); } catch { /* exited */ }
    const grace = setTimeout(() => { try { proc.kill("SIGKILL"); } catch { /* exited */ } }, options.killGraceMs ?? 2000);
    try { await proc.exited; } finally { clearTimeout(grace); }
  })();
  return { events, stop, exited: proc.exited };
}
