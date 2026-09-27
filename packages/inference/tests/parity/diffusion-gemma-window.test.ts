// DiffusionGemma decoder over a prompt longer than the sliding window, against
// an external optiq reference: the encoder prefill over the reference's prompt
// IDs, then one decoder pass over its canvas IDs (the first denoising pass, no
// self-conditioning). Every layer's decoder-selected encoder K/V (the newest
// sliding_window - 1 positions on sliding layers) and the full logits must equal
// the reference byte for byte, and be finite. The model, reference and oracle
// stay outside this repository; this test never starts Python. Opt in with all of
//   MLX_BUN_TEST_DIFFUSION_WINDOW_MODEL=/model/snapshot
//   MLX_BUN_TEST_DIFFUSION_WINDOW_REFERENCE=/reference/dir (manifest.json + raw tensors)
//   MLX_BUN_TEST_DIFFUSION_WINDOW_REFERENCE_SHA256=<manifest SHA-256>
// None set skips; any other combination fails. The manifest pins the inputs,
// the artifact files, the producing runtime and every raw tensor. The artifact,
// inputs, geometry and every reference tensor are verified before native
// libraries load; the runtime identity (MLX version, GPU architecture) is checked
// right after the native import, before the model loads. Every produced tensor's
// shape and dtype are checked against the pinned geometry before its bytes.
import { expect, test } from "bun:test";
import { strict as assert } from "node:assert";
import { cpSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../src/contracts/mlx/cache";
import type { DiffusionGemmaModel } from "../../src/models/diffusion-gemma/model";
import type { KVCache } from "../../src/state/kv";
import type { RotatingKVCache } from "../../src/state/rotating-kv";
import { floatValues, isSha256, optInAll, releaseAll, sha256, verifyArtifact } from "./real-weight-inputs";

const OPT_IN = ["MLX_BUN_TEST_DIFFUSION_WINDOW_MODEL", "MLX_BUN_TEST_DIFFUSION_WINDOW_REFERENCE",
  "MLX_BUN_TEST_DIFFUSION_WINDOW_REFERENCE_SHA256"] as const;
type Tensor = { file: string; shape: number[]; dtype: string; sha: string };
interface Manifest {
  schema: 1; inputs: { prompt: number[]; canvas: number[] };
  artifact: { files: Record<string, string>; weights: Record<string, string> };
  runtime: { mlx: string; architecture: string };
  layers: { layer: number; type: string; offset: number; keys: Tensor; values: Tensor }[];
  logits: Tensor;
}
/** The decoder geometry the artifact config fixes. */
interface Geometry { layers: number; types: string[]; window: number; canvas: number; vocab: number; dtype: string;
  sliding: { heads: number; dim: number }; full: { heads: number; dim: number } }

function optIn(env: Record<string, string | undefined>) {
  const values = optInAll(env, OPT_IN, "DiffusionGemma window parity");
  if (!values) return null;
  if (!isSha256(values[OPT_IN[2]])) throw new Error(`${OPT_IN[2]} must be a lowercase SHA-256`);
  return { model: values[OPT_IN[0]], reference: values[OPT_IN[1]], manifestSha256: values[OPT_IN[2]] };
}
function geometryOf(model: string): Geometry {
  const raw = JSON.parse(readFileSync(join(model, "config.json"), "utf8")), t = raw.text_config ?? raw;
  return { layers: t.num_hidden_layers, types: t.layer_types, window: t.sliding_window, canvas: raw.canvas_length, vocab: t.vocab_size,
    dtype: t.dtype ?? raw.torch_dtype, sliding: { heads: t.num_key_value_heads, dim: t.head_dim },
    full: { heads: t.num_global_key_value_heads ?? t.num_key_value_heads, dim: t.global_head_dim ?? t.head_dim } };
}
const dtypeName = (dtype: string) => dtype.split(".").pop()!;

/** Verify everything before any native load; returns the verified tensor bytes. */
async function verifyInputs(inputs: { model: string; reference: string; manifestSha256: string }) {
  const bytes = readFileSync(join(inputs.reference, "manifest.json"));
  assert.equal(sha256(bytes), inputs.manifestSha256, "reference manifest SHA-256 differs from the supplied pin");
  const manifest = JSON.parse(bytes.toString("utf8")) as Manifest;
  assert.equal(manifest.schema, 1, "unknown manifest schema");
  await verifyArtifact(inputs.model, manifest.artifact);
  const g = geometryOf(inputs.model);
  assert(g.layers > 0 && g.types?.length === g.layers && g.window > 1 && g.canvas > 0 && g.vocab > 0, "incomplete decoder geometry in the config");
  assert(g.dtype === "bfloat16", `unexpected cache dtype ${g.dtype}`);
  const ids = (value: unknown, what: string) => assert(Array.isArray(value) && value.length > 0 &&
    value.every(n => Number.isSafeInteger(n) && n >= 0 && n < g.vocab), `${what}: expected token IDs in [0, ${g.vocab})`);
  ids(manifest.inputs?.prompt, "prompt"); ids(manifest.inputs?.canvas, "canvas");
  assert.equal(manifest.inputs.canvas.length, g.canvas, "canvas length differs from the config");
  const prompt = manifest.inputs.prompt.length;
  assert(prompt > g.window, `prompt of ${prompt} tokens does not exceed the ${g.window}-token window`);
  assert(typeof manifest.runtime?.mlx === "string" && manifest.runtime.mlx && typeof manifest.runtime.architecture === "string" &&
    manifest.runtime.architecture, "reference runtime identity missing");
  const read = (t: Tensor, what: string, shape: number[], dtype: "bfloat16" | "float32") => {
    assert.deepEqual(t?.shape, shape, `${what}: shape ${JSON.stringify(t?.shape)}, expected ${JSON.stringify(shape)}`);
    assert.equal(dtypeName(String(t.dtype)), dtype, `${what}: dtype ${t.dtype}, expected ${dtype}`);
    const blob = new Uint8Array(readFileSync(join(inputs.reference, t.file)));
    assert.equal(sha256(blob), t.sha, `${what}: bytes differ from their pin`);
    assert.equal(blob.byteLength, shape.reduce((a, b) => a * b, 1) * (dtype === "float32" ? 4 : 2), `${what}: extent differs from its shape`);
    assert(floatValues(blob, dtype).every(Number.isFinite), `${what}: non-finite reference value`);
    return blob;
  };
  assert.equal(manifest.layers?.length, g.layers, `reference records ${manifest.layers?.length} layers, the config has ${g.layers}`);
  const layers = manifest.layers.map((l, i) => {
    const sliding = g.types[i] === "sliding_attention", { heads, dim } = sliding ? g.sliding : g.full;
    assert(l.layer === i && l.type === g.types[i] && l.offset === prompt, `layer ${i}: ${l.type} offset ${l.offset}, config ${g.types[i]} at ${prompt}`);
    const shape = [1, heads, sliding ? g.window - 1 : prompt, dim];
    return { shape, keys: read(l.keys, `layer ${i} keys`, shape, "bfloat16"), values: read(l.values, `layer ${i} values`, shape, "bfloat16") };
  });
  const logitsShape = [1, g.canvas, g.vocab];
  const logits = read(manifest.logits, "logits", logitsShape, "float32");
  return { manifest, geometry: g, layers, logits, logitsShape };
}

type Produced = { shape: number[]; dtype: string; bytes: Uint8Array };
/** A produced tensor passes only with the pinned shape and dtype, the matching
 * extent, finite values and the reference's exact bytes (checked in that order). */
function compareProduced(what: string, produced: Produced, expected: Uint8Array, shape: number[], dtype: "bfloat16" | "float32") {
  assert.deepEqual(produced.shape, shape, `${what}: produced shape ${JSON.stringify(produced.shape)}, pinned ${JSON.stringify(shape)}`);
  assert.equal(dtypeName(produced.dtype), dtype, `${what}: produced dtype ${produced.dtype}, pinned ${dtype}`);
  assert.equal(produced.bytes.byteLength, shape.reduce((a, b) => a * b, 1) * (dtype === "float32" ? 4 : 2), `${what}: produced extent differs from its shape`);
  assert(floatValues(produced.bytes, dtype).every(Number.isFinite), `${what}: non-finite value`);
  assert(Buffer.from(produced.bytes).equals(Buffer.from(expected)), `${what}: differs from the reference`);
}

const inputs = optIn(Bun.env);

test.skipIf(!inputs)("DiffusionGemma past the window: selected encoder K/V and first-pass logits match the external reference", async () => {
  const { manifest, geometry, layers, logits: expectedLogits, logitsShape } = await verifyInputs(inputs!);
  const ffi = await import("@mlx-bun/mlx/ffi");
  assert(ffi.MLX_VERSION === manifest.runtime.mlx && ffi.deviceArchitecture() === manifest.runtime.architecture,
    `reference/runtime mismatch: the reference was produced with MLX ${manifest.runtime.mlx} on ${manifest.runtime.architecture}, ` +
    `this runtime is MLX ${ffi.MLX_VERSION} on ${ffi.deviceArchitecture()}; supply a reference generated on a matching runtime`);
  const ops = await import("@mlx-bun/mlx/ops");
  const { MlxArray } = await import("@mlx-bun/mlx/array");
  const { loadModelConfig, Weights, createModel } = await import("@mlx-bun/inference");
  const produced = (a: MlxArray): Produced => {
    const c = ops.contiguous(a);
    try { return { shape: [...c.shape], dtype: c.dtypeName, bytes: new Uint8Array(c.rawBytes()) }; } finally { c.dispose(); }
  };
  const weights = await Weights.open(inputs!.model);
  let cache: Cache[] = [];
  try {
    const model = createModel(weights, await loadModelConfig(inputs!.model)) as DiffusionGemmaModel;
    cache = model.prefill(manifest.inputs.prompt);
    expect(cache).toHaveLength(geometry.layers);
    cache.forEach((c, i) => {
      // The decoder's selection: the newest window - 1 encoder positions on sliding
      // layers. Every view acquired here, original or cut, is released below.
      const owned: MlxArray[] = [...(c as RotatingKVCache | KVCache).temporalView()];
      try {
        const [keys, values] = owned.slice(0, 2).map(a => {
          if (geometry.types[i] !== "sliding_attention") return a;
          const length = a.shape[2]!, keep = geometry.window - 1;
          const cut = a.slice([0, 0, length - keep, 0], a.shape);
          owned.push(cut);
          return cut;
        }) as [MlxArray, MlxArray];
        compareProduced(`layer ${i} keys`, produced(keys), layers[i]!.keys, layers[i]!.shape, "bfloat16");
        compareProduced(`layer ${i} values`, produced(values), layers[i]!.values, layers[i]!.shape, "bfloat16");
      } finally { releaseAll(owned.map(a => () => a.dispose())); }
    });
    const canvas = MlxArray.fromInt32(Int32Array.from(manifest.inputs.canvas), [1, manifest.inputs.canvas.length]);
    let logits: MlxArray | null = null;
    try {
      logits = model.decoderLogits(canvas, cache, null);
      compareProduced("logits", produced(logits), expectedLogits, logitsShape, "float32");
    } finally { releaseAll([() => canvas.dispose(), () => logits?.dispose()]); }
  } finally {
    // Caches, then weights, then the shard mappings Weights.dispose leaves mapped.
    try { releaseAll(cache.map(c => () => c.dispose())); } finally {
      try { weights.dispose(); } finally { releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap())); }
    }
  }
}, 600_000);

