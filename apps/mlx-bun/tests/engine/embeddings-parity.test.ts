// Opt-in with real weights: /v1/embeddings served from Qwen3-Embedding-4B-4bit-DWQ
// returns the vectors the mlx-lm oracle and pre-refactor main computed.
//   MLX_BUN_TEST_NATIVE=1 \
//   MLX_BUN_APP_TEST_EMBED_MODEL=<Qwen3-Embedding snapshot> \
//   MLX_BUN_TEST_EMBED_REFERENCE=<dir with meta.json, pooled.bin and main-embed.json> \
//   MLX_BUN_TEST_EMBED_REFERENCE_SHA256=<meta.json SHA-256> \
//   MLX_BUN_TEST_EMBED_MAIN_SHA256=<main-embed.json SHA-256> \
//   bun test tests/engine/embeddings-parity.test.ts
// The references are the unchanged producer at main 02d723a
// (scripts/oracle/gen-qwen3-embed-golden.py, mlx-lm environment) and
// packages/inference/scripts/main-speech-reference.ts run in a main checkout;
// the inference package's embedding-parity test compares the library the same
// way. Here the HTTP route, its JSON encoding of float32 and its instruction
// field must return those vectors bit for bit. Without the reference variables
// the file skips; setting only some fails. The server runs in this process on an
// ephemeral port and writes only to a temporary directory.
import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdirSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const names = ["MLX_BUN_APP_TEST_EMBED_MODEL", "MLX_BUN_TEST_EMBED_REFERENCE", "MLX_BUN_TEST_EMBED_REFERENCE_SHA256",
  "MLX_BUN_TEST_EMBED_MAIN_SHA256"] as const;
const set = names.filter(name => process.env[name]?.trim());
if (native && set.length > 0 && set.length < names.length)
  throw new Error(`embedding parity needs all of ${names.join(", ")}; missing: ${names.filter(n => !set.includes(n)).join(", ")}`);
const enabled = native && set.length === names.length;
const [modelDir, referenceDir, metaSha, mainSha] = names.map(name => process.env[name] ?? "") as [string, string, string, string];

function pinned<T>(file: string, pin: string): T {
  const bytes = readFileSync(join(referenceDir, file));
  if (createHash("sha256").update(bytes).digest("hex") !== pin) throw new Error(`${file} differs from its pin`);
  return JSON.parse(bytes.toString("utf8")) as T;
}
const floats = (base64: string) => new Float32Array(new Uint8Array(Buffer.from(base64, "base64")).buffer);
const meta = enabled ? pinned<{ text: string; hidden: number }>("meta.json", metaSha) : null;
const main = enabled ? pinned<{
  texts: string[]; instruction: string;
  documents: { tokens: number; vectorBase64: string }[]; queries: { tokens: number; vectorBase64: string }[];
}>("main-embed.json", mainSha) : null;

describe.skipIf(!enabled)("/v1/embeddings over Qwen3-Embedding", () => {
  const scratch = enabled ? mkdtempSync(join(tmpdir(), "mlx-bun-embed-")) : "";
  let app: RunningApp;
  let base = "";
  const embed = async (body: unknown) => {
    const response = await fetch(`${base}/v1/embeddings`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
    return { status: response.status, body: await response.json() as any };
  };
  const bitExact = (got: number[], reference: Float32Array) => {
    expect(got.length).toBe(reference.length);
    let different = 0;
    for (let i = 0; i < got.length; i++) if (Math.fround(got[i]!) !== reference[i]) different++;
    expect(different).toBe(0);
  };

  beforeAll(async () => {
    const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
    const { scanSnapshot } = await import("@mlx-bun/hub/registry");
    const model = await scanSnapshot(modelDir, "qwen3-embedding");
    if (!model) throw new Error("the embedding path has no loadable checkpoint");
    const options = parseServeOptions({ values: { port: "0", "no-open": true }, positionals: [] });
    options.readOnly = true;
    options.chatPaths = { cwd: join(scratch, "project"), agentDir: join(scratch, "agent"), sessionDir: join(scratch, "sessions"), toolApprovalsFile: join(scratch, "approvals.json") };
    options.memoryPaths = { vault: join(scratch, "vault"), skills: join(scratch, "skills") };
    options.storagePaths = { jobsDb: join(scratch, "jobs.sqlite"), jobsLogs: join(scratch, "jobs"), credentialsFile: join(scratch, "hf.json"), artifactRoot: join(scratch, "artifacts") };
    mkdirSync(options.chatPaths.cwd!);
    app = await startModelServer(model, options);
    base = `http://127.0.0.1:${app.port}`;
  }, 300_000);
  afterAll(async () => { await app?.close(); if (scratch) rmSync(scratch, { recursive: true, force: true }); });

  test("the golden text returns the mlx-lm pooled vector bit for bit", async () => {
    const pooled = new Float32Array(readFileSync(join(referenceDir, "pooled.bin")).buffer.slice(0));
    const { status, body } = await embed({ input: [meta!.text, "an unrelated sentence about quarterly cloud revenue"] });
    expect(status).toBe(200);
    expect(body).toMatchObject({ object: "list", model: "qwen3-embedding" });
    expect(body.data.map((row: { index: number }) => row.index)).toEqual([0, 1]);
    expect(body.data[0].embedding.length).toBe(meta!.hidden);
    bitExact(body.data[0].embedding, pooled);
  }, 300_000);

  test("documents and instructed queries return main's vectors bit for bit and count their tokens", async () => {
    for (const [kind, instruction] of [["documents", undefined], ["queries", main!.instruction]] as const) {
      const { status, body } = await embed({ input: main!.texts, ...(instruction ? { instruction } : {}) });
      expect(status).toBe(200);
      main![kind].forEach((row, i) => bitExact(body.data[i].embedding, floats(row.vectorBase64)));
      const tokens = main![kind].reduce((sum, row) => sum + row.tokens, 0);
      expect(body.usage).toEqual({ prompt_tokens: tokens, total_tokens: tokens });
    }
    // A single string is one input.
    const one = await embed({ input: main!.texts[1] });
    expect(one.body.data.length).toBe(1);
    bitExact(one.body.data[0].embedding, floats(main!.documents[1]!.vectorBase64));
  }, 300_000);

  test("malformed input is a 400", async () => {
    for (const input of [[], [7]]) {
      const { status, body } = await embed({ input });
      expect(status).toBe(400);
      expect(body.error.type).toBe("invalid_request_error");
    }
  });
});
