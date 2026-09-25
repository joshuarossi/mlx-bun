// Hold-to-talk voice input for the composer: microphone → 16 kHz float32
// (an AudioContext opened at 16 kHz lets the browser resample the mic) →
// 250 ms chunks streamed to /v1/audio/sessions/<id>/audio while the button
// is held → finish on release → transcript inserted at the caret. Works
// with ANY served chat model: transcription is the Whisper companion, not
// the chat model's audio input. Shown only when `ready.transcription` is
// true (composer.ts updateAttachHint).

import { $, toast } from "./shell";

const SAMPLE_RATE = 16_000;
const CHUNK_SECONDS = 0.25;

interface Take {
  id: string;
  ctx: AudioContext;
  stream: MediaStream;
  node: ScriptProcessorNode;
  pending: Float32Array[];
  pendingLen: number;
  sending: Promise<void>;
  failed: string | null;
}

let take: Take | null = null;
let starting = false;

async function postChunk(id: string, pcm: Float32Array): Promise<void> {
  const r = await fetch(`/v1/audio/sessions/${id}/audio`, {
    method: "POST", headers: { "content-type": "audio/pcm;rate=16000" },
    body: new Uint8Array(pcm.buffer.slice(pcm.byteOffset, pcm.byteOffset + pcm.byteLength) as ArrayBuffer),
  });
  if (!r.ok) throw new Error(`audio chunk rejected (${r.status})`);
}

function flush(t: Take): void {
  if (t.pendingLen === 0) return;
  const buf = new Float32Array(t.pendingLen);
  let o = 0;
  for (const p of t.pending) { buf.set(p, o); o += p.length; }
  t.pending = []; t.pendingLen = 0;
  t.sending = t.sending.then(() => postChunk(t.id, buf)).catch((e) => { t.failed = (e as Error).message; });
}

async function begin(btn: HTMLButtonElement): Promise<void> {
  if (take || starting) return;
  starting = true;
  btn.classList.add("busy");
  try {
    const r = await fetch("/v1/audio/sessions", {
      method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ vad: true, vad_min_speech_ms: 120, temperature: 0 }),
    });
    if (!r.ok) throw new Error(r.status === 503 ? "no Whisper model on this server" : `session failed (${r.status})`);
    const { id } = await r.json() as { id: string };
    const stream = await navigator.mediaDevices.getUserMedia({ audio: { channelCount: 1, echoCancellation: true, noiseSuppression: true } });
    const ctx = new AudioContext({ sampleRate: SAMPLE_RATE });
    const src = ctx.createMediaStreamSource(stream);
    // ScriptProcessorNode is deprecated but universally available and enough
    // for 16 kHz mono capture; an AudioWorklet needs a separately served file.
    const node = ctx.createScriptProcessor(4096, 1, 1);
    const t: Take = { id, ctx, stream, node, pending: [], pendingLen: 0, sending: Promise.resolve(), failed: null };
    node.onaudioprocess = (e) => {
      if (take !== t) return;
      const data = e.inputBuffer.getChannelData(0);
      t.pending.push(new Float32Array(data));
      t.pendingLen += data.length;
      if (t.pendingLen >= SAMPLE_RATE * CHUNK_SECONDS) flush(t);
    };
    src.connect(node);
    node.connect(ctx.destination); // required for onaudioprocess to fire in some browsers
    take = t;
    btn.classList.add("recording");
  } catch (e) {
    toast(`Voice input failed: ${(e as Error).message}`, "err");
  } finally {
    starting = false;
    btn.classList.remove("busy");
  }
}

async function end(btn: HTMLButtonElement, box: HTMLTextAreaElement): Promise<void> {
  const t = take;
  if (!t) return;
  take = null;
  btn.classList.remove("recording");
  btn.classList.add("busy");
  try {
    t.node.disconnect();
    for (const track of t.stream.getTracks()) track.stop();
    void t.ctx.close();
    flush(t);
    await t.sending;
    if (t.failed) throw new Error(t.failed);
    const r = await fetch(`/v1/audio/sessions/${t.id}/finish`, { method: "POST" });
    if (!r.ok) throw new Error(`transcription failed (${r.status})`);
    const body = await r.json() as { text: string; mlx_bun?: { vad?: { speech: boolean } } };
    const text = (body.text || "").trim();
    if (!text) { toast(body.mlx_bun?.vad?.speech === false ? "No speech detected" : "Nothing transcribed", ""); return; }
    insertAtCaret(box, text);
  } catch (e) {
    toast(`Voice input failed: ${(e as Error).message}`, "err");
  } finally {
    btn.classList.remove("busy");
  }
}

function insertAtCaret(box: HTMLTextAreaElement, text: string): void {
  const start = box.selectionStart ?? box.value.length;
  const endPos = box.selectionEnd ?? start;
  const before = box.value.slice(0, start);
  const after = box.value.slice(endPos);
  const lead = before.length && !/\s$/.test(before) ? " " : "";
  const trail = after.length && !/^\s/.test(after) ? " " : "";
  box.value = before + lead + text + trail + after;
  const caret = (before + lead + text + trail).length;
  box.setSelectionRange(caret, caret);
  box.dispatchEvent(new Event("input", { bubbles: true }));
  box.focus();
}

/** Wire hold-to-talk on `btn`: pointer hold, or Space/Enter held while focused. */
export function initVoiceInput(btn: HTMLButtonElement, box: HTMLTextAreaElement): void {
  if (!btn) return;
  if (!navigator.mediaDevices?.getUserMedia) { btn.title = "Microphone capture needs a secure context (https or localhost)"; }
  btn.addEventListener("pointerdown", (e) => { e.preventDefault(); btn.setPointerCapture(e.pointerId); void begin(btn); });
  const release = () => { void end(btn, box); };
  btn.addEventListener("pointerup", release);
  btn.addEventListener("pointercancel", release);
  btn.addEventListener("lostpointercapture", release);
  let keyHeld = false;
  btn.addEventListener("keydown", (e) => {
    if ((e.key === " " || e.key === "Enter") && !keyHeld) { e.preventDefault(); keyHeld = true; void begin(btn); }
  });
  btn.addEventListener("keyup", (e) => {
    if ((e.key === " " || e.key === "Enter") && keyHeld) { e.preventDefault(); keyHeld = false; release(); }
  });
  btn.addEventListener("blur", () => { if (keyHeld) { keyHeld = false; release(); } });
  // expose for tests / the palette
  ($ as unknown as { voice?: unknown }).voice = { begin: () => begin(btn), end: () => end(btn, box) };
}
