// Residency policy and request ordering of the Whisper service with a fake
// runtime and a fake clock: no weights, no native MLX, no timers.
import { expect, test } from "bun:test";
import type { WhisperSegment, WhisperTranscribeOptions, WhisperTranscription } from "@mlx-bun/inference/transcription";
import {
  TranscriptionError, TranscriptionService, type TranscriptionRuntime, type VadGate, type WhisperRun, type WhisperRuntime,
} from "../../src/engine/transcription-service";

const segment = (id: number, text: string, start = 0, end = 1): WhisperSegment =>
  ({ id, seek: 0, start, end, text, tokens: [id], temperature: 0, avgLogprob: -0.1, compressionRatio: 1, noSpeechProb: 0 });

interface Harness {
  events: string[];
  transcribed: WhisperTranscribeOptions[];
  runtime: TranscriptionRuntime;
  /** Blocks every `transcribe` until released; null runs immediately. */
  gate: { promise: Promise<void> } | null;
  /** Blocks `load` until released. */
  loadGate: { promise: Promise<void> } | null;
  /** Blocks every session `feed` and `finish` until released; null runs immediately. */
  feedGate: { promise: Promise<void> } | null;
  vadSegments: { start: number; end: number }[];
  clock: { now: number };
  timers: { scheduled: { id: number; ms: number; fn: () => void }[]; fire(): void };
}

function harness(): Harness {
  const events: string[] = [], transcribed: WhisperTranscribeOptions[] = [];
  const clock = { now: 0 };
  const scheduled: Harness["timers"]["scheduled"] = [];
  let nextTimer = 1;
  const h: Harness = {
    events, transcribed, clock, gate: null, loadGate: null, feedGate: null, vadSegments: [],
    timers: { scheduled, fire() { const timer = scheduled.shift(); timer?.fn(); } },
    runtime: {
      async load(dir) {
        events.push(`load ${dir}`);
        await h.loadGate?.promise;
        clock.now += 250;
        const loaded: WhisperRuntime = {
          promptTokenBudget: 3,
          encode: text => text.split(",").map(part => part.trim()).filter(Boolean).map((_, index) => index),
          async transcribe(samples, options) {
            transcribed.push(options);
            events.push(`transcribe ${samples.length}`);
            await h.gate?.promise;
            options.onSegment?.(segment(0, " hello"));
            clock.now += 40;
            return { text: " hello", segments: [segment(0, " hello")], language: options.language ?? "en" };
          },
          start(options) {
            let fed = 0, finished = false;
            const segments: WhisperSegment[] = [];
            const run: WhisperRun = {
              get segments() { return segments; },
              feedSilent(samples) { fed += samples.length; events.push(`silent ${samples.length}`); },
              async feed(samples) { fed += samples.length; events.push(`feed ${samples.length}`); await h.feedGate?.promise; segments.push(segment(segments.length, ` chunk${segments.length}`)); },
              async finish() {
                if (finished) throw new Error("finished twice");
                finished = true; events.push(`finish ${fed}`);
                await h.feedGate?.promise;
                return { text: segments.map(s => s.text).join("") + ` (${fed})`, segments, language: options.language ?? "en" };
              },
            };
            return run;
          },
          dispose() { events.push("dispose"); },
        };
        return loaded;
      },
      async vad() {
        events.push("vad load");
        const gate: VadGate = {
          detect: () => ({ segments: h.vadSegments.map(s => ({ start: s.start, end: s.end })) }),
          streamState: () => ({ h: new Float32Array(0), c: new Float32Array(0), context: null }) as never,
          probsStreaming: samples => Float32Array.from({ length: Math.ceil(samples.length / 512) }, () => h.vadSegments.length ? 0.9 : 0.1),
          speechTimestamps: (probs, length) => probs.some(p => p >= 0.5) ? [{ start: 0, end: length }] : [],
          dispose: () => { events.push("vad dispose"); },
        };
        return gate;
      },
      async decodeAudio(bytes) { events.push(`decode ${bytes.length}`); return new Float32Array(bytes.length); },
    },
  };
  return h;
}

function service(h: Harness, options: Partial<ConstructorParameters<typeof TranscriptionService>[0]> = {}) {
  return new TranscriptionService({ modelDir: "/whisper", modelId: "org/whisper", runtime: h.runtime, log() {},
    timers: { setTimeout: (fn, ms) => { const id = h.timers.scheduled.length + 1 + Math.random(); h.timers.scheduled.push({ id, ms, fn }); return id; },
      clearTimeout: handle => { const at = h.timers.scheduled.findIndex(t => t.id === handle); if (at >= 0) h.timers.scheduled.splice(at, 1); } },
    now: () => h.clock.now, ...options });
}
const take = new Float32Array(16_000);

