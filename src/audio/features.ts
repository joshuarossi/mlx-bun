// USM log-mel feature extraction for gemma-4 audio — a verbatim-semantics
// port of the oracle's Gemma4AudioFeatureExtractor (optiq/vlm/_mlxvlm/
// models/gemma4/audio_feature_extractor.py, constructor DEFAULTS — §3.3 Q3
// of docs/design/audio-input-plan.md: no per-bin normalization, params are
// fixed for all gemma-4 models). Gated bit-close against the T0 mel goldens
// (goldens/e4b-audio-*-mel.bin) in tests/audio-features.test.ts.
//
// Pipeline (single waveform, 16 kHz mono float32):
//   pad to a multiple of 128 samples (validity mask over the original part)
//   → semicausal left-pad of frame_length/2 = 160 zeros
//   → unfold into 321-sample frames at hop 160, drop the 321st sample
//     (preemphasis = 0 branch)
//   → × periodic Hann window (numpy computes it in FLOAT32 — emulated with
//     Math.fround so the products match the oracle's f32 rounding)
//   → rfft n=512 (numpy promotes to float64; we FFT in f64)
//   → |·| → @ mel filter bank (128 HTK bins over 0–8 kHz, float64, the
//     transformers mel_filter_bank construction: linspace fft freqs,
//     unguarded slope division, no norm)
//   → log(x + 1e-3) → zero out invalid frames → float32 [T, 128].
//
// Frame validity: frame f is valid iff original-sample index
// f·hop + frame_length lands inside the un-padded waveform.

const SR = 16_000;
const FRAME = 320; // 20 ms
const HOP = 160; // 10 ms
const FFT_N = 512; // 2^ceil(log2(320)), fft_overdrive=false
const FREQ_BINS = FFT_N / 2 + 1; // 257
const MEL_BINS = 128;
const MEL_FMIN = 0.0;
const MEL_FMAX = 8000.0;
const MEL_FLOOR = 1e-3;
const PAD_MULTIPLE = 128;

export interface MelFeatures {
  /** [frames, 128] row-major log-mel, float32 (invalid frames zeroed). */
  features: Float32Array;
  frames: number;
  /** Per-frame validity (1 = real audio, 0 = padding). */
  mask: Uint8Array;
}

// --- mel filter bank (float64, transformers semantics) -----------------------
const hzToMel = (f: number): number => 2595.0 * Math.log10(1.0 + f / 700.0);
const melToHz = (m: number): number => 700.0 * (10 ** (m / 2595.0) - 1.0);

function buildMelFilters(): Float64Array {
  // filter_freqs: 130 points linspace in mel space, mapped back to Hz
  const melMin = hzToMel(MEL_FMIN);
  const melMax = hzToMel(MEL_FMAX);
  const nPts = MEL_BINS + 2;
  const filterFreqs = new Float64Array(nPts);
  for (let i = 0; i < nPts; i++)
    filterFreqs[i] = melToHz(melMin + ((melMax - melMin) * i) / (nPts - 1));
  // fft_freqs: linspace(0, sr//2, 257)
  const fftFreqs = new Float64Array(FREQ_BINS);
  for (let k = 0; k < FREQ_BINS; k++) fftFreqs[k] = (8000.0 * k) / (FREQ_BINS - 1);
  // triangular filters: max(0, min(down, up)) — unguarded diffs like the oracle
  const filters = new Float64Array(FREQ_BINS * MEL_BINS);
  for (let m = 0; m < MEL_BINS; m++) {
    const lower = filterFreqs[m]!;
    const center = filterFreqs[m + 1]!;
    const upper = filterFreqs[m + 2]!;
    for (let k = 0; k < FREQ_BINS; k++) {
      const down = (fftFreqs[k]! - lower) / (center - lower);
      const up = (upper - fftFreqs[k]!) / (upper - center);
      filters[k * MEL_BINS + m] = Math.max(0, Math.min(down, up));
    }
  }
  return filters;
}

