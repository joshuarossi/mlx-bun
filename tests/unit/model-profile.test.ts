import { describe, expect, test } from "bun:test";
import type { ModelConfig } from "../../src/config";
import { createModel, MLX_MODEL_IMPLEMENTATIONS, type RuntimeModel } from "../../src/model/factory";
import { ModelImplementationRegistry, type ModelImplementation } from "../../src/model/implementation";
import { configFingerprint } from "../../src/model/fingerprint";
import type { Weights } from "../../src/weights";
import {
  BUILTIN_ARTIFACT_PROFILES,
  ENGINE_CAPABILITIES,
  externalArtifactFingerprint,
  resolveModelProfile,
  type ArtifactModelProfile,
  type ResolvedModelProfile,
} from "../../src/model/profile";

function config(modelType: string, overrides: Partial<ModelConfig> = {}): ModelConfig {
  return {
    modelDir: "/models/local-copy",
    modelType,
    architectures: [],
    dtype: "bfloat16",
    text: {
      hiddenSize: 5120,
      numHiddenLayers: 64,
      numAttentionHeads: 24,
      numKeyValueHeads: 4,
      headDim: 256,
      numGlobalKeyValueHeads: 4,
      globalHeadDim: 256,
      attentionKEqV: false,
      intermediateSize: 17408,
      hiddenActivation: "silu",
      rmsNormEps: 1e-6,
      vocabSize: 248320,
      maxPositionEmbeddings: 262144,
      slidingWindow: 0,
      layerTypes: Array.from({ length: 64 }, (_, layer) =>
        (layer + 1) % 4 === 0 ? "full_attention" : "linear_attention"),
      hiddenSizePerLayerInput: 0,
      vocabSizePerLayerInput: 248320,
      numKvSharedLayers: 0,
      enableMoeBlock: false,
      numExperts: 0,
      topKExperts: 0,
      moeIntermediateSize: 0,
      decoderSparseStep: 1,
      mlpOnlyLayers: [],
      normTopkProb: false,
      linearNumValueHeads: 48,
      linearNumKeyHeads: 16,
      linearKeyHeadDim: 128,
      linearValueHeadDim: 128,
      linearConvKernelDim: 4,
      fullAttentionInterval: 4,
      attnOutputGate: true,
      partialRotaryFactor: 0.25,
      ropeParameters: {},
      finalLogitSoftcapping: null,
      tieWordEmbeddings: false,
      bosTokenId: 248044,
      eosTokenId: [248046, 248044],
    },
    quantization: null,
    kvQuant: null,
    hasVisionSidecar: false,
    eosTokenIds: [248046, 248044],
    raw: { model_type: modelType },
    ...overrides,
  };
}

describe("external artifact identity", () => {
  test("uses the Hugging Face repo revision, not the relocatable local prefix", () => {
    const suffix = "models--mlx-community--Qwen3.8-27B-OptiQ-4bit/" +
      "snapshots/b04599de95d7a9bfbd7f208d347c0f10d9432a42";
    expect(externalArtifactFingerprint(`/a/cache/${suffix}`)).toBe(
      "hf:mlx-community/Qwen3.8-27B-OptiQ-4bit@b04599de95d7a9bfbd7f208d347c0f10d9432a42",
    );
    expect(externalArtifactFingerprint(`/another/cache/${suffix}`)).toBe(
      "hf:mlx-community/Qwen3.8-27B-OptiQ-4bit@b04599de95d7a9bfbd7f208d347c0f10d9432a42",
    );
  });

  test("does not pretend an arbitrary local directory or staged alias is exact", () => {
    expect(externalArtifactFingerprint("/models/Qwen3.8-27B-TQ")).toBeNull();
    expect(externalArtifactFingerprint(
      "/cache/models--mjriii--Qwen3.8-27B/snapshots/staged",
    )).toBeNull();
  });
});

