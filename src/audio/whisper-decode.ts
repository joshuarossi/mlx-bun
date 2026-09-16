// Whisper 30 s-window decoding — a port of mlx-whisper's decoding.py
// (DecodingTask: greedy/sampled decoding, logit filters, language
// detection, ranking) plus the beam search the oracle leaves unimplemented
// (ported from openai-whisper's BeamSearchDecoder, which mlx-whisper
// mirrors everywhere else). Per-step pre-filter logits are gated
// bit-exact vs the oracle for the greedy path (tests/parity/whisper.test.ts).

import { deflateSync } from "node:zlib";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { WhisperKvCache, type WhisperModel } from "../model/whisper";
import { FastKvCache, type FastFilterConfig } from "./whisper-fast";
import { WHISPER_CHUNK_SECONDS } from "./whisper-mel";
import { normalizeWhisperLanguage, type WhisperTask, type WhisperTokenizer } from "./whisper-tokenizer";

export interface WhisperDecodingOptions {
  task?: WhisperTask;
  /** null → detect. */
  language?: string | null;
  temperature?: number;
  sampleLen?: number | null;
  bestOf?: number | null;
  beamSize?: number | null;
  patience?: number | null;
  lengthPenalty?: number | null;
  prompt?: string | number[] | null;
  prefix?: string | number[] | null;
  /** Token ids to suppress; "-1" = the tokenizer's non-speech set (default). */
  suppressTokens?: number[] | "-1" | null;
  /** Execution path: `true` (default) runs the optimized graphs
   *  (whisper-fast.ts) for temperature-0 decoding; `false` forces the
   *  faithful oracle graph. Sampling (temperature > 0) always uses the
   *  faithful path. */
  fast?: boolean;
  /** Lab (whisper.cpp `-ac`): encode only the first `audioCtx` of the 1500
   *  encoder positions (2·audioCtx mel frames). Cheaper for short clips
   *  but NOT the trained context — measured hallucinated repeats below
   *  ~1024 on the fixture clips. null = full context. Fast path only. */
  audioCtx?: number | null;
  /** Parity instrumentation: the decode window's encoder output and each
   *  step's PRE-filter last-position logits [n_group, V] f32 (borrowed —
   *  valid only during the callback). */
  observer?: WhisperDecodeObserver;
  suppressBlank?: boolean;
  withoutTimestamps?: boolean;
  maxInitialTimestamp?: number | null;
}

export interface WhisperDecodeObserver {
  onAudioFeatures?(features: MlxArray): void;
  onStepLogits?(step: number, logits: MlxArray): void;
  /** After each step: the live rows (token histories) and their cumulative log-probs. */
  onStepRows?(step: number, rows: number[][], sumLogprobs: number[]): void;
}

export interface WhisperDecodingResult {
  language: string;
  languageProbs?: Record<string, number>;
  tokens: number[];
  text: string;
  avgLogprob: number;
  noSpeechProb: number;
  temperature: number;
  compressionRatio: number;
}

export function compressionRatio(text: string): number {
  const bytes = Buffer.from(text, "utf8");
  return bytes.length / deflateSync(bytes).length;
}

const dispose = (old: MlxArray, next: MlxArray): MlxArray => {
  old.dispose();
  return next;
};

/** DecodingTask over one audio window (n_audio = 1). */
export class WhisperDecodingTask {
  readonly model: WhisperModel;
  readonly tokenizer: WhisperTokenizer;
  readonly options: Required<Omit<WhisperDecodingOptions, "language">> & { language: string | null };
  readonly nGroup: number;
  readonly nCtx: number;
  readonly sampleLen: number;
  readonly sotSequence: number[];
  readonly initialTokens: number[];
  readonly sampleBegin: number;
  readonly sotIndex: number;
  readonly #suppressMask: MlxArray | null;
  readonly #blankMask: MlxArray | null;
  readonly #suppressIds: number[];
  readonly #blankIds: number[] | null;
  readonly #maxInitialTimestampIndex: number | null;
  readonly #useTimestampRules: boolean;
  /** Language for the tokenizer sequence (oracle: options.language or "en"). */
  readonly tokenizerLanguage: string;

