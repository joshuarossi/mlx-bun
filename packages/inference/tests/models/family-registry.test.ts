import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { loadModelConfig, type ModelConfig } from "../../src/artifacts/config";
import {
  type ArtifactModelProfile, chatTemplateFallbackFor, embeddingDeclarationFor, generationDefaultsFor, mediaTokenDeclarationFor, resolveModelProfile,
  sentinelDeclarationFor, trainingDefaultsFor,
} from "../../src/models/profile";
import { isEmbeddingModelType, isSupportedModelConfig, isTranscriptionModelType, supportTier } from "../../src/models/support";
import { ENGINE_CAPABILITIES, MODEL_FAMILIES, familyForGraph, familyOf, familyOfModelType } from "../../src/models/families";
import { configFingerprint } from "../../src/artifacts/fingerprint";
import { fit } from "../../src/execution/fit";
import { kvGeometry, sdpaFallbackBytes } from "../../src/state/kv-scheme";

const root = mkdtempSync(join(tmpdir(), "mlx-family-registry-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const text = { hidden_size: 64, num_hidden_layers: 2, num_attention_heads: 2, num_key_value_heads: 1, head_dim: 32, vocab_size: 64,
  intermediate_size: 64, rms_norm_eps: 1e-6, rope_theta: 1e6, max_position_embeddings: 128, tie_word_embeddings: true, eos_token_id: 1 };
const linear = { linear_num_value_heads: 4, linear_num_key_heads: 2, linear_key_head_dim: 16, linear_value_head_dim: 16,
  linear_conv_kernel_dim: 4, full_attention_interval: 2, layer_types: ["linear_attention", "full_attention"] };

/** MiniCPM5's structural fingerprint: a llama-typed 1B checkpoint. */
const miniCpm5 = { model_type: "llama", hidden_size: 1536, num_hidden_layers: 24, num_attention_heads: 16, num_key_value_heads: 2,
  head_dim: 128, vocab_size: 130560, intermediate_size: 4096, rms_norm_eps: 1e-6, rope_theta: 1e6, max_position_embeddings: 128,
  tie_word_embeddings: false, eos_token_id: 1 };

const glm52 = (() => {
  const layers = 78;
  return {
    model_type: "glm_moe_dsa", architectures: ["GlmMoeDsaForCausalLM"], dtype: "bfloat16", hidden_size: 6144, num_hidden_layers: layers,
    num_attention_heads: 64, num_key_value_heads: 64, q_lora_rank: 2048, kv_lora_rank: 512, qk_nope_head_dim: 192, qk_rope_head_dim: 64,
    qk_head_dim: 256, v_head_dim: 256, first_k_dense_replace: 3, intermediate_size: 12288, moe_intermediate_size: 2048, n_routed_experts: 256,
    num_experts_per_tok: 8, n_shared_experts: 1, n_group: 1, topk_group: 1, norm_topk_prob: true, routed_scaling_factor: 2.5,
    hidden_act: "silu", rms_norm_eps: 1e-5, rope_parameters: { rope_theta: 8_000_000, rope_type: "default" }, rope_interleave: true,
    vocab_size: 154880, max_position_embeddings: 1_048_576, index_topk: 2048, index_n_heads: 32, index_head_dim: 128,
    indexer_rope_interleave: true, indexer_types: Array.from({ length: layers }, (_, layer) => (layer < 3 || (layer - 2) % 4 === 0 ? "full" : "shared")),
    num_nextn_predict_layers: 1, index_share_for_mtp_iteration: true, tie_word_embeddings: false, bos_token_id: null, pad_token_id: 154820,
    eos_token_id: [154820, 154827], quantization_config: { quant_method: "fp8", fmt: "e4m3", weight_block_size: [128, 128] },
  };
})();

/** One config per family and per rule that separates two families (a shared model_type, an unsupported
 * variant, a malformed field). */
const FIXTURES: Record<string, Record<string, unknown>> = {
  "gemma4": { model_type: "gemma4", text_config: { ...text, layer_types: ["sliding_attention", "full_attention"], sliding_window: 16 } },
  "gemma4-text": { model_type: "gemma4_text", ...text, layer_types: ["sliding_attention", "full_attention"], sliding_window: 16 },
  "gemma4-drafter": { model_type: "gemma4_assistant", ...text },
  "diffusion-gemma": { model_type: "diffusion_gemma", canvas_length: 32, eos_token_id: 1 },
  "qwen3.5": { model_type: "qwen3_5", text_config: { ...text, ...linear } },
  "qwen3.5-text": { model_type: "qwen3_5_text", ...text, ...linear },
  "qwen3.5-moe-variant": { model_type: "qwen3_5", text_config: { ...text, ...linear, num_experts: 4, num_experts_per_tok: 2 } },
  "qwen3.5-mtp-head": { model_type: "qwen3_5_mtp", ...text, ...linear },
  "qwen3.5-unverified-gate": { model_type: "qwen3_5", text_config: { ...text, ...linear, output_gate_type: "other" } },
  "qwen3": { model_type: "qwen3", ...text },
  "qwen3-moe": { model_type: "qwen3_moe", ...text, num_experts: 4, num_experts_per_tok: 2, moe_intermediate_size: 32 },
  "glm5.2": glm52,
  "whisper": { model_type: "whisper", n_mels: 80, n_audio_ctx: 1500, n_audio_state: 384, n_audio_head: 6, n_audio_layer: 4, n_vocab: 51865,
    n_text_ctx: 448, n_text_state: 384, n_text_head: 6, n_text_layer: 4 },
  "whisper-hf-format": { model_type: "whisper", d_model: 384, vocab_size: 51865 },
  "minicpm5": miniCpm5,
  "minicpm5-one-dimension-off": { ...miniCpm5, hidden_size: 1537 },
  "llama": { model_type: "llama", ...text },
  "mistral-remap": { model_type: "mistral", ...text },
  "gemma2": { model_type: "gemma2", ...text, sliding_window: 16, head_dim: 32, query_pre_attn_scalar: 32, final_logit_softcapping: 30, attn_logit_softcapping: 50 },
  "unsupported": { model_type: "not_a_real_architecture", ...text },
};

async function loadFixture(name: string, raw: Record<string, unknown>): Promise<ModelConfig> {
  const dir = join(root, name);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "config.json"), JSON.stringify(raw));
  if (name === "glm5.2") writeFileSync(join(dir, "generation_config.json"), JSON.stringify({ eos_token_id: [154827, 154829], pad_token_id: 154820 }));
  return loadModelConfig(dir);
}