describe("engine-owned quant implementations", () => {
  // Synthetic identities exercise selection without pretending to identify
  // Josh's private quant or to validate an optimized numerical implementation.
  const cfg = config("qwen3_5");
  const exact: ArtifactModelProfile = {
    id: "test-quant", artifactFingerprint: "sha256:test-quant",
    configFingerprint: configFingerprint(cfg),
    fidelity: { tier: "l3", oracle: null, claim: "measured" },
    requiredCapabilities: ["safetensors", "autoregressive", "qwen3.5-graph", "recurrent-state"],
    execution: { loader: "safetensors", graph: "qwen3.5", loop: "autoregressive",
      specialization: "artifact", implementation: "test-quant-optimized" },
  };
  const resolve = (fingerprint = exact.artifactFingerprint) => resolveModelProfile(cfg, {
    artifactFingerprint: fingerprint, artifactProfiles: [exact],
  });
  const implementation = (create: ModelImplementation<Weights, RuntimeModel>["create"]): ModelImplementation<Weights, RuntimeModel> => ({
    id: "test-quant-optimized", graph: "qwen3.5", loader: "safetensors", loop: "autoregressive", create,
  });

  test("the resident factory invokes the selected code with the original weights", () => {
    const weights = {} as Weights;
    const model = {} as RuntimeModel;
    const profile = resolve();
    let calls = 0;
    const registry = MLX_MODEL_IMPLEMENTATIONS.with(implementation((source, config, resolved) => {
      calls++;
      expect(source).toBe(weights);
      expect(config).toBe(cfg);
      expect(resolved).toBe(profile);
      return model;
    }));
    expect(createModel(weights, cfg, profile, registry)).toBe(model);
    expect(calls).toBe(1);
    expect(() => createModel(weights, cfg, profile)).toThrow(/unavailable implementation test-quant-optimized/);
  });

  test("another quant with the same config retains the family implementation", () => {
    const registry = MLX_MODEL_IMPLEMENTATIONS.with(implementation(() => { throw new Error("must not run"); }));
    const unknown = resolve("sha256:another-quant");
    expect(unknown.exactArtifact).toBe(false);
    expect(registry.select(cfg, unknown).id).toBe("qwen3.5");
    expect(registry.select(cfg, resolveModelProfile(cfg)).id).toBe("qwen3.5");
  });

  test("missing or incompatible exact code never falls back", () => {
    const profile = resolve();
    expect(() => MLX_MODEL_IMPLEMENTATIONS.select(cfg, profile)).toThrow(/unavailable.*refusing to fall back/);
    for (const mismatch of [{ graph: "qwen3" }, { loader: "colibri" }, { loop: "diffusion" }] as const) {
      const registry = MLX_MODEL_IMPLEMENTATIONS.with({
        ...implementation(() => { throw new Error("must not run"); }), ...mismatch,
      });
      expect(() => registry.select(cfg, profile)).toThrow(/incompatible.*refusing to fall back/);
    }
  });

  test("construction errors propagate without retrying the family constructor", () => {
    const failure = new Error("incompatible packed tensor layout");
    const registry = MLX_MODEL_IMPLEMENTATIONS.with(implementation(() => { throw failure; }));
    expect(() => createModel({} as Weights, cfg, resolve(), registry)).toThrow(failure);
  });

  test("registry composition rejects ambiguous IDs and snapshots the selected binding", () => {
    const original = {} as RuntimeModel;
    const entry = { ...implementation(() => original) };
    const registry = new ModelImplementationRegistry([entry]);
    const selected = registry.select(cfg, resolve());
    entry.create = () => { throw new Error("later replacement"); };
    entry.graph = "qwen3";
    expect(selected.create({} as Weights, cfg, resolve())).toBe(original);
    expect(selected.graph).toBe("qwen3.5");
    expect(Object.isFrozen(selected)).toBe(true);
    expect(() => registry.with(entry)).toThrow(/duplicate model implementation/);
    expect(() => new ModelImplementationRegistry([{ ...entry, id: " " }])).toThrow(/must not be empty/);
  });

  test("a supplied profile cannot bypass exact identity or config guards", () => {
    const resolved = resolve();
    const registry = MLX_MODEL_IMPLEMENTATIONS.with(implementation(() => { throw new Error("must not run"); }));
    const invalid: ResolvedModelProfile[] = [
      { ...resolved, exactArtifact: false },
      { ...resolved, artifact: { ...resolved.artifact, fingerprint: "sha256:another-quant" } },
      { ...resolved, profile: { ...resolved.profile, configFingerprint: "wrong" } },
    ];
    for (const profile of invalid)
      expect(() => registry.select(cfg, profile)).toThrow(/does not match artifact/);
  });

  test("named quant code requires an exact artifact declaration", () => {
    const family = resolveModelProfile(cfg);
    const forged: ResolvedModelProfile = { ...family, profile: {
      ...family.profile, execution: { ...family.profile.execution, implementation: "test-quant-optimized" },
    } };
    expect(() => MLX_MODEL_IMPLEMENTATIONS.select(cfg, forged)).toThrow(/bind a named implementation to an exact artifact/);
    expect(() => resolveModelProfile(cfg, {
      artifactFingerprint: exact.artifactFingerprint,
      artifactProfiles: [{ ...exact, execution: { ...exact.execution, implementation: " " } }],
    })).toThrow(/bind a named implementation to an exact artifact/);
  });
});