// ---- CPU-only validation (synthetic inputs; no native libraries) ------------------------
function synthetic() {
  const root = mkdtempSync(join(tmpdir(), "diffusion-window-")), model = join(root, "model"), reference = join(root, "reference");
  mkdirSync(model); mkdirSync(reference);
  const config = { canvas_length: 2, text_config: { num_hidden_layers: 2, layer_types: ["sliding_attention", "full_attention"],
    sliding_window: 3, vocab_size: 5, dtype: "bfloat16", num_key_value_heads: 1, head_dim: 2, num_global_key_value_heads: 1, global_head_dim: 2 } };
  const files: Record<string, string> = { "config.json": JSON.stringify(config),
    "model.safetensors.index.json": JSON.stringify({ weight_map: { a: "model.safetensors" } }) };
  for (const [name, text] of Object.entries(files)) writeFileSync(join(model, name), text);
  writeFileSync(join(model, "model.safetensors"), "weight-bytes");
  const bf16 = (values: number[]) => { const f = new Float32Array(values), u = new Uint32Array(f.buffer), out = new Uint16Array(values.length);
    for (let i = 0; i < values.length; i++) out[i] = u[i]! >>> 16; return new Uint8Array(out.buffer); };
  const tensors: Record<string, Uint8Array> = { "k0.bin": bf16([1, 2, 3, 4]), "v0.bin": bf16([5, 6, 7, 8]),
    "k1.bin": bf16([1, 1, 2, 2, 3, 3, 4, 4]), "v1.bin": bf16([5, 5, 6, 6, 7, 7, 8, 8]),
    "logits.bin": new Uint8Array(new Float32Array([0.5, 1, -2, 3, 0.25, 7, 1, 2, 3, 4]).buffer) };
  for (const [name, bytes] of Object.entries(tensors)) writeFileSync(join(reference, name), bytes);
  const t = (file: string, shape: number[], dtype: string) => ({ file, shape, dtype, sha: sha256(tensors[file]!) });
  const manifest = { schema: 1, inputs: { prompt: [1, 2, 3, 4], canvas: [0, 4] },
    artifact: { files: Object.fromEntries(Object.entries(files).map(([n, text]) => [n, sha256(text)])),
      weights: { "model.safetensors": sha256("weight-bytes") } as Record<string, string> },
    runtime: { mlx: "0.32.2", architecture: "applegpu_g13s" },
    layers: [{ layer: 0, type: "sliding_attention", offset: 4, keys: t("k0.bin", [1, 1, 2, 2], "mlx.core.bfloat16"), values: t("v0.bin", [1, 1, 2, 2], "mlx.core.bfloat16") },
      { layer: 1, type: "full_attention", offset: 4, keys: t("k1.bin", [1, 1, 4, 2], "bfloat16"), values: t("v1.bin", [1, 1, 4, 2], "bfloat16") }],
    logits: t("logits.bin", [1, 2, 5], "float32") };
  const pin = () => { const text = JSON.stringify(manifest); writeFileSync(join(reference, "manifest.json"), text); return sha256(text); };
  return { root, model, reference, manifest, tensors, pin, bf16, inputs: () => ({ model, reference, manifestSha256: pin() }) };
}
type Synthetic = ReturnType<typeof synthetic>;
async function rejects(change: (s: Synthetic) => { model: string; reference: string; manifestSha256: string } | void, message: string) {
  const s = synthetic();
  try { await expect(verifyInputs(change(s) ?? s.inputs())).rejects.toThrow(message); }
  finally { rmSync(s.root, { recursive: true, force: true }); }
}
const retag = (s: Synthetic, file: string, bytes: Uint8Array, entry: Tensor) => { writeFileSync(join(s.reference, file), bytes); entry.sha = sha256(bytes); };

