// Opt-in with real weights: generation from image, audio, and mixed
// image+audio prompts through the served chat API of a Gemma4 checkpoint with
// both towers (e2b or e4b; run it once per variant):
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_APP_TEST_GEMMA4_AUDIO_MODEL=<snapshot directory> \
//     bun test tests/engine/media-generation.test.ts
// Media are synthesized (a seeded PNG; speech from macOS `say` when present,
// else a tone); nothing is committed. Greedy requests must be deterministic
// through the encoder cache, streaming must deliver the same text, two
// identical mixed rows released together must agree, rows released beside a
// text row or another medium must complete, and a stream disconnected
// mid-reply must leave the next request unchanged. Media prompts must carry
// their soft tokens (more prompt tokens than text alone). Batched rows are
// compared with their solo output in the log only: batch invariance is not a
// contract here. This is app behavior on real weights, not parity against main
// or an oracle; media-native.test.ts covers prompt preparation.
import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";
import { pngBase64, speech, speechTools, tone, wavBytes } from "../support/media";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_APP_TEST_GEMMA4_AUDIO_MODEL;

test.skipIf(!native || !modelDir)("Gemma4 generates from image, audio, and mixed prompts consistently under batching and disconnect", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-media-generation-"));
  let app: RunningApp | undefined;
  try {
    const audioBytes = speechTools ? (await speech(root)).bytes : wavBytes(tone(2, 440));
    const text = { type: "text", text: "Describe the attached media in one sentence." };
    const image = { type: "image_url", image_url: { url: `data:image/png;base64,${pngBase64(3)}` } };
    const audio = { type: "input_audio", input_audio: { data: Buffer.from(audioBytes).toString("base64"), format: "wav" } };
    const prompts = { text: [text], image: [text, image], audio: [text, audio], mixed: [text, image, audio] };

    const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
    const { scanSnapshot } = await import("@mlx-bun/hub/registry");
    const model = await scanSnapshot(modelDir!, "test-gemma4");
    if (!model) throw new Error("Model path has no loadable checkpoint");
    const options = parseServeOptions({ values: { port: "0", "no-open": true, "max-tokens": "32", thinking: "off" }, positionals: [] });
    options.readOnly = true;
    options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    mkdirSync(options.chatPaths.cwd!);
    app = await startModelServer(model, options);
    const base = `http://127.0.0.1:${app.port}`;
    const listed = await (await fetch(`${base}/v1/models`)).json();
    expect(listed.data[0]).toMatchObject({ vision: true, audio: true });

    const body = (content: unknown[], extra: Record<string, unknown> = {}) => JSON.stringify({
      messages: [{ role: "user", content }], max_tokens: 32, temperature: 0, seed: 1, ...extra });
    const complete = async (content: unknown[]) => {
      const response = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" }, body: body(content) });
      const raw = await response.text();
      expect(response.status, raw).toBe(200);
      const completion = JSON.parse(raw);
      return { text: String(completion.choices[0].message.content ?? ""), finish: completion.choices[0].finish_reason as string,
        prompt: completion.usage.prompt_tokens as number, completion: completion.usage.completion_tokens as number };
    };

    const solo = {
      text: await complete(prompts.text), image: await complete(prompts.image),
      audio: await complete(prompts.audio), mixed: await complete(prompts.mixed),
    };
    for (const [name, result] of Object.entries(solo)) {
      expect(result.completion, name).toBeGreaterThan(0);
      console.log(`[media] ${name}: ${JSON.stringify(result.text)}`);
    }
    expect(solo.image.prompt).toBeGreaterThan(solo.text.prompt);
    expect(solo.audio.prompt).toBeGreaterThan(solo.text.prompt);
    expect(solo.mixed.prompt).toBeGreaterThan(Math.max(solo.image.prompt, solo.audio.prompt));
    // A repeat reads the warm encoder cache.
    expect(await complete(prompts.mixed)).toEqual(solo.mixed);

    const stream = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
      body: body(prompts.mixed, { stream: true }) });
    const frames = (await stream.text()).split("\n").filter(line => line.startsWith("data: ") && line !== "data: [DONE]").map(line => JSON.parse(line.slice(6)));
    expect(frames.map(frame => frame.choices?.[0]?.delta?.content ?? "").join("")).toBe(solo.mixed.text);
    expect(frames.map(frame => frame.choices?.[0]?.finish_reason).filter(Boolean)).toEqual([solo.mixed.finish]);

    // Released together: two mixed rows, then a mixed row beside a text row, then image beside audio.
    const pair = await Promise.all([complete(prompts.mixed), complete(prompts.mixed)]);
    expect(pair[1]).toEqual(pair[0]);
    const groups = { "mixed+mixed": [pair, [solo.mixed, solo.mixed]],
      "mixed+text": [await Promise.all([complete(prompts.mixed), complete(prompts.text)]), [solo.mixed, solo.text]],
      "image+audio": [await Promise.all([complete(prompts.image), complete(prompts.audio)]), [solo.image, solo.audio]] } as const;
    for (const [name, [together, alone]] of Object.entries(groups)) {
      for (const row of together) expect(row.completion, name).toBeGreaterThan(0);
      together.forEach((row, i) => expect(row.prompt, name).toBe(alone[i]!.prompt));
      console.log(`[media] ${name} released together ${JSON.stringify(together) === JSON.stringify(alone) ? "equals" : "differs from"} the solo rows`);
    }

    // A client that disconnects mid-reply leaves the next request unchanged.
    const aborted = new AbortController();
    const interrupted = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
      body: body(prompts.mixed, { stream: true }), signal: aborted.signal });
    const reader = interrupted.body!.getReader();
    let seen = "";
    while (!seen.includes("\"content\"")) {
      const next = await reader.read();
      if (next.done) break;
      seen += new TextDecoder().decode(next.value);
    }
    aborted.abort();
    await reader.cancel().catch(() => {});
    expect(await complete(prompts.mixed)).toEqual(solo.mixed);
    expect(await complete(prompts.text)).toEqual(solo.text);
  } finally {
    try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); }
  }
}, 1_200_000);
