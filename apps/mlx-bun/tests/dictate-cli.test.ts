// Model-free: argument policy (--hotkey's optional value), the live loop over
// a fake capture source that yields generated PCM through the real service
// with a fake runtime (takes, 250 ms chunked feeding, the VAD gate,
// residency), Enter and hotkey modes, --copy/--type delivery, the --server
// backend, cancellation that joins the capture before the weights release,
// and the spawned CLI's help with native MLX blocked.
import { expect, test } from "bun:test";
import { resolve } from "node:path";
import type { WhisperSegment } from "@mlx-bun/inference/transcription";
import type { TranscriptionRuntime, VadGate, WhisperRuntime } from "../src/engine/transcription-service";
import type { MicCapture, MicEvent } from "../src/engine/mic-capture";
import { help } from "../src/cli/args";
import { parseDictateArgs, runDictate, type DictateDependencies } from "../src/cli/dictate";

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
const parse = (...args: string[]) => parseDictateArgs(args);
const plain = (text: string) => text.replace(/\x1b\[[0-9;]*m/g, "");
const segment = (id: number, text: string): WhisperSegment =>
  ({ id, seek: 0, start: id, end: id + 1, text, tokens: [id], temperature: 0, avgLogprob: -0.1, compressionRatio: 1, noSpeechProb: 0 });
const ready = (info: string): MicEvent => ({ kind: "ready", info });
const key = (down: boolean): MicEvent => ({ kind: "hotkey", down });
const pcm = (samples: number): MicEvent => ({ kind: "pcm", samples: new Float32Array(samples).fill(0.1) });
async function waitFor(predicate: () => boolean, timeoutMs = 5000): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (!predicate()) { if (Date.now() > deadline) throw new Error("timed out waiting"); await Bun.sleep(1); }
}

/** An async queue: the test pushes items (mic events, stdin lines) and closes it. */
function channel<T>() {
  const queue: T[] = [];
  let wake: (() => void) | null = null, closed = false;
  const notify = () => { const w = wake; wake = null; w?.(); };
  return {
    push(item: T) { queue.push(item); notify(); },
    close() { closed = true; notify(); },
    async *[Symbol.asyncIterator]() {
      for (;;) {
        if (queue.length) { yield queue.shift()!; continue; }
        if (closed) return;
        await new Promise<void>(r => { wake = r; });
      }
    },
  };
}

/** A capture source over a channel; stop records "stop", then "joined" once the fake process is gone. */
function fakeCapture(events: string[]) {
  const feed = channel<MicEvent>(), exited = Promise.withResolvers<number>();
  let stopping: Promise<void> | undefined;
  const capture: MicCapture = {
    events: feed, exited: exited.promise,
    stop: () => stopping ??= (async () => { events.push("stop"); await Bun.sleep(2); feed.close(); exited.resolve(0); events.push("joined"); })(),
  };
  return { capture, feed };
}

