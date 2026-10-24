// One unpadded positive encode against unchanged MFLUX Qwen35TextModel.
// The Base/SFT snapshots have identical text_encoder and tokenizer bytes; this
// qualifies their shared dense text tower on one 23-token prompt, not a pipeline.
// Existing PyTorch bounds and unresolved failures remain independent gates.
//
// BOTH MLX_BUN_MOSS_CONDITIONER_SNAPSHOT and MLX_BUN_MOSS_CONDITIONER_ORACLE
// opt in. The first is a snapshot root; the second contains the frozen r20
// files named in CAPTURE_PINS. Paths may be relocated; embedded absolute paths
// are provenance only. No Python runtime, reference forwards or downloads.
// MLX_BUN_MOSS_CONDITIONER_RESULTS optionally names the external JSON report.
// Verify all pins before importing MLX. On an idle GPU, run exactly one fresh
// uninstrumented encode and one fresh observed encode of the production graph.
import { describe, expect, test } from "bun:test";
import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { arch, platform, release, tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { MossTextDeltaMixer, MossTextMlp } from "../../src/models/moss-image/text-layers";
import { compare, unpinnedEntries, verifyPinned, type Stats, type Verification } from "./moss-image-oracle-checks";
import { fileSha256, optInAll, sha256 } from "./real-weight-inputs";

const OPT_IN = ["MLX_BUN_MOSS_CONDITIONER_SNAPSHOT", "MLX_BUN_MOSS_CONDITIONER_ORACLE"] as const;
const REFERENCE = {
  mfluxRevision: "a3b21fcaa88726b2267bd42bfc2e2d722f7d5a47", mfluxVersion: "0.23.0",
  mlxVersion: "0.32.2", mlxMetalVersion: "0.32.2", pythonVersion: "3.12.13",
  device: "Apple M4 Pro", architecture: "applegpu_g16s",
  baseRevision: "85975793d8b3d432f1b6e27f352abaa4c2a4c0d3", sftRevision: "f972bd4b4b9e3852133cc5da954d87bc32cd8fb9",
  producerSha256: "1b4a0ea88d3676b1febe1356a6eb94395fdb730efa0c2744900971974f320996",
  tokenizerProducerSha256: "32a3da3f0fe1c024a948f89add68b5ffcfb27fe27795745220484633f4b53884",
  originalInputFileSha256: "8d4fb0dda2c92b40b09ca1601fd385f30550a49eb49942235bbeb6ff58124122",
  native: {
    "libmlx.dylib": "d24c7a9b9d55a76bfd3bbcd1d042251a185cbadcb6340c3244a6ffa3dcb7c7e8",
    "mlx.metallib": "dc59d1cceb1a5c7e578232e6e41e28e2c73c9463ac6dbc3886c3ee17ffc270ed",
  },
} as const;
const SNAPSHOT_PINS = {
  "text_encoder/config.json": "b31ee18a242bcfcccbe740f825f6b1d3ae231b0655eeecb5de3e98d504b7d68c",
  "text_encoder/model.safetensors.index.json": "0af6fa3fa36ba8dcbb6b7ad0325a36c5b1b69862a9a1f1486b1b80385bd8f5ee",
  "text_encoder/model-00001-of-00004.safetensors": "abfaa3d3a8612508c85ee8f6da9c734b862f10298b903765c4ad384177c32b0b",
  "text_encoder/model-00002-of-00004.safetensors": "9112637fa6bf4d07bafd6ae268852b18d3d0c1242f4ee901c5579006e5bd4894",
  "text_encoder/model-00003-of-00004.safetensors": "956f1ef51d0cfe610b0d22987c0b7821c36e3ce228abceccef523518bcf079dc",
  "text_encoder/model-00004-of-00004.safetensors": "9e21d20e8adde88c3e0b65d4a0d251f143d98ee9d52db36b4348361091e4e208",
  "tokenizer/chat_template.jinja": "a4aee8afcf2e0711942cf848899be66016f8d14a889ff9ede07bca099c28f715",
  "tokenizer/tokenizer.json": "06b9509352d2af50381ab2247e083b80d32d5c0aba91c272ca9ff729b6a0e523",
  "tokenizer/tokenizer_config.json": "bee8eba30f0eb4af73c0fe2cd06d0f89b657d7819941c438157ec42f7c80ea87",
} as const;
const CAPTURE_PINS = {
  "manifest.json": "8675793b2b38e05f2e7334b593f66e1c0c44cef6662f1a50cdf36abb7e4494d2",
  "report.json": "b180f1c5852c6eb6917c81e185f4533238156008641ed91cf07128de56aad143",
  "mflux-control.json": "5740e4363ecb3e931d10ad4ae5fa4091d3d25f71e6a0f9c10aad2baa064813f9",
  "mflux-traced.json": "57409912752be3063ede5198ca8b5f5df69f437bafa1f38ae29ab1a82a813111",
  "mflux-control.safetensors": "479d15e4701ad54db43405f0e935cf21a23087466653bdaa0f98b24009c85575",
  "mflux-traced.safetensors": "ac496546a16c368b2bc6211dc4eb6c05c097f5fde8c1d49cc3d4b74c5257ac3b",
  "tokens.safetensors": "5c48781bdc1bb6c5d7b25506c46f8cfeb702f692a3b4a0f5797a7b834ad44d71",
  "tokenizer.json": "407ed854eb9d4bd766fbf3c093905712255d83afed7e7d88589bf883e4a877b2",
} as const;
const INPUT = {
  prompt: "A red fox sitting in fresh snow, morning light, photograph.",
  ids: [248045, 846, 198, 32, 2438, 37550, 11362, 303, 7478, 11456, 11, 6353, 3000, 11, 9994, 13, 248046, 198, 248045, 74455, 198, 248068, 198],
  canonicalInt32Sha256: "7de2d2794acb084c9d88b4e65e1d107521219bfac1d73daa376468e41f840ae1",
} as const;
const STAGES = ["embedding", "layer0.norm1", "layer0.qkv", "layer0.z", "layer0.b", "layer0.a", "layer0.core", "layer0.gated",
  "layer0.mixed", "layer0.after_mixer", "layer0.norm2", "layer0.mlp.gate", "layer0.mlp.up", "layer0.mlp.hidden", "layer0.mlp.output",
  ...Array.from({ length: 32 }, (_, i) => `layer.${i}.output`), "conditioning"];

interface HostTensor { dtype: string; shape: number[]; values: Float32Array }
interface Measurement { stage: string; pass: boolean; measured?: Stats; error?: string; actualSha256?: string; expectedSha256?: string }

/** BF16 word widening preserves signed zero and NaN payloads. */
function widen(bytes: Uint8Array, dtype: string): Float32Array {
  if (dtype === "F32") return new Float32Array(bytes.slice().buffer);
  if (dtype !== "BF16") throw new Error(`unsupported floating capture dtype ${dtype}`);
  const data = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength), words = new Uint32Array(bytes.byteLength / 2);
  for (let i = 0; i < words.length; i++) words[i] = data.getUint16(2 * i, true) << 16;
  return new Float32Array(words.buffer);
}

