/** Reference producer for the speech and embedding parity tests: runs the
 * pre-refactor main checkout's own Whisper, Silero VAD and text-embedding code
 * and writes what it computes to a JSON file outside this repository.
 *
 *   cd <main checkout at 02d723a>
 *   MLX_BUN_LIBMLXC=<libmlxc.dylib> bun --no-env-file <this file> whisper \
 *     --model <mlx-community/whisper-large-v3-turbo snapshot> \
 *     --oracle <dir holding the mlx-whisper whisper.json> --audio <dir of wavs> --out main-whisper.json
 *   ... bun --no-env-file <this file> vad --vad-model <ggml-silero-v6.2.0.bin> --audio <dir> --out main-vad.json
 *   ... bun --no-env-file <this file> embed --model <Qwen3-Embedding snapshot> --out main-embed.json
 *
 * Main's sources are imported by path; nothing is written to or changed in the
 * main checkout, and nothing here is imported by the repository's code. The
 * tests compare a checkout of this tree against the produced file, which is
 * pinned by its SHA-256 and never committed. Whisper cases and clips come from
 * the oracle's manifest (`gen-whisper-golden.py`, unchanged at main `02d723a`),
 * so both references cover the same inputs. */
import { createHash } from "node:crypto";
import { readFileSync, writeFileSync } from "node:fs";
import { basename, join, resolve } from "node:path";
import { parseArgs } from "node:util";

const sha = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");
type Loose = any; // main's modules are imported by path at run time, so they have no static types here
const load = (main: string, path: string): Promise<Loose> => import(join(main, "src", path));

type Recipe = ({ file: string } | { silence: number })[];
interface OracleManifest {
  clips: Record<string, { recipe: Recipe; num_samples: number }>;
  cases: { clip: string; name: string; options: Record<string, unknown> }[];
}

/** Concatenate a clip's recipe from `audioDir`, resolving files by base name. */
function buildClip(audioDir: string, recipe: Recipe, decodeWav: (bytes: Uint8Array) => { samples: Float32Array }): Float32Array {
  const parts = recipe.map(step => "silence" in step
    ? new Float32Array(Math.floor(step.silence * 16_000))
    : decodeWav(new Uint8Array(readFileSync(join(audioDir, basename(step.file))))).samples);
  const out = new Float32Array(parts.reduce((n, part) => n + part.length, 0));
  let offset = 0;
  for (const part of parts) { out.set(part, offset); offset += part.length; }
  return out;
}

const plain = (value: unknown) => JSON.parse(JSON.stringify(value));
const fileSha = (path: string) => createHash("sha256").update(readFileSync(path)).digest("hex");

async function whisper(main: string, model: string, oracle: string, audio: string): Promise<unknown> {
  const [{ decodeWav }, { loadWhisperTokenizer }, { WhisperTranscriber }, { openWhisperModel }] = await Promise.all([
    load(main, "audio/decode.ts"), load(main, "audio/whisper-tokenizer.ts"),
    load(main, "audio/whisper-transcribe.ts"), load(main, "model/factory.ts"),
  ]);
  const manifest = JSON.parse(readFileSync(join(oracle, "whisper.json"), "utf8")) as OracleManifest;
  const { model: graph } = await openWhisperModel(model);
  const transcriber = new WhisperTranscriber(graph, await loadWhisperTokenizer(model, graph.dims.nVocab));
  const clips = new Map<string, Float32Array>();
  for (const [name, clip] of Object.entries(manifest.clips)) {
    const samples = buildClip(audio, clip.recipe, decodeWav);
    if (samples.length !== clip.num_samples) throw new Error(`${name}: ${samples.length} samples, oracle has ${clip.num_samples}`);
    clips.set(name, samples);
  }
  const optionsOf = (o: Record<string, unknown>) => ({
    language: (o.language as string | null | undefined) ?? null,
    task: (o.task as "transcribe" | "translate") ?? "transcribe",
    temperature: 0,
    initialPrompt: (o.initial_prompt as string) ?? null,
    withoutTimestamps: (o.without_timestamps as boolean) ?? false,
    conditionOnPreviousText: (o.condition_on_previous_text as boolean) ?? true,
  });
  const runs: unknown[] = [];
  const record = async (label: string, clip: string, options: Record<string, unknown>) => {
    let features: string | null = null;
    const result = await transcriber.transcribe(clips.get(clip)!, {
      ...options,
      observer: { onAudioFeatures: (f: Loose) => { features ??= sha(f.rawBytes()); } },
    });
    runs.push({ label, clip, options, encoderSha256: features, result: plain(result) });
    console.log(`${label}: ${JSON.stringify(result.text).slice(0, 80)}`);
  };
  for (const c of manifest.cases) {
    if (!clips.has(c.clip)) continue;
    for (const fast of [false, true]) await record(`${c.clip}-${c.name}-${fast ? "fast" : "faithful"}`, c.clip, { ...optionsOf(c.options), fast });
  }
  for (const clip of ["fox", "jfk", "long"]) {
    if (!clips.has(clip)) continue;
    const beam = { language: "en", temperature: 0, beamSize: 5, initialPrompt: clip === "jfk" ? "Sotto, SwiftUI, Metal" : null };
    for (const fast of [false, true]) await record(`${clip}-beam5-${fast ? "fast" : "faithful"}`, clip, { ...beam, fast });
  }
  await record("fox-words-faithful", "fox", { language: "en", temperature: 0, wordTimestamps: true, fast: false });

  // A resumable run fed 1 s at a time.
  const streamed: unknown[] = [];
  const run = transcriber.start({ language: "en", temperature: 0 });
  const jfk = clips.get("jfk")!;
  for (let at = 0; at < jfk.length; at += 16_000) streamed.push(plain(await run.feed(jfk.subarray(at, Math.min(jfk.length, at + 16_000)))));
  const finished = plain(await run.finish());
  transcriber.dispose();
  return { producer: "main-speech-reference whisper", weightsSha256: fileSha(join(model, "weights.safetensors")), runs, streaming: { clip: "jfk", chunkSamples: 16_000, fed: streamed, finished } };
}

