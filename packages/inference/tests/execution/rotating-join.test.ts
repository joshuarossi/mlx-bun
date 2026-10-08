// Shared batching with rotating (sliding-window) layers on real weights: rows
// that join a running row late, and two rows prepared together, with the prompt
// tail split off (a multi-token final prefill) and on (control), plus a joiner
// below the window (control). Each scenario runs twice: as is, and with the
// rotating caches' temporalView replaced by an independent newest-window
// selection through the source position. Both runs must agree on every forward
// (rows, IDs), projection, token and each row's valid state before every decode
// forward; in late joins, each merged row's state must equal its own solo (B1)
// state at the same offset. Every recorded K and V must have the head count and
// dimension the config fixes for its layer, the config's dtype and the expected
// width; projections must be finite [1, 1, vocab] rows of the dtype a one-token
// probe produces. Compiled decode is off so every step is observed.
// Opt in with
//   MLX_BUN_TEST_ROTATING_JOIN_MODEL=/model/snapshot (a Gemma4 artifact with sliding layers)
// and optionally, for a custom graph over a Llama-family artifact's unchanged
// weights (not a published model; alternating sliding and full layers),
//   MLX_BUN_TEST_ROTATING_JOIN_WINDOW=<sliding window>
// The window without a model, or a blank value, fails.
import { expect, test } from "bun:test";
import { strict as assert } from "node:assert";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../src/contracts/mlx/cache";
import { applyDescriptor, descriptorFor, releaseAll, storedFloatDtype } from "../parity/real-weight-inputs";
import { rotatingRowReader, type Layer, type Tensor } from "../parity/rotating-rows";

const MODEL = "MLX_BUN_TEST_ROTATING_JOIN_MODEL", WINDOW = "MLX_BUN_TEST_ROTATING_JOIN_WINDOW";
const FIRST = 40, JOINER = 24, JOIN_AFTER = 5;

// ---- opt-in, descriptor and plan (no native libraries) -------------------------------------
function optIn(env: Record<string, string | undefined>) {
  const model = env[MODEL], window = env[WINDOW];
  if (model === undefined && window === undefined) return null;
  if (!model?.trim()) throw new Error(`${MODEL} is required (${WINDOW} alone is not an opt-in)`);
  if (window !== undefined && !/^[1-9]\d*$/.test(window.trim())) throw new Error(`${WINDOW} must be a positive integer`);
  assert(existsSync(join(model, "config.json")), `${MODEL}: no config.json in ${model}`);
  const raw = JSON.parse(readFileSync(join(model, "config.json"), "utf8")), t = raw.text_config ?? raw;
  if (window !== undefined) {
    assert(["llama", "mistral"].includes(raw.model_type), `a custom window needs a Llama-family artifact, not ${raw.model_type}`);
    return { model, custom: descriptorFor(t.num_hidden_layers, Number(window)), window: Number(window), vocab: t.vocab_size as number,
      kv: kvGeometryFor(raw, "universal", storedFloatDtype(model)) };
  }
  assert(String(raw.model_type).startsWith("gemma4") && t.sliding_window > 0 && (t.layer_types ?? []).includes("sliding_attention"),
    "a published artifact must be Gemma4 with sliding layers");
  return { model, custom: null, window: t.sliding_window as number, vocab: t.vocab_size as number, kv: kvGeometryFor(raw, "gemma4", storedFloatDtype(model)) };
}
/** K/V heads and head dimension per layer kind, as the family's attention
 * derives them from the config (Gemma4: global dimension and, with k = v, global
 * heads on full layers; Universal: the same on every layer), with the dtype the
 * artifact stores (storedFloatDtype), never the config's. */
