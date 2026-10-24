// One SFT final-latent case against unchanged MFLUX at the revision below.
// Expected tensors are MFLUX's outputs, never a Bun candidate's saved outputs.
// The historical PyTorch criteria remain in models/moss-image-vae.test.ts.
//
// Opt in with BOTH MLX_BUN_MOSS_VAE_SNAPSHOT (SFT snapshot root) and
// MLX_BUN_MOSS_VAE_ORACLE (directory containing the four CAPTURE_PINS files).
// Neither set visibly skips; a partial opt-in fails. Files can be relocated:
// embedded absolute paths are provenance only and are never opened here.
// MLX_BUN_MOSS_VAE_RESULTS optionally names the external JSON report.
// Verify all consumed weights and captures before importing MLX. On an idle
// GPU, run one ordinary and one observed production VAE decode; no Python,
// reference execution, DiT/encoder forwards, downloads, or tolerance bounds.
import { describe, test } from "bun:test";
import { strict as assert } from "node:assert";
import { execFileSync } from "node:child_process";
import { readFileSync, readdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Flux2VaeDecoder } from "../../src/models/moss-image/vae";
import { fileSha256, optInAll, sha256 } from "./real-weight-inputs";

const OPT_IN = ["MLX_BUN_MOSS_VAE_SNAPSHOT", "MLX_BUN_MOSS_VAE_ORACLE"] as const;
const REFERENCE = {
  mfluxRevision: "a3b21fcaa88726b2267bd42bfc2e2d722f7d5a47", mlxVersion: "0.32.2", pythonVersion: "3.12.13",
  model: "OpenMOSS-Team/MOSS-Image-SFT", modelRevision: "f972bd4b4b9e3852133cc5da954d87bc32cd8fb9",
  producerSha256: "8328d587195d9bb4e0415cd301bf3dcbd37e8e9ef42a04839b629e4faac2c6bd",
  inputSha256: "6ad12df5762421348d5cb64fd49c037075c54f02bf6e0dd26b9b1a9546f3ae1d",
  native: {
    "libmlx.dylib": "d24c7a9b9d55a76bfd3bbcd1d042251a185cbadcb6340c3244a6ffa3dcb7c7e8",
    "mlx.metallib": "dc59d1cceb1a5c7e578232e6e41e28e2c73c9463ac6dbc3886c3ee17ffc270ed",
  },
} as const;
const SNAPSHOT_PINS = {
  "vae/config.json": "cc77f3f0ce0357039c71018dc19edaa4fcceb0c2f7488fdc2b9c0580d6baafa1",
  "vae/diffusion_pytorch_model.safetensors": "c3bdf94dc67ec69b30ea9fe1fa8340085679cae64d019f7c7e4a9921f1a7f17a",
} as const;
const CAPTURE_PINS = {
  "run.json": "14cc18ebf5d35ab7134a22795fc1a83c0935ac69ed4db145d99e39454f2f54f2",
  "oracle.json": "773b149bb7b6bff5046e9a38a907b783b2a4ec7ff892ac81a9447d15ebe1ee76",
  "oracle.safetensors": "45502ca02707d73643778b8d53835877dafb19815a06100777e06983553eb7d2",
  "oracle.uninstrumented.safetensors": "d9d44254a53fa40f0c99d3955e72d70eef36b3a327d5b5838f3a7db1cf82d1cb",
} as const;
const STAGES = ["input.f32", "weights.bn_mean", "weights.bn_var", "input.bf16", "denormalized", "unpatched", "post_quant", "conv_in",
  "mid.resnet0.silu1", "mid.resnet0.conv1", "mid.resnet0.silu2", "mid.resnet0.conv2", "mid.resnet0",
  "mid.attention.q", "mid.attention.k", "mid.attention.v", "mid.attention.out", "mid.attention", "mid.resnet1"];
for (let block = 0; block < 4; block++) {
  for (let layer = 0; layer < 3; layer++) STAGES.push(`up.${block}.resnet${layer}`);
  if (block < 3) STAGES.push(`up.${block}.upsample`);
}
STAGES.push("norm_out", "activation_out", "conv_out", "raw.nhwc", "pixels.nhwc");
const OUTPUTS = ["raw.nhwc", "pixels.nhwc"] as const;
const SIZES = { BF16: 2, F32: 4, U8: 1 } as const;
interface HostTensor { dtype: keyof typeof SIZES; shape: number[]; bytes: Uint8Array }
interface Measurement {
  stage: string; exact: boolean; words: number; mismatchedWords: number; nonfiniteWords: number;
  actualSha256?: string; expectedSha256?: string; error?: string;
  firstDifference?: { index: number; actualBits: string; expectedBits: string };
}

