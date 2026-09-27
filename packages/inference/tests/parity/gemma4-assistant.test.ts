// Gemma4 assistant drafter against a real target's donor caches, past the
// sliding window. The target's plain rotating and full caches go through a
// prefill longer than the window, a multi-token verify block, a rollback and a
// decode. At each state the donor reader's attention (plain, and affine after
// conversion) and the deterministic draft chain (greedy, no RNG) fed by it must
// equal the same computations over donor rows selected independently of
// temporalView, byte for byte, with finite values and in-vocabulary tokens.
// This checks donor selection only; it is not an external oracle comparison and
// makes no claim about stochastic target verification. Opt in with both of
//   MLX_BUN_TEST_ASSISTANT_TARGET=/gemma4/target/snapshot
//   MLX_BUN_TEST_ASSISTANT_DRAFT=/gemma4/assistant/snapshot
// None set skips; any other combination fails.
import { expect, test } from "bun:test";
import { strict as assert } from "node:assert";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type * as Ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../../src/contracts/mlx/cache";
import type { GemmaAssistantDrafter } from "../../src/models/gemma4/assistant";
import type { KVCache } from "../../src/state/kv";
import { optInAll, releaseAll } from "./real-weight-inputs";

const OPT_IN = ["MLX_BUN_TEST_ASSISTANT_TARGET", "MLX_BUN_TEST_ASSISTANT_DRAFT"] as const;
const STEPS = 6, GROUP = 64, BITS = 8;

/** The target's geometry, checked before any native load. */
function targetOf(dir: string) {
  const raw = JSON.parse(readFileSync(join(dir, "config.json"), "utf8")), t = raw.text_config ?? raw;
  assert(String(raw.model_type).startsWith("gemma4"), `assistant target must be a Gemma4 artifact: ${raw.model_type}`);
  const donors = t.num_hidden_layers - (t.num_kv_shared_layers ?? 0), types: string[] = t.layer_types ?? [];
  assert(t.sliding_window > 0 && types.slice(0, donors).includes("sliding_attention") && types.slice(0, donors).includes("full_attention"),
    "assistant target needs sliding and full donor layers");
  return { window: t.sliding_window as number, vocab: t.vocab_size as number, hidden: t.hidden_size as number };
}
function optIn(env: Record<string, string | undefined>) {
  const values = optInAll(env, OPT_IN, "Gemma4 assistant donors");
  if (!values) return null;
  for (const name of OPT_IN) assert(existsSync(join(values[name], "config.json")), `${name}: no config.json in ${values[name]}`);
  return { target: values[OPT_IN[0]], draft: values[OPT_IN[1]], geometry: targetOf(values[OPT_IN[0]]) };
}
/** A deterministic prompt longer than the window. */
function promptFor(window: number, vocab: number): number[] {
  let s = 17;
  const next = () => (s = (Math.imul(s, 1664525) + 1013904223) >>> 0);
  return [2, ...Array.from({ length: window + Math.ceil(window / 3) - 1 }, () => 1000 + next() % (vocab - 2000))];
}

const inputs = optIn(Bun.env);