export function kvGeometryFor(raw: Record<string, any>, family: "gemma4" | "universal", dtype: string) {
  const t = raw.text_config ?? raw;
  assert(typeof dtype === "string" && dtype, "no stored dtype");
  const heads = t.num_key_value_heads as number, dim = (t.head_dim ?? Math.floor(t.hidden_size / t.num_attention_heads)) as number;
  if (family === "universal") return { dtype, rotating: { heads, dim }, full: { heads, dim } };
  return { dtype, rotating: { heads, dim },
    full: { heads: t.attention_k_eq_v ? (t.num_global_key_value_heads ?? heads) : heads, dim: (t.global_head_dim ?? dim) as number } };
}
interface Scenario { name: string; mode: "b1" | "late" | "initial"; rows: string[]; tailSplit: 0 | 1; budgets: number[] }
/** Prompts around the window, and the scenarios. */
export function planFor(window: number, vocab: number) {
  let s = 29;
  const ids = (n: number) => Array.from({ length: n }, () => 1000 + ((s = (Math.imul(s, 1664525) + 1013904223) >>> 0) % (vocab - 2000)));
  const prompts: Record<string, number[]> = { A: ids(window + Math.ceil(window / 3)), B: ids(window + Math.ceil(2 * window / 3)),
    C: ids(Math.max(2, Math.floor(window / 2))) };
  const b1 = (row: string, tailSplit: 0 | 1): Scenario => ({ name: `b1 ${row} split ${tailSplit}`, mode: "b1", rows: [row], tailSplit, budgets: [FIRST] });
  const pair = (mode: "late" | "initial", a: string, b: string, tailSplit: 0 | 1): Scenario =>
    ({ name: `${mode} ${a}+${b} split ${tailSplit}`, mode, rows: [a, b], tailSplit, budgets: [FIRST, JOINER] });
  return { prompts, scenarios: [b1("A", 0), b1("B", 0), b1("C", 0), b1("A", 1), b1("B", 1),
    pair("late", "A", "B", 0), pair("late", "A", "B", 1), pair("late", "A", "C", 0), pair("initial", "A", "B", 0), pair("initial", "A", "B", 1)] };
}

// ---- report checks (pure; no native libraries) ----------------------------------------------
export interface Projection { shape: number[]; dtype: string; sha: string; finite: boolean }
export interface Forward { B: number; L: number; labels: string[]; ids: number[][]; states: { offset: number; layers: Layer[] }[] | null;
  projections: Projection[] }
export interface Pins { layers: ("rotating" | "full")[]; window: number; vocab: number; projectionDtype: string;
  kv: { dtype: string; rotating: { heads: number; dim: number }; full: { heads: number; dim: number } } }
