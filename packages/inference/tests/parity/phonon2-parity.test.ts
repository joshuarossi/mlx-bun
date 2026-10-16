import { expect, test } from "bun:test";
import { join } from "node:path";
import { readFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { tdtWords } from "../../src/transcription/tdt/segments";
import { optInAll } from "./real-weight-inputs";

const inputs = optInAll(
  process.env,
  [
    "MLX_BUN_TEST_PHONON2_MODEL",
    "MLX_BUN_TEST_PHONON2_REFERENCE",
    "MLX_BUN_TEST_PHONON2_REFERENCE_SHA256",
    "MLX_BUN_TEST_PHONON2_AUDIO",
  ] as const,
  "Phonon-2 parity",
);
const hash = (data: Uint8Array) =>
  createHash("sha256").update(data).digest("hex");

test.skipIf(!inputs)(
  "Phonon-2 Metal graph matches pinned MLX tokens and bounded intermediate error",
  async () => {
    const env = inputs!,
      directory = env.MLX_BUN_TEST_PHONON2_REFERENCE;
    const manifestBytes = readFileSync(
      join(directory, "phonon2-reference.json"),
    );
    expect(hash(manifestBytes)).toBe(env.MLX_BUN_TEST_PHONON2_REFERENCE_SHA256);
    const reference = JSON.parse(manifestBytes.toString());
    expect(reference.versions.mlx).toBe("0.32.2");
    expect(reference.versions["mlx-audio"]).toBe("0.4.6");
    expect(reference.versions["fermion-research"]).toBe("0.2.11");
    expect(reference.container_sha256).toBe(
      "4b6bfa3a12cc3c4e0a54f2ab3ec4ca7a842b09e5c7ecfc8e7ca0ac6cc8c11468",
    );
    for (const row of reference.rows) {
      expect(
        hash(readFileSync(join(env.MLX_BUN_TEST_PHONON2_AUDIO, row.audio))),
      ).toBe(row.audio_sha256);
      for (const name of ["mel", "encoder"])
        expect(hash(readFileSync(join(directory, row[name].file)))).toBe(
          row[name].sha256,
        );
    }
    const [
      { Phonon2Weights },
      { Phonon2Model },
      { PhononMelExtractor },
      { TdtTranscriber },
      { decodeFileWithAudioToolbox },
    ] = await Promise.all([
      import("../../src/artifacts/phonon2"),
      import("../../src/models/phonon2/model"),
      import("../../src/input/audio/phonon-mel"),
      import("../../src/transcription/tdt/transcribe"),
      import("../../src/input/audio/audiotoolbox"),
    ]);
    const weights = await Phonon2Weights.open(env.MLX_BUN_TEST_PHONON2_MODEL),
      graph = new Phonon2Model(weights),
      melExtractor = new PhononMelExtractor(),
      transcriber = new TdtTranscriber(graph);
    try {
      for (const row of reference.rows) {
        const samples = decodeFileWithAudioToolbox(
          join(env.MLX_BUN_TEST_PHONON2_AUDIO, row.audio),
        );
        using mel = melExtractor.logMel(samples);
        using enc = graph.encode(mel);
        for (const [name, value] of [
          ["mel", mel],
          ["encoder", enc],
        ] as const) {
          const pin = row[name],
            bytes = readFileSync(join(directory, pin.file)),
            expected = new Float32Array(
              bytes.buffer,
              bytes.byteOffset,
              bytes.byteLength / 4,
            ),
            actual = value.toFloat32();
          expect(value.shape).toEqual(pin.shape);
          let error = 0,
            magnitude = 0,
            maxAbs = 0;
          for (let i = 0; i < actual.length; i++) {
            expect(Number.isFinite(actual[i])).toBe(true);
            maxAbs = Math.max(maxAbs, Math.abs(actual[i]! - expected[i]!));
            error += (actual[i]! - expected[i]!) ** 2;
            magnitude += expected[i]! ** 2;
          }
          // Metal's reductions and the fused gates may differ in their final bits.
          // Acceptance also requires exactly the reference's full greedy tokens.
          const relativeL2 = Math.sqrt(error / magnitude);
          console.log(
            JSON.stringify({
              audio: row.audio,
              tensor: name,
              relativeL2,
              maxAbs,
            }),
          );
          expect(relativeL2).toBeLessThan(0.02);
        }
        const result = await transcriber.transcribe(samples, {
          wordTimestamps: true,
        });
        expect(result.text).toBe(row.text);
        expect(result.segments.flatMap((s) => s.tokens)).toEqual(
          row.tokens.map((t: { id: number }) => t.id),
        );
        const expectedWords = tdtWords(
          row.tokens.map(
            (t: { id: number; start: number; duration: number }) => ({
              ...t,
              piece: graph.vocabulary[t.id]!,
            }),
          ),
          samples.length / 16000,
        );
        const actualWords = result.segments.flatMap((s) => s.words ?? []);
        expect(actualWords.map((w) => w.word)).toEqual(
          expectedWords.map((w) => w.word),
        );
        for (let i = 0; i < actualWords.length; i++) {
          expect(actualWords[i]!.start).toBeCloseTo(expectedWords[i]!.start, 5);
          expect(actualWords[i]!.end).toBeCloseTo(expectedWords[i]!.end, 5);
        }
        for (const segment of result.segments)
          for (const word of segment.words ?? []) {
            expect(word.start).toBeGreaterThanOrEqual(0);
            expect(word.end).toBeGreaterThanOrEqual(word.start);
            expect(word.end).toBeLessThanOrEqual(samples.length / 16000);
            expect(word.probability).toBeUndefined();
          }
      }
      expect(graph.decodeTraceCount).toBe(1);
      const sample = decodeFileWithAudioToolbox(
        join(env.MLX_BUN_TEST_PHONON2_AUDIO, reference.rows[0].audio),
      );
      const a = transcriber.start(),
        b = transcriber.start();
      await a.feed(sample.subarray(0, 10000));
      await b.feed(sample.subarray(0, 20000));
      await a.feed(sample.subarray(10000));
      await b.feed(sample.subarray(20000));
      expect((await a.finish()).text).toBe(reference.rows[0].text);
      expect((await b.finish()).text).toBe(reference.rows[0].text);
      const abort = new AbortController();
      setImmediate(() => abort.abort(new Error("cancel test")));
      await expect(
        transcriber.transcribe(sample, { signal: abort.signal }),
      ).rejects.toThrow("cancel test");
      expect((await transcriber.transcribe(sample)).text).toBe(
        reference.rows[0].text,
      );
    } finally {
      transcriber.dispose();
      melExtractor.dispose();
      graph.dispose();
    }
  },
  180_000,
);