test("the default policy loads on the first take, reports load_ms only then, and releases right after every take", async () => {
  const h = harness(), whisper = service(h);
  expect(whisper.resident).toBe(false);
  const first = await whisper.transcribe(take, { language: "en" });
  expect(first.timings).toEqual({ load_ms: 250, transcribe_ms: 40, total_ms: 290 });
  expect(first.result.text).toBe(" hello"); expect(first.durationSeconds).toBe(1); expect(first.modelId).toBe("org/whisper");
  expect(whisper.resident).toBe(false);
  expect(whisper.stats).toEqual({ resident: false, loads: 1, unloads: 1, requests: 1, last_load_ms: 250, idle_unload_sec: 0 });
  const second = await whisper.transcribe(new Uint8Array(32_000));
  expect(second.timings.load_ms).toBe(250);
  expect(h.events).toEqual(["load /whisper", "transcribe 16000", "dispose", "decode 32000", "load /whisper", "transcribe 32000", "dispose"]);
  expect(h.timers.scheduled).toEqual([]);
  // Decoding options keep main's defaults and forward the request's choices.
  expect(h.transcribed[0]).toMatchObject({ task: "transcribe", language: "en", initialPrompt: null, beamSize: null,
    conditionOnPreviousText: true, withoutTimestamps: false, wordTimestamps: false, fast: true, audioCtx: null });
  expect(h.transcribed[1]!.language).toBeNull();
});

test("an idle timeout keeps the weights for that long; a new take re-arms it and unload, the timer, and close cancel it", async () => {
  const h = harness(), whisper = service(h, { idleUnloadSec: 5 });
  await whisper.transcribe(take);
  expect(whisper.resident).toBe(true);
  expect(h.timers.scheduled.map(t => t.ms)).toEqual([5000]);
  const warm = await whisper.transcribe(take);
  expect(warm.timings.load_ms).toBe(0);
  expect(h.timers.scheduled.map(t => t.ms)).toEqual([5000]);
  expect(h.events.filter(e => e.startsWith("load"))).toHaveLength(1);
  h.timers.fire();
  expect(whisper.resident).toBe(false); expect(whisper.stats.unloads).toBe(1);
  await whisper.transcribe(take);
  expect(whisper.unload()).toBe(true);
  expect(h.timers.scheduled).toEqual([]);
  expect(whisper.unload()).toBe(false);
  await whisper.transcribe(take);
  expect(h.timers.scheduled).toHaveLength(1);
  whisper.close(); whisper.close();
  expect(h.timers.scheduled).toEqual([]);
  expect(whisper.resident).toBe(false);
  expect(h.events.filter(e => e === "dispose")).toHaveLength(3);
  await expect(whisper.transcribe(take)).rejects.toThrow("transcription service is closed");
});

test("resident pins the weights across takes while an explicit unload still releases them", async () => {
  const h = harness(), whisper = service(h, { resident: true, idleUnloadSec: 5 });
  await whisper.transcribe(take); await whisper.transcribe(take);
  expect(whisper.resident).toBe(true);
  expect(h.timers.scheduled).toEqual([]);
  expect(whisper.stats).toMatchObject({ loads: 1, unloads: 0, requests: 2, idle_unload_sec: null });
  expect(whisper.unload()).toBe(true);
  expect(whisper.resident).toBe(false);
  await whisper.transcribe(take);
  expect(whisper.stats.loads).toBe(2);
  expect(whisper.resident).toBe(true);
  whisper.close();
});