/** The whole parsed config, minus where it was read from. */
function configDigest(config: ModelConfig): string {
  const { modelDir: _, ...rest } = config;
  return new Bun.CryptoHasher("sha256").update(JSON.stringify(rest)).digest("hex").slice(0, 12);
}

/** Everything the model layer resolves for a config, on one line. */
function resolution(config: ModelConfig): string {
  const machine = { name: "fixed", ramBytes: 32 * 2 ** 30, bandwidthGBs: 400 };
  const parts = [`cfg=${configDigest(config)}`, `record=${supportTier(config.modelType)}`,
    `kv=${JSON.stringify(kvGeometry(config))}`, `sdpa=${sdpaFallbackBytes(config, 2048, 8192)}`,
    `fit=${fit(config, 1e9, 4096, machine, 2048, 5e8).predictedDecodeTps.toFixed(3)}`];
  try {
    const resolved = resolveModelProfile(config);
    const { profile } = resolved;
    const { execution } = profile;
    const implementation = execution.implementation ?? (execution.specialization === "generated" ? `${execution.graph}-generated` : execution.graph);
    const sentinels = sentinelDeclarationFor(resolved), media = mediaTokenDeclarationFor(resolved), embedding = embeddingDeclarationFor(resolved);
    parts.push(
      `profile=${profile.id}`, `graph=${execution.graph}`, `${execution.loader}/${execution.loop}/${execution.specialization}`, `impl=${implementation}`,
      `${profile.fidelity.tier}:${profile.fidelity.oracle}`, `caps=${profile.requiredCapabilities.join(",")}`, `exact=${resolved.exactArtifact}`,
      `train=${trainingDefaultsFor(resolved).maxSeqLength}`, `gen=${JSON.stringify(generationDefaultsFor(resolved))}`,
      `embed=${embedding?.terminator ?? "-"}`, `sentinels=${sentinels !== null}`, `media=${media !== null}`,
      `template=${chatTemplateFallbackFor(resolved)?.thinkingFormat ?? "-"}`,
    );
  } catch (error) { parts.push(`error=${(error as Error).message}`); }
  return parts.join(" ");
}

