// The sampling popover: temperature, top_p and top_k with the model's recommended values, the Advanced fields, the
// seed, and the scope (this session, or the next message only). A field is automatic (null: the server's mode-aware
// default) until the user moves it; Reset returns every field to automatic. Every change sends the whole sampling
// state as one `set_sampling` frame; session scope omits `scope`, the shape the server has always taken.
import { $, listen, trapFocus, type Disposer } from "@mlx-bun/web-kit";
import type { ClientMessage } from "../../protocol";
import { closeOtherPopovers, setPopoverClose } from "../popovers";
import type { ComposerState } from "./state";

type Send = (frame: ClientMessage) => boolean;
type SamplingField = keyof ComposerState["sampling"];

interface SampFieldDef {
  id: string;
  field: SamplingField;
  valId: string;
  rec?: (state: ComposerState) => number;
  fmt: (value: number) => string;
}

// The primary fields show the model's recommended value (dimmed) until overridden; the Advanced ones have no natural
// default to show, so they read "off".
const SAMP_FIELDS: SampFieldDef[] = [
  { id: "samp-temp", field: "temperature", valId: "samp-temp-val", rec: (s) => s.recTemp(), fmt: (v) => v.toFixed(2) },
  { id: "samp-topp", field: "top_p", valId: "samp-topp-val", rec: (s) => s.recTopP(), fmt: (v) => v.toFixed(2) },
  { id: "samp-topk", field: "top_k", valId: "samp-topk-val", rec: (s) => s.recTopK(), fmt: (v) => (v >= 1 ? String(Math.round(v)) : "off") },
];
const SAMP_ADV_FIELDS: SampFieldDef[] = [
  { id: "samp-minp", field: "min_p", valId: "samp-minp-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-xtcp", field: "xtc_probability", valId: "samp-xtcp-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-xtct", field: "xtc_threshold", valId: "samp-xtct-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-reppen", field: "repetition_penalty", valId: "samp-reppen-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-repctx", field: "repetition_context_size", valId: "samp-repctx-val", fmt: (v) => String(Math.round(v)) },
  { id: "samp-prespen", field: "presence_penalty", valId: "samp-prespen-val", fmt: (v) => v.toFixed(2) },
  { id: "samp-freqpen", field: "frequency_penalty", valId: "samp-freqpen-val", fmt: (v) => v.toFixed(2) },
];

/** Syncs every slider, readout and the seed field to the state: an overridden field shows its value, an automatic
 * primary field tracks the recommendation (temperature follows the thinking toggle), an automatic Advanced one reads
 * "off". Called when the popover opens, on `ready`, on a thinking flip and on reset. */
export function refreshSamplingRecs(state: ComposerState): void {
  for (const f of SAMP_FIELDS) {
    const slider = $(f.id) as HTMLInputElement | null, value = $(f.valId); if (!slider || !value) continue;
    const override = state.sampling[f.field];
    const shown = override != null ? override : f.rec!(state);
    slider.value = String(shown);
    value.textContent = f.fmt(shown);
    value.classList.toggle("auto", override == null);
  }
  for (const f of SAMP_ADV_FIELDS) {
    const slider = $(f.id) as HTMLInputElement | null, value = $(f.valId); if (!slider || !value) continue;
    const override = state.sampling[f.field];
    slider.value = String(override != null ? override : slider.min);
    value.textContent = override != null ? f.fmt(override) : "off";
    value.classList.toggle("auto", override == null);
  }
  const seed = $("samp-seed") as HTMLInputElement | null;
  if (seed) seed.value = state.sampling.seed != null ? String(state.sampling.seed) : "";
}

function onSlide(state: ComposerState, f: SampFieldDef, send: Send): void {
  const slider = $(f.id) as HTMLInputElement | null; if (!slider) return;
  const value = Number(slider.value);
  (state.sampling[f.field] as number) = value;
  const readout = $(f.valId); if (readout) { readout.textContent = f.fmt(value); readout.classList.remove("auto"); }
  pushSampling(state, send);
}

function onSeedInput(state: ComposerState, send: Send): void {
  const input = $("samp-seed") as HTMLInputElement | null; if (!input) return;
  const raw = input.value.trim();
  let seed: number | null = raw === "" ? null : Number(raw);
  if (seed != null && !Number.isFinite(seed)) seed = null;
  state.sampling.seed = seed;
  pushSampling(state, send);
}

