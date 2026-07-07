// WAV decode for audio input (A1 of docs/design/audio-input-plan.md).
//
// Scope: RIFF/WAVE containers — PCM 16/24/32-bit and IEEE float32, any
// channel count (mean mixdown), any sample rate (linear resample to 16 kHz).
// PCM16 scales by 1/32768 to match the oracle golden generator
// (scripts/gen-e4b-audio-golden.py) exactly. Non-WAV containers (mp3/m4a/
// flac/ogg) are transcoded to WAV by the serve layer via macOS `afconvert`
// before reaching this parser.
//
// Resampling note: optiq's serve frontend never exposes audio, so there is
// no oracle behavior for non-16 kHz input — linear interpolation is our
// documented choice (the parity fixtures are native 16 kHz and skip it).

export const AUDIO_SAMPLE_RATE = 16_000;
export const AUDIO_MS_PER_TOKEN = 40;
export const AUDIO_SEQ_LENGTH = 750; // 30 s cap, matches the oracle processor
/** Raw-speech truncation bound — the oracle feature extractor's default
 *  (audio_feature_extractor.py __call__: truncation=True,
 *  max_length=480_000 → `w[:max_length]`, i.e. 30 s at 16 kHz) applied
 *  BEFORE feature extraction. Mirrored in decodeAudio so a >30 s clip
 *  yields exactly the capped 750 soft tokens AND the matching mel frame
 *  count — the prompt builder hard-checks that the tower's output length
 *  equals the splice's soft-token count. */
export const AUDIO_MAX_SAMPLES = 30 * AUDIO_SAMPLE_RATE; // 480_000

export interface DecodedWav {
  samples: Float32Array; // mono
  sampleRate: number;
}

/** Number of audio soft tokens for a clip — processing_gemma4.py
 *  `_compute_audio_num_tokens`: ceil(duration_ms / 40) capped at 750.
 *  MUST be computed from decoded samples, never from container metadata. */
export function audioSoftTokenCount(
  numSamples: number,
  sampleRate: number = AUDIO_SAMPLE_RATE,
): number {
  const durationMs = (numSamples / sampleRate) * 1000;
  return Math.min(Math.ceil(durationMs / AUDIO_MS_PER_TOKEN), AUDIO_SEQ_LENGTH);
}

const WAVE_FORMAT_PCM = 1;
const WAVE_FORMAT_IEEE_FLOAT = 3;
const WAVE_FORMAT_EXTENSIBLE = 0xfffe;

/** Parse a RIFF/WAVE file into mono float samples at its native rate. */
export function decodeWav(bytes: Uint8Array): DecodedWav {
  const v = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const tag = (o: number) => String.fromCharCode(bytes[o]!, bytes[o + 1]!, bytes[o + 2]!, bytes[o + 3]!);
  if (bytes.length < 44 || tag(0) !== "RIFF" || tag(8) !== "WAVE")
    throw new Error("not a RIFF/WAVE file");

  let fmt: { format: number; channels: number; sampleRate: number; bits: number } | null = null;
  let dataOff = -1;
  let dataLen = 0;
  for (let o = 12; o + 8 <= bytes.length; ) {
    const id = tag(o);
    const size = v.getUint32(o + 4, true);
    const body = o + 8;
    if (id === "fmt ") {
      // the reads below reach body+16 (base fields) / body+26 (extensible)
      if (size < 16 || body + 16 > bytes.length)
        throw new Error("WAV: truncated fmt chunk");
      let format = v.getUint16(body, true);
      const channels = v.getUint16(body + 2, true);
      const sampleRate = v.getUint32(body + 4, true);
      const bits = v.getUint16(body + 14, true);
      if (format === WAVE_FORMAT_EXTENSIBLE) {
        if (size < 40 || body + 26 > bytes.length)
          throw new Error("WAV: truncated WAVE_FORMAT_EXTENSIBLE fmt chunk");
        format = v.getUint16(body + 24, true); // first 2 bytes of SubFormat GUID
      }
      fmt = { format, channels, sampleRate, bits };
    } else if (id === "data") {
      dataOff = body;
      dataLen = Math.min(size, bytes.length - body);
    }
    o = body + size + (size & 1); // chunks are word-aligned
  }
  if (!fmt) throw new Error("WAV: missing fmt chunk");
  if (dataOff < 0) throw new Error("WAV: missing data chunk");
  const { format, channels, sampleRate, bits } = fmt;
  if (channels < 1) throw new Error("WAV: zero channels");

  const bytesPer = bits / 8;
  const frames = Math.floor(dataLen / (bytesPer * channels));
  const out = new Float32Array(frames);

  const readSample = (off: number): number => {
    if (format === WAVE_FORMAT_IEEE_FLOAT && bits === 32) return v.getFloat32(off, true);
    if (format === WAVE_FORMAT_PCM && bits === 16) return v.getInt16(off, true) / 32768;
    if (format === WAVE_FORMAT_PCM && bits === 24) {
      const raw = bytes[off]! | (bytes[off + 1]! << 8) | (bytes[off + 2]! << 16);
      return ((raw << 8) >> 8) / 8388608;
    }
    if (format === WAVE_FORMAT_PCM && bits === 32) return v.getInt32(off, true) / 2147483648;
    throw new Error(`WAV: unsupported format ${format} / ${bits}-bit`);
  };

  for (let f = 0; f < frames; f++) {
    const base = dataOff + f * bytesPer * channels;
    let acc = 0;
    for (let c = 0; c < channels; c++) acc += readSample(base + c * bytesPer);
    out[f] = Math.fround(acc / channels);
  }
  return { samples: out, sampleRate };
}

/** Linear resample to the model rate (no-op passthrough at 16 kHz). */
export function resampleTo16k(samples: Float32Array, sampleRate: number): Float32Array {
  if (sampleRate === AUDIO_SAMPLE_RATE) return samples;
  if (sampleRate <= 0) throw new Error(`bad sample rate ${sampleRate}`);
  const outLen = Math.max(1, Math.round((samples.length * AUDIO_SAMPLE_RATE) / sampleRate));
  const out = new Float32Array(outLen);
  const step = samples.length / outLen;
  for (let i = 0; i < outLen; i++) {
    const pos = i * step;
    const j = Math.floor(pos);
    const fracPart = pos - j;
    const a = samples[Math.min(j, samples.length - 1)]!;
    const b = samples[Math.min(j + 1, samples.length - 1)]!;
    out[i] = Math.fround(a + (b - a) * fracPart);
  }
  return out;
}

/** WAV bytes → mono 16 kHz float samples (the feature-extractor input),
 *  truncated at 30 s exactly like the oracle (AUDIO_MAX_SAMPLES). */
export function decodeAudio(bytes: Uint8Array): Float32Array {
  const { samples, sampleRate } = decodeWav(bytes);
  const s = resampleTo16k(samples, sampleRate);
  return s.length > AUDIO_MAX_SAMPLES ? s.subarray(0, AUDIO_MAX_SAMPLES) : s;
}
