// One dense SFT conditional DiT forward at t=1000, with the r16 capture's exact
// noise and conditioning. This does not qualify Base, the conditioner, guidance,
// a sampling trajectory or the VAE, and does not replace the PyTorch gates.
//
// MFLUX a3b21fcaa88726b2267bd42bfc2e2d722f7d5a47, MLX/MLX-Metal 0.32.2:
// uninstrumented and observed outputs agreed on all 32,768 velocity words.
// The old Bun aa8b4df9 trace agreed at 17/97 stages. Those old Bun values are
// not expected outputs here. The expected outputs come only from MFLUX.
//
// Run on an idle GPU with BOTH MLX_BUN_MOSS_IMAGE_MFLUX_SNAPSHOT (the pinned
// SFT snapshot) and MLX_BUN_MOSS_IMAGE_MFLUX_ORACLE (the r16 capture directory).
// Neither set visibly skips; one alone fails. Copies at other paths work when
// their bytes match. The fixture's absolute paths are never opened.
// MLX_BUN_MOSS_IMAGE_MFLUX_RESULTS optionally names the external JSON report.
// All pins are checked before importing MLX or loading model weights.
// One ordinary forward and one observed forward use fresh copies of the same
// inputs. Hooks only copy original operation inputs/returns, call each original
// method once, return its result unchanged, and restore methods in finally.
import { describe, expect, test } from "bun:test";
import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { arch, platform, release, tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { SafetensorsFile } from "../../src/artifacts/safetensors";
import type { MossRefinerAttention, MossRefinerFeedForward } from "../../src/models/moss-image/blocks";
import { compare, compareSpatial, unpinnedEntries, verifyPinned, type Stats, type Verification } from "./moss-image-oracle-checks";
import { fileSha256, optInAll, sha256 } from "./real-weight-inputs";

const OPT_IN = ["MLX_BUN_MOSS_IMAGE_MFLUX_SNAPSHOT", "MLX_BUN_MOSS_IMAGE_MFLUX_ORACLE"] as const;
const REFERENCE = {
  mfluxRevision: "a3b21fcaa88726b2267bd42bfc2e2d722f7d5a47", mfluxVersion: "0.23.0",
  mlxVersion: "0.32.2", mlxMetalVersion: "0.32.2", pythonVersion: "3.12.13",
  device: "Apple M4 Pro", architecture: "applegpu_g16s", platform: "macOS-27.2-arm64-arm-64bit",
  model: "OpenMOSS-Team/MOSS-Image-SFT", modelRevision: "f972bd4b4b9e3852133cc5da954d87bc32cd8fb9",
  native: {
    "libmlx.dylib": "d24c7a9b9d55a76bfd3bbcd1d042251a185cbadcb6340c3244a6ffa3dcb7c7e8",
    "mlx.metallib": "dc59d1cceb1a5c7e578232e6e41e28e2c73c9463ac6dbc3886c3ee17ffc270ed",
  },
  producerSha256: "a514c1964e21d6ec0428944493998fa1df0687658d639f6fb81c7b0b30394d9d",
  comparisonSha256: "3496ddd43a8552ba33280dbe43d387f3c77893abbae6d6dfde9be273dc8363a0",
  originalNoiseFileSha256: "3855b5b7d668b749fb5e855c79b9668d6891816f3d76f407e1471e17cc7a5b4e",
  originalConditioningFileSha256: "8d4fb0dda2c92b40b09ca1601fd385f30550a49eb49942235bbeb6ff58124122",
} as const;

const SNAPSHOT_PINS = {
  "transformer/config.json": "3291c3a1c7adc22b8182a0de25ca8ec97474d72715ce84adbab09cc0be24f666",
  "transformer/pipeline_moss_image.py": "1dac1aca9feb1bfdfc727a401e4b67d61a505d3190706d1b7d2d784f88678b31",
  "transformer/diffusion_pytorch_model.safetensors.index.json": "b609327fc75dbe5080e7e095d8b727d74d728b4f98e8b047133b0082cfa2fb03",
  "transformer/diffusion_pytorch_model-00001-of-00003.safetensors": "e40d3444940a0b0fd7cd45ba7959a5bd3d5efd7ddf87aae5ce4d87ce8aa03d01",
  "transformer/diffusion_pytorch_model-00002-of-00003.safetensors": "d106da790ec2924ffd8af04b4ffa8f8de281a974b58e55649c3ec596dc8ef033",
  "transformer/diffusion_pytorch_model-00003-of-00003.safetensors": "11f637ab17c7093344a6110a1e87ffda8e56558dc55183d8e790222cfcdcf52d",
} as const;

// The two tensor hashes are frozen in r16/report.json, itself pinned here.
// Never take a replacement hash from a caller's manifest or environment.
const CAPTURE_PINS = {
  "manifest.json": "48ca53a307837bdbbbca19179c41b78829c23b242d0064685e1b99447a99744e",
  "report.json": "131f49ba8837e1abf00d109ae65801ecd1ece534a1307474b5efc09c8e8a11be",
  "mflux-control.json": "48655cb677e49383cb470b9b21fa1572502afdb2f0d8cd6bfaac3d5c9811d7d2",
  "mflux-traced.json": "129001743c5b19e8a5141f2347f74fa6f36d91798b2331fb60f8febd39f302b4",
  "mflux-control.safetensors": "b22191eec2bb96d5dd8a3dd070ffcfa130ddf5034cacbc4def04cf212bfc0cc1",
  "mflux-traced.safetensors": "defc5d11f3e56b2b82e0f79f58aeda4cf525e39945f7dfd93d1ddc104f3ec0a5",
} as const;

const INPUTS = {
  "input.latents": { dtype: "F32", shape: [1, 128, 16, 16], sha256: "afb3c2accd3f1d32c0fae51446b5dc3101d68c57ec31c3c16c8cdffece4b6934" },
  "input.positive": { dtype: "BF16", shape: [1, 23, 4096], sha256: "1401824b09cb8409dcd12a76dafc44c68f8a5b822b3ebe07882173d7acb9c8d5" },
} as const;

// Same selection and ordering as r16/compare.ts, including all text rows in
// joint.41.output. MFLUX's single packed RoPE capture supplies two layout views.
const STAGES = ["input.latents", "input.positive", "time.sinusoid", "time.in_projection", "time.activation", "time.embedding",
  "modulation.block", "modulation.head", "video.input", "video.embedding", "rope.sin", "rope.cos", "text.projection"];
for (let i = 0; i < 2; i++)
  for (const suffix of ["input", "norm1", "qkv", "q.input", "q", "k.input", "k", "q_rot", "k_rot", "attention", "projected",
    "after_attention", "norm2", "up", "gate", "activation", "down", "output"])
    STAGES.push(`text.${i}.${suffix}`);
STAGES.push("joint.input");
for (let i = 0; i < 42; i++) STAGES.push(`joint.${i}.output`);
STAGES.push("head.input", "head.norm", "head.modulated", "head.projected", "velocity");

interface HostTensor { dtype: string; shape: readonly number[]; values: Float32Array }
interface Measurement {
  stage: string; pass: boolean; measured?: Stats; error?: string;
  actual?: { dtype: string; shape: readonly number[]; float32Sha256: string };
  expected?: { dtype: string; shape: readonly number[]; float32Sha256: string };
}

/** Copy words without numeric conversion, preserving BF16 signed zero and NaN payloads. */
function widen(bytes: Uint8Array, dtype: string): Float32Array {
  if (dtype === "F32") return new Float32Array(bytes.slice().buffer);
  if (dtype !== "BF16") throw new Error(`unsupported capture dtype ${dtype}`);
  const source = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength), words = new Uint32Array(bytes.byteLength / 2);
  for (let i = 0; i < words.length; i++) words[i] = source.getUint16(2 * i, true) << 16;
  return new Float32Array(words.buffer);
}

