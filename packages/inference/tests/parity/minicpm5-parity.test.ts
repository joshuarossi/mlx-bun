// MiniCPM5 greedy decode parity against an external mlx-lm reference: 100 full
// f32 logit vectors and greedy IDs through the direct model forward, batch one,
// plain KV. The model, reference and oracle stay outside this repository; this
// test never starts Python. Opt in with all three of
//   MLX_BUN_TEST_MINICPM5_MODEL=/model/snapshot
//   MLX_BUN_TEST_MINICPM5_REFERENCE=/reference/dir (minicpm5-parity.json + 100 blobs)
//   MLX_BUN_TEST_MINICPM5_REFERENCE_SHA256=<manifest SHA-256>
// None set skips; any other combination fails. Every input is verified before
// native libraries load.
import { expect, test } from "bun:test";
import { strict as assert } from "node:assert";
import { createHash } from "node:crypto";
import { cpSync, createReadStream, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const STEPS = 100;
const MANIFEST = "minicpm5-parity.json";
// The artifact this consumer covers: MiniCPM5-1B OptiQ-4bit.
const VOCAB = 130_560, LAYERS = 24;
// The retained reference pins every metadata file of the artifact; more pins are welcome.
const METADATA = ["chat_template.jinja", "config.json", "generation_config.json", "kv_config.json",
  "model.safetensors.index.json", "optiq_metadata.json", "tokenizer.json", "tokenizer_config.json"];
const OPT_IN = ["MLX_BUN_TEST_MINICPM5_MODEL", "MLX_BUN_TEST_MINICPM5_REFERENCE", "MLX_BUN_TEST_MINICPM5_REFERENCE_SHA256"] as const;
const blobName = (step: number) => `minicpm5-logits-step${step}.bin`;
const sha256 = (bytes: string | Uint8Array) => createHash("sha256").update(bytes).digest("hex");
async function fileSha256(path: string): Promise<string> {
  const hash = createHash("sha256");
  for await (const chunk of createReadStream(path)) hash.update(chunk);
  return hash.digest("hex");
}

interface Inputs { model: string; reference: string; manifestSha256: string }
interface Manifest {
  prompt: string; prompt_ids: number[]; greedy_ids: number[]; logit_steps: number; vocab_size: number;
  oracle: {
    mlx: string; device: { architecture: string }; config_sha256: string;
    model_files_sha256: Record<string, string>; weights_sha256: Record<string, string>; blobs: Record<string, string>;
  };
}

function optIn(env: Record<string, string | undefined>): Inputs | null {
  const values = OPT_IN.map(name => env[name]);
  if (values.every(value => value === undefined)) return null;
  const missing = OPT_IN.filter((_, i) => !values[i]?.trim());
  if (missing.length) throw new Error(`MiniCPM5 parity needs all of ${OPT_IN.join(", ")}; missing or blank: ${missing.join(", ")}`);
  const [model, reference, manifestSha256] = values as [string, string, string];
  if (!/^[0-9a-f]{64}$/.test(manifestSha256)) throw new Error(`${OPT_IN[2]} must be a lowercase SHA-256`);
  return { model, reference, manifestSha256 };
}

/** Verify the reference and the model artifacts it pins, wherever they now live.
 * Returns the verified blobs: nothing is re-read after verification. */
async function verifyInputs(inputs: Inputs): Promise<{ manifest: Manifest; blobs: Float32Array[] }> {
  const bytes = readFileSync(join(inputs.reference, MANIFEST));
  assert.equal(sha256(bytes), inputs.manifestSha256, "reference manifest SHA-256 differs from the supplied pin");
  const manifest = JSON.parse(bytes.toString("utf8")) as Manifest;
  const hash = (value: unknown, what: string) => assert(typeof value === "string" && /^[0-9a-f]{64}$/.test(value), `${what}: invalid SHA-256`);
  assert(Number.isSafeInteger(manifest.vocab_size) && manifest.vocab_size > 0, "invalid vocab_size");
  const ids = (value: unknown, what: string) => assert(Array.isArray(value) && value.length > 0 &&
    value.every(n => Number.isSafeInteger(n) && n >= 0 && n < manifest.vocab_size), `${what}: expected token IDs in [0, ${manifest.vocab_size})`);
  assert.equal(manifest.logit_steps, STEPS, "reference must record 100 logit steps");
  ids(manifest.greedy_ids, "greedy_ids");
  assert.equal(manifest.greedy_ids.length, STEPS, "reference must record 100 greedy IDs");
  ids(manifest.prompt_ids, "prompt_ids");
  assert(typeof manifest.prompt === "string" && manifest.prompt.length > 0, "reference prompt missing");
  const oracle = manifest.oracle;
  assert(typeof oracle?.mlx === "string" && oracle.mlx && typeof oracle.device?.architecture === "string" && oracle.device.architecture,
    "reference runtime identity missing");

  // Model artifacts: every pinned metadata file and shard, by content.
  const files = Object.entries(oracle.model_files_sha256 ?? {}), shards = Object.entries(oracle.weights_sha256 ?? {});
  assert(files.length > 0 && shards.length > 0, "reference pins no model files");
  hash(oracle.config_sha256, "config_sha256");
  for (const name of METADATA) assert(oracle.model_files_sha256?.[name], `reference does not pin ${name}`);
  assert.equal(oracle.model_files_sha256["config.json"], oracle.config_sha256, "config pins disagree");
  for (const [name, pin] of files) {
    hash(pin, name);
    assert.equal(await fileSha256(join(inputs.model, name)), pin, `model file ${name} differs from the reference`);
  }
  const config = JSON.parse(readFileSync(join(inputs.model, "config.json"), "utf8")) as { vocab_size?: number };
  assert.equal(config.vocab_size, manifest.vocab_size, "reference vocabulary differs from the model config");
  const index = JSON.parse(readFileSync(join(inputs.model, "model.safetensors.index.json"), "utf8")) as { weight_map?: Record<string, string> };
  assert.deepEqual([...new Set(Object.values(index.weight_map ?? {}))].sort(), shards.map(([name]) => name).sort(),
    "index shards differ from the pinned shards");
  for (const [name, pin] of shards) {
    hash(pin, name);
    assert.equal(await fileSha256(join(inputs.model, name)), pin, `weights ${name} differ from the reference`);
  }

  // Exactly the 100 full-width, finite reference vectors.
  const names = Array.from({ length: STEPS }, (_, step) => blobName(step));
  assert.deepEqual(Object.keys(oracle.blobs ?? {}).sort(), [...names].sort(), "reference must pin exactly the 100 logit blobs");
  const blobs = names.map(name => {
    const blob = readFileSync(join(inputs.reference, name));
    assert.equal(blob.byteLength, manifest.vocab_size * 4, `${name}: expected ${manifest.vocab_size} f32 values`);
    assert.equal(sha256(blob), oracle.blobs[name], `${name} differs from its pin`);
    const values = new Float32Array(new Uint8Array(blob).buffer); // an aligned copy that owns its bytes
    assert(values.every(Number.isFinite), `${name}: non-finite reference logit`);
    return values;
  });
  return { manifest, blobs };
}

/** A bit-exact reference is specific to the MLX version and GPU family that produced it. */
function checkRuntime(manifest: Manifest, runtime: { mlxVersion: string; architecture: string }): void {
  const produced = `MLX ${manifest.oracle.mlx} on ${manifest.oracle.device.architecture}`;
  assert(runtime.mlxVersion === manifest.oracle.mlx && runtime.architecture === manifest.oracle.device.architecture,
    `reference/runtime mismatch: the reference was produced with ${produced}, this runtime is MLX ${runtime.mlxVersion} ` +
    `on ${runtime.architecture}; supply a reference generated on a matching runtime`);
}

/** One step: full width, every value finite on both sides, then identical bytes, so
 * equal NaN or infinite payloads and -0/+0 can never pass as equal. */
function compareStep(step: number, actual: Float32Array, expected: Float32Array): void {
  assert.equal(actual.length, expected.length, `step ${step}: logit width ${actual.length}, reference ${expected.length}`);
  assert(actual.every(Number.isFinite) && expected.every(Number.isFinite), `step ${step}: non-finite logit`);
  const bytes = (values: Float32Array) => Buffer.from(values.buffer, values.byteOffset, values.byteLength);
  assert(bytes(actual).equals(bytes(expected)), `step ${step}: logits differ bitwise`);
}

/** Run every release even when one throws, then rethrow the first failure. */
function releaseAll(releases: Array<() => void>): void {
  const failures: unknown[] = [];
  for (const release of releases) { try { release(); } catch (error) { failures.push(error); } }
  if (failures.length) throw failures[0];
}

const inputs = optIn(Bun.env);

test.skipIf(!inputs)("MiniCPM5: 100 greedy steps match the external reference bit for bit", async () => {
  const { manifest, blobs } = await verifyInputs(inputs!);
  expect(manifest.vocab_size).toBe(VOCAB);
  const ffi = await import("@mlx-bun/mlx/ffi");
  checkRuntime(manifest, { mlxVersion: ffi.MLX_VERSION, architecture: ffi.deviceArchitecture() });
  const { loadModelConfig, loadTokenizer, Weights } = await import("@mlx-bun/inference");
  const { MiniCPM5Model } = await import("@mlx-bun/inference/models/minicpm5");
  const { argmaxLastPosition, lastPositionLogits } = await import("@mlx-bun/inference/scoring");
  const { KVCache } = await import("../../src/state/kv");

  const tokenizer = await loadTokenizer(inputs!.model);
  expect(tokenizer.encode(manifest.prompt)).toEqual(manifest.prompt_ids);
  const config = await loadModelConfig(inputs!.model);
  const weights = await Weights.open(inputs!.model);
  const greedy: number[] = [];
  let cache: Array<{ dispose(): void }> = [], valuesCompared = 0;
  try {
    const model = new MiniCPM5Model(weights, config);
    const layers = model.makeCache();
    cache = layers;
    // Plain KV per layer from the model itself: no artifact loader applies kv_config.json.
    expect(config.text.numHiddenLayers).toBe(LAYERS);
    expect(layers).toHaveLength(LAYERS);
    expect(layers.every(entry => entry instanceof KVCache)).toBe(true);
    // The prompt once, then each selected token on the same live cache; no EOS exit.
    let tokens = manifest.prompt_ids;
    for (let step = 0; step < STEPS; step++) {
      const logits = model.forward(tokens, layers);
      let next: number;
      try {
        const actual = lastPositionLogits(logits);
        compareStep(step, actual, blobs[step]!);
        valuesCompared += actual.length;
        next = argmaxLastPosition(logits);
      } finally { logits.dispose(); }
      assert.equal(next, manifest.greedy_ids[step], `step ${step}: greedy token`);
      greedy.push(next);
      tokens = [next];
    }
  } finally {
    // Caches, then weights, then the shard mappings Weights.dispose leaves mapped; each
    // release runs even if an earlier one throws.
    try { releaseAll(cache.map(entry => () => entry.dispose())); } finally {
      try { weights.dispose(); } finally {
        releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap()));
      }
    }
  }
  expect(greedy).toHaveLength(STEPS);
  expect(valuesCompared).toBe(13_056_000); // 100 × 130,560
  console.log(JSON.stringify({ status: "pass", steps: greedy.length, valuesCompared, promptTokens: manifest.prompt_ids.length,
    batch: 1, kv: "plain", greedyIds: greedy, manifestSha256: inputs!.manifestSha256, mlx: ffi.MLX_VERSION,
    architecture: ffi.deviceArchitecture(), bun: Bun.version }));
}, 300_000);

