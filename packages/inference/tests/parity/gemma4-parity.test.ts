// Gemma4 12B greedy decode against an external mlx-lm reference: batch one,
// plain KV from the model's own makeCache (the artifact's kv_config.json is not
// applied), the prompt once and then each selected token on the same live cache.
// Two entry points, each checked on its own:
//   - createModel, the production dispatch: a 100-token greedy trajectory whose
//     first four full-vocabulary f32 vectors must match bit for bit;
//   - new Gemma4Model, the dedicated graph: a 12-step control, first four
//     vectors bit for bit.
// At every step the whole vector must be finite and its argmax must be the
// reference token, which is then fed. This is a 100-token trajectory plus four
// vectors and a separate 12-step control, not 100-step full-vector parity. For
// this artifact createModel selects the generated 12B graph, whose unrolled path
// serves only the quantized kv_config cache layout; under plain KV it takes its
// monolith fallback, and both entry points assert the unrolled path never ran.
// The model and reference stay outside this repository; Python never runs.
// Opt in with all three of
//   MLX_BUN_TEST_GEMMA4_MODEL=/model/snapshot
//   MLX_BUN_TEST_GEMMA4_REFERENCE=/reference/dir (gemma4-parity.json, the
//     producer's unchanged parity.json and logits-step0..3.bin)
//   MLX_BUN_TEST_GEMMA4_REFERENCE_SHA256=<gemma4-parity.json SHA-256>
// None set skips; any other combination fails. Every input is verified before
// native libraries load: the reference, its producer provenance, the pinned
// model files, tokenizer and exactly the index's shards, and every vector.
import { expect, test } from "bun:test";
import { strict as assert } from "node:assert";
import { cpSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { isSha256, optInAll, releaseAll, sha256, verifyArtifact } from "./real-weight-inputs";

const TRAJECTORY = 100, VECTORS = 4, CONTROL = 12;
const MANIFEST = "gemma4-parity.json", CAPTURE = "parity.json";
// The artifact this consumer covers: gemma-4-12B-it OptiQ-4bit (text path).
const VOCAB = 262_144, LAYERS = 48, WINDOW = 1024;
// Required pins; any further pinned file is verified too.
const METADATA = ["config.json", "model.safetensors.index.json", "tokenizer.json", "tokenizer_config.json"];
// Producer packages and the oracle field that carries each version.
const PACKAGES = { "mlx": "mlx", "mlx-lm": "mlx_lm", "mlx-optiq": "optiq" } as const;
const OPT_IN = ["MLX_BUN_TEST_GEMMA4_MODEL", "MLX_BUN_TEST_GEMMA4_REFERENCE", "MLX_BUN_TEST_GEMMA4_REFERENCE_SHA256"] as const;
const blobName = (step: number) => `logits-step${step}.bin`;

interface Inputs { model: string; reference: string; manifestSha256: string }
interface Oracle {
  mlx: string; mlx_lm: string; optiq: string; device: { architecture: string }; config_sha256: string;
  model_files_sha256: Record<string, string>; weights_sha256: Record<string, string>; blobs: Record<string, string>;
  provenance: {
    producer: { script: string; script_sha256: string; revision: string };
    packages: Record<string, { version: string; files_sha256: Record<string, string> }>;
    capture: Record<string, string>;
  };
}
interface Manifest { prompt: string; prompt_ids: number[]; greedy_ids: number[]; logit_steps: number; vocab_size: number; oracle: Oracle }

function optIn(env: Record<string, string | undefined>): Inputs | null {
  const values = optInAll(env, OPT_IN, "Gemma4 parity");
  if (!values) return null;
  const manifestSha256 = values[OPT_IN[2]];
  if (!isSha256(manifestSha256)) throw new Error(`${OPT_IN[2]} must be a lowercase SHA-256`);
  return { model: values[OPT_IN[0]], reference: values[OPT_IN[1]], manifestSha256 };
}

/** The producer's own record must be the one the consumer manifest describes. */
function verifyProvenance(reference: string, manifest: Manifest): void {
  const oracle = manifest.oracle, p = oracle.provenance;
  assert(typeof p?.producer?.script === "string" && p.producer.script.length > 0 && isSha256(p.producer.script_sha256) &&
    /^[0-9a-f]{40}$/.test(p.producer.revision ?? ""), "reference producer provenance missing or malformed");
  for (const [name, field] of Object.entries(PACKAGES)) {
    const entry = p.packages?.[name];
    assert(typeof entry?.version === "string" && entry.version === oracle[field], `reference provenance: ${name} version differs from oracle.${field}`);
    const files = Object.entries(entry.files_sha256 ?? {});
    assert(files.length > 0 && files.every(([, pin]) => isSha256(pin)), `reference provenance: ${name} source files missing or malformed`);
  }
  assert.deepEqual(Object.keys(p.capture ?? {}), [CAPTURE], "reference provenance must pin exactly the producer's parity.json");
  const bytes = readFileSync(join(reference, CAPTURE));
  assert.equal(sha256(bytes), p.capture[CAPTURE], "parity.json differs from its pin");
  const capture = JSON.parse(bytes.toString("utf8"));
  for (const key of ["prompt", "prompt_ids", "greedy_ids", "logit_steps", "vocab_size"] as const)
    assert.deepEqual(capture[key], manifest[key], `parity.json ${key} differs from the manifest`);
  for (const key of ["mlx", "mlx_lm", "optiq", "config_sha256", "blobs"] as const)
    assert.deepEqual(capture.oracle?.[key], oracle[key], `parity.json oracle.${key} differs from the manifest`);
  assert.equal(capture.oracle?.device?.architecture, oracle.device.architecture, "parity.json device differs from the manifest");
}

/** Verify the reference, its provenance and the model artifacts it pins, wherever
 * they now live. Returns the verified vectors: nothing is re-read afterwards. */
async function verifyInputs(inputs: Inputs): Promise<{ manifest: Manifest; vectors: Float32Array[] }> {
  const bytes = readFileSync(join(inputs.reference, MANIFEST));
  assert.equal(sha256(bytes), inputs.manifestSha256, "reference manifest SHA-256 differs from the supplied pin");
  const manifest = JSON.parse(bytes.toString("utf8")) as Manifest;
  assert(Number.isSafeInteger(manifest.vocab_size) && manifest.vocab_size > 0, "invalid vocab_size");
  const ids = (value: unknown, what: string) => assert(Array.isArray(value) && value.length > 0 &&
    value.every(n => Number.isSafeInteger(n) && n >= 0 && n < manifest.vocab_size), `${what}: expected token IDs in [0, ${manifest.vocab_size})`);
  assert.equal(manifest.logit_steps, VECTORS, "reference must record 4 logit vectors");
  ids(manifest.greedy_ids, "greedy_ids");
  assert.equal(manifest.greedy_ids.length, TRAJECTORY, "reference must record 100 greedy IDs");
  ids(manifest.prompt_ids, "prompt_ids");
  assert(typeof manifest.prompt === "string" && manifest.prompt.length > 0, "reference prompt missing");
  const oracle = manifest.oracle;
  assert(typeof oracle?.mlx === "string" && oracle.mlx && typeof oracle.device?.architecture === "string" && oracle.device.architecture &&
    typeof oracle.mlx_lm === "string" && oracle.mlx_lm && typeof oracle.optiq === "string" && oracle.optiq, "reference runtime identity missing");
  assert(Object.keys(oracle.model_files_sha256 ?? {}).length > 0 && Object.keys(oracle.weights_sha256 ?? {}).length > 0,
    "reference pins no model files");
  verifyProvenance(inputs.reference, manifest);

  assert(isSha256(oracle.config_sha256), "config_sha256: invalid SHA-256");
  assert.equal(oracle.model_files_sha256["config.json"], oracle.config_sha256, "config pins disagree");
  await verifyArtifact(inputs.model, { files: oracle.model_files_sha256, weights: oracle.weights_sha256 }, METADATA);
  const config = JSON.parse(readFileSync(join(inputs.model, "config.json"), "utf8")) as { vocab_size?: number; text_config?: { vocab_size?: number } };
  assert.equal(config.text_config?.vocab_size ?? config.vocab_size, manifest.vocab_size, "reference vocabulary differs from the model config");

  const names = Array.from({ length: VECTORS }, (_, step) => blobName(step));
  assert.deepEqual(Object.keys(oracle.blobs ?? {}).sort(), [...names].sort(), "reference must pin exactly the 4 logit vectors");
  const vectors = names.map(name => {
    const blob = readFileSync(join(inputs.reference, name));
    assert.equal(blob.byteLength, manifest.vocab_size * 4, `${name}: expected ${manifest.vocab_size} f32 values`);
    assert.equal(sha256(blob), oracle.blobs[name], `${name} differs from its pin`);
    const values = new Float32Array(new Uint8Array(blob).buffer); // an aligned copy that owns its bytes
    assert(values.every(Number.isFinite), `${name}: non-finite reference logit`);
    return values;
  });
  return { manifest, vectors };
}

/** The pinned tokenizer must encode the reference prompt to its IDs (no native code). */
async function checkTokenizer(model: string, manifest: Manifest): Promise<void> {
  const { loadTokenizer } = await import("../../src/input/tokenizer");
  const tokenizer = await loadTokenizer(model);
  assert.deepEqual(tokenizer.encode(manifest.prompt), manifest.prompt_ids, "the model's tokenizer does not encode the reference prompt to its IDs");
}

/** A bit-exact reference is specific to the MLX version and GPU family that produced it. */
function checkRuntime(manifest: Manifest, runtime: { mlxVersion: string; architecture: string }): void {
  const produced = `MLX ${manifest.oracle.mlx} on ${manifest.oracle.device.architecture}`;
  assert(runtime.mlxVersion === manifest.oracle.mlx && runtime.architecture === manifest.oracle.device.architecture,
    `reference/runtime mismatch: the reference was produced with ${produced}, this runtime is MLX ${runtime.mlxVersion} ` +
    `on ${runtime.architecture}; supply a reference generated on a matching runtime`);
}

/** Every step: full width and every value finite. */
function checkFinite(step: number, actual: Float32Array, width: number): void {
  assert.equal(actual.length, width, `step ${step}: logit width ${actual.length}, reference ${width}`);
  assert(actual.every(Number.isFinite), `step ${step}: non-finite logit`);
}

/** A vector step: finite on both sides, then identical bytes, so equal NaN or
 * infinite payloads and -0/+0 can never pass as equal. */
function compareStep(step: number, actual: Float32Array, expected: Float32Array): void {
  checkFinite(step, actual, expected.length);
  assert(expected.every(Number.isFinite), `step ${step}: non-finite logit`);
  const bytes = (values: Float32Array) => Buffer.from(values.buffer, values.byteOffset, values.byteLength);
  assert(bytes(actual).equals(bytes(expected)), `step ${step}: logits differ bitwise`);
}

/** Plain caches from the model for the pinned geometry: a window-sized rotating
 * cache per sliding layer, an unbounded one per full layer, nothing quantized. */
function checkPlainCaches(caches: readonly unknown[], layerTypes: readonly string[],
  classes: { KVCache: abstract new (...args: never[]) => unknown; RotatingKVCache: abstract new (...args: never[]) => unknown }): void {
  assert.equal(caches.length, LAYERS, `${caches.length} caches, expected ${LAYERS}`);
  caches.forEach((cache, layer) => {
    const sliding = layerTypes[layer] === "sliding_attention";
    const plain = sliding ? cache instanceof classes.RotatingKVCache && (cache as { maxSize: number }).maxSize === WINDOW
      : (cache as object)?.constructor === classes.KVCache;
    assert(plain, `layer ${layer}: expected a plain ${sliding ? `rotating (window ${WINDOW})` : "full"} cache`);
  });
}

/** Caches, the model, the weights, then the shard mappings Weights.dispose leaves
 * mapped: every release runs even if an earlier one throws; the first failure wins. */
function releaseEntry(caches: ReadonlyArray<{ dispose(): void }>, model: { dispose?(): void } | null,
  weights: { dispose(): void; shards: { files: Map<string, { mmap: { unmap(): void } }> } }): void {
  releaseAll([() => releaseAll(caches.map(entry => () => entry.dispose())), () => model?.dispose?.(), () => weights.dispose(),
    () => releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap()))]);
}