  constructor(model: WhisperModel, tokenizer: WhisperTokenizer, options: WhisperDecodingOptions) {
    this.model = model;
    this.tokenizer = tokenizer;
    const o = {
      task: options.task ?? "transcribe",
      language: options.language == null ? null : normalizeWhisperLanguage(options.language),
      temperature: options.temperature ?? 0,
      sampleLen: options.sampleLen ?? null,
      bestOf: options.bestOf ?? null,
      beamSize: options.beamSize ?? null,
      patience: options.patience ?? null,
      lengthPenalty: options.lengthPenalty ?? null,
      prompt: options.prompt ?? null,
      prefix: options.prefix ?? null,
      suppressTokens: options.suppressTokens === undefined ? "-1" as const : options.suppressTokens,
      suppressBlank: options.suppressBlank ?? true,
      withoutTimestamps: options.withoutTimestamps ?? false,
      maxInitialTimestamp: options.maxInitialTimestamp === undefined ? 1.0 : options.maxInitialTimestamp,
      observer: options.observer ?? {},
      fast: options.fast ?? true,
      audioCtx: options.audioCtx ?? null,
    };
    if (o.audioCtx !== null && (!Number.isInteger(o.audioCtx) || o.audioCtx < 64 || o.audioCtx > model.dims.nAudioCtx))
      throw new Error(`audio_ctx must be an integer in [64, ${model.dims.nAudioCtx}]`);
    if (o.beamSize !== null && o.bestOf !== null) throw new Error("beam_size and best_of can't be given together");
    if (o.temperature === 0 && o.bestOf !== null) throw new Error("best_of with greedy sampling (T=0) is not compatible");
    if (o.patience !== null && o.beamSize === null) throw new Error("patience requires beam_size to be given");
    if (o.lengthPenalty !== null && !(o.lengthPenalty >= 0 && o.lengthPenalty <= 1))
      throw new Error("length_penalty (alpha) should be a value between 0 and 1");
    this.options = o;
    this.tokenizerLanguage = o.language ?? "en";
    this.nGroup = o.beamSize ?? o.bestOf ?? 1;
    this.nCtx = model.dims.nTextCtx;
    this.sampleLen = o.sampleLen ?? Math.floor(model.dims.nTextCtx / 2);
    this.sotSequence = tokenizer.sotSequence(this.tokenizerLanguage, o.task);
    if (o.withoutTimestamps) this.sotSequence = [...this.sotSequence, tokenizer.noTimestamps];
    this.initialTokens = this.#initialTokens();
    this.sampleBegin = this.initialTokens.length;
    this.sotIndex = this.initialTokens.indexOf(tokenizer.sot);

    const V = model.dims.nVocab;
    this.#blankIds = o.suppressBlank ? [...tokenizer.encode(" "), tokenizer.eot] : null;
    this.#blankMask = this.#blankIds ? maskOf(V, this.#blankIds) : null;
    const suppress = this.#suppressTokens();
    this.#suppressIds = suppress;
    this.#suppressMask = suppress.length ? maskOf(V, suppress) : null;
    this.#useTimestampRules = !o.withoutTimestamps;
    const precision = WHISPER_CHUNK_SECONDS / model.dims.nAudioCtx; // 0.02
    this.#maxInitialTimestampIndex = o.maxInitialTimestamp ? Math.round(o.maxInitialTimestamp / precision) : null;
  }

