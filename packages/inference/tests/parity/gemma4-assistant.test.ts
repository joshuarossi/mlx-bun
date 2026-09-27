// Gemma4 assistant drafter against a real target's donor caches, past the
// sliding window. The target's plain rotating and full caches go through a
// prefill of N tokens (longer than the window), a 4-token verify block, a
// rollback of 2 and a decode; the donors must hold exactly N, N+4, N+2 and N+3
// positions at those states. At each state the donor reader's attention (plain,
// and affine after conversion) and the deterministic draft chain (greedy, no
// RNG) fed by it must equal the same computations over donor rows selected
// independently of temporalView: same shape and dtype, finite, identical bytes,
// in-vocabulary tokens. This checks donor selection only; it is not an external
// oracle comparison and makes no claim about stochastic target verification.
// Opt in with both of
//   MLX_BUN_TEST_ASSISTANT_TARGET=/gemma4/target/snapshot
//   MLX_BUN_TEST_ASSISTANT_DRAFT=/gemma4/assistant/snapshot
// None set skips; any other combination fails.
import { expect, spyOn, test } from "bun:test";
import { strict as assert } from "node:assert";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type * as Ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../../src/contracts/mlx/cache";
import type { GemmaAssistantDrafter } from "../../src/models/gemma4/assistant";
import type { KVCache } from "../../src/state/kv";
import { optInAll, releaseAll, sha256, storedFloatDtype } from "./real-weight-inputs";

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
/** The scripted states and the positions each donor must then hold. */
const STATES = (n: number) => [[`prefill ${n}`, n], ["verify block 4", n + 4], ["rollback 2", n + 2], ["decode 1", n + 3]] as const;
/** Both donors hold the scripted positions, and the reader sees the expected widths. */
function assertDonorOffsets(state: string, got: { sliding: number; full: number; slidingWidth: number; fullWidth: number },
  expected: number, window: number) {
  assert(got.sliding === expected && got.full === expected,
    `${state}: donors hold ${got.sliding}/${got.full} positions, the script expects ${expected}`);
  assert(got.slidingWidth === Math.min(expected, window) && got.fullWidth === expected,
    `${state}: donor views ${got.slidingWidth}/${got.fullWidth} wide, expected ${Math.min(expected, window)}/${expected}`);
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
  type Rows = MlxArray | Triple;
  const release = (x: Rows) => { if ("packed" in x) releaseAll([() => x.packed.dispose(), () => x.scales.dispose(), () => x.biases.dispose()]); else x.dispose(); };
  const bytes = (a: MlxArray) => { const c = ops.contiguous(a); try { return Buffer.from(c.rawBytes()); } finally { c.dispose(); } };
  /** Same pinned shape, same dtype, finite values, identical bytes. */
  const expectSame = (what: string, got: MlxArray, want: MlxArray, shape: number[]) => {
    expect({ what, got: [got.shape, got.dtypeName], want: [want.shape, want.dtypeName] })
      .toEqual({ what, got: [shape, want.dtypeName], want: [shape, got.dtypeName] });
    expect({ what, finite: [...got.toFloat32()].every(Number.isFinite) && [...want.toFloat32()].every(Number.isFinite) }).toEqual({ what, finite: true });
    expect({ what, equal: bytes(got).equals(bytes(want)) }).toEqual({ what, equal: true });
  };

  const config = await loadModelConfig(inputs!.target);
  const weights = await Weights.open(inputs!.target);
  const held: (() => void)[] = [];
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
    /** Donor rows chosen independently of temporalView, each registered as it is made. */
    const select = (c: Cache, sliding: boolean, quantized: boolean, own: (x: Rows) => void): [Rows, Rows] => {
      const cache = c as unknown as { keys: never; values: never; offset: number; maxSize: number };
      const rows: Rows[] = [];
      const add = (x: Rows) => { own(x); rows.push(x); };
      if (sliding) {
        const state = rotatingSourcePosition(c as never), valid = Math.min(cache.offset, cache.maxSize);
        const range = { from: Math.max(0, state.activeLength - valid), to: state.activeLength };
        const storage = (quantized ? quantizedRowStorage : plainRowStorage) as typeof plainRowStorage;
        add(temporalStorageView(storage, cache.keys, state, range)); add(temporalStorageView(storage, cache.values, state, range));
      } else {
        const cut = (a: MlxArray) => a.slice([0, 0, 0, 0], [a.shape[0]!, a.shape[1]!, cache.offset, a.shape[3]!]);
        for (const source of [cache.keys, cache.values] as (MlxArray | Triple)[]) {
          if (!("packed" in source)) { add(cut(source)); continue; }
          const parts: MlxArray[] = [];
          try { for (const part of [source.packed, source.scales, source.biases]) parts.push(cut(part)); }
          catch (error) { releaseAll(parts.map(p => () => p.dispose())); throw error; }
          add({ packed: parts[0]!, scales: parts[1]!, biases: parts[2]! });
        }
      }
      return rows as [Rows, Rows];
    };
    let seed = 12345;
    const query = (D: number, dtype: MlxArray["dtype"]) => {
      const data = Float32Array.from({ length: t.numAttentionHeads * D }, () => ((seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0) / 2 ** 32) * 2 - 1);
      using f = MlxArray.fromFloat32(data, [1, t.numAttentionHeads, 1, D]);
      return f.astype(dtype);
    };
    /** One deterministic draft chain. Partial output is released if a step throws. */
    const chain = (shared: Parameters<GemmaAssistantDrafter["forwardRows"]>[2], anchor: MlxArray, pending: number, position: number) => {
      const steps: { token: number; hidden: MlxArray }[] = [];
      let token = pending, hidden = anchor;
      try {
        for (let k = 0; k < STEPS; k++) {
          using e = embed(token);
          const step = drafter!.forwardRows(e, hidden, shared, position + k);
          const entry = { token: -1, hidden: step.nextHidden };
          steps.push(entry); // owned before the tokens are read or released
          try { entry.token = step.tokens.toIntTokens()[0]!; } finally { step.tokens.dispose(); }
          token = entry.token; hidden = step.nextHidden;
        }
        return steps;
      } catch (error) { releaseAll(steps.map(s => () => s.hidden.dispose())); throw error; }
    };
    const check = (state: string, expected: number, anchor: MlxArray, pending: number) => {
      const position = expected - 1;
      for (const quantized of [false, true]) {
        const label = `${state} ${quantized ? "affine" : "plain"}`, owned: (() => void)[] = [];
        const own = (x: Rows) => { owned.push(() => release(x)); };
        try {
          let pair: Cache[] = [caches[slidingAt]!, caches[fullAt]!];
          if (quantized) {
            const clones = cloneKvCaches(pair), converted: Cache[] = [];
            owned.push(() => releaseAll(clones.map(c => () => c.dispose())));
            for (const clone of clones) {
              const q = (clone as KVCache).toQuantized(GROUP, BITS) as unknown as Cache;
              converted.push(q); owned.push(() => q.dispose());
            }
            pair = converted;
          }
          const views: ReturnType<typeof captureKvDonorAttention>[] = [];
          for (const c of pair) { const view = captureKvDonorAttention(c); owned.push(() => view.dispose()); views.push(view); }
          assertDonorOffsets(label, { sliding: pair[0]!.offset, full: pair[1]!.offset, slidingWidth: views[0]!.width, fullWidth: views[1]!.width }, expected, window);
          const reader = readAssistantDonors(pair[0]!, pair[1]!);
          owned.push(() => reader.dispose());
          const selected = [select(pair[0]!, true, quantized, own), select(pair[1]!, false, quantized, own)];
          // Donor attention, layer by layer.
          for (const [index, layer] of (["sliding", "full"] as const).entries()) {
            const [k, v] = selected[index]!, keys = ("packed" in k ? k.scales : k) as MlxArray;
            const width = layer === "sliding" ? Math.min(expected, window) : expected;
            const D = "packed" in k ? k.packed.shape[3]! * 32 / BITS : k.shape[3]!;
            expect({ label, layer, selected: keys.shape[2] }).toEqual({ label, layer, selected: width });
            using q = query(D, keys.dtype);
            using got = reader[layer].attend(q, D ** -0.5, layer === "sliding" ? window : null);
            using want = "packed" in k ? quantizedSdpa(q, k, v as Triple, D ** -0.5, { mode: "", arr: null }, GROUP, BITS)
              : ops.sdpa(q, k, v as MlxArray, D ** -0.5, "", null);
            expectSame(`${label} ${layer} attention`, got, want, [1, t.numAttentionHeads, 1, D]);
          }
          // The deterministic draft chain, fed each way; each chain is owned before the next runs.
          const bind = ([k, v]: Rows[]) => ({ attend: (q: MlxArray, scale: number) =>
            quantizedSdpa(q, k as Triple, v as Triple, scale, { mode: "", arr: null }, GROUP, BITS) });
          const independent = quantized ? { sliding: bind(selected[0]!), full: bind(selected[1]!) }
            : assistant.plainAssistantDonors({ sliding: selected[0] as [MlxArray, MlxArray], full: selected[1] as [MlxArray, MlxArray] }, position);
          const got = chain(reader, anchor, pending, position);
          owned.push(() => releaseAll(got.map(s => () => s.hidden.dispose())));
          const want = chain(independent, anchor, pending, position);
          owned.push(() => releaseAll(want.map(s => () => s.hidden.dispose())));
          got.forEach((step, i) => {
            expect({ label, step: i, token: step.token, inVocabulary: step.token >= 0 && step.token < vocab })
              .toEqual({ label, step: i, token: want[i]!.token, inVocabulary: true });
            expectSame(`${label} chain step ${i}`, step.hidden, want[i]!.hidden, [1, 1, hidden]);
          });
        } finally { releaseAll(owned.reverse()); }
      }
    };
    const prompt = promptFor(window, vocab), [prefill, verify, rollback, decode] = STATES(prompt.length);
    const hold = (a: MlxArray) => { held.push(() => a.dispose()); return a; };
    const h = hold(forward(prompt)), anchor = hold(at(h, prompt.length - 1));
    check(prefill[0], prefill[1], anchor, greedy(anchor));
    const block = hold(forward([greedy(anchor), 5002, 5003, 5004])), blockAnchor = hold(at(block, 3));
    check(verify[0], verify[1], blockAnchor, greedy(blockAnchor));
    for (const c of caches) { if (c instanceof RotatingKVCache) c.trim(2, true); else c.trim(2); }
    const kept = hold(at(block, 1));
    check(rollback[0], rollback[1], kept, greedy(kept));
    const next = hold(forward([greedy(kept)])), decoded = hold(at(next, 0));
    check(decode[0], decode[1], decoded, greedy(decoded));
  } finally {
    try { releaseAll([...held, ...caches.map(c => () => c.dispose()), () => drafter?.dispose()]); } finally {
      try { weights.dispose(); } finally { releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap())); }
    }
  }
}, 600_000);

