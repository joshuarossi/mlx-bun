// AudioToolbox in-process decode (darwin): WAV decodes bit-identically to
// the PCM parser; an afconvert-made m4a of the same clip decodes to a
// highly correlated 16 kHz signal of the same length.

import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync, unlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { decodeBytesWithAudioToolbox, decodeFileWithAudioToolbox } from "../../src/audio/audiotoolbox";
import { decodeWav } from "../../src/audio/decode";

const FOX = `${import.meta.dir}/../../fixtures/audio/speech-fox.wav`;

describe.skipIf(process.platform !== "darwin")("AudioToolbox decode", () => {
  test("wav: identical to the PCM parser", () => {
    const ref = decodeWav(new Uint8Array(readFileSync(FOX))).samples;
    const at = decodeFileWithAudioToolbox(FOX);
    expect(at.length).toBe(ref.length);
    let maxAbs = 0;
    for (let i = 0; i < ref.length; i++) maxAbs = Math.max(maxAbs, Math.abs(at[i]! - ref[i]!));
    expect(maxAbs).toBe(0);
  });

  test("m4a (afconvert) round trip correlates > 0.95", () => {
    const out = `${tmpdir()}/mlx-bun-at-test-${process.pid}.m4a`;
    const r = Bun.spawnSync(["afconvert", "-f", "m4af", "-d", "aac", FOX, out]);
    if (r.exitCode !== 0 || !existsSync(out)) return; // afconvert unavailable → nothing to assert
    try {
      const ref = decodeWav(new Uint8Array(readFileSync(FOX))).samples;
      const dec = decodeBytesWithAudioToolbox(new Uint8Array(readFileSync(out)));
      expect(Math.abs(dec.length - ref.length)).toBeLessThan(4096); // encoder priming/padding
      // AAC adds a codec delay; find the best lag over ±2048 samples
      let best = 0;
      for (let lag = -2048; lag <= 2048; lag += 64) {
        let c = 0, a = 0, b = 0;
        for (let i = 4096; i < Math.min(ref.length, dec.length) - 4096; i += 3) {
          const x = ref[i]!, y = dec[i + lag] ?? 0;
          c += x * y; a += x * x; b += y * y;
        }
        best = Math.max(best, c / Math.sqrt(a * b));
      }
      expect(best).toBeGreaterThan(0.95);
    } finally {
      try { unlinkSync(out); } catch { /* ignore */ }
    }
  });

  test("garbage bytes throw", () => {
    expect(() => decodeBytesWithAudioToolbox(new Uint8Array(200))).toThrow();
  });
});
