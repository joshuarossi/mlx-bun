// GATED integration: audio input end to end through the HTTP server (T3 of
// docs/design/generic-model-support.md §3.4). Ephemeral in-process server (dies
// with the test), real /v1/chat/completions requests carrying base64 audio.
//
//   MLX_BUN_TEST_AUDIO_SERVE=1 bun test tests/e4b-audio-serve.test.ts
//
// The NUMERICS are gated offline (tests/e4b-audio.test.ts: full greedy stream
// oracle-EXACT). This gates the WIRING: content-part detection → extractAudio
// → ensureWav (CoreAudio transcode for non-WAV) → buildMultimodalPrompt →
// embeddings prefill followed by shared decode — and the failure surfaces (explicit
// 400s, never a silent text-only degrade). Default server config = bf16 KV +
// batch lane live (batch defaults > 1), so the transcription must match the
// offline golden exactly AND the routing assertion is non-vacuous:
// text and audio requests both enter the shared executor.

import { afterAll, describe, expect, spyOn, test } from "bun:test";
import type { Gemma4Model } from "../../src/model/gemma4";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { encode } from "fast-png";
import { unlink } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { goldenAt } from "../support/goldens";
import { SNAPSHOT_E4B } from "../support/paths";

interface AudioFixture { wav: string; text: string; decoded: string }
interface AudioGolden { fixtures: Record<string, AudioFixture> }

const optIn = process.env.MLX_BUN_TEST_AUDIO_SERVE === "1";
// Select an existing complete sidecar snapshot when a machine also holds a
// text-only copy of the same repository revision.
const modelPath = process.env.MLX_BUN_TEST_AUDIO_MODEL ?? SNAPSHOT_E4B;
const haveWeights =
  existsSync(`${modelPath}/config.json`) &&
  existsSync(`${modelPath}/optiq_vision.safetensors`);
const goldenFile = goldenAt("e4b-audio.json");
const golden = (await goldenFile.exists())
  ? ((await goldenFile.json()) as AudioGolden)
  : null;
const speech = golden?.fixtures.speech ?? null;
const haveFixture = speech !== null && existsSync(speech.wav);

/** Golden `decoded` keeps the oracle's trailing turn marker (a special the
 *  server's stop-on-EOS path never emits) — strip it for the HTTP bar. */
const expectedText = (speech?.decoded ?? "").replace(/<[^<>]*>$/, "").trim();