/** Sends the sampling state. Next-message scope arms the one-shot indicator only when something is overridden. */
export function pushSampling(state: ComposerState, send: Send): void {
  if (state.samplingScope === "next_turn") {
    send({ type: "set_sampling", scope: "next_turn", ...state.sampling });
    state.oneShotArmed = Object.values(state.sampling).some((v) => v != null);
  } else {
    send({ type: "set_sampling", ...state.sampling });
    state.oneShotArmed = false;
  }
  updateSamplingUi(state);
}

/** The Sampling button's dot: accent while a field is overridden, warning (pulsing) while a next-message override
 * is armed and not yet used. */
export function updateSamplingUi(state: ComposerState): void {
  const dirty = Object.values(state.sampling).some((v) => v != null);
  const button = $("chat-sampling");
  if (button) {
    button.classList.toggle("dirty", dirty && !state.oneShotArmed);
    button.classList.toggle("armed", state.oneShotArmed);
    const dot = button.querySelector(".dot");
    if (dot) dot.className = "dot" + (state.oneShotArmed ? " warn" : dirty ? " accent" : "");
    button.title = state.oneShotArmed ? "Sampling override armed for your next message only"
      : dirty ? "Sampling overridden. Open to edit or reset" : "Sampling: temperature, top_p, top_k and more";
  }
  const chip = $("samp-oneshot-chip");
  if (chip) chip.style.display = state.oneShotArmed ? "" : "none";
  const scope = $("samp-scope") as HTMLSelectElement | null;
  if (scope && scope.value !== state.samplingScope) scope.value = state.samplingScope;
}

/** Called on every `turn_end` (and a failed prompt's `error`): the server applied a one-shot override to exactly that
 * turn, so the indicator clears in lockstep and the scope returns to the session. The values stay: the server owns
 * what the session reverts to. */
export function clearOneShotArmed(state: ComposerState): void {
  if (!state.oneShotArmed) return;
  state.oneShotArmed = false;
  state.samplingScope = "session";
  updateSamplingUi(state);
}

export function resetSampling(state: ComposerState, send: Send): void {
  for (const key of Object.keys(state.sampling) as SamplingField[]) (state.sampling[key] as number | null) = null;
  state.samplingScope = "session";
  refreshSamplingRecs(state);
  pushSampling(state, send);
}

/** Wires the Sampling button and its popover. A click outside closes it; Escape closes it through the host's sweep
 * (`popovers.ts`), never a second Escape listener. */
export function initSampling(state: ComposerState, send: Send, disposer: Disposer): void {
  const button = $("chat-sampling"), pop = $("chat-sampling-pop");
  if (!button || !pop) return;
  const trap = trapFocus(pop, () => pop.classList.contains("open"));
  const setOpen = (open: boolean) => {
    if (open === pop.classList.contains("open")) return;
    if (open) { closeOtherPopovers("chat-sampling-pop"); trap.capture(); }
    pop.classList.toggle("open", open);
    button.classList.toggle("on", open);
    button.setAttribute("aria-expanded", String(open));
    if (open) refreshSamplingRecs(state);
    else if (pop.contains(document.activeElement)) trap.restore(); // a click elsewhere keeps its own focus
  };
  setPopoverClose("chat-sampling-pop", () => setOpen(false));
  button.onclick = (event) => { event.stopPropagation(); setOpen(!pop.classList.contains("open")); };
  pop.addEventListener("click", (event) => event.stopPropagation());
  disposer.add(listen(document, "click", () => setOpen(false)));
  for (const f of [...SAMP_FIELDS, ...SAMP_ADV_FIELDS]) $(f.id)?.addEventListener("input", () => onSlide(state, f, send));
  $("samp-seed")?.addEventListener("input", () => onSeedInput(state, send));
  const reset = $("samp-reset"); if (reset) reset.onclick = (event) => { event.stopPropagation(); resetSampling(state, send); };
  // Choosing "next message only" sends nothing by itself: it changes what the next edit means. Returning to the session
  // scope clears a not-yet-used indicator; the server reverts its one-shot only at turn_end.
  const scope = $("samp-scope") as HTMLSelectElement | null;
  scope?.addEventListener("change", (event) => {
    event.stopPropagation();
    state.samplingScope = scope.value === "next_turn" ? "next_turn" : "session";
    if (state.samplingScope === "session") state.oneShotArmed = false;
    updateSamplingUi(state);
  });
  updateSamplingUi(state);
  refreshSamplingRecs(state);
}
