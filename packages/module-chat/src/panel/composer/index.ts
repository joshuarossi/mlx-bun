// The composer: its state (attachments, the model's capabilities from `ready`, sampling, the system prompt), the Send
// and Stop buttons, the queue bar of steering and follow-up messages, the quiet line under it (connection status, the
// decode rate, time to first token and context fill), the Thinking toggle and the LoRA adapter select. The popovers,
// attachments and the `#` picker live in this directory's other files; every frame goes through the `send` the
// controller passes in, which owns the socket.
import { $, errorOf, esc, ms, percent, rate, tokens, type Api } from "@mlx-bun/web-kit";
import type { ClientMessage } from "../../protocol";
import { toast } from "../host";
import { refreshSamplingRecs } from "./sampling";
import type { ComposerState } from "./state";

export { ComposerState, type Attachment } from "./state";
export { addFiles, buildMessageText, clearAttachments, initAttachments, renderAttachments, updateAttachHint, type BuiltMessage } from "./attachments";
export { applyMention, buildMentionItems, detectMentionQuery, filterFileMentions, initMentionPicker, renderMentionListHtml, type MentionItem, type MentionQuery } from "./mentions";
export { clearOneShotArmed, initSampling, pushSampling, refreshSamplingRecs, resetSampling, updateSamplingUi } from "./sampling";
export { applyPreset, clearSystemPrompt, initSystemPrompt, loadPresets, presetFromState, refreshSystemPromptUi, removePreset, renderPresetOptionsHtml, upsertPreset, type Preset } from "./system-prompt";

type Send = (frame: ClientMessage) => boolean;

/** A turn is streaming: Stop takes Send's place. Send stays disabled until the turn ends (Enter still queues a
 * follow-up); when it ends Send is back and enabled, whatever ended it. */
export function setStreaming(on: boolean): void {
  const send = $("chat-send") as HTMLButtonElement | null, stop = $("chat-stop");
  if (send) { send.disabled = on; send.style.display = on ? "none" : ""; }
  if (stop) stop.style.display = on ? "" : "none";
}

/** Stop was pressed: it hides at once and Send shows, still disabled, until the turn's end arrives. */
export function showStopping(): void {
  const send = $("chat-send") as HTMLButtonElement | null, stop = $("chat-stop");
  if (stop) stop.style.display = "none";
  if (send) send.style.display = "";
}

/** The queue bar: the latest steering note and one tag per queued follow-up (arrays, so gated on length). */
export function renderQueue(q: { steering?: readonly string[]; followUp?: readonly string[] }): void {
  const bar = $("chat-queue");
  const parts: string[] = [];
  const steering = q.steering || [];
  if (steering.length) parts.push('<span class="tag qtag">Steering: <b>' + esc(String(steering[steering.length - 1]).slice(0, 60)) + "</b></span>");
  for (const message of q.followUp || []) parts.push('<span class="tag qtag">Queued: <b>' + esc(String(message).slice(0, 60)) + "</b></span>");
  bar.innerHTML = parts.join("");
  bar.style.display = parts.length ? "flex" : "none";
}

export interface ContextFrame {
  tokens: number | null;
  contextWindow: number;
  percent: number | null;
}

/** The context fill from the server's `context` frame: warning past 70%, bad past 85% (it compacts before it fills). */
export function renderContext(m: ContextFrame): void {
  const node = $("pf-fill");
  if (!node || !m.contextWindow) return;
  const pct = m.percent;
  node.textContent = "Context " + tokens(m.tokens) + " / " + tokens(m.contextWindow) + (pct == null ? "" : " (" + percent(pct / 100) + ")");
  node.className = "pf-item" + (pct == null ? "" : pct >= 85 ? " bad" : pct >= 70 ? " warn" : "");
}

/** The live decode rate and time to first token of the streaming (or last) turn. */
export function renderPerf(perf: { tps?: number; ttftMs?: number }): void {
  const tps = $("pf-tps"), ttft = $("pf-ttft");
  if (tps && perf.tps !== undefined) tps.textContent = rate(perf.tps);
  if (ttft && perf.ttftMs !== undefined) ttft.textContent = "First token " + ms(perf.ttftMs);
}

/** Thinking shows only for a model with a reasoning channel; its dot is lit while reasoning is on. */
export function updateThinkingToggle(state: ComposerState): void {
  const button = $("chat-think");
  if (!button) return;
  button.style.display = state.thinkingCapable ? "" : "none";
  button.classList.toggle("think-on", state.thinkingOn);
  const dot = button.querySelector(".dot");
  if (dot) dot.className = "dot" + (state.thinkingOn ? " accent" : "");
  button.title = state.thinkingOn ? "Reasoning is on. Turn it off to answer directly" : "Reasoning is off. Turn it on to let the model think first";
  button.setAttribute("aria-pressed", String(state.thinkingOn));
  refreshSamplingRecs(state); // the recommended temperature follows the thinking state
}

/* The LoRA adapter select: every adapter on disk, the ones trained for another model disabled with the reason. The
   routing table behind the gear (adapters-panel.ts) is the full view; both write the same selection. */

export interface AdapterInfo {
  id: string;
  path: string;
  rank?: number;
  mounted?: boolean;
  compatible?: boolean;
  base_model?: string;
}

/** The select's options. Adapter ids, paths and base models are on-disk names, so every field is escaped. */
export function renderAdapterOptionsHtml(list: AdapterInfo[]): string {
  return '<option value="">No adapter</option>' + list.map((a) => {
    const label = esc(a.id) + (a.rank ? " · r" + esc(a.rank) : "") + (a.mounted ? " · mounted" : "");
    if (a.compatible) return `<option value="${esc(a.id)}" data-path="${esc(a.path)}">${label}</option>`;
    const why = a.base_model ? `trained for ${esc(a.base_model)}, not the served model` : "not compatible with the served model";
    return `<option value="${esc(a.id)}" disabled title="${why}">${label} (incompatible)</option>`;
  }).join("");
}

/** Reloads the select's options, keeping the current choice when it is still on disk. */
export async function refreshAdapters(api: Api): Promise<void> {
  const select = $("chat-adapter") as HTMLSelectElement | null;
  if (!select) return;
  const answer = await api.get<{ adapters?: AdapterInfo[] }>("/v1/adapters/available");
  const list = answer.adapters || [];
  const current = select.value;
  select.innerHTML = renderAdapterOptionsHtml(list);
  if (current && list.some((a) => a.id === current)) select.value = current;
}

/** Mounts the chosen adapter (idempotent server-side) and selects it for the chat's next turns; none is the base model. */
export async function onSelectAdapter(select: HTMLSelectElement, send: Send, api: Api): Promise<void> {
  const id = select.value;
  if (!id) { send({ type: "set_adapter", id: null }); return; }
  const path = select.options[select.selectedIndex]?.getAttribute("data-path");
  if (path) {
    const answer = await api.post("/v1/adapters", { id, path });
    if (answer.error || answer.ok === false) {
      toast("Could not mount the adapter: " + errorOf(answer, "mount failed"), "err");
      select.value = ""; send({ type: "set_adapter", id: null }); return;
    }
  }
  send({ type: "set_adapter", id });
  // Adapter-namespaced KV means a swap never reuses the outgoing adapter's cache: say so.
  toast("Adapter selected. New turns start a fresh KV cache segment.", "ok");
}
