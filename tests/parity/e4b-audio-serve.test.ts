// GATED integration: audio input end to end through the HTTP server (T3 of
// docs/design/generic-model-support.md §3.4). Ephemeral in-process server (dies
// with the test), real /v1/chat/completions requests carrying base64 audio.
//
//   MLX_BUN_TEST_AUDIO_SERVE=1 bun test tests/e4b-audio-serve.test.ts
//
// The NUMERICS are gated offline (tests/e4b-audio.test.ts: full greedy stream
// oracle-EXACT). This gates the WIRING: content-part detection → extractAudio
// → ensureWav (CoreAudio transcode for non-WAV) → buildMultimodalPrompt →
// embeddings prefill on the SERIAL lane — and the failure surfaces (explicit
// 400s, never a silent text-only degrade). Default server config = bf16 KV +
// batch lane live (batch defaults > 1), so the transcription must match the
// offline golden exactly AND the routing assertion is non-vacuous: text
// requests ride the batch lane while audio drains to serial.

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { unlink } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { goldenAt } from "../support/goldens";
import { SNAPSHOT_E4B, snapshotE4bAvailable } from "../support/paths";

interface AudioFixture { wav: string; text: string; decoded: string }
interface AudioGolden { fixtures: Record<string, AudioFixture> }

const optIn = process.env.MLX_BUN_TEST_AUDIO_SERVE === "1";
const haveWeights =
  (await snapshotE4bAvailable()) &&
  existsSync(`${SNAPSHOT_E4B}/optiq_vision.safetensors`);
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
    const ctx = await loadContext(SNAPSHOT_E4B, "gemma-4-e4b-it-optiq");
    const server = createServer(ctx, 0); // defaults: bf16 KV, batch lane live
    const base = `http://localhost:${server.port}`;
    afterAll(() => server.stop(true));

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
      // Serial-lane routing: audio (embeddings prefill) must never enter the
      // batch lane — submitted_rows only advances for batched rows.
      expect(await submittedRows()).toBe(before);
      // ...and the batch lane IS live on this server (non-vacuous check):
      // a plain text request advances it.
      const textRes = await chat({
        messages: [{ role: "user", content: "Say ping." }],
        max_tokens: 4, temperature: 0,
      });
      expect(textRes.status).toBe(200);
      expect(await submittedRows()).toBe(before + 1);
    }, 600_000);

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
