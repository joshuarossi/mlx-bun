// The Silero VAD graph against two external references, with real weights
// (ggml-org/whisper-vad's ggml-silero-v6.2.0.bin):
//   - silero-vad 6.2.1, the torch reference (main 02d723a:scripts/oracle/
//     gen-silero-golden.py, unchanged): per-chunk probabilities within 5e-3 (the
//     ggml weights are fp16) and identical speech segments under sotto's
//     parameters and the defaults. Its noise clip comes from numpy's generator,
//     which is not reproduced here, so that clip is not compared;
//   - pre-refactor main's own VAD (scripts/main-speech-reference.ts run in a main
//     checkout): probabilities, streamed probabilities and segments identical.
// The model, audio and references stay outside this repository; this test never
// starts Python or main. Opt in with all of
//   MLX_BUN_TEST_VAD_MODEL=/path/ggml-silero-v6.2.0.bin
//   MLX_BUN_TEST_VAD_AUDIO=/dir (speech-fox.wav, chirp-1s6.wav, jfk.wav)
//   MLX_BUN_TEST_VAD_REFERENCE=/dir (silero-vad.json and main-vad.json)
//   MLX_BUN_TEST_VAD_REFERENCE_SHA256=<silero-vad.json SHA-256>
//   MLX_BUN_TEST_VAD_MAIN_SHA256=<main-vad.json SHA-256>
// None set skips; any other combination fails. References and the model file are
// verified against their pins before native libraries load.
import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { strict as assert } from "node:assert";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { fileSha256, optInAll } from "./real-weight-inputs";
import { countMismatch, readPinnedJson } from "./speech-inputs";

const OPT_IN = ["MLX_BUN_TEST_VAD_MODEL", "MLX_BUN_TEST_VAD_AUDIO", "MLX_BUN_TEST_VAD_REFERENCE",
  "MLX_BUN_TEST_VAD_REFERENCE_SHA256", "MLX_BUN_TEST_VAD_MAIN_SHA256"] as const;
const opted = optInAll(process.env, OPT_IN, "Silero VAD parity");

interface Segment { start: number; end: number }
interface Oracle {
  oracle: { silero_vad: string; torch: string };
  clips: Record<string, { num_samples: number; probs: number[]; segments: Segment[]; segments_default: Segment[] }>;
}
interface Main {
  mainRevision: string; modelSha256: string;
  clips: Record<string, { numSamples: number; probs: number[]; streamedProbs: number[]; segments: Segment[]; segmentsDefault: Segment[] }>;
}
const reference = opted?.MLX_BUN_TEST_VAD_REFERENCE;
const oracle = opted ? readPinnedJson<Oracle>(join(reference!, "silero-vad.json"), opted.MLX_BUN_TEST_VAD_REFERENCE_SHA256, "oracle manifest") : null;
const main = opted ? readPinnedJson<Main>(join(reference!, "main-vad.json"), opted.MLX_BUN_TEST_VAD_MAIN_SHA256, "main reference") : null;

describe.skipIf(!opted)("silero vad vs silero-vad 6.2.1 and main", () => {
  let SileroVad: typeof import("@mlx-bun/inference/models/audio/silero-vad").SileroVad;
  let vad: import("@mlx-bun/inference/models/audio/silero-vad").SileroVad;
  const clips = new Map<string, Float32Array>();

  beforeAll(async () => {
    assert.equal(await fileSha256(opted!.MLX_BUN_TEST_VAD_MODEL), main!.modelSha256, "the VAD model differs from main's reference");
    const [{ decodeWav }, silero] = await Promise.all([import("@mlx-bun/inference/input/audio"), import("@mlx-bun/inference/models/audio/silero-vad")]);
    SileroVad = silero.SileroVad;
    const wav = (name: string) => decodeWav(new Uint8Array(readFileSync(join(opted!.MLX_BUN_TEST_VAD_AUDIO, name)))).samples;
    clips.set("fox", wav("speech-fox.wav"));
    clips.set("chirp", wav("chirp-1s6.wav"));
    clips.set("jfk", wav("jfk.wav"));
    clips.set("silence", new Float32Array(32_000));
    vad = SileroVad.load(opted!.MLX_BUN_TEST_VAD_MODEL);
  });
  afterAll(() => vad?.dispose());

  for (const name of ["fox", "chirp", "silence", "jfk"]) {
    test(`probabilities and segments: ${name}`, () => {
      const samples = clips.get(name)!;
      const probs = vad.probs(samples);
      const theirs = main!.clips[name]!, torch = oracle!.clips[name]!;
      expect(samples.length).toBe(theirs.numSamples);
      expect(samples.length).toBe(torch.num_samples);

      // Main: identical, one-shot and streamed in 100 ms pieces.
      expect(countMismatch(probs, theirs.probs)).toEqual({ count: 0, maxAbs: 0 });
      const state = SileroVad.streamState(), streamed: number[] = [];
      for (let at = 0; at < samples.length; at += 1_600) streamed.push(...vad.probsStreaming(samples.subarray(at, Math.min(samples.length, at + 1_600)), state));
      expect(countMismatch(streamed, theirs.streamedProbs)).toEqual({ count: 0, maxAbs: 0 });
      expect(SileroVad.speechTimestamps(probs, samples.length, { threshold: 0.5, minSpeechDurationMs: 120 })).toEqual(theirs.segments);
      expect(SileroVad.speechTimestamps(probs, samples.length)).toEqual(theirs.segmentsDefault);

      // The torch reference: probabilities to fp16 weight precision, segments exactly.
      expect(probs.length).toBe(torch.probs.length);
      let maxAbs = 0;
      for (let i = 0; i < probs.length; i++) maxAbs = Math.max(maxAbs, Math.abs(probs[i]! - torch.probs[i]!));
      console.log(`[silero-vad] ${name}: ${probs.length} chunks, max |p - torch| ${maxAbs.toExponential(3)}`);
      expect(maxAbs).toBeLessThan(5e-3);
      expect(SileroVad.speechTimestamps(probs, samples.length, { threshold: 0.5, minSpeechDurationMs: 120 })).toEqual(torch.segments);
      expect(SileroVad.speechTimestamps(probs, samples.length)).toEqual(torch.segments_default);
    });
  }
});
