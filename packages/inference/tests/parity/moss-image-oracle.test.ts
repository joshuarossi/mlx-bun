// MOSS-Image's stages against the external PyTorch reference: the snapshot's own
// pipeline_moss_image.py with transformers 5.12.1's Qwen3_5Model and diffusers
// 0.38.0, torch 2.9.1 on the CPU, run from an environment outside every mlx-bun
// checkout (this repository holds no Python and starts none). The reference
// wrote its tensors as safetensors captures: the tokenized prompts and the
// encoder's hidden states, the schedule, its own seeded noise (equal seeds do
// not give equal noise across backends, so the noise is an input here), DiT
// stage outputs at two timesteps with and without the skipped block, an 8-step
// guided trajectory, and the conditioner's linear attention (`delta`); and, as a
// measure of its own variation, the same DiT stages and trajectory on its MPS
// backend (`dit-mps`, `sample-8-mps`). Each comparison feeds both sides
// identical inputs.
//
// INPUTS are verified before anything is read for a comparison: the SHA-256 of
// every snapshot file and capture the comparisons read is computed from its bytes
// and must equal the pins below for that revision, and every file in a snapshot
// directory a loader reads must be pinned (an unpinned index or shard could be
// selected in place of the pinned bytes). A revision without pins, a mismatch or
// an unpinned file fails the run. A Hugging Face cache symlink's target name is
// recorded as provenance only (a filename claim, not a verification of the bytes).
// The results file says whether the run completed: a test that stopped before
// recording all its checks leaves the status `incomplete`, never a pass.
//
// ORIGINAL criteria, fixed before the first run, from the arithmetic each stage does:
// - token ids and the schedule: exact.
// - conditioner hidden states and every DiT stage output: relative Frobenius
//   error <= 3e-2, per-token cosine >= 0.999, mean cosine >= 0.9995 (bf16
//   activations through up to 42 blocks, per-operation rounding about 2^-9).
// - the 8-step guided trajectory: relative error <= 6e-2 and cosine >= 0.995 at
//   every step.
//
// Calculation bugs the first runs exposed, fixed in the code (not in the bounds):
// - the schedule replayed torch.linspace with the product rounded separately;
//   the reference's CPU kernel fuses it (one multiply-add), which moved two
//   noise levels by one float32 ulp. Fixed in models/moss-image/scheduler.ts.
// - this test read a transposed MLX view's storage order (a cast keeps the
//   layout), which made the velocity look uncorrelated; reads are row-major now,
//   and generation/image.ts makes decoded pixels contiguous before its raw read.
//
// ADJUDICATED by independent review (2026-10-23): the last DiT block's text rows
// feed no later operation and are reported, not held; its image rows hold the
// original bounds. Every other check holds its original bounds. Two remain
// unresolved and fail here until investigated: Base's block 22 at step 4 (worst
// token, row 40, below the 0.999 cosine bound; float32 attention does not
// explain it) and trajectory steps 5 to 7 beyond the original bounds. The
// review's proposed experiments: block 22 alone on identical captured block-21
// inputs and modulation, comparing its norm, projections, RoPE, attention, SITU
// and residual outputs; and each step's velocity on identical reference
// trajectory states. The rule "relative error <= SPREAD_FACTOR times the
// reference's own MPS-vs-CPU relative error" is recorded as an investigative
// bound beside the original verdict and is not asserted.
//
// LINEAR ATTENTION bounds (`DELTA`), fixed before the first comparison against the
// `delta` captures, which hold transformers' own l2norm, F.softplus and
// torch_chunk_gated_delta_rule outputs on seeded bf16 inputs at lengths around the
// 64-token chunk boundary, Qwen3_5RMSNormGated on seeded bf16 values
// (`gated-norm`, its bound fixed with that capture), and two real layers' linear
// attention on a 23-token and a 203-token prompt. The recurrence here steps token by token in float32;
// the reference solves 64-token chunks in float32 (cumulative log-decays, exp of
// their differences, a triangular solve). The softplus here is logaddexp(x, 0)
// below torch's threshold, where torch computes log1p(exp(x)). These checks
// measure both differences against the reference's float32 outputs.
//
// Every run writes its checks, verdicts, verified input hashes, provenance and
// the implementation's commit to MLX_BUN_MOSS_IMAGE_RESULTS (default:
// moss-image-oracle-results.json in the system temporary directory).
// Opt in with both of
//   MLX_BUN_MOSS_IMAGE_SNAPSHOT=<a MOSS-Image snapshot directory>
//   MLX_BUN_MOSS_IMAGE_ORACLE=<the reference's capture directory for that snapshot>
// Neither set skips; one alone fails.
import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import type { SafetensorsFile } from "../../src/artifacts/safetensors";
import { compare, meets, runStatus, ulpBf16, ulpDistance, ulpFloat32, unpinnedEntries, verifyPinned, type Bounds, type Stats, type UlpStats, type Verification } from "./moss-image-oracle-checks";
import { optInAll } from "./real-weight-inputs";

const OPT_IN = ["MLX_BUN_MOSS_IMAGE_SNAPSHOT", "MLX_BUN_MOSS_IMAGE_ORACLE"] as const;
const opted = optInAll(process.env, OPT_IN, "MOSS-Image oracle comparison");