const inputs = optIn(Bun.env);

/** One entry point: verified inputs, matching runtime, plain caches, `steps`
 * greedy steps from the prompt with the first four vectors compared. */
async function runEntry(entry: "createModel" | "Gemma4Model", steps: number) {
  const { manifest, vectors } = await verifyInputs(inputs!);
  expect(manifest.vocab_size).toBe(VOCAB);
  await checkTokenizer(inputs!.model, manifest);
  const ffi = await import("@mlx-bun/mlx/ffi");
  checkRuntime(manifest, { mlxVersion: ffi.MLX_VERSION, architecture: ffi.deviceArchitecture() });
  const { loadModelConfig, Weights, createModel } = await import("@mlx-bun/inference");
  const { Gemma4Model } = await import("@mlx-bun/inference/models/gemma4");
  const { argmaxLastPosition, lastPositionLogits } = await import("@mlx-bun/inference/scoring");
  const { KVCache } = await import("../../src/state/kv");
  const { RotatingKVCache } = await import("../../src/state/rotating-kv");
  const generated = await import("../../src/models/gemma4/generated/gemma4-12b");

  const config = await loadModelConfig(inputs!.model);
  expect([config.text.numHiddenLayers, config.text.numKvSharedLayers, config.text.slidingWindow, config.text.vocabSize])
    .toEqual([LAYERS, 0, WINDOW, VOCAB]);
  const weights = await Weights.open(inputs!.model);
  let model: InstanceType<typeof Gemma4Model> | null = null, caches: Array<{ dispose(): void }> = [];
  const greedy: number[] = [];
  let vectorsCompared = 0;
  const unrolledBefore = generated.generatedForwardUses;
  try {
    model = entry === "createModel" ? createModel(weights, config) as InstanceType<typeof Gemma4Model> : new Gemma4Model(weights, config);
    if (entry === "createModel") expect(model).toBeInstanceOf(generated.GeneratedGemma4);
    else expect(model).not.toBeInstanceOf(generated.GeneratedGemma4);
    const layers = model.makeCache();
    caches = layers;
    checkPlainCaches(layers, config.text.layerTypes, { KVCache, RotatingKVCache });
    let tokens = manifest.prompt_ids;
    for (let step = 0; step < steps; step++) {
      const logits = model.forward(tokens, layers);
      let next: number;
      try {
        const actual = lastPositionLogits(logits);
        checkFinite(step, actual, manifest.vocab_size);
        if (step < VECTORS) { compareStep(step, actual, vectors[step]!); vectorsCompared++; }
        next = argmaxLastPosition(logits);
      } finally { logits.dispose(); }
      assert.equal(next, manifest.greedy_ids[step], `step ${step}: greedy token`);
      greedy.push(next);
      tokens = [next];
    }
  } finally { releaseEntry(caches, model, weights); }
  // Plain KV never matches the unrolled graph's cache layout.
  expect(generated.generatedForwardUses).toBe(unrolledBefore);
  expect(greedy).toHaveLength(steps);
  expect(vectorsCompared).toBe(VECTORS);
  console.log(JSON.stringify({ status: "pass", entry, steps: greedy.length, vectorsCompared, valuesCompared: VECTORS * VOCAB,
    scope: entry === "createModel" ? "100-token greedy trajectory + 4 full vectors" : "12-step dedicated-graph control + 4 full vectors",
    unrolledForwards: 0, promptTokens: manifest.prompt_ids.length, batch: 1, kv: "plain", greedyIds: greedy,
    manifestSha256: inputs!.manifestSha256, mlx: ffi.MLX_VERSION, architecture: ffi.deviceArchitecture(), bun: Bun.version }));
}

