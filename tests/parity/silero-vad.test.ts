// Silero VAD port vs the silero-vad 6.2.1 reference (goldens/silero-vad.json,
// tracked): per-chunk probabilities within 5e-3 (the ggml weights are fp16)
// and identical speech segments under sotto's parameters and the defaults.
// Needs ggml-org/whisper-vad's ggml-silero-v6.2.0.bin in the HF cache.

import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import { decodeWav } from "../../src/audio/decode";
import { SileroVad, resolveSileroVadPath } from "../../src/audio/silero-vad";
import { goldenPath } from "../support/goldens";

const ROOT = `${import.meta.dir}/../..`;
const manifestPath = goldenPath("silero-vad.json");
const manifest = existsSync(manifestPath) ? await Bun.file(manifestPath).json() : null;
const ready = !!manifest && resolveSileroVadPath() !== null;

/** numpy default_rng(0).standard_normal is not reproducible here; the noise
 *  clip only asserts "no speech", so any low-level noise serves. */
function clipFor(name: string, n: number): Float32Array | null {
  if (name === "fox") return decodeWav(new Uint8Array(readFileSync(`${ROOT}/fixtures/audio/speech-fox.wav`))).samples;
  if (name === "chirp") return decodeWav(new Uint8Array(readFileSync(`${ROOT}/fixtures/audio/chirp-1s6.wav`))).samples;
  if (name === "silence") return new Float32Array(n);
  if (name === "jfk") {
    const p = `${process.env.HOME}/Code/sotto/vendor/whisper.cpp/samples/jfk.wav`;
    return existsSync(p) ? decodeWav(new Uint8Array(readFileSync(p))).samples : null;
  }
  return null;
}

describe.skipIf(!ready)("silero vad parity", () => {
  const vad = ready ? SileroVad.load() : null!;
  for (const [name, clip] of Object.entries((manifest?.clips ?? {}) as Record<string, { num_samples: number; probs: number[]; segments: { start: number; end: number }[]; segments_default: { start: number; end: number }[] }>)) {
    const samples = ready ? clipFor(name, clip.num_samples) : null;
    test.skipIf(!samples)(`probs + segments: ${name}`, () => {
      const probs = vad.probs(samples!);
      expect(probs.length).toBe(clip.probs.length);
      let maxAbs = 0;
      for (let i = 0; i < probs.length; i++) maxAbs = Math.max(maxAbs, Math.abs(probs[i]! - clip.probs[i]!));
      expect(maxAbs).toBeLessThan(5e-3);
      expect(SileroVad.speechTimestamps(probs, samples!.length, { threshold: 0.5, minSpeechDurationMs: 120 })).toEqual(clip.segments);
      expect(SileroVad.speechTimestamps(probs, samples!.length)).toEqual(clip.segments_default);
    });
  }
  test("streaming state matters: chunk context is carried", () => {
    const fox = clipFor("fox", 0)!;
    const a = vad.probs(fox);
    const b = vad.probs(fox.subarray(512)); // dropping the first chunk shifts the LSTM state
    expect(a.length).toBe(b.length + 1);
    expect(Math.abs(a[5]! - b[4]!)).toBeGreaterThan(0); // not identical
  });
});
