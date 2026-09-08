import { afterEach, describe, expect, spyOn, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { localBenchmarkModel, measureChatRequest, measureCompletionRequest, serialBenchmarkArgs, unsupportedBenchmarkArm, workloadNonce } from "../../scripts/bench-serve";
import { inventoryModel } from "../../scripts/bench/model-inventory";

const dirs: string[] = [];
function fixture(config: object): string {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bench-model-"));
  dirs.push(dir);
  writeFileSync(join(dir, "config.json"), JSON.stringify(config));
  return dir;
}
afterEach(() => { for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true }); });

const moduleName = "model.layers.0.mlp.down_proj";
const trellis = { mode: "trellis", bits: 3, group_size: 32, trellis: { L: 12, code: "1mad", axis: 0 } };
function packedFixture(): string {
  const dir = fixture({ model_type: "qwen3_5", quantization: {
    bits: 3, group_size: 64, [moduleName]: trellis,
    // Exporters carry both aliases; count only the tensor that exists.
    [`language_model.${moduleName}`]: trellis,
  } });
  const header = Buffer.from(JSON.stringify({
    [`${moduleName}.weight`]: { dtype: "U32", shape: [2, 3], data_offsets: [0, 24] },
    [`${moduleName}.scales`]: { dtype: "F16", shape: [2], data_offsets: [24, 28] },
    "model.norm.weight": { dtype: "BF16", shape: [2], data_offsets: [28, 32] },
  }));
  const len = Buffer.alloc(8);
  len.writeBigUInt64LE(BigInt(header.length));
  writeFileSync(join(dir, "model.safetensors"), Buffer.concat([len, header, Buffer.alloc(32)]));
  return dir;
}

describe("benchmark artifact selection", () => {
  test("keeps exact local path and labels unsupported packed oracle arms", () => {
    const dir = packedFixture();
    const model = localBenchmarkModel(dir, "packed Q3");
    expect(model.label).toBe("packed Q3");
    expect(model.configSha256).toMatch(/^[a-f0-9]{64}$/);
    expect(model.packedTrellis).toBe(true);
    expect(unsupportedBenchmarkArm(model, "mlx-lm")).toContain("separate artifact");
    expect(unsupportedBenchmarkArm(model, "mlx-bun-serial")).toBeNull();
    expect(unsupportedBenchmarkArm(model, "typo")).toContain("unknown arm");
  });

  test("affine artifacts remain comparable with mlx-lm", () => {
    const model = localBenchmarkModel(fixture({ quantization: { bits: 4, group_size: 64 } }));
    expect(model.packedTrellis).toBe(false);
    expect(unsupportedBenchmarkArm(model, "mlx-lm")).toBeNull();
  });

  test("all --dry-run inspects a tiny config without preflight, server, or GPU", () => {
    const dir = packedFixture();
    const child = Bun.spawnSync(["bun", "scripts/bench-serve.ts", "all", "--model-path", dir, "--dry-run"]);
    expect(child.exitCode).toBe(0);
    const plan = JSON.parse(child.stdout.toString());
    expect(plan.measurement).toBe(false);
    expect(plan.workload).toMatchObject({ decodeRuns: 5, enableThinking: true });
    expect(plan.cells.find((c: { arm: string }) => c.arm === "mlx-lm").command).toBeNull();
    const command = plan.cells.find((c: { arm: string }) => c.arm === "mlx-bun-serial").command;
    expect(command[command.indexOf("--model") + 1]).toBe(plan.models[0].path);
    expect(command).toContain("--batch");
    expect(child.stderr.toString()).not.toContain("preflight");
  });

  test("explicit unsupported oracle requests fail before any server can start", () => {
    const child = Bun.spawnSync(["bun", "scripts/bench-serve.ts", "all", "--model-path", packedFixture(), "--arms", "mlx-lm", "--dry-run"]);
    expect(child.exitCode).not.toBe(0);
    expect(child.stderr.toString()).toContain("no stock mlx-lm/optiq loader");
  });

  test("an explicitly requested mixed-KV arm cannot silently skip its missing config", () => {
    const child = Bun.spawnSync(["bun", "scripts/bench-serve.ts", "all", "--model-path", packedFixture(), "--arms", "mlx-bun-mixed", "--dry-run"]);
    expect(child.exitCode).not.toBe(0);
    expect(child.stderr.toString()).toContain("required KV config");
  });
});

