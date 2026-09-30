// Qwen3.8-27B packed-Trellis graph and its native MTP draft head against main's
// own outputs. The packed-Trellis artifact has no external oracle (mlx-lm cannot
// load it), so the reference is what main at 02d723a computes for the same
// artifacts, produced outside this repository by
// packages/inference/scripts/main-qwen-trellis-reference.ts. This test never
// starts main or Python. Opt in with all four of
//   MLX_BUN_TEST_QWEN_TRELLIS_TARGET=/packed/trellis/snapshot
//   MLX_BUN_TEST_QWEN_TRELLIS_DRAFT=/folded/mtp/snapshot
//   MLX_BUN_TEST_QWEN_TRELLIS_REFERENCE=/path/main-qwen-trellis.json
//   MLX_BUN_TEST_QWEN_TRELLIS_REFERENCE_SHA256=<its SHA-256>
// None set skips; any other combination fails. The reference and both artifacts
// (metadata files and shards, by content) are verified before native libraries
// load, and the runtime must match the reference's MLX version and GPU family.
// Checked, batch one, plain KV, per prompt:
//  - the tokenizer and template render the reference's prompt IDs;
//  - greedy trajectory: the prompt once and each selected token on the same live
//    cache through `model.forward`; every step's full last-position float32
//    logits hash to main's (bit for bit) and are finite, and every selected
//    token is main's;
//  - MTP speculation, depth 2, greedy, stop tokens off, through the public gateway
//    binding: the emitted tokens, every target forward's input IDs (so every
//    verify row [pending, ...proposals], accepted or rejected) and the round and
//    draft counters equal main's shared batch-one gateway.
// Continuation state and append geometry are the runtime-oracle plan's job
// (README, "Repeatable runtime comparison"). This is not a claim about other
// artifacts, batching above one, quantized KV, sampling, or speed.
import { expect, spyOn, test } from "bun:test";
import { strict as assert } from "node:assert";
import { cpSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { isSha256, optInAll, releaseAll, sha256, verifyArtifact } from "./real-weight-inputs";

const OPT_IN = ["MLX_BUN_TEST_QWEN_TRELLIS_TARGET", "MLX_BUN_TEST_QWEN_TRELLIS_DRAFT", "MLX_BUN_TEST_QWEN_TRELLIS_REFERENCE",
  "MLX_BUN_TEST_QWEN_TRELLIS_REFERENCE_SHA256"] as const;
const SPEC_KEYS = ["drafted", "accepted", "rejected", "targetCalls", "rounds", "acceptanceLengths", "draftedByPos", "acceptedByPos"] as const;
const TARGET_METADATA = ["config.json", "model.safetensors.index.json", "tokenizer.json", "tokenizer_config.json", "chat_template.jinja"];
type A = any;

interface Inputs { target: string; draft: string; reference: string; referenceSha256: string }
interface Pins { files: Record<string, string>; weights: Record<string, string> }
interface Reference {
  producer: string; schema: 1; mainRevision: string; graph: string;
  runtime: { mlx: string; architecture: string };
  artifacts: { target: Pins; draft: Pins };
  prompts: { text: string; ids: number[] }[];
  trajectories: { prompt: string; promptIds: number[]; greedy: number[]; logitsSha256: string[]; finite: boolean; vocab: number }[];
  mtp: { execution: "shared-b1"; depth: number; maxTokens: number; runs: { prompt: string; tokens: number[]; forwards: number[][]; spec: Record<string, unknown> }[] };
}

function optIn(env: Record<string, string | undefined>): Inputs | null {
  const values = optInAll(env, OPT_IN, "Qwen Trellis parity");
  if (!values) return null;
  const referenceSha256 = values[OPT_IN[3]];
  if (!isSha256(referenceSha256)) throw new Error(`${OPT_IN[3]} must be a lowercase SHA-256`);
  return { target: values[OPT_IN[0]], draft: values[OPT_IN[1]], reference: values[OPT_IN[2]], referenceSha256 };
}

/** Verify the reference and both artifacts it pins, wherever they now live. */
async function verifyInputs(inputs: Inputs): Promise<Reference> {
  const bytes = readFileSync(inputs.reference);
  assert.equal(sha256(bytes), inputs.referenceSha256, "reference SHA-256 differs from the supplied pin");
  const reference = JSON.parse(bytes.toString("utf8")) as Reference;
  assert.equal(reference.producer, "main-qwen-trellis-reference", "not a main-qwen-trellis-reference file");
  assert.equal(reference.schema, 1, "unsupported reference schema");
  assert(typeof reference.runtime?.mlx === "string" && reference.runtime.mlx && typeof reference.runtime?.architecture === "string" && reference.runtime.architecture,
    "reference runtime identity missing");
  const ids = (value: unknown, what: string) => assert(Array.isArray(value) && value.length > 0 && value.every(n => Number.isSafeInteger(n) && n >= 0), `${what}: expected token IDs`);
  assert(reference.prompts?.length > 0, "reference has no prompts");
  reference.prompts.forEach((p, i) => ids(p.ids, `prompt ${i}`));
  assert.equal(reference.trajectories?.length, reference.prompts.length, "a trajectory per prompt is required");
  reference.trajectories.forEach((t, i) => {
    assert.deepEqual(t.promptIds, reference.prompts[i]!.ids, `trajectory ${i}: prompt IDs differ from the prompt`);
    ids(t.greedy, `trajectory ${i} greedy`);
    assert.equal(t.logitsSha256?.length, t.greedy.length, `trajectory ${i}: a logits hash per step is required`);
    t.logitsSha256.forEach(h => assert(isSha256(h), `trajectory ${i}: invalid logits SHA-256`));
    assert.equal(t.finite, true, `trajectory ${i}: main's logits were not all finite`);
    assert(Number.isSafeInteger(t.vocab) && t.vocab > 0, `trajectory ${i}: vocabulary`);
  });
  assert.equal(reference.mtp?.execution, "shared-b1", "MTP reference must use the same shared batch-one execution shape");
  assert.equal(reference.mtp?.runs?.length, reference.prompts.length, "an MTP run per prompt is required");
  assert(Number.isSafeInteger(reference.mtp.depth) && reference.mtp.depth >= 1, "MTP depth");
  reference.mtp.runs.forEach((run, i) => {
    ids(run.tokens, `mtp run ${i} tokens`);
    assert.equal(run.tokens.length, reference.mtp.maxTokens, `mtp run ${i}: expected ${reference.mtp.maxTokens} tokens`);
    assert(Array.isArray(run.forwards) && run.forwards.length > 1 && run.forwards.every(row => Array.isArray(row) && row.length > 0), `mtp run ${i}: target forwards`);
    for (const key of SPEC_KEYS) assert(key in (run.spec ?? {}), `mtp run ${i}: spec.${key} missing`);
  });
  await verifyArtifact(inputs.target, reference.artifacts?.target, TARGET_METADATA);
  await verifyArtifact(inputs.draft, reference.artifacts?.draft, ["config.json"]);
  return reference;
}

const inputs = optIn(Bun.env);

test.skipIf(!inputs)("Qwen3.8 packed-Trellis: logits, greedy tokens and MTP speculation equal main's", async () => {
  const reference = await verifyInputs(inputs!);
  const ffi = await import("@mlx-bun/mlx/ffi");
  assert(ffi.MLX_VERSION === reference.runtime.mlx && ffi.deviceArchitecture() === reference.runtime.architecture,
    `reference/runtime mismatch: the reference was produced with MLX ${reference.runtime.mlx} on ${reference.runtime.architecture}, ` +
    `this runtime is MLX ${ffi.MLX_VERSION} on ${ffi.deviceArchitecture()}; supply a reference generated on a matching runtime`);
  const { loadModelConfig, loadTokenizer, ChatTemplate, Weights, createModel } = await import("@mlx-bun/inference");
  const { QwenMtpProvider } = await import("@mlx-bun/inference/generation/speculative");
  const { bindMlxGateway } = await import("@mlx-bun/inference/execution");
  const { argmaxLastPosition, lastPositionLogits } = await import("@mlx-bun/inference/scoring");
  const { Qwen38TrellisTQ } = await import("@mlx-bun/inference/models/qwen38-27b-trellis-tq");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");

  const config = await loadModelConfig(inputs!.target);
  const tokenizer = await loadTokenizer(inputs!.target), template = await ChatTemplate.load(inputs!.target);
  for (const prompt of reference.prompts) {
    const ids: number[] = tokenizer.encode(template.render([{ role: "user", content: prompt.text }], { enableThinking: false }));
    expect(ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId ? ids.slice(1) : ids, prompt.text).toEqual(prompt.ids);
  }

  const weights = await Weights.open(inputs!.target);
  const releases: Array<() => void> = [];
  const report: Record<string, unknown> = {};
  try {
    const model = createModel(weights, config) as A;
    // The purpose-built graph main selected must be the one this tree selects too.
    expect(model).toBeInstanceOf(Qwen38TrellisTQ);
    report.graph = model.constructor.name;

    // Greedy trajectories, full logits by hash.
    let steps = 0;
    for (const [i, trajectory] of reference.trajectories.entries()) {
      const cache = model.makeCache();
      try {
        let tokens = trajectory.promptIds;
        for (let step = 0; step < trajectory.greedy.length; step++) {
          const out = model.forward(tokens, cache);
          let next: number;
          try {
            const last: Float32Array = lastPositionLogits(out);
            expect(last.length, `trajectory ${i} step ${step}: width`).toBe(trajectory.vocab);
            expect(last.every(Number.isFinite), `trajectory ${i} step ${step}: finite`).toBe(true);
            expect(sha256(new Uint8Array(last.buffer, last.byteOffset, last.byteLength)), `trajectory ${i} step ${step}: logits differ from main's bytes`)
              .toBe(trajectory.logitsSha256[step]!);
            next = argmaxLastPosition(out);
          } finally { out.dispose(); }
          expect(next, `trajectory ${i} step ${step}: greedy token`).toBe(trajectory.greedy[step]!);
          tokens = [next];
          steps++;
        }
      } finally { releaseAll(cache.map((c: A) => () => c.dispose())); clearCache(); }
    }
    report.trajectorySteps = steps;

    // Native MTP through the gateway binding, one request at a time.
    const provider = await QwenMtpProvider.load(inputs!.draft);
    releases.push(() => provider.dispose());
    let forwards: number[][] = [];
    const forwardHidden = model.forwardHidden.bind(model);
    const spy = spyOn(model, "forwardHidden").mockImplementation((input: A, caches: A[], ...rest: A[]) => {
      forwards.push(input.toIntTokens() as number[]);
      return forwardHidden(input, caches, ...rest);
    });
    releases.push(() => spy.mockRestore());
    const binding = bindMlxGateway(model, { provider, numDraftTokens: reference.mtp.depth });
    const options = { temperature: 0, maxTokens: reference.mtp.maxTokens };
    const rounds: unknown[] = [];
    for (const [i, run] of reference.mtp.runs.entries()) {
      forwards = [];
      const plan = binding.plan({ hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
        kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: true }, options,
      { continuous: true, quantizedBatch: false, checkpoints: false });
      assert.equal(plan.method, "speculative");
      const method = binding.methodRequest!(plan, options);
      assert(method, "the MTP method must bind");
      const group = binding.createBatchGroup({ maxBatch: 1 });
      const tokens: number[] = [];
      let result: A;
      try {
        result = await group.submit({ method, promptIds: reference.prompts[i]!.ids, maxTokens: reference.mtp.maxTokens, eosTokenIds: [],
          onToken(token: number) { tokens.push(token); } });
      } finally { await group.close(); }
      expect(tokens, `mtp run ${i}: emitted tokens`).toEqual(run.tokens);
      expect(forwards, `mtp run ${i}: target forwards (prefill, then [pending, ...proposals] per round)`).toEqual(run.forwards);
      const spec = Object.fromEntries(SPEC_KEYS.map(key => [key, result.spec?.[key] ?? null]));
      expect(spec, `mtp run ${i}: speculation counters`).toEqual(Object.fromEntries(SPEC_KEYS.map(key => [key, run.spec[key]])));
      rounds.push({ accepted: spec.accepted, drafted: spec.drafted, rounds: spec.rounds });
      clearCache();
    }
    report.mtp = rounds;
  } finally {
    try { releaseAll(releases.reverse()); } finally {
      try { weights.dispose(); } finally {
        releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap()).concat([() => clearCache()]));
      }
    }
  }
  console.log(JSON.stringify({ status: "pass", ...report, referenceSha256: inputs!.referenceSha256, mainRevision: reference.mainRevision,
    mlx: ffi.MLX_VERSION, architecture: ffi.deviceArchitecture(), bun: Bun.version }));
}, 3_600_000);

