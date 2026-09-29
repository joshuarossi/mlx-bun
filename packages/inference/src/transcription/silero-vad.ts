// Silero VAD v6 (16 kHz) — the voice-activity gate sotto runs before Whisper:
// per 512-sample chunk (32 ms) a speech probability, then the reference
// `get_speech_timestamps` state machine. Ported from the silero-vad 6.2.1
// TorchScript graph (NOT whisper.cpp's approximation, which drops the
// 64-sample inter-chunk context and pads both sides):
//   x = [context(64) ‖ chunk(512)] → ReflectionPad1d(0, 64) → conv1d with
//   the STFT basis (258 filters, 256 taps, hop 128) → |re, im| → [129, 4]
//   → 4 × (Conv1d k3 + ReLU; strides 1,2,2,1; channels 128,64,64,128) → [128]
//   → LSTMCell(128) → ReLU → Conv1d(128→1) → sigmoid.
// Weights: ggml-org/whisper-vad's ggml-silero-v6.2.0.bin (885 KB; conv and
// STFT weights are stored f16 there, so probabilities differ from the f32
// reference by ~1e-3 — parity test tolerance; segments match).
// Execution: the STFT, the conv encoder and the LSTM input projection run
// batched over ALL chunks in one MLX graph; only the 128-wide recurrence
// runs per chunk, on the host (65 K MACs each).

import { existsSync, readdirSync, readFileSync } from "node:fs";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

export const VAD_SAMPLE_RATE = 16_000;
export const VAD_WINDOW = 512;
export const VAD_CONTEXT = 64;
const STFT_FILTERS = 258;
const STFT_TAPS = 256;
const STFT_HOP = 128;
const STFT_PAD_RIGHT = 64;
const LSTM_HIDDEN = 128;

export interface VadStreamState {
  h: Float32Array;
  c: Float32Array;
  /** Last 64 samples of the previous call (null before the first). */
  context: Float32Array | null;
  chunks: number;
}

export interface VadSegment {
  /** Sample offsets at 16 kHz. */
  start: number;
  end: number;
}

export interface SpeechTimestampOptions {
  threshold?: number;
  minSpeechDurationMs?: number;
  maxSpeechDurationS?: number;
  minSilenceDurationMs?: number;
  speechPadMs?: number;
  negThreshold?: number | null;
  minSilenceAtMaxSpeechMs?: number;
  useMaxPossibleSilenceAtMaxSpeech?: boolean;
}

interface Tensor {
  data: Float32Array;
  shape: number[];
}

/** Parse whisper.cpp's ggml Silero container (models/convert-silero-vad-to-ggml.py). */
export function parseSileroGgml(bytes: Uint8Array): { tensors: Map<string, Tensor>; version: string } {
  const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  let o = 0;
  const i32 = () => { const v = dv.getInt32(o, true); o += 4; return v; };
  if (i32() !== 0x67676d6c) throw new Error("silero vad: not a ggml file");
  const typeLen = i32();
  const modelType = new TextDecoder().decode(bytes.subarray(o, o + typeLen)); o += typeLen;
  if (modelType !== "silero-16k") throw new Error(`silero vad: unexpected model type ${modelType}`);
  const version = `${i32()}.${i32()}.${i32()}`;
  const window = i32(); const context = i32();
  if (window !== VAD_WINDOW || context !== VAD_CONTEXT) throw new Error(`silero vad: window ${window}/context ${context} unsupported`);
  const nLayers = i32();
  for (let l = 0; l < nLayers; l++) { i32(); i32(); i32(); }
  i32(); i32(); i32(); i32(); // lstm in/hidden, final in/out
  const tensors = new Map<string, Tensor>();
  while (o < bytes.byteLength) {
    const nDims = i32(); const nameLen = i32(); const ftype = i32();
    const dims: number[] = [];
    for (let d = 0; d < nDims; d++) dims.push(i32());
    const name = new TextDecoder().decode(bytes.subarray(o, o + nameLen)); o += nameLen;
    const n = dims.reduce((a, b) => a * b, 1);
    const shape = [...dims].reverse(); // ggml ne[] is reversed row-major
    let data: Float32Array;
    if (ftype === 1) {
      data = new Float32Array(n);
      for (let i = 0; i < n; i++) data[i] = f16ToF32(dv.getUint16(o + 2 * i, true));
      o += 2 * n;
    } else {
      data = new Float32Array(n);
      for (let i = 0; i < n; i++) data[i] = dv.getFloat32(o + 4 * i, true);
      o += 4 * n;
    }
    tensors.set(name, { data, shape });
  }
  return { tensors, version };
}