  #initialTokens(): number[] {
    const t = this.tokenizer;
    let tokens = [...this.sotSequence];
    const { prefix, prompt } = this.options;
    if (prefix) {
      let prefixTokens = typeof prefix === "string" ? t.encode(" " + prefix.trim()) : prefix;
      const maxPrefixLen = Math.floor(this.nCtx / 2) - this.sampleLen;
      prefixTokens = prefixTokens.slice(Math.max(0, prefixTokens.length - maxPrefixLen));
      if (maxPrefixLen <= 0) prefixTokens = []; // python: list[-0:] → whole list; guard matches sample_len default
      tokens = [...tokens, ...prefixTokens];
    }
    if (prompt && prompt.length) {
      const promptTokens = typeof prompt === "string" ? t.encode(" " + prompt.trim()) : prompt;
      const keep = Math.floor(this.nCtx / 2) - 1;
      tokens = [t.sotPrev, ...promptTokens.slice(Math.max(0, promptTokens.length - keep)), ...tokens];
    }
    return tokens;
  }

  #suppressTokens(): number[] {
    const t = this.tokenizer;
    let suppress: number[];
    const opt = this.options.suppressTokens;
    if (opt === "-1") suppress = [...t.nonSpeechTokens];
    else if (opt === null || opt.length === 0) suppress = [];
    else if (opt.includes(-1)) suppress = [...opt.filter((x) => x >= 0), ...t.nonSpeechTokens];
    else suppress = [...opt];
    suppress.push(t.transcribe, t.translate, t.sot, t.sotPrev, t.sotLm, t.noSpeech);
    return [...new Set(suppress)].sort((a, b) => a - b);
  }

  /** Prompt-token budget the transcribe loop may carry (n_ctx/2 − 1). */
  get promptBudget(): number {
    return Math.floor(this.nCtx / 2) - 1;
  }

  // --- logit filters ----------------------------------------------------------

  /** Host-side timestamp-rule mask (ApplyTimestampRules, numpy part). */
  #timestampMask(tokens: number[][]): Float32Array {
    const t = this.tokenizer;
    const V = this.model.dims.nVocab;
    const B = tokens.length;
    const mask = new Float32Array(B * V);
    const fill = (row: number, from: number, to: number) => {
      for (let i = from; i < to; i++) mask[row * V + i] = -Infinity;
    };
    for (let k = 0; k < B; k++) mask[k * V + t.noTimestamps] = -Infinity;
    for (let k = 0; k < B; k++) {
      const seq = tokens[k]!.slice(this.sampleBegin);
      const lastWasTimestamp = seq.length >= 1 && seq[seq.length - 1]! >= t.timestampBegin;
      const penultimateWasTimestamp = seq.length < 2 || seq[seq.length - 2]! >= t.timestampBegin;
      if (lastWasTimestamp) {
        if (penultimateWasTimestamp) fill(k, t.timestampBegin, V);
        else fill(k, 0, t.eot);
      }
      // Monotonic timestamps (openai-whisper decoding.py): forbid timestamp
      // tokens below the last one emitted, and force a nonzero segment
      // length. mlx-whisper's port collects sequence INDICES here and slices
      // `mask[k, timestamp_begin:index]` — an empty slice, so its rule never
      // fires; we keep the reference semantics (pre-filter logits stay
      // bit-exact; the only difference is which timestamp a beam may pick).
      let lastTs = -1;
      for (const v of seq) if (v >= t.timestampBegin) lastTs = v;
      if (lastTs >= 0) {
        const timestampLast = lastWasTimestamp && !penultimateWasTimestamp ? lastTs : lastTs + 1;
        fill(k, t.timestampBegin, Math.min(V, timestampLast));
      }
    }
    if (tokens[0]!.length === this.sampleBegin) {
      for (let k = 0; k < B; k++) fill(k, 0, t.timestampBegin);
      if (this.#maxInitialTimestampIndex !== null) {
        const lastAllowed = t.timestampBegin + this.#maxInitialTimestampIndex;
        for (let k = 0; k < B; k++) fill(k, lastAllowed + 1, V);
      }
    }
    return mask;
  }

  /** Apply the configured filters to `logits` [B, V] f32 → new array. */
  applyFilters(logits: MlxArray, tokens: number[][]): MlxArray {
    let out = logits;
    let owned = false;
    if (this.#blankMask && tokens[0]!.length === this.sampleBegin) {
      out = ops.add(out, this.#blankMask);
      owned = true;
    }
    if (this.#suppressMask) {
      const next = ops.add(out, this.#suppressMask);
      if (owned) out.dispose();
      out = next;
      owned = true;
    }
    if (this.#useTimestampRules) {
      const t = this.tokenizer;
      const B = tokens.length;
      const V = this.model.dims.nVocab;
      const mask = MlxArray.fromFloat32(this.#timestampMask(tokens), [B, V]);
      const lse = ops.logsumexpAxis(out, -1, true);
      const logprobs = ops.sub(out, lse);
      lse.dispose();
      const tsPart = logprobs.slice([0, t.timestampBegin], [B, V]);
      const tsLogprob = ops.logsumexpAxis(tsPart, -1, true);
      tsPart.dispose();
      const textPart = logprobs.slice([0, 0], [B, t.timestampBegin]);
      const maxText = ops.maxAxis(textPart, -1, true);
      textPart.dispose();
      logprobs.dispose();
      const cond = ops.greater(tsLogprob, maxText);
      tsLogprob.dispose();
      maxText.dispose();
      const maskText = mask.slice([0, 0], [B, t.timestampBegin]);
      const maskTs = mask.slice([0, t.timestampBegin], [B, V]);
      const negInf = MlxArray.fromFloat32(new Float32Array([-Infinity]), []);
      const masked = ops.where(cond, negInf, maskText);
      const full = ops.concatAxis([masked, maskTs], 1);
      for (const a of [cond, maskText, maskTs, negInf, masked, mask]) a.dispose();
      const next = ops.add(out, full);
      full.dispose();
      if (owned) out.dispose();
      out = next;
      owned = true;
    }
    return owned ? out : ops.copyOf(out);
  }

  // --- language detection -------------------------------------------------------

  /** detect_language on encoded audio features [1, 1500, D]. */
  detectLanguage(audioFeatures: MlxArray): { token: number; code: string; probs: Record<string, number> } {
    const t = this.tokenizer;
    const cache = new WhisperKvCache(this.model.dims.nTextLayer);
    const x = ops.fromInt32([t.sot], [1, 1]);
    const { logits: raw } = this.model.decode(x, audioFeatures, cache);
    x.dispose();
    cache.dispose();
    const V = this.model.dims.nVocab;
    let logits = raw.slice([0, 0, 0], [1, 1, V]);
    raw.dispose();
    logits = dispose(logits, ops.reshape(logits, [1, V]));
    // mask: -inf everywhere except language tokens (float32 → promotes f16 logits)
    const m = new Float32Array(V).fill(-Infinity);
    for (const id of t.allLanguageTokens) m[id] = 0;
    const mask = MlxArray.fromFloat32(m, [V]);
    logits = dispose(logits, ops.add(logits, mask));
    mask.dispose();
    const arg = ops.argmaxAxis(logits, -1);
    const token = arg.toIntTokens()[0]!;
    arg.dispose();
    const probsArr = ops.softmaxAxis(logits, -1, false);
    const probs = probsArr.toFloat32();
    probsArr.dispose();
    logits.dispose();
    const out: Record<string, number> = {};
    t.allLanguageTokens.forEach((id, i) => { out[t.allLanguageCodes[i]!] = probs[id]!; });
    return { token, code: t.allLanguageCodes[t.allLanguageTokens.indexOf(token)]!, probs: out };
  }

  // --- main loop ----------------------------------------------------------------

  /** Whether this task decodes on the optimized path. */
  get useFast(): boolean {
    return this.options.fast && this.options.temperature === 0;
  }

  /** Encoder for this task's path. */
  encode(mel: MlxArray): MlxArray {
    if (this.options.audioCtx !== null) return this.model.fast.encode(mel, this.options.audioCtx);
    return this.options.fast ? this.model.fast.encode(mel) : this.model.encode(mel);
  }

  #fastFilterConfig(): FastFilterConfig {
    return {
      nVocab: this.model.dims.nVocab,
      eot: this.tokenizer.eot,
      timestampBegin: this.tokenizer.timestampBegin,
      noTimestamps: this.tokenizer.noTimestamps,
      suppressIds: this.#suppressIds,
      blankIds: this.#blankIds,
      useTimestampRules: this.#useTimestampRules,
      maxInitialTimestampIndex: this.#maxInitialTimestampIndex,
    };
  }

  /** Run on a mel window [1, 3000, n_mels] (already the model dtype) or
   *  pre-encoded audio features [1, 1500, D]. */
  run(melOrFeatures: MlxArray): WhisperDecodingResult {
    const { model, tokenizer: t } = this;
    const d = model.dims;
    // encoder output has the text width (1280); a mel window has n_mels (128)
    const isFeatures = melOrFeatures.shape[2] === d.nAudioState;
    const audioFeatures = isFeatures ? melOrFeatures : this.encode(melOrFeatures);
    try {
      return this.#runOnFeatures(audioFeatures);
    } finally {
      if (!isFeatures) audioFeatures.dispose();
    }
  }

  #runGreedyFast(audioFeatures: MlxArray, rows: number[][], language: string, languageProbs: Record<string, number> | undefined): WhisperDecodingResult {
    const { model, tokenizer: t } = this;
    const B = rows.length;
    const cache = new FastKvCache();
    const cfg = this.#fastFilterConfig();
    model.fast.crossKv(audioFeatures, cache);
    const sumLp: number[] = new Array(B).fill(0);
    let noSpeechProb = Number.NaN;
    const initial = rows[0]!;
    const owned: MlxArray[] = [];
    try {
      // step 0: eager prefill + host filters (sample_begin rules)
      const inputTokens = ops.fromInt32(rows.flat(), [B, initial.length]);
      const raw = model.fast.prefill(inputTokens, cache);
      inputTokens.dispose();
      const preLogits = raw.astype(Dtype.float32);
      raw.dispose();
      const L = preLogits.shape[1]!;
      const V = preLogits.shape[2]!;
      let last = preLogits.slice([0, L - 1, 0], [B, L, V]);
      last = dispose(last, ops.reshape(last, [B, V]));
      let atSot = preLogits.slice([0, this.sotIndex, 0], [B, this.sotIndex + 1, V]);
      atSot = dispose(atSot, ops.reshape(atSot, [B, V]));
      const probs = ops.softmaxAxis(atSot, -1, false);
      atSot.dispose();
      const colView = probs.slice([0, t.noSpeech], [B, t.noSpeech + 1]);
      probs.dispose();
      const col = ops.contiguous(colView);
      colView.dispose();
      noSpeechProb = col.toFloat32()[0]!;
      col.dispose();
      preLogits.dispose();
      const filtered = this.applyFilters(last, rows);
      last.dispose();
      let next = ops.argmaxAxis(filtered, -1);
      next = dispose(next, next.astype(Dtype.int32));
      const lse = ops.logsumexpAxis(filtered, -1, true);
      const logprobs = ops.sub(filtered, lse);
      lse.dispose();
      filtered.dispose();
      const idx = ops.reshape(next, [B, 1]);
      let lp = ops.takeAlongAxis(logprobs, idx, 1);
      idx.dispose();
      logprobs.dispose();
      lp = dispose(lp, ops.reshape(lp, [B]));
      const tb = t.timestampBegin;
      const tsBeginArr = ops.fromInt32([tb], [1]);
      const minusOne = ops.fromInt32(new Array(B).fill(-1), [B]);
      const isTs0 = ops.greaterEqual(next, tsBeginArr);
      let lastTs = ops.where(isTs0, next, minusOne);
      isTs0.dispose();
      let lastTok = next; // token appended at step 0 becomes seq[-1]
      let penultTok: MlxArray = minusOne; // seq has one element after step 0
      owned.push(tsBeginArr, minusOne);
      ops.asyncEvalAll([next, lp, lastTs, ...cache.k, ...cache.v]);
      // pending = step whose token the host has not consumed yet
      let pending: { next: MlxArray; lp: MlxArray } = { next, lp };
      let done = false;
      for (let i = 1; i < this.sampleLen && !done; i++) {
        if (rows[0]!.length + 1 > this.nCtx) break;
        // issue step i BEFORE reading step i-1's token (pipelining)
        const out = model.fast.greedyStep({ tok: lastTok, lastTok, penultTok, lastTs }, cache, cfg);
        ops.asyncEvalAll([out.next, out.lp, out.lastTs, ...cache.k, ...cache.v]);
        // consume step i-1
        const toks = pending.next.toIntTokens();
        const lps = pending.lp.toFloat32();
        done = true;
        for (let b = 0; b < B; b++) {
          const r = rows[b]!;
          const wasEot = r[r.length - 1] === t.eot;
          const tok = wasEot ? t.eot : toks[b]!;
          if (!wasEot) sumLp[b] = sumLp[b]! + lps[b]!;
          r.push(tok);
          if (tok !== t.eot) done = false;
        }
        pending.lp.dispose();
        out.pre.dispose();
        // rotate state: step i's inputs were (lastTok=tok_{i-1}); its outputs feed step i+1
        if (penultTok !== minusOne) penultTok.dispose();
        penultTok = lastTok;
        lastTok = out.next;
        lastTs.dispose();
        lastTs = out.lastTs;
        pending = { next: out.next, lp: out.lp };
      }
      if (!done) {
        // consume the last issued step (loop bound hit)
        const toks = pending.next.toIntTokens();
        const lps = pending.lp.toFloat32();
        for (let b = 0; b < B; b++) {
          const r = rows[b]!;
          const wasEot = r[r.length - 1] === t.eot;
          if (!wasEot) { sumLp[b] = sumLp[b]! + lps[b]!; r.push(toks[b]!); } else r.push(t.eot);
        }
      }
      pending.lp.dispose();
      if (lastTok !== pending.next) lastTok.dispose();
      pending.next.dispose();
      if (penultTok !== minusOne) penultTok.dispose();
      lastTs.dispose();
    } finally {
      for (const a of owned) a.dispose();
      cache.dispose();
    }
    // finalize like GreedyDecoder: ensure EOT, cut at first EOT
    const seqs = rows.map((r) => {
      const s = [...r.slice(this.sampleBegin), t.eot];
      return s.slice(0, s.indexOf(t.eot));
    });
    const tokens = seqs[0]!;
    const text = t.decode(tokens).trim();
    return {
      language, languageProbs, tokens, text,
      avgLogprob: sumLp[0]! / (tokens.length + 1),
      noSpeechProb, temperature: 0, compressionRatio: compressionRatio(text),
    };
  }

  #runOnFeatures(audioFeatures: MlxArray): WhisperDecodingResult {
    const { model, tokenizer: t } = this;
    this.options.observer.onAudioFeatures?.(audioFeatures);
    const initial = [...this.initialTokens];
    let language = this.options.language;
    let languageProbs: Record<string, number> | undefined;
    if (language === null) {
      const det = this.detectLanguage(audioFeatures);
      language = det.code;
      languageProbs = det.probs;
      initial[this.sotIndex + 1] = det.token;
    }
    const nGroup = this.nGroup;
    const rows: number[][] = Array.from({ length: nGroup }, () => [...initial]);
    const fast = this.useFast;
    if (fast && this.options.beamSize === null && !this.options.observer.onStepLogits)
      return this.#runGreedyFast(audioFeatures, rows, language!, languageProbs);
    const cache: WhisperKvCache | FastKvCache = fast ? new FastKvCache() : new WhisperKvCache(model.dims.nTextLayer);
    const fastCfg = fast ? this.#fastFilterConfig() : null;
    if (fast) model.fast.crossKv(audioFeatures, cache as FastKvCache);
    const decoder = this.options.beamSize !== null
      ? new BeamSearchDecoder(this.options.beamSize, t.eot, cache, this.options.patience)
      : new GreedyDecoder(this.options.temperature, t.eot);
    let sumLogprobs = ops.zeros([nGroup], Dtype.float32);
    let noSpeechProb = Number.NaN;
    try {
      let completed = false;
      for (let i = 0; i < this.sampleLen; i++) {
        if (rows[0]!.length > this.nCtx) break;
        let last: MlxArray;
        let filtered: MlxArray;
        if (i === 0 || !fast) {
          const inputTokens = i === 0
            ? ops.fromInt32(rows.flat(), [nGroup, initial.length])
            : ops.fromInt32(rows.map((r) => r[r.length - 1]!), [nGroup, 1]);
          const raw = fast
            ? model.fast.prefill(inputTokens, cache as FastKvCache)
            : model.decode(inputTokens, audioFeatures, cache as WhisperKvCache).logits;
          inputTokens.dispose();
          const preLogits = raw.astype(Dtype.float32);
          raw.dispose();
          const L = preLogits.shape[1]!;
          const V = preLogits.shape[2]!;
          last = preLogits.slice([0, L - 1, 0], [nGroup, L, V]);
          last = dispose(last, ops.reshape(last, [nGroup, V]));
          if (i === 0) {
            // no_speech_probs = softmax(pre_logits[:, sot_index])[:, no_speech]
            let atSot = preLogits.slice([0, this.sotIndex, 0], [nGroup, this.sotIndex + 1, V]);
            atSot = dispose(atSot, ops.reshape(atSot, [nGroup, V]));
            const probs = ops.softmaxAxis(atSot, -1, false);
            atSot.dispose();
            const colView = probs.slice([0, t.noSpeech], [nGroup, t.noSpeech + 1]);
            probs.dispose();
            const col = ops.contiguous(colView); // strided view → materialize before readback
            colView.dispose();
            noSpeechProb = col.toFloat32()[0]!;
            col.dispose();
          }
          preLogits.dispose();
          this.options.observer.onStepLogits?.(i, last);
          filtered = this.applyFilters(last, rows);
        } else {
          const tb = t.timestampBegin;
          const seqs = rows.map((r) => r.slice(this.sampleBegin));
          const state = {
            lastTok: seqs.map((q) => q[q.length - 1] ?? -1),
            penultTok: seqs.map((q) => q.length >= 2 ? q[q.length - 2]! : -1),
            lastTs: seqs.map((q) => { let v = -1; for (const x of q) if (x >= tb) v = x; return v; }),
            atBegin: rows[0]!.length === this.sampleBegin,
          };
          if (decoder instanceof BeamSearchDecoder) {
            const out = model.fast.beamStep(rows.map((r) => r[r.length - 1]!), cache as FastKvCache, fastCfg!, decoder.beamSize + 1, state);
            this.options.observer.onStepLogits?.(i, out.pre);
            out.pre.dispose();
            const step = decoder.updateFromTopK(rows, out.idx, out.vals, sumLogprobs);
            sumLogprobs = step.sumLogprobs;
            completed = step.completed;
            if (this.options.observer.onStepRows)
              this.options.observer.onStepRows(i, rows.map((r) => [...r]), [...sumLogprobs.toFloat32()]);
            if (completed) break;
            continue;
          }
          const out = model.fast.step(rows.map((r) => r[r.length - 1]!), cache as FastKvCache, fastCfg!, state);
          last = out.pre;
          filtered = out.filtered;
          this.options.observer.onStepLogits?.(i, last);
        }
        last.dispose();
        const step = decoder.update(rows, filtered, sumLogprobs);
        filtered.dispose();
        sumLogprobs = step.sumLogprobs;
        completed = step.completed;
        if (this.options.observer.onStepRows)
          this.options.observer.onStepRows(i, rows.map((r) => [...r]), [...sumLogprobs.toFloat32()]);
        if (completed) break;
      }
      const fin = decoder.finalize(rows, sumLogprobs);
      const seqs = fin.tokens.map((r) => {
        const s = r.slice(this.sampleBegin);
        const e = s.indexOf(t.eot);
        return e >= 0 ? s.slice(0, e) : s;
      });
      const lps = fin.sumLogprobs;
      // MaximumLikelihoodRanker
      const scores = seqs.map((s, k) => {
        const length = s.length;
        const penalty = this.options.lengthPenalty === null ? length : ((5 + length) / 6) ** this.options.lengthPenalty;
        return lps[k]! / penalty;
      });
      let best = 0;
      for (let k = 1; k < scores.length; k++) if (scores[k]! > scores[best]!) best = k;
      const tokens = seqs[best]!;
      const text = t.decode(tokens).trim();
      return {
        language: language!,
        languageProbs,
        tokens,
        text,
        avgLogprob: lps[best]! / (tokens.length + 1),
        noSpeechProb,
        temperature: this.options.temperature,
        compressionRatio: compressionRatio(text),
      };
    } finally {
      sumLogprobs.dispose();
      cache.dispose();
    }
  }
}

