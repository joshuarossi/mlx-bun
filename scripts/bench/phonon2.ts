// Matched Phonon-2 A/B against Fermion's default optimized MLX runtime.
// Run the whole command through gpu.sh; children share its GPU reservation.
import { createHash } from "node:crypto";
import { existsSync, readFileSync, realpathSync, writeFileSync } from "node:fs";
import { hostname, release } from "node:os";
import {
  basename,
  dirname,
  isAbsolute,
  join,
  relative,
  resolve,
} from "node:path";
import { parseArgs } from "node:util";
import { checkMachine, pairedDelta } from "./perf-check";
import { sourceSnapshot } from "./plan";

const ROOT = resolve(import.meta.dir, "../..");
const sha = (path: string) =>
  createHash("sha256").update(readFileSync(path)).digest("hex");
const median = (v: number[]) => {
  const a = [...v].sort((x, y) => x - y),
    i = a.length >> 1;
  return a.length % 2 ? a[i]! : (a[i - 1]! + a[i]!) / 2;
};
interface Timing {
  rep: number;
  audio: string;
  ms: number;
  text: string;
}
interface Worker {
  loadMs: number;
  warmup: Array<{ audio: string; ms: number }>;
  rows: Timing[];
  memory: { active: number; cache: number; peak: number };
  [key: string]: unknown;
}

