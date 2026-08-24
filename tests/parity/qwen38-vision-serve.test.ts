// Qwen3.8 vision SERVE smoke (PLAN 14v) — OPT-IN heavy tier, its own file
// so the 20 GB model loads exactly once in this process (running it beside
// the e2e parity describe loaded TWO instances and hit the documented
// Metal-completion-thread failure under memory saturation).
//
//   MLX_BUN_TEST_QWEN38_VISION_SERVE=1 bun test tests/qwen38-vision-serve.test.ts

import { describe, expect, test } from "bun:test";
import { SNAPSHOT_QWEN38, snapshotQwen38Available } from "../support/paths";

const FIX = `${import.meta.dir}/../fixtures`;
const optIn = process.env.MLX_BUN_TEST_QWEN38_VISION_SERVE === "1";
const haveModel = await snapshotQwen38Available();

describe.skipIf(!optIn || !haveModel)("qwen3.8 vision serve smoke", async () => {
  if (!optIn || !haveModel) return;
  test("serve path: image chat completion through the full HTTP wiring", async () => {
    // The complete serving chain: extractImages → template ({type:"image"} →
    // vision tokens) → pad expansion → tower → splice → gateway serial lane
    // with the scoped mrope → streamed decode. Uses the ALREADY-LOADED model.
    const { createServer, loadContext } = await import("../../src/server");
    const ctx = await loadContext(SNAPSHOT_QWEN38, "mlx-community/Qwen3.8-27B-OptiQ-4bit");
    const server = createServer(ctx, 0, { owner: "embedded", memoryBudgetBytes: 22_500_000_000 });
    try {
      const png = await Bun.file(`${FIX}/grad-500x300.png`).arrayBuffer();
      const b64 = Buffer.from(png).toString("base64");
      const res = await fetch(`http://localhost:${server.port}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          model: "qwen38",
          max_tokens: 48,
          temperature: 0,
          chat_template_kwargs: { enable_thinking: false },
          messages: [{
            role: "user",
            content: [
              { type: "image_url", image_url: { url: `data:image/png;base64,${b64}` } },
              { type: "text", text: "What two colors dominate this image? Answer briefly." },
            ],
          }],
        }),
        // @ts-expect-error Bun extension
        timeout: false,
      });
      expect(res.status).toBe(200);
      const json = await res.json() as { choices: { message: { content: string } }[] };
      const text = json.choices[0]!.message.content.toLowerCase();
      // The 500x300 gradient runs green → pink (the oracle's own words).
      expect(/green|pink|magenta/.test(text)).toBe(true);
      // A follow-up TEXT request on the same server must be unaffected by the
      // vision request's mrope state (scoped clear).
      const res2 = await fetch(`http://localhost:${server.port}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          model: "qwen38", max_tokens: 16, temperature: 0,
          chat_template_kwargs: { enable_thinking: false },
          messages: [{ role: "user", content: "What is 2+2? Just the number." }],
        }),
        // @ts-expect-error Bun extension
        timeout: false,
      });
      expect(res2.status).toBe(200);
      const json2 = await res2.json() as { choices: { message: { content: string } }[] };
      expect(json2.choices[0]!.message.content).toContain("4");
      // VIDEO request on the same server (PLAN 14w): the fixture clip runs
      // through the AVFoundation sidecar → frames → tower → mRoPE. Skipped
      // gracefully only when no extractor resolves on this machine.
      const { resolveFrameExtract } = await import("../../src/vision/video-frames");
      if (await resolveFrameExtract()) {
        const mov = await Bun.file(`${FIX}/qwen38-clip.mov`).arrayBuffer();
        const vb64 = Buffer.from(mov).toString("base64");
        const res3 = await fetch(`http://localhost:${server.port}/v1/chat/completions`, {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({
            model: "qwen38",
            max_tokens: 48,
            temperature: 0,
            chat_template_kwargs: { enable_thinking: false },
            messages: [{
              role: "user",
              content: [
                { type: "video_url", video_url: { url: `data:video/quicktime;base64,${vb64}` } },
                { type: "text", text: "Describe this video in one short sentence." },
              ],
            }],
          }),
          // @ts-expect-error Bun extension
          timeout: false,
        });
        expect(res3.status).toBe(200);
        const json3 = await res3.json() as { choices: { message: { content: string } }[] };
        // The clip is a moving gradient; any real description mentions
        // gradient/color words.
        expect(/gradient|colou?r/i.test(json3.choices[0]!.message.content)).toBe(true);
      }
    } finally {
      server.stop(true);
    }
  }, 3_600_000);
});