describe("family resolution", () => {
  test("configs of every supported family resolve as they did before the registry", async () => {
    const actual: Record<string, string> = {};
    for (const [name, raw] of Object.entries(FIXTURES)) {
      try { actual[name] = resolution(await loadFixture(name, raw)); }
      catch (error) { actual[name] = `load error=${(error as Error).message}`; }
    }
    expect(actual).toEqual(EXPECTED_FIXTURES);
  });

  const hub = join(homedir(), ".cache/huggingface/hub");
  const snapshots = existsSync(hub) ? readdirSync(hub).filter(name => name.startsWith("models--")).flatMap(name => {
    const snapshotDir = join(hub, name, "snapshots");
    const revision = existsSync(snapshotDir) ? readdirSync(snapshotDir).find(entry => existsSync(join(snapshotDir, entry, "config.json"))) : undefined;
    return revision ? [{ repo: `${name.slice("models--".length).replace("--", "/")}@${revision.slice(0, 8)}`, dir: join(snapshotDir, revision) }] : [];
  }) : [];

  test("every local snapshot's config resolves as it did before the registry (skips models that are not downloaded)", async () => {
    const actual: Record<string, string> = {};
    for (const { repo, dir } of snapshots) {
      if (!(repo in EXPECTED_SNAPSHOTS)) continue;
      try { actual[repo] = resolution(await loadModelConfig(dir)); }
      catch (error) { actual[repo] = `load error=${(error as Error).message}`; }
    }
    expect(actual).toEqual(Object.fromEntries(Object.entries(EXPECTED_SNAPSHOTS).filter(([repo]) => repo in actual)));
  });

  test("the config-level and record-level answers agree", async () => {
    for (const [name, raw] of Object.entries(FIXTURES)) {
      let config: ModelConfig;
      try { config = await loadFixture(name, raw); } catch { continue; }
      let resolved = true;
      try { resolveModelProfile(config); } catch { resolved = false; }
      if (config.modelType.includes("assistant")) continue;
      expect(isSupportedModelConfig(config), name).toBe(resolved);
    }
  });
});

describe("profile declarations", () => {
  const artifact = "hf:example/model@" + "a".repeat(40);
  async function exact(name: string, raw: Record<string, unknown>, declare: (base: Pick<ArtifactModelProfile, "artifactFingerprint" | "configFingerprint">) => ArtifactModelProfile) {
    const config = await loadFixture(name, raw);
    const profile = declare({ artifactFingerprint: artifact, configFingerprint: configFingerprint(config) });
    return () => resolveModelProfile(config, { artifactFingerprint: artifact, artifactProfiles: [profile] });
  }
  const qwen3Exact = (base: Pick<ArtifactModelProfile, "artifactFingerprint" | "configFingerprint">, execution: Partial<ArtifactModelProfile["execution"]> = {},
    rest: Partial<ArtifactModelProfile> = {}): ArtifactModelProfile => ({
    id: "example", ...base, fidelity: { tier: "l1", oracle: "mlx-lm", claim: "bit-exact" },
    requiredCapabilities: ["safetensors", "autoregressive", "qwen3-graph"],
    execution: { loader: "safetensors", graph: "qwen3", loop: "autoregressive", specialization: "artifact", ...execution }, ...rest,
  });

  test("an exact artifact declaration outranks the family profile and keeps its own identity", async () => {
    const resolved = (await exact("qwen3", FIXTURES.qwen3!, base => qwen3Exact(base)))();
    expect(resolved.exactArtifact).toBe(true);
    expect(resolved.profile.id).toBe("example");
    expect(resolved.profile.execution.specialization).toBe("artifact");
  });

  test("a declaration must match the artifact's config and a graph that accepts it, and never falls back", async () => {
    const config = await loadFixture("qwen3", FIXTURES.qwen3!);
    const declared = qwen3Exact({ artifactFingerprint: artifact, configFingerprint: "0".repeat(16) });
    expect(() => resolveModelProfile(config, { artifactFingerprint: artifact, artifactProfiles: [declared] })).toThrow("refusing to fall back");
    await expect((await exact("qwen3", FIXTURES.qwen3!, base => qwen3Exact(base, { graph: "gemma4" },
      { requiredCapabilities: ["safetensors", "autoregressive", "gemma4-graph"] })))).toThrow("incompatible with qwen3");
  });

  test("a declaration cannot compose a loader or loop its graph does not run, or claim another graph's oracle", async () => {
    await expect(await exact("qwen3", FIXTURES.qwen3!, base => qwen3Exact(base, { loader: "colibri" }))).toThrow("invalid execution composition");
    await expect(await exact("qwen3", FIXTURES.qwen3!, base => qwen3Exact(base, { loop: "diffusion" }))).toThrow("invalid execution composition");
    await expect(await exact("qwen3", FIXTURES.qwen3!, base => qwen3Exact(base, {}, { fidelity: { tier: "l1", oracle: "mlx-whisper", claim: "bit-exact" } })))
      .toThrow("invalid fidelity contract");
    await expect(await exact("qwen3", FIXTURES.qwen3!, base => qwen3Exact(base, {}, { requiredCapabilities: ["safetensors", "autoregressive"] })))
      .toThrow("does not declare execution capabilities: qwen3-graph");
  });

  test("a graph the engine lacks a capability for is refused, not substituted", async () => {
    const config = await loadFixture("qwen3", FIXTURES.qwen3!);
    expect(() => resolveModelProfile(config, { engineCapabilities: ["safetensors", "autoregressive"] })).toThrow("requires missing engine capabilities: qwen3-graph");
  });
});