async function main() {
  const { values } = parseArgs({
    options: {
      model: { type: "string" },
      container: { type: "string" },
      config: { type: "string" },
      python: { type: "string" },
      audio: { type: "string", multiple: true },
      out: { type: "string" },
      sessions: { type: "string", default: "6" },
      repetitions: { type: "string", default: "7" },
      warmup: { type: "string", default: "2" },
      worker: { type: "boolean" },
      screen: { type: "boolean" },
      help: { type: "boolean" },
    },
  });
  if (values.help) {
    console.log(`Run under gpu.sh:
  bun scripts/bench/phonon2.ts --model /absolute/Phonon-2 --python /external/venv/bin/python \\
    --container /unpacked/model.fermion --config /unpacked/config.json \\
    --audio /clip1.flac --audio /clip2.flac --audio /clip3.flac --out /external/result.json

Uses pinned mlx 0.32.2, mlx-audio 0.4.6 and fermion-research 0.2.11.
Fresh process pairs alternate reference/candidate order. Both use mono 16 kHz
clips, greedy English, bf16 activations, dense16 encoder and completed readbacks.
Audio decoding is outside timers. Loading and first-use compilation are separate
from warm transcription. Reports session-median ratios and paired 95% intervals,
source/native/artifact hashes, machine preflight and MLX allocator memory.
Defaults: --sessions 6 --repetitions 7 --warmup 2. Outputs must be outside Git.
This measures the library transcription call; HTTP transport is not included.
--screen records an unclear machine for diagnosis, without qualifying a speed claim.`);
    return;
  }
  if (!values.model || !values.audio?.length)
    throw new Error("--model and --audio required");
  const repetitions = Number(values.repetitions),
    warmup = Number(values.warmup),
    sessions = Number(values.sessions);
  for (const n of [repetitions, warmup, sessions])
    if (!Number.isSafeInteger(n) || n < 1)
      throw new Error("counts must be positive integers");
  if (values.worker) {
    const [{ openTranscriber }, { decodeFileWithAudioToolbox }, ffi] =
      await Promise.all([
        import("@mlx-bun/inference"),
        import("@mlx-bun/inference/input/audio"),
        import("@mlx-bun/mlx/ffi"),
      ]);
    const clips = values.audio.map((path) => ({
      audio: basename(path),
      samples: decodeFileWithAudioToolbox(path),
    }));
    const start = performance.now(),
      model = await openTranscriber(values.model);
    const loadMs = performance.now() - start;
    try {
      const first: Array<{ audio: string; ms: number }> = [],
        rows: Timing[] = [];
      for (let rep = 0; rep < warmup; rep++)
        for (const clip of clips) {
          const t = performance.now();
          await model.transcribe(clip.samples);
          first.push({ audio: clip.audio, ms: performance.now() - t });
        }
      for (let rep = 0; rep < repetitions; rep++)
        for (const clip of clips) {
          const t = performance.now(),
            result = await model.transcribe(clip.samples);
          rows.push({
            rep,
            audio: clip.audio,
            ms: performance.now() - t,
            text: result.text,
          });
        }
      console.log(
        JSON.stringify({
          loadMs,
          warmup: first,
          rows,
          residentBytes: model.residentBytes,
          memory: {
            active: ffi.activeMemory(),
            cache: ffi.cacheMemory(),
            peak: ffi.peakMemory(),
          },
          native: Object.fromEntries(
            ["libmlxc.dylib", "libmlx.dylib", "mlx.metallib"].map((n) => [
              n,
              sha(join(dirname(ffi.LIBMLXC_PATH), n)),
            ]),
          ),
          mlx: ffi.MLX_VERSION,
          architecture: ffi.deviceArchitecture(),
        }),
      );
    } finally {
      model.dispose();
    }
    return;
  }
  if (!values.python || !values.container || !values.config || !values.out)
    throw new Error("--python, --container, --config and --out required");
  const out = resolve(values.out),
    rel = relative(ROOT, realpathSync(dirname(out)));
  if (!isAbsolute(values.out) || !rel.startsWith("../") || existsSync(out))
    throw new Error("--out must be a new absolute path outside the checkout");
  const names = values.audio.map((p) => basename(p));
  if (new Set(names).size !== names.length)
    throw new Error("audio basenames must be distinct");
  const before = checkMachine();
  if (!before.ok && !values.screen)
    throw new Error(`benchmark preflight: ${before.problems.join("; ")}`);
  const source = sourceSnapshot(ROOT);
  const containerSha = sha(values.container),
    modelConfig = JSON.parse(
      readFileSync(join(values.model, "config.json"), "utf8"),
    );
  const candidateSha =
    modelConfig.artifact?.container_sha256 ??
    sha(join(values.model, "model.fermion"));
  if (candidateSha !== containerSha)
    throw new Error("candidate and reference model artifacts differ");
  const common = [
    "--repetitions",
    String(repetitions),
    "--warmup",
    String(warmup),
    ...values.audio.flatMap((p) => ["--audio", resolve(p)]),
  ];
  const native = [
    process.execPath,
    import.meta.filename,
    "--worker",
    "--model",
    resolve(values.model),
    ...common,
  ];
  const reference = [
    values.python,
    join(ROOT, "packages/inference/scripts/phonon2-reference.py"),
    "--container",
    resolve(values.container),
    "--config",
    resolve(values.config),
    "--benchmark",
    String(repetitions),
    "--warmup",
    String(warmup),
    "--audio",
    ...values.audio.map((p) => resolve(p)),
  ];
  const pairs: Array<{ baseline: Worker; candidate: Worker }> = [];
  async function run(command: string[]): Promise<Worker> {
    const child = Bun.spawn(command, { stdout: "pipe", stderr: "inherit" });
    const output = await new Response(child.stdout).text(),
      code = await child.exited;
    if (code) throw new Error(`worker exited ${code}`);
    return JSON.parse(output);
  }
  for (let i = 0; i < sessions; i++) {
    let baseline: Worker, candidate: Worker;
    if (i % 2) {
      candidate = await run(native);
      baseline = await run(reference);
    } else {
      baseline = await run(reference);
      candidate = await run(native);
    }
    if (
      baseline.rows.length !== repetitions * names.length ||
      candidate.rows.length !== baseline.rows.length
    )
      throw new Error("incomplete worker");
    for (let j = 0; j < baseline.rows.length; j++) {
      const a = baseline.rows[j]!,
        b = candidate.rows[j]!;
      if (a.audio !== b.audio || a.rep !== b.rep || a.text !== b.text)
        throw new Error(`transcription mismatch in session ${i + 1}`);
    }
    pairs.push({ baseline, candidate });
    console.log(
      `completed pair ${i + 1}/${sessions} (${i % 2 ? "candidate first" : "reference first"})`,
    );
  }
  const compare = (name: string, sample: (w: Worker) => number) => {
    const cells = pairs.map((p, i) => ({
      id: String(i + 1),
      baseline: sample(p.baseline),
      candidate: sample(p.candidate),
    }));
    const baselineMedian = median(cells.map((p) => p.baseline)),
      candidateMedian = median(cells.map((p) => p.candidate));
    return pairedDelta(
      {
        metric: name,
        unit: "ms",
        direction: "lower-is-better",
        pairs: cells,
        baselineMedian,
        candidateMedian,
        ratio: null,
        observation:
          candidateMedian < baselineMedian
            ? "candidate better"
            : candidateMedian > baselineMedian
              ? "candidate worse"
              : "equal",
        unpaired: { baseline: [], candidate: [] },
        excluded: [],
      },
      true,
    );
  };
  const deltas = names.map((name) =>
    compare(name, (w) =>
      median(w.rows.filter((r) => r.audio === name).map((r) => r.ms)),
    ),
  );
  const after = checkMachine();
  const sourceAfter = sourceSnapshot(ROOT),
    sourceUnchanged =
      source.sha256 === sourceAfter.sha256 && source.head === sourceAfter.head;
  const report = {
    schema: 1,
    at: new Date().toISOString(),
    source,
    sourceAfter,
    sourceUnchanged,
    machine: { host: hostname(), os: release(), bun: Bun.version },
    before,
    after,
    settings: {
      sessions,
      repetitions,
      warmup,
      reference: "dense16+tdt16",
      candidate:
        "Metal fp16 expansion + MLX GEMM, compiled blocks + Metal TDT16",
      audioDecodeTimed: false,
    },
    artifacts: {
      container: containerSha,
      config: sha(values.config),
      modelConfig: sha(join(values.model, "config.json")),
      clips: values.audio.map((p) => ({ name: basename(p), sha256: sha(p) })),
    },
    deltas,
    load: compare("cold model loading", (w) => w.loadMs),
    pairs,
    timingMeetsBaseline: deltas.every(
      (d) => d.interval !== null && d.interval[1] <= 1,
    ),
    meetsBaseline:
      before.ok &&
      after.ok &&
      sourceUnchanged &&
      deltas.every((d) => d.interval !== null && d.interval[1] <= 1),
  };
  writeFileSync(out, JSON.stringify(report, null, 2));
  console.log(
    JSON.stringify(
      {
        meetsBaseline: report.meetsBaseline,
        timingMeetsBaseline: report.timingMeetsBaseline,
        preflight: { before: before.ok, after: after.ok },
        deltas,
        load: report.load,
      },
      null,
      2,
    ),
  );
  if (!report.meetsBaseline) process.exitCode = 1;
}
if (import.meta.main) await main();