function harness(input: { speech?: boolean } = {}) {
  const events: string[] = [], writes: string[] = [], notes: string[] = [];
  const runtime: TranscriptionRuntime = {
    async load(dir) {
      events.push(`load ${dir}`);
      const loaded: WhisperRuntime = {
        promptTokenBudget: 223, encode: text => text.split(/[\s,]+/).filter(Boolean).map((_, i) => i),
        async transcribe() { throw new Error("dictation streams"); },
        start(options) {
          let fed = 0;
          const segments: WhisperSegment[] = [];
          return {
            get segments() { return segments; },
            feedSilent(samples) { fed += samples.length; events.push(`silent ${samples.length}`); },
            async feed(samples) { fed += samples.length; events.push(`feed ${samples.length}`); segments.push(segment(segments.length, ` chunk${segments.length}`)); },
            async finish() { events.push(`finish ${fed}`); return { text: segments.map(s => s.text).join("") + ` (${fed})`, segments, language: options.language ?? "en" }; },
          };
        },
        dispose() { events.push("dispose"); },
      };
      return loaded;
    },
    async vad() {
      events.push("vad load");
      const gate: VadGate = {
        detect: () => ({ segments: [] }), streamState: () => ({}) as never,
        probsStreaming: samples => Float32Array.from({ length: Math.ceil(samples.length / 512) }, () => (input.speech ? 0.9 : 0.1)),
        speechTimestamps: (probs, length) => (probs.some(p => p >= 0.5) ? [{ start: 0, end: length }] : []),
        dispose: () => { events.push("vad dispose"); },
      };
      return gate;
    },
    async decodeAudio() { throw new Error("dictation never decodes"); },
  };
  let clock = 0;
  const deps = (capture: MicCapture, keys = channel<string>()): Partial<DictateDependencies> => ({
    resolveModel: async query => { events.push(`resolve ${query ?? "(default)"}`); return { path: "/whisper", repoId: "org/whisper" }; },
    runtime,
    capture: async options => { events.push(`capture hotkey=${options.hotkey}`); return capture; },
    fetch: async () => { throw new Error("no server in this test"); },
    async *lines(signal) {
      signal.addEventListener("abort", () => keys.close(), { once: true });
      for await (const line of keys) yield line;
    },
    copy: async text => { events.push(`copy ${text}`); },
    type: async text => { events.push(`type ${text}`); },
    sleep: async ms => { events.push(`sleep ${ms}`); },
    write: text => { writes.push(text); events.push(`out ${plain(text).trim()}`); },
    note: text => { notes.push(text); },
    now: () => (clock += 10),
  });
  return { events, writes, notes, deps, text: () => plain(notes.join("")) };
}

test("dictate arguments keep main's flags, the optional --hotkey value, and the typing-delay default", () => {
  expect(parse()).toEqual({ query: undefined, server: undefined, hotkey: null, language: "en", beamSize: null, prompt: undefined,
    vocabulary: undefined, vad: true, idleUnloadSec: 30, resident: false, copy: false, type: false, typeDelaySec: 1 });
  expect(parse("--hotkey")).toMatchObject({ hotkey: 61, typeDelaySec: 0 });
  expect(parse("--hotkey", "55")).toMatchObject({ hotkey: 55 });
  expect(parse("--hotkey=55", "--copy")).toMatchObject({ hotkey: 55, copy: true });
  expect(parse("--hotkey", "--copy")).toMatchObject({ hotkey: 61, copy: true });
  expect(parse("--hotkey", "abc")).toMatchObject({ hotkey: 61, query: undefined }); // main consumed the token as the keycode
  expect(parse("--hotkey", "0")).toMatchObject({ hotkey: 61 });
  expect(parse("--hotkey", "--type-delay", "2")).toMatchObject({ hotkey: 61, typeDelaySec: 2 });
  expect(parse("turbo", "--model", "/dir", "--query", "ignored")).toMatchObject({ query: "/dir" });
  expect(parse("turbo")).toMatchObject({ query: "turbo" });
  expect(parse("--query", "q")).toMatchObject({ query: "q" });
  expect(parse("--server", "http://localhost:8090/", "--language", "auto", "--beam-size", "5", "--prompt", "p", "--vocabulary", " Sotto, SwiftUI ,,Metal ",
    "--no-vad", "--idle-unload", "0", "--resident", "--copy", "--type", "--type-delay", "0"))
    .toEqual({ query: undefined, server: "http://localhost:8090", hotkey: null, language: null, beamSize: 5, prompt: "p",
      vocabulary: ["Sotto", "SwiftUI", "Metal"], vad: false, idleUnloadSec: 0, resident: true, copy: true, type: true, typeDelaySec: 0 });
  expect(() => parse("a", "b")).toThrow("Too many arguments");
  for (const args of [["--idle-unload", "x"], ["--beam-size", "0"], ["--type-delay", ""]]) expect(() => parse(...args)).toThrow("invalid --");
  expect(help("dictate")).toContain("--hotkey");
  expect(help()).toContain("dictate");
});