describe("the family registry", () => {
  const loaded = async () => Object.fromEntries(await Promise.all(Object.entries(FIXTURES).map(async ([name, raw]) => {
    try { return [name, await loadFixture(name, raw)] as const; } catch { return [name, null] as const; }
  })));

  test("each graph is declared once and every declaration is well-formed", () => {
    const graphs = MODEL_FAMILIES.map(family => family.graph);
    expect(new Set(graphs).size).toBe(graphs.length);
    // The universal family comes last, so a targeted family always wins.
    expect(MODEL_FAMILIES.at(-1)!.tier).toBe("generic");
    expect(MODEL_FAMILIES.filter(family => family.tier === "generic")).toHaveLength(1);
    for (const family of MODEL_FAMILIES) {
      expect(familyForGraph(family.graph)).toBe(family);
      expect(family.tier === "targeted", family.graph).toBe(family.label !== undefined);
      for (const capability of family.capabilities) expect(ENGINE_CAPABILITIES).toContain(capability);
    }
  });

  test("one accepts rule per family: no config is accepted by two targeted families, and a targeted family outranks the universal one", async () => {
    for (const [name, config] of Object.entries(await loaded())) {
      if (!config) continue;
      const accepting = MODEL_FAMILIES.filter(family => { try { return family.accepts(config); } catch { return false; } });
      expect(accepting.filter(family => family.tier === "targeted").length, name).toBeLessThanOrEqual(1);
      if (accepting.length) expect(familyOf(config), name).toBe(accepting[0]!);
    }
  });

  test("a model_type shared by two families is told apart by the config, never by the repository name", async () => {
    const { minicpm5, "minicpm5-one-dimension-off": other } = await loaded();
    expect(familyOf(minicpm5!)!.graph).toBe("minicpm5");
    expect(familyOf(other!)!.graph).toBe("universal-dense");
    // A listing with only the model_type cannot tell them apart, so it reports what every llama is.
    expect(supportTier("llama")).toBe("generic");
    expect(familyOfModelType("llama")!.graph).toBe("universal-dense");
  });

  test("the roles a model_type plays come from its family's declarations", () => {
    expect(isEmbeddingModelType("qwen3")).toBe(true);
    expect(isTranscriptionModelType("whisper")).toBe(true);
    for (const type of ["llama", "qwen3_5", "qwen3_moe", "gemma4", "glm_moe_dsa", "diffusion_gemma"]) {
      expect(isEmbeddingModelType(type), type).toBe(false);
      expect(isTranscriptionModelType(type), type).toBe(false);
    }
    expect(supportTier("gemma4_assistant")).toBeNull();
    expect(supportTier("not_a_real_architecture")).toBeNull();
  });

  test("every family's record is native-free: importing the registry never loads MLX", () => {
    const transpiler = new Bun.Transpiler({ loader: "ts" });
    const seen = new Set<string>(), native: string[] = [];
    const visit = (file: string) => {
      if (seen.has(file)) return;
      seen.add(file);
      for (const { path } of transpiler.scanImports(readFileSync(file, "utf8"))) {
        if (path.startsWith("@mlx-bun/mlx")) native.push(`${file} -> ${path}`);
        else if (path.startsWith(".")) visit(existsSync(resolve(dirname(file), path) + ".ts") ? resolve(dirname(file), path) + ".ts" : resolve(dirname(file), path, "index.ts"));
      }
    };
    for (const entry of ["families", "profile", "support"]) visit(resolve(import.meta.dir, `../../src/models/${entry}.ts`));
    expect(native).toEqual([]);
    expect(seen.size).toBeGreaterThan(MODEL_FAMILIES.length);
  });
});

/** What the model layer resolved for each fixture on 3ea16429, before the family registry, from the same
 * `resolution` above: the parsed config's digest, the record-level tier, the KV geometry, the SDPA-fallback
 * bytes, the fit prediction, and the profile with every declaration read from it. */