export interface Run { forwards: Forward[]; tokens: Record<string, number[]>; finish: Record<string, string>; joinedAfter: number | null }
/** Attribution, budgets and state completeness of one run against its scenario. */
export function checkRun(run: Run, scenario: Scenario, prompts: Record<string, number[]>, pins: Pins) {
  const tensorOk = (x: Tensor, shape: number[], dtype: string) =>
    JSON.stringify(x?.shape) === JSON.stringify(shape) && x.dtype === dtype && /^[0-9a-f]{64}$/.test(x.sha);
  const cursor: Record<string, number> = {}, projected: Record<string, number> = {};
  scenario.rows.forEach((row, i) => {
    assert.equal(run.finish[row], "length", `${row} finished ${run.finish[row]}`);
    assert.equal(run.tokens[row]?.length, scenario.budgets[i], `${row} emitted ${run.tokens[row]?.length}, budget ${scenario.budgets[i]}`);
  });
  run.forwards.forEach((f, index) => {
    const at = `forward ${index}`;
    assert(f.labels.length === f.B && f.ids.length === f.B, `${at}: ${f.labels.length} labels for B=${f.B}`);
    const before = { ...cursor };
    f.labels.forEach((label, r) => {
      assert(scenario.rows.includes(label), `${at}: unknown row ${label}`);
      const history = [...prompts[label]!, ...run.tokens[label]!], from = cursor[label] ?? 0, ids = f.ids[r]!;
      let pad = 0; // a row prepared with others may be left-padded by a constant run
      while (pad < ids.length && JSON.stringify(ids.slice(pad)) !== JSON.stringify(history.slice(from, from + ids.length - pad))) pad++;
      assert(pad < ids.length && (pad === 0 || (f.B > 1 && ids.slice(0, pad).every(id => id === ids[0]))), `${at}: row ${label} does not continue its history at ${from}`);
      cursor[label] = from + ids.length - pad;
    });
    if (f.projections.length) {
      assert.equal(f.projections.length, f.B, `${at}: ${f.projections.length} projected rows for B=${f.B}`);
      f.projections.forEach((p, r) => {
        assert(p.finite && tensorOk(p, [1, 1, pins.vocab], pins.projectionDtype), `${at}: projection ${r} invalid ${JSON.stringify(p).slice(0, 120)}`);
        projected[f.labels[r]!] = (projected[f.labels[r]!] ?? 0) + 1;
      });
    }
    const decode = f.labels.every(label => (before[label] ?? 0) >= prompts[label]!.length);
    if (decode) assert(f.states?.length === f.B, `${at}: decode forward without every row's state`);
    for (const [r, state] of (f.states ?? []).entries()) {
      assert.equal(state.offset, before[f.labels[r]!], `${at}: row ${r} state offset ${state.offset}, expected ${before[f.labels[r]!]}`);
      assert.equal(state.layers.length, pins.layers.length, `${at}: row ${r} state has ${state.layers.length} layers, the graph has ${pins.layers.length}`);
      state.layers.forEach((layer, j) => {
        const kind = pins.layers[j]!, { heads, dim } = pins.kv[kind];
        const shape = [1, heads, kind === "rotating" ? Math.min(state.offset, pins.window) : state.offset, dim];
        assert(layer.kind === kind && layer.offset === state.offset && tensorOk(layer.keys, shape, pins.kv.dtype) &&
          tensorOk(layer.values, shape, pins.kv.dtype), `${at}: row ${r} layer ${j} invalid ${JSON.stringify(layer).slice(0, 160)}`);
      });
    }
  });
  scenario.rows.forEach((row, i) => {
    // A row that finishes while another still runs gets one extra, unsampled step.
    const extra = scenario.rows.length === 2 && scenario.budgets[i]! < Math.max(...scenario.budgets) ? 1 : 0;
    assert.equal(cursor[row], prompts[row]!.length + scenario.budgets[i]! - 1 + extra, `${row}: forwarded ${cursor[row]} positions`);
    assert.equal(projected[row], scenario.budgets[i]! + extra, `${row}: ${projected[row]} projected rows`);
  });
  if (scenario.mode === "late") {
    const [first, second] = scenario.rows as [string, string];
    assert.equal(run.joinedAfter, JOIN_AFTER, `the join happened after ${run.joinedAfter} tokens`);
    assert(run.forwards.some(f => f.B === 2 && f.L === 1 && f.labels[0] === first && f.labels[1] === second), "no two-row decode");
  }
  if (scenario.mode === "initial") assert(run.forwards.some(f => f.B === 2 && f.L === 1), "no two-row decode");
}

const inputs = optIn(Bun.env);

