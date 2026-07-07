// Regenerate the tracked audio test fixtures (fixtures/audio/).
//
//   bun scripts/regen-audio-fixtures.ts
//
// - chirp-1s6.wav: fully deterministic 1.6 s linear chirp 200→4000 Hz,
//   16 kHz mono PCM16 — the byte-stable parity fixture (T0 mel goldens).
// - speech-fox.wav: ~2.5 s spoken sentence synthesized with macOS `say`
//   (voice-dependent, so the OUTPUT is tracked; regen only when
//   intentionally refreshing the fixture, then regen the goldens too).
//   Pipeline: say → aiff → afconvert to 16 kHz mono PCM16 WAV.

import { $ } from "bun";
import { mkdirSync } from "node:fs";
import { join } from "node:path";

const outDir = join(import.meta.dir, "..", "fixtures", "audio");
mkdirSync(outDir, { recursive: true });

// --- chirp (deterministic) -------------------------------------------------
const SR = 16_000;
const DUR = 1.6;
const N = Math.round(SR * DUR);
const F0 = 200;
const F1 = 4000;
const pcm = new Int16Array(N);
for (let i = 0; i < N; i++) {
  const t = i / SR;
  // linear chirp: phase = 2π (f0 t + (f1-f0) t² / (2 dur))
  const phase = 2 * Math.PI * (F0 * t + ((F1 - F0) * t * t) / (2 * DUR));
  // 0.5 amplitude with a 10 ms cosine fade at both ends (no clicks)
  const fade = Math.min(1, (SR * 0.01), i, N - 1 - i) / (SR * 0.01);
  const env = 0.5 * (fade >= 1 ? 1 : 0.5 - 0.5 * Math.cos(Math.PI * fade));
  pcm[i] = Math.round(32767 * env * Math.sin(phase));
}

function wavBytes(samples: Int16Array, sampleRate: number): Uint8Array {
  const dataLen = samples.length * 2;
  const buf = new ArrayBuffer(44 + dataLen);
  const v = new DataView(buf);
  const wr = (o: number, s: string) => { for (let i = 0; i < s.length; i++) v.setUint8(o + i, s.charCodeAt(i)); };
  wr(0, "RIFF"); v.setUint32(4, 36 + dataLen, true); wr(8, "WAVE");
  wr(12, "fmt "); v.setUint32(16, 16, true); v.setUint16(20, 1, true); // PCM
  v.setUint16(22, 1, true); v.setUint32(24, sampleRate, true);
  v.setUint32(28, sampleRate * 2, true); v.setUint16(32, 2, true); v.setUint16(34, 16, true);
  wr(36, "data"); v.setUint32(40, dataLen, true);
  new Int16Array(buf, 44).set(samples);
  return new Uint8Array(buf);
}

const chirpPath = join(outDir, "chirp-1s6.wav");
await Bun.write(chirpPath, wavBytes(pcm, SR));
console.log(`wrote ${chirpPath} (${N} samples @ ${SR} Hz)`);

// --- speech (say → afconvert) ----------------------------------------------
const tmpAiff = join(outDir, ".speech-tmp.aiff");
const speechPath = join(outDir, "speech-fox.wav");
await $`say -o ${tmpAiff} "The quick brown fox jumps over the lazy dog."`;
await $`afconvert -f WAVE -d LEI16@16000 -c 1 ${tmpAiff} ${speechPath}`;
await $`rm -f ${tmpAiff}`;
const sz = Bun.file(speechPath).size;
console.log(`wrote ${speechPath} (${sz} bytes)`);