const EXPECTED_FIXTURES: Record<string, string> = {
  "gemma4":
    "cfg=20705c7fac57 record=targeted kv={\"fullBytesPerToken\":128,\"slidingBytesPerToken\":128,\"linearStateBytes\":0,\"window\":16} sdpa=67108864 fit=327.827 profile=gemma4-dedicated graph=gemma4 safetensors/autoregressive/dedicated impl=gemma4 l1:mlx-lm caps=safetensors,autoregressive,gemma4-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=true media=true template=-",
  "gemma4-text":
    "cfg=0b78280bd1bf record=targeted kv={\"fullBytesPerToken\":128,\"slidingBytesPerToken\":128,\"linearStateBytes\":0,\"window\":16} sdpa=67108864 fit=327.827 profile=gemma4-dedicated graph=gemma4 safetensors/autoregressive/dedicated impl=gemma4 l1:mlx-lm caps=safetensors,autoregressive,gemma4-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=true media=true template=-",
  "gemma4-drafter":
    "cfg=59390c1b6d7c record=null kv={\"fullBytesPerToken\":256,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=67108864 fit=327.656 profile=gemma4-dedicated graph=gemma4 safetensors/autoregressive/dedicated impl=gemma4 l1:mlx-lm caps=safetensors,autoregressive,gemma4-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=true media=true template=-",
  "diffusion-gemma":
    "cfg=67be3b1ce912 record=targeted kv={\"fullBytesPerToken\":20480,\"slidingBytesPerToken\":204800,\"linearStateBytes\":0,\"window\":1024} sdpa=536870912 fit=368.551 profile=diffusion-gemma-dedicated graph=diffusion-gemma safetensors/diffusion/dedicated impl=diffusion-gemma l2:mlx-optiq caps=safetensors,diffusion,diffusion-gemma-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=true template=-",
  "qwen3.5":
    "cfg=f3b8072fdbe4 record=targeted kv={\"fullBytesPerToken\":128,\"slidingBytesPerToken\":0,\"linearStateBytes\":4864,\"window\":0} sdpa=67108864 fit=327.827 profile=qwen3.5-dedicated graph=qwen3.5 safetensors/autoregressive/dedicated impl=qwen3.5 l1:mlx-lm caps=safetensors,autoregressive,qwen3.5-graph,recurrent-state exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "qwen3.5-text":
    "cfg=070a009743f0 record=targeted kv={\"fullBytesPerToken\":128,\"slidingBytesPerToken\":0,\"linearStateBytes\":4864,\"window\":0} sdpa=67108864 fit=327.827 profile=qwen3.5-dedicated graph=qwen3.5 safetensors/autoregressive/dedicated impl=qwen3.5 l1:mlx-lm caps=safetensors,autoregressive,qwen3.5-graph,recurrent-state exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "qwen3.5-moe-variant":
    "cfg=fa7be7cd7d81 record=targeted kv={\"fullBytesPerToken\":128,\"slidingBytesPerToken\":0,\"linearStateBytes\":4864,\"window\":0} sdpa=67108864 fit=327.827 error=unsupported model_type \"qwen3_5\" — targeted: gemma4*, diffusion_gemma, glm_moe_dsa, qwen3_5, qwen3, qwen3_moe, whisper, MiniCPM5; generic (Tier-0): gemma, gemma2, glm4, granite, llama, olmo2, phi3, qwen2, qwen3, smollm3, starcoder2",
  "qwen3.5-mtp-head":
    "cfg=e8e8e513a383 record=null kv={\"fullBytesPerToken\":128,\"slidingBytesPerToken\":0,\"linearStateBytes\":4864,\"window\":0} sdpa=67108864 fit=327.827 error=unsupported model_type \"qwen3_5_mtp\" — targeted: gemma4*, diffusion_gemma, glm_moe_dsa, qwen3_5, qwen3, qwen3_moe, whisper, MiniCPM5; generic (Tier-0): gemma, gemma2, glm4, granite, llama, olmo2, phi3, qwen2, qwen3, smollm3, starcoder2",
  "qwen3.5-unverified-gate":
    "load error=qwen3_5: unverified output_gate_type \"other\" (only \"swish\" is verified to mean the standard sigmoid output gate)",
  "qwen3":
    "cfg=b9915a26afb7 record=targeted kv={\"fullBytesPerToken\":256,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=67108864 fit=327.656 profile=qwen3-dedicated graph=qwen3 safetensors/autoregressive/dedicated impl=qwen3 l1:mlx-lm caps=safetensors,autoregressive,qwen3-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=<|endoftext|> sentinels=false media=false template=-",
  "qwen3-moe":
    "cfg=050eaab11f7e record=targeted kv={\"fullBytesPerToken\":256,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=67108864 fit=327.656 profile=qwen3-moe-dedicated graph=qwen3-moe safetensors/autoregressive/dedicated impl=qwen3-moe l1:mlx-lm caps=safetensors,autoregressive,qwen3-moe-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "glm5.2":
    "cfg=a6975f9e2b22 record=targeted kv={\"fullBytesPerToken\":5111808,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=2147483648 fit=14.170 profile=glm5.2-colibri graph=glm5.2 colibri/autoregressive/dedicated impl=glm5.2 l3:null caps=colibri-container,autoregressive,glm5.2-graph,streamed-experts exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=think-tag",
  "whisper":
    "cfg=be319d2e31f0 record=targeted kv={\"fullBytesPerToken\":0,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=328.000 profile=whisper-dedicated graph=whisper safetensors/encoder-decoder/dedicated impl=whisper l1:mlx-whisper caps=safetensors,encoder-decoder,whisper-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "whisper-hf-format":
    "cfg=60bb46ee9a70 record=targeted kv={\"fullBytesPerToken\":0,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=328.000 error=unsupported model_type \"whisper\" — targeted: gemma4*, diffusion_gemma, glm_moe_dsa, qwen3_5, qwen3, qwen3_moe, whisper, MiniCPM5; generic (Tier-0): gemma, gemma2, glm4, granite, llama, olmo2, phi3, qwen2, qwen3, smollm3, starcoder2",
  "minicpm5":
    "cfg=25ae5f4169ce record=generic kv={\"fullBytesPerToken\":24576,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=298.002 profile=minicpm5-dedicated graph=minicpm5 safetensors/autoregressive/dedicated impl=minicpm5 l1:mlx-lm caps=safetensors,autoregressive,minicpm5-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7,\"enableThinking\":false} embed=- sentinels=false media=false template=-",
  "minicpm5-one-dimension-off":
    "cfg=5f7d7880cbe1 record=generic kv={\"fullBytesPerToken\":24576,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=298.002 profile=universal-dense graph=universal-dense safetensors/autoregressive/generic impl=universal-dense l1:mlx-lm caps=safetensors,autoregressive,universal-dense-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "llama":
    "cfg=f7f8a8d51678 record=generic kv={\"fullBytesPerToken\":256,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=67108864 fit=327.656 profile=universal-dense graph=universal-dense safetensors/autoregressive/generic impl=universal-dense l1:mlx-lm caps=safetensors,autoregressive,universal-dense-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "mistral-remap":
    "cfg=d4e9439a10a6 record=generic kv={\"fullBytesPerToken\":256,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=67108864 fit=327.656 profile=universal-dense graph=universal-dense safetensors/autoregressive/generic impl=universal-dense l1:mlx-lm caps=safetensors,autoregressive,universal-dense-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "gemma2":
    "cfg=7acea78ade47 record=generic kv={\"fullBytesPerToken\":256,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":16} sdpa=67108864 fit=327.656 profile=universal-dense graph=universal-dense safetensors/autoregressive/generic impl=universal-dense l1:mlx-lm caps=safetensors,autoregressive,universal-dense-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "unsupported":
    "cfg=baaba3c3af21 record=null kv={\"fullBytesPerToken\":256,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=67108864 fit=327.656 error=unsupported model_type \"not_a_real_architecture\" — targeted: gemma4*, diffusion_gemma, glm_moe_dsa, qwen3_5, qwen3, qwen3_moe, whisper, MiniCPM5; generic (Tier-0): gemma, gemma2, glm4, granite, llama, olmo2, phi3, qwen2, qwen3, smollm3, starcoder2",
};
/** The same for the first snapshot of each model in the local Hugging Face cache, keyed by repository and
 * revision. A model that is not downloaded (or another revision) is skipped. */
