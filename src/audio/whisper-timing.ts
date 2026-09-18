// Word-level timestamps — a port of mlx-whisper's timing.py: cross-attention
// weights of the checkpoint's `alignment_heads` over the text tokens →
// z-normalize per head → median filter (width 7) along time → mean over
// heads → DTW (numba dtw_cpu / backtrace, ported to plain JS) → word
// boundaries from the tokenizer's word split; then add_word_timestamps'
// duration heuristics and punctuation merging. Runs the FAITHFUL decoder
// once per window with `wantCrossQk` (the alignment pass of the reference).

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { WhisperKvCache, type WhisperModel } from "../model/whisper";
import { WHISPER_HOP, WHISPER_SAMPLE_RATE, WHISPER_TOKENS_PER_SECOND } from "./whisper-mel";
import type { WhisperTokenizer } from "./whisper-tokenizer";
import type { WhisperSegment, WhisperWord } from "./whisper-transcribe";

export interface WordTiming {
  word: string;
  tokens: number[];
  start: number;
  end: number;
  probability: number;
}

/** Reflect-padded median filter along the last axis (scipy.signal.medfilt semantics
 *  on the padded row; odd width). */
export function medianFilter(x: Float32Array, rows: number, cols: number, width: number): Float32Array {
  const pad = Math.floor(width / 2);
  if (cols <= pad) return x;
  const out = new Float32Array(rows * cols);
  const buf = new Float32Array(width);
  for (let r = 0; r < rows; r++) {
    const row = x.subarray(r * cols, (r + 1) * cols);
    for (let c = 0; c < cols; c++) {
      for (let k = 0; k < width; k++) {
        let j = c - pad + k;
        if (j < 0) j = -j; // reflect
        else if (j >= cols) j = 2 * cols - j - 2;
        buf[k] = row[j]!;
      }
      const sorted = buf.slice().sort();
      out[r * cols + c] = sorted[pad]!;
    }
  }
  return out;
}

/** DTW over cost matrix x [N, M] (row-major); returns the aligned index
 *  pairs (text_indices, time_indices) like timing.dtw_cpu + backtrace. */
export function dtw(x: Float32Array, N: number, M: number): { text: Int32Array; time: Int32Array } {
  const cost = new Float32Array((N + 1) * (M + 1)).fill(Infinity);
  const trace = new Int8Array((N + 1) * (M + 1)).fill(-1);
  const W = M + 1;
  cost[0] = 0;
  for (let j = 1; j <= M; j++) {
    for (let i = 1; i <= N; i++) {
      const c0 = cost[(i - 1) * W + (j - 1)]!;
      const c1 = cost[(i - 1) * W + j]!;
      const c2 = cost[i * W + (j - 1)]!;
      let c: number;
      let t: number;
      if (c0 < c1 && c0 < c2) { c = c0; t = 0; }
      else if (c1 < c0 && c1 < c2) { c = c1; t = 1; }
      else { c = c2; t = 2; }
      cost[i * W + j] = x[(i - 1) * M + (j - 1)]! + c;
      trace[i * W + j] = t;
    }
  }
  // backtrace
  let i = N;
  let j = M;
  for (let jj = 0; jj <= M; jj++) trace[jj] = 2;
  for (let ii = 0; ii <= N; ii++) trace[ii * W] = 1;
  const text: number[] = [];
  const time: number[] = [];
  while (i > 0 || j > 0) {
    text.push(i - 1);
    time.push(j - 1);
    const t = trace[i * W + j];
    if (t === 0) { i--; j--; }
    else if (t === 1) i--;
    else if (t === 2) j--;
    else throw new Error("Unexpected trace value");
  }
  text.reverse();
  time.reverse();
  return { text: Int32Array.from(text), time: Int32Array.from(time) };
}

/** find_alignment: word timings for `textTokens` within one 30 s window
 *  (`mel` [1, 3000, n_mels] model dtype, `numFrames` = content mel frames). */
