// Independent MFLUX public-pipeline cases. The default captured-256-8 case
// preserves its frozen inputs, outputs and all 46 exact/control checks per model.
// MLX_BUN_MOSS_PIPELINE_CASE=native-1024-50 selects the separately declared case;
// it cannot load a model until its independent output-lock pin is embedded.
// Its public generateImage call omits options.latents: reference noise is only
// an expected output, never an input supplied to the candidate.
//
// Both cases need MLX_BUN_MOSS_PIPELINE_BASE_SNAPSHOT, _SFT_SNAPSHOT and _ORACLE
// (each with the MLX_BUN_MOSS_PIPELINE prefix). No options set visibly skips;
// partial opt-in or an unknown case fails before native imports. _RESULTS names
// an external results directory. All fixture paths may be relocated.
//
// Each engine owns both tokenization/conditioning branches. Observers call the
// original methods once, retain at most one GPU step, and restore in finally.
// All selected float32 words (BF16 widened exactly), token IDs, pixels and
// observer controls must match exactly and be finite. No teacher forcing,
// Python, downloads, binding overrides or kernel-selection flags run here.
import { describe, expect, test } from "bun:test";
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { arch, platform, release, tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { TextToImagePipeline } from "../../src/contracts/mlx/image-generation";
import type { MossImageConditioner } from "../../src/models/moss-image/text-encoder";
import { compare, compareSpatial, unpinnedEntries, verifyPinned, type Stats } from "./moss-image-oracle-checks";
import { fileSha256, optInAll, sha256 } from "./real-weight-inputs";

const OPT_IN = ["MLX_BUN_MOSS_PIPELINE_BASE_SNAPSHOT", "MLX_BUN_MOSS_PIPELINE_SFT_SNAPSHOT", "MLX_BUN_MOSS_PIPELINE_ORACLE"] as const;
const CASE_ENV = "MLX_BUN_MOSS_PIPELINE_CASE";
const CASES = Object.freeze({
  "captured-256-8": Object.freeze({
    caseSha256: "648fa31099379169ed6abbef060261eb78938a323a1c7e1052693d53122fb276", oracleLockSha256: "33cb5ae0297db091e6eac5008d71909fb273a74472019ac0ef899da2dea6f998" as string | null,
    noise: "captured", positiveTokens: 23 as number | null, timeoutMs: 1320000,
    request: Object.freeze({"prompt":"A red fox sitting in fresh snow, morning light, photograph.","negativePrompt":"","width":256,"height":256,"steps":8,"guidance":3,"seed":42,"uncondSkipLayers":Object.freeze([22])}),
  }),
  "native-1024-50": Object.freeze({
    caseSha256: "7d00407abf707efc8d925ed2df9f6a4404848c22861aabc4005fde1979d6dd7c", oracleLockSha256: "e06e4a7181c34c7d6e0a58735e38a65b469b9a2d37299c61e388f3b9471676ad" as string | null,
    noise: "native", positiveTokens: null as number | null, timeoutMs: 3720000,
    request: Object.freeze({"prompt":"A brass telescope beside a blue velvet armchair in a sunlit observatory, a folded star chart on an oak desk, detailed photograph.","negativePrompt":"","width":1024,"height":1024,"steps":50,"guidance":3,"seed":42,"uncondSkipLayers":Object.freeze([22])}),
  }),
});
const caseName = process.env[CASE_ENV] ?? "captured-256-8";
const DECLARED = CASES[caseName as keyof typeof CASES] ?? CASES["captured-256-8"];
const CASE_SHA256 = DECLARED.caseSha256, ORACLE_LOCK_SHA256 = DECLARED.oracleLockSha256;
const REQUEST = DECLARED.request;
let positiveTokens = DECLARED.positiveTokens ?? 0;
const MFLUX_REVISION = "a3b21fcaa88726b2267bd42bfc2e2d722f7d5a47";
const MLX_VERSION = "0.32.2";
const STAGES = ["input.noise", "tokens.positive", "tokens.negative", "conditioning.positive", "conditioning.negative", "schedule.sigmas", "schedule.timesteps"];
for (let step = 0; step < REQUEST.steps; step++) for (const output of ["conditional", "unconditional", "guided", "latents"]) STAGES.push(`step.${step}.${output}`);
STAGES.push("final.latents", "final.raw", "final.pixels");
const CONTROLS = ["final.latents", "final.pixels"];

interface Tensor { dtype: "F32" | "I32" | "U8"; shape: number[]; bytes: Uint8Array }
interface Measurement { stage: string; pass: boolean; actualSha256?: string; expectedSha256?: string; error?: string;
  measured?: Stats | { elements: number; byteMismatches: number; nonFinite: number } }
interface Fixture {
  schema: number; reference: { revision: string; mlx: string; mlxMetal: string; mflux: string };
  models: Record<"base" | "sft", { revision: string; snapshot: Record<string, string> }>;
  noise: { mode?: "native_seeded"; file?: string; sha256?: string; payloadSha256?: string };
  tokenizer: Record<"positive" | "negative", { values: number[]; sha256: string } | null>;
  selected: string[]; budget: { memoryLimitBytes: number; secondsPerPipeline: number };
}

/** Host parsing only, before importing an MLX array or loading any weights. */
function readCapture(path: string): Map<string, Tensor> {
  const bytes = readFileSync(path);
  if (bytes.length < 8) throw new Error(`short capture ${path}`);
  const offset = 8 + Number(bytes.readBigUInt64LE(0));
  if (!Number.isSafeInteger(offset) || offset < 8 || offset > bytes.length) throw new Error(`invalid header ${path}`);
  const header = JSON.parse(bytes.subarray(8, offset).toString()) as Record<string, { dtype: Tensor["dtype"]; shape: number[]; data_offsets: [number, number] }>;
  const result = new Map<string, Tensor>(), ranges: [number, number][] = [];
  for (const [name, info] of Object.entries(header)) {
    if (name === "__metadata__") continue;
    const size = { F32: 4, I32: 4, U8: 1 }[info.dtype], [begin, end] = info.data_offsets;
    if (!size || !Array.isArray(info.shape) || !info.shape.every(n => Number.isSafeInteger(n) && n > 0)
      || !Number.isSafeInteger(begin) || !Number.isSafeInteger(end) || begin < 0 || end < begin || offset + end > bytes.length
      || end - begin !== size * info.shape.reduce((a, b) => a * b, 1)) throw new Error(`invalid tensor ${name}`);
    ranges.push([begin, end]);
    result.set(name, { dtype: info.dtype, shape: info.shape, bytes: new Uint8Array(bytes.subarray(offset + begin, offset + end)) });
  }
  ranges.sort((a, b) => a[0] - b[0]);
  let end = 0;
  for (const r of ranges) { if (r[0] !== end) throw new Error("noncontiguous capture payloads"); end = r[1]; }
  if (offset + end !== bytes.length) throw new Error("unaccounted capture bytes");
  return result;
}

function writeCapture(path: string, values: Map<string, Tensor>): void {
  const header: Record<string, { dtype: string; shape: number[]; data_offsets: [number, number] }> = {};
  let offset = 0;
  for (const [name, tensor] of values) {
    header[name] = { dtype: tensor.dtype, shape: tensor.shape, data_offsets: [offset, offset + tensor.bytes.length] };
    offset += tensor.bytes.length;
  }
  let text = JSON.stringify(header); text += " ".repeat((8 - Buffer.byteLength(text) % 8) % 8);
  const size = Buffer.alloc(8); size.writeBigUInt64LE(BigInt(Buffer.byteLength(text)));
  writeFileSync(path, Buffer.concat([size, Buffer.from(text), ...[...values.values()].map(t => Buffer.from(t.bytes))]));
}

/** BF16 to F32 by word placement, including negative zero and NaN payloads. */
function widen(bytes: Uint8Array, bf16: boolean): Uint8Array {
  if (!bf16) return bytes.slice();
  const source = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength), words = new Uint32Array(bytes.length / 2);
  for (let i = 0; i < words.length; i++) words[i] = source.getUint16(2 * i, true) << 16;
  return new Uint8Array(words.buffer);
}