function f16ToF32(h: number): number {
  const s = (h & 0x8000) ? -1 : 1;
  const e = (h >> 10) & 0x1f;
  const f = h & 0x3ff;
  if (e === 0) return s * 2 ** -14 * (f / 1024);
  if (e === 0x1f) return f ? Number.NaN : s * Infinity;
  return s * 2 ** (e - 15) * (1 + f / 1024);
}

/** HF-cache location of ggml-org/whisper-vad's ggml-silero-v6.2.0.bin, or null. */
export function resolveSileroVadPath(explicit?: string | null): string | null {
  if (explicit) return existsSync(explicit) ? explicit : null;
  const base = `${process.env.HOME}/.cache/huggingface/hub/models--ggml-org--whisper-vad/snapshots`;
  try {
    for (const snap of readdirSync(base)) {
      const p = `${base}/${snap}/ggml-silero-v6.2.0.bin`;
      if (existsSync(p)) return p;
    }
  } catch { /* absent */ }
  return null;
}

export class SileroVad {
  readonly version: string;
  // device weights (MLX layouts)
  readonly #stftW: MlxArray;        // [258, 256, 1]
  readonly #convW: MlxArray[] = []; // [out, k, in]
  readonly #convB: MlxArray[] = []; // [out]
  readonly #convStride = [1, 2, 2, 1];
  readonly #wIhT: MlxArray;         // [128, 512]
  readonly #bIhHh: MlxArray;        // [512] = b_ih + b_hh
  // host weights for the recurrence
  readonly #wHh: Float32Array;      // [512, 128]
  readonly #wFinal: Float32Array;   // [128]
  readonly #bFinal: number;

