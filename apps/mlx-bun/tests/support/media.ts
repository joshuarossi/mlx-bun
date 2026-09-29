// Media synthesized for the opt-in real-weight tests; nothing is committed.
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { deflateSync } from "node:zlib";

/** An RGB PNG with a seeded pattern (stored with zlib, filter byte 0 per row), base64. */
export function pngBase64(seed: number, width = 64, height = 48): string {
  const crcTable = Array.from({ length: 256 }, (_, n) => {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    return c >>> 0;
  });
  const crc = (bytes: Uint8Array) => {
    let c = 0xffffffff;
    for (const byte of bytes) c = crcTable[(c ^ byte) & 0xff]! ^ (c >>> 8);
    return (c ^ 0xffffffff) >>> 0;
  };
  const chunk = (type: string, data: Uint8Array) => {
    const body = new Uint8Array(4 + data.length);
    body.set(new TextEncoder().encode(type)); body.set(data, 4);
    const out = new Uint8Array(12 + data.length), view = new DataView(out.buffer);
    view.setUint32(0, data.length); out.set(body, 4); view.setUint32(8 + data.length, crc(body));
    return out;
  };
  const header = new Uint8Array(13), view = new DataView(header.buffer);
  view.setUint32(0, width); view.setUint32(4, height); header.set([8, 2, 0, 0, 0], 8);
  const rows = new Uint8Array(height * (1 + width * 3));
  for (let y = 0; y < height; y++) for (let x = 0; x < width; x++) {
    const at = y * (1 + width * 3) + 1 + x * 3;
    rows.set([(x * seed) % 256, (y * 7 + seed) % 256, (x + y * seed) % 256], at);
  }
  const bytes = [new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10]), chunk("IHDR", header),
    chunk("IDAT", deflateSync(rows)), chunk("IEND", new Uint8Array())];
  return Buffer.concat(bytes).toString("base64");
}

/** A sine tone at 16 kHz, amplitude 0.3. */
export function tone(seconds: number, hz: number): Float32Array {
  const rate = 16_000;
  return Float32Array.from({ length: Math.round(seconds * rate) }, (_, i) => Math.sin(2 * Math.PI * hz * i / rate) * 0.3);
}

/** 16-bit mono PCM WAV at 16 kHz. */
export function wavBytes(samples: Float32Array): Uint8Array<ArrayBuffer> {
  const rate = 16_000, frames = samples.length, buffer = new ArrayBuffer(44 + frames * 2), view = new DataView(buffer);
  const ascii = (offset: number, text: string) => { for (let i = 0; i < text.length; i++) view.setUint8(offset + i, text.charCodeAt(i)); };
  ascii(0, "RIFF"); view.setUint32(4, 36 + frames * 2, true); ascii(8, "WAVE"); ascii(12, "fmt ");
  view.setUint32(16, 16, true); view.setUint16(20, 1, true); view.setUint16(22, 1, true); view.setUint32(24, rate, true);
  view.setUint32(28, rate * 2, true); view.setUint16(32, 2, true); view.setUint16(34, 16, true); ascii(36, "data"); view.setUint32(40, frames * 2, true);
  for (let i = 0; i < frames; i++) view.setInt16(44 + i * 2, Math.round(Math.max(-1, Math.min(1, samples[i]!)) * 32767), true);
  return new Uint8Array(buffer);
}

/** Samples of a 16-bit mono WAV, walking its chunks to `data`. */
export function wavSamples(bytes: Uint8Array): Float32Array {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const tag = (offset: number) => String.fromCharCode(...bytes.subarray(offset, offset + 4));
  if (tag(0) !== "RIFF" || tag(8) !== "WAVE") throw new Error("not a WAV file");
  for (let offset = 12; offset + 8 <= bytes.length;) {
    const size = view.getUint32(offset + 4, true);
    if (tag(offset) === "fmt " && (view.getUint16(offset + 8, true) !== 1 || view.getUint16(offset + 10, true) !== 1
      || view.getUint32(offset + 12, true) !== 16_000 || view.getUint16(offset + 22, true) !== 16))
      throw new Error("expected 16-bit mono PCM at 16 kHz");
    if (tag(offset) === "data")
      return Float32Array.from({ length: size / 2 }, (_, i) => view.getInt16(offset + 8 + i * 2, true) / 32768);
    offset += 8 + size + (size % 2);
  }
  throw new Error("WAV file has no data chunk");
}

export const SPEECH_TEXT = "The quick brown fox jumps over the lazy dog.";
export const SPEECH_WORDS = ["quick", "brown", "fox", "lazy", "dog"];
/** macOS text-to-speech written to a file (no audio device), when both tools exist. */
export const speechTools = Bun.which("say") !== null && Bun.which("afconvert") !== null;

/** Synthesized English speech as a 16 kHz mono WAV and its samples. */
export async function speech(dir: string, text = SPEECH_TEXT): Promise<{ path: string; bytes: Uint8Array; samples: Float32Array }> {
  const aiff = join(dir, "speech.aiff"), path = join(dir, "speech.wav");
  for (const command of [["say", "-o", aiff, text], ["afconvert", "-f", "WAVE", "-d", "LEI16@16000", "-c", "1", aiff, path]]) {
    const run = Bun.spawnSync(command, { stdout: "ignore", stderr: "pipe" });
    if (run.exitCode !== 0) throw new Error(`${command[0]} failed: ${run.stderr.toString()}`);
  }
  const bytes = new Uint8Array(readFileSync(path));
  return { path, bytes, samples: wavSamples(bytes) };
}

/** Expected words absent from a transcript (case and punctuation ignored). */
export function missingWords(transcript: string, words = SPEECH_WORDS): string[] {
  const heard = new Set(transcript.toLowerCase().replace(/[^a-z\s]/g, " ").split(/\s+/).filter(Boolean));
  return words.filter(word => !heard.has(word));
}