test("hotkey takes feed the session in 250 ms chunks, print each transcript in order, and the signal joins the capture before the weights release", async () => {
  const h = harness({ speech: true }), mic = fakeCapture(h.events), abort = new AbortController();
  for (const event of [ready("rate=16000 input=48000Hz/1ch"), key(true), pcm(1000), pcm(1000), pcm(1000), pcm(1000), pcm(1000), key(false),
    key(true), pcm(1024), key(false)]) mic.feed.push(event);
  const run = runDictate(parse("--hotkey", "--resident"), h.deps(mic.capture), abort.signal);
  await waitFor(() => h.writes.length === 2);
  abort.abort(new Error("dictation cancelled"));
  await run; // main exited 0 on Ctrl-C
  expect(h.writes).toEqual(["chunk0 chunk1 (5000)\n", "chunk0 (1024)\n"]);
  expect(h.events).toEqual(["resolve (default)", "load /whisper", "vad load", "capture hotkey=61",
    "feed 4000", "feed 1000", "finish 5000", "out chunk0 chunk1 (5000)",
    "feed 1024", "finish 1024", "out chunk0 (1024)",
    "stop", "joined", "dispose", "vad dispose"]);
  expect(h.text()).toBe("loading whisper… ready\nhold key 61 to talk · Ctrl-C quits · mic rate=16000 input=48000Hz/1ch\n" +
    "● recording (release to stop)\ntranscribing… 10 ms\n● recording (release to stop)\ntranscribing… 10 ms\n");
});

test("Enter toggles takes, silence prints (no speech) and releases the weights per --idle-unload 0, and q quits after joining the capture", async () => {
  const h = harness(), mic = fakeCapture(h.events), keys = channel<string>();
  mic.feed.push(ready("rate=16000"));
  const run = runDictate(parse("--idle-unload", "0"), h.deps(mic.capture, keys));
  await waitFor(() => h.text().includes("Enter: start/stop a take · q: quit"));
  keys.push("");
  await waitFor(() => h.text().includes("● recording (Enter to stop)"));
  mic.feed.push(pcm(4096));
  await waitFor(() => h.events.includes("silent 4096"));
  keys.push("");
  await waitFor(() => h.writes.length === 1);
  expect(h.writes).toEqual(["(no speech)\n"]);
  keys.push("q\r");
  await run;
  expect(h.events).toEqual(["resolve (default)", "load /whisper", "vad load", "capture hotkey=null", "silent 4096", "dispose", "out (no speech)",
    "stop", "joined", "vad dispose"]);
  expect(h.text()).toBe("loading whisper… ready\nEnter: start/stop a take · q: quit\n● recording (Enter to stop)\ntranscribing… 10 ms\n");
});

test("cancellation mid-take drops the take, joins the capture, and releases the weights without output", async () => {
  const h = harness({ speech: true }), mic = fakeCapture(h.events), abort = new AbortController();
  for (const event of [ready(""), key(true), pcm(4000)]) mic.feed.push(event);
  const run = runDictate(parse("--hotkey", "--resident"), h.deps(mic.capture), abort.signal);
  await waitFor(() => h.events.includes("feed 4000"));
  abort.abort(new Error("dictation cancelled"));
  await run;
  expect(h.writes).toEqual([]);
  expect(h.events.slice(-5)).toEqual(["feed 4000", "stop", "joined", "dispose", "vad dispose"]);
});

test("a signal before capture starts rejects without loading; a sidecar error ends dictation with its message after joining", async () => {
  const early = harness(), abort = new AbortController();
  abort.abort(new Error("dictation cancelled"));
  await expect(runDictate(parse(), early.deps(fakeCapture(early.events).capture), abort.signal)).rejects.toThrow("dictation cancelled");
  expect(early.events).toEqual([]);
  const h = harness(), mic = fakeCapture(h.events);
  mic.feed.push({ kind: "error", message: "audio engine failed: no input device" });
  await expect(runDictate(parse("--hotkey"), h.deps(mic.capture))).rejects.toThrow("audio engine failed: no input device");
  expect(h.events).toEqual(["resolve (default)", "load /whisper", "vad load", "capture hotkey=61", "stop", "joined", "dispose", "vad dispose"]);
});