test("opt-in is all or nothing (CPU only)", () => {
  expect(optIn({})).toBeNull();
  const full = { [OPT_IN[0]]: "/m", [OPT_IN[1]]: "/r", [OPT_IN[2]]: "a".repeat(64) };
  expect(optIn(full)).toEqual({ model: "/m", reference: "/r", manifestSha256: "a".repeat(64) });
  expect(() => optIn({ [OPT_IN[0]]: "/m" })).toThrow("missing or blank");
  expect(() => optIn({ ...full, [OPT_IN[1]]: " " })).toThrow(`missing or blank: ${OPT_IN[1]}`);
  expect(() => optIn({ ...full, [OPT_IN[2]]: "A".repeat(64) })).toThrow("lowercase SHA-256");
});

test("a relocated identical model and reference verify (CPU only)", async () => {
  const s = synthetic();
  try {
    const moved = join(s.root, "moved"); cpSync(s.model, moved, { recursive: true });
    const verified = await verifyInputs({ ...s.inputs(), model: moved });
    expect(verified.layers).toHaveLength(2);
    expect(verified.logits.byteLength).toBe(40);
  } finally { rmSync(s.root, { recursive: true, force: true }); }
});

test("incomplete, altered or mismatched references fail before any native load (CPU only)", async () => {
  await rejects(s => ({ ...s.inputs(), manifestSha256: "0".repeat(64) }), "manifest SHA-256 differs");
  await rejects(s => { rmSync(join(s.reference, "v1.bin")); }, "v1.bin");
  await rejects(s => { writeFileSync(join(s.reference, "k0.bin"), s.bf16([1, 2, 3, 5])); }, "layer 0 keys: bytes differ");
  await rejects(s => { retag(s, "k1.bin", s.bf16([1, 1, 2, 2, 3, 3, 4]), s.manifest.layers[1]!.keys); }, "layer 1 keys: extent differs");
  await rejects(s => { retag(s, "v0.bin", s.bf16([5, Number.NaN, 7, 8]), s.manifest.layers[0]!.values); }, "non-finite reference value");
  await rejects(s => { s.manifest.layers[0]!.keys.shape = [1, 2, 1, 2]; }, "layer 0 keys: shape");
  await rejects(s => { s.manifest.layers[1]!.values.dtype = "float16"; }, "layer 1 values: dtype");
  await rejects(s => { s.manifest.layers.pop(); }, "records 1 layers, the config has 2");
  await rejects(s => { s.manifest.layers[1]!.type = "sliding_attention"; }, "layer 1: sliding_attention");
  await rejects(s => { s.manifest.layers[0]!.offset = 3; }, "layer 0: sliding_attention offset 3");
  await rejects(s => { s.manifest.logits.shape = [1, 5, 2]; }, "logits: shape");
  await rejects(s => { s.manifest.inputs.canvas = [0]; }, "canvas length differs");
  await rejects(s => { s.manifest.inputs.prompt = [1, 2, 9]; }, "prompt: expected token IDs");
  await rejects(s => { s.manifest.inputs.prompt = [1, 2]; }, "does not exceed the 3-token window");
  await rejects(s => { writeFileSync(join(s.model, "config.json"), "{}"); }, "model file config.json differs");
  await rejects(s => { delete s.manifest.artifact.files["model.safetensors.index.json"]; }, "do not include model.safetensors.index.json");
  await rejects(s => { s.manifest.artifact.weights["model-2.safetensors"] = "b".repeat(64); }, "index shards differ");
  await rejects(s => { writeFileSync(join(s.model, "model.safetensors"), "other-bytes"); }, "weights model.safetensors differ");
  await rejects(s => { s.manifest.runtime.architecture = ""; }, "runtime identity missing");
});