  private constructor(tensors: Map<string, Tensor>, version: string) {
    this.version = version;
    const t = (name: string): Tensor => {
      const v = tensors.get(name);
      if (!v) throw new Error(`silero vad: missing tensor ${name}`);
      return v;
    };
    // STFT basis: torch (258, 1, 256) → MLX conv weight [out=258, k=256, in=1]
    this.#stftW = MlxArray.fromFloat32(t("_model.stft.forward_basis_buffer").data, [STFT_FILTERS, STFT_TAPS, 1]);
    for (let l = 0; l < 4; l++) {
      const w = t(`_model.encoder.${l}.reparam_conv.weight`); // torch (out, in, 3)
      const [out, inC, k] = w.shape as [number, number, number];
      const mlx = new Float32Array(out * k * inC);
      for (let oc = 0; oc < out; oc++) for (let ic = 0; ic < inC; ic++) for (let kk = 0; kk < k; kk++)
        mlx[(oc * k + kk) * inC + ic] = w.data[(oc * inC + ic) * k + kk]!;
      this.#convW.push(MlxArray.fromFloat32(mlx, [out, k, inC]));
      this.#convB.push(MlxArray.fromFloat32(t(`_model.encoder.${l}.reparam_conv.bias`).data, [out]));
    }
    const wIh = t("_model.decoder.rnn.weight_ih"); // (512, 128)
    const wIhT = new Float32Array(LSTM_HIDDEN * 4 * LSTM_HIDDEN);
    for (let r = 0; r < 4 * LSTM_HIDDEN; r++) for (let c = 0; c < LSTM_HIDDEN; c++) wIhT[c * 4 * LSTM_HIDDEN + r] = wIh.data[r * LSTM_HIDDEN + c]!;
    this.#wIhT = MlxArray.fromFloat32(wIhT, [LSTM_HIDDEN, 4 * LSTM_HIDDEN]);
    const bIh = t("_model.decoder.rnn.bias_ih").data;
    const bHh = t("_model.decoder.rnn.bias_hh").data;
    const b = new Float32Array(4 * LSTM_HIDDEN);
    for (let i = 0; i < b.length; i++) b[i] = bIh[i]! + bHh[i]!;
    this.#bIhHh = MlxArray.fromFloat32(b, [4 * LSTM_HIDDEN]);
    this.#wHh = t("_model.decoder.rnn.weight_hh").data;
    this.#wFinal = t("_model.decoder.decoder.2.weight").data;
    this.#bFinal = t("_model.decoder.decoder.2.bias").data[0]!;
    ops.evalAll([this.#stftW, ...this.#convW, ...this.#convB, this.#wIhT, this.#bIhHh]);
  }

  static load(path?: string | null): SileroVad {
    const p = resolveSileroVadPath(path);
    if (!p)
      throw new Error(
        "Silero VAD weights not found: download ggml-org/whisper-vad (ggml-silero-v6.2.0.bin, 885 KB) " +
        "into the HF cache or pass --vad-model <path>",
      );
    const { tensors, version } = parseSileroGgml(new Uint8Array(readFileSync(p)));
    return new SileroVad(tensors, version);
  }

  /** Speech probability per 512-sample chunk (the last chunk zero-padded). */
  probs(samples: Float32Array): Float32Array {
    return this.probsStreaming(samples, null);
  }

  /** Streaming variant: `state` (LSTM h/c + the previous chunk's 64-sample
   *  context) carries across calls; pass null to start fresh. Feed whole
   *  512-sample multiples per call (a trailing partial chunk is zero-padded
   *  and ends the stream like the reference). */
  probsStreaming(samples: Float32Array, state: VadStreamState | null): Float32Array {
    const n = Math.ceil(samples.length / VAD_WINDOW);
    if (n === 0) return new Float32Array(0);
    const hState = state?.h ?? new Float32Array(LSTM_HIDDEN);
    const cState = state?.c ?? new Float32Array(LSTM_HIDDEN);
    const prevContext = state?.context ?? null;
    // [n, 640]: context (previous chunk's last 64 samples) ‖ chunk ‖ reflect pad 64
    const W = VAD_CONTEXT + VAD_WINDOW + STFT_PAD_RIGHT;
    const x = new Float32Array(n * W);
    for (let c = 0; c < n; c++) {
      const row = c * W;
      const start = c * VAD_WINDOW;
      for (let i = 0; i < VAD_CONTEXT; i++) {
        const src = start - VAD_CONTEXT + i;
        x[row + i] = src >= 0 ? samples[src]! : (prevContext ? prevContext[VAD_CONTEXT + src]! : 0);
      }
      for (let i = 0; i < VAD_WINDOW; i++) x[row + VAD_CONTEXT + i] = samples[start + i] ?? 0;
      // reflect (torch ReflectionPad1d): pad[i] = x[L - 2 - i]
      const L = VAD_CONTEXT + VAD_WINDOW;
      for (let i = 0; i < STFT_PAD_RIGHT; i++) x[row + L + i] = x[row + L - 2 - i]!;
    }
    const inp = MlxArray.fromFloat32(x, [n, W, 1]);
    let h = ops.conv1d(inp, this.#stftW, STFT_HOP, 0); // [n, 4, 258]
    inp.dispose();
    const cutoff = STFT_FILTERS / 2; // 129
    const re = h.slice([0, 0, 0], [n, 4, cutoff]);
    const im = h.slice([0, 0, cutoff], [n, 4, STFT_FILTERS]);
    h.dispose();
    const re2 = ops.square(re); const im2 = ops.square(im);
    re.dispose(); im.dispose();
    let mag = ops.add(re2, im2);
    re2.dispose(); im2.dispose();
    mag = dispose(mag, ops.sqrt(mag)); // [n, 4, 129]
    let cur = mag;
    const zero = MlxArray.fromFloat32(new Float32Array([0]), []);
    for (let l = 0; l < 4; l++) {
      cur = dispose(cur, ops.conv1d(cur, this.#convW[l]!, this.#convStride[l]!, 1));
      cur = dispose(cur, ops.add(cur, this.#convB[l]!));
      cur = dispose(cur, ops.maximum(cur, zero)); // ReLU
    }
    zero.dispose();
    // cur: [n, 1, 128] → input gates [n, 512]
    cur = dispose(cur, ops.reshape(cur, [n, LSTM_HIDDEN]));
    let gates = ops.addmm(this.#bIhHh, cur, this.#wIhT);
    cur.dispose();
    const g = gates.toFloat32();
    gates.dispose();
    // host recurrence
    const H = LSTM_HIDDEN;
    const pre = new Float32Array(4 * H);
    const out = new Float32Array(n);
    const wHh = this.#wHh;
    for (let t = 0; t < n; t++) {
      const gi = t * 4 * H;
      for (let r = 0; r < 4 * H; r++) {
        let acc = g[gi + r]!;
        const wr = r * H;
        for (let c = 0; c < H; c++) acc += wHh[wr + c]! * hState[c]!;
        pre[r] = acc;
      }
      for (let j = 0; j < H; j++) {
        const i = sigmoid(pre[j]!);
        const f = sigmoid(pre[H + j]!);
        const gg = Math.tanh(pre[2 * H + j]!);
        const o = sigmoid(pre[3 * H + j]!);
        const c = f * cState[j]! + i * gg;
        cState[j] = c;
        hState[j] = o * Math.tanh(c);
      }
      let acc = this.#bFinal;
      for (let j = 0; j < H; j++) acc += this.#wFinal[j]! * Math.max(0, hState[j]!);
      out[t] = sigmoid(acc);
    }
    if (state) {
      state.h = hState;
      state.c = cState;
      const ctx = new Float32Array(VAD_CONTEXT);
      const tail = n * VAD_WINDOW - VAD_CONTEXT;
      for (let i = 0; i < VAD_CONTEXT; i++) ctx[i] = samples[tail + i] ?? 0;
      state.context = ctx;
      state.chunks += n;
    }
    return out;
  }

  /** Fresh streaming state. */
  static streamState(): VadStreamState {
    return { h: new Float32Array(LSTM_HIDDEN), c: new Float32Array(LSTM_HIDDEN), context: null, chunks: 0 };
  }

  /** get_speech_timestamps over the probabilities (sample offsets). */
  static speechTimestamps(probs: Float32Array, audioLengthSamples: number, opts: SpeechTimestampOptions = {}): VadSegment[] {
    const sr = VAD_SAMPLE_RATE;
    const window = VAD_WINDOW;
    const threshold = opts.threshold ?? 0.5;
    const minSpeech = sr * (opts.minSpeechDurationMs ?? 250) / 1000;
    const speechPad = sr * (opts.speechPadMs ?? 30) / 1000;
    const maxSpeechS = opts.maxSpeechDurationS ?? Infinity;
    const maxSpeech = sr * maxSpeechS - window - 2 * speechPad;
    const minSilence = sr * (opts.minSilenceDurationMs ?? 100) / 1000;
    const minSilenceAtMax = sr * (opts.minSilenceAtMaxSpeechMs ?? 98) / 1000;
    const useMaxPoss = opts.useMaxPossibleSilenceAtMaxSpeech ?? true;
    const negThreshold = opts.negThreshold ?? Math.max(threshold - 0.15, 0.01);
    let triggered = false;
    const speeches: { start: number; end: number }[] = [];
    let current: { start: number; end?: number } | null = null;
    let tempEnd = 0; let prevEnd = 0; let nextStart = 0;
    let possibleEnds: [number, number][] = [];
    for (let i = 0; i < probs.length; i++) {
      const p = probs[i]!;
      const cur = window * i;
      if (p >= threshold && tempEnd) {
        const silDur = cur - tempEnd;
        if (silDur > minSilenceAtMax) possibleEnds.push([tempEnd, silDur]);
        tempEnd = 0;
        if (nextStart < prevEnd) nextStart = cur;
      }
      if (p >= threshold && !triggered) { triggered = true; current = { start: cur }; continue; }
      if (triggered && current && cur - current.start > maxSpeech) {
        if (useMaxPoss && possibleEnds.length) {
          let best = possibleEnds[0]!;
          for (const pe of possibleEnds) if (pe[1] > best[1]) best = pe;
          const [pEnd, dur] = best;
          prevEnd = pEnd;
          speeches.push({ start: current.start, end: prevEnd });
          current = null;
          nextStart = prevEnd + dur;
          if (nextStart < prevEnd + cur) current = { start: nextStart };
          else triggered = false;
          prevEnd = nextStart = tempEnd = 0;
          possibleEnds = [];
        } else if (prevEnd) {
          speeches.push({ start: current.start, end: prevEnd });
          current = null;
          if (nextStart < prevEnd) triggered = false; else current = { start: nextStart };
          prevEnd = nextStart = tempEnd = 0;
          possibleEnds = [];
        } else {
          speeches.push({ start: current.start, end: cur });
          current = null;
          prevEnd = nextStart = tempEnd = 0;
          triggered = false;
          possibleEnds = [];
          continue;
        }
      }
      if (p < negThreshold && triggered && current) {
        if (!tempEnd) tempEnd = cur;
        const silNow = cur - tempEnd;
        if (!useMaxPoss && silNow > minSilenceAtMax) prevEnd = tempEnd;
        if (silNow < minSilence) continue;
        if (tempEnd - current.start > minSpeech) speeches.push({ start: current.start, end: tempEnd });
        current = null;
        prevEnd = nextStart = tempEnd = 0;
        triggered = false;
        possibleEnds = [];
        continue;
      }
    }
    if (current && audioLengthSamples - current.start > minSpeech) speeches.push({ start: current.start, end: audioLengthSamples });
    for (let i = 0; i < speeches.length; i++) {
      const s = speeches[i]!;
      if (i === 0) s.start = Math.floor(Math.max(0, s.start - speechPad));
      if (i !== speeches.length - 1) {
        const nxt = speeches[i + 1]!;
        const silence = nxt.start - s.end;
        if (silence < 2 * speechPad) {
          s.end += Math.floor(silence / 2);
          nxt.start = Math.floor(Math.max(0, nxt.start - Math.floor(silence / 2)));
        } else {
          s.end = Math.floor(Math.min(audioLengthSamples, s.end + speechPad));
          nxt.start = Math.floor(Math.max(0, nxt.start - speechPad));
        }
      } else s.end = Math.floor(Math.min(audioLengthSamples, s.end + speechPad));
    }
    return speeches;
  }

  /** Probabilities + segments in one call. */
  detect(samples: Float32Array, opts: SpeechTimestampOptions = {}): { probs: Float32Array; segments: VadSegment[] } {
    const probs = this.probs(samples);
    return { probs, segments: SileroVad.speechTimestamps(probs, samples.length, opts) };
  }

  dispose(): void {
    this.#stftW.dispose();
    for (const a of [...this.#convW, ...this.#convB, this.#wIhT, this.#bIhHh]) a.dispose();
  }
}

const sigmoid = (x: number) => 1 / (1 + Math.exp(-x));
const dispose = (old: MlxArray, next: MlxArray): MlxArray => { old.dispose(); return next; };