function rawNchw(tensor: Tensor): Tensor {
  if (tensor.dtype !== "F32" || tensor.shape.join() !== [1, REQUEST.height, REQUEST.width, 3].join()) throw new Error("expected raw NHWC image");
  const input = new Uint32Array(tensor.bytes.buffer, tensor.bytes.byteOffset, tensor.bytes.length / 4), words = new Uint32Array(input.length);
  const positions = REQUEST.height * REQUEST.width;
  for (let p = 0; p < positions; p++) for (let c = 0; c < 3; c++) words[c * positions + p] = input[p * 3 + c]!;
  return { dtype: "F32", shape: [1, 3, REQUEST.height, REQUEST.width], bytes: new Uint8Array(words.buffer) };
}

function spec(stage: string): { dtype: Tensor["dtype"]; shape: number[] } {
  if (stage.startsWith("tokens.")) return { dtype: "I32", shape: [stage.endsWith("positive") ? positiveTokens : 10] };
  if (stage.startsWith("conditioning.")) return { dtype: "F32", shape: [1, stage.endsWith("positive") ? positiveTokens : 10, 4096] };
  if (stage === "schedule.sigmas") return { dtype: "F32", shape: [REQUEST.steps + 1] };
  if (stage === "schedule.timesteps") return { dtype: "F32", shape: [REQUEST.steps] };
  if (stage === "final.raw") return { dtype: "F32", shape: [1, 3, REQUEST.height, REQUEST.width] };
  if (stage === "final.pixels") return { dtype: "U8", shape: [1, REQUEST.height, REQUEST.width, 3] };
  return { dtype: "F32", shape: [1, 128, REQUEST.height / 16, REQUEST.width / 16] };
}