describe.skipIf(!optIn || !haveWeights || !haveFixture)(
  "e4b audio serving (T3)",
  async () => {
    if (!optIn || !haveWeights || !haveFixture || !speech) return;

    const { createServer, loadContext } = await import("../../src/server");
    const ctx = await loadContext(modelPath, "gemma-4-e4b-it-optiq");
    const model = ctx.model as Gemma4Model, batches: number[] = [];
    const forward = model.forwardHidden.bind(model);
    const probe = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
      batches.push(ids.shape[0]!); return forward(ids, caches);
    });
    const server = createServer(ctx, 0); // defaults: bf16 KV, batch lane live
    const base = `http://localhost:${server.port}`;
    afterAll(() => { server.stop(true); probe.mockRestore(); });

    const speechB64 = Buffer.from(
      await Bun.file(speech.wav).arrayBuffer(),
    ).toString("base64");

    const chat = (body: Record<string, unknown>) =>
      fetch(`${base}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(body),
      });
    // Document order mirrors the golden generator: audio part FIRST, then
    // the instruction text (tests/e4b-audio.test.ts uses the same shape).
    const audioReq = (data: string, format: string, text = speech.text) => ({
      messages: [{
        role: "user",
        content: [
          { type: "input_audio", input_audio: { data, format } },
          { type: "text", text },
        ],
      }],
      max_tokens: 32,
      temperature: 0,
    });
    const submittedRows = async () =>
      ((await (await fetch(`${base}/stats`)).json()) as any).batch
        .submitted_rows as number;

    test("input_audio WAV → exact golden transcription over HTTP", async () => {
      const before = await submittedRows();
      const res = await chat(audioReq(speechB64, "wav"));
      expect(res.status).toBe(200);
      const body = (await res.json()) as any;
      expect(body.choices[0].message.content.trim()).toBe(expectedText);
      expect(body.usage.prompt_tokens).toBeGreaterThan(0);
      expect(body.usage.lane).toBe("batched");
      expect(await submittedRows()).toBe(before + 1);
      // ...and the batch lane IS live on this server (non-vacuous check):
      // a plain text request advances it.
      const textRes = await chat({
        messages: [{ role: "user", content: "Say ping." }],
        max_tokens: 4, temperature: 0,
      });
      expect(textRes.status).toBe(200);
      expect(await submittedRows()).toBe(before + 2);
    }, 600_000);

    test("two prepared audio requests share actual B2 decode", async () => {
      const before = await submittedRows(); batches.length = 0;
      const responses = await Promise.all([chat(audioReq(speechB64, "wav")), chat(audioReq(speechB64, "wav"))]);
      for (const response of responses) {
        expect(response.status).toBe(200);
        const body = await response.json() as any;
        expect(body.usage.lane).toBe("batched");
        expect(body.choices[0].message.content).toMatch(/quick brown fox/i);
      }
      expect(await submittedRows()).toBe(before + 2);
      expect(batches).toContain(2);
    }, 600_000);

    test("a stalled audio download leaves text decode available", async () => {
      const { configureRuntime } = await import("../../src/runtime-config");
      const restore = configureRuntime({ MLX_BUN_ALLOW_PRIVATE_MEDIA: "1" });
      const arrived = Promise.withResolvers<void>(), release = Promise.withResolvers<void>();
      const media = Bun.serve({ port: 0, hostname: "127.0.0.1", async fetch() {
        arrived.resolve(); await release.promise;
        return new Response(Bun.file(speech.wav), { headers: { "content-type": "audio/wav" } });
      } });
      const pending = chat({ messages: [{ role: "user", content: [
        { type: "audio_url", audio_url: { url: `http://127.0.0.1:${media.port}/speech.wav` } },
        { type: "text", text: speech.text },
      ] }], temperature: 0, max_tokens: 32 });
      try {
        await arrived.promise;
        const text = await fetch(`${base}/v1/chat/completions`, {
          method: "POST", headers: { "content-type": "application/json" },
          body: JSON.stringify({ messages: [{ role: "user", content: "Say ping." }],
            temperature: 0, max_tokens: 4 }), signal: AbortSignal.timeout(5000),
        });
        expect(text.status).toBe(200);
        expect((await text.json() as any).usage.lane).toBe("batched");
      } finally {
        release.resolve();
        try {
          const response = await pending;
          expect(response.status).toBe(200);
          expect((await response.json() as any).choices[0].message.content.trim()).toBe(expectedText);
        } finally { media.stop(true); restore(); }
      }
    }, 30_000);

    for (const storage of ["ram", "ssd"] as const) test(`mixed image/audio reuse through ${storage} preserves output and logprobs`, async () => {
      const { getAudioTower, getVisionTower } = await import("../../src/serve/model-host");
      const audioTower = getAudioTower(ctx)!, visionTower = getVisionTower(ctx)!;
      const audioProbe = spyOn(audioTower, "features"), imageProbe = spyOn(visionTower, "features");
      const dir = mkdtempSync(join(tmpdir(), "mlx-bun-gemma-encoder-"));
      const options = storage === "ssd"
        ? { promptCacheBytes: 16, ssdCacheDir: dir, ssdCacheVerify: true }
        : { promptCacheBytes: 32 * 2 ** 20 };
      let fresh = createServer(ctx, 0, options);
      const data = Uint8Array.from({ length: 64 * 64 * 3 }, (_, i) => i % 3 === 1 ? 255 : 0);
      const png = Buffer.from(encode({ width: 64, height: 64, channels: 3, data })).toString("base64");
      const request = { messages: [{ role: "user", content: [
        { type: "image_url", image_url: { url: `data:image/png;base64,${png}` } },
        { type: "input_audio", input_audio: { data: speechB64, format: "wav" } },
        { type: "text", text: "Transcribe the audio, then name the image color." },
      ] }], temperature: 0, seed: 42, max_tokens: 16, logprobs: true, top_logprobs: 2 };
      const submit = async () => {
        const response = await fetch(`http://127.0.0.1:${fresh.port}/v1/chat/completions`, {
          method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(request),
        });
        expect(response.status).toBe(200); return await response.json() as any;
      };
      const flush = async () => {
        const result = await (await fetch(`http://127.0.0.1:${fresh.port}/admin/cache/flush`, { method: "POST" })).json() as any;
        expect(result.durable).toBe(true);
      };
      try {
        const first = await submit();
        expect(first.choices[0].logprobs.content.length).toBeGreaterThan(0);
        if (storage === "ssd") {
          await flush();
          const stats = await (await fetch(`http://127.0.0.1:${fresh.port}/stats`)).json() as any;
          expect(stats.prompt_cache.bytes).toBe(0);
          expect(stats.ssd_cache.entries).toBe(2);
          fresh.stop(true); fresh = createServer(ctx, 0, options);
        }
        const second = await submit();
        expect(second.choices).toEqual(first.choices);
        expect(second.usage).toEqual(first.usage);
        expect(audioProbe).toHaveBeenCalledTimes(1);
        expect(imageProbe).toHaveBeenCalledTimes(1);
        const stats = await (await fetch(`http://127.0.0.1:${fresh.port}/stats`)).json() as any;
        expect(storage === "ssd" ? stats.prompt_cache.object_restores : stats.prompt_cache.object_hits).toBe(2);
        if (storage === "ssd") await flush();
      } finally {
        fresh.stop(true); audioProbe.mockRestore(); imageProbe.mockRestore();
        rmSync(dir, { recursive: true, force: true });
      }
    }, 120_000);

    test("m4a (AAC) transcodes via CoreAudio and still transcribes", async () => {
      // Build the m4a at test time from the tracked WAV fixture (afconvert is
      // darwin-builtin; lossy AAC, so the bar is the transcript's content,
      // not bit-exactness with the WAV golden).
      const m4aPath = join(tmpdir(), `mlx-bun-audio-serve-test-${Date.now()}.m4a`);
      try {
        const enc = Bun.spawn(
          ["afconvert", "-f", "m4af", "-d", "aac", speech.wav, m4aPath],
          { stdout: "ignore", stderr: "ignore" },
        );
        expect(await enc.exited).toBe(0);
        const m4aB64 = Buffer.from(
          await Bun.file(m4aPath).arrayBuffer(),
        ).toString("base64");
        const res = await chat(audioReq(m4aB64, "m4a"));
        expect(res.status).toBe(200);
        const body = (await res.json()) as any;
        expect(body.choices[0].message.content).toMatch(/quick brown fox/i);
      } finally {
        await unlink(m4aPath).catch(() => {});
      }
    }, 600_000);

    test("malformed input_audio part (no data) → 400", async () => {
      const res = await chat({
        messages: [{
          role: "user",
          content: [
            { type: "input_audio", input_audio: { format: "wav" } },
            { type: "text", text: speech.text },
          ],
        }],
        max_tokens: 8,
      });
      expect(res.status).toBe(400);
      const body = (await res.json()) as any;
      expect(body.error.message).toContain("input_audio");
    });

    test("undecodable non-WAV bytes → 400 naming the transcode", async () => {
      const junk = Buffer.from(
        crypto.getRandomValues(new Uint8Array(2048)),
      ).toString("base64");
      const res = await chat(audioReq(junk, "mp3"));
      expect(res.status).toBe(400);
      const body = (await res.json()) as any;
      expect(body.error.message).toContain("audio transcode failed");
    });

    test("Anthropic /v1/messages rejects audio blocks with a pointer to the OpenAI endpoint", async () => {
      const res = await fetch(`${base}/v1/messages`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          model: "gemma-4-e4b-it-optiq",
          max_tokens: 8,
          messages: [{
            role: "user",
            content: [
              { type: "input_audio", input_audio: { data: speechB64, format: "wav" } },
              { type: "text", text: speech.text },
            ],
          }],
        }),
      });
      expect(res.status).toBe(400);
      const body = (await res.json()) as any;
      expect(body.error.type).toBe("invalid_request_error");
      expect(body.error.message).toContain("/v1/chat/completions");
    });
  },
);
