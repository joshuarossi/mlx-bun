// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// The composer's non-thread surface: attachments (files + images), the
// sampling popover (full parameter set incl. Advanced), the LoRA adapter
// selector, the reasoning-toggle presentation, and the perf strip (tok/s,
// TTFT, context-fill, lane badge). Extracted from the original monolithic
// controllers.chat closure in app.html — behavior identical. Owns its own
// module-level state (there's only ever one composer on screen, same as
// the original single IIFE), but every WS send goes through a callback
// passed in from chat.ts, which owns the actual WebSocket.

import type { ReadyGenDefaults, SamplingOverrides } from "../../pi-web";
import type { Lane } from "../../serve/lane-registry";
import { api } from "./api";
import type { ApiEnvelope } from "./protocol";
import {
  $, el, toast, trapFocus, type FocusTrap, setSamplingPopoverClose, setSysPromptPopoverClose,
} from "./shell";

/* ────────────────────────────────────────────────────────────────────
   Attachments (files + images)
   ──────────────────────────────────────────────────────────────────── */

export interface Attachment {
  id: number;
  kind: "image" | "text";
  name: string;
  mimeType?: string;
  data?: string;
  text?: string;
  truncated?: boolean;
}

const MAX_TEXT_BYTES = 256 * 1024;
const TEXT_EXTS = /\.(txt|md|markdown|csv|tsv|json|jsonl|ya?ml|toml|ini|cfg|conf|log|xml|html?|css|scss|js|mjs|cjs|ts|tsx|jsx|py|rs|go|java|c|h|cpp|hpp|cc|cs|rb|php|sh|bash|zsh|fish|sql|swift|kt|lua|r|jl|tex|svg|env|gitignore|dockerfile|makefile)$/i;

function isTextFile(f: File): boolean {
  if (f.type.startsWith("text/")) return true;
  if (/(json|xml|javascript|yaml|x-sh|x-toml|csv|markdown)/i.test(f.type)) return true;
  return TEXT_EXTS.test(f.name || "");
}
function readDataUrl(file: File): Promise<string> {
  return new Promise((res, rej) => {
    const r = new FileReader(); r.onerror = rej;
    r.onload = () => { const s = String(r.result); const i = s.indexOf(","); res(i >= 0 ? s.slice(i + 1) : s); };
    r.readAsDataURL(file);
  });
}
function readText(file: File): Promise<string> {
  return new Promise((res, rej) => { const r = new FileReader(); r.onerror = rej; r.onload = () => res(String(r.result)); r.readAsText(file); });
}

export class ComposerState {
  attachments: Attachment[] = [];
  visionCapable = false;  // from the `ready` frame; gates image attachments
  thinkingCapable = false; // from `ready`; gates the reasoning toggle
  // default on: with tools (read/web_search) the reasoning step gives the
  // small model far better tool judgment (answers math/writing itself,
  // only searches when needed). The thinking box defaults collapsed.
  thinkingOn = true;
  attachSeq = 0;

  // Per-request sampling. Each field is either a user override (a number)
  // or null = "use the recommended default" (resolved server-side).
  sampling: Required<SamplingOverrides> = {
    temperature: null, top_p: null, top_k: null, min_p: null,
    xtc_probability: null, xtc_threshold: null, repetition_penalty: null,
    repetition_context_size: null, presence_penalty: null, frequency_penalty: null,
    seed: null,
  };
  // Populated from the `ready` frame (ReadyGenDefaults); null entries fall
  // back to the built-in constants below until a ready frame arrives.
  genDefaults: ReadyGenDefaults = { temperature: null, topP: null, topK: null };

  // Per-chat custom system prompt (plan §9 Phase 2 item, beat matrix Axis 4),
  // layered onto the built-in surface prompt server-side (see pi-web.ts's
  // injectSystemPrompt/installSystemPromptHook). null/"" = none set.
  systemPrompt: string | null = null;

  recTemp(): number { return this.genDefaults.temperature != null ? this.genDefaults.temperature : (this.thinkingOn ? 0.9 : 0.7); }
  recTopP(): number { return this.genDefaults.topP != null ? this.genDefaults.topP : 0.95; }
  recTopK(): number { return this.genDefaults.topK != null ? this.genDefaults.topK : 0; }
}