describe("declared model profiles", () => {
  test("an exact artifact declaration outranks the family profile", () => {
    const cfg = config("qwen3_5");
    const artifactFingerprint = "sha256:qwen-test-artifact";
    const exact: ArtifactModelProfile = {
      id: "qwen-test-exact",
      artifactFingerprint,
      configFingerprint: configFingerprint(cfg),
      fidelity: { tier: "l3", oracle: null, claim: "measured" },
      requiredCapabilities: [
        "safetensors", "autoregressive", "qwen3.5-graph", "recurrent-state",
      ],
      execution: {
        loader: "safetensors",
        graph: "qwen3.5",
        loop: "autoregressive",
        specialization: "artifact",
      },
    };

    const resolved = resolveModelProfile(cfg, {
      artifactFingerprint,
      artifactProfiles: [exact],
    });

    expect(resolved.profile.id).toBe("qwen-test-exact");
    expect(resolved.exactArtifact).toBe(true);
    expect(resolved.artifact.fingerprint).toBe(artifactFingerprint);
    expect(resolved.profile.execution.specialization).toBe("artifact");
    expect(Object.isFrozen(resolved)).toBe(true);
    expect(Object.isFrozen(resolved.profile)).toBe(true);
    expect(Object.isFrozen(resolved.profile.fidelity)).toBe(true);
    expect(Object.isFrozen(resolved.profile.requiredCapabilities)).toBe(true);
    expect(Object.isFrozen(resolved.profile.execution)).toBe(true);
  });

  test("an exact match with a missing capability rejects instead of downgrading", () => {
    const cfg = config("qwen3_5");
    const exact: ArtifactModelProfile = {
      id: "qwen-needs-native-mtp",
      artifactFingerprint: "sha256:qwen-needs-mtp",
      configFingerprint: configFingerprint(cfg),
      fidelity: { tier: "l3", oracle: null, claim: "measured" },
      requiredCapabilities: [
        "safetensors", "autoregressive", "qwen3.5-graph", "recurrent-state", "native-mtp",
      ],
      execution: {
        loader: "safetensors",
        graph: "qwen3.5",
        loop: "autoregressive",
        specialization: "artifact",
      },
    };

    expect(() => resolveModelProfile(cfg, {
      artifactFingerprint: exact.artifactFingerprint,
      artifactProfiles: [exact],
      engineCapabilities: ENGINE_CAPABILITIES.filter((cap) => cap !== "native-mtp"),
    })).toThrow(/qwen-needs-native-mtp.*native-mtp.*refusing to fall back/s);
  });

  test("an exact fingerprint with the wrong config rejects instead of falling back", () => {
    const cfg = config("qwen3_5");
    const exact: ArtifactModelProfile = {
      id: "wrong-config",
      artifactFingerprint: "sha256:wrong-config",
      configFingerprint: "0000000000000000",
      fidelity: { tier: "l1", oracle: "mlx-lm", claim: "bit-exact" },
      requiredCapabilities: [
        "safetensors", "autoregressive", "qwen3.5-graph", "recurrent-state",
      ],
      execution: {
        loader: "safetensors",
        graph: "qwen3.5",
        loop: "autoregressive",
        specialization: "artifact",
      },
    };

    expect(() => resolveModelProfile(cfg, {
      artifactFingerprint: exact.artifactFingerprint,
      artifactProfiles: [exact],
    })).toThrow(/wrong-config.*config fingerprint.*refusing to fall back/s);
  });

  test("a Qwen hybrid without an exact declaration uses its dedicated family path", () => {
    const resolved = resolveModelProfile(config("qwen3_5"));
    expect(resolved.exactArtifact).toBe(false);
    expect(resolved.profile.id).toBe("qwen3.5-dedicated");
    expect(resolved.profile.execution).toEqual({
      loader: "safetensors",
      graph: "qwen3.5",
      loop: "autoregressive",
      specialization: "dedicated",
    });
  });

  test("an ordinary supported architecture retains the universal fallback", () => {
    const cfg = config("mistral", {
      raw: {
        model_type: "mistral",
        hidden_size: 2048,
        num_hidden_layers: 16,
        num_attention_heads: 32,
        num_key_value_heads: 8,
        head_dim: 64,
        intermediate_size: 8192,
        rms_norm_eps: 1e-5,
        vocab_size: 128256,
        rope_theta: 500000,
      },
    });
    const resolved = resolveModelProfile(cfg);
    expect(resolved.profile.id).toBe("universal-dense");
    expect(resolved.profile.execution.specialization).toBe("generic");
  });

  test("the factory refuses a profile resolved for another config", () => {
    const cfg = config("qwen3_5");
    const resolved = resolveModelProfile(cfg);
    const changed = config("qwen3_5", {
      text: { ...cfg.text, hiddenSize: cfg.text.hiddenSize + 1 },
    });
    expect(() => createModel(null as unknown as Weights, changed, resolved))
      .toThrow(/qwen3\.5-dedicated was resolved for config/);
  });

  test("the shipped exact declarations pin the Qwen and Colibri artifacts", () => {
    expect(BUILTIN_ARTIFACT_PROFILES.map((profile) => profile.id)).toEqual([
      "qwen3.8-27b-optiq-4bit",
      "glm5.2-colibri-int4-int8-mtp",
    ]);
    expect(BUILTIN_ARTIFACT_PROFILES.every((profile) =>
      profile.artifactFingerprint.startsWith("hf:"))).toBe(true);
  });
});
