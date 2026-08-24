// Regenerate the tracked audio test fixtures (fixtures/audio/).
//
//   bun scripts/regen.ts audio-fixtures
//
// - chirp-1s6.wav: fully deterministic 1.6 s FM warble — carrier 900 Hz
//   ± 400 Hz at 1.5 Hz, amp 0.6, 10 ms raised-cosine fades, 16 kHz mono
//   PCM16. Chosen empirically against the oracle (2026-07-07): e4b greedily
//   grounds this as "cricket chirping"; a linear 200→4000 Hz sweep decodes
//   as "dog barking" and can't pass the tone-grounded gate. The synthesis
//   mirrors the numpy original bit-for-bit: float64 throughout, INCLUSIVE
//   sequential cumsum for the phase (sample 0 already includes inst_f[0]),
//   2π·cumsum/sr association, round-half-to-EVEN quantization.
// - speech-fox.wav: ~2.7 s spoken sentence synthesized with macOS `say`
//   (voice/OS dependent, so the OUTPUT is tracked; regen only when
//   intentionally refreshing). Pipeline: say → aiff → afconvert to 16 kHz
//   mono PCM16 WAV.
//
// After regenerating EITHER fixture, rerun the oracle goldens:
//   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/oracle/gen-e4b-audio-golden.py

import { $ } from "bun";
import { mkdirSync } from "node:fs";
import { join } from "node:path";

const outDir = join(import.meta.dir, "..", "fixtures", "audio");
mkdirSync(outDir, { recursive: true });

// --- chirp warble (deterministic) -------------------------------------------
const SR = 16_000;
const N = 25_600; // 1.6 s
const x = new Float64Array(N);
let phaseAcc = 0;
for (let i = 0; i < N; i++) {
  const t = i / SR;
  phaseAcc += 900.0 + 400.0 * Math.sin(2 * Math.PI * 1.5 * t); // inclusive cumsum
  x[i] = 0.6 * Math.sin((2 * Math.PI * phaseAcc) / SR);
}
const FADE = 160; // int(0.010 * 16000)
for (let k = 0; k < FADE; k++) {
  const ramp = 0.5 - 0.5 * Math.cos((Math.PI * k) / FADE); // ramp[0]=0, never hits 1
  x[k]! *= ramp;
  x[N - 1 - k]! *= ramp; // reversed: final sample fades to exactly 0
}
// np.round semantics: round-half-to-even (JS Math.round is half-away-from-zero).
const roundHalfEven = (v: number): number => {
  const f = Math.floor(v);
  const d = v - f;
  if (d !== 0.5) return Math.round(v);
  return f % 2 === 0 ? f : f + 1;
};
const pcm = new Int16Array(N);
for (let i = 0; i < N; i++) pcm[i] = roundHalfEven(x[i]! * 32767.0);

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
let peak = 0;
for (let i = 0; i < N; i++) peak = Math.max(peak, Math.abs(pcm[i]!));
console.log(`wrote ${chirpPath} (${N} samples @ ${SR} Hz, peak ${peak} — expect 19660)`);

// --- speech (say → afconvert) ----------------------------------------------
if (process.argv.includes("--speech")) {
  const tmpAiff = join(outDir, ".speech-tmp.aiff");
  const speechPath = join(outDir, "speech-fox.wav");
  await $`say -o ${tmpAiff} "The quick brown fox jumps over the lazy dog."`;
  await $`afconvert -f WAVE -d LEI16@16000 -c 1 ${tmpAiff} ${speechPath}`;
  await $`rm -f ${tmpAiff}`;
  console.log(`wrote ${speechPath} (${Bun.file(speechPath).size} bytes)`);
} else {
  console.log("speech-fox.wav left untouched (pass --speech to re-synthesize; voice-dependent)");
}