export async function addFiles(state: ComposerState, files: File[]): Promise<void> {
  for (const f of files) {
    if (f.type.startsWith("image/")) {
      if (!state.visionCapable) { toast("This model can't see images — serve a vision-capable model (look for the vision tag in the Library).", "err"); continue; }
      try { state.attachments.push({ id: ++state.attachSeq, kind: "image", name: f.name || "image", mimeType: f.type, data: await readDataUrl(f) }); }
      catch { toast("Couldn't read " + (f.name || "image"), "err"); }
    } else if (isTextFile(f)) {
      try {
        let text = await readText(f); const truncated = text.length > MAX_TEXT_BYTES; if (truncated) text = text.slice(0, MAX_TEXT_BYTES);
        state.attachments.push({ id: ++state.attachSeq, kind: "text", name: f.name || "file", text, truncated });
      } catch { toast("Couldn't read " + (f.name || "file"), "err"); }
    } else {
      toast("Unsupported file type: " + (f.name || "file"), "err");
    }
  }
  renderAttachments(state);
}
export function renderAttachments(state: ComposerState): void {
  const box = $("chat-attach");
  box.innerHTML = "";
  box.style.display = state.attachments.length ? "flex" : "none";
  for (const a of state.attachments) {
    const chip = el("div", "attach-chip", box);
    chip.dataset.attId = String(a.id); // mention-picker pulse target (composer.ts's initMentionPicker)
    if (a.kind === "image") { const im = el("img", "", chip); im.src = "data:" + a.mimeType + ";base64," + a.data; im.alt = a.name; }
    else el("span", "att-ico", chip).textContent = "📄";
    el("span", "att-name", chip).textContent = a.name + (a.truncated ? " (truncated)" : "");
    const x = el("button", "att-x", chip); x.type = "button"; x.textContent = "✕";
    x.onclick = () => { state.attachments = state.attachments.filter((z) => z.id !== a.id); renderAttachments(state); };
  }
}
export function clearAttachments(state: ComposerState): void { state.attachments = []; renderAttachments(state); }

/** Prepend text-file contents to the message the model sees (UI shows chips). */
export function buildMessageText(state: ComposerState, userText: string): string {
  const files = state.attachments.filter((a) => a.kind === "text");
  if (!files.length) return userText;
  let pre = "";
  for (const a of files) pre += "Attached file: " + a.name + "\n```\n" + a.text + "\n```\n\n";
  return pre + userText;
}
export function updateAttachHint(state: ComposerState): void {
  const btn = $("chat-attach-btn");
  if (btn) btn.title = state.visionCapable ? "Attach files or images" : "Attach files (this model can't see images)";
}

/* ────────────────────────────────────────────────────────────────────
   LoRA adapter selector
   ──────────────────────────────────────────────────────────────────── */

export interface AdapterInfo {
  id: string;
  path: string;
  rank?: number;
  mounted?: boolean;
  compatible?: boolean;
  base_model?: string;
}

function escHtml(s: unknown): string {
  return String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string, string>)[c]!);
}

/** Pure: builds the <option> markup for the adapter <select> from the
 *  /v1/adapters/available list. Split out from refreshAdapters() (which
 *  does the fetch + DOM write) so tests/web-app.test.ts can exercise the
 *  esc() discipline on this template directly without a DOM or network —
 *  every interpolated field (id, rank, path, base_model) must be escaped,
 *  since adapter ids/paths are user-controlled (on-disk directory names). */
export function renderAdapterOptionsHtml(list: AdapterInfo[]): string {
  return '<option value="">no adapter</option>' + list.map((a) => {
    const label = escHtml(a.id) + (a.rank ? " · r" + escHtml(a.rank) : "") + (a.mounted ? " · mounted" : "");
    if (a.compatible) return `<option value="${escHtml(a.id)}" data-path="${escHtml(a.path)}">${label}</option>`;
    const why = a.base_model
      ? `trained for ${escHtml(a.base_model)}, not the currently-served model`
      : "not compatible with the currently-served model";
    return `<option value="${escHtml(a.id)}" disabled title="${why}">${label} (incompatible)</option>`;
  }).join("");
}

// — LoRA adapter selector. Pi-native: app.html lists + mounts adapters, then
//   tells pi-web which one is active; the before_provider_request hook injects
//   it into every provider request. Default "" = none (base model). Still a
//   single-select <select> this phase (the full three-state routing table is
//   Phase 2) — the presentation upgrade here is showing every adapter found
//   on disk (not just ones that fit the served model) with incompatible
//   entries grayed via the `compatible` flag /v1/adapters/available now
//   returns, each with a title explaining why it's unusable right now. —
export async function refreshAdapters(): Promise<void> {
  const sel = $("chat-adapter") as HTMLSelectElement | null;
  if (!sel) return;
  let list: AdapterInfo[] = [];
  try { const d = await api("/v1/adapters/available"); list = (d as { adapters?: AdapterInfo[] }).adapters || []; } catch { /* leave list empty */ }
  const cur = sel.value;
  sel.innerHTML = renderAdapterOptionsHtml(list);
  if (cur && list.some((a) => a.id === cur)) sel.value = cur; // keep prior selection
}

export async function onSelectAdapter(sel: HTMLSelectElement, send: (obj: unknown) => boolean): Promise<void> {
  const id = sel.value;
  if (!id) { send({ type: "set_adapter", id: null }); return; } // none -> base model
  const opt = sel.options[sel.selectedIndex];
  const path = opt && opt.getAttribute("data-path");
  if (path) { // auto-load on select; mount() is idempotent server-side
    const r = await api("/v1/adapters", { method: "POST", body: { id, path } });
    if (r && (r.error || r.ok === false)) {
      toast("adapter: " + (r.error || "mount failed"), "err");
      sel.value = ""; send({ type: "set_adapter", id: null }); return;
    }
  }
  send({ type: "set_adapter", id });
  // Adapter-namespaced KV means a swap can never reuse the outgoing
  // adapter's cache — make that concrete instead of implicit (plan §5.2).
  toast("adapter mounted — new turns start a fresh KV segment", "ok");
}

