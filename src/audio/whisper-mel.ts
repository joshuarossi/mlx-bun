// Whisper log-mel spectrogram — an op-for-op port of mlx-whisper's
// audio.py (log_mel_spectrogram / stft / mel_filters), gated bit-exact
// against the oracle in tests/parity/whisper.test.ts.
//
// Pipeline (single 16 kHz mono float32 waveform):
//   [optional zero pad of `padding` samples on the right]
//   → reflect pad N_FFT/2 = 200 samples each side (done host-side; the
//     values are a copy so the device graph is identical)
//   → frames [T, 400] via as_strided (stride HOP = 160)
//   → × periodic Hann window (np.hanning(401)[:-1], float32)
//   → rfft n=400 → drop the LAST frame → |·|² (float32)
//   → @ melᵀ [201, 128]   (librosa slaney filters, float32 — built below)
//   → log10(max(·, 1e-10)) → max(·, global_max − 8) → (· + 4) / 4
// Output: [T, n_mels] float32 where T = (len + 400 − 400 + 160) // 160 − 1
// (the oracle's `freqs[:-1]`), i.e. exactly len/160 frames for a multiple
// of the hop.
//
// The mel filter bank reproduces librosa.filters.mel(sr=16000, n_fft=400,
// n_mels, htk=False, norm="slaney") in float64 and rounds to float32 — the
// same values mlx-whisper ships pre-computed in assets/mel_filters.npz
// (checked bit-exact by the parity test against the oracle dump).

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";

export const WHISPER_SAMPLE_RATE = 16_000;
export const WHISPER_N_FFT = 400;
export const WHISPER_HOP = 160;
export const WHISPER_CHUNK_SECONDS = 30;
/** 480_000 samples per 30 s window. */
export const WHISPER_N_SAMPLES = WHISPER_CHUNK_SECONDS * WHISPER_SAMPLE_RATE;
/** 3000 mel frames per window. */
export const WHISPER_N_FRAMES = WHISPER_N_SAMPLES / WHISPER_HOP;
/** 100 mel frames per second. */
export const WHISPER_FRAMES_PER_SECOND = WHISPER_SAMPLE_RATE / WHISPER_HOP;
/** 50 encoder positions per second (conv2 stride 2). */
export const WHISPER_TOKENS_PER_SECOND = WHISPER_SAMPLE_RATE / (WHISPER_HOP * 2);

const dispose = (old: MlxArray, next: MlxArray): MlxArray => {
  old.dispose();
  return next;
};

// --- librosa slaney mel filter bank ----------------------------------------
const F_SP = 200.0 / 3;
const MIN_LOG_HZ = 1000.0;
const MIN_LOG_MEL = MIN_LOG_HZ / F_SP; // 15
const LOGSTEP = Math.log(6.4) / 27.0;

function hzToMel(f: number): number {
  const m = f / F_SP;
  return f >= MIN_LOG_HZ ? MIN_LOG_MEL + Math.log(f / MIN_LOG_HZ) / LOGSTEP : m;
}
function melToHz(m: number): number {
  return m >= MIN_LOG_MEL ? MIN_LOG_HZ * Math.exp(LOGSTEP * (m - MIN_LOG_MEL)) : F_SP * m;
}

/** Row-major [nMels, 201] float32 — librosa.filters.mel semantics. */
export function whisperMelFilters(nMels: number): Float32Array {
  const nBins = WHISPER_N_FFT / 2 + 1; // 201
  const fmax = WHISPER_SAMPLE_RATE / 2;
  // np.fft.rfftfreq(400, 1/16000) = arange(201) * 16000/400
  // np.fft.rfftfreq: val = 1/(n·d) with d = 1/sr, then k·val — keep numpy's
  // float64 rounding (1/16000 is inexact in binary) for bit-exact filters.
  const val = 1.0 / (WHISPER_N_FFT * (1.0 / WHISPER_SAMPLE_RATE));
  const fftFreqs = new Float64Array(nBins);
  for (let k = 0; k < nBins; k++) fftFreqs[k] = k * val;
  // mel_frequencies(n_mels + 2): np.linspace in mel space, mapped to Hz
  const nPts = nMels + 2;
  const melMin = hzToMel(0);
  const melMax = hzToMel(fmax);
  const melF = new Float64Array(nPts);
  const step = (melMax - melMin) / (nPts - 1);
  for (let i = 0; i < nPts; i++) melF[i] = melToHz(melMin + step * i);
  const out = new Float32Array(nMels * nBins);
  for (let i = 0; i < nMels; i++) {
    const fd0 = melF[i + 1]! - melF[i]!;
    const fd1 = melF[i + 2]! - melF[i + 1]!;
    const enorm = 2.0 / (melF[i + 2]! - melF[i]!);
    for (let k = 0; k < nBins; k++) {
      const lower = -(melF[i]! - fftFreqs[k]!) / fd0;
      const upper = (melF[i + 2]! - fftFreqs[k]!) / fd1;
      // librosa stores the un-normalized weight into a float32 array, then
      // `weights *= enorm[:, None]` (float64 multiply, float32 store).
      const w = Math.fround(Math.max(0, Math.min(lower, upper)));
      out[i * nBins + k] = Math.fround(w * enorm);
    }
  }
  return out;
}