function measure(stage: string, actual: HostTensor | undefined, expected: HostTensor | undefined, spatial = false): Measurement {
  const describe = (t: HostTensor) => ({ dtype: t.dtype, shape: t.shape,
    float32Sha256: sha256(new Uint8Array(t.values.buffer, t.values.byteOffset, t.values.byteLength)) });
  const result: Measurement = { stage, pass: false, actual: actual && describe(actual), expected: expected && describe(expected) };
  if (!actual || !expected) return { ...result, error: "missing observation or reference" };
  try {
    result.measured = spatial ? compareSpatial(actual.values, expected.values, 128)
      : compare(actual.values, expected.values, expected.shape.at(-1)!);
    if (actual.shape.join() !== expected.shape.join()) result.error = "shape mismatch";
    result.pass = !result.error && result.measured.elements === expected.values.length
      && result.measured.bitMismatches === 0 && result.measured.nonFinite === 0;
  } catch (error) { result.error = String(error); }
  return result;
}

describe("MOSS-Image SFT t1000 against pinned MFLUX, exact float32 words", () => {
  if (OPT_IN.every(name => process.env[name] === undefined)) {
    test.skip(`needs ${OPT_IN.join(" and ")}`, () => {});
    return;
  }

  test("all 97 common stages and the uninstrumented velocity are exact and finite", async () => {
    const resultsPath = process.env.MLX_BUN_MOSS_IMAGE_MFLUX_RESULTS ?? join(tmpdir(), "moss-image-mflux-results.json");
    const root = resolve(import.meta.dir, "../../../..");
    const git = (...args: string[]) => execFileSync("git", args, { cwd: root, encoding: "utf8" }).trim();
    const checks: Measurement[] = [], issues: string[] = [];
    const opened: SafetensorsFile[] = [];
    const expected = new Map<string, HostTensor>(), actual = new Map<string, HostTensor>();
    let candidateControl: HostTensor | undefined;
    const run: {
      status: "incomplete" | "passed" | "failed"; error?: string;
      scope: string; reference: typeof REFERENCE; comparison: string; selectedStages: string[];
      implementation?: { commit: string; modified: string[]; bun: string; host: string; testSha256: string; helperSha256: string };
      runtime?: { mlxVersion: string; architecture: string; libmlxcPath: string; libmlxcSha256: string; companionFiles: Record<string, string | null> };
      inputs: { verified: boolean; snapshot?: Verification; captures?: Verification; unpinned: string[]; tensorSha256: Record<string, string> };
      forwards: { control: number; traced: number; controlCompleted: boolean; tracedCompleted: boolean };
      rotations: number; hookOrder: string[]; checks: Measurement[]; issues: string[]; failures: string[];
    } = {
      status: "incomplete", scope: "SFT dense conditional DiT, t=1000, latents [1,128,16,16], context [1,23,4096], no skipped blocks",
      reference: REFERENCE, comparison: "All float32 words, signed zero included; BF16 widened exactly; non-finite values fail independently",
      selectedStages: STAGES, inputs: { verified: false, unpinned: [], tensorSha256: {} },
      forwards: { control: 0, traced: 0, controlCompleted: false, tracedCompleted: false },
      rotations: 0, hookOrder: [], checks, issues, failures: [],
    };
    const save = () => writeFileSync(resultsPath, JSON.stringify(run,
      (_key, value) => typeof value === "number" && !Number.isFinite(value) ? String(value) : value, 2) + "\n");
    save(); // A killed or timed-out process leaves an incomplete report.
    try {
      const opted = optInAll(process.env, OPT_IN, "MOSS-Image MFLUX exact comparison")!;
      const snapshot = opted.MLX_BUN_MOSS_IMAGE_MFLUX_SNAPSHOT, oracle = opted.MLX_BUN_MOSS_IMAGE_MFLUX_ORACLE;
      run.implementation = { commit: git("rev-parse", "HEAD"), modified: git("status", "--porcelain").split("\n").filter(Boolean),
        bun: Bun.version, host: `${platform()} ${release()} ${arch()}`,
        testSha256: await fileSha256(import.meta.path), helperSha256: await fileSha256(join(import.meta.dir, "moss-image-oracle-checks.ts")) };
      run.inputs.snapshot = await verifyPinned(snapshot, SNAPSHOT_PINS);
      run.inputs.captures = await verifyPinned(oracle, CAPTURE_PINS);
      run.inputs.unpinned = unpinnedEntries(snapshot, SNAPSHOT_PINS);
      const problems = [...run.inputs.snapshot.mismatched, ...run.inputs.captures.mismatched, ...run.inputs.unpinned.map(p => `unpinned snapshot file: ${p}`)];
      if (problems.length) throw new Error(`input verification failed:\n${problems.join("\n")}`);

      // These metadata files have embedded pins too. Their path strings are provenance only.
      const manifest = JSON.parse(readFileSync(join(oracle, "manifest.json"), "utf8"));
      const report = JSON.parse(readFileSync(join(oracle, "report.json"), "utf8"));
      if (manifest.source.mflux !== REFERENCE.mfluxRevision || manifest.packages.mflux.version !== REFERENCE.mfluxVersion
        || manifest.packages.mlx.version !== REFERENCE.mlxVersion || manifest.packages["mlx-metal"].version !== REFERENCE.mlxMetalVersion)
        throw new Error("unexpected independent producer revision or versions");
      if (STAGES.length !== 97 || JSON.stringify(report.order) !== JSON.stringify(STAGES)) throw new Error("selected stages differ from pinned r16 comparison");
      for (const mode of ["control", "traced"] as const) {
        const info = JSON.parse(readFileSync(join(oracle, `mflux-${mode}.json`), "utf8"));
        if (info.status !== "complete" || info.forward_calls !== 1 || info.mode !== mode
          || info.manifest_sha256 !== CAPTURE_PINS["manifest.json"] || info.output_sha256 !== CAPTURE_PINS[`mflux-${mode}.safetensors`])
          throw new Error(`incomplete or inconsistent MFLUX ${mode}`);
      }

      const { SafetensorsFile } = await import("../../src/artifacts/safetensors");
      const control = SafetensorsFile.open(join(oracle, "mflux-control.safetensors"));
      opened.push(control);
      const traced = SafetensorsFile.open(join(oracle, "mflux-traced.safetensors"));
      opened.push(traced);
      const host = (source: typeof control, name: string): HostTensor => {
        const info = source.tensors.get(name);
        if (!info) throw new Error(`missing reference ${name}`);
        return { dtype: info.dtype, shape: info.shape, values: widen(source.view(name), info.dtype) };
      };
      if (control.tensors.size !== 3 || traced.tensors.size !== 96) throw new Error("unexpected independent capture set");
      for (const [name, pin] of Object.entries(INPUTS)) {
        const t = host(control, name), digest = sha256(control.view(name));
        run.inputs.tensorSha256[name] = digest;
        if (t.dtype !== pin.dtype || t.shape.join() !== pin.shape.join() || digest !== pin.sha256)
          throw new Error(`input payload differs: ${name}`);
      }
      for (const name of STAGES.filter(name => name !== "rope.sin" && name !== "rope.cos")) expected.set(name, host(traced, name));
      const packed = host(traced, "rope.packed");
      if (packed.dtype !== "BF16" || packed.shape.join() !== "1,279,128") throw new Error("unexpected packed RoPE layout");
      // Layout copies only: [sin half | cos half] -> duplicated halves for each.
      // Copy uint32 words after exact widening, without trigonometry or rerounding.
      const packedWords = new Uint32Array(packed.values.buffer);
      for (const [part, offset] of [["sin", 0], ["cos", 64]] as const) {
        const words = new Uint32Array(279 * 128);
        for (let row = 0; row < 279; row++) {
          const half = packedWords.subarray(row * 128 + offset, row * 128 + offset + 64);
          words.set(half, row * 128); words.set(half, row * 128 + 64);
        }
        expected.set(`rope.${part}`, { dtype: "BF16", shape: [1, 279, 1, 128], values: new Float32Array(words.buffer) });
      }
      for (const name of ["input.latents", "input.positive", "velocity"])
        checks.push(measure(`mflux.hooks.${name}`, expected.get(name), host(control, name), name !== "input.positive"));
      run.inputs.verified = true;
      save();

      const { MlxArray } = await import("@mlx-bun/mlx/array");
      const ffi = await import("@mlx-bun/mlx/ffi"), { Dtype } = ffi;
      const ops = await import("@mlx-bun/mlx/ops");
      const { MossImageTransformer, parseMossTransformerConfig } = await import("../../src/models/moss-image/transformer");
      const companions: Record<string, string | null> = {};
      for (const name of ["libmlx.dylib", "mlx.metallib"]) {
        const path = join(dirname(ffi.LIBMLXC_PATH), name);
        companions[path] = existsSync(path) ? await fileSha256(path) : null;
      }
      run.runtime = { mlxVersion: ffi.MLX_VERSION, architecture: ffi.deviceArchitecture(), libmlxcPath: ffi.LIBMLXC_PATH,
        libmlxcSha256: await fileSha256(ffi.LIBMLXC_PATH), companionFiles: companions };
      if (ffi.MLX_VERSION !== REFERENCE.mlxVersion) issues.push(`MLX version ${ffi.MLX_VERSION}, reference ${REFERENCE.mlxVersion}`);
      const copy = (array: MlxArray): HostTensor => {
        using contiguous = ops.contiguous(array);
        contiguous.eval();
        const dtype = array.dtype === Dtype.bfloat16 ? "BF16" : array.dtype === Dtype.float32 ? "F32" : String(array.dtype);
        return { dtype, shape: array.shape, values: widen(contiguous.rawBytes(), dtype) };
      };
      const device = (name: keyof typeof INPUTS) => MlxArray.fromBytesCopy(control.view(name), [...INPUTS[name].shape],
        INPUTS[name].dtype === "F32" ? Dtype.float32 : Dtype.bfloat16);
      // Exercise the production graph; hooks below only observe its bound operations.
      const model = await MossImageTransformer.open(join(snapshot, "transformer"),
        parseMossTransformerConfig(JSON.parse(readFileSync(join(snapshot, "transformer/config.json"), "utf8"))));
      const restore: (() => void)[] = [];
      const patch = <T extends object, K extends keyof T>(object: T, key: K, replacement: T[K]) => {
        const descriptor = Object.getOwnPropertyDescriptor(object, key);
        restore.push(() => { if (descriptor) Object.defineProperty(object, key, descriptor); else Reflect.deleteProperty(object, key); });
        object[key] = replacement;
      };
      const observe = (name: string, array: MlxArray) => {
        run.hookOrder.push(name);
        if (actual.has(name)) { issues.push(`duplicate observation: ${name}`); return; }
        try { actual.set(name, copy(array)); }
        catch (error) { issues.push(`observation ${name}: ${String(error)}`); }
      };
      const wrap = <Args extends [MlxArray, ...unknown[]]>(object: { forward(...args: Args): MlxArray }, output: string, input?: string) => {
        const original = object.forward;
        patch(object, "forward", function (this: typeof object, ...args: Args) {
          if (input) observe(input, args[0]);
          const result = original.apply(this, args);
          observe(output, result);
          return result;
        });
      };
      try {
        if (model.depth !== 42 || model.textBlocks.length !== 2) throw new Error("unexpected model depth");
        // No hooks are installed for the candidate control. Inputs are fresh for each forward.
        {
          using latents = device("input.latents"), positive = device("input.positive");
          run.forwards.control++; save();
          using velocity = model.velocity(latents, 1000, positive);
          candidateControl = copy(velocity);
          run.forwards.controlCompleted = true;
        }
        wrap(model.timestepEmbedder.inProj, "time.in_projection", "time.sinusoid");
        wrap(model.timestepEmbedder.outProj, "time.embedding", "time.activation");
        wrap(model.modulation.block, "modulation.block"); wrap(model.modulation.head, "modulation.head");
        wrap(model.latentEmbedder.proj, "video.embedding", "video.input"); wrap(model.textProjection, "text.projection");
        const layout = model.rope.layout;
        patch(model.rope, "layout", function (this: typeof model.rope, ...args) {
          const result = layout.apply(this, args);
          observe("rope.cos", result.joint.cos); observe("rope.sin", result.joint.sin);
          return result;
        });
        const rotate = model.rope.apply;
        patch(model.rope, "apply", function (this: typeof model.rope, ...args) {
          const result = rotate.apply(this, args), n = run.rotations++;
          if (n < 4) observe(`text.${Math.floor(n / 2)}.${n % 2 === 0 ? "q_rot" : "k_rot"}`, result);
          return result;
        });
        for (let i = 0; i < 2; i++) {
          const block = model.textBlocks[i]!, p = `text.${i}`;
          // The generic graph constructs these concrete layers; its forward
          // contract intentionally exposes fewer fields than this observer needs.
          const attention = block.attention as MossRefinerAttention;
          const feedForward = block.feedForward as MossRefinerFeedForward;
          wrap(block, `${p}.output`, `${p}.input`); wrap(block.norm1, `${p}.norm1`);
          wrap(attention.qkv, `${p}.qkv`);
          wrap(attention.qNorm, `${p}.q`, `${p}.q.input`); wrap(attention.kNorm, `${p}.k`, `${p}.k.input`);
          wrap(attention.proj, `${p}.projected`, `${p}.attention`);
          wrap(block.norm2, `${p}.norm2`, `${p}.after_attention`);
          wrap(feedForward.up, `${p}.up`); wrap(feedForward.gate, `${p}.gate`);
          wrap(feedForward.down, `${p}.down`, `${p}.activation`);
        }
        for (let i = 0; i < 42; i++) wrap(model.blocks[i]!, `joint.${i}.output`, i === 0 ? "joint.input" : undefined);
        wrap(model.head.norm, "head.norm", "head.input"); wrap(model.head.proj, "head.projected", "head.modulated");
        {
          using latents = device("input.latents"), positive = device("input.positive");
          observe("input.latents", latents); observe("input.positive", positive);
          run.forwards.traced++; save();
          using velocity = model.velocity(latents, 1000, positive);
          observe("velocity", velocity);
          run.forwards.tracedCompleted = true;
        }
      } finally {
        try {
          for (const undo of restore.reverse()) {
            try { undo(); } catch (error) { issues.push(`hook restoration: ${String(error)}`); }
          }
        }
        finally { try { model.dispose(); } finally { ffi.clearCache(); } }
      }
      if (run.rotations !== 88) issues.push(`observed ${run.rotations} RoPE calls, expected 88`);
      if (run.hookOrder.length !== 97 || actual.size !== 97) issues.push(`observed ${run.hookOrder.length} calls / ${actual.size} tensors, expected 97`);
      for (const name of actual.keys()) if (!STAGES.includes(name)) issues.push(`unexpected observation: ${name}`);
    } catch (error) {
      run.error = error instanceof Error ? error.stack ?? error.message : String(error);
    } finally {
      for (const source of opened) {
        try { source.mmap.unmap(); } catch (error) { issues.push(`capture cleanup: ${String(error)}`); }
      }
      // Record every available measurement before the single assertion. Missing
      // stages remain explicit failures, including after an execution error.
      checks.push(measure("candidate.control.velocity", candidateControl, expected.get("velocity"), true));
      checks.push(measure("candidate.hooks.velocity", actual.get("velocity"), candidateControl, true));
      for (const name of STAGES) checks.push(measure(name, actual.get(name), expected.get(name), name === "input.latents" || name === "velocity"));
      const complete = run.inputs.verified && run.forwards.controlCompleted && run.forwards.tracedCompleted
        && STAGES.every(name => actual.has(name)) && !run.error;
      run.failures = [...checks.filter(check => !check.pass).map(check => check.stage), ...issues];
      if (run.error) run.failures.unshift(run.error.split("\n")[0]!);
      if (!complete) run.failures.push("execution incomplete");
      run.status = complete ? run.failures.length ? "failed" : "passed" : "incomplete";
      save();
      console.log(`MFLUX SFT t1000: ${run.status}; ${STAGES.filter(name => checks.find(check => check.stage === name)?.pass).length}/97 exact stages; results: ${resultsPath}`);
    }
    expect(run.failures).toEqual([]);
  }, 1_800_000);
});