test.skipIf(!inputs)("Gemma4 12B createModel: 100-token greedy trajectory, first 4 full-vocabulary vectors bit for bit", async () => {
  await runEntry("createModel", TRAJECTORY);
}, 600_000);

test.skipIf(!inputs)("Gemma4 12B dedicated graph: 12-step greedy control, first 4 full-vocabulary vectors bit for bit", async () => {
  await runEntry("Gemma4Model", CONTROL);
}, 300_000);

// ---- CPU-only validation (synthetic inputs; no native libraries) ------------------------
const SHARDS = ["model-00001-of-00002.safetensors", "model-00002-of-00002.safetensors"];
function synthetic() {
  const root = mkdtempSync(join(tmpdir(), "gemma4-parity-")), model = join(root, "model"), reference = join(root, "reference");
  mkdirSync(model);
  mkdirSync(reference);
  const vocab = 4;
  const files: Record<string, string> = {
    ...Object.fromEntries(METADATA.map(name => [name, `${name} contents`])),
    "config.json": JSON.stringify({ model_type: "gemma4_unified", text_config: { vocab_size: vocab } }),
    "model.safetensors.index.json": JSON.stringify({ weight_map: { "a.weight": SHARDS[0], "b.weight": SHARDS[1] } }),
  };
  for (const [name, text] of Object.entries(files)) writeFileSync(join(model, name), text);
  for (const shard of SHARDS) writeFileSync(join(model, shard), `${shard} bytes`);
  const blobs: Record<string, string> = {};
  for (let step = 0; step < VECTORS; step++) {
    const blob = Buffer.from(Float32Array.from({ length: vocab }, (_, i) => step + i / 8).buffer);
    writeFileSync(join(reference, blobName(step)), blob);
    blobs[blobName(step)] = sha256(blob);
  }
  const base = { prompt: "p", prompt_ids: [0, 1], greedy_ids: Array.from({ length: TRAJECTORY }, (_, i) => i % vocab),
    logit_steps: VECTORS, vocab_size: vocab };
  const runtime = { mlx: "0.32.2", mlx_lm: "0.31.3", optiq: "0.2.7", device: { architecture: "applegpu_g13s" },
    config_sha256: sha256(files["config.json"]!), blobs };
  // The producer's record, as scripts/regen/parity.ts writes it.
  const capture = { ...base, oracle: { model: "/original/location", ...runtime } };
  const manifest: Manifest = {
    ...structuredClone(base),
    oracle: { ...structuredClone(runtime),
      model_files_sha256: Object.fromEntries(Object.entries(files).map(([name, text]) => [name, sha256(text)])),
      weights_sha256: Object.fromEntries(SHARDS.map(shard => [shard, sha256(`${shard} bytes`)])),
      provenance: {
        producer: { script: "scripts/regen/parity.ts", script_sha256: sha256("script"), revision: "a".repeat(40) },
        packages: Object.fromEntries(Object.entries(PACKAGES).map(([name, field]) =>
          [name, { version: runtime[field], files_sha256: { [`${name}/__init__.py`]: sha256(name) } }])),
        capture: {},
      } },
  };
  const writeCapture = () => {
    const text = JSON.stringify(capture);
    writeFileSync(join(reference, CAPTURE), text);
    manifest.oracle.provenance.capture = { [CAPTURE]: sha256(text) };
  };
  writeCapture();
  const pin = () => { const text = JSON.stringify(manifest); writeFileSync(join(reference, MANIFEST), text); return sha256(text); };
  return { root, model, reference, manifest, capture, writeCapture, pin, inputs: (): Inputs => ({ model, reference, manifestSha256: pin() }) };
}
type Synthetic = ReturnType<typeof synthetic>;
async function rejects(change: (s: Synthetic) => Inputs | void, message: string) {
  const s = synthetic();
  try {
    const inputs = change(s) ?? s.inputs();
    await expect(verifyInputs(inputs)).rejects.toThrow(message);
  } finally { rmSync(s.root, { recursive: true, force: true }); }
}
const rewriteBlob = (s: Synthetic, step: number, values: number[]) => {
  const blob = Buffer.from(Float32Array.from(values).buffer);
  writeFileSync(join(s.reference, blobName(step)), blob);
  s.manifest.oracle.blobs[blobName(step)] = sha256(blob);
  s.capture.oracle.blobs[blobName(step)] = sha256(blob);
  s.writeCapture();
};