/** np.hanning(N+1)[:-1] as float32 (periodic Hann). */
export function whisperHannWindow(): Float32Array {
  const n = WHISPER_N_FFT;
  const w = new Float32Array(n);
  for (let i = 0; i < n; i++) w[i] = Math.fround(0.5 - 0.5 * Math.cos((2 * Math.PI * i) / n));
  return w;
}

/** Device-resident constants for one mel configuration (built once per model). */
export class WhisperMelExtractor {
  readonly nMels: number;
  /** [201, nMels] float32 — filters transposed for `magnitudes @ filtersᵀ`. */
  readonly #filtersT: MlxArray;
  /** [400] float32. */
  readonly #window: MlxArray;

  constructor(nMels: number) {
    this.nMels = nMels;
    const f = whisperMelFilters(nMels);
    const nBins = WHISPER_N_FFT / 2 + 1;
    const t = new Float32Array(nBins * nMels);
    for (let i = 0; i < nMels; i++)
      for (let k = 0; k < nBins; k++) t[k * nMels + i] = f[i * nBins + k]!;
    this.#filtersT = MlxArray.fromFloat32(t, [nBins, nMels]);
    this.#window = MlxArray.fromFloat32(whisperHannWindow(), [WHISPER_N_FFT]);
  }

  /** Number of mel frames the oracle produces for `numSamples` (+ padding). */
  static frameCount(numSamples: number, padding = 0): number {
    const len = numSamples + padding + WHISPER_N_FFT; // reflect-padded length
    return Math.floor((len - WHISPER_N_FFT + WHISPER_HOP) / WHISPER_HOP) - 1;
  }

  /** log_mel_spectrogram(audio, n_mels, padding) → [T, nMels] float32 (lazy). */
  logMel(samples: Float32Array, padding = 0): MlxArray {
    const half = WHISPER_N_FFT / 2;
    const n = samples.length + padding;
    if (samples.length <= half) throw new Error(`whisper mel: clip too short (${samples.length} samples)`);
    // host-side: zero pad right, then reflect pad `half` on both sides
    const padded = new Float32Array(n + 2 * half);
    // prefix = x[1:half+1][::-1]
    for (let i = 0; i < half; i++) padded[i] = samples[half - i] ?? 0;
    padded.set(samples, half);
    // (zero padding region already 0)
    // suffix = x[-(half+1):-1][::-1] over the ZERO-PADDED signal
    const src = (idx: number): number => (idx < samples.length ? samples[idx]! : 0);
    for (let i = 0; i < half; i++) padded[half + n + i] = src(n - 2 - i);
    const x = MlxArray.fromFloat32(padded, [padded.length]);
    const t = Math.floor((padded.length - WHISPER_N_FFT + WHISPER_HOP) / WHISPER_HOP);
    let frames = ops.asStrided(x, [t, WHISPER_N_FFT], [WHISPER_HOP, 1]);
    frames = dispose(frames, ops.mul(frames, this.#window));
    let spec = ops.rfft(frames, WHISPER_N_FFT, -1);
    frames.dispose();
    x.dispose();
    spec = dispose(spec, spec.slice([0, 0], [t - 1, WHISPER_N_FFT / 2 + 1]));
    spec = dispose(spec, ops.abs(spec));
    spec = dispose(spec, ops.square(spec));
    let mel = ops.matmul(spec, this.#filtersT);
    spec.dispose();
    const floor = ops.scalarLike(1e-10, mel);
    mel = dispose(mel, ops.maximum(mel, floor));
    floor.dispose();
    mel = dispose(mel, ops.log10(mel));
    const mx = ops.maxAll(mel);
    const eight = ops.scalarLike(8.0, mel);
    const lo = ops.sub(mx, eight);
    mel = dispose(mel, ops.maximum(mel, lo));
    mx.dispose();
    eight.dispose();
    lo.dispose();
    const four = ops.scalarLike(4.0, mel);
    mel = dispose(mel, ops.add(mel, four));
    mel = dispose(mel, ops.div(mel, four));
    four.dispose();
    return mel;
  }

  dispose(): void {
    this.#filtersT.dispose();
    this.#window.dispose();
  }
}

/** pad_or_trim along the frame axis to `length` frames (zeros on the right). */
export function padOrTrimFrames(mel: MlxArray, length: number, dtype: Dtype): MlxArray {
  const [t, m] = mel.shape as [number, number];
  let out: MlxArray;
  if (t > length) out = mel.slice([0, 0], [length, m]);
  else if (t < length) out = ops.pad(mel, [[0, length - t], [0, 0]]);
  else out = ops.copyOf(mel);
  if (out.dtype !== dtype) out = dispose(out, out.astype(dtype));
  return out;
}