/** The files of each pinned revision that the comparisons read, and the reference's captures for it: SHA-256 of their bytes. */
const PINS: Readonly<Record<string, { readonly snapshot: Readonly<Record<string, string>>; readonly captures: Readonly<Record<string, string>> }>> = {
  "85975793d8b3d432f1b6e27f352abaa4c2a4c0d3": {
    snapshot: {
      "scheduler/scheduler_config.json": "707322832cc507dfb8c51c0e0cd04d44ee2d30a9b036b6f3c47d6c17aa71adf0",
      "scheduler/pipeline_moss_image.py": "1dac1aca9feb1bfdfc727a401e4b67d61a505d3190706d1b7d2d784f88678b31",
      "text_encoder/config.json": "b31ee18a242bcfcccbe740f825f6b1d3ae231b0655eeecb5de3e98d504b7d68c",
      "text_encoder/model.safetensors.index.json": "0af6fa3fa36ba8dcbb6b7ad0325a36c5b1b69862a9a1f1486b1b80385bd8f5ee",
      "text_encoder/model-00001-of-00004.safetensors": "abfaa3d3a8612508c85ee8f6da9c734b862f10298b903765c4ad384177c32b0b",
      "text_encoder/model-00002-of-00004.safetensors": "9112637fa6bf4d07bafd6ae268852b18d3d0c1242f4ee901c5579006e5bd4894",
      "text_encoder/model-00003-of-00004.safetensors": "956f1ef51d0cfe610b0d22987c0b7821c36e3ce228abceccef523518bcf079dc",
      "text_encoder/model-00004-of-00004.safetensors": "9e21d20e8adde88c3e0b65d4a0d251f143d98ee9d52db36b4348361091e4e208",
      "tokenizer/tokenizer.json": "06b9509352d2af50381ab2247e083b80d32d5c0aba91c272ca9ff729b6a0e523",
      "tokenizer/tokenizer_config.json": "bee8eba30f0eb4af73c0fe2cd06d0f89b657d7819941c438157ec42f7c80ea87",
      "tokenizer/chat_template.jinja": "a4aee8afcf2e0711942cf848899be66016f8d14a889ff9ede07bca099c28f715",
      "transformer/config.json": "3291c3a1c7adc22b8182a0de25ca8ec97474d72715ce84adbab09cc0be24f666",
      "transformer/pipeline_moss_image.py": "1dac1aca9feb1bfdfc727a401e4b67d61a505d3190706d1b7d2d784f88678b31",
      "transformer/diffusion_pytorch_model.safetensors.index.json": "b609327fc75dbe5080e7e095d8b727d74d728b4f98e8b047133b0082cfa2fb03",
      "transformer/diffusion_pytorch_model-00001-of-00003.safetensors": "ae085fba123b6df67daf90aa9698fadee60c73e45bcaf3f3043d15f34e7a1804",
      "transformer/diffusion_pytorch_model-00002-of-00003.safetensors": "806e876d80c7fba560663a3a95580e6c7033da3f9ea3c52765245ef0e1818f75",
      "transformer/diffusion_pytorch_model-00003-of-00003.safetensors": "5f319b72c40324294007c270d78112425627b537fcd8769b3c00f9f070e506a9",
    },
    captures: {
      "encode.json": "e76f6baf6681ad1d75c4503a545f9f2d49900bed566b0dc1d76d4373f6b503bf",
      "encode.safetensors": "8d4fb0dda2c92b40b09ca1601fd385f30550a49eb49942235bbeb6ff58124122",
      "schedule-8.safetensors": "0081c117fcbbaf074a8992535e4869df1356a942403a5926984e989047bb411c",
      "schedule-50.safetensors": "d3c9c2dc93d29da5af446789ece7122c9993254830ba0a2648da3e38bce46698",
      "noise.safetensors": "3855b5b7d668b749fb5e855c79b9668d6891816f3d76f407e1471e17cc7a5b4e",
      "dit.safetensors": "c29012904c494a087ae6e08fb997ea3c6231fcb845b622081a5f63bc455c00b1",
      "dit-mps.safetensors": "cd37e58473024ddd1d9494f729c2447221dc82eda9b41e733067713187643b82",
      "sample-8.safetensors": "c38907e0e6b17c314d0cd81b9f61dccb837890c9bd28016dace337c32d02c22e",
      "sample-8-mps.safetensors": "9054abae6e9a7c728a3d0a992f46f7e17605db5581d415c2022ece923dcdf093",
      "delta.json": "5ed696c58db8008643e4bd02cfa8e53b2cfc90966dab0755830c5589191093d9",
      "delta.safetensors": "9a3535ea24f3fad9a1a5fc7c3f01a794d315da035108ae6fed86b75dd0e64fef",
      "gated-norm.json": "07200b37b3636bdd16c44afe04c91d9c80d460364f726ebf4af135e5bad78452",
      "gated-norm.safetensors": "567fa19e7089195ddbc088ad71cb6a8cd8dc651c8274e3b65dae5d10617b4149",
    },
  },
  "f972bd4b4b9e3852133cc5da954d87bc32cd8fb9": {
    snapshot: {
      "scheduler/scheduler_config.json": "707322832cc507dfb8c51c0e0cd04d44ee2d30a9b036b6f3c47d6c17aa71adf0",
      "scheduler/pipeline_moss_image.py": "1dac1aca9feb1bfdfc727a401e4b67d61a505d3190706d1b7d2d784f88678b31",
      "text_encoder/config.json": "b31ee18a242bcfcccbe740f825f6b1d3ae231b0655eeecb5de3e98d504b7d68c",
      "text_encoder/model.safetensors.index.json": "0af6fa3fa36ba8dcbb6b7ad0325a36c5b1b69862a9a1f1486b1b80385bd8f5ee",
      "text_encoder/model-00001-of-00004.safetensors": "abfaa3d3a8612508c85ee8f6da9c734b862f10298b903765c4ad384177c32b0b",
      "text_encoder/model-00002-of-00004.safetensors": "9112637fa6bf4d07bafd6ae268852b18d3d0c1242f4ee901c5579006e5bd4894",
      "text_encoder/model-00003-of-00004.safetensors": "956f1ef51d0cfe610b0d22987c0b7821c36e3ce228abceccef523518bcf079dc",
      "text_encoder/model-00004-of-00004.safetensors": "9e21d20e8adde88c3e0b65d4a0d251f143d98ee9d52db36b4348361091e4e208",
      "tokenizer/tokenizer.json": "06b9509352d2af50381ab2247e083b80d32d5c0aba91c272ca9ff729b6a0e523",
      "tokenizer/tokenizer_config.json": "bee8eba30f0eb4af73c0fe2cd06d0f89b657d7819941c438157ec42f7c80ea87",
      "tokenizer/chat_template.jinja": "a4aee8afcf2e0711942cf848899be66016f8d14a889ff9ede07bca099c28f715",
      "transformer/config.json": "3291c3a1c7adc22b8182a0de25ca8ec97474d72715ce84adbab09cc0be24f666",
      "transformer/pipeline_moss_image.py": "1dac1aca9feb1bfdfc727a401e4b67d61a505d3190706d1b7d2d784f88678b31",
      "transformer/diffusion_pytorch_model.safetensors.index.json": "b609327fc75dbe5080e7e095d8b727d74d728b4f98e8b047133b0082cfa2fb03",
      "transformer/diffusion_pytorch_model-00001-of-00003.safetensors": "e40d3444940a0b0fd7cd45ba7959a5bd3d5efd7ddf87aae5ce4d87ce8aa03d01",
      "transformer/diffusion_pytorch_model-00002-of-00003.safetensors": "d106da790ec2924ffd8af04b4ffa8f8de281a974b58e55649c3ec596dc8ef033",
      "transformer/diffusion_pytorch_model-00003-of-00003.safetensors": "11f637ab17c7093344a6110a1e87ffda8e56558dc55183d8e790222cfcdcf52d",
    },
    captures: {
      "encode.json": "1e07a7dcba95a80bfecb141ba9b1f129ee4954435a5bebe080ee013453124f15",
      "encode.safetensors": "8d4fb0dda2c92b40b09ca1601fd385f30550a49eb49942235bbeb6ff58124122",
      "schedule-8.safetensors": "0081c117fcbbaf074a8992535e4869df1356a942403a5926984e989047bb411c",
      "schedule-50.safetensors": "d3c9c2dc93d29da5af446789ece7122c9993254830ba0a2648da3e38bce46698",
      "noise.safetensors": "3855b5b7d668b749fb5e855c79b9668d6891816f3d76f407e1471e17cc7a5b4e",
      "dit.safetensors": "c8d1115251904d74ff6fbd016227c31247048cee9f42aa0486b83ec98e782dea",
      "dit-mps.safetensors": "aaf662162eeaf34a92c6867cba7a6215ab18f2547eee96cff5a580abbfe1c7d4",
      "sample-8.safetensors": "d4ea36617636b350a75240b84f8f7cfb65e801a94bf0a7bd15f446563f40dcea",
      "sample-8-mps.safetensors": "3c0a72b2c53f2afe4370423398f3412101c6830183d53bb481b59c40a1c177b4",
      "delta.json": "c0d93d859fe19c023c13d3be8bcdb550453a1492a98856c54207233cdb9f9f9d",
      "delta.safetensors": "9a3535ea24f3fad9a1a5fc7c3f01a794d315da035108ae6fed86b75dd0e64fef",
      "gated-norm.json": "07200b37b3636bdd16c44afe04c91d9c80d460364f726ebf4af135e5bad78452",
      "gated-norm.safetensors": "567fa19e7089195ddbc088ad71cb6a8cd8dc651c8274e3b65dae5d10617b4149",
    },
  },
};