test("opt-in is all or nothing (CPU only)", () => {
  expect(optIn({})).toBeNull();
  const full = { [OPT_IN[0]]: "/m", [OPT_IN[1]]: "/r", [OPT_IN[2]]: "a".repeat(64) };
  expect(optIn(full)).toEqual({ model: "/m", reference: "/r", manifestSha256: "a".repeat(64) });
  expect(() => optIn({ [OPT_IN[0]]: "/m" })).toThrow("missing or blank");
  expect(() => optIn({ ...full, [OPT_IN[1]]: " " })).toThrow(`missing or blank: ${OPT_IN[1]}`);
  expect(() => optIn({ ...full, [OPT_IN[2]]: "A".repeat(64) })).toThrow("lowercase SHA-256");
});

test("a relocated identical model and reference verify; recorded paths are informational (CPU only)", async () => {
  const s = synthetic();
  try {
    const moved = join(s.root, "relocated");
    cpSync(s.model, moved, { recursive: true });
    const { manifest, vectors } = await verifyInputs({ ...s.inputs(), model: moved });
    expect(vectors).toHaveLength(VECTORS);
    expect(manifest.greedy_ids).toHaveLength(TRAJECTORY);
  } finally { rmSync(s.root, { recursive: true, force: true }); }
});

test("a capture without artifact, tokenizer or producer pins cannot qualify (CPU only)", async () => {
  // The shape of the retained main capture: its record alone, used as the manifest.
  await rejects(s => { const text = JSON.stringify(s.capture); writeFileSync(join(s.reference, MANIFEST), text);
    return { model: s.model, reference: s.reference, manifestSha256: sha256(text) }; }, "reference pins no model files");
  await rejects(s => { delete (s.manifest.oracle as Partial<Oracle>).provenance; }, "producer provenance missing");
});