// --- periodic Hann window: the ORACLE'S EXACT float32 values -----------------
// numpy builds this in float32 end-to-end (arange f32 → ×2π/320 → cos, all in
// numpy's vectorized f32 routines) and those cos values differ from
// fround(Math.cos(x)) by 1 ulp on some inputs. That 1 ulp is the ONLY
// divergence in the whole pipeline: with these exact values our extractor
// reproduces the oracle mel golden BIT-EXACTLY; with a recomputed window the
// log-amplified cancellation error reaches ~4.5e-4 (verified 2026-07-07).
// So the constant IS the spec. Regen (oracle venv):
//   python -c "from optiq.vlm._mlxvlm.models.gemma4.audio_feature_extractor \
//     import Gemma4AudioFeatureExtractor as F; import base64; \
//     print(base64.b64encode(F().window.astype('<f4').tobytes()).decode())"
const WINDOW_B64 =
  "AAAAAAAgyjgAHMo5AFRjOgAHyjqAyR07ACJjOwCDmjvAtsk7wCf/O0BoHTyAVT48gFhiPNC2hDyQ" +
  "yJk8UF+wPPB4yDwQE+I8ECv9PDDfDD0Q5Rs9qKUrPXAfPD3IUE09+DdfPUjTcT1okII9XI+MPYDl" +
  "lj3QkaE9PJOsPbDotz0MkcM9LIvPPeDV2z30b+g9JFj1PZZGAT7iBgg+SOwOPhr2FT6mIx0+PHQk" +
  "PhrnKz6OezM+zjA7Ph4GQz64+ko+0A1TPp4+Wz5OjGM+EvZrPhR7dD54Gn0+uemCPopShz5Ix4s+" +
  "fEeQPrbSlD6GaJk+dQiePhCyoj7gZKc+biCsPkTksD7or7U+4oK6Prdcvz7uPMQ+CiPJPpEOzj4F" +
  "/9I+6fPXPsTs3D4S6eE+W+jmPhvq6z7Y7fA+EvP1Pkr5+j4AAAA/XIMCP3cGBT8ViQc/8woKP9OL" +
  "DD93Cw8/oIkRPwwGFD9+gBY/uPgYP3xuGz+K4R0/pVEgP5C+Ij8OKCU/340nP8rvKT+RTSw/+KYu" +
  "P8b7MD++SzM/pZY1P0PcNz9dHDo/u1Y8PySLPj9iuUA/PeFCP3wCRT/sHEc/WjBJP448Sz9SQU0/" +
  "eD5PP84zUT8dIVM/OgZVP/LiVj8Yt1g/eoJaP+5EXD9I/l0/Wq5fP/xUYT8C8mI/RIVkP5oOZj/e" +
  "jWc/6gJpP5ltaj/GzWs/UCNtPxVubj/0rW8/zOJwP4EMcj/0KnM/Cj50P6ZFdT+wQXY/DTJ3P6gW" +
  "eD9o73g/OLx5PwZ9ej+8MXs/Stp7P552fD+qBn0/YIp9P7ABfj+SbH4/+sp+P94cfz82Yn8//Zp/" +
  "PyvHfz+85n8/r/l/PwAAgD+v+X8/vOZ/PyvHfz/9mn8/NmJ/P94cfz/6yn4/kmx+P7ABfj9gin0/" +
  "qgZ9P552fD9J2ns/uzF7PwV9ej84vHk/aO94P6gWeD8NMnc/r0F2P6RFdT8IPnQ/8ipzP4AMcj/M" +
  "4nA/861vPxRubj9QI20/xc1rP5dtaj/rAmk/3o1nP5oOZj9EhWQ/AfJiP/tUYT9Yrl8/SP5dP+9E" +
  "XD95glo/FbdYP/DiVj84BlU/HCFTP80zUT93Pk8/UkFNP4o8Sz9ZMEk/6xxHP3gCRT894UI/YrlA" +
  "PyKLPj+6Vjw/Whw6P0LcNz+mljU/vEszP8b7MD/4pi4/jk0sP8jvKT/cjSc/DCglP5C+Ij+kUSA/" +
  "iuEdP3puGz+1+Bg/fYAWPwwGFD+diRE/dwsPP9KLDD/zCgo/EokHP3MGBT9dgwI/AAAAP0X5+j4R" +
  "8/U+0+3wPhrq6z5U6OY+EenhPsXs3D7o89c+/v7SPo4Ozj4EI8k+6zzEPrhcvz7fgro+6a+1PkHk" +
  "sD5oIKw+3WSnPgqyoj5zCJ4+iGiZPrTSlD58R5A+RMeLPoRShz616YI+ehp9Pgx7dD4Q9ms+Roxj" +
  "Ppw+Wz7IDVM+qvpKPiQGQz7MMDs+hHszPhrnKz4ydCQ+piMdPhL2FT5E7A4+5AYIPpRGAT4UWPU9" +
  "7G/oPdDV2z0oi889EJHDPajotz08k6w9yJGhPXDllj1Uj4w9WJCCPTjTcT34N189uFBNPXAfPD2Y" +
  "pSs98OQbPTjfDD0QK/088BLiPPB4yDxAX7A8gMiZPMC2hDxgWGI8gFU+PCBoHTyAJ/87wLbJO8CC" +
  "mjsAImM7gMkdOwAGyjoAVGM6ABzKOQAgyjg=";