const ORIGINAL = {
  hidden: { relative: 3e-2, minCosine: 0.999, meanCosine: 0.9995 },
  trajectory: { relative: 6e-2, minCosine: 0.995 },
} as const;
/** Investigative only (see the header). */
const SPREAD_FACTOR = 2;
/** Linear attention bounds, fixed before the first comparison (see the header). */
const DELTA = {
  /** bf16 ulps of the reference value, every element. */
  l2NormUlps: 1,
  /** The gated norm (Qwen3_5RMSNormGated) on seeded bf16 values: bf16 ulps of the reference value, every element. Fixed with
   * its capture, before its first comparison. */
  gatedNormUlps: 1,
  /** float32 ulps of the reference value, every element. */
  softplusUlps: 4,
  logDecayUlps: 8,
  /** The recurrence's float32 outputs from the reference's own float32 inputs: relative Frobenius error, every length. */
  recurrenceRelative: 1e-4,
  /** The whole rule's bf16 outputs from the bf16 inputs. */
  rule: { relative: 4e-3, minCosine: 0.99999 },
  /** A real layer's linear attention on its real input. */
  mixer: { relative: 1e-2, minCosine: 0.9999 },
} as const;

interface Check {
  stage: string;
  measured: Stats | UlpStats;
  /** The criterion asserted and its verdict. */
  asserted: { criterion: string; pass: boolean };
  /** The original bounds' verdict, for checks the original criteria cover. */
  original?: Bounds & { pass: boolean };
  investigative?: { criterion: string; pass: boolean };
  referenceSpread?: Stats;
}