/** Pure host reader: pin checking and the reference observer control load no native code. */
function readCapture(path: string): Map<string, HostTensor> {
  const bytes = readFileSync(path);
  assert(bytes.length >= 8, `truncated capture: ${path}`);
  const start = 8 + Number(bytes.readBigUInt64LE(0));
  assert(Number.isSafeInteger(start) && start > 8 && start <= bytes.length, `invalid header: ${path}`);
  const header = JSON.parse(bytes.subarray(8, start).toString()) as Record<string,
    { dtype: keyof typeof SIZES; shape: number[]; data_offsets: [number, number] }>;
  const tensors = new Map<string, HostTensor>();
  for (const [name, info] of Object.entries(header)) {
    if (name === "__metadata__") continue;
    const [begin, end] = info.data_offsets, width = SIZES[info.dtype];
    assert(width && Number.isSafeInteger(begin) && Number.isSafeInteger(end) && begin >= 0 && end >= begin && start + end <= bytes.length);
    assert(info.shape.every(size => Number.isSafeInteger(size) && size >= 0));
    assert.equal(end - begin, info.shape.reduce((a, b) => a * b, 1) * width, `${name}: invalid byte count`);
    tensors.set(name, { dtype: info.dtype, shape: info.shape, bytes: bytes.subarray(start + begin, start + end) });
  }
  return tensors;
}

function measure(stage: string, actual: HostTensor | undefined, expected: HostTensor | undefined): Measurement {
  const result: Measurement = { stage, exact: false, words: 0, mismatchedWords: 0, nonfiniteWords: 0 };
  if (!actual || !expected) return { ...result, error: "missing tensor" };
  result.actualSha256 = sha256(actual.bytes); result.expectedSha256 = sha256(expected.bytes);
  if (actual.dtype !== expected.dtype || actual.shape.join() !== expected.shape.join() || actual.bytes.length !== expected.bytes.length)
    return { ...result, error: "dtype, shape, or byte count differs" };
  const width = SIZES[expected.dtype], mask = expected.dtype === "BF16" ? 0x7f80 : expected.dtype === "F32" ? 0x7f800000 : 0;
  const a = new DataView(actual.bytes.buffer, actual.bytes.byteOffset, actual.bytes.byteLength);
  const b = new DataView(expected.bytes.buffer, expected.bytes.byteOffset, expected.bytes.byteLength);
  result.words = actual.bytes.length / width;
  for (let index = 0; index < result.words; index++) {
    const offset = index * width;
    const av = width === 4 ? a.getUint32(offset, true) : width === 2 ? a.getUint16(offset, true) : a.getUint8(offset);
    const bv = width === 4 ? b.getUint32(offset, true) : width === 2 ? b.getUint16(offset, true) : b.getUint8(offset);
    if (mask && ((av & mask) === mask || (bv & mask) === mask)) result.nonfiniteWords++;
    if (av !== bv) {
      result.mismatchedWords++;
      result.firstDifference ??= { index, actualBits: av.toString(16), expectedBits: bv.toString(16) };
    }
  }
  result.exact = result.mismatchedWords === 0 && result.nonfiniteWords === 0;
  return result;
}

function sourceFiles(directory: string): string[] {
  return readdirSync(directory, { withFileTypes: true }).flatMap(entry => entry.isDirectory()
    ? sourceFiles(join(directory, entry.name)) : entry.name.endsWith(".ts") ? [join(directory, entry.name)] : []);
}