// ---- CPU-only validation (synthetic inputs; no native libraries) ------------------------
function synthetic() {
  const root = mkdtempSync(join(tmpdir(), "qwen-trellis-parity-"));
  const target = join(root, "target"), draft = join(root, "draft");
  mkdirSync(target); mkdirSync(draft);
  const files = Object.fromEntries(TARGET_METADATA.map(name => [name, `${name} contents`]));
  files["model.safetensors.index.json"] = JSON.stringify({ weight_map: { "a.weight": "model-00001-of-00002.safetensors", "b.weight": "model-00002-of-00002.safetensors" } });
  for (const [name, text] of Object.entries(files)) writeFileSync(join(target, name), text);
  writeFileSync(join(target, "model-00001-of-00002.safetensors"), "shard-one");
  writeFileSync(join(target, "model-00002-of-00002.safetensors"), "shard-two");
  writeFileSync(join(draft, "config.json"), "draft config");
  writeFileSync(join(draft, "model.safetensors"), "draft weights");
  const h = "a".repeat(64);
  const reference: Reference = {
    producer: "main-qwen-trellis-reference", schema: 1, mainRevision: "rev", graph: "Qwen38TrellisTQ", runtime: { mlx: "0.32.2", architecture: "applegpu_g13s" },
    artifacts: {
      target: { files: Object.fromEntries(Object.entries(files).map(([name, text]) => [name, sha256(text)])),
        weights: { "model-00001-of-00002.safetensors": sha256("shard-one"), "model-00002-of-00002.safetensors": sha256("shard-two") } },
      draft: { files: { "config.json": sha256("draft config") }, weights: { "model.safetensors": sha256("draft weights") } },
    },
    prompts: [{ text: "p", ids: [1, 2, 3] }],
    trajectories: [{ prompt: "p", promptIds: [1, 2, 3], greedy: [4, 5], logitsSha256: [h, h], finite: true, vocab: 8 }],
    mtp: { execution: "shared-b1", depth: 2, maxTokens: 3, runs: [{ prompt: "p", tokens: [4, 5, 6], forwards: [[1, 2, 3], [6, 7, 8]],
      spec: Object.fromEntries(SPEC_KEYS.map(key => [key, 0])) }] },
  };
  const pin = () => { const text = JSON.stringify(reference); writeFileSync(join(root, "reference.json"), text); return sha256(text); };
  return { root, target, draft, reference, pin, inputs: (): Inputs => ({ target, draft, reference: join(root, "reference.json"), referenceSha256: pin() }) };
}
type Synthetic = ReturnType<typeof synthetic>;
async function rejects(change: (s: Synthetic) => Inputs | void, message: string) {
  const s = synthetic();
  try {
    const changed = change(s) ?? s.inputs();
    await expect(verifyInputs(changed)).rejects.toThrow(message);
  } finally { rmSync(s.root, { recursive: true, force: true }); }
}

