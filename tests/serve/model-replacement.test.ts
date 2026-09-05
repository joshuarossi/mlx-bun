import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadModelConfig } from "../../src/config";
import { ChatTemplate } from "../../src/chat-template";
import { resolveModelProfile } from "../../src/model/profile";
import { configFingerprint } from "../../src/model/fingerprint";
import { runtimeConfig } from "../../src/runtime-config";
import { createServer, shutdownServer, loadContext, ModelImplementationRegistry,
  type ServingContext, type ModelHostSource, type ModelServingBinding } from "../../src/index";

test("one model binding supplies multiple methods to the unchanged HTTP/session path", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-model-port-"));
  let server: ReturnType<typeof createServer> | undefined;
  try {
    writeFileSync(join(dir, "config.json"), JSON.stringify({
      model_type: "qwen3", hidden_size: 16, num_hidden_layers: 1,
      num_attention_heads: 2, num_key_value_heads: 1, head_dim: 8,
      intermediate_size: 32, vocab_size: 16, max_position_embeddings: 4096,
      eos_token_id: 0,
    }));
    writeFileSync(join(dir, "tokenizer_config.json"), JSON.stringify({ chat_template: "test prompt" }));
    const config = await loadModelConfig(dir);
    const selected: string[] = [];
    const binding: ModelServingBinding = {
      gateway: {
        config, runtime: runtimeConfig(),
        cachesBatchable: () => false, kvBatchable: () => false,
        createBatchGroup() { throw new Error("this implementation owns its serial methods"); },
        plan(_request, options) {
          return Object.freeze({
            method: options.temperature === 0 ? "custom-exact" : "custom-alternate",
            mechanism: "serial", pagedKv: false, promptCache: false, checkpoint: false,
            fill: false, compiledDecode: false, grammarJump: false, reasons: [],
          });
        },
      },
      createSerial: () => async (_prompt, _options, onToken, _vision, _trace, execution) => {
        selected.push(execution!.method);
        const token = execution!.method === "custom-exact" ? 1 : 2;
        await onToken(token);
        return { promptTokens: 3, cachedTokens: 0, generatedTokens: 1,
          prefillMs: 0, decodeMs: 0, prefillTps: 0, decodeTps: 0, cacheTokens: [] };
      },
      async buildPrompt() {
        return { promptIds: [3, 4, 5], vision: undefined, startInThinking: false,
          probeStableLen: false, diffusionPixels: null };
      },
      restore: () => null,
      signal: async () => ({ bins: [1], vocab: 16 }),
      diagnostics: () => ({ custom_model: { method_count: 2 } }),
      discovery: { adapters: false, training: false, embeddings: false, dsa: false },
    };
    // No RuntimeModel cast, graph class, forward(), makeCache() or native weights.
    const ctx: ServingContext = {
      model: { config, weightsBytes: 0 }, serving: binding,
      profile: resolveModelProfile(config), modelId: "independent-model",
      tokenizer: { encode: () => [3, 4, 5], decode: (ids) => ids.map((id) => `t${id}`).join(""),
        idToToken: (id) => `t${id}`, bosTokenId: null, eosTokenId: 0 },
      template: await ChatTemplate.load(dir),
      adapters: { resolveSpec: () => [], cacheNamespace: () => "", list: () => [], get: () => undefined,
        mount: async () => { throw new Error("unsupported"); }, unmount: () => 0 },
      kvConfig: null, genDefaults: {}, draft: null,
      vision: null, loadVision: null, audio: null, loadAudio: null, audioTokenIds: null,
      visionTokenIds: { imageTokenId: 1, boiTokenId: 2, eoiTokenId: 3 },
    };
    let opens = 0;
    const implementations = new ModelImplementationRegistry<ModelHostSource, Promise<ServingContext>>([{
      id: "independent-quant", loader: "safetensors", graph: "qwen3", loop: "autoregressive",
      async create(source, resolvedConfig, profile) {
        opens++;
        expect(source.modelDir).toBe(dir);
        expect(resolvedConfig.modelType).toBe("qwen3");
        return { ...ctx, profile };
      },
    }]);
    const opened = await loadContext(dir, "independent-model", {
      implementations,
      profiles: { artifactFingerprint: "sha256:synthetic-host-quant", artifactProfiles: [{
        id: "independent-quant", artifactFingerprint: "sha256:synthetic-host-quant",
        configFingerprint: configFingerprint(config), requiredCapabilities: ["safetensors", "autoregressive", "qwen3-graph"],
        fidelity: { tier: "l3", oracle: null, claim: "measured" },
        execution: { loader: "safetensors", graph: "qwen3", loop: "autoregressive",
          specialization: "artifact", implementation: "independent-quant" },
      }] },
    });
    expect(opens).toBe(1); // no default weights exist, so any default loader call would fail
    server = createServer(opened, 0, { batch: 1, promptCacheBytes: 0 });
    const base = `http://127.0.0.1:${server.port}`;
    for (const [temperature, expected] of [[0, "t1"], [1, "t2"]] as const) {
      const response = await fetch(`${base}/v1/chat/completions`, {
        method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ messages: [{ role: "user", content: "hello" }], temperature, max_tokens: 4 }),
      });
      expect(response.status).toBe(200);
      const body = await response.json() as any;
      expect(body.choices[0].message.content).toBe(expected);
      expect(body.usage.completion_tokens).toBe(1);
    }
    expect(selected).toEqual(["custom-exact", "custom-alternate"]);
    const models = await (await fetch(`${base}/v1/models`)).json() as any;
    expect(models.data[0]).toMatchObject({ id: "independent-model", embeddings: false, adapters: false });
    expect((await fetch(`${base}/v1/embeddings`, {
      method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ input: "hello" }),
    })).status).toBe(400);
    const stats = await (await fetch(`${base}/stats`)).json() as any;
    expect(stats.custom_model).toEqual({ method_count: 2 });
  } finally {
    if (server) await shutdownServer(server);
    rmSync(dir, { recursive: true, force: true });
  }
});