test("incomplete, altered or mismatched references fail before any native load (CPU only)", async () => {
  await rejects(s => ({ ...s.inputs(), manifestSha256: "0".repeat(64) }), "manifest SHA-256 differs");
  await rejects(s => { rmSync(join(s.reference, blobName(2))); }, blobName(2));
  await rejects(s => { writeFileSync(join(s.reference, blobName(3)), Buffer.from(new Float32Array(4).buffer)); }, `${blobName(3)} differs from its pin`);
  await rejects(s => { rewriteBlob(s, 1, [1, 2, 3, 4, 5]); }, `${blobName(1)}: expected 4 f32 values`);
  await rejects(s => { rewriteBlob(s, 0, [1, Number.NaN, 3, 4]); }, "non-finite reference logit");
  await rejects(s => { s.manifest.oracle.blobs[blobName(4)] = sha256("x"); s.capture.oracle.blobs[blobName(4)] = sha256("x"); s.writeCapture(); },
    "exactly the 4 logit vectors");
  await rejects(s => { s.manifest.logit_steps = 3; }, "4 logit vectors");
  await rejects(s => { s.manifest.greedy_ids[7] = 4; }, "greedy_ids: expected token IDs in [0, 4)");
  await rejects(s => { s.manifest.greedy_ids[7] = 1.5; }, "greedy_ids: expected token IDs");
  await rejects(s => { s.manifest.greedy_ids.pop(); }, "100 greedy IDs");
  await rejects(s => { s.manifest.prompt_ids = []; }, "prompt_ids: expected token IDs");
  await rejects(s => { s.manifest.prompt_ids = [-1]; }, "prompt_ids: expected token IDs");
  await rejects(s => { s.manifest.oracle.device.architecture = ""; }, "runtime identity missing");
  await rejects(s => { s.manifest.oracle.optiq = ""; }, "runtime identity missing");
});

