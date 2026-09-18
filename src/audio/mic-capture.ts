// Microphone capture for `mlx-bun dictate`: spawns the AVAudioEngine
// sidecar (src/native/mic_capture.swift, `mlx-bun-mic-capture`), yields
// 16 kHz float32 PCM chunks and hotkey down/up events. Resolution mirrors
// the video frame extractor: env override → beside the binary → the
// native-pack dir → dev-compile from source with swiftc.

import { existsSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { nativeRuntimeDir } from "../native-pack";
import { runtimeValue } from "../runtime-config";

const BIN = "mlx-bun-mic-capture";
let devCompile: Promise<string | null> | null = null;

function compileFromSource(): Promise<string | null> {
  devCompile ??= (async () => {
    const src = join(import.meta.dir, "..", "native", "mic_capture.swift");
    if (!existsSync(src)) return null;
    const out = join(import.meta.dir, "..", "..", "dist-native", BIN);
    try {
      mkdirSync(dirname(out), { recursive: true });
      const proc = Bun.spawn(["swiftc", "-O", src, "-o", out], { stdout: "ignore", stderr: "pipe" });
      if ((await proc.exited) === 0 && existsSync(out)) return out;
    } catch { /* no swiftc */ }
    return null;
  })();
  return devCompile;
}

export async function resolveMicCapture(): Promise<string | null> {
  const explicit = runtimeValue("MLX_BUN_MIC_CAPTURE");
  if (explicit) return explicit;
  const beside = join(dirname(process.execPath), BIN);
  if (existsSync(beside)) return beside;
  const dir = nativeRuntimeDir();
  if (dir && existsSync(join(dir, BIN))) return join(dir, BIN);
  const dev = join(import.meta.dir, "..", "..", "dist-native", BIN);
  if (existsSync(dev)) return dev;
  return compileFromSource();
}

export type MicEvent =
  | { kind: "ready"; info: string }
  | { kind: "pcm"; samples: Float32Array }
  | { kind: "hotkey"; down: boolean }
  | { kind: "error"; message: string };

export interface MicCapture {
  events: AsyncIterable<MicEvent>;
  stop(): void;
}

/** Start capturing. `hotkey` is a macOS virtual keycode (61 = Right Option). */
export async function startMicCapture(opts: { hotkey?: number | null } = {}): Promise<MicCapture> {
  const bin = await resolveMicCapture();
  if (!bin) throw new Error("microphone capture needs the mlx-bun-mic-capture sidecar (build: scripts/build-mic-capture.sh, needs swiftc)");
  const args = [bin, "--rate", "16000"];
  if (opts.hotkey != null) args.push("--hotkey", String(opts.hotkey));
  const proc = Bun.spawn(args, { stdin: "pipe", stdout: "pipe", stderr: "pipe" });
  const queue: MicEvent[] = [];
  const waiter: { fn: (() => void) | null } = { fn: null };
  let done = false;
  const push = (e: MicEvent) => { queue.push(e); const w = waiter.fn; waiter.fn = null; w?.(); };
  (async () => {
    let carry = new Uint8Array(0);
    for await (const chunk of proc.stdout) {
      const buf = new Uint8Array(carry.length + chunk.length);
      buf.set(carry); buf.set(chunk, carry.length);
      const usable = buf.length - (buf.length % 4);
      if (usable > 0) push({ kind: "pcm", samples: new Float32Array(buf.buffer.slice(0, usable)) });
      carry = buf.subarray(usable);
    }
    done = true; const w = waiter.fn; waiter.fn = null; w?.();
  })();
  (async () => {
    let text = "";
    for await (const chunk of proc.stderr) {
      text += new TextDecoder().decode(chunk);
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
        await new Promise<void>((r) => { waiter.fn = r; });
      }
    },
  };
  return { events, stop: () => { try { proc.stdin.end(); } catch { /* gone */ } proc.kill(); } };
}