test.skipIf(!inputs)("rotating rows keep their newest window through late joins and joint preparation", async () => {
  const { window, vocab, custom } = inputs!;
  const ops = await import("@mlx-bun/mlx/ops");
  const { loadModelConfig, Weights, createModel } = await import("@mlx-bun/inference");
  const { bindMlxGateway, createRuntimeConfig } = await import("../../src/execution");
  const { RotatingKVCache } = await import("../../src/state/rotating-kv");
  const { hash, newest, rowStates } = await rotatingRowReader();

  const config = await loadModelConfig(inputs!.model);
  // One descriptor for both the parsed config and the raw arguments the graph is built from.
  if (custom) applyDescriptor(config, custom);
  const weights = await Weights.open(inputs!.model);
  const originalView = RotatingKVCache.prototype.temporalView;
  try {
    const model = createModel(weights, config);
    if (custom) {
      const args = (model as unknown as { args: { layerTypes: string[]; slidingWindow: number } }).args;
      expect({ layerTypes: args.layerTypes, slidingWindow: args.slidingWindow }).toEqual(custom);
    }
    const { prompts, scenarios } = planFor(window, vocab);
    // Layer kinds from the graph's caches; the projection dtype from a one-token probe.
    const probe = model.makeCache();
    let kinds: ("rotating" | "full")[], projectionDtype: string;
    try {
      kinds = probe.map(c => c instanceof RotatingKVCache ? "rotating" as const : "full" as const);
      using ids = ops.fromInt32([prompts.A![0]!], [1, 1]);
      using h = model.forwardHidden(ids, probe);
      using logits = model.logitsFromHidden(h);
      projectionDtype = logits.dtypeName;
    } finally { releaseAll(probe.map(c => () => c.dispose())); }
    const pins: Pins = { layers: kinds, window, vocab, projectionDtype, kv: inputs!.kv };
    const run = async (scenario: Scenario): Promise<Run> => {
      const forwards: Forward[] = [], labelsOf = new WeakMap<object, string[]>(), assigned = new Set<string>(), admitted = new Set<string>();
      const finished = new Set<string>(), tokens: Record<string, number[]> = Object.fromEntries(scenario.rows.map(r => [r, []]));
      const cursor: Record<string, number> = {};
      let current: Forward | null = null, joinedAfter: number | null = null;
      const forwardHidden = model.forwardHidden, logitsFromHidden = model.logitsFromHidden;
      model.forwardHidden = function (this: typeof model, ids: MlxArray, caches: Cache[]) {
        const [B, L] = ids.shape as [number, number];
        let labels = labelsOf.get(caches[0]!);
        if (!labels) {
          const running = scenario.rows.filter(r => admitted.has(r) && !finished.has(r));
          labels = L > 1 || B !== running.length ? scenario.rows.filter(r => !assigned.has(r)).slice(0, B) : running;
          for (const l of labels) assigned.add(l);
          labelsOf.set(caches[0]!, labels);
        } else if (labels.length !== B) labels = labels.filter(l => !finished.has(l));
        const flat = ids.toIntTokens(), rows = Array.from({ length: B }, (_, r) => flat.slice(r * L, (r + 1) * L));
        const decode = labels.length === B && labels.every(l => (cursor[l] ?? 0) >= prompts[l]!.length);
        const states = decode ? rowStates(caches, B) : null;
        labels.forEach((l, r) => {
          const from = cursor[l] ?? 0, row = rows[r]!, prompt = prompts[l]!;
          let pad = 0;
          if (from < prompt.length) while (pad < row.length && JSON.stringify(row.slice(pad)) !== JSON.stringify(prompt.slice(from, from + row.length - pad))) pad++;
          cursor[l] = from + row.length - pad;
        });
        current = { B, L, labels, ids: rows, states, projections: [] };
        forwards.push(current);
        return forwardHidden.call(this, ids, caches);
      };
      model.logitsFromHidden = function (this: typeof model, hidden: MlxArray) {
        const out = logitsFromHidden.call(this, hidden);
        try {
          const [B, L, V] = out.shape as [number, number, number];
          assert(current && current.B === B, "a projection without its forward");
          for (let r = 0; r < B; r++) {
            using row = out.slice([r, L - 1, 0], [r + 1, L, V]);
            current.projections.push({ shape: [...row.shape], dtype: row.dtypeName, sha: hash(row), finite: [...row.toFloat32()].every(Number.isFinite) });
          }
          current = null;
          return out;
        } catch (error) { out.dispose(); throw error; }
      };
      const runtime = createRuntimeConfig({ MLX_BUN_PREFILL_TAIL_SPLIT: String(scenario.tailSplit), MLX_BUN_COMPILED_DECODE: "0" });
      const group = bindMlxGateway(model).createBatchGroup({ maxBatch: scenario.mode === "b1" ? 1 : 2, prefillChunkSize: 2048, runtime });
      const finish: Record<string, string> = {}, pending: Promise<unknown>[] = [];
      const submit = (i: number) => {
        const row = scenario.rows[i]!; admitted.add(row);
        if (i === 1 && scenario.mode === "late") joinedAfter = tokens[scenario.rows[0]!]!.length;
        pending.push(group.submit({ promptIds: prompts[row]!, maxTokens: scenario.budgets[i]!, eosTokenIds: [], plainGreedy: true,
          sample: logits => ops.argmaxAxis(logits, -1),
          onToken(token) {
            tokens[row]!.push(token);
            if (tokens[row]!.length === scenario.budgets[i]) finished.add(row);
            if (scenario.mode === "late" && i === 0 && tokens[row]!.length === JOIN_AFTER) submit(1);
          } }).then(stats => { finish[row] = stats.finishReason; }));
      };
      try {
        submit(0);
        if (scenario.mode === "initial") submit(1);
        for (let seen = 0; seen !== pending.length;) { seen = pending.length; await Promise.all(pending); }
      } finally { model.forwardHidden = forwardHidden; model.logitsFromHidden = logitsFromHidden; await group.close(); }
      return { forwards, tokens, finish, joinedAfter };
    };
    // The caller owns the returned views; a failed read releases what it made.
    const independent = function (this: InstanceType<typeof RotatingKVCache>) {
      const made: MlxArray[] = [];
      try { return newest(this, a => { made.push(a); return a; }); }
      catch (error) { releaseAll(made.map(a => () => a.dispose())); throw error; }
    };
    const b1: Record<string, Run> = {};
    for (const scenario of scenarios) {
      const plain = await run(scenario);
      checkRun(plain, scenario, prompts, pins);
      if (scenario.mode === "b1") { b1[`${scenario.rows[0]} ${scenario.tailSplit}`] = plain; continue; }
      RotatingKVCache.prototype.temporalView = independent;
      let reference: Run;
      try { reference = await run(scenario); } finally { RotatingKVCache.prototype.temporalView = originalView; }
      checkRun(reference, scenario, prompts, pins);
      expect({ scenario: scenario.name, run: plain }).toEqual({ scenario: scenario.name, run: reference });
      if (scenario.mode === "late") {
        // At the merge, each row's state is its own solo state at the same offset.
        const merged = plain.forwards.find(f => f.B === 2 && f.L === 1)!;
        merged.labels.forEach((label, r) => {
          const state = merged.states![r]!, solo = b1[`${label} ${scenario.tailSplit}`]!.forwards.find(f => f.states?.[0]?.offset === state.offset);
          expect({ scenario: scenario.name, label, state: solo?.states?.[0] }).toEqual({ scenario: scenario.name, label, state });
        });
      }
    }
  } finally {
    RotatingKVCache.prototype.temporalView = originalView;
    try { weights.dispose(); } finally { releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap())); }
  }
}, 900_000);