test("opt-in is all or nothing (CPU only)", () => {
  expect(optIn({})).toBeNull();
  const full = { [OPT_IN[0]]: "/t", [OPT_IN[1]]: "/d", [OPT_IN[2]]: "/r.json", [OPT_IN[3]]: "a".repeat(64) };
  expect(optIn(full)).toEqual({ target: "/t", draft: "/d", reference: "/r.json", referenceSha256: "a".repeat(64) });
  expect(() => optIn({ [OPT_IN[0]]: "/t" })).toThrow("missing or blank");
  expect(() => optIn({ ...full, [OPT_IN[1]]: " " })).toThrow(`missing or blank: ${OPT_IN[1]}`);
  expect(() => optIn({ ...full, [OPT_IN[3]]: "A".repeat(64) })).toThrow("lowercase SHA-256");
});

test("a relocated identical reference and artifacts verify (CPU only)", async () => {
  const s = synthetic();
  try {
    const moved = join(s.root, "moved");
    cpSync(s.target, join(moved, "t"), { recursive: true });
    cpSync(s.draft, join(moved, "d"), { recursive: true });
    const verified = await verifyInputs({ ...s.inputs(), target: join(moved, "t"), draft: join(moved, "d") });
    expect(verified.trajectories[0]!.greedy).toEqual([4, 5]);
  } finally { rmSync(s.root, { recursive: true, force: true }); }
});