describe("benchmark measurement contract", () => {
  test("configured experiments require an explicit serial arm and complete values", () => {
    expect(() => serialBenchmarkArgs(["--draft-kind", "mtp"])).toThrow("--arms mlx-bun-serial");
    expect(() => serialBenchmarkArgs(["--arms", "mlx-bun-serial,mlx-lm", "--kv-quant", "4"])).toThrow("controls separately");
    for (const args of [["--draft-kind"], ["--draft-model", "--dry-run"],
      ["--prompt-cache", "NaN"], ["--num-draft-tokens", "0"]])
      expect(() => serialBenchmarkArgs(args)).toThrow("requires");
  });

  test("dry-run includes draft and KV arguments without a research preload", () => {
    const child = Bun.spawnSync([process.execPath, "scripts/bench-serve.ts", "all",
      "--model-path", packedFixture(), "--arms", "mlx-bun-serial",
      "--draft-model", "/local/draft", "--draft-kind", "mtp", "--num-draft-tokens", "2",
      "--kv-quant", "4", "--prompt-cache", "4", "--dry-run"], {
      env: { ...process.env, MLX_BUN_MTP_PROMPT_CACHE: "1", MLX_BUN_QWEN_SPEC_KV4: "1" },
    });
    expect(child.exitCode).toBe(0);
    const plan = JSON.parse(child.stdout.toString()), command = plan.cells[0].command as string[];
    for (const [flag, value] of [["--draft-model", "/local/draft"], ["--draft-kind", "mtp"],
      ["--num-draft-tokens", "2"], ["--kv-quant", "4"], ["--prompt-cache", "4"]])
      expect(command[command.indexOf(flag!) + 1]).toBe(value);
    expect(plan.runtimeEnvironment.MLX_BUN_QWEN_SPEC_KV4).toBe("1");
    expect(plan.measurement).toBe(false);
  });

  test("paired prompts are reproducible and retries cannot reuse cold-attempt nonces", () => {
    expect(workloadNonce("block-0", "decode", 0, 0)).toBe(workloadNonce("block-0", "decode", 0, 0));
    const cells = [
      workloadNonce("block-0", "decode", 0, 0), workloadNonce("block-0", "decode", 0, 1),
      workloadNonce("block-0", "decode", 1, 0), workloadNonce("block-1", "decode", 0, 0),
    ];
    expect(new Set(cells).size).toBe(4);
  });

  test("token usage, not SSE chunk count, controls throughput; wall time includes stream completion", async () => {
    let body: Record<string, unknown> = {};
    const enc = new TextEncoder();
    const mockFetch = Object.assign(async (...[_url, init]: Parameters<typeof fetch>) => {
      body = JSON.parse(String(init?.body));
      return new Response(new ReadableStream({ async start(controller) {
        const send = (data: unknown) => controller.enqueue(enc.encode(`data: ${JSON.stringify(data)}\n\n`));
        send({ choices: [{ delta: { reasoning: "think ", content: "a" } }] });
        await Bun.sleep(5);
        send({ choices: [{ delta: { content: "b" }, finish_reason: "length" }] });
        await Bun.sleep(5);
        send({ usage: { prompt_tokens: 20, completion_tokens: 100 } });
        controller.enqueue(enc.encode("data: [DONE]\n\n"));
        controller.close();
      } }));
    }, { preconnect: fetch.preconnect });
    const fetchMock = spyOn(globalThis, "fetch").mockImplementation(mockFetch);
    try {
      const result = await measureChatRequest("http://mock", "prompt", 100);
      expect(result).toMatchObject({ text: "athink b", genTokens: 100, contentChunks: 2, finishReason: "length" });
      expect(result.endToEndTps).toBeCloseTo(100_000 / result.wallMs);
      expect(result.endToEndTps).toBeLessThan(result.decodeTps);
      expect(result.outputEventTimesMs).toHaveLength(2);
      expect(result.firstByteMs).toBeGreaterThanOrEqual(result.headersMs);
      expect(result.ttftMs).toBeGreaterThanOrEqual(result.firstByteMs);
      expect(result.doneSeen).toBe(true);
      expect(body.chat_template_kwargs).toEqual({ enable_thinking: true });
    } finally { fetchMock.mockRestore(); }
  });

  test("missing usage fails instead of treating a token burst as one token", async () => {
    const fetchMock = spyOn(globalThis, "fetch").mockResolvedValue(new Response(
      'data: {"choices":[{"delta":{"content":"many tokens"},"finish_reason":"stop"}]}\n\n',
    ));
    try { await expect(measureChatRequest("http://mock", "prompt", 100)).rejects.toThrow("SSE chunk counts"); }
    finally { fetchMock.mockRestore(); }
  });

  test("raw completion timing sends an untemplated prompt and reads text chunks", async () => {
    let url = "";
    let body: any;
    const mockFetch = Object.assign(async (input: any, init?: RequestInit) => {
      url = String(input); body = JSON.parse(String(init?.body));
      return new Response([
        { choices: [{ text: "a " }] },
        { choices: [{ text: "b", finish_reason: "length" }] },
        { choices: [], usage: { prompt_tokens: 6, completion_tokens: 3 } },
      ].map((event) => `data: ${JSON.stringify(event)}\n\n`).join("") + "data: [DONE]\n\n");
    }, { preconnect: fetch.preconnect });
    const fetchMock = spyOn(globalThis, "fetch").mockImplementation(mockFetch);
    try {
      const result = await measureCompletionRequest("http://mock", "raw prompt", 3);
      expect(url).toBe("http://mock/v1/completions");
      expect(body.prompt).toBe("raw prompt");
      expect(body.messages).toBeUndefined();
      expect(body.chat_template_kwargs).toBeUndefined();
      expect(result).toMatchObject({ text: "a b", genTokens: 3, promptTokens: 6,
        contentChunks: 2, finishReason: "length", doneSeen: true });
      expect(result.outputEventTimesMs).toHaveLength(2);
    } finally { fetchMock.mockRestore(); }
  });

  test("tool-only streams have output latency and retain burst arrival times", async () => {
    const events = [
      { choices: [{ delta: { role: "assistant" } }] },
      { choices: [{ delta: { tool_calls: [{ index: 0, function: { name: "weather", arguments: "" } }] } }] },
      { choices: [{ delta: { tool_calls: [{ index: 0, function: { arguments: '{"city":"Paris"}' } }] }, finish_reason: "tool_calls" }] },
      { choices: [], usage: { prompt_tokens: 30, completion_tokens: 15 } },
    ];
    const fetchMock = spyOn(globalThis, "fetch").mockResolvedValue(new Response(
      events.map((e) => `data: ${JSON.stringify(e)}\r\n\r\n`).join("") + "data: [DONE]",
    ));
    try {
      const result = await measureChatRequest("http://mock", "prompt", 32);
      expect(result).toMatchObject({ contentChunks: 0, toolCallChunks: 2, genTokens: 15, finishReason: "tool_calls", doneSeen: true });
      expect(result.outputEventTimesMs).toHaveLength(2);
      expect(result.ttftMs).toBeGreaterThanOrEqual(result.firstEventMs);
    } finally { fetchMock.mockRestore(); }
  });

  test("a successful HTTP status cannot hide an SSE error or truncated completion", async () => {
    for (const [body, error] of [
      ['data: {"error":{"message":"pressure"}}\n\n', "SSE error"],
      ['data: {malformed}\n\n', "malformed SSE"],
      ['data: {"choices":[{"delta":{"content":"x"},"finish_reason":"stop"}],"usage":{"prompt_tokens":2,"completion_tokens":1}}\n\n', "incomplete SSE"],
    ]) {
      const fetchMock = spyOn(globalThis, "fetch").mockResolvedValue(new Response(body));
      try { await expect(measureChatRequest("http://mock", "prompt", 8)).rejects.toThrow(error); }
      finally { fetchMock.mockRestore(); }
    }
  });
});