// ---- CPU-only validation (no native libraries) ------------------------------------------
test("opt-in: a model alone or with a custom window; a window alone or a blank value fails (CPU only)", () => {
  expect(optIn({})).toBeNull();
  expect(() => optIn({ [WINDOW]: "8" })).toThrow(`${MODEL} is required`);
  expect(() => optIn({ [MODEL]: " " })).toThrow(`${MODEL} is required`);
  expect(() => optIn({ [MODEL]: "/m", [WINDOW]: "0" })).toThrow("positive integer");
  expect(() => optIn({ [MODEL]: "/nonexistent-model" })).toThrow("no config.json");
});

test("a custom descriptor is one value source; the plan brackets the window (CPU only)", () => {
  expect(descriptorFor(4, 8)).toEqual({ layerTypes: ["sliding_attention", "full_attention", "sliding_attention", "full_attention"], slidingWindow: 8 });
  const { prompts, scenarios } = planFor(8, 1000 + 2001);
  expect([prompts.A!.length, prompts.B!.length, prompts.C!.length]).toEqual([11, 14, 4]);
  expect(prompts).toEqual(planFor(8, 3001).prompts);
  expect(scenarios.map(s => s.name)).toContain("late A+B split 1");
  expect(scenarios.filter(s => s.mode !== "b1").every(s => scenarios.some(b => b.mode === "b1" && b.rows[0] === s.rows[1] && b.tailSplit === s.tailSplit))).toBe(true);
});

test("K/V geometry follows each family's attention (CPU only)", () => {
  const gemma = { model_type: "gemma4", text_config: { num_key_value_heads: 2, head_dim: 256, global_head_dim: 512, attention_k_eq_v: false,
    num_global_key_value_heads: 4, dtype: "bfloat16", hidden_size: 2560, num_attention_heads: 8 } };
  expect(kvGeometryFor(gemma, "gemma4", "bfloat16")).toEqual({ dtype: "bfloat16", rotating: { heads: 2, dim: 256 }, full: { heads: 2, dim: 512 } });
  expect(kvGeometryFor({ ...gemma, text_config: { ...gemma.text_config, attention_k_eq_v: true } }, "gemma4", "bfloat16").full).toEqual({ heads: 4, dim: 512 });
  const llama = { model_type: "llama", torch_dtype: "bfloat16", num_key_value_heads: 8, hidden_size: 3072, num_attention_heads: 24 };
  expect(kvGeometryFor(llama, "universal", "float16")).toEqual({ dtype: "float16", rotating: { heads: 8, dim: 128 }, full: { heads: 8, dim: 128 } });
  expect(() => kvGeometryFor(llama, "universal", "")).toThrow("no stored dtype");
});