test("produced tensors pass only with pinned shape and dtype, finite values and identical bytes (CPU only)", () => {
  const f32 = (...xs: number[]) => new Uint8Array(new Float32Array(xs).buffer);
  const out = (bytes: Uint8Array, shape = [1, 2], dtype = "float32"): Produced => ({ shape, dtype, bytes });
  compareProduced("x", out(f32(1, 2)), f32(1, 2), [1, 2], "float32");
  // Equal bytes do not excuse a reshape or a different dtype.
  expect(() => compareProduced("x", out(f32(1, 2), [2, 1]), f32(1, 2), [1, 2], "float32")).toThrow("x: produced shape [2,1], pinned [1,2]");
  expect(() => compareProduced("x", out(f32(1, 2), [1, 2], "float16"), f32(1, 2), [1, 2], "float32")).toThrow("x: produced dtype float16, pinned float32");
  expect(() => compareProduced("k", out(new Uint8Array(4), [1, 2], "bfloat16"), new Uint8Array(4), [1, 2], "float32")).toThrow("produced dtype bfloat16");
  expect(() => compareProduced("x", out(f32(1, 2, 3)), f32(1, 2, 3), [1, 2], "float32")).toThrow("produced extent differs");
  expect(() => compareProduced("x", out(f32(1, Number.NaN)), f32(1, Number.NaN), [1, 2], "float32")).toThrow("non-finite");
  expect(() => compareProduced("x", out(f32(1, 0)), f32(1, -0), [1, 2], "float32")).toThrow("differs from the reference");
});