describe("MOSS SFT VAE against pinned independent MFLUX captures", () => {
  if (OPT_IN.every(name => process.env[name] === undefined)) { test.skip(`needs ${OPT_IN.join(" and ")}`, () => {}); return; }
  test("both observer controls, 39 stages, raw image and pixels are bit-exact", async () => {
    const results = process.env.MLX_BUN_MOSS_VAE_RESULTS ?? join(tmpdir(), "moss-image-mflux-vae-results.json");
    const root = resolve(import.meta.dir, "../../../.."), checks: Measurement[] = [];
    const forwards = { uninstrumented: 0, traced: 0, dit: 0, encoder: 0 };
    const report: Record<string, unknown> = { status: "incomplete", reference: REFERENCE, selectedStages: STAGES, checks, forwards,
      scope: "one SFT final sample-8 latent input; VAE only; historical CPU criteria remain unchanged" };
    const save = () => writeFileSync(results, JSON.stringify(report, null, 2) + "\n");
    const check = (name: string, actual: HostTensor | undefined, expected: HostTensor | undefined) => {
      const measured = measure(name, actual, expected); checks.push(measured);
      assert(measured.exact, `${name}: ${JSON.stringify(measured)}`);
      return measured;
    };
    const held = new Map<string, MlxArray>(), restore: (() => void)[] = [];
    let graph: Flux2VaeDecoder | undefined;
    save(); // A crash or timeout leaves an incomplete report.
    try {
      const opted = optInAll(process.env, OPT_IN, "MOSS exact VAE comparison")!;
      const snapshot = opted.MLX_BUN_MOSS_VAE_SNAPSHOT, oracle = opted.MLX_BUN_MOSS_VAE_ORACLE;
      const git = (...args: string[]) => execFileSync("git", args, { cwd: root, encoding: "utf8" }).trim();
      // Hash the current working sources, including every new/untracked kernel.
      // HEAD alone would describe the earlier serial implementation during integration.
      const implementationFiles = [...sourceFiles(join(root, "packages/inference/src/models/moss-image")),
        ...sourceFiles(join(root, "packages/inference/src/kernels")), ...sourceFiles(join(root, "packages/mlx/src")),
        join(root, "packages/inference/src/artifacts/weights.ts"), join(root, "packages/inference/src/artifacts/diffusers-shards.ts"),
        import.meta.path, join(import.meta.dir, "real-weight-inputs.ts")].sort();
      report.implementation = { commit: git("rev-parse", "HEAD"), modified: git("status", "--porcelain").split("\n").filter(Boolean),
        bun: Bun.version, sourceSha256: Object.fromEntries(await Promise.all(implementationFiles.map(async path => [relative(root, path), await fileSha256(path)]))) };
      const verified: Record<string, string> = {};
      for (const [directory, pins] of [[snapshot, SNAPSHOT_PINS], [oracle, CAPTURE_PINS]] as const) {
        for (const [name, pin] of Object.entries(pins)) {
          const actual = await fileSha256(join(directory, name));
          assert.equal(actual, pin, `${name}: content differs from its fixed pin`);
          verified[join(directory, name)] = actual;
        }
      }
      const vaeDir = join(snapshot, "vae");
      assert.deepEqual(readdirSync(vaeDir).filter(name => name.endsWith(".safetensors") || name.endsWith(".index.json")).sort(),
        ["diffusion_pytorch_model.safetensors"], "unpinned alternate VAE weight/index file");
      const manifest = JSON.parse(readFileSync(join(oracle, "run.json"), "utf8"));
      const info = JSON.parse(readFileSync(join(oracle, "oracle.json"), "utf8"));
      assert.equal(manifest.case.oracleSha, REFERENCE.mfluxRevision);
      assert.deepEqual(manifest.case.stages, STAGES);
      assert.equal(Object.entries(manifest.diagnosticSources).find(([name]) => name.endsWith("/oracle.py"))?.[1], REFERENCE.producerSha256);
      assert.equal(info.mlx, REFERENCE.mlxVersion);
      assert.equal(info.forwardCount, 2);
      assert.equal(info.uninstrumentedForwardCount, 1); assert.equal(info.tracedForwardCount, 1);
      assert.equal(info.ditForwardCount, 0); assert.equal(info.encoderForwardCount, 0);
      const expected = readCapture(join(oracle, "oracle.safetensors"));
      const referenceControl = readCapture(join(oracle, "oracle.uninstrumented.safetensors"));
      assert.equal(STAGES.length, 39);
      assert.deepEqual([...expected.keys()].sort(), [...STAGES].sort());
      assert.deepEqual([...referenceControl.keys()].sort(), [...OUTPUTS].sort());
      const input = expected.get("input.f32")!;
      assert.equal(input.dtype, "F32"); assert.deepEqual(input.shape, [1, 128, 16, 16]);
      assert.equal(sha256(input.bytes), REFERENCE.inputSha256);
      for (const name of OUTPUTS) check(`mflux.observer.${name}`, expected.get(name), referenceControl.get(name));
      report.inputs = { verified, inputSha256: sha256(input.bytes), referenceObserverExact: true }; save();

      const { MlxArray } = await import("@mlx-bun/mlx/array");
      const ffi = await import("@mlx-bun/mlx/ffi"), { Dtype } = ffi;
      const ops = await import("@mlx-bun/mlx/ops");
      const { Flux2VaeDecoder, parseFlux2VaeConfig } = await import("../../src/models/moss-image/vae");
      const { Flux2ResnetBlock, Flux2MidAttention } = await import("../../src/models/moss-image/vae-layers");
      const nativeFiles = [ffi.LIBMLXC_PATH, ...["libmlx.dylib", "libjaccl.dylib", "mlx.metallib"].map(name => join(dirname(ffi.LIBMLXC_PATH), name))];
      report.runtime = { mlxVersion: ffi.MLX_VERSION, architecture: ffi.deviceArchitecture(),
        nativeSha256: Object.fromEntries(await Promise.all(nativeFiles.map(async path => [path, await fileSha256(path)]))) };
      assert.equal(ffi.MLX_VERSION, REFERENCE.mlxVersion);
      const copy = (value: MlxArray): HostTensor => {
        using contiguous = ops.contiguous(value);
        const dtype = value.dtype === Dtype.bfloat16 ? "BF16" : value.dtype === Dtype.float32 ? "F32" : value.dtype === Dtype.uint8 ? "U8" : null;
        assert(dtype, `unexpected candidate dtype ${value.dtype}`);
        return { dtype, shape: value.shape, bytes: contiguous.rawBytes() };
      };
      const config = parseFlux2VaeConfig(JSON.parse(readFileSync(join(vaeDir, "config.json"), "utf8")));
      graph = await Flux2VaeDecoder.open(vaeDir, config);
      using latents = MlxArray.fromBytesCopy(input.bytes, input.shape, Dtype.float32);
      const control = new Map<string, HostTensor>();
      {
        forwards.uninstrumented++;
        using raw = graph.decode(latents);
        using pixels = graph.pixels(raw);
        ops.evalAll([raw, pixels]);
        control.set("raw.nhwc", copy(raw)); control.set("pixels.nhwc", copy(pixels));
      }
      save();
      const observe = (name: string, value: MlxArray) => {
        assert(!held.has(name), `duplicate observation: ${name}`);
        held.set(name, ops.copyOf(value)); // Retain lazily; do not evaluate between stages.
      };
      const wrap = (owner: { forward(x: MlxArray): MlxArray }, output: string, inputName?: string) => {
        const original = owner.forward, descriptor = Object.getOwnPropertyDescriptor(owner, "forward");
        restore.push(() => { if (descriptor) Object.defineProperty(owner, "forward", descriptor); else Reflect.deleteProperty(owner, "forward"); });
        owner.forward = function (x) {
          if (inputName) observe(inputName, x);
          const result = original.call(this, x);
          try { observe(output, result); return result; }
          catch (error) { result.dispose(); throw error; }
        };
      };
      observe("input.f32", latents);
      observe("weights.bn_mean", graph.weights.tensor("bn.running_mean")); observe("weights.bn_var", graph.weights.tensor("bn.running_var"));
      wrap(graph.input, "input.bf16"); wrap(graph.denormalize, "denormalized"); wrap(graph.unpatchify, "unpatched");
      wrap(graph.postQuantConv, "post_quant"); wrap(graph.convIn, "conv_in");
      const first = graph.midBlock[0], attention = graph.midBlock[1];
      assert(first instanceof Flux2ResnetBlock && attention instanceof Flux2MidAttention);
      wrap(first.conv1, "mid.resnet0.conv1", "mid.resnet0.silu1"); wrap(first.conv2, "mid.resnet0.conv2", "mid.resnet0.silu2");
      wrap(first, "mid.resnet0");
      for (const name of ["q", "k", "v", "out"] as const) wrap(attention[name], `mid.attention.${name}`);
      wrap(attention, "mid.attention"); wrap(graph.midBlock[2]!, "mid.resnet1");
      graph.upBlocks.forEach((block, i) => block.forEach((layer, j) => wrap(layer, j <= config.layersPerBlock ? `up.${i}.resnet${j}` : `up.${i}.upsample`)));
      wrap(graph.normOut, "norm_out"); wrap(graph.convOut, "conv_out", "activation_out");
      forwards.traced++;
      using raw = graph.decode(latents);
      observe("raw.nhwc", raw);
      using pixels = graph.pixels(raw);
      observe("pixels.nhwc", pixels);
      ops.evalAll([...held.values()]);
      assert.deepEqual([...held.keys()], STAGES, "candidate observation order or inventory differs");
      const actual = new Map([...held].map(([name, value]) => [name, copy(value)]));
      for (const name of OUTPUTS) check(`candidate.observer.${name}`, actual.get(name), control.get(name));
      report.candidateObserverExact = true; save();
      let words = 0;
      for (const name of STAGES) words += check(name, actual.get(name), expected.get(name)).words;
      assert.equal(words, 72_712_448); assert.equal(checks.length, 43);
      report.status = "passed"; report.exactStages = 39; report.comparedWords = words; report.mismatchedWords = 0;
    } catch (error) {
      report.status = "failed"; report.error = String(error); throw error;
    } finally {
      try {
        for (const reset of restore.reverse()) reset();
        for (const value of held.values()) value.dispose();
        graph?.dispose();
      } finally { save(); }
    }
  }, 300_000);
});