/** Independently walk greedy target predictions; EOS is accepted but never
 * published, and the final budget may retain fewer proposals than were drafted. */
function assistantRound(drafts: readonly number[], predictions: readonly number[], remaining: number,
  eos: readonly number[], vocab: number) {
  assert.equal(predictions.length, drafts.length + 1, "every verify position needs a prediction");
  assert(Number.isInteger(remaining) && remaining > 0, "positive remaining budget");
  assert([...drafts, ...predictions].every(id => Number.isInteger(id) && id >= 0 && id < vocab), "in-vocabulary IDs");
  let accepted = 0, disagreed = false;
  const emitted: number[] = [];
  for (let i = 0; i < predictions.length && emitted.length < remaining; i++) {
    const token = predictions[i]!, matches = i < drafts.length && token === drafts[i];
    if (matches) accepted++;
    else if (i < drafts.length) disagreed = true;
    if (eos.includes(token)) break;
    emitted.push(token);
    if (!matches) break;
  }
  return { accepted, emitted, retained: Math.min(accepted, emitted.length), disagreed };
}

// This is a generation consumer, separate from donor selection above. Ordinary
// greedy output is a behavioral control, not a single-token/wide-logit oracle.
// The numerical check replays IDENTICAL forward blocks in independent direct
// caches and trims them by the independently checked accepted prefix. It is
// direct-graph consistency with shared execution, not main/Python preservation.
// Deliberately B1/plain/below-window: wrap, B>1 and stochastic sampling need their
// own matched-shape qualification. No synthetic provider or forced proposals.
test.skipIf(!inputs)("Gemma4 assistant: shared generation accepts, rejects and continues with exact-block replay", async () => {
  const { loadModelConfig, Weights, createModel, generate } = await import("@mlx-bun/inference");
  const { loadTokenizer, ChatTemplate } = await import("@mlx-bun/inference/input");
  const { AssistantProvider } = await import("@mlx-bun/inference/generation/speculative");
  const { bindMlxGateway } = await import("@mlx-bun/inference/execution");
  const { bindSpeculativeTargetModel } = await import("@mlx-bun/inference/generation/speculative/binding");
  const ops = await import("@mlx-bun/mlx/ops");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");
  const config = await loadModelConfig(inputs!.target), dtype = storedFloatDtype(inputs!.target);
  const tokenizer = await loadTokenizer(inputs!.target), template = await ChatTemplate.load(inputs!.target);
  let prompt = tokenizer.encode(template.render([{ role: "user", content: "List the planets of the solar system in order from the Sun." }]));
  if (prompt[0] === prompt[1] && prompt[0] === tokenizer.bosTokenId) prompt = prompt.slice(1);
  const depth = 2, maxTokens = 80, vocab = config.text.vocabSize;
  assert(prompt.length > 1 && prompt.length + maxTokens + depth < inputs!.geometry.window, "this consumer stays below the sliding window");
  const weights = await Weights.open(inputs!.target);
  const cleanup: (() => void)[] = [];
  try {
    const model = createModel(weights, config);
    cleanup.push(() => { if ("dispose" in model) model.dispose(); });
    const replay = createModel(weights, config);
    cleanup.push(() => { if ("dispose" in replay) replay.dispose(); });
    const replayBinding = bindSpeculativeTargetModel(replay);
    const prefillTokens = prompt.length - Number(replayBinding.prefillTailSplit);
    const provider = await AssistantProvider.load(inputs!.draft);
    cleanup.push(() => provider.dispose());
    const options = { temperature: 0, maxTokens, prefillChunkSize: prompt.length };
    const baseline: number[] = [];
    const ordinary = generate(model, prompt, options);
    for await (const token of ordinary) baseline.push(token.token);
    assert(baseline.length > 0 && baseline.length <= maxTokens, "ordinary control content length");
    assert(ordinary.stats && ordinary.stats.generatedTokens >= baseline.length &&
      ordinary.stats.generatedTokens <= Math.min(maxTokens, baseline.length + 1), "ordinary control completed");
    const replayCaches: Cache[] = replay.makeCache();
    cleanup.push(() => releaseAll(replayCaches.map(cache => () => cache.dispose())));
    const output: number[] = [], processed: number[] = [];
    type Round = { pending: number; proposals: number[]; start: number; outputStart: number; predictions?: number[]; accepted?: number; retained?: number; disagreed?: boolean; committedState?: string[] };
    const rounds: Round[] = [];
    const forwards: { ids: number[]; offset: number; logits: string; state: string[] }[] = [];
    let active: Round | undefined, liveCaches: Cache[] = [], opens = 0;
    const bytes = (array: MlxArray) => { using a = ops.contiguous(array); return Buffer.from(a.rawBytes()); };
    const same = (a: MlxArray, b: MlxArray, shape: number[], label: string) => {
      assert.deepEqual(a.shape, shape, `${label} actual geometry`);
      assert.deepEqual(b.shape, shape, `${label} replay geometry`);
      assert.equal(a.dtypeName, b.dtypeName, `${label} dtype`);
      assert(a.toFloat32().every(Number.isFinite) && b.toFloat32().every(Number.isFinite), `${label} nonfinite`);
      const raw = bytes(a);
      assert(raw.equals(bytes(b)), `${label} bytes differ`);
      return sha256(raw);
    };
    const state = (caches: Cache[], offset: number) => {
      const owners = config.text.numHiddenLayers - config.text.numKvSharedLayers;
      assert.equal(caches.length, owners, "all owned layers must be checked");
      assert.equal(replayCaches.length, owners);
      const hashes: string[] = [];
      for (let layer = 0; layer < owners; layer++) {
        const actual = caches[layer]!, wanted = replayCaches[layer]!;
        assert.equal(actual.offset, offset, `layer ${layer} committed offset`);
        assert.equal(wanted.offset, offset, `layer ${layer} replay offset`);
        const a = actual.state();
        let b: MlxArray[] = [];
        try {
          b = wanted.state();
          assert.equal(a.length, offset ? 2 : 0, `layer ${layer} plain K/V only`);
          assert.equal(b.length, a.length);
          const full = config.text.layerTypes[layer] === "full_attention";
          const heads = full ? config.text.numGlobalKeyValueHeads : config.text.numKeyValueHeads;
          const dim = full ? config.text.globalHeadDim : config.text.headDim;
          for (let plane = 0; plane < a.length; plane++) {
            const shape = [1, heads, offset, dim];
            assert.equal(a[plane]!.dtypeName, dtype, `layer ${layer} stored dtype`);
            using av = a[plane]!.slice([0, 0, 0, 0], shape);
            using bv = b[plane]!.slice([0, 0, 0, 0], shape);
            hashes.push(same(av, bv, shape, `layer ${layer} plane ${plane}`));
          }
        } finally {
          releaseAll([...(actual.stateNeedsDispose ? a.map(v => () => v.dispose()) : []),
            ...(wanted.stateNeedsDispose ? b.map(v => () => v.dispose()) : [])]);
        }
      }
      return hashes;
    };
    const originalForward = model.forwardHidden.bind(model);
    const forward = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
      assert.deepEqual(ids.shape, [1, ids.shape[1]], "B1 inputs");
      const values = ids.toIntTokens();
      if (!active) {
        assert.equal(forwards.length, 0, "one unchunked assistant prefill");
        assert.equal(values.length, prefillTokens, "actual tail-split prefill extent");
      }
      assert.deepEqual(values, active ? [active.pending, ...active.proposals] : prompt.slice(processed.length, processed.length + values.length), "exact prompt/verify inputs");
      state(caches, processed.length);
      const hidden = originalForward(ids, caches);
      let pin: { close(): void } | undefined;
      try {
        // Match the bound verify policy only for verify blocks. Gemma4 currently
        // has no pin operation; other target bindings may own one.
        if (active) pin = replayBinding.pinVerify?.();
        using reference = replay.forwardHidden(ids, replayCaches);
        using actualLogits = model.logitsFromHidden(hidden), wantedLogits = replay.logitsFromHidden(reference);
        const logits = same(actualLogits, wantedLogits, [1, values.length, vocab], "full target logits");
        processed.push(...values);
        forwards.push({ ids: [...values], offset: processed.length, logits, state: state(caches, processed.length) });
        liveCaches = caches;
        if (active) {
          assert.equal(active.predictions, undefined, "one target forward per round");
          using greedy = ops.argmaxAxis(actualLogits, -1);
          active.predictions = greedy.toIntTokens();
        }
        return hidden;
      } catch (error) { hidden.dispose(); throw error; }
      finally { pin?.close(); }
    });
    cleanup.push(() => forward.mockRestore());
    const originalOpen = provider.grouped.open.bind(provider.grouped);
    const opened = spyOn(provider.grouped, "open").mockImplementation(args => {
      opens++;
      const row = originalOpen(args), draft = row.draft.bind(row), commit = row.commit.bind(row);
      row.draft = async (pending, count, steps) => {
        assert.equal(active, undefined, "previous round committed");
        assert.deepEqual(pending, [output.at(-1) ?? prompt.at(-1)!], "actual pending token");
        assert.equal(processed.length, prompt.length + output.length - 1, "continuing prefix excludes pending");
        const proposals = await draft(pending, count, steps);
        assert.equal(proposals.length, 1);
        assert(proposals[0]!.length > 0 && proposals[0]!.length <= depth, "real assistant proposals");
        active = { pending: pending[0]!, proposals: [...proposals[0]!], start: processed.length, outputStart: output.length };
        rounds.push(active);
        return proposals;
      };
      row.commit = async (kept, context) => {
        assert(active?.predictions, "commit requires complete verification");
        const expected = assistantRound(active.proposals, active.predictions, maxTokens - active.outputStart, config.eosTokenIds, vocab);
        assert.deepEqual(output.slice(active.outputStart), expected.emitted, "published verify tokens");
        assert.deepEqual(kept, [expected.retained], "retained accepted prefix");
        const remove = active.proposals.length - expected.retained;
        for (const cache of replayCaches) if (remove) cache.trim(remove, true);
        processed.length = active.start + 1 + expected.retained;
        assert.deepEqual(processed, [...prompt, ...output].slice(0, processed.length), "committed token identity");
        active.committedState = state(liveCaches, processed.length); // target rollback has already run
        active.accepted = expected.accepted; active.retained = expected.retained; active.disagreed = expected.disagreed;
        await commit(kept, context);
        active = undefined;
      };
      return row;
    });
    cleanup.push(() => opened.mockRestore());
    const binding = bindMlxGateway(model, { provider, numDraftTokens: depth });
    const plan = binding.plan({ hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
      kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: true }, options,
    { continuous: true, quantizedBatch: false, checkpoints: false });
    assert.equal(plan.mechanism, "continuous"); assert.equal(plan.method, "speculative");
    const method = binding.methodRequest!(plan, options);
    assert(method, "real assistant method must be bound");
    const group = binding.createBatchGroup({ maxBatch: 1 });
    try {
      const stats = await group.submit({ method, promptIds: prompt, maxTokens, eosTokenIds: config.eosTokenIds,
        onToken: token => { assert(Number.isInteger(token) && token >= 0 && token < vocab); output.push(token); } });
      assert.deepEqual(output, baseline, "greedy output versus ordinary control (not logits)");
      assert.equal(opens, 1); assert.equal(active, undefined);
      assert(["stop", "length"].includes(stats.finishReason));
      assert(stats.generatedTokens >= output.length && stats.generatedTokens <= Math.min(maxTokens, output.length + 1));
      assert(rounds.length > 1 && rounds.every(round => round.retained !== undefined), "all rounds committed");
      const accepted = rounds.reduce((sum, round) => sum + round.accepted!, 0);
      const drafted = rounds.reduce((sum, round) => sum + round.proposals.length, 0);
      assert(accepted > 0 && drafted > accepted, "nonzero accepted and rejected proposals required");
      assert(rounds.slice(0, -1).some(round => round.disagreed &&
        round.proposals[round.accepted!] !== round.predictions![round.accepted!]),
      "must continue after a target/proposal disagreement, not budget or EOS truncation");
      assert.equal(stats.spec!.drafted, drafted); assert.equal(stats.spec!.accepted, accepted);
      assert.equal(stats.spec!.rejected, drafted - accepted); assert.equal(stats.spec!.rounds, rounds.length);
      assert.equal(forwards.length, rounds.length + 1, "one prefill plus every verification");
      assert.equal(stats.spec!.targetCalls, forwards.length);
      console.log(JSON.stringify({ scope: "B1/plain/below-window assistant generation; direct-graph exact-block replay, not main/oracle parity",
        depth, prefillTokens, prompt, output, ordinaryStats: ordinary.stats, stats, rounds, forwards }));
    } finally { await group.close(); }
    assert.equal(group.activeRows, 0); assert.equal(group.pendingRows, 0);
  } finally {
    try { releaseAll(cleanup.reverse()); }
    finally {
      try { weights.dispose(); }
      finally { releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap()).concat([() => clearCache()])); }
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

