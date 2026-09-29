// Facts the application used to derive from a model's family: which models plan
// their own memory, which pool embeddings and how, and which registry types play
// which role. Each is declared by the model layer and read as data.
import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "@mlx-bun/mlx/array";
import { loadModelConfig } from "../../src/artifacts/config";
import { declareGraph, declaredGraph } from "../../src/models/capabilities";
import { BUILTIN_ARTIFACT_PROFILES, chatTemplateFallbackFor, embeddingDeclarationFor, generationDefaultsFor, GENERIC_GENERATION_DEFAULTS,
  mediaTokenDeclarationFor, resolveModelProfile, sentinelDeclarationFor, type ResolvedModelProfile } from "../../src/models/profile";
import { loadModelChatTemplate } from "../../src/models/chat-template";
import { ChatTemplate } from "../../src/input/chat-template";
import { resolveAudioTokenIds, resolveSentinelTokens, resolveVisionTokenIds } from "../../src/input/special-tokens";
import { plansMemory, planRuntimeMemory } from "../../src/models/memory-plan";
import { isEmbeddingModelType, isTranscriptionModelType } from "../../src/models/support";
import { embeddingTerminatorId, embedOne } from "../../src/embeddings/text";

const root = mkdtempSync(join(tmpdir(), "mlx-serving-facts-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));
async function config(name: string, raw: Record<string, unknown>) {
  const dir = join(root, name);
  await Bun.$`mkdir -p ${dir}`.quiet();
  writeFileSync(join(dir, "config.json"), JSON.stringify(raw));
  return { dir, config: await loadModelConfig(dir) };
}
const text = { hidden_size: 64, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 1, head_dim: 32, vocab_size: 64,
  intermediate_size: 64, rms_norm_eps: 1e-6, rope_theta: 1e6, max_position_embeddings: 128, tie_word_embeddings: true, eos_token_id: 1 };

describe("planned runtimes", () => {
  test("only a profile whose weights load through a planned runtime plans memory; every other model has no plan", async () => {
    const qwen3 = await config("qwen3", { model_type: "qwen3", ...text });
    expect(plansMemory(resolveModelProfile(qwen3.config))).toBe(false);
    expect(await planRuntimeMemory(qwen3.dir, qwen3.config)).toBeNull();
    const streamed = BUILTIN_ARTIFACT_PROFILES.find(profile => profile.execution.loader === "colibri")!;
    expect(plansMemory({ profile: streamed, artifact: { fingerprint: streamed.artifactFingerprint, configFingerprint: streamed.configFingerprint }, exactArtifact: true } as ResolvedModelProfile)).toBe(true);
  });
});

describe("pooled embeddings", () => {
  test("the qwen3 profile declares the pooling terminator and no other graph does; the registry type agrees", async () => {
    const qwen3 = await config("qwen3-embed", { model_type: "qwen3", ...text });
    expect(embeddingDeclarationFor(resolveModelProfile(qwen3.config))).toEqual({ terminator: "<|endoftext|>" });
    const llama = await config("llama", { model_type: "llama", ...text });
    expect(embeddingDeclarationFor(resolveModelProfile(llama.config))).toBeNull();
    expect(isEmbeddingModelType("qwen3")).toBe(true);
    for (const type of ["llama", "qwen3_5", "qwen3_moe", "gemma4", "whisper", "glm_moe_dsa"]) expect(isEmbeddingModelType(type)).toBe(false);
  });

  test("a graph that declares embeddings must provide the pooling operation", () => {
    expect(() => declaredGraph({ graphCapabilities: declareGraph({ embeddings: true }) })).toThrow("provides no embedPooled");
    expect(declaredGraph({ graphCapabilities: declareGraph({ embeddings: true }), embedPooled: () => { throw new Error("unused"); } })
      .graphCapabilities.embeddings).toBe(true);
  });

  test("the terminator id comes from the tokenizer and must be one token", () => {
    const tokenizer = { encode: (value: string) => value === "<|endoftext|>" ? [151643] : [1, 2] };
    expect(embeddingTerminatorId(tokenizer, "<|endoftext|>")).toBe(151643);
    expect(() => embeddingTerminatorId(tokenizer, "other")).toThrow("not a single token");
  });

  test("the declared terminator, not a family constant, ends the embedded input", () => {
    const seen: number[][] = [];
    const graph = { embedPooled(ids: MlxArray) {
      seen.push([...new Int32Array(ids.rawBytes().buffer)]);
      return MlxArray.fromFloat32(Float32Array.of(1), [1, 1]);
    } };
    const tokenizer = { encode: () => [5, 6] } as never;
    for (const terminator of [151643, 7]) {
      const result = embedOne(graph as never, tokenizer, terminator, "text");
      expect(result.tokens).toBe(3);
    }
    expect(seen).toEqual([[5, 6, 151643], [5, 6, 7]]);
  });
});

describe("registry roles", () => {
  test("a Whisper checkpoint is the transcription type and nothing else is", () => {
    expect(isTranscriptionModelType("whisper")).toBe(true);
    for (const type of ["qwen3", "gemma4", "llama"]) expect(isTranscriptionModelType(type)).toBe(false);
  });
});

const glmProfile = (): ResolvedModelProfile => {
  const profile = BUILTIN_ARTIFACT_PROFILES.find(candidate => candidate.execution.graph === "glm5.2")!;
  return { profile, artifact: { fingerprint: profile.artifactFingerprint, configFingerprint: profile.configFingerprint }, exactArtifact: true };
};

// MiniCPM5's structural fingerprint (support.ts isMiniCPM5Config): a llama-typed 1B checkpoint.
const miniCpm5 = { model_type: "llama", hidden_size: 1536, num_hidden_layers: 24, num_attention_heads: 16, num_key_value_heads: 2,
  head_dim: 128, vocab_size: 130560, intermediate_size: 4096, rms_norm_eps: 1e-6, rope_theta: 1e6, max_position_embeddings: 128,
  tie_word_embeddings: false, eos_token_id: 1 };

describe("chat generation defaults", () => {
  test("MiniCPM5 declares direct replies by default; a model that declares nothing keeps the template's default and the generic cap", async () => {
    const cpm = await config("minicpm5", miniCpm5);
    expect(generationDefaultsFor(resolveModelProfile(cpm.config))).toEqual({ enableThinking: false, noThinkTemperatureCap: 0.7 });
    const llama = await config("llama-defaults", { model_type: "llama", ...text });
    expect(generationDefaultsFor(resolveModelProfile(llama.config))).toBe(GENERIC_GENERATION_DEFAULTS);
    expect(GENERIC_GENERATION_DEFAULTS.enableThinking).toBeUndefined();
    // The one-line cap that applied to every model before it was declared.
    expect(GENERIC_GENERATION_DEFAULTS.noThinkTemperatureCap).toBe(0.7);
  });
});

describe("sentinel and media tokens", () => {
  const vocabulary = new Map<string, number>([["<|tool_call>", 48], ["<tool_call|>", 49], ["<|channel>", 100], ["<channel|>", 101],
    ["<|image|>", 258880], ["<|image>", 255999], ["<image|>", 258882], ["<|audio|>", 258881], ["<|audio>", 256000], ["<audio|>", 258883]]);
  const tokenizer = { encode: (value: string) => vocabulary.has(value) ? [vocabulary.get(value)!] : [1, 2] };

  test("the Gemma4 graph declares its marker tokens and image/audio soft tokens; other graphs declare none", async () => {
    const gemma = await config("gemma4-tokens", { model_type: "gemma4", ...text });
    const declared = resolveModelProfile(gemma.config);
    expect(resolveSentinelTokens(tokenizer, sentinelDeclarationFor(declared)!))
      .toEqual({ toolCallStart: 48, toolCallEnd: 49, channelStart: 100, channelEnd: 101 });
    expect(mediaTokenDeclarationFor(declared)).not.toBeNull();
    for (const [name, raw] of [["llama-tokens", { model_type: "llama", ...text }], ["qwen3-tokens", { model_type: "qwen3", ...text }], ["cpm-tokens", miniCpm5]] as const) {
      const other = resolveModelProfile((await config(name, raw)).config);
      expect(sentinelDeclarationFor(other)).toBeNull();
      expect(mediaTokenDeclarationFor(other)).toBeNull();
    }
  });

  test("a declared marker that is not one token in the tokenizer is refused, never guessed", () => {
    expect(() => resolveSentinelTokens({ encode: () => [1, 2] }, { toolCallStart: "a", toolCallEnd: "b", channelStart: "c", channelEnd: "d" }))
      .toThrow("not a single token");
  });

  test("soft-token ids come from the checkpoint's config first, the declared token text second, and are absent when neither supplies them", () => {
    const texts = { image: "<|image|>", begin: "<|image>", end: "<image|>" };
    expect(resolveVisionTokenIds({}, tokenizer, texts)).toEqual({ imageTokenId: 258880, boiTokenId: 255999, eoiTokenId: 258882 });
    expect(resolveVisionTokenIds({ image_token_id: 7, boi_token_id: 8 }, tokenizer, texts)).toEqual({ imageTokenId: 7, boiTokenId: 8, eoiTokenId: 258882 });
    expect(resolveVisionTokenIds({}, tokenizer, null)).toBeNull();
    expect(resolveVisionTokenIds({ image_token_id: 7 }, tokenizer, null)).toBeNull();
    const audio = { audio: "<|audio|>", begin: "<|audio>", end: "<audio|>" };
    expect(resolveAudioTokenIds({}, tokenizer, audio)).toBeNull();
    expect(resolveAudioTokenIds({ audio_config: {} }, tokenizer, audio)).toEqual({ audioTokenId: 258881, boaTokenId: 256000, eoaTokenId: 258883 });
    expect(resolveAudioTokenIds({ audio_config: {}, eoa_token_id: 9 }, tokenizer, audio)?.eoaTokenId).toBe(9);
  });
});

describe("chat template fallback", () => {
  test("only the profile that declares a renderer gets one for an artifact that ships no template", async () => {
    expect(chatTemplateFallbackFor(glmProfile())).not.toBeNull();
    const llama = resolveModelProfile((await config("llama-template", { model_type: "llama", ...text })).config);
    expect(chatTemplateFallbackFor(llama)).toBeNull();
    const dir = join(root, "bare");
    await Bun.$`mkdir -p ${dir}`.quiet();
    writeFileSync(join(dir, "tokenizer_config.json"), JSON.stringify({ bos_token: null, eos_token: "<|endoftext|>" }));
    const template = await loadModelChatTemplate(dir, glmProfile());
    expect(template.thinkingFormat).toBe("think-tag");
    expect(template.render([{ role: "user", content: "Hi" }])).toBe("[gMASK]<sop><|user|>Hi<|assistant|><think></think>");
    await expect(loadModelChatTemplate(dir, llama)).rejects.toThrow("no chat template found");
    await expect(ChatTemplate.load(dir)).rejects.toThrow("no chat template found");
  });
});