function maskOf(V: number, ids: number[]): MlxArray {
  const m = new Float32Array(V);
  for (const id of ids) m[id] = -Infinity;
  return MlxArray.fromFloat32(m, [V]);
}

interface TokenDecoder {
  /** Mutates `rows` (appends the chosen token per row). Takes ownership of
   *  `sumLogprobs` and returns the new one. */
  update(rows: number[][], logits: MlxArray, sumLogprobs: MlxArray): { completed: boolean; sumLogprobs: MlxArray };
  finalize(rows: number[][], sumLogprobs: MlxArray): { tokens: number[][]; sumLogprobs: number[] };
}

/** GreedyDecoder (temperature 0 → argmax, else categorical sampling). */
class GreedyDecoder implements TokenDecoder {
  constructor(readonly temperature: number, readonly eot: number) {}

  update(rows: number[][], logits: MlxArray, sumLogprobs: MlxArray) {
    const B = rows.length;
    let nextArr: MlxArray;
    if (this.temperature === 0) nextArr = ops.argmaxAxis(logits, -1);
    else {
      const temp = ops.scalarLike(this.temperature, logits);
      const scaled = ops.div(logits, temp);
      temp.dispose();
      // mx.random.categorical(logits / temp) on the GLOBAL key, like the oracle
      nextArr = ops.randomCategorical(scaled, null);
      scaled.dispose();
    }
    nextArr = dispose(nextArr, nextArr.astype(Dtype.int32));
    const lse = ops.logsumexpAxis(logits, -1, true);
    const logprobs = ops.sub(logits, lse);
    lse.dispose();
    const idx = ops.reshape(nextArr, [B, 1]);
    let current = ops.takeAlongAxis(logprobs, idx, 1);
    idx.dispose();
    logprobs.dispose();
    current = dispose(current, ops.reshape(current, [B]));
    const lastWasEot = rows.map((r) => (r[r.length - 1] === this.eot ? 1 : 0));
    const notEot = MlxArray.fromFloat32(new Float32Array(lastWasEot.map((e) => 1 - e)), [B]);
    const contrib = ops.mul(current, notEot);
    current.dispose();
    notEot.dispose();
    const newSum = ops.add(sumLogprobs, contrib);
    contrib.dispose();
    sumLogprobs.dispose();
    const next = nextArr.toIntTokens();
    nextArr.dispose();
    let completed = true;
    for (let k = 0; k < B; k++) {
      const tok = lastWasEot[k] ? this.eot : next[k]!;
      rows[k]!.push(tok);
      if (tok !== this.eot) completed = false;
    }
    return { completed, sumLogprobs: newSum };
  }