function buildWindow(): Float32Array {
  const raw = Buffer.from(WINDOW_B64, "base64");
  return new Float32Array(raw.buffer, raw.byteOffset, FRAME);
}

// --- iterative radix-2 complex FFT (float64), N = 512 ------------------------
const FFT_COS = new Float64Array(FFT_N / 2);
const FFT_SIN = new Float64Array(FFT_N / 2);
for (let i = 0; i < FFT_N / 2; i++) {
  FFT_COS[i] = Math.cos((-2 * Math.PI * i) / FFT_N);
  FFT_SIN[i] = Math.sin((-2 * Math.PI * i) / FFT_N);
}

function fft512(re: Float64Array, im: Float64Array): void {
  // bit-reversal permutation
  for (let i = 1, j = 0; i < FFT_N; i++) {
    let bit = FFT_N >> 1;
    for (; j & bit; bit >>= 1) j ^= bit;
    j ^= bit;
    if (i < j) {
      const tr = re[i]!; re[i] = re[j]!; re[j] = tr;
      const ti = im[i]!; im[i] = im[j]!; im[j] = ti;
    }
  }
  for (let len = 2; len <= FFT_N; len <<= 1) {
    const half = len >> 1;
    const step = FFT_N / len;
    for (let i = 0; i < FFT_N; i += len) {
      for (let k = 0; k < half; k++) {
        const c = FFT_COS[k * step]!;
        const s = FFT_SIN[k * step]!;
        const xr = re[i + k + half]! * c - im[i + k + half]! * s;
        const xi = re[i + k + half]! * s + im[i + k + half]! * c;
        re[i + k + half] = re[i + k]! - xr;
        im[i + k + half] = im[i + k]! - xi;
        re[i + k] = re[i + k]! + xr;
        im[i + k] = im[i + k]! + xi;
      }
    }
  }
}

let melFilters: Float64Array | null = null;
let hannWindow: Float32Array | null = null;

/** 16 kHz mono float32 waveform → USM log-mel features [T, 128]. */
export function extractMelFeatures(waveform: Float32Array): MelFeatures {
  melFilters ??= buildMelFilters();
  hannWindow ??= buildWindow();

  const nReal = waveform.length;
  const nPadded = Math.ceil(nReal / PAD_MULTIPLE) * PAD_MULTIPLE;
  const PAD_LEFT = FRAME >> 1; // 160
  const total = PAD_LEFT + nPadded;
  const frames = Math.floor((total - (FRAME + 1)) / HOP) + 1;
  if (frames <= 0) return { features: new Float32Array(0), frames: 0, mask: new Uint8Array(0) };

  const features = new Float32Array(frames * MEL_BINS);
  const mask = new Uint8Array(frames);
  const re = new Float64Array(FFT_N);
  const im = new Float64Array(FFT_N);
  const mel = new Float64Array(MEL_BINS);

  for (let f = 0; f < frames; f++) {
    // frame f covers padded indices [f*HOP, f*HOP+FRAME) after the left pad;
    // validity = the frame-END sample (index f*HOP+FRAME in the left-padded
    // stream, i.e. f*HOP+FRAME-PAD_LEFT in the original) is real audio.
    const endIdx = f * HOP + FRAME - PAD_LEFT;
    const valid = endIdx >= 0 && endIdx < nReal;
    mask[f] = valid ? 1 : 0;
    if (!valid) continue; // oracle zeroes invalid frames; ours start zeroed

    re.fill(0);
    im.fill(0);
    for (let n = 0; n < FRAME; n++) {
      const srcIdx = f * HOP + n - PAD_LEFT; // <0 → semicausal zero pad
      const sample = srcIdx >= 0 && srcIdx < nReal ? waveform[srcIdx]! : 0;
      re[n] = Math.fround(sample * hannWindow[n]!); // numpy f32 product
    }
    fft512(re, im);

    mel.fill(0);
    for (let k = 0; k < FREQ_BINS; k++) {
      const mag = Math.hypot(re[k]!, im[k]!);
      if (mag === 0) continue;
      const base = k * MEL_BINS;
      for (let m = 0; m < MEL_BINS; m++) mel[m] = mel[m]! + mag * melFilters![base + m]!;
    }
    const out = f * MEL_BINS;
    for (let m = 0; m < MEL_BINS; m++)
      features[out + m] = Math.fround(Math.log(mel[m]! + MEL_FLOOR));
  }
  return { features, frames, mask };
}