// ---- CPU-only validation (synthetic inputs; no native libraries) ------------------------
function synthetic() {
  const root = mkdtempSync(join(tmpdir(), "minicpm5-parity-")), model = join(root, "model"), reference = join(root, "reference");
  mkdirSync(model);
  mkdirSync(reference);
  const vocab = 4;
  const files: Record<string, string> = {
    ...Object.fromEntries(METADATA.map(name => [name, `${name} contents`])),
    "config.json": JSON.stringify({ model_type: "llama", vocab_size: vocab }),
    "model.safetensors.index.json": JSON.stringify({ weight_map: { "a.weight": "model.safetensors", "b.weight": "model.safetensors" } }),
  };
  for (const [name, text] of Object.entries(files)) writeFileSync(join(model, name), text);
  writeFileSync(join(model, "model.safetensors"), "weight-bytes");
  const blobs: Record<string, string> = {};
  for (let step = 0; step < STEPS; step++) {
    const blob = Buffer.from(Float32Array.from({ length: vocab }, (_, i) => step + i / 8).buffer);
    writeFileSync(join(reference, blobName(step)), blob);
    blobs[blobName(step)] = sha256(blob);
  }
  const manifest: Manifest & { snapshot: string } = {
    snapshot: "/original/location", prompt: "p", prompt_ids: [0, 1], greedy_ids: Array.from({ length: STEPS }, (_, i) => i % vocab),
    logit_steps: STEPS, vocab_size: vocab,
    oracle: { mlx: "0.32.2", device: { architecture: "applegpu_g13s" }, config_sha256: sha256(files["config.json"]!),
      model_files_sha256: Object.fromEntries(Object.entries(files).map(([name, text]) => [name, sha256(text)])),
      weights_sha256: { "model.safetensors": sha256("weight-bytes") }, blobs },
  };
  const pin = () => { const text = JSON.stringify(manifest); writeFileSync(join(reference, MANIFEST), text); return sha256(text); };
  return { root, model, reference, manifest, pin, inputs: (): Inputs => ({ model, reference, manifestSha256: pin() }) };
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
};