export function updateThinkingToggle(state: ComposerState): void {
  const b = $("chat-think");
  if (!b) return;
  b.style.display = state.thinkingCapable ? "inline-flex" : "none"; // only for thinking-capable models
  b.classList.toggle("think-on", state.thinkingOn);
  b.title = state.thinkingOn ? "Reasoning on — click to answer directly" : "Reasoning off — click to let the model think";
  b.setAttribute("aria-pressed", String(state.thinkingOn));
  refreshSamplingRecs(state); // recommended temperature follows the thinking state
}

/* ────────────────────────────────────────────────────────────────────
   Sampling popover
   ──────────────────────────────────────────────────────────────────── */

type SamplingField = keyof ComposerState["sampling"];

interface SampFieldDef {
  id: string;
  field: SamplingField;
  valId: string;
  rec?: (state: ComposerState) => number;
  fmt: (v: number) => string;
}

// Each row is a slider + a live value readout. A field is "auto" (null
// override -> the server uses its mode-aware default; temperature/top_p/top_k
// recommendations come from genDefaults, resolved per-model) until the user
// drags it, which records an explicit override. Reset returns every field to
// auto. The three primary fields have a live "rec" (a meaningful recommended
// number always shown dimmed); the Advanced fields have no natural default
// number to display, so they just show "off" until overridden.
const SAMP_FIELDS: SampFieldDef[] = [
  { id: "samp-temp", field: "temperature", valId: "samp-temp-val", rec: (s) => s.recTemp(), fmt: (v) => v.toFixed(2) },
  { id: "samp-topp", field: "top_p", valId: "samp-topp-val", rec: (s) => s.recTopP(), fmt: (v) => v.toFixed(2) },
  { id: "samp-topk", field: "top_k", valId: "samp-topk-val", rec: (s) => s.recTopK(), fmt: (v) => (v >= 1 ? String(Math.round(v)) : "off") },
];
// Advanced fields: no meaningful "recommended" number — auto just reads "off".
const SAMP_ADV_FIELDS: SampFieldDef[] = [
  { id: "samp-minp", field: "min_p", valId: "samp-minp-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-xtcp", field: "xtc_probability", valId: "samp-xtcp-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-xtct", field: "xtc_threshold", valId: "samp-xtct-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-reppen", field: "repetition_penalty", valId: "samp-reppen-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-repctx", field: "repetition_context_size", valId: "samp-repctx-val", fmt: (v) => String(Math.round(v)) },
  { id: "samp-prespen", field: "presence_penalty", valId: "samp-prespen-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-freqpen", field: "frequency_penalty", valId: "samp-freqpen-val", fmt: (v) => v.toFixed(2) },
];
const SAMP_SLIDER_FIELDS = SAMP_FIELDS.concat(SAMP_ADV_FIELDS);

// Sync every slider + readout to current state: an overridden field shows its
// set value (bright readout); an auto primary field shows the recommended
// value (dimmed) and tracks it live — e.g. temperature when the thinking
// toggle flips; an auto Advanced field just shows "off". Also syncs the seed
// text input. Called on thinking-toggle flips, ready-frame arrival, popover
// open, and reset.
export function refreshSamplingRecs(state: ComposerState): void {
  for (const f of SAMP_FIELDS) {
    const slider = $(f.id) as HTMLInputElement | null, val = $(f.valId); if (!slider || !val) continue;
    const over = state.sampling[f.field];
    const v = over != null ? over : f.rec!(state);
    slider.value = String(v);
    val.textContent = f.fmt(v);
    val.classList.toggle("auto", over == null);
  }
  for (const f of SAMP_ADV_FIELDS) {
    const slider = $(f.id) as HTMLInputElement | null, val = $(f.valId); if (!slider || !val) continue;
    const over = state.sampling[f.field];
    slider.value = String(over != null ? over : slider.min);
    val.textContent = over != null ? f.fmt(over) : "off";
    val.classList.toggle("auto", over == null);
  }
  const seedInput = $("samp-seed") as HTMLInputElement | null;
  if (seedInput) seedInput.value = state.sampling.seed != null ? String(state.sampling.seed) : "";
}

// User dragged a slider -> record the explicit override, brighten the readout,
// and push the whole sampling state to the server.
function onSlide(state: ComposerState, f: SampFieldDef, send: (obj: unknown) => boolean): void {
  const slider = $(f.id) as HTMLInputElement | null; if (!slider) return;
  const v = Number(slider.value);
  (state.sampling[f.field] as number) = v;
  const val = $(f.valId); if (val) { val.textContent = f.fmt(v); val.classList.remove("auto"); }
  updateSamplingUi(state);
  pushSampling(state, send);
}
function onSeedInput(state: ComposerState, send: (obj: unknown) => boolean): void {
  const input = $("samp-seed") as HTMLInputElement | null; if (!input) return;
  const raw = input.value.trim();
  let seed: number | null = raw === "" ? null : Number(raw);
  if (seed != null && !Number.isFinite(seed)) seed = null;
  state.sampling.seed = seed;
  updateSamplingUi(state);
  pushSampling(state, send);
}
function pushSampling(state: ComposerState, send: (obj: unknown) => boolean): void {
  send({ type: "set_sampling", ...state.sampling });
}