test.skipIf(!inputs)("Gemma4 assistant: donor attention and draft chains equal independently selected donors past the window", async () => {
  const { window, vocab, hidden } = inputs!.geometry;
  const ops: typeof Ops = await import("@mlx-bun/mlx/ops");
  const { MlxArray } = await import("@mlx-bun/mlx/array");
  const { loadModelConfig, Weights, createModel } = await import("@mlx-bun/inference");
  const { RotatingKVCache } = await import("../../src/state/rotating-kv");
  const { KVCache: KVCacheClass } = await import("../../src/state/kv");
  const { rotatingSourcePosition } = await import("../../src/state/rotating-kv-layout");
  const { plainRowStorage, quantizedRowStorage, temporalStorageView } = await import("../../src/state/batched-row-storage");
  const { captureKvDonorAttention } = await import("../../src/state/kv-attention-view");
  const { cloneKvCaches } = await import("../../src/state/persistence");
  const { readAssistantDonors } = await import("../../src/generation/speculative/bindings/assistant-target");
  const assistant = await import("../../src/models/gemma4/assistant");
  const { quantizedSdpa } = await import("../../src/layers/quantized-attention");
  type Triple = Ops.QuantizedTensor;
  const bytes = (a: MlxArray) => { const c = ops.contiguous(a); try { return Buffer.from(c.rawBytes()); } finally { c.dispose(); } };
  const expectSame = (what: string, got: MlxArray, want: MlxArray, shape: number[]) => {
    expect({ what, shape: got.shape }).toEqual({ what, shape });
    expect({ what, shape: want.shape }).toEqual({ what, shape });
    expect({ what, finite: [...got.toFloat32()].every(Number.isFinite) && [...want.toFloat32()].every(Number.isFinite) }).toEqual({ what, finite: true });
    expect({ what, equal: bytes(got).equals(bytes(want)) }).toEqual({ what, equal: true });
  };

  const config = await loadModelConfig(inputs!.target);
  const weights = await Weights.open(inputs!.target);
  const owned: (() => void)[] = [];
  let drafter: GemmaAssistantDrafter | null = null, caches: Cache[] = [];
  try {
    const model = createModel(weights, config) as unknown as {
      makeCache(): Cache[]; forwardHidden(ids: MlxArray, caches: Cache[]): MlxArray; logitsFromHidden(h: MlxArray): MlxArray;
      embed: { encode(ids: MlxArray): MlxArray }; embedScale: number };
    drafter = await assistant.GemmaAssistantDrafter.load(inputs!.draft);
    const t = config.text, donors = t.numHiddenLayers - t.numKvSharedLayers;
    const last = (type: string) => { let at = -1; for (let i = 0; i < donors; i++) if (t.layerTypes[i] === type) at = i; return at; };
    const slidingAt = last("sliding_attention"), fullAt = last("full_attention");
    caches = model.makeCache();
    assert(caches[slidingAt] instanceof RotatingKVCache && caches[fullAt] instanceof KVCacheClass, "unexpected donor cache kinds");
    const embed = (token: number) => { using ids = ops.fromInt32([token], [1, 1]); using e = model.embed.encode(ids); return ops.mulScalar(e, model.embedScale); };
    const greedy = (h: MlxArray) => { using logits = model.logitsFromHidden(h); using arg = ops.argmaxAxis(logits, -1); return arg.toIntTokens()[0]!; };
    const forward = (ids: number[]) => { using x = ops.fromInt32(ids, [1, ids.length]); return model.forwardHidden(x, caches); };
    const at = (h: MlxArray, i: number) => h.slice([0, i, 0], [1, i + 1, h.shape[2]!]);
    /** Donor rows chosen independently of temporalView: the newest positions, or every full position. */
    const select = (c: Cache, sliding: boolean, quantized: boolean): [MlxArray | Triple, MlxArray | Triple] => {
      const cache = c as unknown as { keys: never; values: never; offset: number; maxSize: number };
      if (sliding) {
        const state = rotatingSourcePosition(c as never), valid = Math.min(cache.offset, cache.maxSize);
        const range = { from: Math.max(0, state.activeLength - valid), to: state.activeLength };
        const storage = (quantized ? quantizedRowStorage : plainRowStorage) as typeof plainRowStorage;
        return [temporalStorageView(storage, cache.keys, state, range), temporalStorageView(storage, cache.values, state, range)];
      }
      const cut = (a: MlxArray) => a.slice([0, 0, 0, 0], [a.shape[0]!, a.shape[1]!, cache.offset, a.shape[3]!]);
      const cutTriple = (q: Triple) => ({ packed: cut(q.packed), scales: cut(q.scales), biases: cut(q.biases) });
      return quantized ? [cutTriple(cache.keys), cutTriple(cache.values)] : [cut(cache.keys), cut(cache.values)];
    };
    const release = (x: MlxArray | Triple) => { if ("packed" in x) { x.packed.dispose(); x.scales.dispose(); x.biases.dispose(); } else x.dispose(); };
    let seed = 12345;
    const query = (D: number, dtype: MlxArray["dtype"]) => {
      const data = Float32Array.from({ length: t.numAttentionHeads * D }, () => ((seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0) / 2 ** 32) * 2 - 1);
      using f = MlxArray.fromFloat32(data, [1, t.numAttentionHeads, 1, D]);
      return f.astype(dtype);
    };
    const chain = (shared: Parameters<NonNullable<typeof drafter>["forwardRows"]>[2], anchor: MlxArray, pending: number, position: number) => {
      const steps: { token: number; hidden: MlxArray }[] = [];
      let token = pending, hidden = anchor;
      for (let k = 0; k < STEPS; k++) {
        using e = embed(token);
        const step = drafter!.forwardRows(e, hidden, shared, position + k);
        token = step.tokens.toIntTokens()[0]!; step.tokens.dispose();
        steps.push({ token, hidden: step.nextHidden }); hidden = step.nextHidden;
      }
      return steps;
    };
    const check = (state: string, anchor: MlxArray, pending: number) => {
      const position = caches[fullAt]!.offset - 1;
      for (const quantized of [false, true]) {
        const label = `${state} ${quantized ? "affine" : "plain"}`;
        const pair = quantized ? cloneKvCaches([caches[slidingAt]!, caches[fullAt]!]).map(c => (c as KVCache).toQuantized(GROUP, BITS) as unknown as Cache)
          : [caches[slidingAt]!, caches[fullAt]!];
        const reader = readAssistantDonors(pair[0]!, pair[1]!);
        const selected = [select(pair[0]!, true, quantized), select(pair[1]!, false, quantized)];
        const chains: { token: number; hidden: MlxArray }[][] = [];
        try {
          // Donor attention, layer by layer.
          for (const [index, layer] of (["sliding", "full"] as const).entries()) {
            const cache = pair[index]!, width = layer === "sliding" ? Math.min(cache.offset, window) : cache.offset;
            const view = captureKvDonorAttention(cache);
            try { expect({ label, layer, width: view.width }).toEqual({ label, layer, width }); } finally { view.dispose(); }
            const [k, v] = selected[index]!, keys = ("packed" in k ? k.scales : k) as MlxArray;
            const D = "packed" in k ? k.packed.shape[3]! * 32 / BITS : k.shape[3]!;
            expect({ label, layer, selected: keys.shape[2] }).toEqual({ label, layer, selected: width });
            using q = query(D, keys.dtype);
            using got = reader[layer].attend(q, D ** -0.5, layer === "sliding" ? window : null);
            using want = "packed" in k ? quantizedSdpa(q, k, v as Triple, D ** -0.5, { mode: "", arr: null }, GROUP, BITS)
              : ops.sdpa(q, k, v as MlxArray, D ** -0.5, "", null);
            expectSame(`${label} ${layer} attention`, got, want, [1, t.numAttentionHeads, 1, D]);
          }
          // The deterministic draft chain, fed each way.
          const bind = ([k, v]: (MlxArray | Triple)[]) => ({ attend: (q: MlxArray, scale: number) =>
            quantizedSdpa(q, k as Triple, v as Triple, scale, { mode: "", arr: null }, GROUP, BITS) });
          const independent = quantized ? { sliding: bind(selected[0]!), full: bind(selected[1]!) }
            : assistant.plainAssistantDonors({ sliding: selected[0] as [MlxArray, MlxArray], full: selected[1] as [MlxArray, MlxArray] }, position);
          chains.push(chain(reader, anchor, pending, position), chain(independent, anchor, pending, position));
          chains[0]!.forEach((got, i) => {
            const want = chains[1]![i]!;
            expect({ label, step: i, token: got.token, inVocabulary: got.token >= 0 && got.token < vocab })
              .toEqual({ label, step: i, token: want.token, inVocabulary: true });
            expectSame(`${label} chain step ${i}`, got.hidden, want.hidden, [1, 1, hidden]);
          });
        } finally {
          releaseAll([() => reader.dispose(), ...selected.flat().map(x => () => release(x)),
            ...chains.flat().map(s => () => s.hidden.dispose()), ...(quantized ? pair.map(c => () => c.dispose()) : [])]);
        }
      }
    };
    const prompt = promptFor(window, vocab);
    let h = forward(prompt), anchor = at(h, prompt.length - 1); h.dispose();
    owned.push(() => anchor.dispose());
    check(`prefill ${prompt.length}`, anchor, greedy(anchor));
    const block = forward([greedy(anchor), 5002, 5003, 5004]);
    owned.push(() => block.dispose());
    const blockAnchor = at(block, 3); owned.push(() => blockAnchor.dispose());
    check("verify block 4", blockAnchor, greedy(blockAnchor));
    for (const c of caches) { if (c instanceof RotatingKVCache) c.trim(2, true); else c.trim(2); }
    const kept = at(block, 1); owned.push(() => kept.dispose());
    check("rollback 2", kept, greedy(kept));
    h = forward([greedy(kept)]); const decoded = at(h, 0); h.dispose(); owned.push(() => decoded.dispose());
    check("decode 1", decoded, greedy(decoded));
  } finally {
    try { releaseAll([...owned, ...caches.map(c => () => c.dispose()), () => drafter?.dispose()]); } finally {
      try { weights.dispose(); } finally { releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap())); }
    }
  }
}, 600_000);

// ---- CPU-only validation (no native libraries) ------------------------------------------
test("opt-in is all or nothing, and the target must carry sliding and full donors (CPU only)", () => {
  expect(optIn({})).toBeNull();
  expect(() => optIn({ [OPT_IN[0]]: "/t" })).toThrow("missing or blank");
  expect(() => optIn({ [OPT_IN[0]]: "/t", [OPT_IN[1]]: " " })).toThrow(`missing or blank: ${OPT_IN[1]}`);
  expect(() => optIn({ [OPT_IN[0]]: "/nonexistent-target", [OPT_IN[1]]: "/nonexistent-draft" })).toThrow("no config.json");
});

test("the prompt is deterministic, in vocabulary, and longer than the window (CPU only)", () => {
  const prompt = promptFor(512, 262_144);
  expect(prompt).toEqual(promptFor(512, 262_144));
  expect(prompt.length).toBeGreaterThan(512);
  expect(prompt.every(id => Number.isInteger(id) && id >= 0 && id < 262_144)).toBe(true);
});