test("takes serialize FIFO, share one load, run inside the host's exclusive wrapper, and refuse unload while active", async () => {
  const h = harness();
  let exclusive = 0;
  const whisper = service(h, { idleUnloadSec: 5, exclusive: async (fn, signal) => { exclusive++; signal?.throwIfAborted(); return fn(); } });
  const gate = Promise.withResolvers<void>();
  h.gate = gate; h.loadGate = gate;
  const controller = new AbortController();
  const first = whisper.transcribe(take, { signal: controller.signal });
  const second = whisper.transcribe(new Float32Array(32_000));
  await Bun.sleep(1);
  expect(h.events).toEqual(["load /whisper"]);
  expect(whisper.unload()).toBe(false);
  gate.resolve(); h.gate = null; h.loadGate = null;
  await Promise.all([first, second]);
  expect(h.events).toEqual(["load /whisper", "transcribe 16000", "transcribe 32000"]);
  expect(exclusive).toBe(2);
  expect(whisper.stats).toMatchObject({ loads: 1, requests: 2 });
  // A failed take does not block the queue behind it.
  await expect(whisper.transcribe(new Float32Array(10))).rejects.toMatchObject({ status: 400 });
  expect((await whisper.transcribe(take)).result.text).toBe(" hello");
  whisper.close();
});

test("closing during a load releases the weights on arrival and the waiting take fails cleanly", async () => {
  const h = harness(), whisper = service(h);
  const gate = Promise.withResolvers<void>();
  h.loadGate = gate;
  const pending = whisper.transcribe(take);
  await Bun.sleep(1);
  whisper.close();
  gate.resolve();
  await expect(pending).rejects.toBeInstanceOf(TranscriptionError);
  expect(h.events).toEqual(["load /whisper", "dispose"]);
  expect(whisper.resident).toBe(false);
});

test("sessions feed windows in order under the exclusive queue, finish returns the whole take, and the idle policy applies after release", async () => {
  const h = harness();
  const exclusive: string[] = [];
  const whisper = service(h, { exclusive: async fn => { exclusive.push("lock"); return fn(); } });
  const session = await whisper.createSession({ language: "de", vocabulary: ["Sotto", "Metal"] });
  expect(whisper.resident).toBe(true); expect(whisper.sessionCount).toBe(1);
  expect(session.vocabulary).toEqual({ included: ["Sotto", "Metal"], omitted: [], token_count: 2, token_budget: 3 });
  expect(whisper.unload()).toBe(false);
  const a = session.append(new Float32Array(1000)), b = session.append(new Float32Array(2000));
  expect((await a).segments.map(s => s.text)).toEqual([" chunk0"]);
  expect((await b).segments.map(s => s.text)).toEqual([" chunk0", " chunk1"]);
  expect(session.samples).toBe(3000); expect(session.durationSeconds).toBeCloseTo(3000 / 16_000);
  const outcome = await session.finish();
  expect(outcome.result.text).toBe(" chunk0 chunk1 (3000)");
  expect(outcome.result.language).toBe("de");
  expect(outcome.vocabulary).toEqual(session.vocabulary);
  expect(exclusive).toEqual(["lock", "lock", "lock"]);
  expect(session.closed).toBe(true); expect(whisper.session(session.id)).toBeNull();
  expect(whisper.stats).toMatchObject({ requests: 1, unloads: 1 });
  expect(whisper.resident).toBe(false);
  expect(() => session.append(new Float32Array(1))).toThrow(TranscriptionError);
  await expect(session.finish()).rejects.toMatchObject({ status: 409 });
  expect(h.events).toEqual(["load /whisper", "feed 1000", "feed 2000", "finish 3000", "dispose"]);
});

test("a deleted session releases the service, at most 64 stay open, and close discards open sessions", async () => {
  const h = harness(), whisper = service(h, { resident: true });
  const sessions = [];
  for (let i = 0; i < 64; i++) sessions.push(await whisper.createSession());
  await expect(whisper.createSession()).rejects.toMatchObject({ status: 429 });
  sessions[0]!.close();
  expect(whisper.sessionCount).toBe(63);
  const replacement = await whisper.createSession();
  expect(whisper.session(replacement.id)).toBe(replacement);
  whisper.close();
  expect(whisper.sessionCount).toBe(0);
  expect(replacement.closed).toBe(true);
  expect(h.events.filter(e => e === "dispose")).toHaveLength(1);
});

test("a streaming session with VAD stays silent until speech and finishes empty without speech", async () => {
  const h = harness(), whisper = service(h, { resident: true });
  const silent = await whisper.createSession({ vad: {} });
  await silent.append(new Float32Array(1024));
  const outcome = await silent.finish();
  expect(outcome.result.text).toBe(""); expect(outcome.vad).toEqual({ speech: false, segments: [] });
  expect(h.events).toEqual(["load /whisper", "vad load", "silent 1024"]);
  h.vadSegments = [{ start: 0, end: 1024 }];
  const voiced = await whisper.createSession({ vad: {} });
  expect((await voiced.append(new Float32Array(1024))).speech).toBe(true);
  expect((await voiced.finish()).vad?.speech).toBe(true);
  expect(h.events.slice(3)).toEqual(["feed 1024", "finish 1024"]);
  whisper.close();
  expect(h.events.at(-2)).toBe("dispose"); expect(h.events.at(-1)).toBe("vad dispose");
});