// The pill shows a lit dot whenever any field is overridden.
function updateSamplingUi(state: ComposerState): void {
  const dirty = Object.values(state.sampling).some((v) => v != null);
  const pill = $("chat-sampling");
  if (pill) { pill.classList.toggle("dirty", dirty); pill.title = dirty
    ? "Sampling overridden — click to edit or reset" : "Sampling controls (temperature · top_p · top_k · Advanced)"; }
}

export function resetSampling(state: ComposerState, send: (obj: unknown) => boolean): void {
  for (const k of Object.keys(state.sampling) as SamplingField[]) (state.sampling[k] as number | null) = null;
  refreshSamplingRecs(state); updateSamplingUi(state);
  pushSampling(state, send);
}

export function initSampling(state: ComposerState, send: (obj: unknown) => boolean): void {
  const pill = $("chat-sampling"), pop = $("chat-sampling-pop");
  if (!pill || !pop) return;
  const trap: FocusTrap = trapFocus(pop, () => pop.classList.contains("open"));
  const setOpen = (open: boolean) => {
    const was = pop.classList.contains("open");
    if (open === was) return;
    if (open) trap.capture();
    pop.classList.toggle("open", open);
    pill.classList.toggle("on", open);
    pill.setAttribute("aria-expanded", String(open));
    if (open) refreshSamplingRecs(state);
    else trap.restore();
  };
  // Exposed so the global Escape sweep (closeTopOverlay) can close this
  // popover uniformly instead of keeping a second Escape listener.
  setSamplingPopoverClose(() => setOpen(false));
  const toggle = () => setOpen(!pop.classList.contains("open"));
  pill.onclick = (e) => { e.stopPropagation(); toggle(); };
  pill.addEventListener("keydown", (e) => { if ((e as KeyboardEvent).key === "Enter" || (e as KeyboardEvent).key === " ") { e.preventDefault(); toggle(); } });
  pop.addEventListener("click", (e) => e.stopPropagation());
  // Click-away closes the popover (Escape is handled globally, see
  // closeTopOverlay — kept out of this listener to avoid a second,
  // divergent Escape path).
  document.addEventListener("click", () => setOpen(false));
  for (const f of SAMP_SLIDER_FIELDS) {
    const e = $(f.id); if (!e) continue;
    e.addEventListener("input", () => onSlide(state, f, send));
  }
  const seedInput = $("samp-seed");
  if (seedInput) seedInput.addEventListener("input", () => onSeedInput(state, send));
  const reset = $("samp-reset"); if (reset) reset.onclick = (e) => { e.stopPropagation(); resetSampling(state, send); };
  updateSamplingUi(state); refreshSamplingRecs(state);
}

/* ────────────────────────────────────────────────────────────────────
   System prompt (plan §9 Phase 2, beat matrix Axis 4) + presets v1
   ──────────────────────────────────────────────────────────────────── */

const SYS_PROMPT_MAX = 4000;

/**
 * One saved preset bundle: a name, the system-prompt text, and a sampling
 * snapshot. Shaped so Phase 5's persona/bundle concept (system prompt +
 * adapter selection + tool allowlist + memory scope, plan §5.7/§6) is an
 * ADDITIVE extension of this same object — new optional fields, no
 * migration of the fields already here. Saved to localStorage, never sent
 * to the server (presets are a client-only convenience over the existing
 * set_system_prompt/set_sampling frames).
 */
export interface Preset {
  name: string;
  systemPrompt: string | null;
  sampling: SamplingOverrides;
  // Phase 5 additive fields (not read/written by v1, documented here so the
  // shape doesn't need revisiting): adapterId?: string | null;
  // toolAllowlist?: string[]; memoryScope?: "off" | "read" | "read+write".
}

const PRESETS_KEY = "mlxbun.presets";

/** Load saved presets from localStorage. Corrupt/missing storage -> empty
 *  list (never throws — a settings-picker feature must never break the
 *  composer it lives next to). */
