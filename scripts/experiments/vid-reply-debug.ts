// One-off: print the actual serve-path reply for the fixture video clip
// (assertion calibration for tests/qwen38-vision-serve.test.ts).
import { SNAPSHOT_QWEN38 } from "../../tests/paths";
import { createServer, loadContext } from "../../src/server";

const ctx = await loadContext(SNAPSHOT_QWEN38, "mlx-community/Qwen3.8-27B-OptiQ-4bit");
const server = createServer(ctx, 0, { owner: "embedded", memoryBudgetBytes: 22_500_000_000 });
const mov = await Bun.file(`${import.meta.dir}/../../tests/fixtures/qwen38-clip.mov`).arrayBuffer();
const vb64 = Buffer.from(mov).toString("base64");
const res = await fetch(`http://localhost:${server.port}/v1/chat/completions`, {
  method: "POST",
  headers: { "content-type": "application/json" },
  body: JSON.stringify({
    model: "qwen38", max_tokens: 64, temperature: 0,
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
console.log("status", res.status);
const j = await res.json() as { choices?: { message: { content: string } }[] };
console.log("content:", j.choices?.[0]?.message?.content ?? JSON.stringify(j).slice(0, 300));
server.stop(true);
