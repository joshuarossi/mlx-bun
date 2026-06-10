// Phase 8 LoRA hot-swap gates (OPT-IN slow tier — loads the e4b base):
//
//   MLX_BUN_TEST_LORA=1 bun test tests/lora.test.ts
//
// Opt-in for the same reason as parity-26b: bun test is one process and
// the default suite already holds ~16 GB of models; another 7 GB risks
// the uncatchable async GPU OOM (PLAN Phase 6 verification findings).
//
//  (1) FREE gate: adapter mounted but inactive, and active-at-scale-0,
//      must be BYTE-IDENTICAL to no adapter (tier a, toBe(0)).
//  (2) Adapter-applied logits bit-exact vs the mlx-lm oracle
//      (goldens regen: bun scripts/regen-lora-goldens.ts).
//  (3) A→B→A switching: each result identical to that adapter run in
//      isolation (same process, same loop shape ⇒ token-identical).

import { describe, expect, test } from "bun:test";
import { goldenAt } from "./goldens";

const E4B = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;
const optIn = process.env.MLX_BUN_TEST_LORA === "1";
const haveWeights = await Bun.file(`${E4B}/config.json`).exists();
const haveAdapters = await Bun.file("fixtures/adapters/upper/adapters.safetensors").exists();
const haveGoldens = await goldenAt("lora-upper.json").exists();

