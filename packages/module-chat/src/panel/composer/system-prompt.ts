// The system prompt popover and its presets. A custom prompt is layered on top of the built-in assistant prompt
// server-side (`set_system_prompt`, applied from the next message) and the Prompt button's dot shows while one is set,
// so it is never shaping replies unseen. A preset bundles the prompt with the current sampling; presets live in this
// browser's localStorage and apply through the existing `set_system_prompt` and `set_sampling` frames.
import { $, esc, listen, trapFocus, type Disposer } from "@mlx-bun/web-kit";
import type { ClientMessage, SamplingOverrides } from "../../protocol";
import { toast } from "../host";
import { closeOtherPopovers, setPopoverClose } from "../popovers";
import { pushSampling, refreshSamplingRecs } from "./sampling";
import type { ComposerState } from "./state";

type Send = (frame: ClientMessage) => boolean;

const SYS_PROMPT_MAX = 4000;

/** One saved preset: a name, the system prompt and a sampling snapshot. Persona fields (an adapter, a tool allowlist, a
 * memory scope) would be additive optional fields. Saved in localStorage, never sent to the server. */
export interface Preset {
  name: string;
  systemPrompt: string | null;
  sampling: SamplingOverrides;
}

const PRESETS_KEY = "mlxbun.presets";

/** Saved presets; missing or corrupt storage reads as none (a convenience never breaks the composer). */
export function loadPresets(): Preset[] {
  try {
    const raw = localStorage.getItem(PRESETS_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.filter((p): p is Preset => !!p && typeof p === "object" && typeof (p as Preset).name === "string");
  } catch {
    return [];
  }
}

function savePresets(presets: Preset[]): void {
  try { localStorage.setItem(PRESETS_KEY, JSON.stringify(presets)); } catch { /* storage full or unavailable: best effort */ }
}

/** A preset snapshot of the composer's current prompt and sampling. */
export function presetFromState(name: string, state: ComposerState): Preset {
  return { name, systemPrompt: state.systemPrompt, sampling: { ...state.sampling } };
}

/** Insert or replace by name, so saving "Concise" again updates it in place. */
export function upsertPreset(presets: Preset[], preset: Preset): Preset[] {
  const i = presets.findIndex((p) => p.name === preset.name);
  if (i === -1) return [...presets, preset];
  const out = presets.slice();
  out[i] = preset;
  return out;
}

export function removePreset(presets: Preset[], name: string): Preset[] {
  return presets.filter((p) => p.name !== name);
}

/** Applies a preset's prompt and sampling and sends both through the existing frames. */
export function applyPreset(state: ComposerState, preset: Preset, send: Send): void {
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
  pushSampling(state, send);
}

function pushSystemPrompt(state: ComposerState, send: Send): void {
  send({ type: "set_system_prompt", text: state.systemPrompt });
}

function showPromptState(text: string): void {
  const count = $("sysprompt-count");
  if (count) count.textContent = text.length + " / " + SYS_PROMPT_MAX;
  const button = $("chat-sysprompt");
  if (!button) return;
  const active = text.trim().length > 0;
  button.classList.toggle("dirty", active);
  const dot = button.querySelector(".dot");
  if (dot) dot.className = "dot" + (active ? " accent" : "");
  button.title = active ? "A custom system prompt is shaping replies. Open to edit or clear it" : "System prompt: shapes how the assistant replies in this chat";
}

/** Syncs the text box, the character count and the Prompt button to the state. */
export function refreshSystemPromptUi(state: ComposerState): void {
  const text = state.systemPrompt ?? "";
  const box = $("sysprompt-text") as HTMLTextAreaElement | null;
  if (box && box.value !== text) box.value = text;
  showPromptState(text);
}

function onSystemPromptInput(state: ComposerState, send: Send): void {
  const box = $("sysprompt-text") as HTMLTextAreaElement | null;
  if (!box) return;
  const text = box.value.slice(0, SYS_PROMPT_MAX);
  if (text !== box.value) box.value = text;
  state.systemPrompt = text.length ? text : null;
  showPromptState(text);
  pushSystemPrompt(state, send);
}

export function clearSystemPrompt(state: ComposerState, send: Send): void {
  state.systemPrompt = null;
  refreshSystemPromptUi(state);
  pushSystemPrompt(state, send);
}

/** The presets `<option>` markup. Preset names are user-authored, so every interpolation is escaped. */
export function renderPresetOptionsHtml(presets: Preset[]): string {
  return '<option value="">Choose a preset</option>' +
    presets.map((p) => `<option value="${esc(p.name)}">${esc(p.name)}</option>`).join("");
}

function renderPresetSelect(): void {
  const select = $("sysprompt-preset-select") as HTMLSelectElement | null;
  if (!select) return;
  const current = select.value;
  select.innerHTML = renderPresetOptionsHtml(loadPresets());
  if (current && [...select.options].some((o) => o.value === current)) select.value = current;
}

/** Wires the Prompt button, its popover and the preset controls. */
export function initSystemPrompt(state: ComposerState, send: Send, disposer: Disposer): void {
  const button = $("chat-sysprompt"), pop = $("chat-sysprompt-pop");
  if (!button || !pop) return;
  const trap = trapFocus(pop, () => pop.classList.contains("open"));
  const setOpen = (open: boolean) => {
    if (open === pop.classList.contains("open")) return;
    if (open) { closeOtherPopovers("chat-sysprompt-pop"); trap.capture(); }
    pop.classList.toggle("open", open);
    button.classList.toggle("on", open);
    button.setAttribute("aria-expanded", String(open));
    if (open) { refreshSystemPromptUi(state); renderPresetSelect(); }
    else if (pop.contains(document.activeElement)) trap.restore(); // a click elsewhere keeps its own focus
  };
  setPopoverClose("chat-sysprompt-pop", () => setOpen(false));
  button.onclick = (event) => { event.stopPropagation(); setOpen(!pop.classList.contains("open")); };
  pop.addEventListener("click", (event) => event.stopPropagation());
  disposer.add(listen(document, "click", () => setOpen(false)));

  $("sysprompt-text")?.addEventListener("input", () => onSystemPromptInput(state, send));
  const clear = $("sysprompt-clear");
  if (clear) clear.onclick = (event) => { event.stopPropagation(); clearSystemPrompt(state, send); };

  const select = $("sysprompt-preset-select") as HTMLSelectElement | null;
  select?.addEventListener("change", (event) => {
    event.stopPropagation();
    const name = select.value;
    if (!name) return;
    const preset = loadPresets().find((p) => p.name === name);
    if (preset) { applyPreset(state, preset, send); toast(`Applied the preset “${name}”.`, "ok"); }
  });
  const save = $("sysprompt-preset-save");
  if (save) save.onclick = (event) => {
    event.stopPropagation();
    const name = (window.prompt("Save the current system prompt and sampling as a preset named:") || "").trim();
    if (!name) return;
    savePresets(upsertPreset(loadPresets(), presetFromState(name, state)));
    renderPresetSelect();
    if (select) select.value = name;
    toast(`Saved the preset “${name}”.`, "ok");
  };
  const remove = $("sysprompt-preset-delete");
  if (remove) remove.onclick = (event) => {
    event.stopPropagation();
    const name = select?.value;
    if (!name) { toast("Choose a preset to delete first.", "err"); return; }
    savePresets(removePreset(loadPresets(), name));
    renderPresetSelect();
    toast(`Deleted the preset “${name}”.`, "ok");
  };
  refreshSystemPromptUi(state);
}