// These small captures are read on the host. Importing this test or validating
// its reference control needs no native array or mmap binding.
function readCapture(path: string) {
  const bytes = readFileSync(path), offset = 8 + Number(bytes.readBigUInt64LE(0));
  if (!Number.isSafeInteger(offset) || offset < 8 || offset > bytes.length) throw new Error(`invalid safetensors header: ${path}`);
  const header = JSON.parse(bytes.subarray(8, offset).toString()) as Record<string, { dtype: string; shape: number[]; data_offsets: [number, number] }>;
  const names = Object.keys(header).filter(name => name !== "__metadata__");
  const raw = (name: string) => {
    const meta = header[name];
    if (!meta) throw new Error(`missing ${name} in ${path}`);
    const [start, end] = meta.data_offsets, size = { BF16: 2, F32: 4, I64: 8 }[meta.dtype];
    if (!size || start < 0 || end < start || offset + end > bytes.length || end - start !== meta.shape.reduce((a, b) => a * b, 1) * size)
      throw new Error(`invalid tensor ${name} in ${path}`);
    return { ...meta, bytes: new Uint8Array(bytes.subarray(offset + start, offset + end)) };
  };
  return { names, raw, tensor(name: string): HostTensor { const t = raw(name); return { dtype: t.dtype, shape: t.shape, values: widen(t.bytes, t.dtype) }; } };
}