  finalize(rows: number[][], sumLogprobs: MlxArray) {
    const lp = [...sumLogprobs.toFloat32()];
    return { tokens: rows.map((r) => [...r, this.eot]), sumLogprobs: lp };
  }

}

/** BeamSearchDecoder (openai-whisper decoding.py) for n_audio = 1: keeps
 *  `beamSize` live hypotheses as cache rows, collects finished sequences
 *  per audio, stops after `beamSize × patience` finished sequences. Cumulative
 *  log-probs are tracked on the host (beam scores are sums of read-back
 *  candidate log-probs, same arithmetic as the reference's python floats). */
class BeamSearchDecoder implements TokenDecoder {
  readonly maxCandidates: number;
  #finished = new Map<string, { tokens: number[]; logprob: number }>();
  constructor(
    readonly beamSize: number, readonly eot: number, readonly cache: { rearrange(indices: number[]): void },
    patience: number | null,
  ) {
    this.maxCandidates = Math.round(beamSize * (patience ?? 1.0));
    if (this.maxCandidates <= 0) throw new Error(`Invalid beam size (${beamSize}) or patience (${patience})`);
  }

  update(rows: number[][], logits: MlxArray, sumLogprobs: MlxArray) {
    const B = rows.length;
    if (B !== this.beamSize) throw new Error(`beam rows ${B} != beam size ${this.beamSize}`);
    const k = this.beamSize + 1;
    const lse = ops.logsumexpAxis(logits, -1, true);
    const logprobs = ops.sub(logits, lse);
    lse.dispose();
    // top-k per row on device: argpartition puts the k SMALLEST first, so
    // partition the negated log-probs; values gathered, sorted on host.
    const neg = ops.neg(logprobs);
    const part = ops.argpartitionAxis(neg, k - 1, -1);
    neg.dispose();
    // The [B, k] slice is a strided VIEW of the [B, V] partition; host
    // readback walks memory linearly, so materialize it first.
    const idxView = part.slice([0, 0], [B, k]);
    part.dispose();
    const idx = ops.contiguous(idxView);
    idxView.dispose();
    const vals = ops.takeAlongAxis(logprobs, idx, 1);
    logprobs.dispose();
    return this.updateFromTopK(rows, idx, vals, sumLogprobs);
  }

