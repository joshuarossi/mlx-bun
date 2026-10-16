// Real speech through the public server, using the same pinned captures as
// inference/tests/parity/phonon2-parity.test.ts. Run through gpu.sh.
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";
const names = [
  "MLX_BUN_TEST_PHONON2_MODEL",
  "MLX_BUN_TEST_PHONON2_REFERENCE",
  "MLX_BUN_TEST_PHONON2_REFERENCE_SHA256",
  "MLX_BUN_TEST_PHONON2_AUDIO",
] as const;
const native = process.env.MLX_BUN_TEST_NATIVE === "1",
  set = names.filter((n) => process.env[n]?.trim());
if (native && set.length && set.length !== names.length)
  throw new Error(`Phonon-2 HTTP parity needs ${names.join(", ")}`);

test.skipIf(!native || set.length !== names.length)(
  "Phonon-2 serves pinned speech, sessions, unsupported options and unload",
  async () => {
    const [modelDir, referenceDir, referenceSha, audioDir] = names.map(
      (n) => process.env[n]!,
    ) as [string, string, string, string];
    const bytes = readFileSync(join(referenceDir, "phonon2-reference.json"));
    expect(createHash("sha256").update(bytes).digest("hex")).toBe(referenceSha);
    const reference = JSON.parse(bytes.toString());
    const [
      { startTranscriptionServer, parseServeOptions },
      { scanSnapshot },
      { decodeFileWithAudioToolbox },
    ] = await Promise.all([
      import("../../src/cli/serve"),
      import("@mlx-bun/hub/registry"),
      import("@mlx-bun/inference/input/audio"),
    ]);
    const record = await scanSnapshot(modelDir, "test-phonon2");
    if (!record) throw new Error("Phonon-2 path has no loadable checkpoint");
    let app: RunningApp | undefined;
    try {
      app = await startTranscriptionServer(
        record,
        parseServeOptions({
          values: { port: "0", "no-open": true, "whisper-idle-unload": "300" },
          positionals: [],
        }),
      );
      const base = `http://127.0.0.1:${app.port}`;
      const post = (
        path: string,
        fields: Record<string, unknown>,
        audio = reference.rows[0].audio,
      ) => {
        const form = new FormData(),
          clip = readFileSync(join(audioDir, audio));
        form.set("file", new Blob([clip], { type: "audio/flac" }), audio);
        for (const [key, value] of Object.entries(fields))
          form.set(
            key,
            typeof value === "string" ? value : JSON.stringify(value),
          );
        return fetch(`${base}${path}`, { method: "POST", body: form });
      };
      for (const row of reference.rows) {
        const clip = readFileSync(join(audioDir, row.audio));
        expect(createHash("sha256").update(clip).digest("hex")).toBe(
          row.audio_sha256,
        );
        const res = await post(
          "/v1/audio/transcriptions",
          {
            response_format: "verbose_json",
            "timestamp_granularities[]": "word",
          },
          row.audio,
        );
        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body.text).toBe(row.text);
        expect(
          body.segments.flatMap((s: { tokens: number[] }) => s.tokens),
        ).toEqual(row.tokens.map((t: { id: number }) => t.id));
        expect(body.segments[0].avg_logprob).toBeUndefined();
        expect(body.words.length).toBeGreaterThan(0);
        expect(body.words[0].probability).toBeUndefined();
      }
      for (const fields of [
        { prompt: "hello" },
        { language: "fr" },
        { temperature: "0.5" },
        { beam_size: "2" },
        { audio_ctx: "128" },
        { no_speech_threshold: "0.6" },
        { vocabulary: ["hello"] },
      ])
        expect((await post("/v1/audio/transcriptions", fields)).status).toBe(
          400,
        );
      expect((await post("/v1/audio/translations", {})).status).toBe(400);
      const sse = await post("/v1/audio/transcriptions", {
        stream: "true",
        prompt: "hello",
      });
      expect(await sse.text()).toContain("event: error");
      const created = await fetch(`${base}/v1/audio/sessions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: "{}",
      });
      expect(created.status).toBe(200);
      const session = await created.json(),
        wave = decodeFileWithAudioToolbox(
          join(audioDir, reference.rows[0].audio),
        );
      for (const part of [wave.subarray(0, 10000), wave.subarray(10000)]) {
        const res = await fetch(
          `${base}/v1/audio/sessions/${session.id}/audio`,
          {
            method: "POST",
            headers: { "content-type": "audio/pcm;rate=16000" },
            body: new Float32Array(part).buffer,
          },
        );
        expect(res.status).toBe(200);
      }
      const finished = await fetch(
        `${base}/v1/audio/sessions/${session.id}/finish`,
        { method: "POST" },
      );
      expect(finished.status).toBe(200);
      expect((await finished.json()).text).toBe(reference.rows[0].text);
      const unloaded = await fetch(`${base}/admin/transcription/unload`, {
        method: "POST",
      });
      expect(await unloaded.json()).toMatchObject({
        unloaded: true,
        resident: false,
        loads: 1,
      });
    } finally {
      await app?.close();
    }
  },
  180_000,
);
