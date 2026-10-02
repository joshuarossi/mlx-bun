// Whisper large-v3-turbo against two external references, with real weights:
//   - the mlx-whisper oracle (main 02d723a:scripts/oracle/gen-whisper-golden.py,
//     unchanged): mel and window-0 encoder output bit for bit, window-0
//     per-step logits bit for bit on the faithful graph, and identical
//     transcripts, segment tokens, timestamps and seeks;
//   - pre-refactor main's own Whisper (scripts/main-speech-reference.ts run in a
//     main checkout): whole results, encoder-output hashes, beam search, word
//     timestamps and a fed-in-chunks run, identical for the faithful and the fast
//     path. The fast path is also held to the oracle within two tokens per clip.
// The model, tokenizer, audio and references stay outside this repository; this
// test never starts Python or main. Opt in with all of
//   MLX_BUN_TEST_WHISPER_MODEL=/mlx-community/whisper-large-v3-turbo/snapshot
//   MLX_BUN_TEST_WHISPER_AUDIO=/dir (speech-fox.wav, jfk.wav)
//   MLX_BUN_TEST_WHISPER_REFERENCE=/dir (whisper.json, its blobs and main-whisper.json)
//   MLX_BUN_TEST_WHISPER_REFERENCE_SHA256=<whisper.json SHA-256>
//   MLX_BUN_TEST_WHISPER_MAIN_SHA256=<main-whisper.json SHA-256>
// None set skips; any other combination fails. The openai/whisper-large-v3-turbo
// tokenizer files must be in the Hugging Face cache. Manifests, blobs and the
// weights are verified against their pins before native libraries load.
import { afterAll, beforeAll, describe, expect, setDefaultTimeout, test } from "bun:test";
import { strict as assert } from "node:assert";
import { join } from "node:path";
import { fileSha256, optInAll } from "./real-weight-inputs";
import { buildClip, countMismatch, float32Of, readBlob, readPinnedJson, tokenDiff, type Recipe } from "./speech-inputs";

const OPT_IN = ["MLX_BUN_TEST_WHISPER_MODEL", "MLX_BUN_TEST_WHISPER_AUDIO", "MLX_BUN_TEST_WHISPER_REFERENCE",
  "MLX_BUN_TEST_WHISPER_REFERENCE_SHA256", "MLX_BUN_TEST_WHISPER_MAIN_SHA256"] as const;
const opted = optInAll(process.env, OPT_IN, "Whisper parity");

interface Segment { tokens: number[]; start: number; end: number; seek: number; text: string;
  avgLogprob: number; noSpeechProb: number; compressionRatio: number }
interface Result { language: string; text: string; segments: Segment[] }
interface OracleSegment { tokens: number[]; start: number; end: number; seek: number; text: string;
  avg_logprob: number; no_speech_prob: number; compression_ratio: number }
interface Oracle {
  dims: Record<string, number>;
  oracle: { mlx: string; mlx_whisper: string; weights_sha256: string };
  clips: Record<string, { recipe: Recipe; num_samples: number; mel_shape: number[] }>;
  cases: { clip: string; name: string; language: string; text: string; segments: OracleSegment[]; window0_steps: number }[];
  blobs: Record<string, { sha256: string }>;
}
interface MainRun { label: string; clip: string; options: Record<string, unknown>; encoderSha256: string | null; result: Result }
interface Main {
  mainRevision: string; weightsSha256: string; runs: MainRun[];
  streaming: { clip: string; chunkSamples: number; fed: unknown[]; finished: Result };
}

const reference = opted?.MLX_BUN_TEST_WHISPER_REFERENCE;
const oracle = opted ? readPinnedJson<Oracle>(join(reference!, "whisper.json"), opted.MLX_BUN_TEST_WHISPER_REFERENCE_SHA256, "oracle manifest") : null;
const main = opted ? readPinnedJson<Main>(join(reference!, "main-whisper.json"), opted.MLX_BUN_TEST_WHISPER_MAIN_SHA256, "main reference") : null;
const plain = (value: unknown) => JSON.parse(JSON.stringify(value)) as Result;
const tokens = (segments: { tokens: number[] }[]) => segments.flatMap(s => s.tokens);

