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
import { BUILTIN_ARTIFACT_PROFILES, embeddingDeclarationFor, resolveModelProfile, type ResolvedModelProfile } from "../../src/models/profile";
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