export function loadPresets(): Preset[] {
  try {
    const raw = localStorage.getItem(PRESETS_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.filter((p): p is Preset =>
      !!p && typeof p === "object" && typeof (p as Preset).name === "string");
  } catch {
    return [];
  }
}

function savePresets(presets: Preset[]): void {
  try { localStorage.setItem(PRESETS_KEY, JSON.stringify(presets)); } catch { /* storage full/unavailable — best effort */ }
}

/** Build a preset snapshot from the current composer state. Pure. */
export function presetFromState(name: string, state: ComposerState): Preset {
  return { name, systemPrompt: state.systemPrompt, sampling: { ...state.sampling } };
}

/** Insert-or-replace by name (case-sensitive), so re-saving "Concise" updates
 *  it in place rather than piling up duplicates. Pure — returns the new
 *  array, doesn't touch storage (callers persist via savePresets). */
export function upsertPreset(presets: Preset[], preset: Preset): Preset[] {
  const i = presets.findIndex((p) => p.name === preset.name);
  if (i === -1) return [...presets, preset];
  const out = presets.slice();
  out[i] = preset;
  return out;
}

/** Remove a preset by name. Pure. */
export function removePreset(presets: Preset[], name: string): Preset[] {
  return presets.filter((p) => p.name !== name);
}

/** Apply a preset's system prompt + sampling to the composer state and push
 *  both through the EXISTING set_system_prompt/set_sampling frames (no new
 *  wire shape for presets — they're a client-side convenience over frames
 *  that already exist). */
export function applyPreset(state: ComposerState, preset: Preset, send: (obj: unknown) => boolean): void {
  state.systemPrompt = preset.systemPrompt ?? null;
  state.sampling = {
    temperature: null, top_p: null, top_k: null, min_p: null,
    xtc_probability: null, xtc_threshold: null, repetition_penalty: null,
    repetition_context_size: null, presence_penalty: null, frequency_penalty: null,
    seed: null,
    ...preset.sampling,
  };
  refreshSystemPromptUi(state);
  pushSystemPrompt(state, send);
  refreshSamplingRecs(state);
  updateSamplingUi(state);
  pushSampling(state, send);
}

function pushSystemPrompt(state: ComposerState, send: (obj: unknown) => boolean): void {
  send({ type: "set_system_prompt", text: state.systemPrompt });
}

/** Sync the textarea, character count, and indicator pill to current state.
 *  Called on popover open and after every edit/clear/preset-apply. */
export function refreshSystemPromptUi(state: ComposerState): void {
  const ta = $("sysprompt-text") as HTMLTextAreaElement | null;
  const count = $("sysprompt-count");
  const text = state.systemPrompt ?? "";
  if (ta && ta.value !== text) ta.value = text;
  if (count) count.textContent = text.length + " / " + SYS_PROMPT_MAX;
  // The pill must always visibly show a custom prompt is shaping replies —
  // a trust rule, not a nicety (task brief item 2).
  const active = text.trim().length > 0;
  const pill = $("chat-sysprompt");
  if (pill) {
    pill.classList.toggle("dirty", active);
    pill.title = active
      ? "Custom system prompt active — click to edit or clear"
      : "System prompt (shapes how the assistant replies in this chat)";
  }
}

function onSystemPromptInput(state: ComposerState, send: (obj: unknown) => boolean): void {
  const ta = $("sysprompt-text") as HTMLTextAreaElement | null;
  if (!ta) return;
  const text = ta.value.slice(0, SYS_PROMPT_MAX);
  if (text !== ta.value) ta.value = text; // hard cap, mirrors the live count
  state.systemPrompt = text.length ? text : null;
  const count = $("sysprompt-count");
  if (count) count.textContent = text.length + " / " + SYS_PROMPT_MAX;
  const pill = $("chat-sysprompt");
  if (pill) {
    const active = text.trim().length > 0;
    pill.classList.toggle("dirty", active);
  }
  pushSystemPrompt(state, send);
}

export function clearSystemPrompt(state: ComposerState, send: (obj: unknown) => boolean): void {
  state.systemPrompt = null;
  refreshSystemPromptUi(state);
  pushSystemPrompt(state, send);
}

/** Pure: builds the <option> markup for the presets <select>. Split out for
 *  the same reason renderAdapterOptionsHtml is — testable esc() discipline
 *  without a DOM. Preset names are user-authored, so every interpolation
 *  must be escaped. */
export function renderPresetOptionsHtml(presets: Preset[]): string {
  return '<option value="">— presets —</option>' +
    presets.map((p) => `<option value="${escHtml(p.name)}">${escHtml(p.name)}</option>`).join("");
}

function renderPresetSelect(): void {
  const sel = $("sysprompt-preset-select") as HTMLSelectElement | null;
  if (!sel) return;
  const cur = sel.value;
  sel.innerHTML = renderPresetOptionsHtml(loadPresets());
  if (cur && [...sel.options].some((o) => o.value === cur)) sel.value = cur;
}

export function initSystemPrompt(state: ComposerState, send: (obj: unknown) => boolean): void {
  const pill = $("chat-sysprompt"), pop = $("chat-sysprompt-pop");
  if (!pill || !pop) return;
  const trap: FocusTrap = trapFocus(pop, () => pop.classList.contains("open"));
  const setOpen = (open: boolean) => {
    const was = pop.classList.contains("open");
    if (open === was) return;
    if (open) trap.capture();
    pop.classList.toggle("open", open);
    pill.classList.toggle("on", open);
    pill.setAttribute("aria-expanded", String(open));
    if (open) { refreshSystemPromptUi(state); renderPresetSelect(); }
    else trap.restore();
  };
  setSysPromptPopoverClose(() => setOpen(false));
  const toggle = () => setOpen(!pop.classList.contains("open"));
  pill.onclick = (e) => { e.stopPropagation(); toggle(); };
  pill.addEventListener("keydown", (e) => { if ((e as KeyboardEvent).key === "Enter" || (e as KeyboardEvent).key === " ") { e.preventDefault(); toggle(); } });
  pop.addEventListener("click", (e) => e.stopPropagation());
  document.addEventListener("click", () => setOpen(false));

  const ta = $("sysprompt-text");
  if (ta) ta.addEventListener("input", () => onSystemPromptInput(state, send));
  const clearBtn = $("sysprompt-clear");
  if (clearBtn) clearBtn.onclick = (e) => { e.stopPropagation(); clearSystemPrompt(state, send); };

  // — Presets v1: save-current / apply / delete over the select above. —
  const presetSelect = $("sysprompt-preset-select") as HTMLSelectElement | null;
  if (presetSelect) presetSelect.addEventListener("change", (e) => {
    e.stopPropagation();
    const name = presetSelect.value;
    if (!name) return;
    const preset = loadPresets().find((p) => p.name === name);
    if (preset) { applyPreset(state, preset, send); toast('Applied preset "' + name + '"', "ok"); }
  });
  const saveBtn = $("sysprompt-preset-save");
  if (saveBtn) saveBtn.onclick = (e) => {
    e.stopPropagation();
    const name = (window.prompt("Save current system prompt + sampling as a preset named:") || "").trim();
    if (!name) return;
    const presets = upsertPreset(loadPresets(), presetFromState(name, state));
    savePresets(presets);
    renderPresetSelect();
    if (presetSelect) presetSelect.value = name;
    toast('Saved preset "' + name + '"', "ok");
  };
  const delBtn = $("sysprompt-preset-delete");
  if (delBtn) delBtn.onclick = (e) => {
    e.stopPropagation();
    const name = presetSelect?.value;
    if (!name) { toast("Select a preset to delete first", "err"); return; }
    savePresets(removePreset(loadPresets(), name));
    renderPresetSelect();
    toast('Deleted preset "' + name + '"', "ok");
  };

  refreshSystemPromptUi(state);
}

/* ────────────────────────────────────────────────────────────────────
   Perf strip: tok/s, TTFT, context-fill, lane badge
   ──────────────────────────────────────────────────────────────────── */

export function fmtTok(n: number | null | undefined): string {
  if (n == null) return "—";
  if (n >= 1e6) return (n / 1e6).toFixed(1) + "M";
  if (n >= 1e3) return (n / 1e3).toFixed(n >= 1e4 ? 0 : 1) + "k";
  return String(n);
}

export interface ContextFrame {
  tokens: number | null;
  contextWindow: number;
  percent: number | null;
}

export function renderContext(m: ContextFrame): void {
  const node = $("pf-fill");
  if (!node || !m.contextWindow) return;
  const pct = m.percent;
  const pctStr = pct == null ? "" : " (" + Math.round(pct) + "%)";
  node.textContent = "ctx " + fmtTok(m.tokens) + "/" + fmtTok(m.contextWindow) + pctStr;
  node.style.color = pct == null ? "var(--dimmer)" : pct >= 85 ? "var(--orange)" : pct >= 70 ? "var(--yellow)" : "var(--dimmer)";
}

// Lane badge (plan §5.2/§6.4, risk #5): server-driven only, from the
// turn_end frame's optional `lane` field (src/serve/lane-registry.ts +
// pi-web.ts). Absent on turns that never resolved a lane (aborted before
// any model call) — the badge just stays hidden rather than guessing.
const LANE_LABEL: Record<Lane, string> = { serial: "serial", "serial+spec": "spec-decode active", batched: "batched" };
const LANE_CLASS: Record<Lane, string> = { serial: "serial", "serial+spec": "spec", batched: "batched" };

export function renderLane(lane: Lane | undefined): void {
  const laneEl = $("pf-lane"), label = $("pf-lane-label");
  if (!laneEl || !label) return;
  if (!lane) { laneEl.style.display = "none"; return; }
  laneEl.className = "pf-lane " + (LANE_CLASS[lane] || "");
  label.textContent = LANE_LABEL[lane] || lane;
  laneEl.style.display = "inline-flex";
}

/* ────────────────────────────────────────────────────────────────────
   Unified "#" retrieval mention (plan §5.2/§9 Phase 2): typing "#" opens a
   picker over BOTH currently-attached files and vault articles (via
   /api/memory/search) as one retrieval gesture — Open WebUI's `#`-mention
   pattern, extended so "attach a file" and "search my memory" are the same
   interaction. Selecting a file pulses its existing attach chip (the file
   is already attached — nothing to insert); selecting an article inserts
   `[[Article Name]]` at the query span (the wikilink syntax
   src/memory/vault.ts's resolveWikilinkToStem/extractWikilinkTargets
   already resolves, so the agent's memory tools pick it up naturally, same
   as in the vault's own prose). No vault -> files-only picker. Pure
   query-detection/insertion helpers below are unit-tested directly
   (tests/web-app.test.ts); DOM wiring (initMentionPicker) owns the
   picker's open/close/keyboard-nav state.
   ──────────────────────────────────────────────────────────────────── */

export interface MentionQuery {
  /** Index (in the textarea value) where the "#" itself sits. */
  hashIndex: number;
  /** The text typed after "#", up to the caret (no spaces — a space ends
   *  the mention span, matching Open WebUI/Slack-style "#" pickers). */
  query: string;
}

/** Pure: does the caret currently sit inside an open "#mention" span? Scans
 *  backward from the caret for a "#" that isn't preceded by a word
 *  character (so "C#" or "issue#12" don't trigger it) and has no whitespace
 *  between it and the caret. Returns null when there's no open mention. */
export function detectMentionQuery(text: string, caret: number): MentionQuery | null {
  if (caret < 0 || caret > text.length) return null;
  let i = caret - 1;
  while (i >= 0) {
    const ch = text[i]!;
    if (ch === "#") {
      const before = i > 0 ? text[i - 1]! : "";
      if (/[A-Za-z0-9_]/.test(before)) return null; // "C#", "issue#12" — not a mention
      return { hashIndex: i, query: text.slice(i + 1, caret) };
    }
    if (/\s/.test(ch)) return null; // whitespace ends the mention span
    i--;
  }
  return null;
}

export type MentionItem =
  | { kind: "file"; id: number; name: string }
  | { kind: "article"; name: string; excerpt?: string };

const MAX_MENTION_FILE_RESULTS = 6;
const MAX_MENTION_ARTICLE_RESULTS = 8;

/** Pure: filters currently-attached files by the mention query (case-
 *  insensitive substring on name; empty query matches everything, so
 *  opening the picker with just "#" shows all attachments first). */
export function filterFileMentions(attachments: Attachment[], query: string): MentionItem[] {
  const q = query.trim().toLowerCase();
  const matches = attachments.filter((a) => !q || a.name.toLowerCase().includes(q));
  return matches.slice(0, MAX_MENTION_FILE_RESULTS).map((a) => ({ kind: "file", id: a.id, name: a.name }));
}

/** Pure: combines file matches (always first — already-attached context is
 *  the cheapest/most relevant hit) with article search hits into one flat
 *  list for keyboard nav. Article list is capped independently of files so
 *  a vault with many hits doesn't crowd out attachments. */
export function buildMentionItems(fileMatches: MentionItem[], articleNames: string[]): MentionItem[] {
  const articles: MentionItem[] = articleNames.slice(0, MAX_MENTION_ARTICLE_RESULTS).map((name) => ({ kind: "article", name }));
  return [...fileMatches, ...articles];
}

/** Pure: replaces the open "#query" span with the mention's insertion text
 *  and returns the new full text + where the caret should land. Files
 *  insert nothing (the file is already attached — the span is just
 *  deleted); articles insert `[[Name]] ` (trailing space so typing
 *  continues naturally, matching resolveWikilinkToStem's bracket syntax). */
export function applyMention(text: string, q: MentionQuery, item: MentionItem, caret: number): { text: string; caret: number } {
  const insertion = item.kind === "article" ? "[[" + item.name + "]] " : "";
  const before = text.slice(0, q.hashIndex);
  const after = text.slice(caret);
  const newText = before + insertion + after;
  return { text: newText, caret: before.length + insertion.length };
}

function escMention(s: unknown): string { return escHtml(s); }

/** Pure: builds the picker's inner HTML for a given item list + selected
 *  index. Split out for esc()-discipline testing without a DOM, same
 *  reasoning as renderAdapterOptionsHtml/renderPresetOptionsHtml above —
 *  file/article names are user/vault data and must be escaped. */
export function renderMentionListHtml(items: MentionItem[], selected: number, memoryEnabled: boolean): string {
  if (!items.length) {
    return '<div class="mention-empty">' +
      (memoryEnabled ? "No matching files or memory articles." : "No matching attached files.") +
      "</div>";
  }
  let filesHtml = "", articlesHtml = "";
  items.forEach((item, i) => {
    const active = i === selected ? " active" : "";
    const row = item.kind === "file"
      ? '<div class="mention-row' + active + '" data-idx="' + i + '" role="option">' +
        '<span class="mention-ico" aria-hidden="true">📄</span>' +
        '<span class="mention-label">' + escMention(item.name) + "</span>" +
        '<span class="mention-tag">attached</span></div>'
      : '<div class="mention-row' + active + '" data-idx="' + i + '" role="option">' +
        '<span class="mention-ico" aria-hidden="true">◆</span>' +
        '<span class="mention-label">' + escMention(item.name.replace(/_/g, " ")) + "</span>" +
        '<span class="mention-tag">memory</span></div>';
    if (item.kind === "file") filesHtml += row; else articlesHtml += row;
  });
  const sections: string[] = [];
  if (filesHtml) sections.push('<div class="mention-sec-title">Attached files</div>' + filesHtml);
  if (articlesHtml) sections.push('<div class="mention-sec-title">Memory</div>' + articlesHtml);
  return sections.join("");
}

type MentionSearchResp = ApiEnvelope & { summaries?: { article: string }[]; enabled?: boolean };

/** DOM wiring for the picker: opens on "#", filters attachments locally +
 *  debounces a /api/memory/search round trip, keyboard nav (arrows/Enter/
 *  Escape), click-to-select, and returns focus to the textarea at the
 *  right caret position on every path (selection, Escape, click-away). */
export function initMentionPicker(state: ComposerState, box: HTMLTextAreaElement, opts: { onFileSelected: (a: Attachment) => void }): void {
  const pop = $("chat-mention-pop");
  if (!pop) return;
  let items: MentionItem[] = [];
  let selected = 0;
  let activeQuery: MentionQuery | null = null;
  let memoryEnabled = true; // optimistic; a failed/empty search just yields no article rows
  let debounce: ReturnType<typeof setTimeout> | undefined;
  let searchSeq = 0;

  function render(): void {
    pop.innerHTML = renderMentionListHtml(items, selected, memoryEnabled);
    pop.querySelectorAll<HTMLElement>(".mention-row").forEach((row) => {
      row.addEventListener("mousedown", (e) => { e.preventDefault(); const idx = Number(row.dataset.idx); if (Number.isFinite(idx)) select(idx); });
    });
  }

  function close(): void {
    pop.classList.remove("open");
    activeQuery = null;
    items = [];
    selected = 0;
  }

  function select(idx: number): void {
    const item = items[idx];
    if (!item || !activeQuery) { close(); return; }
    if (item.kind === "file") {
      const att = state.attachments.find((a) => a.id === item.id);
      const q = activeQuery;
      // File mentions don't rewrite the text — the file is already attached
      // context — just clear the typed "#query" span and pulse its chip.
      const before = box.value.slice(0, q.hashIndex);
      const after = box.value.slice(box.selectionStart ?? box.value.length);
      box.value = before + after;
      box.selectionStart = box.selectionEnd = before.length;
      if (att) opts.onFileSelected(att);
    } else {
      const q = activeQuery;
      const caret = box.selectionStart ?? box.value.length;
      const result = applyMention(box.value, q, item, caret);
      box.value = result.text;
      box.selectionStart = box.selectionEnd = result.caret;
    }
    close();
    box.focus();
    box.dispatchEvent(new Event("input")); // resize + any other input-driven UI stays in sync
  }

  async function runSearch(query: string): Promise<void> {
    const seq = ++searchSeq;
    if (!query.trim()) { updateItems([]); return; }
    try {
      const d = await api<MentionSearchResp>("/api/memory/search?q=" + encodeURIComponent(query));
      if (seq !== searchSeq) return; // stale response — a newer keystroke already superseded it
      // enabled:false is the REST layer's explicit "no vault yet" signal
      // (src/memory/rest.ts's noVault()) — only THAT latches the picker into
      // files-only mode; any other failure (a transient search error) just
      // yields an empty article list for this keystroke, not a permanent
      // downgrade for the rest of the picker session.
      if (d.enabled === false) { memoryEnabled = false; updateItems([]); return; }
      if (d.ok === false) { updateItems([]); return; }
      updateItems((d.summaries || []).map((s) => s.article));
    } catch {
      if (seq !== searchSeq) return;
      updateItems([]);
    }
  }

  function updateItems(articleNames: string[]): void {
    if (!activeQuery) return;
    const fileMatches = filterFileMentions(state.attachments, activeQuery.query);
    items = buildMentionItems(fileMatches, articleNames);
    selected = 0;
    render();
  }

  function openFor(q: MentionQuery): void {
    activeQuery = q;
    pop.classList.add("open");
    const fileMatches = filterFileMentions(state.attachments, q.query);
    items = buildMentionItems(fileMatches, []);
    selected = 0;
    render();
    clearTimeout(debounce);
    debounce = setTimeout(() => runSearch(q.query), 180);
  }

  box.addEventListener("input", () => {
    const caret = box.selectionStart ?? box.value.length;
    const q = detectMentionQuery(box.value, caret);
    if (!q) { close(); return; }
    if (!activeQuery || activeQuery.hashIndex !== q.hashIndex) { openFor(q); return; }
    activeQuery = q;
    const fileMatches = filterFileMentions(state.attachments, q.query);
    items = buildMentionItems(fileMatches, items.filter((i) => i.kind === "article").map((i) => (i as { name: string }).name));
    selected = 0;
    render();
    clearTimeout(debounce);
    debounce = setTimeout(() => runSearch(q.query), 180);
  });

  box.addEventListener("keydown", (e) => {
    if (!pop.classList.contains("open") || !items.length) return;
    if (e.key === "ArrowDown") { e.preventDefault(); selected = Math.min(selected + 1, items.length - 1); render(); }
    else if (e.key === "ArrowUp") { e.preventDefault(); selected = Math.max(selected - 1, 0); render(); }
    else if (e.key === "Enter" || e.key === "Tab") { e.preventDefault(); select(selected); }
    else if (e.key === "Escape") { e.preventDefault(); close(); }
  });

  box.addEventListener("blur", () => {
    // Delay so a click on a .mention-row (which also blurs the textarea)
    // still registers via its mousedown handler before we tear the popover
    // down — mousedown fires before blur, but keep this defensive.
    setTimeout(() => { if (document.activeElement !== box) close(); }, 120);
  });
}

export function renderQueue(q: { steering?: readonly string[]; followUp?: readonly string[] }): void {
  const bar = $("chat-queue");
  const parts: string[] = [];
  // steering/followUp are arrays (pi-web queue_update) — an empty array is
  // truthy, so gate on .length; show the latest steering note and one pill
  // per queued follow-up.
  const steering = q.steering || [];
  if (steering.length) parts.push('<span class="qtag">steering: <b>' + escHtml(String(steering[steering.length - 1]).slice(0, 60)) + "</b></span>");
  for (const f of q.followUp || []) parts.push('<span class="qtag">queued: <b>' + escHtml(String(f).slice(0, 60)) + "</b></span>");
  bar.innerHTML = parts.join("");
  bar.style.display = parts.length ? "flex" : "none";
}