describe.skipIf(!opted)("whisper-large-v3-turbo vs the mlx-whisper oracle and main", () => {
  setDefaultTimeout(900_000);
  let transcriber: import("@mlx-bun/inference/transcription").WhisperTranscriber;
  let model: import("@mlx-bun/inference/models/whisper").WhisperModel;
  let f16Bytes: (a: import("@mlx-bun/mlx/array").MlxArray) => Uint8Array;
  let logMelSamples: number;
  const clips = new Map<string, Float32Array>();
  const results = new Map<string, Result>();

  beforeAll(async () => {
    const weights = join(opted!.MLX_BUN_TEST_WHISPER_MODEL, "weights.safetensors");
    const digest = await fileSha256(weights);
    assert(digest.startsWith(oracle!.oracle.weights_sha256), "weights differ from the oracle's");
    assert.equal(digest, main!.weightsSha256, "weights differ from main's reference");
    const [{ decodeWav, loadWhisperTokenizer, WHISPER_N_SAMPLES }, { WhisperTranscriber }, { openWhisperModel }, { ops }] = await Promise.all([
      import("@mlx-bun/inference/input/audio"), import("@mlx-bun/inference/transcription"),
      import("@mlx-bun/inference/models"), import("@mlx-bun/mlx"),
    ]);
    logMelSamples = WHISPER_N_SAMPLES;
    for (const [name, clip] of Object.entries(oracle!.clips)) {
      const samples = buildClip(opted!.MLX_BUN_TEST_WHISPER_AUDIO, clip.recipe, decodeWav);
      assert.equal(samples.length, clip.num_samples, `${name}: sample count differs from the oracle's`);
      clips.set(name, samples);
    }
    ({ model } = await openWhisperModel(opted!.MLX_BUN_TEST_WHISPER_MODEL));
    assert.equal(model.dims.nVocab, oracle!.dims.n_vocab);
    transcriber = new WhisperTranscriber(model, await loadWhisperTokenizer(opted!.MLX_BUN_TEST_WHISPER_MODEL, model.dims.nVocab));
    f16Bytes = a => { using c = ops.contiguous(a); return c.rawBytes(); };
  });
  afterAll(() => { transcriber?.dispose(); model?.dispose(); });

  test("every oracle case has a faithful and a fast main run", () => {
    for (const c of oracle!.cases)
      for (const mode of ["faithful", "fast"]) expect(main!.runs.some(r => r.label === `${c.clip}-${c.name}-${mode}`)).toBe(true);
    for (const clip of ["fox", "jfk", "long"]) expect(main!.runs.some(r => r.label === `${clip}-beam5-fast`)).toBe(true);
  });

  for (const clip of Object.keys(oracle?.clips ?? {})) {
    test(`mel is bit-exact with the oracle: ${clip}`, () => {
      const info = oracle!.clips[clip]!;
      const mel = transcriber.mel.logMel(clips.get(clip)!, logMelSamples);
      const ours = mel.toFloat32(), shape = mel.shape;
      mel.dispose();
      expect(shape).toEqual(info.mel_shape);
      const ref = float32Of(readBlob(reference!, `whisper-${clip}-mel.bin`, oracle!.blobs[`whisper-${clip}-mel.bin`]?.sha256));
      expect(countMismatch(ours, ref)).toEqual({ count: 0, maxAbs: 0 });
    });
  }

  for (const run of main?.runs ?? []) {
    const c = oracle!.cases.find(o => `${o.clip}-${o.name}-faithful` === run.label);
    test(`${run.label}: identical to main${c ? " and the oracle" : ""}`, async () => {
      const tag = c ? `${c.clip}-${c.name}` : "";
      let encoder: Uint8Array | null = null, windows = 0;
      const steps: Float32Array[] = [];
      // Step logits are observed only where the oracle recorded them; that forces the faithful graph, as here.
      const result = await transcriber.transcribe(clips.get(run.clip)!, {
        ...run.options,
        observer: {
          onAudioFeatures: f => { windows++; encoder ??= f16Bytes(f); },
          ...(c ? { onStepLogits: (_step: number, l: import("@mlx-bun/mlx/array").MlxArray) => { if (windows === 1) steps.push(l.toFloat32()); } } : {}),
        },
      });
      results.set(run.label, plain(result));
      expect(encoder).not.toBeNull();
      // Main first: same code and options, so any difference is a regression in this tree.
      expect(new Bun.CryptoHasher("sha256").update(encoder!).digest("hex")).toBe(run.encoderSha256 as string);
      expect(plain(result)).toEqual(run.result);
      if (!c) return;

      // The oracle: tensors first, since they localize a divergence.
      const encName = `whisper-${tag}-enc.bin`, logitsName = `whisper-${tag}-logits.bin`;
      expect(countMismatch(encoder!, readBlob(reference!, encName, oracle!.blobs[encName]?.sha256))).toEqual({ count: 0, maxAbs: 0 });
      // The oracle's pipelined loop decodes one extra step after every row reaches EOT; ours stops first.
      expect([c.window0_steps, c.window0_steps - 1]).toContain(steps.length);
      const V = model.dims.nVocab, ref = float32Of(readBlob(reference!, logitsName, oracle!.blobs[logitsName]?.sha256));
      for (let s = 0; s < steps.length; s++) {
        const m = countMismatch(steps[s]!, ref.subarray(s * V, (s + 1) * V));
        if (m.count) throw new Error(`step ${s}: ${m.count} logit mismatches, max |d| ${m.maxAbs}`);
      }
      expect(result.language).toBe(c.language);
      expect(result.text).toBe(c.text);
      expect(result.segments.length).toBe(c.segments.length);
      c.segments.forEach((ref, i) => {
        const ours = result.segments[i]!;
        expect(ours.tokens).toEqual(ref.tokens);
        expect(ours.start).toBeCloseTo(ref.start, 6);
        expect(ours.end).toBeCloseTo(ref.end, 6);
        expect(ours.seek).toBe(ref.seek);
        expect(ours.text).toBe(ref.text);
        // avg_logprob sums log-softmax over the filtered logits; the timestamp filter follows
        // openai-whisper's monotonic rule, which mlx-whisper never applies, so the normalizer
        // differs by about 1e-4 after a timestamp. Tokens match; the value only to two decimals.
        expect(ours.avgLogprob).toBeCloseTo(ref.avg_logprob, 2);
        expect(ours.noSpeechProb).toBeCloseTo(ref.no_speech_prob, 6);
        // CPython's zlib and Bun's pick different level-6 matches, so the ratio is only within 5 %;
        // the 2.4 fallback decision must agree.
        expect(Math.abs(ours.compressionRatio - ref.compression_ratio) / ref.compression_ratio).toBeLessThan(0.05);
        expect(ours.compressionRatio > 2.4).toBe(ref.compression_ratio > 2.4);
      });
    });
  }

  // Different attention kernels can flip a near-tie; the fast path is held to at most two
  // differing tokens per clip against the oracle (recorded at main 02d723a) and against the
  // faithful graph.
  for (const c of oracle?.cases ?? []) {
    test(`fast path is within two tokens of the oracle: ${c.clip}-${c.name}`, () => {
      const fast = results.get(`${c.clip}-${c.name}-fast`);
      assert(fast, "the fast run did not complete");
      const diff = tokenDiff(tokens(fast.segments), tokens(c.segments));
      console.log(`[whisper] fast vs oracle ${c.clip}-${c.name}: ${diff} token differences`);
      if (diff > 2) throw new Error(`${diff} token differences\n ours: ${fast.text}\n ref:  ${c.text}`);
      expect(fast.segments.length).toBe(c.segments.length);
      expect(fast.segments.map(s => s.start)).toEqual(c.segments.map(s => s.start));
    });
  }
  for (const clip of ["fox", "jfk", "long"]) {
    test(`beam-5 fast path is within two tokens of the faithful graph: ${clip}`, () => {
      const fast = results.get(`${clip}-beam5-fast`), faithful = results.get(`${clip}-beam5-faithful`);
      assert(fast && faithful, "beam runs did not complete");
      const diff = tokenDiff(tokens(fast.segments), tokens(faithful.segments));
      console.log(`[whisper] beam-5 fast vs faithful ${clip}: ${diff} token differences`);
      if (diff > 2) throw new Error(`${diff} token differences\n fast:     ${fast.text}\n faithful: ${faithful.text}`);
    });
  }

  test("a run fed one second at a time matches main", async () => {
    const { clip, chunkSamples } = main!.streaming;
    const samples = clips.get(clip)!;
    const run = transcriber.start({ language: "en", temperature: 0 });
    const fed: unknown[] = [];
    for (let at = 0; at < samples.length; at += chunkSamples) fed.push(plain(await run.feed(samples.subarray(at, Math.min(samples.length, at + chunkSamples)))));
    expect(fed).toEqual(main!.streaming.fed);
    expect(plain(await run.finish())).toEqual(main!.streaming.finished);
  });
});