function measure(stage: string, actual: HostTensor | undefined, expected: HostTensor | undefined): Measurement {
  const hash = (t: HostTensor) => sha256(new Uint8Array(t.values.buffer, t.values.byteOffset, t.values.byteLength));
  const result: Measurement = { stage, pass: false, actualSha256: actual && hash(actual), expectedSha256: expected && hash(expected) };
  if (!actual || !expected) return { ...result, error: "missing observation or reference" };
  try {
    result.measured = compare(actual.values, expected.values, expected.shape.at(-1)!);
    if (actual.dtype !== expected.dtype || actual.shape.join() !== expected.shape.join()) result.error = "dtype or shape mismatch";
    result.pass = !result.error && result.measured.elements === expected.values.length && result.measured.bitMismatches === 0 && result.measured.nonFinite === 0;
  } catch (error) { result.error = String(error); }
  return result;
}

describe("MOSS shared Base/SFT conditioner against pinned MFLUX", () => {
  if (OPT_IN.every(name => process.env[name] === undefined)) { test.skip(`needs ${OPT_IN.join(" and ")}`, () => {}); return; }
  test("48 stages, final conditioning and both observer controls are exact and finite", async () => {
    const resultsPath = process.env.MLX_BUN_MOSS_CONDITIONER_RESULTS ?? join(tmpdir(), "moss-image-mflux-conditioner-results.json");
    const root = resolve(import.meta.dir, "../../../.."), checks: Measurement[] = [], issues: string[] = [];
    const expected = new Map<string, HostTensor>(), actual = new Map<string, HostTensor>();
    let candidateControl: HostTensor | undefined;
    const run: {
      status: "incomplete" | "passed" | "failed"; error?: string; reference: typeof REFERENCE; scope: string; selectedStages: string[];
      implementation?: { commit: string; modified: string[]; bun: string; host: string; testSha256: string; helperSha256: string };
      runtime?: { mlxVersion: string; architecture: string; native: Record<string, string | null> };
      inputs: { verified: boolean; snapshot?: Verification; captures?: Verification; unpinned: string[]; tokenIdsExact: boolean };
      encodes: { control: number; traced: number; controlCompleted: boolean; tracedCompleted: boolean };
      hookOrder: string[]; checks: Measurement[]; issues: string[]; failures: string[];
    } = { status: "incomplete", reference: REFERENCE, scope: "Shared Base/SFT dense text tower, one 23-token positive prompt, no quantization or image generation",
      selectedStages: STAGES, inputs: { verified: false, unpinned: [], tokenIdsExact: false },
      encodes: { control: 0, traced: 0, controlCompleted: false, tracedCompleted: false }, hookOrder: [], checks, issues, failures: [] };
    const save = () => writeFileSync(resultsPath, JSON.stringify(run,
      (_key, value) => typeof value === "number" && !Number.isFinite(value) ? String(value) : value, 2) + "\n");
    save();
    try {
      const opted = optInAll(process.env, OPT_IN, "MOSS exact conditioner comparison")!;
      const snapshot = opted.MLX_BUN_MOSS_CONDITIONER_SNAPSHOT, oracle = opted.MLX_BUN_MOSS_CONDITIONER_ORACLE;
      const git = (...args: string[]) => execFileSync("git", args, { cwd: root, encoding: "utf8" }).trim();
      run.implementation = { commit: git("rev-parse", "HEAD"), modified: git("status", "--porcelain").split("\n").filter(Boolean),
        bun: Bun.version, host: `${platform()} ${release()} ${arch()}`, testSha256: await fileSha256(import.meta.path),
        helperSha256: await fileSha256(join(import.meta.dir, "moss-image-oracle-checks.ts")) };
      run.inputs.snapshot = await verifyPinned(snapshot, SNAPSHOT_PINS);
      run.inputs.captures = await verifyPinned(oracle, CAPTURE_PINS);
      run.inputs.unpinned = unpinnedEntries(snapshot, SNAPSHOT_PINS);
      const problems = [...run.inputs.snapshot.mismatched, ...run.inputs.captures.mismatched, ...run.inputs.unpinned];
      if (problems.length) throw new Error(`input verification failed:\n${problems.join("\n")}`);
      const manifest = JSON.parse(readFileSync(join(oracle, "manifest.json"), "utf8"));
      const referenceReport = JSON.parse(readFileSync(join(oracle, "report.json"), "utf8"));
      if (manifest.source.mflux !== REFERENCE.mfluxRevision || JSON.stringify(referenceReport.order) !== JSON.stringify(STAGES)
        || manifest.prompt !== INPUT.prompt || JSON.stringify(manifest.ids) !== JSON.stringify(INPUT.ids)) throw new Error("reference provenance or selected stages differ");
      for (const mode of ["control", "traced"] as const) {
        const info = JSON.parse(readFileSync(join(oracle, `mflux-${mode}.json`), "utf8"));
        if (info.status !== "complete" || info.full_encodes !== 1 || info.mode !== mode || info.manifest_sha256 !== CAPTURE_PINS["manifest.json"]
          || info.output_sha256 !== CAPTURE_PINS[`mflux-${mode}.safetensors`]) throw new Error(`incomplete MFLUX ${mode}`);
      }
      const tokens = readCapture(join(oracle, "tokens.safetensors")).raw("input_ids");
      if (tokens.dtype !== "I64" || tokens.shape.join() !== "1,23") throw new Error("unexpected MFLUX token layout");
      const tokenBytes = new DataView(tokens.bytes.buffer, tokens.bytes.byteOffset, tokens.bytes.byteLength);
      const ids = Array.from({ length: 23 }, (_, i) => Number(tokenBytes.getBigInt64(i * 8, true)));
      const canonical = new Uint8Array(23 * 4), canonicalView = new DataView(canonical.buffer);
      ids.forEach((id, i) => canonicalView.setInt32(i * 4, id, true));
      if (JSON.stringify(ids) !== JSON.stringify(INPUT.ids) || sha256(canonical) !== INPUT.canonicalInt32Sha256) throw new Error("token input differs");
      const control = readCapture(join(oracle, "mflux-control.safetensors")), traced = readCapture(join(oracle, "mflux-traced.safetensors"));
      if (control.names.join() !== "conditioning" || traced.names.toSorted().join() !== STAGES.toSorted().join()) throw new Error("unexpected capture set");
      for (const name of STAGES) expected.set(name, traced.tensor(name));
      checks.push(measure("mflux.observer", expected.get("conditioning"), control.tensor("conditioning")));
      if (!checks.at(-1)!.pass) throw new Error("MFLUX observer control failed");
      run.inputs.verified = true; save();

      const ffi = await import("@mlx-bun/mlx/ffi"), { Dtype } = ffi;
      const ops = await import("@mlx-bun/mlx/ops");
      const { MossImageConditioner } = await import("../../src/models/moss-image/text-encoder");
      const native: Record<string, string | null> = {};
      for (const file of [ffi.LIBMLXC_PATH, join(dirname(ffi.LIBMLXC_PATH), "libmlx.dylib"), join(dirname(ffi.LIBMLXC_PATH), "mlx.metallib")])
        native[file] = existsSync(file) ? await fileSha256(file) : null;
      run.runtime = { mlxVersion: ffi.MLX_VERSION, architecture: ffi.deviceArchitecture(), native };
      if (ffi.MLX_VERSION !== REFERENCE.mlxVersion) throw new Error(`MLX version ${ffi.MLX_VERSION}, expected ${REFERENCE.mlxVersion}`);
      const copy = (array: MlxArray): HostTensor => {
        using contiguous = ops.contiguous(array); contiguous.eval();
        const dtype = array.dtype === Dtype.bfloat16 ? "BF16" : array.dtype === Dtype.float32 ? "F32" : String(array.dtype);
        return { dtype, shape: array.shape, values: widen(contiguous.rawBytes(), dtype) };
      };
      for (const mode of ["control", "traced"] as const) {
        const model = await MossImageConditioner.open(join(snapshot, "text_encoder"), join(snapshot, "tokenizer"));
        const restore: (() => void)[] = [];
        const patch = <T extends object, K extends keyof T>(object: T, key: K, replacement: T[K]) => {
          const descriptor = Object.getOwnPropertyDescriptor(object, key);
          restore.push(() => { if (descriptor) Object.defineProperty(object, key, descriptor); else Reflect.deleteProperty(object, key); });
          object[key] = replacement;
        };
        const observe = (name: string, array: MlxArray) => {
          run.hookOrder.push(name);
          if (actual.has(name)) { issues.push(`duplicate observation: ${name}`); return; }
          try { actual.set(name, copy(array)); } catch (error) { issues.push(`observation ${name}: ${String(error)}`); }
        };
        const wrap = <Args extends [MlxArray, ...unknown[]]>(object: { forward(...args: Args): MlxArray }, output: string, input?: string) => {
          const original = object.forward;
          patch(object, "forward", function (this: typeof object, ...args: Args) {
            if (input) observe(input, args[0]);
            const result = original.apply(this, args); observe(output, result); return result;
          });
        };
        try {
          if (JSON.stringify(model.tokens(INPUT.prompt)) !== JSON.stringify(INPUT.ids)) throw new Error(`Bun ${mode} token IDs differ`);
          run.inputs.tokenIdsExact = true;
          if (model.layers.length !== 32) throw new Error("unexpected layer count");
          if (mode === "traced") {
            const first = model.layers[0]!;
            if (!("mixer" in first)) throw new Error("expected a DeltaNet first layer");
            const delta = first.mixer as MossTextDeltaMixer, mlp = first.mlp as MossTextMlp;
            wrap(model.embedding, "embedding"); wrap(first.inputNorm, "layer0.norm1");
            wrap(delta.qkv, "layer0.qkv"); wrap(delta.z, "layer0.z"); wrap(delta.b, "layer0.b"); wrap(delta.a, "layer0.a");
            wrap(delta.norm, "layer0.gated", "layer0.core"); wrap(delta, "layer0.mixed");
            wrap(first.postNorm, "layer0.norm2", "layer0.after_mixer");
            wrap(mlp.gate, "layer0.mlp.gate"); wrap(mlp.up, "layer0.mlp.up"); wrap(mlp.down, "layer0.mlp.output", "layer0.mlp.hidden");
            model.layers.forEach((layer, i) => wrap(layer, `layer.${i}.output`));
          }
          run.encodes[mode]++; save();
          using output = model.encode(INPUT.prompt);
          if (mode === "control") { candidateControl = copy(output); run.encodes.controlCompleted = true; }
          else { observe("conditioning", output); run.encodes.tracedCompleted = true; }
        } finally {
          try { for (const undo of restore.reverse()) undo(); }
          finally { try { model.dispose(); } finally { ffi.clearCache(); } }
        }
      }
      if (run.hookOrder.length !== 48 || actual.size !== 48) issues.push(`observed ${run.hookOrder.length} calls / ${actual.size} tensors, expected 48`);
      for (const name of actual.keys()) if (!STAGES.includes(name)) issues.push(`unexpected observation: ${name}`);
    } catch (error) { run.error = error instanceof Error ? error.stack ?? error.message : String(error); }
    finally {
      checks.push(measure("candidate.control", candidateControl, expected.get("conditioning")));
      checks.push(measure("candidate.observer", actual.get("conditioning"), candidateControl));
      for (const stage of STAGES) checks.push(measure(stage, actual.get(stage), expected.get(stage)));
      const complete = run.inputs.verified && run.inputs.tokenIdsExact && run.encodes.controlCompleted && run.encodes.tracedCompleted
        && STAGES.every(stage => actual.has(stage)) && !run.error;
      run.failures = [...checks.filter(c => !c.pass).map(c => c.stage), ...issues];
      if (run.error) run.failures.unshift(run.error.split("\n")[0]!);
      if (!complete) run.failures.push("execution incomplete");
      run.status = complete ? run.failures.length ? "failed" : "passed" : "incomplete";
      save();
      const stages = checks.filter(c => STAGES.includes(c.stage));
      console.log(`MFLUX conditioner: ${run.status}; ${stages.filter(c => c.pass).length}/48 stages; `
        + `${stages.reduce((n, c) => n + (c.measured?.bitMismatches ?? 0), 0)}/${stages.reduce((n, c) => n + (c.measured?.elements ?? 0), 0)} words differ; ${resultsPath}`);
    }
    expect(run.failures).toEqual([]);
  }, 300_000);
});