function measure(label: string, stage: string, actual: Tensor | undefined, expected: Tensor | undefined): Measurement {
  const result: Measurement = { stage: label, pass: false, actualSha256: actual && sha256(actual.bytes), expectedSha256: expected && sha256(expected.bytes) };
  if (!actual || !expected) return { ...result, error: "missing observation or reference" };
  try {
    const wanted = spec(stage);
    if (actual.dtype !== wanted.dtype || expected.dtype !== wanted.dtype || actual.shape.join() !== wanted.shape.join()
      || expected.shape.join() !== wanted.shape.join()) result.error = "shape or dtype mismatch";
    if (actual.dtype === "F32" && expected.dtype === "F32") {
      const a = new Float32Array(actual.bytes.slice().buffer), e = new Float32Array(expected.bytes.slice().buffer);
      const stats = wanted.shape.length === 4 ? compareSpatial(a, e, wanted.shape[1]!) : compare(a, e, wanted.shape.at(-1)!);
      result.measured = stats;
      result.pass = !result.error && stats.elements === wanted.shape.reduce((a, b) => a * b, 1) && stats.bitMismatches === 0 && stats.nonFinite === 0;
    } else {
      let byteMismatches = Math.abs(actual.bytes.length - expected.bytes.length);
      for (let i = 0; i < Math.min(actual.bytes.length, expected.bytes.length); i++) if (actual.bytes[i] !== expected.bytes[i]) byteMismatches++;
      result.measured = { elements: expected.shape.reduce((a, b) => a * b, 1), byteMismatches, nonFinite: 0 };
      result.pass = !result.error && byteMismatches === 0;
    }
  } catch (error) { result.error = String(error); }
  return result;
}

/** Save an object's original descriptor, including an inherited method. */
function patch(object: object, key: string, replacement: unknown, restore: (() => void)[]): void {
  const descriptor = Object.getOwnPropertyDescriptor(object, key);
  Object.defineProperty(object, key, { configurable: true, writable: true, value: replacement });
  restore.push(() => { if (descriptor) Object.defineProperty(object, key, descriptor); else Reflect.deleteProperty(object, key); });
}