test("the VAD gate skips Whisper on silence and trims to the speech span with clip-relative timestamps", async () => {
  const h = harness(), whisper = service(h);
  const quiet = await whisper.transcribe(take, { vad: {} });
  expect(quiet.result.text).toBe(""); expect(quiet.vad).toEqual({ speech: false, segments: [] });
  expect(quiet.timings).toMatchObject({ load_ms: 0, transcribe_ms: 0 });
  expect(h.events).toEqual(["vad load"]);
  h.vadSegments = [{ start: 16_000, end: 24_000 }];
  const trimmed = await whisper.transcribe(new Float32Array(48_000), { vad: { trim: true } });
  expect(trimmed.vad).toEqual({ speech: true, segments: [{ start: 1, end: 1.5 }], trimmed: { start: 0.5, end: 2 } });
  expect(trimmed.result.segments[0]).toMatchObject({ start: 0.5, end: 1.5 });
  expect(trimmed.durationSeconds).toBe(1.5);
  expect(h.events).toEqual(["vad load", "load /whisper", "transcribe 24000", "dispose"]);
  whisper.close();
});

test("vocabulary hints fit whole terms into the prompt budget in order after the prompt", () => {
  const encode = (text: string) => text.split(",").map(part => part.trim()).filter(Boolean).map((_, index) => index);
  expect(TranscriptionService.fitVocabulary(encode, 3, "", ["a", "b", "c", "d", "e"]))
    .toEqual({ prompt: "a, b, c", usage: { included: ["a", "b", "c"], omitted: ["d", "e"], token_count: 3, token_budget: 3 } });
  expect(TranscriptionService.fitVocabulary(encode, 3, " Sotto ", ["x", "y", "z"]))
    .toEqual({ prompt: "Sotto, x, y", usage: { included: ["x", "y"], omitted: ["z"], token_count: 3, token_budget: 3 } });
  expect(TranscriptionService.fitVocabulary(encode, 3, "", []).usage).toEqual({ included: [], omitted: [], token_count: 0, token_budget: 3 });
});

test("a session reserves the weights before its VAD gate resolves, so unload is refused until the session releases", async () => {
  const h = harness();
  let releaseVad!: () => void;
  const pending = new Promise<void>(resolve => { releaseVad = resolve; });
  const whisper = service(h, { runtime: { ...h.runtime, vad: async path => { await pending; return h.runtime.vad(path); } } });
  const creating = whisper.createSession({ vad: {} });
  await Bun.sleep(0);
  expect(whisper.resident).toBe(true);
  expect(whisper.unload()).toBe(false);
  releaseVad();
  const session = await creating;
  expect(whisper.sessionCount).toBe(1); expect(whisper.resident).toBe(true);
  h.vadSegments = [{ start: 0, end: 16_000 }];
  expect((await session.append(take)).speech).toBe(true);
  session.close();
  expect(whisper.sessionCount).toBe(0); expect(whisper.resident).toBe(false);
  expect(h.events).toEqual(["load /whisper", "vad load", "feed 16000", "dispose"]);
});

test("close between a cached VAD gate and registration rejects the session and registers nothing", async () => {
  const h = harness();
  const whisper = service(h);
  await whisper.ensureLoaded(); await whisper.vad();
  const creating = whisper.createSession({ vad: {} });
  queueMicrotask(() => whisper.close());
  await expect(creating).rejects.toMatchObject({ status: 503 });
  expect(whisper.sessionCount).toBe(0); expect(whisper.resident).toBe(false);
  expect(h.events.filter(event => event === "dispose")).toEqual(["dispose"]);
  expect(h.events.filter(event => event === "vad dispose")).toEqual(["vad dispose"]);
  await expect(whisper.createSession()).rejects.toMatchObject({ status: 503 });
});

test("a session whose run fails to start releases its reservation and the idle policy applies", async () => {
  const h = harness();
  const whisper = service(h);
  const { loaded } = await whisper.ensureLoaded();
  const start = loaded.start;
  loaded.start = () => { throw new Error("no decoder"); };
  await expect(whisper.createSession()).rejects.toThrow("no decoder");
  expect(whisper.sessionCount).toBe(0); expect(whisper.resident).toBe(false);
  loaded.start = start;
  await expect(whisper.transcribe(take)).resolves.toMatchObject({ result: { text: " hello" } });
});