test("--copy and --type deliver after printing; typing waits for the delay and reports Accessibility failures; --no-vad skips the gate", async () => {
  const h = harness(), mic = fakeCapture(h.events);
  for (const event of [key(true), pcm(4000), key(false)]) mic.feed.push(event);
  const run = runDictate(parse("--hotkey", "--copy", "--type", "--type-delay", "2", "--no-vad"), h.deps(mic.capture));
  await waitFor(() => h.events.includes("type chunk0 (4000)"));
  await mic.capture.stop(); // the sidecar going away ends the loop
  await run;
  expect(h.events).toEqual(["resolve (default)", "load /whisper", "capture hotkey=61", "feed 4000", "finish 4000",
    "out chunk0 (4000)", "copy chunk0 (4000)", "sleep 2000", "type chunk0 (4000)", "stop", "joined", "dispose"]);
  const failing = harness(), failingMic = fakeCapture(failing.events);
  for (const event of [key(true), pcm(4000), key(false)]) failingMic.feed.push(event);
  const failingRun = runDictate(parse("--hotkey", "--type", "--no-vad"),
    { ...failing.deps(failingMic.capture), type: async () => { throw new Error("osascript: not allowed"); } });
  await waitFor(() => failing.text().includes("typing failed"));
  await failingMic.capture.stop();
  await failingRun;
  expect(failing.text()).toContain("typing failed (grant Accessibility to your terminal): osascript: not allowed\n");
  expect(failing.events.filter(e => e.startsWith("sleep"))).toEqual([]);
});

test("--server drives a running server's sessions instead of loading a model", async () => {
  const h = harness(), mic = fakeCapture(h.events), requests: { url: string; init?: RequestInit }[] = [];
  const fetchFake = async (url: string, init?: RequestInit) => {
    requests.push({ url, init });
    if (url.endsWith("/sessions")) return Response.json({ id: "s1" });
    if (url.endsWith("/finish")) return Response.json({ text: " served text " });
    return new Response("ok");
  };
  for (const event of [key(true), pcm(4000), pcm(100), key(false)]) mic.feed.push(event);
  const run = runDictate(parse("--hotkey", "--server", "http://localhost:8090/", "--vocabulary", "Sotto,Metal", "--language", "auto",
    "--beam-size", "2", "--prompt", "p"), { ...h.deps(mic.capture), fetch: fetchFake });
  await waitFor(() => h.writes.length === 1);
  await mic.capture.stop();
  await run;
  expect(h.writes).toEqual(["served text\n"]);
  expect(h.events).toEqual(["capture hotkey=61", "out served text", "stop", "joined"]);
  expect(requests.map(r => r.url)).toEqual(["http://localhost:8090/v1/audio/sessions", "http://localhost:8090/v1/audio/sessions/s1/audio",
    "http://localhost:8090/v1/audio/sessions/s1/audio", "http://localhost:8090/v1/audio/sessions/s1/finish", "http://localhost:8090/v1/audio/sessions/s1"]);
  expect(JSON.parse(requests[0]!.init!.body as string)).toEqual({ language: null, beam_size: 2, temperature: 0, prompt: "p",
    vocabulary: ["Sotto", "Metal"], vad: true, vad_min_speech_ms: 120 });
  expect((requests[1]!.init!.headers as Record<string, string>)["content-type"]).toBe("audio/pcm;rate=16000");
  expect((requests[1]!.init!.body as Uint8Array).byteLength).toBe(4000 * 4);
  expect((requests[2]!.init!.body as Uint8Array).byteLength).toBe(100 * 4);
  expect(requests[3]!.init).toMatchObject({ method: "POST", signal: expect.any(AbortSignal) });
  expect(requests[4]!.init).toMatchObject({ method: "DELETE", signal: expect.any(AbortSignal) });
  // A failed session create ends dictation with the server's answer.
  const refused = harness(), refusedMic = fakeCapture(refused.events);
  refusedMic.feed.push(key(true));
  await expect(runDictate(parse("--hotkey", "--server", "http://localhost:8090"),
    { ...refused.deps(refusedMic.capture), fetch: async () => new Response("busy", { status: 429 }) })).rejects.toThrow("session create failed: 429 busy");
  expect(refused.events.slice(-2)).toEqual(["stop", "joined"]);
});

