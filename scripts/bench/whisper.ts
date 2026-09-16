#!/usr/bin/env bun
// Whisper transcription benchmark: our fast and faithful paths vs the
// mlx-whisper oracle (its own venv) and whisper.cpp (sotto's vendored
// v1.9.3 helper, when built). Warm, in-process, min-of-N per cell; every
// arm decodes the same clips and the texts are printed so quality can be
// eyeballed alongside the numbers. Results land in docs/reference/benchmarks.md
// by hand; raw JSON goes to reports/.
//
//   bun scripts/bench/whisper.ts [--reps 5] [--json reports/whisper-bench.json]

import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { hostname } from "node:os";
import { dirname } from "node:path";
import { decodeWav } from "../../src/audio/decode";
import { loadWhisperTokenizer } from "../../src/audio/whisper-tokenizer";
import { WhisperTranscriber } from "../../src/audio/whisper-transcribe";
import { openWhisperModel } from "../../src/model/factory";
import { SNAPSHOT_WHISPER, WHISPER_ORACLE_PYTHON } from "../../tests/support/paths";

const argv = process.argv.slice(2);
const opt = (n: string, d: string) => { const i = argv.indexOf(`--${n}`); return i >= 0 ? argv[i + 1]! : d; };
const reps = Number(opt("reps", "5"));
const jsonPath = opt("json", "reports/whisper-bench.json");
const ROOT = `${import.meta.dir}/../..`;
const SOTTO = `${process.env.HOME}/Code/sotto`;
const JFK = `${SOTTO}/vendor/whisper.cpp/samples/jfk.wav`;
const FOX = `${ROOT}/fixtures/audio/speech-fox.wav`;

const wav = (p: string) => decodeWav(new Uint8Array(readFileSync(p))).samples;
const cat = (parts: Float32Array[]) => { const o = new Float32Array(parts.reduce((n, p) => n + p.length, 0)); let i = 0; for (const p of parts) { o.set(p, i); i += p.length; } return o; };
const fox = wav(FOX);
const clips: Record<string, Float32Array> = { fox };
if (existsSync(JFK)) {
  const jfk = wav(JFK);
  clips.jfk = jfk;
  clips.long = cat([fox, new Float32Array(32_000), jfk, new Float32Array(16_000), fox, jfk, fox]);
}
const writeWav = (path: string, s: Float32Array) => {
  const buf = Buffer.alloc(44 + s.length * 2);
  buf.write("RIFF", 0); buf.writeUInt32LE(36 + s.length * 2, 4); buf.write("WAVE", 8); buf.write("fmt ", 12);
  buf.writeUInt32LE(16, 16); buf.writeUInt16LE(1, 20); buf.writeUInt16LE(1, 22); buf.writeUInt32LE(16_000, 24);
  buf.writeUInt32LE(32_000, 28); buf.writeUInt16LE(2, 32); buf.writeUInt16LE(16, 34); buf.write("data", 36); buf.writeUInt32LE(s.length * 2, 40);
  for (let i = 0; i < s.length; i++) buf.writeInt16LE(Math.max(-32768, Math.min(32767, Math.round(s[i]! * 32768))), 44 + i * 2);
  writeFileSync(path, buf);
};
mkdirSync("/tmp/mlx-bun-whisper-bench", { recursive: true });
for (const [name, s] of Object.entries(clips)) writeWav(`/tmp/mlx-bun-whisper-bench/${name}.wav`, s);

interface Cell { engine: string; clip: string; mode: string; ms: number; text: string; audioSeconds: number }
const cells: Cell[] = [];
const record = (engine: string, clip: string, mode: string, ms: number, text: string) => {
  cells.push({ engine, clip, mode, ms, text, audioSeconds: clips[clip]!.length / 16_000 });
  console.log(`${engine.padEnd(14)} ${clip.padEnd(5)} ${mode.padEnd(7)} ${ms.toFixed(0).padStart(5)} ms  ${(clips[clip]!.length / 16_000 / (ms / 1000)).toFixed(1).padStart(5)}× rt  ${JSON.stringify(text.slice(0, 60))}`);
};