test("opt-in is all or nothing (CPU only)", () => {
  expect(optIn({})).toBeNull();
  const full = { [OPT_IN[0]]: "/m", [OPT_IN[1]]: "/r", [OPT_IN[2]]: "a".repeat(64) };
  expect(optIn(full)).toEqual({ model: "/m", reference: "/r", manifestSha256: "a".repeat(64) });
  expect(() => optIn({ [OPT_IN[0]]: "/m" })).toThrow("missing or blank");
  expect(() => optIn({ ...full, [OPT_IN[1]]: " " })).toThrow(`missing or blank: ${OPT_IN[1]}`);
  expect(() => optIn({ ...full, [OPT_IN[2]]: "A".repeat(64) })).toThrow("lowercase SHA-256");
});

test("a relocated identical model and reference verify; the recorded snapshot path is informational (CPU only)", async () => {
  const s = synthetic();
  try {
    const moved = join(s.root, "relocated");
    cpSync(s.model, moved, { recursive: true });
    const { manifest, blobs } = await verifyInputs({ ...s.inputs(), model: moved });
    expect(blobs).toHaveLength(STEPS);
    expect(manifest.greedy_ids).toHaveLength(STEPS);
  } finally { rmSync(s.root, { recursive: true, force: true }); }
});

test("incomplete, altered or mismatched inputs fail before any native load (CPU only)", async () => {
  await rejects(s => ({ ...s.inputs(), manifestSha256: "0".repeat(64) }), "manifest SHA-256 differs");
  await rejects(s => { rmSync(join(s.reference, blobName(57))); }, blobName(57));
  await rejects(s => { writeFileSync(join(s.reference, blobName(3)), Buffer.from(new Float32Array(4).buffer)); }, `${blobName(3)} differs from its pin`);
  await rejects(s => { rewriteBlob(s, 9, [1, 2, 3, 4, 5]); }, `${blobName(9)}: expected 4 f32 values`);
  await rejects(s => { rewriteBlob(s, 9, [1, Number.NaN, 3, 4]); }, "non-finite reference logit");
  await rejects(s => { s.manifest.logit_steps = 99; }, "100 logit steps");
  await rejects(s => { s.manifest.greedy_ids[7] = 4; }, "greedy_ids: expected token IDs in [0, 4)");
  await rejects(s => { s.manifest.greedy_ids[7] = 1.5; }, "greedy_ids: expected token IDs");
  await rejects(s => { s.manifest.prompt_ids = [-1]; }, "prompt_ids: expected token IDs");
  await rejects(s => { s.manifest.prompt_ids = []; }, "prompt_ids: expected token IDs");
  await rejects(s => { s.manifest.greedy_ids.pop(); }, "100 greedy IDs");
  await rejects(s => { delete s.manifest.oracle.blobs[blobName(99)]; }, "exactly the 100 logit blobs");
  await rejects(s => { s.manifest.vocab_size = 5; }, "vocabulary differs from the model config");
  await rejects(s => { s.manifest.oracle.config_sha256 = "c".repeat(64); }, "config pins disagree");
  await rejects(s => { writeFileSync(join(s.model, "tokenizer.json"), "{\"changed\":true}"); }, "model file tokenizer.json differs");
  await rejects(s => { delete s.manifest.oracle.model_files_sha256["tokenizer.json"]; }, "reference does not pin tokenizer.json");
  await rejects(s => { rmSync(join(s.model, "kv_config.json")); }, "kv_config.json");
  await rejects(s => {
    const text = JSON.stringify({ weight_map: { "a.weight": "model.safetensors", "c.weight": "model-00002.safetensors" } });
    writeFileSync(join(s.model, "model.safetensors.index.json"), text);
    s.manifest.oracle.model_files_sha256["model.safetensors.index.json"] = sha256(text);
  }, "index shards differ");
  await rejects(s => { writeFileSync(join(s.model, "model.safetensors"), "other-bytes"); }, "weights model.safetensors differ");
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

test("a step passes only on identical finite bytes (CPU only)", () => {
  const values = (...xs: number[]) => Float32Array.from(xs);
  compareStep(0, values(1, 2.5, -3, 0), values(1, 2.5, -3, 0));
  // Identical bytes are not enough when a value is not finite.
  expect(() => compareStep(1, values(1, Number.NaN, 3, 4), values(1, Number.NaN, 3, 4))).toThrow("step 1: non-finite logit");
  expect(() => compareStep(2, values(1, Infinity, 3, 4), values(1, Infinity, 3, 4))).toThrow("non-finite");
  expect(() => compareStep(3, values(1, 2, 3, 4), values(1, 2, 3, -Infinity))).toThrow("non-finite");
  // Numerically equal but not the same bits.
  expect(() => compareStep(4, values(1, 0, 3, 4), values(1, -0, 3, 4))).toThrow("step 4: logits differ bitwise");
  expect(() => compareStep(5, values(1, 2, 3), values(1, 2, 3, 4))).toThrow("logit width 3, reference 4");
});

test("every owned resource is released even when one release throws (CPU only)", () => {
  const released: string[] = [];
  expect(() => releaseAll([() => { released.push("a"); }, () => { throw new Error("b failed"); }, () => { released.push("c"); }]))
    .toThrow("b failed");
  expect(released).toEqual(["a", "c"]);
});