export function findAlignment(
  model: WhisperModel, tokenizer: WhisperTokenizer, language: string,
  textTokens: number[], mel: MlxArray, numFrames: number,
  medfiltWidth = 7, qkScale = 1.0,
): WordTiming[] {
  if (textTokens.length === 0) return [];
  const sot = tokenizer.sotSequence(language, "transcribe");
  const tokens = [...sot, tokenizer.noTimestamps, ...textTokens, tokenizer.eot];
  const feats = model.encode(mel);
  const cache = new WhisperKvCache(model.dims.nTextLayer);
  const tokArr = ops.fromInt32(tokens, [1, tokens.length]);
  const { logits, crossQk } = model.decode(tokArr, feats, cache, { wantCrossQk: true });
  tokArr.dispose();
  feats.dispose();
  cache.dispose();
  const V = model.dims.nVocab;
  const T = tokens.length;
  // text-token probabilities from the logits predicting each text token
  let sampled = logits.slice([0, sot.length, 0], [1, T - 2, tokenizer.eot]);
  logits.dispose();
  sampled = (() => { const r = ops.reshape(sampled, [T - 2 - sot.length, tokenizer.eot]); sampled.dispose(); return r; })();
  const probs = ops.softmaxAxis(sampled, -1, true);
  sampled.dispose();
  const idx = ops.fromInt32(textTokens, [textTokens.length, 1]);
  const picked = ops.takeAlongAxis(probs, idx, 1);
  idx.dispose();
  probs.dispose();
  const textTokenProbs = picked.toFloat32();
  picked.dispose();
  // alignment heads: [heads, T, frames]
  const heads = model.alignmentHeads;
  const frames = Math.floor(numFrames / 2);
  const stacked: MlxArray[] = [];
  for (const [l, h] of heads) {
    const qk = crossQk[l];
    if (!qk) continue;
    const w = qk.slice([0, h, 0, 0], [1, h + 1, T, frames]); // [1,1,T,frames]
    stacked.push(ops.reshape(w, [T, frames]));
    w.dispose();
  }
  for (const q of crossQk) q?.dispose();
  let weights = ops.stackAxis(stacked, 0); // [heads, T, frames]
  for (const a of stacked) a.dispose();
  if (qkScale !== 1.0) weights = (() => { const s = ops.scalarLike(qkScale, weights); const r = ops.mul(weights, s); s.dispose(); weights.dispose(); return r; })();
  weights = (() => { const r = ops.softmaxAxis(weights, -1, true); weights.dispose(); return r; })();
  weights = (() => { const r = weights.astype(Dtype.float32); weights.dispose(); return r; })();
  const mean = ops.meanAxis(weights, -2, true);
  let std = ops.varAxis(weights, -2, true, 0);
  std = (() => { const r = ops.sqrt(std); std.dispose(); return r; })();
  let z = ops.sub(weights, mean);
  z = (() => { const r = ops.div(z, std); z.dispose(); return r; })();
  weights.dispose(); mean.dispose(); std.dispose();
  const nHeads = stacked.length;
  const zHost = z.toFloat32();
  z.dispose();
  const filtered = medianFilter(zHost, nHeads * T, frames, medfiltWidth);
  // mean over heads → [T, frames], then rows sot.length … T-2
  const rows = T - 1 - sot.length;
  const matrix = new Float32Array(rows * frames);
  for (let r = 0; r < rows; r++)
    for (let f = 0; f < frames; f++) {
      let acc = 0;
      for (let h = 0; h < nHeads; h++) acc += filtered[(h * T + sot.length + r) * frames + f]!;
      matrix[r * frames + f] = -(acc / nHeads);
    }
  const { text: textIndices, time: timeIndices } = dtw(matrix, rows, frames);
  const { words, wordTokens } = tokenizer.splitToWordTokens([...textTokens, tokenizer.eot], language);
  if (wordTokens.length <= 1) return [];
  const boundaries = [0];
  for (let i = 0; i < wordTokens.length - 1; i++) boundaries.push(boundaries[i]! + wordTokens[i]!.length);
  const jumps: boolean[] = [true];
  for (let i = 1; i < textIndices.length; i++) jumps.push(textIndices[i]! - textIndices[i - 1]! !== 0);
  const jumpTimes: number[] = [];
  for (let i = 0; i < timeIndices.length; i++) if (jumps[i]) jumpTimes.push(timeIndices[i]! / WHISPER_TOKENS_PER_SECOND);
  const out: WordTiming[] = [];
  for (let w = 0; w < words.length; w++) {
    const a = boundaries[w]!;
    const b = boundaries[w + 1] ?? a;
    let p = 0;
    for (let i = a; i < b; i++) p += textTokenProbs[i] ?? 0;
    out.push({
      word: words[w]!, tokens: wordTokens[w]!,
      start: jumpTimes[a] ?? jumpTimes[jumpTimes.length - 1] ?? 0,
      end: jumpTimes[b] ?? jumpTimes[jumpTimes.length - 1] ?? 0,
      probability: b > a ? p / (b - a) : 0,
    });
  }
  return out;
}