async function vad(main: string, vadModel: string, audio: string): Promise<unknown> {
  const { decodeWav } = await load(main, "audio/decode.ts");
  const { SileroVad } = await load(main, "audio/silero-vad.ts");
  const wav = (name: string) => decodeWav(new Uint8Array(readFileSync(join(audio, name)))).samples as Float32Array;
  const clips: Record<string, Float32Array> = {
    fox: wav("speech-fox.wav"), chirp: wav("chirp-1s6.wav"), silence: new Float32Array(32_000), jfk: wav("jfk.wav"),
  };
  const vadGraph = SileroVad.load(vadModel);
  const out: Record<string, unknown> = {};
  for (const [name, samples] of Object.entries(clips)) {
    const probs: Float32Array = vadGraph.probs(samples);
    const state = SileroVad.streamState();
    const streamed: number[] = [];
    for (let at = 0; at < samples.length; at += 1_600) streamed.push(...vadGraph.probsStreaming(samples.subarray(at, Math.min(samples.length, at + 1_600)), state));
    out[name] = {
      numSamples: samples.length, probs: [...probs], streamedProbs: streamed,
      segments: SileroVad.speechTimestamps(probs, samples.length, { threshold: 0.5, minSpeechDurationMs: 120 }),
      segmentsDefault: SileroVad.speechTimestamps(probs, samples.length),
    };
  }
  vadGraph.dispose();
  return { producer: "main-speech-reference vad", modelSha256: fileSha(vadModel), clips: out };
}

const TEXTS = [
  "The cat sat on the warm windowsill in the afternoon sun.",
  "an unrelated sentence about quarterly cloud revenue",
  "a",
  "Bit-exact numerics against a reference implementation are the contract; policy defaults are separate. ".repeat(6).trim(),
];
const INSTRUCTION = "Given a web search query, retrieve relevant passages that answer the query";

async function embed(main: string, model: string): Promise<unknown> {
  const [{ loadModelConfig }, { createModel }, { Weights }, { loadTokenizer }, embedding] = await Promise.all([
    load(main, "config.ts"), load(main, "model/factory.ts"), load(main, "weights.ts"), load(main, "tokenizer.ts"), load(main, "embed.ts"),
  ]);
  const config = await loadModelConfig(model);
  const graph = createModel(await Weights.open(model), config);
  const tokenizer = await loadTokenizer(model);
  const encode = (results: { vector: Float32Array; tokens: number }[]) =>
    results.map(r => ({ tokens: r.tokens, vectorBase64: Buffer.from(r.vector.buffer, r.vector.byteOffset, r.vector.byteLength).toString("base64") }));
  embedding.resetEmbedCounter();
  const documents = encode(embedding.embedMany(graph, tokenizer, TEXTS));
  const queries = encode(embedding.embedMany(graph, tokenizer, TEXTS, INSTRUCTION));
  return { producer: "main-speech-reference embed", weightsSha256: fileSha(join(model, "model.safetensors")), texts: TEXTS, instruction: INSTRUCTION, documents, queries, counter: embedding.getEmbedCounter() };
}

const { positionals, values } = parseArgs({
  allowPositionals: true,
  options: { main: { type: "string" }, model: { type: "string" }, oracle: { type: "string" }, audio: { type: "string" },
    "vad-model": { type: "string" }, out: { type: "string" } },
});
const need = (name: keyof typeof values) => {
  const value = values[name];
  if (!value) throw new Error(`--${name} is required`);
  return resolve(value as string);
};
const main = resolve(values.main ?? process.cwd());
const command = positionals[0];
const reference =
  command === "whisper" ? await whisper(main, need("model"), need("oracle"), need("audio"))
  : command === "vad" ? await vad(main, need("vad-model"), need("audio"))
  : command === "embed" ? await embed(main, need("model"))
  : (() => { throw new Error("usage: main-speech-reference.ts <whisper|vad|embed> [--main dir] --out file (see the file header)"); })();
writeFileSync(need("out"), JSON.stringify({ mainRevision: Bun.spawnSync(["git", "-C", main, "rev-parse", "HEAD"]).stdout.toString().trim(), ...reference as object }, null, 1) + "\n");
console.log(`wrote ${need("out")}`);