test("altered, incomplete or mismatched inputs fail before any native load (CPU only)", async () => {
  await rejects(s => ({ ...s.inputs(), referenceSha256: "0".repeat(64) }), "reference SHA-256 differs");
  await rejects(s => { s.reference.schema = 2 as 1; }, "unsupported reference schema");
  await rejects(s => { s.reference.producer = "other"; }, "not a main-qwen-trellis-reference file");
  await rejects(s => { s.reference.trajectories[0]!.logitsSha256.pop(); }, "a logits hash per step");
  await rejects(s => { s.reference.trajectories[0]!.logitsSha256[1] = "xyz"; }, "invalid logits SHA-256");
  await rejects(s => { s.reference.trajectories[0]!.finite = false; }, "were not all finite");
  await rejects(s => { s.reference.trajectories[0]!.promptIds = [9]; }, "prompt IDs differ from the prompt");
  await rejects(s => { s.reference.trajectories = []; }, "a trajectory per prompt");
  await rejects(s => { s.reference.mtp.runs[0]!.tokens.pop(); }, "expected 3 tokens");
  await rejects(s => { delete s.reference.mtp.runs[0]!.spec.acceptanceLengths; }, "spec.acceptanceLengths missing");
  await rejects(s => { s.reference.mtp.execution = "serial" as "shared-b1"; }, "same shared batch-one execution shape");
  await rejects(s => { s.reference.mtp.runs = []; }, "an MTP run per prompt");
  await rejects(s => { s.reference.runtime.architecture = ""; }, "runtime identity missing");
  await rejects(s => { writeFileSync(join(s.target, "tokenizer.json"), "changed"); }, "model file tokenizer.json differs");
  await rejects(s => { writeFileSync(join(s.target, "model-00002-of-00002.safetensors"), "other"); }, "weights model-00002-of-00002.safetensors differ");
  await rejects(s => { writeFileSync(join(s.draft, "model.safetensors"), "other"); }, "weights model.safetensors differ");
  await rejects(s => { rmSync(join(s.draft, "model.safetensors")); }, "model.safetensors");
  await rejects(s => { delete s.reference.artifacts.target.files["chat_template.jinja"]; }, "artifact pins do not include chat_template.jinja");
});