describe.skipIf(!optIn || !haveWeights || !haveAdapters)("LoRA hot-swap (e4b)", async () => {
  if (!optIn || !haveWeights || !haveAdapters) return;

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model, argmaxLastPosition, lastPositionLogits } =
    await import("../src/model/gemma4");
  const { AdapterManager } = await import("../src/lora");
  const { generate } = await import("../src/generate");

  const config = await loadModelConfig(E4B);
  const weights = await Weights.open(E4B);
  const model = new Gemma4Model(weights, config);
  const manager = new AdapterManager(model);

  const golden = haveGoldens
    ? ((await goldenAt("lora-upper.json").json()) as {
        prompt_ids: number[]; greedy_ids: number[];
      })
    : null;
  // Without goldens, fall back to a fixed token list for the structural tests.
  const promptIds = golden?.prompt_ids ?? [2, 105, 2364, 107, 1567, 506, 2390, 107];

  /** Single forward over a fresh cache → last-position logits (f32). */
  const forwardLogits = (adapters: string[]): Float32Array => {
    model.loraState.active = adapters;
    const cache = model.makeCache();
    try {
      const logits = model.forward(promptIds, cache);
      const out = lastPositionLogits(logits);
      logits.dispose();
      return out;
    } finally {
      model.loraState.active = [];
      for (const c of cache) c.dispose();
    }
  };

  const greedyTokens = async (adapters: string[] | null, n: number): Promise<number[]> => {
    // eosTokenIds: [] — the oracle regen loop runs fixed-length; match it.
    const gen = generate(model, promptIds, {
      maxTokens: n, temperature: 0, eosTokenIds: [], ...(adapters ? { adapters } : {}),
    });
    const out: number[] = [];
    for await (const t of gen) out.push(t.token);
    return out;
  };

  const maxAbsDiff = (a: Float32Array, b: Float32Array): number => {
    let m = 0;
    for (let i = 0; i < a.length; i++) m = Math.max(m, Math.abs(a[i]! - b[i]!));
    return m;
  };

  const baseline = forwardLogits([]);

  test("mount validates and reports layer counts", async () => {
    const upper = await manager.mount("upper", "fixtures/adapters/upper");
    const french = await manager.mount("french", "fixtures/adapters/french");
    // 4 layers × 7 mountable modules (q/o/gate/up/down + 2 per-layer-input)
    expect(upper.mountedLayers).toBe(28);
    expect(french.mountedLayers).toBe(28);
    expect(upper.scale).toBe(20.0);
  });

  test("bad adapter fails at mount, not at request time", async () => {
    // The 12B-shaped directory has no e4b-compatible tensors; an adapter
    // dir without configs/weights must throw with a clear message.
    expect(manager.mount("bogus", "/tmp/definitely-missing-adapter-dir")).rejects.toThrow(
      "adapter dir not found",
    );
    expect(() => manager.resolveSpec("not-mounted")).toThrow("unknown adapter");
  });

  test("FREE gate: mounted-but-inactive is byte-identical to base", () => {
    const inactive = forwardLogits([]);
    expect(maxAbsDiff(baseline, inactive)).toBe(0);
  });

  test("FREE gate: active at scale=0 is byte-identical to base", () => {
    // Force scale 0 on every mounted weight of 'upper', forward, restore.
    const saved: number[] = [];
    for (const lin of model.loraTargets().values()) {
      const lw = lin.adapters?.get("upper");
      if (lw) { saved.push(lw.scale); lw.scale = 0; }
    }
    try {
      const zeroed = forwardLogits(["upper"]);
      expect(maxAbsDiff(baseline, zeroed)).toBe(0);
    } finally {
      let i = 0;
      for (const lin of model.loraTargets().values()) {
        const lw = lin.adapters?.get("upper");
        if (lw) lw.scale = saved[i++]!;
      }
    }
  });

  test.skipIf(!haveGoldens)("adapter-applied logits bit-exact vs mlx-lm oracle", async () => {
    for (const id of ["upper", "french"]) {
      const ours = forwardLogits([id]);
      const ref = new Float32Array(
        await goldenAt(`lora-${id}-logits.bin`).arrayBuffer(),
      );
      expect(maxAbsDiff(ours, ref)).toBe(0);
    }
  });

  test.skipIf(!haveGoldens)("greedy prefix matches oracle per adapter", async () => {
    const g = (await goldenAt("lora-upper.json").json()) as { greedy_ids: number[] };
    const ours = await greedyTokens(["upper"], g.greedy_ids.length);
    expect(ours).toEqual(g.greedy_ids);
  }, 120_000);

  test("A→B→A isolation: switching leaves no residue", async () => {
    const N = 8;
    const isolatedA = await greedyTokens(["upper"], N);
    const isolatedB = await greedyTokens(["french"], N);
    const a1 = await greedyTokens(["upper"], N);
    const b = await greedyTokens(["french"], N);
    const a2 = await greedyTokens(["upper"], N);
    expect(a1).toEqual(isolatedA);
    expect(b).toEqual(isolatedB);
    expect(a2).toEqual(isolatedA);
    // and the base path is still untouched after all that switching
    expect(maxAbsDiff(baseline, forwardLogits([]))).toBe(0);
  }, 240_000);

  test("per-request selection over HTTP", async () => {
    const { createServer } = await import("../src/server");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const server = createServer({
      model,
      tokenizer: await loadTokenizer(E4B),
      template: await ChatTemplate.load(E4B),
      modelId: "e4b-lora-test",
      vision: null,
      visionTokenIds: { imageTokenId: 258880, boiTokenId: 255999, eoiTokenId: 258882 },
      adapters: manager,
      kvConfig: null,
    });
    try {
      const ask = async (adapter?: string) => {
        const res = await fetch(`http://localhost:${server.port}/v1/chat/completions`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            messages: [{ role: "user", content: "What color is the sky?" }],
            max_tokens: 24, temperature: 0,
            ...(adapter ? { adapter } : {}),
          }),
        });
        expect(res.status).toBe(200);
        const json = (await res.json()) as any;
        return json.choices[0].message.content as string;
      };

      expect(await ask("upper")).toContain("THE SKY IS BLUE");
      expect(await ask("french")).toContain("Le ciel est bleu");
      const base = await ask();
      expect(base).not.toContain("THE SKY IS BLUE");

      // unknown adapter → 400, loudly
      const bad = await fetch(`http://localhost:${server.port}/v1/chat/completions`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          messages: [{ role: "user", content: "hi" }], adapter: "nope",
        }),
      });
      expect(bad.status).toBe(400);

      // adapter admin: list shows both mounts
      const list = (await (await fetch(`http://localhost:${server.port}/v1/adapters`)).json()) as any;
      expect(list.adapters.map((a: any) => a.id).sort()).toEqual(["french", "upper"]);
    } finally {
      server.stop(true);
    }
  }, 240_000);

  test("unmount removes the adapter and frees selection", () => {
    const removed = manager.unmount("french");
    expect(removed).toBe(28);
    expect(() => manager.resolveSpec("french")).toThrow("unknown adapter");
    expect(maxAbsDiff(baseline, forwardLogits([]))).toBe(0);
  });
});