describe("MOSS Base and SFT public pipeline against independent MFLUX", () => {
  if ([...OPT_IN, CASE_ENV].every(name => process.env[name] === undefined)) { test.skip(`needs ${OPT_IN.join(" and ")}`, () => {}); return; }
  for (const model of ["base", "sft"] as const) test(`${model}: ${STAGES.length} stages plus four observer controls, exact and finite`, async () => {
    const root = resolve(import.meta.dir, "../../../..");
    const output = process.env.MLX_BUN_MOSS_PIPELINE_RESULTS ?? join(tmpdir(), DECLARED.noise === "captured" ? "moss-image-mflux-pipeline-results" : `moss-image-mflux-pipeline-${caseName}-results`);
    mkdirSync(output, { recursive: true });
    const reportPath = join(output, `${model}-results.json`);
    const checks: Measurement[] = [], issues: string[] = [];
    const run: Record<string, unknown> = { status: "incomplete", caseName, model, request: REQUEST, selected: STAGES, caseSha256: CASE_SHA256,
      oracleLockSha256: ORACLE_LOCK_SHA256, reference: { revision: MFLUX_REVISION, mlx: MLX_VERSION }, checks, issues, pipelines: {} };
    const modes = run.pipelines as Record<string, Record<string, unknown>>;
    const captures = { control: new Map<string, Tensor>(), traced: new Map<string, Tensor>() };
    let expected = new Map<string, Tensor>(), referenceControl = new Map<string, Tensor>();
    const save = () => writeFileSync(reportPath, JSON.stringify(run,
      (_key, value) => typeof value === "number" && !Number.isFinite(value) ? String(value) : value, 2) + "\n");
    const git = (...args: string[]) => execFileSync("git", args, { cwd: root, encoding: "utf8" }).trim();
    const sourceHashes = async () => {
      const files = new Set(git("ls-files", "--cached", "--others", "--exclude-standard", "packages/inference/src", "packages/mlx/src", "packages/tokenizers/src").split("\n").filter(Boolean));
      const hashes: Record<string, string> = {};
      for (const relative of [...files].sort()) if (existsSync(join(root, relative))) hashes[relative] = await fileSha256(join(root, relative));
      return hashes;
    };
    save();
    try {
      const opted = optInAll(process.env, OPT_IN, "MOSS full pipeline comparison")!;
      if (!Object.hasOwn(CASES, caseName)) throw new Error(`unknown declared case ${caseName}`);
      if (!ORACLE_LOCK_SHA256) throw new Error(`${caseName}: independent output pin is not frozen; no model may load`);
      const oracle = opted.MLX_BUN_MOSS_PIPELINE_ORACLE;
      const snapshot = model === "base" ? opted.MLX_BUN_MOSS_PIPELINE_BASE_SNAPSHOT : opted.MLX_BUN_MOSS_PIPELINE_SFT_SNAPSHOT;
      const initialPins = await verifyPinned(oracle, { "case.json": CASE_SHA256, "oracle-lock.json": ORACLE_LOCK_SHA256 });
      run.inputVerification = initialPins;
      if (initialPins.mismatched.length) throw new Error(initialPins.mismatched.join("\n"));
      const fixture = JSON.parse(readFileSync(join(oracle, "case.json"), "utf8")) as Fixture;
      const lock = JSON.parse(readFileSync(join(oracle, "oracle-lock.json"), "utf8")) as { caseSha256: string; producerSha256: string; files: Record<string, string> };
      if (fixture.schema !== 1 || fixture.reference.revision !== MFLUX_REVISION || fixture.reference.mlx !== MLX_VERSION
        || fixture.reference.mlxMetal !== MLX_VERSION || fixture.reference.mflux !== "0.23.0" || lock.caseSha256 !== CASE_SHA256
        || JSON.stringify(fixture.selected) !== JSON.stringify(STAGES)) throw new Error("unexpected independent reference or scope");
      const verified = await verifyPinned(snapshot, fixture.models[model].snapshot);
      const extras = unpinnedEntries(snapshot, fixture.models[model].snapshot);
      // model_index.json is pinned separately; do not reject unrelated root files.
      const inputPins = DECLARED.noise === "captured" ? { [fixture.noise.file!]: fixture.noise.sha256! } : {};
      const capturesVerified = await verifyPinned(oracle, { ...lock.files, ...inputPins });
      run.verified = { snapshot: verified, captures: capturesVerified, unpinned: extras };
      if (verified.mismatched.length || capturesVerified.mismatched.length || extras.length)
        throw new Error([...verified.mismatched, ...capturesVerified.mismatched, ...extras].join("\n"));
      for (const mode of ["control", "traced"]) {
        const report = JSON.parse(readFileSync(join(oracle, `${model}-${mode}.json`), "utf8"));
        if (report.status !== "complete" || report.caseSha256 !== CASE_SHA256 || report.producerSha256 !== lock.producerSha256
          || report.model !== model || report.mode !== mode || report.captureSha256 !== lock.files[`${model}-${mode}.safetensors`]
          || JSON.stringify(report.calls) !== JSON.stringify({ generate: 1, noise: 1, encodes: 2, transformer: 2 * REQUEST.steps, decode: 1 })
          || !report.observerRestored || report.failures.length) throw new Error(`incomplete independent ${mode}`);
      }
      expected = readCapture(join(oracle, `${model}-traced.safetensors`));
      referenceControl = readCapture(join(oracle, `${model}-control.safetensors`));
      if (expected.size !== STAGES.length || STAGES.some(s => !expected.has(s)) || referenceControl.size !== 2) throw new Error("reference capture set");
      const positiveIds = expected.get("tokens.positive")!;
      if (positiveIds.dtype !== "I32" || positiveIds.shape.length !== 1 || positiveIds.shape[0]! < 1 || positiveIds.shape[0]! > 4096)
        throw new Error("invalid independent positive token sequence");
      positiveTokens = positiveIds.shape[0]!;
      if (DECLARED.positiveTokens !== null && positiveTokens !== DECLARED.positiveTokens) throw new Error("pinned token count changed");
      const expectedNoise = expected.get("input.noise")!;
      if (expectedNoise.dtype !== "F32" || expectedNoise.shape.join() !== spec("input.noise").shape.join()) throw new Error("independent noise geometry");
      let noise: Tensor | undefined;
      if (DECLARED.noise === "captured") {
        noise = readCapture(join(oracle, fixture.noise.file!)).get("latents")!;
        if (sha256(noise.bytes) !== fixture.noise.payloadSha256 || noise.dtype !== "F32" || noise.shape.join() !== spec("input.noise").shape.join()
          || sha256(expectedNoise.bytes) !== fixture.noise.payloadSha256) throw new Error("initial noise payload changed");
      } else if (fixture.noise.mode !== "native_seeded") throw new Error("native case must use its original seeded noise path");
      for (const branch of ["positive", "negative"] as const) {
        const pin = fixture.tokenizer[branch];
        if (pin && sha256(expected.get(`tokens.${branch}`)!.bytes) !== pin.sha256) throw new Error(`independent ${branch} tokenizer ids changed`);
      }
      const implementation = { commit: git("rev-parse", "HEAD"), modified: git("status", "--porcelain"), sourceSha256: await sourceHashes(),
        testSha256: await fileSha256(import.meta.path), helperSha256: await fileSha256(join(import.meta.dir, "moss-image-oracle-checks.ts")),
        bun: Bun.version, host: `${platform()} ${release()} ${arch()}` };
      run.implementation = implementation;
      save();

      const { MlxArray } = await import("@mlx-bun/mlx/array");
      const ffi = await import("@mlx-bun/mlx/ffi"), { Dtype } = ffi;
      const ops = await import("@mlx-bun/mlx/ops");
      const { openImagePipeline } = await import("../../src/models/image-factory");
      const { generateImage, GuidedVelocity } = await import("../../src/generation/image");
      const native: Record<string, string | null> = {};
      for (const path of [ffi.LIBMLXC_PATH, ...["libmlx.dylib", "mlx.metallib"].map(name => join(dirname(ffi.LIBMLXC_PATH), name))])
        native[path] = existsSync(path) ? await fileSha256(path) : null;
      run.runtime = { mlxVersion: ffi.MLX_VERSION, architecture: ffi.deviceArchitecture(), native };
      if (ffi.MLX_VERSION !== MLX_VERSION) issues.push(`MLX version changed: ${ffi.MLX_VERSION}`);
      const copy = (value: MlxArray): Tensor => {
        using rowMajor = ops.contiguous(value);
        rowMajor.eval();
        if (value.dtype !== Dtype.float32 && value.dtype !== Dtype.bfloat16) throw new Error("unexpected floating capture dtype");
        return { dtype: "F32", shape: [...value.shape], bytes: widen(rowMajor.rawBytes(), value.dtype === Dtype.bfloat16) };
      };
      const previousLimit = ffi.setMemoryLimit(fixture.budget.memoryLimitBytes);
      try {
        for (const mode of ["control", "traced"] as const) {
          const observed = mode === "traced", values = captures[mode], restores: (() => void)[] = [], pending = new Map<string, MlxArray>();
          const counts = { generate: 0, encodes: 0, transformer: 0, guided: 0, decode: 0, tokens: 0 };
          const stageOrder: string[] = [], released: string[] = [], memory: unknown[] = [];
          const detail: Record<string, unknown> = { status: "incomplete", counts, stageOrder, released, memory };
          modes[mode] = detail;
          let pipeline: TextToImagePipeline | undefined;
          const started = performance.now();
          const observe = (name: string, tensor: Tensor) => { if (values.has(name)) throw new Error(`duplicate ${name}`); values.set(name, tensor); };
          const retain = (name: string, tensor: MlxArray) => { if (pending.has(name)) throw new Error(`duplicate retained ${name}`); pending.set(name, ops.copyOf(tensor)); };
          const flush = () => { for (const [name, value] of pending) { try { observe(name, name === "final.raw" ? rawNchw(copy(value)) : copy(value)); } finally { value.dispose(); pending.delete(name); } } };
          try {
            ffi.clearCache(); ffi.resetPeakMemory();
            pipeline = (await openImagePipeline(snapshot)).pipeline;
            detail.stageBytes = pipeline.stageBytes;
            const releaseStage = pipeline.release;
            patch(pipeline, "release", function (this: TextToImagePipeline, stage: "conditioner" | "denoiser" | "decoder") {
              const result = releaseStage.call(this, stage); released.push(stage); return result;
            }, restores);
            const openConditioner = pipeline.conditioner;
            patch(pipeline, "conditioner", async function (this: TextToImagePipeline) {
              const component = await openConditioner.call(this) as MossImageConditioner;
              stageOrder.push("conditioner");
              const encode = component.encode;
              patch(component, "encode", function (this: MossImageConditioner, prompt: string) {
                counts.encodes++; const result = encode.call(this, prompt);
                if (observed) observe(`conditioning.${prompt === REQUEST.prompt ? "positive" : "negative"}`, copy(result));
                return result;
              }, restores);
              if (observed) {
                const tokens = component.tokens;
                patch(component, "tokens", function (this: MossImageConditioner, prompt: string) {
                  counts.tokens++; const result = tokens.call(this, prompt);
                  observe(`tokens.${prompt === REQUEST.prompt ? "positive" : "negative"}`, { dtype: "I32", shape: [result.length], bytes: new Uint8Array(Int32Array.from(result).buffer) });
                  return result;
                }, restores);
              }
              return component;
            }, restores);
            const openDenoiser = pipeline.denoiser;
            patch(pipeline, "denoiser", async function (this: TextToImagePipeline) {
              const component = await openDenoiser.call(this); stageOrder.push("denoiser");
              const velocity = component.velocity;
              patch(component, "velocity", function (this: typeof component, ...args: Parameters<typeof velocity>) {
                const index = counts.transformer++; const result = velocity.apply(this, args);
                if (observed) retain(`step.${Math.floor(index / 2)}.${index % 2 ? "unconditional" : "conditional"}`, result);
                return result;
              }, restores);
              return component;
            }, restores);
            const openDecoder = pipeline.decoder;
            patch(pipeline, "decoder", async function (this: TextToImagePipeline) {
              const component = await openDecoder.call(this); stageOrder.push("decoder");
              const decode = component.decode;
              patch(component, "decode", function (this: typeof component, latents: MlxArray) {
                counts.decode++; flush();
                const final = copy(latents); observe("final.latents", final);
                if (observed) observe(`step.${REQUEST.steps - 1}.latents`, final);
                const result = decode.call(this, latents);
                if (observed) retain("final.raw", result);
                return result;
              }, restores);
              return component;
            }, restores);
            if (observed) {
              const velocity = GuidedVelocity.prototype.velocity;
              patch(GuidedVelocity.prototype, "velocity", function (this: InstanceType<typeof GuidedVelocity>, latents: MlxArray, timestep: number) {
                flush(); const step = counts.guided++;
                observe(step === 0 ? "input.noise" : `step.${step - 1}.latents`, copy(latents));
                const result = velocity.call(this, latents, timestep);
                retain(`step.${step}.guided`, result); return result;
              }, restores);
              const sigmas = pipeline.schedule.sigmas, timestep = pipeline.schedule.timestep, timesteps: number[] = [];
              patch(pipeline.schedule, "sigmas", function (this: TextToImagePipeline["schedule"], steps: number) {
                const result = sigmas.call(this, steps); observe("schedule.sigmas", { dtype: "F32", shape: [result.length], bytes: new Uint8Array(result.slice().buffer) }); return result;
              }, restores);
              patch(pipeline.schedule, "timestep", function (this: TextToImagePipeline["schedule"], sigma: number) {
                const result = timestep.call(this, sigma); timesteps.push(result);
                if (timesteps.length === REQUEST.steps) observe("schedule.timesteps", { dtype: "F32", shape: [REQUEST.steps], bytes: new Uint8Array(Float32Array.from(timesteps).buffer) });
                return result;
              }, restores);
            }
            // Native case deliberately has no input tensor to copy: public generateImage draws its own seeded noise.
            using initial = noise ? MlxArray.fromBytesCopy(noise.bytes, noise.shape, Dtype.float32) : null;
            counts.generate++;
            const image = await generateImage(pipeline, REQUEST, { ...(initial ? { latents: initial } : {}), releaseStages: true,
              signal: AbortSignal.timeout(fixture.budget.secondsPerPipeline * 1000),
              onProgress: progress => { memory.push({ ...progress, activeBytes: ffi.activeMemory(), peakBytes: ffi.peakMemory() }); save(); },
            });
            flush();
            observe("final.pixels", { dtype: "U8", shape: [1, image.height, image.width, 3], bytes: image.pixels.slice() });
            if (image.steps !== REQUEST.steps || image.seed !== REQUEST.seed || image.guidance !== REQUEST.guidance) issues.push(`${mode}: generation metadata mismatch`);
            detail.status = "complete";
          } catch (error) { detail.error = String(error); issues.push(`${mode}: ${String(error)}`); }
          finally {
            for (const restore of restores.reverse()) restore();
            for (const value of pending.values()) value.dispose(); pending.clear();
            pipeline?.dispose();
            await new Promise<void>(done => setImmediate(done));
            detail.seconds = (performance.now() - started) / 1000;
            detail.peakBytes = ffi.peakMemory();
            detail.observerRestored = true;
            const file = join(output, `${model}-${mode}.safetensors`);
            writeCapture(file, values); detail.captureSha256 = await fileSha256(file); detail.captured = [...values.keys()];
            if (counts.generate !== 1 || counts.encodes !== 2 || counts.transformer !== 2 * REQUEST.steps || counts.decode !== 1
              || observed && (counts.guided !== REQUEST.steps || counts.tokens !== 2)) issues.push(`${mode}: forward or tokenizer count mismatch`);
            if (stageOrder.join() !== "conditioner,denoiser,decoder" || released.join() !== "conditioner,denoiser,decoder") issues.push(`${mode}: stage lifecycle mismatch`);
            if (ffi.peakMemory() > fixture.budget.memoryLimitBytes) issues.push(`${mode}: memory budget exceeded`);
            const names = observed ? STAGES : CONTROLS;
            if (values.size !== names.length || names.some(name => !values.has(name))) issues.push(`${mode}: capture set mismatch`);
            ffi.clearCache(); save();
          }
          if (detail.status !== "complete" || issues.length) break; // stop after any recorded run failure
        }
      } finally { ffi.setMemoryLimit(previousLimit); }
      if (git("rev-parse", "HEAD") !== implementation.commit || JSON.stringify(await sourceHashes()) !== JSON.stringify(implementation.sourceSha256))
        issues.push("candidate source changed during execution");
    } catch (error) { run.error = String(error); issues.push(String(error)); }
    finally {
      // Every declared measurement is recorded before the single assertion,
      // including missing observations when a pipeline failed partway through.
      for (const stage of STAGES) checks.push(measure(stage, stage, captures.traced.get(stage), expected.get(stage)));
      for (const stage of CONTROLS) {
        checks.push(measure(`mflux.control.${stage}`, stage, expected.get(stage), referenceControl.get(stage)));
        checks.push(measure(`bun.control.${stage}`, stage, captures.traced.get(stage), captures.control.get(stage)));
      }
      run.status = modes.control?.status !== "complete" || modes.traced?.status !== "complete" ? "incomplete"
        : issues.length || checks.some(check => !check.pass) ? "failed" : "passed";
      run.failures = [...issues, ...checks.filter(check => !check.pass).map(check => check.stage)];
      save();
    }
    expect(run.failures).toEqual([]);
  }, DECLARED.timeoutMs);
});
