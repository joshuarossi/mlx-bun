// FAST (no model load): T0 gates for audio input (A1 of
// docs/design/generic-model-support.md) — WAV decode, soft-token counts, and the
// USM mel extractor vs the oracle goldens dumped by
// scripts/oracle/gen-e4b-audio-golden.py. The mel .bin blobs are untracked and
// regenerable; the tensor-compare tests skip when they're absent
// (goldens/README.md presence-gating convention). Everything else runs on
// the tracked fixtures + manifest alone.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { audioSoftTokenCount, decodeAudio, decodeWav } from "../../src/audio/decode";
import { extractMelFeatures } from "../../src/audio/features";
import { goldenPath } from "../support/goldens";

const FIXTURES = `${import.meta.dir}/../../fixtures/audio`;
const manifestPath = goldenPath("e4b-audio.json");
const manifest = existsSync(manifestPath) ? await Bun.file(manifestPath).json() : null;

const melGoldens: Record<string, Float32Array | null> = {};
for (const n of ["chirp", "speech"]) {
  const p = goldenPath(`e4b-audio-${n}-mel.bin`);
  melGoldens[n] = existsSync(p) ? new Float32Array(await Bun.file(p).arrayBuffer()) : null;
}

describe("audio decode (model-free)", () => {
  test("chirp fixture: 16 kHz mono PCM16, 25600 samples, 40 soft tokens", async () => {
    const bytes = new Uint8Array(await Bun.file(`${FIXTURES}/chirp-1s6.wav`).arrayBuffer());
    const { samples, sampleRate } = decodeWav(bytes);
    expect(sampleRate).toBe(16_000);
    expect(samples.length).toBe(25_600);
    expect(audioSoftTokenCount(samples.length)).toBe(40);
    // oracle scaling contract: int16 / 32768
    let peak = 0;
    for (const s of samples) peak = Math.max(peak, Math.abs(s));
    expect(peak).toBeCloseTo(19660 / 32768, 6);
  });

  test("speech fixture: 67 soft tokens", async () => {
    const bytes = new Uint8Array(await Bun.file(`${FIXTURES}/speech-fox.wav`).arrayBuffer());
    const samples = decodeAudio(bytes);
    expect(audioSoftTokenCount(samples.length)).toBe(67);
  });

  test("soft-token cap: >30 s clips at 750", () => {
    expect(audioSoftTokenCount(16_000 * 31)).toBe(750);
    expect(audioSoftTokenCount(0)).toBe(0);
  });

  test("stereo mixdown + resample passthrough shape", () => {
    // hand-built 8-frame stereo PCM16 WAV @ 16 kHz: L = 1000, R = 3000
    const frames = 8;
    const buf = new ArrayBuffer(44 + frames * 4);
    const v = new DataView(buf);
    const wr = (o: number, s: string) => { for (let i = 0; i < s.length; i++) v.setUint8(o + i, s.charCodeAt(i)); };
    wr(0, "RIFF"); v.setUint32(4, 36 + frames * 4, true); wr(8, "WAVE");
    wr(12, "fmt "); v.setUint32(16, 16, true); v.setUint16(20, 1, true);
    v.setUint16(22, 2, true); v.setUint32(24, 16_000, true);
    v.setUint32(28, 64_000, true); v.setUint16(32, 4, true); v.setUint16(34, 16, true);
    wr(36, "data"); v.setUint32(40, frames * 4, true);
    for (let f = 0; f < frames; f++) {
      v.setInt16(44 + f * 4, 1000, true);
      v.setInt16(44 + f * 4 + 2, 3000, true);
    }
    const { samples, sampleRate } = decodeWav(new Uint8Array(buf));
    expect(sampleRate).toBe(16_000);
    expect(samples.length).toBe(frames);
    expect(samples[0]).toBeCloseTo(2000 / 32768, 6);
  });
});

describe("USM mel extraction (model-free)", () => {
  test("frame counts + full-validity masks match the oracle", async () => {
    const chirp = decodeAudio(new Uint8Array(await Bun.file(`${FIXTURES}/chirp-1s6.wav`).arrayBuffer()));
    const speech = decodeAudio(new Uint8Array(await Bun.file(`${FIXTURES}/speech-fox.wav`).arrayBuffer()));
    const mc = extractMelFeatures(chirp);
    const ms = extractMelFeatures(speech);
    expect(mc.frames).toBe(159);
    expect(ms.frames).toBe(267);
    expect(mc.mask.every((x) => x === 1)).toBe(true);
    expect(ms.mask.every((x) => x === 1)).toBe(true);
  });

  for (const [name, file] of [["chirp", "chirp-1s6.wav"], ["speech", "speech-fox.wav"]] as const) {
    test.skipIf(!manifest || !melGoldens[name])(
      `${name} mel features match the T0 golden (tol 1e-5)`,
      async () => {
        const golden = melGoldens[name]!;
        const fx = manifest!.fixtures[name];
        const wave = decodeAudio(new Uint8Array(await Bun.file(`${FIXTURES}/${file}`).arrayBuffer()));
        const { features, frames } = extractMelFeatures(wave);
        expect([frames, 128]).toEqual(fx.mel_shape);
        expect(features.length).toBe(golden.length);
        let maxDiff = 0;
        for (let i = 0; i < golden.length; i++)
          maxDiff = Math.max(maxDiff, Math.abs(features[i]! - golden[i]!));
        expect(maxDiff).toBeLessThan(1e-5);
      },
    );
  }
});
