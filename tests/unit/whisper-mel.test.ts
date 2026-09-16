// Model-free Whisper front-end checks: mel filter bank invariants, the
// periodic Hann window, frame counting, and the GPU log-mel on a synthetic
// tone (shape, range, dtype). Bit-exactness vs the oracle is the parity
// test's job (tests/parity/whisper.test.ts).

import { describe, expect, test } from "bun:test";
import {
  WHISPER_N_FRAMES, WHISPER_N_SAMPLES, WhisperMelExtractor, padOrTrimFrames,
  whisperHannWindow, whisperMelFilters,
} from "../../src/audio/whisper-mel";
import { Dtype } from "../../src/mlx/ffi";

describe("whisper mel front-end (model-free)", () => {
  test("slaney filter bank: 128 × 201, unit-area triangles, DC bin empty", () => {
    const f = whisperMelFilters(128);
    expect(f.length).toBe(128 * 201);
    for (let i = 0; i < 128; i++) {
      let sum = 0;
      let nonzero = 0;
      for (let k = 0; k < 201; k++) { sum += f[i * 201 + k]!; if (f[i * 201 + k]! > 0) nonzero++; }
      expect(nonzero).toBeGreaterThan(0);
      expect(sum).toBeGreaterThan(0);
    }
    // bin 0 (0 Hz) is covered by no filter; the top filter reaches Nyquist
    for (let i = 0; i < 128; i++) expect(f[i * 201]).toBe(0);
    expect(f[127 * 201 + 200]).toBe(0);
    // librosa's 80-bin bank is the v1/v2 layout; both build
    expect(whisperMelFilters(80).length).toBe(80 * 201);
  });

  test("periodic Hann window", () => {
    const w = whisperHannWindow();
    expect(w.length).toBe(400);
    expect(w[0]).toBe(0);
    expect(w[200]).toBeCloseTo(1, 6);
    expect(w[1]).toBeCloseTo(w[399]!, 6);
  });

  test("frame count matches the oracle stft (len/160 for hop multiples)", () => {
    expect(WhisperMelExtractor.frameCount(WHISPER_N_SAMPLES)).toBe(WHISPER_N_FRAMES);
    expect(WhisperMelExtractor.frameCount(176_000, WHISPER_N_SAMPLES)).toBe(4100);
    expect(WhisperMelExtractor.frameCount(16_000)).toBe(100);
  });

  test("log-mel of a 1 kHz tone: [T,128] float32, 2.0 dynamic range, peak near the 1 kHz bin", () => {
    const n = 16_000;
    const s = new Float32Array(n);
    for (let i = 0; i < n; i++) s[i] = 0.5 * Math.sin((2 * Math.PI * 1000 * i) / 16_000);
    const ex = new WhisperMelExtractor(128);
    const mel = ex.logMel(s, 0);
    expect(mel.shape).toEqual([100, 128]);
    expect(mel.dtype).toBe(Dtype.float32);
    const v = mel.toFloat32();
    let max = -Infinity;
    let min = Infinity;
    for (const x of v) { max = Math.max(max, x); min = Math.min(min, x); }
    // dynamic range is clamped to 8 dB-decades below the peak → (x+4)/4 spans ≤ 2
    expect(max - min).toBeLessThanOrEqual(2.0 + 1e-6);
    expect(min).toBeGreaterThanOrEqual(max - 2.0 - 1e-6);
    // frame 50: argmax mel bin should sit where 1 kHz lands (slaney: bin ~ 15·(128/…))
    let best = 0;
    for (let k = 1; k < 128; k++) if (v[50 * 128 + k]! > v[50 * 128 + best]!) best = k;
    expect(best).toBeGreaterThan(30);
    expect(best).toBeLessThan(60);
    const padded = padOrTrimFrames(mel, WHISPER_N_FRAMES, Dtype.float16);
    expect(padded.shape).toEqual([WHISPER_N_FRAMES, 128]);
    expect(padded.dtype).toBe(Dtype.float16);
    const trimmed = padOrTrimFrames(mel, 10, Dtype.float32);
    expect(trimmed.shape).toEqual([10, 128]);
    for (const a of [mel, padded, trimmed]) a.dispose();
    ex.dispose();
  });
});