async function cli(...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, ...args], {
    env: { ...process.env, HF_HUB_CACHE: "/nonexistent/hub", HF_HUB_OFFLINE: "1", NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" },
    stdout: "pipe", stderr: "pipe",
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("the spawned CLI answers dictate help and argument errors with native MLX blocked", async () => {
  const helpRun = await cli("dictate", "--help");
  expect(helpRun.code).toBe(0); expect(helpRun.err).toBe("");
  expect(helpRun.out).toContain("Usage: mlx-bun dictate [query] [options]");
  for (const flag of ["--server", "--hotkey", "--copy", "--type", "--idle-unload", "--no-vad"]) expect(helpRun.out).toContain(flag);
  const unknown = await cli("dictate", "--hotkey", "--bogus");
  expect(unknown.code).toBe(1); expect(unknown.out).toBe(""); expect(unknown.err).toContain("Unknown option '--bogus'");
  const invalid = await cli("dictate", "--idle-unload", "x");
  expect(invalid).toEqual({ out: "", err: "invalid --idle-unload: x\n", code: 1 });
});

for (const stage of ["create", "feed", "finish"] as const) {
  test(`cancellation joins a pending remote ${stage} and releases the take without delivery`, async () => {
    const h = harness(), mic = fakeCapture(h.events), keys = channel<string>();
    const abort = new AbortController(), entered = Promise.withResolvers<void>();
    let active = 0, cancelled = false, deleted = false;
    const fetchFake = async (url: string, init?: RequestInit): Promise<Response> => {
      if (init?.method === "DELETE") {
        expect(init.signal?.aborted).toBe(false); deleted = true; return Response.json({ ok: true });
      }
      const current = url.endsWith("/sessions") ? "create" : url.endsWith("/audio") ? "feed" : "finish";
      if (current !== stage) return Response.json(current === "create" ? { id: "s1" } : { text: "unexpected delivery" });
      expect(init?.signal).toBeInstanceOf(AbortSignal);
      active++; entered.resolve();
      return new Promise<Response>((_resolve, reject) => {
        init!.signal!.addEventListener("abort", () => {
          active--; cancelled = true; reject(init!.signal!.reason);
        }, { once: true });
      });
    };
    const run = runDictate(parse("--server", "http://localhost:8090"),
      { ...h.deps(mic.capture, keys), fetch: fetchFake }, abort.signal);
    run.catch(() => {});
    try {
      keys.push("");
      if (stage !== "create") {
        await waitFor(() => h.text().includes("recording"));
        mic.feed.push(pcm(4000));
        if (stage === "finish") keys.push("");
      }
      await entered.promise;
      abort.abort(new Error("client cancelled"));
      await run;
      expect(cancelled).toBe(true); expect(active).toBe(0);
      expect(deleted).toBe(stage !== "create");
      expect(h.writes).toEqual([]);
      expect(h.events).toContain("joined");
    } finally { abort.abort(); keys.close(); await mic.capture.stop(); }
  });
}

test("cancellation during the typing delay never types after shutdown", async () => {
  const h = harness(), mic = fakeCapture(h.events), abort = new AbortController();
  const delaying = Promise.withResolvers<void>();
  for (const event of [key(true), pcm(4000), key(false)]) mic.feed.push(event);
  const run = runDictate(parse("--hotkey", "--type", "--type-delay", "10", "--no-vad"), {
    ...h.deps(mic.capture),
    sleep: async (_ms, signal) => {
      expect(signal).toBeInstanceOf(AbortSignal); delaying.resolve();
      await new Promise<void>((_resolve, reject) => signal!.addEventListener("abort", () => reject(signal!.reason), { once: true }));
    },
  }, abort.signal);
  run.catch(() => {});
  try {
    await delaying.promise; abort.abort(); await run;
    expect(h.events.filter(event => event.startsWith("type "))).toEqual([]);
    expect(h.events.indexOf("joined")).toBeLessThan(h.events.indexOf("dispose"));
    expect(h.text()).not.toContain("typing failed");
  } finally { abort.abort(); await mic.capture.stop(); }
});