const EXPECTED_SNAPSHOTS: Record<string, string> = {
  "mlx-community/Qwen3.5-0.8B-OptiQ-4bit@a1207d2d":
    "cfg=6ec0fdc34b37 record=targeted kv={\"fullBytesPerToken\":12288,\"slidingBytesPerToken\":0,\"linearStateBytes\":19537920,\"window\":0} sdpa=268435456 fit=306.579 profile=qwen3.5-dedicated graph=qwen3.5 safetensors/autoregressive/dedicated impl=qwen3.5 l1:mlx-lm caps=safetensors,autoregressive,qwen3.5-graph,recurrent-state exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "mlx-community/Llama-3.2-3B-Instruct-4bit@7f0dc925":
    "cfg=bafa0435470d record=generic kv={\"fullBytesPerToken\":114688,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=223.165 profile=universal-dense graph=universal-dense safetensors/autoregressive/generic impl=universal-dense l1:mlx-lm caps=safetensors,autoregressive,universal-dense-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "mlx-community/diffusiongemma-26B-A4B-it-OptiQ-4bit@c42b77a0":
    "cfg=58cf47bfc11f record=targeted kv={\"fullBytesPerToken\":20480,\"slidingBytesPerToken\":204800,\"linearStateBytes\":0,\"window\":1024} sdpa=536870912 fit=368.551 profile=diffusion-gemma-dedicated graph=diffusion-gemma safetensors/diffusion/dedicated impl=diffusion-gemma l2:mlx-optiq caps=safetensors,diffusion,diffusion-gemma-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=true template=-",
  "mjriii/Qwen3.8-27B-MTP-TQ-bf16@staged":
    "cfg=cd002d6f767f record=null kv={\"fullBytesPerToken\":65536,\"slidingBytesPerToken\":0,\"linearStateBytes\":153944064,\"window\":0} sdpa=805306368 fit=230.599 error=unsupported model_type \"qwen3_5_mtp\" — targeted: gemma4*, diffusion_gemma, glm_moe_dsa, qwen3_5, qwen3, qwen3_moe, whisper, MiniCPM5; generic (Tier-0): gemma, gemma2, glm4, granite, llama, olmo2, phi3, qwen2, qwen3, smollm3, starcoder2",
  "mlx-community/gemma-4-12B-it-OptiQ-4bit@b617be81":
    "cfg=008dfd4f074a record=targeted kv={\"fullBytesPerToken\":16384,\"slidingBytesPerToken\":327680,\"linearStateBytes\":0,\"window\":1024} sdpa=536870912 fit=233.843 profile=gemma4-generated graph=gemma4 safetensors/autoregressive/generated impl=gemma4-generated l1:mlx-lm caps=safetensors,autoregressive,gemma4-graph,generated-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=true media=true template=-",
  "mlx-community/MiniCPM5-1B-OptiQ-4bit@fce82a8b":
    "cfg=6ba1d3ce36a6 record=generic kv={\"fullBytesPerToken\":24576,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=298.002 profile=minicpm5-dedicated graph=minicpm5 safetensors/autoregressive/dedicated impl=minicpm5 l1:mlx-lm caps=safetensors,autoregressive,minicpm5-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7,\"enableThinking\":false} embed=- sentinels=false media=false template=-",
  "mlx-community/gemma-4-E4B-it-assistant-bf16@844e008e":
    "cfg=362b80cb8324 record=null kv={\"fullBytesPerToken\":4096,\"slidingBytesPerToken\":6144,\"linearStateBytes\":0,\"window\":512} sdpa=134217728 fit=321.593 profile=gemma4-dedicated graph=gemma4 safetensors/autoregressive/dedicated impl=gemma4 l1:mlx-lm caps=safetensors,autoregressive,gemma4-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=true media=true template=-",
  "mlx-community/gemma-4-e4b-it-OptiQ-4bit@98d7dc6a":
    "cfg=d97ddeea343b record=targeted kv={\"fullBytesPerToken\":28672,\"slidingBytesPerToken\":71680,\"linearStateBytes\":0,\"window\":512} sdpa=268435456 fit=284.194 profile=gemma4-generated graph=gemma4 safetensors/autoregressive/generated impl=gemma4-generated l1:mlx-lm caps=safetensors,autoregressive,gemma4-graph,generated-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=true media=true template=-",
  "mlx-community/gemma-4-e2b-it-qat-OptiQ-4bit@b0162532":
    "cfg=9727792633a9 record=targeted kv={\"fullBytesPerToken\":14336,\"slidingBytesPerToken\":28672,\"linearStateBytes\":0,\"window\":512} sdpa=268435456 fit=305.571 profile=gemma4-dedicated graph=gemma4 safetensors/autoregressive/dedicated impl=gemma4 l1:mlx-lm caps=safetensors,autoregressive,gemma4-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=true media=true template=-",
  "openbmb/MiniCPM5-2B@abe115e8":
    "cfg=9173ccf60500 record=generic kv={\"fullBytesPerToken\":43008,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=278.873 profile=universal-dense graph=universal-dense safetensors/autoregressive/generic impl=universal-dense l1:mlx-lm caps=safetensors,autoregressive,universal-dense-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "mlx-bun/Qwen3.8-27B-MTP-folded-rtn4-g64-rd@local":
    "cfg=73e53a893981 record=null kv={\"fullBytesPerToken\":65536,\"slidingBytesPerToken\":0,\"linearStateBytes\":153944064,\"window\":0} sdpa=805306368 fit=230.599 error=unsupported model_type \"qwen3_5_mtp\" — targeted: gemma4*, diffusion_gemma, glm_moe_dsa, qwen3_5, qwen3, qwen3_moe, whisper, MiniCPM5; generic (Tier-0): gemma, gemma2, glm4, granite, llama, olmo2, phi3, qwen2, qwen3, smollm3, starcoder2",
  "mlx-community/Qwen3-4B-Instruct-2507-4bit@50d42775":
    "cfg=b05dd738e495 record=targeted kv={\"fullBytesPerToken\":147456,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=204.491 profile=qwen3-dedicated graph=qwen3 safetensors/autoregressive/dedicated impl=qwen3 l1:mlx-lm caps=safetensors,autoregressive,qwen3-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=<|endoftext|> sentinels=false media=false template=-",
  "mjriii/Qwen3.8-27B-TQ@staged":
    "cfg=cb2a69e5c503 record=targeted kv={\"fullBytesPerToken\":65536,\"slidingBytesPerToken\":0,\"linearStateBytes\":153944064,\"window\":0} sdpa=805306368 fit=230.599 profile=qwen3.5-dedicated graph=qwen3.5 safetensors/autoregressive/dedicated impl=qwen3.5 l1:mlx-lm caps=safetensors,autoregressive,qwen3.5-graph,recurrent-state exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit@dbfd2a77":
    "cfg=1a8b12070ab3 record=targeted kv={\"fullBytesPerToken\":20480,\"slidingBytesPerToken\":204800,\"linearStateBytes\":0,\"window\":1024} sdpa=536870912 fit=368.551 profile=gemma4-generated graph=gemma4 safetensors/autoregressive/generated impl=gemma4-generated l1:mlx-lm caps=safetensors,autoregressive,gemma4-graph,generated-graph exact=false train=8192 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=true media=true template=-",
  "mjriii/Qwen3.8-27B@staged":
    "cfg=458e3d550642 record=targeted kv={\"fullBytesPerToken\":65536,\"slidingBytesPerToken\":0,\"linearStateBytes\":153944064,\"window\":0} sdpa=805306368 fit=230.599 profile=qwen3.5-dedicated graph=qwen3.5 safetensors/autoregressive/dedicated impl=qwen3.5 l1:mlx-lm caps=safetensors,autoregressive,qwen3.5-graph,recurrent-state exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "mlx-bun/qwen38-trellis-global-exit5-h39-q4b-v2@local":
    "cfg=acc2d7f29678 record=targeted kv={\"fullBytesPerToken\":65536,\"slidingBytesPerToken\":0,\"linearStateBytes\":153944064,\"window\":0} sdpa=805306368 fit=230.599 profile=qwen3.5-dedicated graph=qwen3.5 safetensors/autoregressive/dedicated impl=qwen3.5 l1:mlx-lm caps=safetensors,autoregressive,qwen3.5-graph,recurrent-state exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "mlx-community/whisper-large-v3-turbo@a4aaeec0":
    "cfg=0908b21a332f record=targeted kv={\"fullBytesPerToken\":0,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=328.000 profile=whisper-dedicated graph=whisper safetensors/encoder-decoder/dedicated impl=whisper l1:mlx-whisper caps=safetensors,encoder-decoder,whisper-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "mlx-community/Qwen2.5-0.5B-Instruct-4bit@a5339a41":
    "cfg=72550d5cba98 record=generic kv={\"fullBytesPerToken\":12288,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":32768} sdpa=0 fit=312.282 profile=universal-dense graph=universal-dense safetensors/autoregressive/generic impl=universal-dense l1:mlx-lm caps=safetensors,autoregressive,universal-dense-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
  "mlx-community/Qwen3-Embedding-4B-4bit-DWQ@b5d88f1f":
    "cfg=ef42202d87fd record=targeted kv={\"fullBytesPerToken\":147456,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=204.491 profile=qwen3-dedicated graph=qwen3 safetensors/autoregressive/dedicated impl=qwen3 l1:mlx-lm caps=safetensors,autoregressive,qwen3-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=<|endoftext|> sentinels=false media=false template=-",
  "openai/whisper-large-v3-turbo@41f01f3f":
    "cfg=d93678af0f8d record=targeted kv={\"fullBytesPerToken\":null,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":0} sdpa=0 fit=NaN error=unsupported model_type \"whisper\" — targeted: gemma4*, diffusion_gemma, glm_moe_dsa, qwen3_5, qwen3, qwen3_moe, whisper, MiniCPM5; generic (Tier-0): gemma, gemma2, glm4, granite, llama, olmo2, phi3, qwen2, qwen3, smollm3, starcoder2",
  "mlx-community/gemma-2-2b-it-4bit@2c715097":
    "cfg=c0010da6780c record=generic kv={\"fullBytesPerToken\":106496,\"slidingBytesPerToken\":0,\"linearStateBytes\":0,\"window\":4096} sdpa=268435456 fit=228.379 profile=universal-dense graph=universal-dense safetensors/autoregressive/generic impl=universal-dense l1:mlx-lm caps=safetensors,autoregressive,universal-dense-graph exact=false train=4096 gen={\"noThinkTemperatureCap\":0.7} embed=- sentinels=false media=false template=-",
};
