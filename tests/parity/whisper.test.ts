// Whisper L1 parity vs the mlx-whisper oracle (goldens/whisper.json +
// untracked blobs from scripts/oracle/gen-whisper-golden.py):
//   - mel spectrogram bit-exact (float32)
//   - decode-window encoder output bit-exact (float16 raw bytes)
//   - per-step PRE-filter logits bit-exact (float32) for the first window
//   - transcription text / segment tokens / timestamps identical; avg_logprob
//     and no_speech_prob within float tolerance
// Skips cleanly without the model snapshot, the tokenizer files, or the
// manifest; clips whose source files are absent (jfk lives in sotto's
// vendored whisper.cpp checkout) skip individually.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { decodeWav } from "../../src/audio/decode";
import { WHISPER_N_FRAMES, WHISPER_N_SAMPLES, padOrTrimFrames } from "../../src/audio/whisper-mel";
import { loadWhisperTokenizer, resolveWhisperTokenizerDir } from "../../src/audio/whisper-tokenizer";
import { WhisperTranscriber } from "../../src/audio/whisper-transcribe";
import type { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { openWhisperModel } from "../../src/model/factory";
import { goldenPath } from "../support/goldens";
import { SNAPSHOT_WHISPER } from "../support/paths";

const ROOT = `${import.meta.dir}/../..`;
const SOTTO_VENDOR = `${process.env.HOME}/Code/sotto`;
const manifestPath = goldenPath("whisper.json");
const manifest = existsSync(manifestPath) ? await Bun.file(manifestPath).json() : null;
const haveModel = existsSync(`${SNAPSHOT_WHISPER}/config.json`);
const haveTokenizer = haveModel && resolveWhisperTokenizerDir(SNAPSHOT_WHISPER, 51866) !== null;
const ready = !!manifest && haveModel && haveTokenizer;

type Recipe = ({ file: string } | { silence: number })[];

function buildClip(recipe: Recipe): Float32Array | null {
  const parts: Float32Array[] = [];
  for (const step of recipe) {
    if ("silence" in step) parts.push(new Float32Array(Math.floor(step.silence * 16_000)));
    else {
      const path = step.file.startsWith("fixtures/") ? `${ROOT}/${step.file}` : `${SOTTO_VENDOR}/${step.file}`;
      if (!existsSync(path)) return null;
      const bytes = new Uint8Array(require("node:fs").readFileSync(path));
      parts.push(decodeWav(bytes).samples);
    }
  }
  const total = parts.reduce((n, p) => n + p.length, 0);
  const out = new Float32Array(total);
  let o = 0;
  for (const p of parts) { out.set(p, o); o += p.length; }
  return out;
}

function blob(name: string): Uint8Array | null {
  const p = goldenPath(name);
  return existsSync(p) ? new Uint8Array(require("node:fs").readFileSync(p)) : null;
}

function f16Bytes(a: MlxArray): Uint8Array {
  const c = ops.contiguous(a);
  const b = c.rawBytes();
  c.dispose();
  return b;
}

function countMismatch(a: ArrayLike<number>, b: ArrayLike<number>): { count: number; maxAbs: number } {
  let count = 0;
  let maxAbs = 0;
  for (let i = 0; i < a.length; i++) {
    if (a[i] !== b[i]) { count++; maxAbs = Math.max(maxAbs, Math.abs(a[i]! - b[i]!)); }
  }
  return { count, maxAbs };
}

describe.skipIf(!ready)("whisper L1 parity vs mlx-whisper", async () => {
  const { model } = ready ? await openWhisperModel(SNAPSHOT_WHISPER) : { model: null as never };
  const tokenizer = ready ? await loadWhisperTokenizer(SNAPSHOT_WHISPER, model.dims.nVocab) : null!;
  const transcriber = ready ? new WhisperTranscriber(model, tokenizer) : null!;
  const clips = new Map<string, Float32Array>();
  if (ready) {
    for (const [name, clip] of Object.entries(manifest.clips as Record<string, { recipe: Recipe; num_samples: number }>)) {
      const s = buildClip(clip.recipe);
      if (s) {
        expect(s.length).toBe(clip.num_samples);
        clips.set(name, s);
      }
    }
  }

  test("manifest oracle pins", () => {
    expect(manifest.dims.n_vocab).toBe(model.dims.nVocab);
    expect(manifest.dims.n_audio_layer).toBe(model.dims.nAudioLayer);
  });

  for (const [name, clip] of Object.entries((manifest?.clips ?? {}) as Record<string, { mel_shape: number[] }>)) {
    const melBlob = blob(`whisper-${name}-mel.bin`);
    test.skipIf(!clips.has(name) || !melBlob)(`mel bit-exact: ${name}`, () => {
      const mel = transcriber.mel.logMel(clips.get(name)!, WHISPER_N_SAMPLES);
      expect(mel.shape).toEqual(clip.mel_shape);
      const ours = mel.toFloat32();
      mel.dispose();
      const ref = new Float32Array(melBlob!.buffer, melBlob!.byteOffset, melBlob!.byteLength / 4);
      expect(countMismatch(ours, ref)).toEqual({ count: 0, maxAbs: 0 });
    });
  }

  for (const c of (manifest?.cases ?? []) as {
    clip: string; name: string; options: Record<string, unknown>; language: string; text: string;
    segments: Record<string, unknown>[]; windows: number; window0_steps: number;
  }[]) {
    const tag = `${c.clip}-${c.name}`;
    const encBlob = blob(`whisper-${tag}-enc.bin`);
    const logitsBlob = blob(`whisper-${tag}-logits.bin`);
    test.skipIf(!clips.has(c.clip))(`transcribe parity: ${tag}`, async () => {
      const o = c.options;
      let encSeen: Uint8Array | null = null;
      const stepLogits: Float32Array[] = [];
      let windows = 0;
      const result = await transcriber.transcribe(clips.get(c.clip)!, {
        language: (o.language as string | null | undefined) ?? null,
        task: (o.task as "transcribe" | "translate") ?? "transcribe",
        temperature: 0,
        initialPrompt: (o.initial_prompt as string) ?? null,
        withoutTimestamps: (o.without_timestamps as boolean) ?? false,
        conditionOnPreviousText: (o.condition_on_previous_text as boolean) ?? true,
        fast: false, // the oracle-parity graph; the fast path has its own token-exact gate
        observer: {
          onAudioFeatures: (f) => { windows++; if (!encSeen) encSeen = f16Bytes(f); },
          onStepLogits: (_step, l) => { if (windows === 1) stepLogits.push(l.toFloat32()); },
        },
      });
      // Tensor gates first — they localize a divergence; text/segments after.
      if (encBlob) {
        expect(encSeen).not.toBeNull();
        const m = countMismatch(encSeen!, encBlob);
        expect(m).toEqual({ count: 0, maxAbs: 0 });
      }
      if (logitsBlob) {
        // The oracle's pipelined loop evaluates one extra decoder step after
        // every row hit EOT (its `completed` check trails by a step); ours
        // stops as soon as the rows complete. Compare the common prefix.
        expect([c.window0_steps, c.window0_steps - 1]).toContain(stepLogits.length);
        const V = model.dims.nVocab;
        const ref = new Float32Array(logitsBlob.buffer, logitsBlob.byteOffset, logitsBlob.byteLength / 4);
        for (let s = 0; s < stepLogits.length; s++) {
          const m = countMismatch(stepLogits[s]!, ref.subarray(s * V, (s + 1) * V));
          if (m.count) throw new Error(`step ${s}: ${m.count} logit mismatches, max |Δ| ${m.maxAbs}`);
        }
      }
      expect(result.language).toBe(c.language);
      expect(result.text).toBe(c.text);
      expect(result.segments.length).toBe(c.segments.length);
      for (let i = 0; i < c.segments.length; i++) {
        const ours = result.segments[i]!;
        const ref = c.segments[i]!;
        expect(ours.tokens).toEqual(ref.tokens as number[]);
        expect(ours.start).toBeCloseTo(ref.start as number, 6);
        expect(ours.end).toBeCloseTo(ref.end as number, 6);
        expect(ours.seek).toBe(ref.seek as number);
        expect(ours.text).toBe(ref.text as string);
        // avg_logprob sums log-softmax over the FILTERED logits; our
        // timestamp filter follows openai-whisper's monotonic rule (which
        // mlx-whisper's port never applies — see whisper-decode.ts), so the
        // normalizer differs by ~1e-4 when a timestamp was already emitted.
        // Tokens are identical; the value only has to agree to 2 decimals.
        expect(ours.avgLogprob).toBeCloseTo(ref.avg_logprob as number, 2);
        expect(ours.noSpeechProb).toBeCloseTo(ref.no_speech_prob as number, 6);
        // compression_ratio = len(text) / len(zlib.compress(text)). Bun's
        // bundled zlib and CPython's zlib 1.2.12 pick different matches for
        // the same level-6 stream (51 vs 52 bytes for the fox sentence), so
        // the ratio is implementation-defined; the 2.4 fallback threshold
        // decision must agree, the value only within 5 %.
        const refCr = ref.compression_ratio as number;
        expect(Math.abs(ours.compressionRatio - refCr) / refCr).toBeLessThan(0.05);
        expect(ours.compressionRatio > 2.4).toBe(refCr > 2.4);
      }
    });
  }

  test("30 s window pad/trim shape", () => {
    const mel = transcriber.mel.logMel(clips.get("fox")!, 0);
    const p = padOrTrimFrames(mel, WHISPER_N_FRAMES, model.dtype);
    expect(p.shape).toEqual([WHISPER_N_FRAMES, model.dims.nMels]);
    p.dispose();
    mel.dispose();
  });
});