const format = (measured: Stats | UlpStats) => ("maxUlps" in measured
  ? `${measured.mismatches}/${measured.total} elements differ, at most ${measured.maxUlps.toFixed(3)} ulp`
  : `relative ${measured.relative.toExponential(3)}, max |diff| ${measured.maxAbs.toExponential(3)}, ` +
    `cosine min ${measured.minCosine.toFixed(6)} mean ${measured.meanCosine.toFixed(6)}`) +
  (measured.nonFinite ? `, ${measured.nonFinite} NON-FINITE` : "");

/** The tests in this file, by name: a run is complete only when each has recorded all its checks. */
const TESTS = ["schedule", "conditioner", "linear attention", "DiT stages", "trajectory"] as const;

describe("MOSS-Image against the PyTorch reference (adjudicated criteria; acceptance pending)", async () => {
  // A describe body always runs to collect its tests: without the opt-in, register one visible skip and read nothing.
  if (!opted) { test.skip(`needs ${OPT_IN.join(" and ")}`, () => {}); return; }
  const snapshot = opted.MLX_BUN_MOSS_IMAGE_SNAPSHOT, captures = opted.MLX_BUN_MOSS_IMAGE_ORACLE;
  const resultsPath = process.env.MLX_BUN_MOSS_IMAGE_RESULTS ?? join(tmpdir(), "moss-image-oracle-results.json");
  const { MlxArray } = await import("@mlx-bun/mlx/array");
  const { Dtype } = await import("@mlx-bun/mlx/ffi");
  const ffi = await import("@mlx-bun/mlx/ffi");
  const ops = await import("@mlx-bun/mlx/ops");
  const { SafetensorsFile: Safetensors } = await import("../../src/artifacts/safetensors");
  const { loadModelConfig } = await import("../../src/artifacts/config");
  const { Weights } = await import("../../src/artifacts/weights");
  const { gatedDeltaFloat32 } = await import("../../src/kernels/gated-delta-float32");
  const { bindMossLinear } = await import("../../src/models/moss-image/layers");
  const { MossImageSchedule, parseMossImageScheduleConfig } = await import("../../src/models/moss-image/scheduler");
  const { MossImageConditioner } = await import("../../src/models/moss-image/text-encoder");
  const { MossTextDeltaMixer, MossTextDeltaRecurrence, MossTextGatedNorm, MossTextL2Norm, MossTextLogDecay } =
    await import("../../src/models/moss-image/text-layers");
  const { MossImageTransformer, parseMossTransformerConfig } = await import("../../src/models/moss-image/transformer");
  const { denoiseLatents, guidanceFor } = await import("../../src/generation/image");
  type Array = InstanceType<typeof MlxArray>;

  const checks: Check[] = [];
  const exact: { stage: string; pass: boolean }[] = [];
  /** The tests that recorded every check they make (whatever the verdicts). */
  const completed = new Set<string>();
  const inputs: { snapshot?: Verification; captures?: Verification; unpinned: string[]; error?: string } = { unpinned: [] };
  let inputsVerified = false;

  beforeAll(async () => {
    try {
      const revision = basename(snapshot), pinned = PINS[revision];
      if (!pinned) throw new Error(`${revision} has no pins (pinned revisions: ${Object.keys(PINS).join(", ")})`);
      inputs.snapshot = await verifyPinned(snapshot, pinned.snapshot);
      inputs.captures = await verifyPinned(captures, pinned.captures);
      // Every file in a snapshot directory a loader reads must be pinned: an unpinned index or shard could be selected.
      inputs.unpinned = unpinnedEntries(snapshot, pinned.snapshot);
      const problems = [...inputs.snapshot.mismatched.map(item => `snapshot/${item}`), ...inputs.captures.mismatched.map(item => `captures/${item}`),
        ...inputs.unpinned.map(file => `snapshot/${file}: not pinned, in a directory a loader reads`)];
      if (problems.length) throw new Error(`inputs differ from the pins:\n${problems.join("\n")}`);
      inputsVerified = true;
    } catch (error) {
      inputs.error = error instanceof Error ? error.message : String(error);
      throw error;
    }
  }, 1_800_000);

  const files = new Map<string, SafetensorsFile>();
  const capture = (file: string) => {
    let opened = files.get(file);
    if (!opened) { opened = Safetensors.open(join(captures, `${file}.safetensors`)); files.set(file, opened); }
    return opened;
  };
  /** A captured tensor as float32 host values (bf16 widened exactly). */
  const host = (file: string, name: string): Float32Array => {
    const source = capture(file), info = source.tensors.get(name);
    if (!info) throw new Error(`${file}.safetensors has no ${name}`);
    const bytes = source.view(name);
    if (info.dtype === "F32") return new Float32Array(bytes.slice().buffer);
    if (info.dtype === "BF16") {
      const halves = new Uint16Array(bytes.slice().buffer), out = new Uint32Array(halves.length);
      for (let i = 0; i < halves.length; i++) out[i] = halves[i]! << 16;
      return new Float32Array(out.buffer);
    }
    if (info.dtype === "I32") return Float32Array.from(new Int32Array(bytes.slice().buffer));
    throw new Error(`unexpected capture dtype ${info.dtype}`);
  };
  /** A captured tensor on the device in its stored dtype. */
  const device = (file: string, name: string): Array => {
    const source = capture(file), info = source.tensors.get(name);
    if (!info) throw new Error(`${file}.safetensors has no ${name}`);
    const dtype = { F32: Dtype.float32, BF16: Dtype.bfloat16, I32: Dtype.int32 }[info.dtype as "F32" | "BF16" | "I32"];
    return MlxArray.fromBytesCopy(source.view(name), info.shape, dtype);
  };
  // A transposed view keeps its layout through a cast; read row-major memory.
  const values = (array: Array) => { using wide = array.astype(Dtype.float32); using rowMajor = ops.contiguous(wide); return rowMajor.toFloat32(); };

  const report = (check: Check) => {
    checks.push(check);
    console.log(`${check.stage}: ${format(check.measured)} | ${check.asserted.criterion}: ${check.asserted.pass ? "met" : "NOT MET"}` +
      (check.original && check.asserted.criterion !== "original bounds" ? ` | ORIGINAL ${check.original.pass ? "met" : "NOT MET"}` : "") +
      (check.investigative ? ` | investigative (${check.investigative.criterion}) ${check.investigative.pass ? "met" : "not met"}` : "") +
      (check.referenceSpread ? `\n  reference MPS vs CPU: ${format(check.referenceSpread)}` : ""));
  };
  /** A check the original criteria cover: asserted against them unless the review adjudicated otherwise. */
  const record = (stage: string, stats: Stats, original: Bounds,
    extra: { adjudicated?: { criterion: string; pass: boolean }; investigative?: { criterion: string; pass: boolean }; referenceSpread?: Stats } = {}) => {
    const verdict = meets(stats, original);
    report({ stage, measured: stats, original: { ...original, pass: verdict }, asserted: extra.adjudicated ?? { criterion: "original bounds", pass: verdict },
      ...(extra.investigative ? { investigative: extra.investigative } : {}), ...(extra.referenceSpread ? { referenceSpread: extra.referenceSpread } : {}) });
  };
  /** A linear attention check against its `DELTA` bound. */
  const recordDelta = (stage: string, measured: Stats | UlpStats, criterion: string, pass: boolean) => report({ stage, measured, asserted: { criterion, pass } });
  /** Every check a test recorded holds its asserted criterion (all are recorded first, so one failure hides none). */
  const assertRecorded = (from: number) =>
    expect(checks.slice(from).filter(check => !check.asserted.pass).map(check => `${check.stage}: ${check.asserted.criterion}`)).toEqual([]);

  afterAll(async () => {
    const git = (...args: string[]) => Bun.spawnSync(["git", ...args], { cwd: import.meta.dir }).stdout.toString().trim();
    const failures = checks.filter(check => !check.asserted.pass).map(check => check.stage).concat(exact.filter(item => !item.pass).map(item => item.stage));
    const originalFailures = checks.filter(check => check.original && !check.original.pass).map(check => check.stage);
    const execution = runStatus({ inputsVerified, tests: TESTS, completed, failures });
    writeFileSync(resultsPath, JSON.stringify({ status: execution.status, acceptance: "pending", execution, originalCriteria: ORIGINAL, delta: DELTA,
      adjudicated: { lastBlockTextRows: "reported", unresolved: ["block 22 at step 4 (Base)", "trajectory steps 5 to 7"] },
      investigative: { spreadFactor: SPREAD_FACTOR },
      implementation: { commit: git("rev-parse", "HEAD"), modified: git("status", "--porcelain").split("\n").filter(Boolean) },
      inputs: { revision: basename(snapshot), verified: inputsVerified, ...(inputs.error ? { error: inputs.error } : {}),
        sha256: { snapshot: inputs.snapshot?.sha256 ?? {}, captures: inputs.captures?.sha256 ?? {} }, unpinned: inputs.unpinned,
        provenanceOnly: { hubBlobNames: inputs.snapshot?.provenanceOnly ?? {} } },
      reference: inputsVerified ? JSON.parse(readFileSync(join(captures, "encode.json"), "utf8")).versions : null,
      exact, checks, failures, originalFailures }, null, 2));
    if (execution.status === "incomplete")
      console.log(`INCOMPLETE: ${inputsVerified ? "" : "inputs not verified; "}tests that did not record all their checks: ${execution.incomplete.join(", ") || "none"}`);
    console.log(`asserted criteria not met by the checks recorded: ${failures.length ? failures.join("; ") : "none"}`);
    console.log(`results written to ${resultsPath}`);
  });

  // Read only after the inputs are verified.
  const encodeMeta = () => JSON.parse(readFileSync(join(captures, "encode.json"), "utf8")) as { positive: { text: string }; negative: { text: string } };
  const schedule = () => new MossImageSchedule(parseMossImageScheduleConfig(JSON.parse(readFileSync(join(snapshot, "scheduler/scheduler_config.json"), "utf8"))));
  const transformerConfig = () => parseMossTransformerConfig(JSON.parse(readFileSync(join(snapshot, "transformer/config.json"), "utf8")));

  test("the schedule's noise levels and timesteps equal the reference's (original criterion: exact)", () => {
    expect(inputsVerified).toBe(true);
    const levels = schedule(), compared: [number[], number[]][] = [];
    for (const steps of [8, 50]) {
      const sigmas = Array.from(levels.sigmas(steps)), expected = Array.from(host(`schedule-${steps}`, "sigmas"));
      const timesteps = sigmas.slice(0, -1).map(sigma => levels.timestep(sigma)), expectedTimesteps = Array.from(host(`schedule-${steps}`, "timesteps"));
      exact.push({ stage: `schedule ${steps} steps`, pass: sigmas.join() === expected.join() && timesteps.join() === expectedTimesteps.join() });
      compared.push([sigmas, expected], [timesteps, expectedTimesteps]);
    }
    completed.add("schedule");
    for (const [ours, reference] of compared) expect(ours).toEqual(reference);
  });

  test("the conditioner's tokens equal the reference's and its hidden states agree (original criteria)", async () => {
    expect(inputsVerified).toBe(true);
    const from = checks.length;
    ffi.resetPeakMemory();
    const prompts = encodeMeta();
    const conditioner = await MossImageConditioner.open(join(snapshot, "text_encoder"), join(snapshot, "tokenizer"));
    try {
      for (const role of ["positive", "negative"] as const) {
        const text = prompts[role].text, tokens = conditioner.tokens(text), expected = Array.from(host("encode", `${role}_ids`));
        exact.push({ stage: `conditioner ${role} token ids`, pass: tokens.join() === expected.join() });
        expect(tokens).toEqual(expected);
        using hidden = conditioner.encode(text);
        record(`conditioner ${role} hidden states`, compare(values(hidden), host("encode", `${role}_embeds`), 4096), ORIGINAL.hidden);
      }
    } finally {
      conditioner.dispose();
      ffi.clearCache();
    }
    console.log(`conditioner peak ${(ffi.peakMemory() / 2 ** 30).toFixed(2)} GiB`);
    completed.add("conditioner");
    assertRecorded(from);
  }, 600_000);

  test("the conditioner's linear attention agrees with the reference's at chunk boundaries and on real layers (bounds fixed before the first run)", async () => {
    expect(inputsVerified).toBe(true);
    const from = checks.length;
    const meta = JSON.parse(readFileSync(join(captures, "delta.json"), "utf8")) as
      { lengths: number[]; layers: number[]; tokens: Record<string, number>; shape: { key_heads: number; value_heads: number; key_dim: number; value_dim: number } };
    const { key_heads: keyHeads, value_heads: valueHeads, key_dim: keyDim, value_dim: valueDim } = meta.shape;
    using aLog = device("delta", "A_log"), dtBias = device("delta", "dt_bias");
    const logDecay = new MossTextLogDecay(aLog, dtBias), norm = new MossTextL2Norm(), rule = new MossTextDeltaRecurrence(logDecay, keyDim);
    const scale = Math.fround(1 / Math.sqrt(keyDim));
    for (const length of meta.lengths) {
      const at = (name: string) => `L${length}.${name}`, tag = `L=${length}`;
      using q = device("delta", at("q")), k = device("delta", at("k")), v = device("delta", at("v"));
      using a = device("delta", at("a")), b = device("delta", at("b"));
      for (const [name, x] of [["q", q], ["k", k]] as const) {
        using ours = norm.forward(x);
        const measured = ulpDistance(values(ours), host("delta", at(`${name}_norm`)), ulpBf16);
        recordDelta(`${tag} ${name} l2norm (bf16)`, measured, `within ${DELTA.l2NormUlps} bf16 ulp`, measured.maxUlps <= DELTA.l2NormUlps);
      }
      // The softplus input exactly as the reference forms it: a.float() + dt_bias, in float32.
      using aWide = a.astype(Dtype.float32), dtWide = dtBias.astype(Dtype.float32);
      using x = ops.add(aWide, dtWide);
      using softplus = logDecay.softplus(x);
      const softplusMeasured = ulpDistance(values(softplus), host("delta", at("softplus")), ulpFloat32);
      recordDelta(`${tag} softplus (float32)`, softplusMeasured, `within ${DELTA.softplusUlps} float32 ulps`, softplusMeasured.maxUlps <= DELTA.softplusUlps);
      using g = logDecay.forward(a);
      const gMeasured = ulpDistance(values(g), host("delta", at("g")), ulpFloat32);
      recordDelta(`${tag} log-decay (float32)`, gMeasured, `within ${DELTA.logDecayUlps} float32 ulps`, gMeasured.maxUlps <= DELTA.logDecayUlps);
      // The recurrence alone, from the reference's own float32 inputs (its normalized q and k, v, beta and g).
      using qNorm = device("delta", at("q_norm")), kNorm = device("delta", at("k_norm")), betaRef = device("delta", at("beta")), gRef = device("delta", at("g"));
      using qWide = qNorm.astype(Dtype.float32), kWide = kNorm.astype(Dtype.float32), vWide = v.astype(Dtype.float32), betaWide = betaRef.astype(Dtype.float32);
      using qScaled = ops.mulScalar(qWide, scale);
      using decay = ops.exp(gRef);
      using y32 = gatedDeltaFloat32(qScaled, kWide, vWide, decay, betaWide);
      const recurrence = compare(values(y32), host("delta", at("out_f32")), valueDim);
      recordDelta(`${tag} recurrence from identical float32 inputs`, recurrence, `relative <= ${DELTA.recurrenceRelative}`, recurrence.relative <= DELTA.recurrenceRelative);
      using y16 = y32.astype(Dtype.bfloat16);
      console.log(`  ${tag} recurrence outputs stored in bf16: ${format(ulpDistance(values(y16), host("delta", at("out")), ulpBf16))}`);
      // The whole rule from the bf16 inputs.
      using out = rule.forward(q, k, v, a, b);
      const whole = compare(values(out), host("delta", at("out")), valueDim);
      recordDelta(`${tag} delta rule (bf16)`, whole, `relative <= ${DELTA.rule.relative}, every row's cosine >= ${DELTA.rule.minCosine}`,
        whole.relative <= DELTA.rule.relative && whole.minCosine >= DELTA.rule.minCosine);
      console.log(`  ${tag} delta rule: ${format(ulpDistance(values(out), host("delta", at("out")), ulpBf16))}`);
    }
    // The gated norm alone, on the reference's seeded bf16 values and gates with layer 0's weight.
    const normMeta = JSON.parse(readFileSync(join(captures, "gated-norm.json"), "utf8")) as { eps: number; lengths: number[] };
    using normWeight = device("gated-norm", "weight");
    const gatedNorm = new MossTextGatedNorm(normWeight, normMeta.eps);
    for (const length of normMeta.lengths) {
      using hidden = device("gated-norm", `L${length}.hidden`), gate = device("gated-norm", `L${length}.gate`);
      using ours = gatedNorm.forward(hidden, gate);
      const measured = ulpDistance(values(ours), host("gated-norm", `L${length}.out`), ulpBf16);
      recordDelta(`L=${length} gated norm (bf16)`, measured, `within ${DELTA.gatedNormUlps} bf16 ulp`, measured.maxUlps <= DELTA.gatedNormUlps);
    }
    // Real layers: each linear attention on the hidden states it received for the 23- and 203-token prompts.
    const textDir = join(snapshot, "text_encoder"), config = await loadModelConfig(textDir), weights = await Weights.open(textDir);
    try {
      for (const layer of meta.layers) {
        const p = `language_model.layers.${layer}.linear_attn`, linear = (name: string) => bindMossLinear(weights, config, `${p}.${name}`);
        const mixer = new MossTextDeltaMixer(linear("in_proj_qkv"), linear("in_proj_z"), linear("in_proj_b"), linear("in_proj_a"), linear("out_proj"),
          weights.tensor(`${p}.conv1d.weight`), new MossTextDeltaRecurrence(new MossTextLogDecay(weights.tensor(`${p}.A_log`), weights.tensor(`${p}.dt_bias`)), keyDim),
          new MossTextGatedNorm(weights.tensor(`${p}.norm.weight`), config.text.rmsNormEps), { keyHeads, valueHeads, keyDim, valueDim });
        try {
          for (const prompt of Object.keys(meta.tokens)) {
            using flat = device("delta", `${prompt}.layer${layer}.input`);
            using input = ops.reshape(flat, [1, ...flat.shape]);
            using output = mixer.forward(input);
            const stats = compare(values(output), host("delta", `${prompt}.layer${layer}.output`), flat.shape.at(-1)!);
            recordDelta(`layer ${layer} linear attention, ${meta.tokens[prompt]}-token prompt`, stats,
              `relative <= ${DELTA.mixer.relative}, every token's cosine >= ${DELTA.mixer.minCosine}`,
              stats.relative <= DELTA.mixer.relative && stats.minCosine >= DELTA.mixer.minCosine);
          }
        } finally { mixer.dispose(); }
      }
    } finally {
      weights.dispose();
      ffi.clearCache();
    }
    completed.add("linear attention");
    assertRecorded(from);
  }, 900_000);

  test("the DiT's stages agree from identical inputs (original criteria; the last block's text rows adjudicated)", async () => {
    expect(inputsVerified).toBe(true);
    const from = checks.length;
    ffi.resetPeakMemory();
    const dit = await MossImageTransformer.open(join(snapshot, "transformer"), transformerConfig());
    const spreadFile = existsSync(join(captures, "dit-mps.safetensors")) ? "dit-mps" : null;
    const spread = (name: string, width: number, from = 0, to?: number) =>
      spreadFile ? compare(host(spreadFile, name), host("dit", name), width, from, to) : undefined;
    const spreadOf = (stats: Stats | undefined) => stats ? { referenceSpread: stats } : {};
    try {
      const timesteps = host("schedule-8", "timesteps");
      using latents = device("noise", "latents");
      using flat = device("encode", "positive_embeds");
      using context = ops.reshape(flat, [1, ...flat.shape]);
      const height = latents.shape[2]!, width = latents.shape[3]!, tokens = height * width;
      for (const step of [0, 4]) {
        const tag = `t${step}`, timestep = timesteps[step]!;
        using time = dit.timestepEmbedder.forward(timestep);
        record(`${tag} time embedding`, compare(values(time), host("dit", `${tag}.time_embedding`), 3072), ORIGINAL.hidden);
        using modulation = dit.modulation.block.forward(time);
        record(`${tag} block modulation`, compare(values(modulation), host("dit", `${tag}.modulation`), 18432), ORIGINAL.hidden);
        using image = dit.latentEmbedder.forward(latents);
        record(`${tag} latent embedding`, compare(values(image), host("dit", `${tag}.video_embedded`), 3072), ORIGINAL.hidden);
        const layout = dit.rope.layout(height, width, context.shape[1]!);
        let text = dit.textProjection.forward(context);
        for (const textBlock of dit.textBlocks) { using previous = text; text = textBlock.forward(previous, layout.text); }
        record(`${tag} refined text`, compare(values(text), host("dit", `${tag}.text_embedded`), 3072), ORIGINAL.hidden);
        using mod = dit.modulation.forward(time);
        let x = dit.sequence.join(image, text);
        text.dispose();
        for (let i = 0; i < dit.blocks.length; i++) {
          using previous = x;
          x = dit.blocks[i]!.forward(previous, layout.joint, mod.block);
          const name = `${tag}.block${i}`;
          if ([0, 21, 22].includes(i)) {
            const stats = compare(values(x), host("dit", name), 3072);
            record(`${tag} block ${i}`, stats, ORIGINAL.hidden, {
              investigative: { criterion: "relative and mean cosine; worst token beside the reference's spread",
                pass: stats.relative <= ORIGINAL.hidden.relative && stats.meanCosine >= ORIGINAL.hidden.meanCosine },
              ...spreadOf(spread(name, 3072)),
            });
          }
          if (i === dit.blocks.length - 1) {
            const ours = values(x), reference = host("dit", name);
            record(`${tag} block ${i} all rows`, compare(ours, reference, 3072), ORIGINAL.hidden, {
              adjudicated: { criterion: "text rows reported, image rows held (review)", pass: true },
              ...spreadOf(spread(name, 3072)),
            });
            record(`${tag} block ${i} image rows`, compare(ours, reference, 3072, 0, tokens), ORIGINAL.hidden,
              spreadOf(spread(name, 3072, 0, tokens)));
          }
        }
        x.dispose();
        using velocity = dit.velocity(latents, timestep, context);
        record(`${tag} velocity`, compare(values(velocity), host("dit", `${tag}.velocity`), tokens), ORIGINAL.hidden,
          spreadOf(spread(`${tag}.velocity`, tokens)));
        using skipped = dit.velocity(latents, timestep, context, new Set([22]));
        record(`${tag} velocity, block 22 skipped`, compare(values(skipped), host("dit", `${tag}_skip22.velocity`), tokens), ORIGINAL.hidden,
          spreadOf(spread(`${tag}_skip22.velocity`, tokens)));
      }
    } finally {
      dit.dispose();
      ffi.clearCache();
    }
    console.log(`DiT peak ${(ffi.peakMemory() / 2 ** 30).toFixed(2)} GiB`);
    completed.add("DiT stages");
    assertRecorded(from);
  }, 1_200_000);

  test("the 8-step guided trajectory agrees from identical noise and conditioning (original criteria)", async () => {
    expect(inputsVerified).toBe(true);
    const from = checks.length;
    const dit = await MossImageTransformer.open(join(snapshot, "transformer"), transformerConfig());
    try {
      using noise = device("noise", "latents");
      using positiveFlat = device("encode", "positive_embeds"), negativeFlat = device("encode", "negative_embeds");
      using positive = ops.reshape(positiveFlat, [1, ...positiveFlat.shape]), negative = ops.reshape(negativeFlat, [1, ...negativeFlat.shape]);
      const tokens = noise.shape[2]! * noise.shape[3]!;
      const step = guidanceFor(dit, { positive, negative, dispose() {} }, { guidance: 3, uncondSkipLayers: [22] });
      const calibrated = existsSync(join(captures, "sample-8-mps.safetensors"));
      const trajectoryStep = (index: number, ours: Float32Array) => {
        const name = `step${index}`, stats = compare(ours, host("sample-8", name), tokens);
        const spread = calibrated ? compare(host("sample-8-mps", name), host("sample-8", name), tokens) : undefined;
        record(`trajectory step ${index}`, stats, ORIGINAL.trajectory, spread ? {
          investigative: { criterion: `relative <= ${SPREAD_FACTOR}x the reference's MPS-vs-CPU relative (${(SPREAD_FACTOR * spread.relative).toExponential(3)})`,
            pass: stats.relative <= SPREAD_FACTOR * spread.relative },
          referenceSpread: spread,
        } : {});
      };
      const seen: number[] = [];
      let calls = 0;
      // Each step's input is the previous step's result: compare it with the reference's capture of that step.
      const observed = { velocity: (x: Array, t: number) => {
        if (calls > 0) trajectoryStep(calls - 1, values(x));
        calls++;
        return step.velocity(x, t);
      } };
      const result = await denoiseLatents(observed, schedule(), noise, { steps: 8, onStep: done => seen.push(done) });
      using final = result.latents;
      expect(result.steps).toBe(8);
      expect(seen).toEqual([1, 2, 3, 4, 5, 6, 7, 8]);
      trajectoryStep(7, values(final));
    } finally {
      dit.dispose();
      ffi.clearCache();
    }
    completed.add("trajectory");
    assertRecorded(from);
  }, 1_800_000);
});