test("producer provenance must be well formed and agree with the producer's record (CPU only)", async () => {
  await rejects(s => { s.manifest.oracle.provenance.producer.script_sha256 = "abc"; }, "producer provenance");
  await rejects(s => { s.manifest.oracle.provenance.producer.revision = "02d723a"; }, "producer provenance");
  await rejects(s => { s.manifest.oracle.provenance.producer.script = ""; }, "producer provenance");
  await rejects(s => { delete s.manifest.oracle.provenance.packages["mlx-optiq"]; }, "mlx-optiq version differs from oracle.optiq");
  await rejects(s => { s.manifest.oracle.provenance.packages["mlx-lm"]!.version = "0.31.2"; }, "mlx-lm version differs from oracle.mlx_lm");
  await rejects(s => { s.manifest.oracle.provenance.packages["mlx"]!.files_sha256 = {}; }, "mlx source files");
  await rejects(s => { s.manifest.oracle.provenance.packages["mlx"]!.files_sha256 = { "mlx/core.py": "x" }; }, "mlx source files");
  await rejects(s => { s.manifest.oracle.provenance.capture = {}; }, "pin exactly the producer's parity.json");
  await rejects(s => { s.manifest.oracle.provenance.capture["extra.json"] = sha256("e"); }, "pin exactly the producer's parity.json");
  await rejects(s => { writeFileSync(join(s.reference, CAPTURE), "{}"); }, "parity.json differs from its pin");
  await rejects(s => { s.capture.greedy_ids[3] = 0; s.writeCapture(); }, "parity.json greedy_ids differs from the manifest");
  await rejects(s => { s.capture.oracle.mlx = "0.31.2"; s.writeCapture(); }, "parity.json oracle.mlx differs");
  await rejects(s => { s.capture.oracle.blobs = { ...s.capture.oracle.blobs, [blobName(0)]: sha256("other") }; s.writeCapture(); },
    "parity.json oracle.blobs differs");
  await rejects(s => { s.capture.oracle.device = { architecture: "applegpu_g16s" }; s.writeCapture(); }, "parity.json device differs");
});