test("the KV dtype pin is the artifact's one stored floating dtype, not its config (CPU only)", () => {
  const dir = mkdtempSync(join(tmpdir(), "stored-dtype-"));
  /** A header-only safetensors shard: the tensors' dtypes, zero-filled data. */
  const shard = (name: string, dtypes: string[]) => {
    let offset = 0;
    const entries = Object.fromEntries(dtypes.map((dtype, i) => {
      const bytes = dtype === "F32" || dtype === "U32" ? 4 : 2, entry = [`t${i}`, { dtype, shape: [1], data_offsets: [offset, offset + bytes] }];
      offset += bytes; return entry;
    }));
    const header = Buffer.from(JSON.stringify({ __metadata__: { format: "mlx" }, ...entries })), prefix = Buffer.alloc(8);
    prefix.writeBigUInt64LE(BigInt(header.length));
    writeFileSync(join(dir, name), Buffer.concat([prefix, header, Buffer.alloc(offset)]));
  };
  const artifact = (config: object, shards: Record<string, string[]>, indexed = true) => {
    rmSync(dir, { recursive: true, force: true }); mkdirSync(dir);
    writeFileSync(join(dir, "config.json"), JSON.stringify(config));
    for (const [name, dtypes] of Object.entries(shards)) shard(name, dtypes);
    if (indexed) writeFileSync(join(dir, "model.safetensors.index.json"), JSON.stringify({ weight_map:
      Object.fromEntries(Object.keys(shards).map((name, i) => [`w${i}`, name])) }));
    return dir;
  };
  try {
    // An MLX conversion stores float16 while its config names the source bfloat16.
    const llama = { model_type: "llama", torch_dtype: "bfloat16", num_hidden_layers: 4, num_key_value_heads: 8,
      hidden_size: 3072, num_attention_heads: 24, vocab_size: 128256 };
    expect(storedFloatDtype(artifact(llama, { "model.safetensors": ["F16", "U32", "F16"] }))).toBe("float16");
    expect(kvGeometryFor(llama, "universal", storedFloatDtype(dir)).dtype).toBe("float16");
    expect(storedFloatDtype(artifact(llama, { "model.safetensors": ["BF16", "U32"] }, false))).toBe("bfloat16");
    expect(storedFloatDtype(artifact(llama, { "a.safetensors": ["F32"], "b.safetensors": ["U32", "F32"] }))).toBe("float32");
    // Mixed floating inputs, within or across shards, and none at all are unsupported.
    expect(() => storedFloatDtype(artifact(llama, { "model.safetensors": ["F16", "BF16"] }))).toThrow("exactly one is supported");
    expect(() => storedFloatDtype(artifact(llama, { "a.safetensors": ["F16"], "b.safetensors": ["F32"] }))).toThrow("exactly one is supported");
    expect(() => storedFloatDtype(artifact(llama, { "model.safetensors": ["U32"] }))).toThrow("exactly one is supported");
    writeFileSync(join(dir, "model.safetensors"), Buffer.alloc(4));
    expect(() => storedFloatDtype(dir)).toThrow("no safetensors header");
    const oversized = Buffer.alloc(16); oversized.writeBigUInt64LE(1n << 40n);
    writeFileSync(join(dir, "model.safetensors"), oversized);
    expect(() => storedFloatDtype(dir)).toThrow("header length");
    const truncated = Buffer.alloc(16); truncated.writeBigUInt64LE(64n);
    writeFileSync(join(dir, "model.safetensors"), truncated);
    expect(() => storedFloatDtype(dir)).toThrow("truncated header");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("the run check rejects misattributed, incomplete or malformed records (CPU only)", () => {
  const prompts = { A: [10, 11, 12], B: [20, 21] };
  const pins: Pins = { layers: ["rotating", "full"], window: 2, vocab: 5, projectionDtype: "bfloat16",
    kv: { dtype: "bfloat16", rotating: { heads: 1, dim: 2 }, full: { heads: 1, dim: 4 } } };
  const scenario: Scenario = { name: "late A+B", mode: "late", rows: ["A", "B"], tailSplit: 0, budgets: [3, 2] };
  const h = (c: string) => c.repeat(64);
  const kv = (shape: number[], c: string): Tensor => ({ shape, dtype: "bfloat16", sha: h(c) });
  const state = (offset: number) => ({ offset, layers: [
    { kind: "rotating" as const, offset, keys: kv([1, 1, Math.min(offset, 2), 2], "a"), values: kv([1, 1, Math.min(offset, 2), 2], "b") },
    { kind: "full" as const, offset, keys: kv([1, 1, offset, 4], "c"), values: kv([1, 1, offset, 4], "d") }] });
  const p = (): Projection => ({ shape: [1, 1, 5], dtype: "bfloat16", sha: h("e"), finite: true });
  // A: prompt 3 then tokens 1,2,3; B joins: prompt 2 then tokens 4,5 (+1 extra step).
  const valid = (): Run => ({ tokens: { A: [1, 2, 3], B: [4, 5] }, finish: { A: "length", B: "length" }, joinedAfter: JOIN_AFTER, forwards: [
    { B: 1, L: 3, labels: ["A"], ids: [[10, 11, 12]], states: null, projections: [p()] },
    { B: 1, L: 2, labels: ["B"], ids: [[20, 21]], states: null, projections: [p()] },
    { B: 2, L: 1, labels: ["A", "B"], ids: [[1], [4]], states: [state(3), state(2)], projections: [p(), p()] },
    { B: 2, L: 1, labels: ["A", "B"], ids: [[2], [5]], states: [state(4), state(3)], projections: [p(), p()] },
  ] });
  expect(() => checkRun(valid(), scenario, prompts, pins)).not.toThrow();
  const rejects = (change: (r: Run) => void, message: string) => { const r = valid(); change(r); expect(() => checkRun(r, scenario, prompts, pins)).toThrow(message); };
  const layer = (r: Run, f: number, row: number, j: number) => r.forwards[f]!.states![row]!.layers[j]!;
  rejects(r => { r.forwards[2]!.labels.reverse(); }, "does not continue its history");
  rejects(r => { r.forwards[3]!.ids[0] = [9]; }, "does not continue its history");
  rejects(r => { r.forwards.pop(); }, "positions");
  rejects(r => { r.forwards[2]!.projections.pop(); }, "projected rows for B=2");
  rejects(r => { r.forwards[2]!.states = null; }, "decode forward without every row's state");
  rejects(r => { for (const s of r.forwards[3]!.states!) s.layers.pop(); }, "state has 1 layers, the graph has 2");
  rejects(r => { layer(r, 3, 0, 0).keys.shape[2] = 3; }, "layer 0 invalid");
  rejects(r => { layer(r, 3, 1, 1).kind = "rotating"; }, "layer 1 invalid");
  // Equal-byte reshapes, other dtypes, and V metadata that disagrees with K.
  rejects(r => { layer(r, 2, 0, 1).keys.shape = [1, 2, 3, 2]; }, "layer 1 invalid");
  rejects(r => { layer(r, 2, 1, 0).keys.dtype = "float16"; }, "layer 0 invalid");
  rejects(r => { layer(r, 3, 0, 1).values.shape = [1, 1, 4, 2]; }, "layer 1 invalid");
  rejects(r => { layer(r, 3, 1, 0).values.dtype = "float32"; }, "layer 0 invalid");
  rejects(r => { r.forwards[2]!.projections[0]!.finite = false; }, "projection 0 invalid");
  rejects(r => { r.forwards[2]!.projections[1]!.shape = [1, 5]; }, "projection 1 invalid");
  rejects(r => { r.forwards[3]!.projections[0]!.dtype = "float32"; }, "projection 0 invalid");
  rejects(r => { r.tokens.B!.pop(); }, "B emitted 1, budget 2");
  rejects(r => { r.finish.A = "stop"; }, "A finished stop");
  rejects(r => { r.joinedAfter = 1; }, "the join happened after 1 tokens");
});