  /** Beam update from device top-k `idx`/`vals` [B, k] (owned, disposed here). */
  updateFromTopK(rows: number[][], idx: MlxArray, vals: MlxArray, sumLogprobs: MlxArray) {
    const B = rows.length;
    const k = this.beamSize + 1;
    const topIdx = idx.toIntTokens();
    idx.dispose();
    const topVals = vals.toFloat32();
    vals.dispose();
    const prevSum = [...sumLogprobs.toFloat32()];
    sumLogprobs.dispose();
    // reference: for each beam, its top-(beam+1) candidates by logprob;
    // scores collected in a dict keyed by the sequence (dedup), then the
    // best `beamSize` unfinished are kept.
    const scores = new Map<string, number>();
    const sources = new Map<string, number>();
    const seqOf = new Map<string, number[]>();
    for (let j = 0; j < B; j++) {
      const cands: { lp: number; tok: number }[] = [];
      for (let c = 0; c < k; c++) cands.push({ lp: topVals[j * k + c]!, tok: topIdx[j * k + c]! });
      cands.sort((a, b) => b.lp - a.lp);
      for (const { lp, tok } of cands) {
        const seq = [...rows[j]!, tok];
        const key = seq.join(",");
        scores.set(key, prevSum[j]! + lp);
        sources.set(key, j);
        seqOf.set(key, seq);
      }
    }
    // python dict insertion order + sorted(scores, key=scores.get, reverse=True)
    // — a stable sort, so ties keep insertion order.
    const ordered = [...scores.keys()].sort((a, b) => scores.get(b)! - scores.get(a)!);
    const nextRows: number[][] = [];
    const nextSum: number[] = [];
    const sourceIdx: number[] = [];
    let saved = 0;
    for (const key of ordered) {
      const seq = seqOf.get(key)!;
      if (seq[seq.length - 1] === this.eot) {
        if (!this.#finished.has(key)) this.#finished.set(key, { tokens: seq, logprob: scores.get(key)! });
      } else {
        nextRows.push(seq);
        nextSum.push(scores.get(key)!);
        sourceIdx.push(sources.get(key)!);
        saved++;
        if (saved === this.beamSize) break;
      }
    }
    // pad (only when fewer than beamSize unfinished exist — all EOT)
    while (nextRows.length < this.beamSize) {
      const j = nextRows.length;
      nextRows.push([...rows[j]!, this.eot]);
      nextSum.push(prevSum[j]!);
      sourceIdx.push(j);
    }
    for (let j = 0; j < B; j++) rows[j] = nextRows[j]!;
    this.cache.rearrange(sourceIdx);
    const completed = this.#finished.size >= this.maxCandidates;
    return { completed, sumLogprobs: MlxArray.fromFloat32(new Float32Array(nextSum), [B]) };
  }

  finalize(rows: number[][], sumLogprobs: MlxArray) {
    const prev = [...sumLogprobs.toFloat32()];
    // collect all finished sequences, including patience; add unfinished
    // ones if not enough
    const finished = [...this.#finished.values()];
    if (finished.length < this.beamSize) {
      const order = [...prev.keys()].sort((a, b) => prev[b]! - prev[a]!);
      for (const j of order) {
        finished.push({ tokens: [...rows[j]!, this.eot], logprob: prev[j]! });
        if (finished.length >= this.beamSize) break;
      }
    }
    return { tokens: finished.map((f) => f.tokens), sumLogprobs: finished.map((f) => f.logprob) };
  }
}