test("deleting a session during an in-flight feed joins the feed before the weights are released", async () => {
  const h = harness();
  const whisper = service(h);
  const session = await whisper.createSession();
  let release!: () => void;
  h.feedGate = { promise: new Promise<void>(resolve => { release = resolve; }) };
  const fed = session.append(take).catch(error => error);
  await Bun.sleep(0);
  expect(h.events).toEqual(["load /whisper", "feed 16000"]);
  let closed = false;
  const closing = session.close().then(() => { closed = true; });
  await Bun.sleep(0);
  expect(closed).toBe(false);
  expect(whisper.sessionCount).toBe(1); expect(whisper.resident).toBe(true);
  expect(whisper.unload()).toBe(false);
  expect(() => session.append(take)).toThrow(TranscriptionError);
  release();
  await closing; await fed;
  expect(whisper.sessionCount).toBe(0); expect(whisper.resident).toBe(false);
  expect(h.events).toEqual(["load /whisper", "feed 16000", "dispose"]);
  await session.close();
});

test("deleting a session while it finishes waits for the finish, which still returns its result", async () => {
  const h = harness();
  const whisper = service(h);
  const session = await whisper.createSession();
  await session.append(new Float32Array(1000));
  let release!: () => void;
  h.feedGate = { promise: new Promise<void>(resolve => { release = resolve; }) };
  const finishing = session.finish();
  await Bun.sleep(0);
  let closed = false;
  const closing = session.close().then(() => { closed = true; });
  await Bun.sleep(0);
  expect(closed).toBe(false); expect(whisper.resident).toBe(true);
  release();
  expect((await finishing).result.text).toBe(" chunk0 (1000)");
  await closing;
  expect(whisper.sessionCount).toBe(0); expect(whisper.resident).toBe(false);
  expect(h.events).toEqual(["load /whisper", "feed 1000", "finish 1000", "dispose"]);
});

test("closing the service stops admission, skips pending session work, joins the active take, then releases once", async () => {
  const h = harness();
  const whisper = service(h, { idleUnloadSec: 60 });
  let releaseTake!: () => void;
  h.gate = { promise: new Promise<void>(resolve => { releaseTake = resolve; }) };
  const outcome = whisper.transcribe(take);
  const session = await whisper.createSession();
  const fed = session.append(take).catch(error => error);
  await Bun.sleep(0);
  expect(h.events).toEqual(["load /whisper", "transcribe 16000"]);
  let closed = false;
  const closing = whisper.close().then(() => { closed = true; });
  await Bun.sleep(0);
  expect(closed).toBe(false);
  expect(h.events).not.toContain("dispose");
  await expect(whisper.transcribe(take)).rejects.toMatchObject({ status: 503 });
  await expect(whisper.createSession()).rejects.toMatchObject({ status: 503 });
  releaseTake();
  expect((await outcome).result.text).toBe(" hello");
  expect(await fed).toBeInstanceOf(TranscriptionError);
  await closing;
  expect(closed).toBe(true);
  expect(whisper.sessionCount).toBe(0); expect(whisper.resident).toBe(false);
  expect(h.events).toEqual(["load /whisper", "transcribe 16000", "dispose"]);
  await whisper.close();
  expect(h.events.filter(event => event === "dispose")).toEqual(["dispose"]);
});

test("a session creation aborted by its request after the load releases the reservation and registers nothing", async () => {
  const h = harness();
  let releaseVad!: () => void;
  const pending = new Promise<void>(resolve => { releaseVad = resolve; });
  const whisper = service(h, { runtime: { ...h.runtime, vad: async path => { await pending; return h.runtime.vad(path); } } });
  const request = new AbortController();
  const creating = whisper.createSession({ vad: {}, signal: request.signal });
  await Bun.sleep(0);
  expect(whisper.resident).toBe(true);
  request.abort(new Error("client gone"));
  releaseVad();
  await expect(creating).rejects.toThrow("client gone");
  expect(whisper.sessionCount).toBe(0); expect(whisper.resident).toBe(false);
  expect(whisper.unload()).toBe(false);
  expect(h.events).toEqual(["load /whisper", "vad load", "dispose"]);
});
