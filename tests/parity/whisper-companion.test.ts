// Companion mode (slow tier): the FULL chat server (MiniCPM5, ephemeral port,
// dies with the test) also answers /v1/audio/transcriptions with the
// default Whisper checkpoint resolved lazily, advertises it on /v1/models,
// and keeps chat working after a transcription (gateway exclusive lock).

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import { resolveWhisperTokenizerDir } from "../../src/audio/whisper-tokenizer";
import { SNAPSHOT_MINICPM5, SNAPSHOT_WHISPER, snapshotMiniCPM5Available } from "../support/paths";

const FOX = `${import.meta.dir}/../../fixtures/audio/speech-fox.wav`;
const have = (await snapshotMiniCPM5Available()) &&
  existsSync(`${SNAPSHOT_WHISPER}/config.json`) && resolveWhisperTokenizerDir(SNAPSHOT_WHISPER, 51866) !== null;

describe.skipIf(!have)("whisper companion on the chat server", async () => {
  if (!have) return;
  const { createServer, loadContext } = await import("../../src/server");
  const ctx = await loadContext(SNAPSHOT_MINICPM5, "minicpm5");
  const server = createServer(ctx, 0, { whisperModelDir: SNAPSHOT_WHISPER, whisperModelId: "whisper-turbo", whisperResident: true });
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  test("/v1/models lists the companion and the transcription capability", async () => {
    const body = await (await fetch(`${base}/v1/models`)).json() as { data: { id: string; transcription?: boolean; capabilities: { transcription?: boolean } }[] };
    expect(body.data[0]!.capabilities.transcription).toBe(true);
    expect(body.data.find((m) => m.id === "whisper-turbo")).toMatchObject({ transcription: true });
  });

  test("transcribes, then chat still answers", async () => {
    const form = new FormData();
    form.set("file", new Blob([readFileSync(FOX)], { type: "audio/wav" }), "fox.wav");
    form.set("language", "en");
    form.set("temperature", "0");
    const res = await fetch(`${base}/v1/audio/transcriptions`, { method: "POST", body: form });
    expect(res.status).toBe(200);
    const body = await res.json() as { text: string; mlx_bun: { timings: { load_ms: number } } };
    expect(body.text.toLowerCase()).toContain("quick brown fox");
    expect(body.mlx_bun.timings.load_ms).toBeGreaterThan(0);
    const chat = await fetch(`${base}/v1/chat/completions`, {
      method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: [{ role: "user", content: "Say hi." }], max_tokens: 8 }),
    });
    expect(chat.status).toBe(200);
    const cb = await chat.json() as { choices: { message: { content: string } }[] };
    expect(typeof cb.choices[0]!.message.content).toBe("string");
  });
});