test("donors must hold the scripted positions: a missing or wrong rollback fails (CPU only)", () => {
  const n = 683, window = 512, [, verify, rollback] = STATES(n);
  expect(STATES(n).map(([, offset]) => offset)).toEqual([n, n + 4, n + 2, n + 3]);
  const at = (offset: number) => ({ sliding: offset, full: offset, slidingWidth: Math.min(offset, window), fullWidth: offset });
  assertDonorOffsets(rollback[0], at(rollback[1]), rollback[1], window);
  // A rollback that did nothing leaves the verify block's positions.
  expect(() => assertDonorOffsets(rollback[0], at(verify[1]), rollback[1], window)).toThrow("donors hold 687/687 positions, the script expects 685");
  expect(() => assertDonorOffsets(rollback[0], { ...at(rollback[1]), full: rollback[1] + 1 }, rollback[1], window)).toThrow("685/686");
  expect(() => assertDonorOffsets(rollback[0], { ...at(rollback[1]), slidingWidth: 513 }, rollback[1], window)).toThrow("donor views 513/685 wide");
});


test("assistant acceptance checks complete verification, EOS, final budget and retained rollback (CPU only)", () => {
  expect(assistantRound([4, 5], [4, 5, 6], 8, [9], 10)).toEqual({ accepted: 2, emitted: [4, 5, 6], retained: 2, disagreed: false });
  expect(assistantRound([4, 5], [4, 7, 6], 8, [9], 10)).toEqual({ accepted: 1, emitted: [4, 7], retained: 1, disagreed: true });
  expect(assistantRound([4, 9], [4, 9, 6], 8, [9], 10)).toEqual({ accepted: 2, emitted: [4], retained: 1, disagreed: false });
  expect(assistantRound([4, 5], [4, 5, 6], 1, [9], 10)).toEqual({ accepted: 1, emitted: [4], retained: 1, disagreed: false });
  expect(assistantRound([4, 5], [4, 7, 6], 1, [9], 10).disagreed).toBe(false); // unreached after budget
  expect(assistantRound([9, 5], [9, 7, 6], 8, [9], 10).disagreed).toBe(false); // unreached after EOS
  expect(() => assistantRound([4, 5], [4], 8, [], 10)).toThrow("every verify position");
  expect(() => assistantRound([4, 5], [4, 5, 10], 8, [], 10)).toThrow("in-vocabulary");
  expect(() => assistantRound([4, 5], [4, 5, -1], 8, [], 10)).toThrow("in-vocabulary");
});