test("model files, tokenizer and exactly the index's shards are pinned by content (CPU only)", async () => {
  await rejects(s => { s.manifest.oracle.config_sha256 = s.capture.oracle.config_sha256 = "c".repeat(64); s.writeCapture(); }, "config pins disagree");
  await rejects(s => { s.manifest.vocab_size = 5; s.capture.vocab_size = 5; s.writeCapture(); }, "vocabulary differs from the model config");
  await rejects(s => { writeFileSync(join(s.model, "tokenizer.json"), "{\"changed\":true}"); }, "model file tokenizer.json differs");
  await rejects(s => { delete s.manifest.oracle.model_files_sha256["tokenizer_config.json"]; }, "artifact pins do not include tokenizer_config.json");
  await rejects(s => { writeFileSync(join(s.model, SHARDS[1]!), "other bytes"); }, `weights ${SHARDS[1]} differ`);
  await rejects(s => { delete s.manifest.oracle.weights_sha256[SHARDS[1]!]; }, "index shards differ");
  await rejects(s => {
    const text = JSON.stringify({ weight_map: { "a.weight": SHARDS[0], "b.weight": SHARDS[1], "c.weight": "model-00003-of-00003.safetensors" } });
    writeFileSync(join(s.model, "model.safetensors.index.json"), text);
    s.manifest.oracle.model_files_sha256["model.safetensors.index.json"] = sha256(text);
  }, "index shards differ");
});