describe("header-only matrix inventory", () => {
  test("reconstructs axis-0 3-bit shape and includes scales without alias duplication", () => {
    const report = inventoryModel(packedFixture());
    expect(report.tensorCount).toBe(3);
    expect(report.payloadBytes).toBe(32);
    expect(report.matrices).toHaveLength(1);
    expect(report.matrices[0]).toMatchObject({
      storedShape: [2, 3], logicalShape: [32, 2], parameters: 64,
      payloadBytes: 28, bits: 3, axis: 0,
    });
    expect(report.matrixEffectiveBpw).toBe(3.5);
    expect(report.roles.other!.payloadBytes).toBe(4);
  });

  test("does not mistake config default bits for dense tensor storage", () => {
    const dir = fixture({ quantization: { bits: 4, group_size: 64 } });
    const header = Buffer.from(JSON.stringify({
      "model.embed_tokens.weight": { dtype: "BF16", shape: [2, 2], data_offsets: [0, 8] },
    }));
    const len = Buffer.alloc(8); len.writeBigUInt64LE(BigInt(header.length));
    writeFileSync(join(dir, "model.safetensors"), Buffer.concat([len, header, Buffer.alloc(8)]));
    expect(inventoryModel(dir).matrices[0]).toMatchObject({ logicalShape: [2, 2], mode: "dense", bits: 16 });
  });

  test("rejects an index that names a tensor absent from its shard", () => {
    const dir = packedFixture();
    writeFileSync(join(dir, "model.safetensors.index.json"), JSON.stringify({
      weight_map: { missing: "model.safetensors" },
    }));
    expect(() => inventoryModel(dir)).toThrow("index/header mismatch");
  });
});
