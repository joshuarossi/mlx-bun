// /v1/embeddings route (slow tier): an ephemeral-port server inside the test
// process (dies with the test — NOT a persistent server) serving the
// Qwen3-Embedding model. Verifies the OpenAI-shaped response AND ties the HTTP
// path back to the oracle: the vector for the golden text must match the
// mlx-lm golden (goldens/qwen3-embed/pooled.bin) produced in the parity test.

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { SNAPSHOT_QWEN3_EMBED, snapshotQwen3EmbedAvailable } from "./paths";

const GOLD_DIR = "goldens/qwen3-embed";
const have = (await snapshotQwen3EmbedAvailable()) && existsSync(`${GOLD_DIR}/meta.json`);

describe.skipIf(!have)("/v1/embeddings", async () => {
  if (!have) return;
  const { createServer, loadContext } = await import("../src/server");
  const meta = (await Bun.file(`${GOLD_DIR}/meta.json`).json()) as { text: string; hidden: number };
  const refPooled = new Float32Array(await Bun.file(`${GOLD_DIR}/pooled.bin`).arrayBuffer());

  const ctx = await loadContext(SNAPSHOT_QWEN3_EMBED, "qwen3-embedding");
  const server = createServer(ctx, 0);
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  test("POST returns OpenAI-shaped embeddings matching the mlx-lm golden", async () => {
    const res = await fetch(`${base}/v1/embeddings`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ input: [meta.text, "an unrelated sentence about quarterly cloud revenue"] }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as {
      object: string;
      model: string;
      data: { object: string; index: number; embedding: number[] }[];
      usage: { prompt_tokens: number; total_tokens: number };
    };
    expect(body.object).toBe("list");
    expect(body.model).toBe("qwen3-embedding");
    expect(body.data.length).toBe(2);
    expect(body.data[0]!.embedding.length).toBe(meta.hidden);
    expect(body.data[1]!.index).toBe(1);
    expect(body.usage.total_tokens).toBeGreaterThan(0);

    // The first input IS the golden text → its vector must match pooled.bin
    // (the whole stack is bit-exact vs mlx-lm; allow a hair for float JSON).
    const got = body.data[0]!.embedding;
    let sqErr = 0;
    let sqRef = 0;
    for (let i = 0; i < refPooled.length; i++) {
      const d = got[i]! - refPooled[i]!;
      sqErr += d * d;
      sqRef += refPooled[i]! * refPooled[i]!;
    }
    expect(Math.sqrt(sqErr / sqRef)).toBeLessThan(1e-6);
  });

  test("empty input is a 400", async () => {
    const res = await fetch(`${base}/v1/embeddings`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ input: [] }),
    });
    expect(res.status).toBe(400);
    const body = (await res.json()) as { error: { type: string } };
    expect(body.error.type).toBe("invalid_request_error");
  });
});