const SENTENCE_END = ".。!！?？";

function mergePunctuations(alignment: WordTiming[], prepended: string, appended: string): void {
  let i = alignment.length - 2;
  let j = alignment.length - 1;
  while (i >= 0) {
    const previous = alignment[i]!;
    const following = alignment[j]!;
    if (previous.word.startsWith(" ") && prepended.includes(previous.word.trim())) {
      following.word = previous.word + following.word;
      following.tokens = [...previous.tokens, ...following.tokens];
      previous.word = "";
      previous.tokens = [];
    } else j = i;
    i--;
  }
  i = 0;
  j = 1;
  while (j < alignment.length) {
    const previous = alignment[i]!;
    const following = alignment[j]!;
    if (!previous.word.endsWith(" ") && appended.includes(following.word)) {
      previous.word = previous.word + following.word;
      previous.tokens = [...previous.tokens, ...following.tokens];
      following.word = "";
      following.tokens = [];
    } else i = j;
    j++;
  }
}

/** add_word_timestamps: annotates `segments` (one window) with words. */
export function addWordTimestamps(
  segments: WhisperSegment[], model: WhisperModel, tokenizer: WhisperTokenizer, language: string,
  mel: MlxArray, numFrames: number, lastSpeechTimestamp: number,
  prependPunctuations = "\"'“¿([{-", appendPunctuations = "\"'.。,，!！?？:：”)]}、",
): number {
  if (segments.length === 0) return lastSpeechTimestamp;
  const perSegment = segments.map((s) => s.tokens.filter((t) => t < tokenizer.eot));
  const textTokens = perSegment.flat();
  const alignment = findAlignment(model, tokenizer, language, textTokens, mel, numFrames);
  const durations = alignment.map((t) => t.end - t.start).filter((d) => d !== 0);
  const sortedD = [...durations].sort((a, b) => a - b);
  let medianDuration = sortedD.length ? (sortedD.length % 2 ? sortedD[(sortedD.length - 1) / 2]! : (sortedD[sortedD.length / 2 - 1]! + sortedD[sortedD.length / 2]!) / 2) : 0;
  medianDuration = Math.min(0.7, medianDuration);
  const maxDuration = medianDuration * 2;
  if (durations.length > 0) {
    for (let i = 1; i < alignment.length; i++) {
      const a = alignment[i]!;
      if (a.end - a.start > maxDuration) {
        if (SENTENCE_END.includes(a.word)) a.end = a.start + maxDuration;
        else if (SENTENCE_END.includes(alignment[i - 1]!.word)) a.start = a.end - maxDuration;
      }
    }
  }
  mergePunctuations(alignment, prependPunctuations, appendPunctuations);
  const timeOffset = (segments[0]!.seek * WHISPER_HOP) / WHISPER_SAMPLE_RATE;
  let wordIndex = 0;
  for (let si = 0; si < segments.length; si++) {
    const segment = segments[si]!;
    const tt = perSegment[si]!;
    let saved = 0;
    const words: WhisperWord[] = [];
    while (wordIndex < alignment.length && saved < tt.length) {
      const timing = alignment[wordIndex]!;
      if (timing.word)
        words.push({ word: timing.word, start: Math.round((timeOffset + timing.start) * 100) / 100, end: Math.round((timeOffset + timing.end) * 100) / 100, probability: timing.probability });
      saved += timing.tokens.length;
      wordIndex++;
    }
    if (words.length > 0) {
      const w0 = words[0]!;
      if (w0.end - lastSpeechTimestamp > medianDuration * 4 &&
          (w0.end - w0.start > maxDuration || (words.length > 1 && words[1]!.end - w0.start > maxDuration * 2))) {
        if (words.length > 1 && words[1]!.end - words[1]!.start > maxDuration) {
          const boundary = Math.max(words[1]!.end / 2, words[1]!.end - maxDuration);
          w0.end = words[1]!.start = boundary;
        }
        w0.start = Math.max(0, w0.end - maxDuration);
      }
      if (segment.start < w0.end && segment.start - 0.5 > w0.start)
        w0.start = Math.max(0, Math.min(w0.end - medianDuration, segment.start));
      else segment.start = w0.start;
      const wl = words[words.length - 1]!;
      if (segment.end > wl.start && segment.end + 0.5 < wl.end)
        wl.end = Math.max(wl.start + medianDuration, segment.end);
      else segment.end = wl.end;
      lastSpeechTimestamp = segment.end;
    }
    segment.words = words;
  }
  return lastSpeechTimestamp;
}