// --- ours ---
const { model } = await openWhisperModel(SNAPSHOT_WHISPER);
const tok = await loadWhisperTokenizer(SNAPSHOT_WHISPER, model.dims.nVocab);
const tr = new WhisperTranscriber(model, tok);
for (const [clip, s] of Object.entries(clips)) for (const [mode, beam] of [["greedy", null], ["beam5", 5]] as const) for (const fast of [true, false]) {
  const o = { language: "en", temperature: 0, beamSize: beam, fast };
  await tr.transcribe(s, o);
  let best = Infinity; let text = "";
  for (let i = 0; i < reps; i++) { const t0 = performance.now(); const r = await tr.transcribe(s, o); best = Math.min(best, performance.now() - t0); text = r.text; }
  record(fast ? "mlx-bun fast" : "mlx-bun faith", clip, mode, best, text);
}

// --- mlx-whisper (oracle venv) ---
if (existsSync(WHISPER_ORACLE_PYTHON)) {
  const py = `
import time, json, sys, numpy as np, wave, mlx_whisper
p = ${JSON.stringify(SNAPSHOT_WHISPER)}
out = []
for name in ${JSON.stringify(Object.keys(clips))}:
    w = wave.open(f"/tmp/mlx-bun-whisper-bench/{name}.wav"); a = np.frombuffer(w.readframes(w.getnframes()), np.int16).astype(np.float32) / 32768.0
    mlx_whisper.transcribe(a, path_or_hf_repo=p, language="en", temperature=0.0, fp16=True)
    best = 1e9; text = ""
    for _ in range(${reps}):
        t = time.perf_counter(); r = mlx_whisper.transcribe(a, path_or_hf_repo=p, language="en", temperature=0.0, fp16=True); best = min(best, (time.perf_counter() - t) * 1000); text = r["text"]
    out.append({"clip": name, "ms": best, "text": text})
print(json.dumps(out))
`;
  const proc = Bun.spawnSync([WHISPER_ORACLE_PYTHON, "-c", py], { stdout: "pipe", stderr: "pipe" });
  const line = proc.stdout.toString().trim().split("\n").at(-1) ?? "[]";
  for (const r of JSON.parse(line) as { clip: string; ms: number; text: string }[]) record("mlx-whisper", r.clip, "greedy", r.ms, r.text);
}

// --- whisper.cpp via sotto's helper (beam 5, temperature 0, its VAD gate) ---
const helper = `${SOTTO}/build/server/helpers/sotto-engine`;
const ggml = `${SOTTO}/.local/models/ggml-large-v3-turbo.bin`;
const vad = `${SOTTO}/build/server/resources/silero-vad.bin`;
if (existsSync(helper) && existsSync(ggml) && existsSync(vad)) {
  const reqs: string[] = [];
  for (const clip of Object.keys(clips)) for (let i = 0; i < reps + 1; i++)
    reqs.push(JSON.stringify({ type: "transcribe", id: `${clip}-${i}`, path: `/tmp/mlx-bun-whisper-bench/${clip}.wav`, language: "en", vocabularyTerms: [] }));
  reqs.push(JSON.stringify({ type: "quit" }));
  const proc = Bun.spawnSync([helper, "--model", ggml, "--vad-model", vad, "--threads", "4"], { stdin: Buffer.from(reqs.join("\n") + "\n"), stdout: "pipe", stderr: "pipe" });
  const best: Record<string, { ms: number; text: string }> = {};
  for (const line of proc.stdout.toString().split("\n")) {
    if (!line.includes('"result"')) continue;
    const r = JSON.parse(line) as { id: string; elapsed: number; text: string };
    const [clip, i] = r.id.split("-") as [string, string];
    if (i === "0") continue; // warm-up
    if (!best[clip] || r.elapsed * 1000 < best[clip]!.ms) best[clip] = { ms: r.elapsed * 1000, text: r.text };
  }
  for (const [clip, r] of Object.entries(best)) record("whisper.cpp", clip, "beam5", r.ms, r.text);
}

mkdirSync(dirname(jsonPath), { recursive: true });
writeFileSync(jsonPath, JSON.stringify({ host: hostname(), date: new Date().toISOString(), reps, cells }, null, 1));
console.log(`\nwrote ${jsonPath}`);