test("the runtime must match the one that produced the reference (CPU only)", () => {
  const { manifest, root } = synthetic();
  try {
    checkRuntime(manifest, { mlxVersion: "0.32.2", architecture: "applegpu_g13s" });
    expect(() => checkRuntime(manifest, { mlxVersion: "0.31.2", architecture: "applegpu_g13s" }))
      .toThrow("reference/runtime mismatch: the reference was produced with MLX 0.32.2 on applegpu_g13s, this runtime is MLX 0.31.2");
    expect(() => checkRuntime(manifest, { mlxVersion: "0.32.2", architecture: "applegpu_g16s" })).toThrow("on applegpu_g16s; supply a reference");
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("a vector step passes only on identical finite bytes; every step must be finite (CPU only)", () => {
  const values = (...xs: number[]) => Float32Array.from(xs);
  compareStep(0, values(1, 2.5, -3, 0), values(1, 2.5, -3, 0));
  expect(() => compareStep(1, values(1, Number.NaN, 3, 4), values(1, Number.NaN, 3, 4))).toThrow("step 1: non-finite logit");
  expect(() => compareStep(2, values(1, Infinity, 3, 4), values(1, Infinity, 3, 4))).toThrow("non-finite");
  expect(() => compareStep(3, values(1, 2, 3, 4), values(1, 2, 3, -Infinity))).toThrow("non-finite");
  expect(() => compareStep(3, values(1, 0, 3, 4), values(1, -0, 3, 4))).toThrow("step 3: logits differ bitwise");
  expect(() => compareStep(0, values(1, 2, 3), values(1, 2, 3, 4))).toThrow("logit width 3, reference 4");
  checkFinite(57, values(1, 2, 3, 4), 4);
  expect(() => checkFinite(57, values(1, 2, Number.NaN, 4), 4)).toThrow("step 57: non-finite logit");
  expect(() => checkFinite(99, values(1, 2, 3), 4)).toThrow("step 99: logit width 3, reference 4");
});

test("only plain caches of the pinned geometry are accepted (CPU only)", () => {
  class KVCache {}
  class RotatingKVCache { constructor(readonly maxSize: number) {} }
  class QuantizedKVCache extends KVCache {}
  const types = Array.from({ length: LAYERS }, (_, i) => (i % 6 === 5 ? "full_attention" : "sliding_attention"));
  const caches = () => types.map(type => type === "sliding_attention" ? new RotatingKVCache(WINDOW) : new KVCache());
  checkPlainCaches(caches(), types, { KVCache, RotatingKVCache });
  expect(() => checkPlainCaches(caches().slice(1), types, { KVCache, RotatingKVCache })).toThrow("47 caches, expected 48");
  const quantized = caches(); quantized[5] = new QuantizedKVCache();
  expect(() => checkPlainCaches(quantized, types, { KVCache, RotatingKVCache })).toThrow("layer 5: expected a plain full cache");
  const narrow = caches(); narrow[0] = new RotatingKVCache(512);
  expect(() => checkPlainCaches(narrow, types, { KVCache, RotatingKVCache })).toThrow("layer 0: expected a plain rotating (window 1024) cache");
});

test("every owned resource is released even when a release throws (CPU only)", () => {
  const released: string[] = [];
  const cache = (name: string, fail = false) => ({ dispose() { released.push(name); if (fail) throw new Error(`${name} failed`); } });
  const weights = { dispose() { released.push("weights"); throw new Error("weights failed"); },
    shards: { files: new Map([["a", { mmap: { unmap() { released.push("unmap a"); } } }], ["b", { mmap: { unmap() { released.push("unmap b"); } } }]]) } };
  expect(() => releaseEntry([cache("c0"), cache("c1", true), cache("c2")], { dispose() { released.push("model"); } }, weights)).toThrow("c1 failed");
  expect(released).toEqual(["c0", "c1", "c2", "model", "weights", "unmap a", "unmap b"]);
});
