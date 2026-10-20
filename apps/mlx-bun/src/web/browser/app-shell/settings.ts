// The settings dialog: appearance (the theme control the shell drives), the agent-tools section (the chat panel's
// host side) and the Hugging Face token. The dialog is one overlay with one focus trap; Escape closes it through the
// shell's overlay sweep.
//
// Agent tools: the state of record for both the opt-in toggle and the durable always-allow list is server-side (the
// toggle's enforcement, the tool-approvals file). This file reflects what the server last reported (the chat panel
// relays its `coding_tools` and `tool_approvals` frames here) plus a localStorage mirror that restores the checkbox
// before the first `ready` frame arrives.
import { $, createApi, errorOf, esc, trapFocus, type FocusTrap } from "@mlx-bun/web-kit";
import { toast } from "@mlx-bun/web-shell";
import { chatPanel } from "./chat-panel";

const api = createApi("/api/settings");
let trap: FocusTrap | null = null;

export const isSettingsOpen = (): boolean => $("settings-overlay")?.classList.contains("open") ?? false;

export function openSettings(): void {
  const overlay = $("settings-overlay");
  trap?.capture();
  overlay.classList.add("open");
  $("nav-settings")?.setAttribute("aria-expanded", "true");
  ($("hf-token-input") as HTMLInputElement).value = "";
  $("hf-settings-msg").innerHTML = "";
  void refreshHfState();
  setTimeout(() => $("settings-close")?.focus(), 40);
}

export function closeSettings(): void {
  $("settings-overlay").classList.remove("open");
  $("nav-settings")?.setAttribute("aria-expanded", "false");
  trap?.restore();
}

/** Whether a write token is saved, as the dialog states it. */
export async function refreshHfState(): Promise<boolean> {
  const state = $("hf-state");
  if (state) state.textContent = "Checking for a saved token…";
  const answer = await api.get<{ hasToken?: boolean }>("hf-token");
  const saved = answer.ok !== false && !!answer.hasToken;
  if (state) {
    state.textContent = answer.ok === false ? "Could not read the token setting: " + errorOf(answer)
      : saved ? "A write token is saved. Enter a new one to replace it." : "No token saved. Add a write token to push models and datasets to the Hub.";
  }
  return saved;
}

async function saveHfToken(): Promise<void> {
  const input = $("hf-token-input") as HTMLInputElement;
  const token = input.value.trim();
  const message = $("hf-settings-msg");
  if (!token) { message.innerHTML = '<div class="notice bad" role="alert">Enter a token first.</div>'; input.focus(); return; }
  const button = $("hf-save") as HTMLButtonElement;
  button.disabled = true;
  const answer = await api.post("hf-token", { token });
  button.disabled = false;
  if (!answer.ok) { message.innerHTML = '<div class="notice bad" role="alert">' + esc(errorOf(answer, "could not save the token")) + "</div>"; return; }
  message.innerHTML = '<div class="notice ok" role="status">Token saved to <code>~/.mlx-bun/hf.json</code>.</div>';
  input.value = "";
  void refreshHfState();
  toast("Hugging Face token saved", "ok");
}

/* ── Agent tools ── */
const CODING_TOOLS_KEY = "mlxbun.codingTools";

/** This browser's last requested state; the server decides what is enforced. */
export function storedCodingToolsPreference(): boolean {
  return localStorage.getItem(CODING_TOOLS_KEY) === "1";
}

/** Reflect the server's `coding_tools` report: `active` is what this chat was built with, `pending` the request that
 * applies to the next one; the note says which is which instead of implying the toggle is live at once. */
export function renderCodingToolsState(active: boolean, pending: boolean): void {
  const box = $("settings-coding-tools") as HTMLInputElement | null;
  if (box) box.checked = pending;
  const note = $("settings-coding-tools-note");
  if (!note) return;
  if (pending && !active) { note.style.display = ""; note.textContent = "Applies from your next new chat; this chat keeps its current tools."; }
  else if (!pending && active) { note.style.display = ""; note.textContent = "This chat keeps its tools until you start a new one."; }
  else { note.style.display = "none"; note.textContent = ""; }
}

/** The durable always-allow list, each row with the action that forgets it (the chat panel owns the request). */
export function renderToolApprovals(tools: readonly string[], onForget: (tool: string) => void): void {
  const list = $("settings-approvals-list");
  if (!list) return;
  if (!tools.length) { list.innerHTML = '<div class="settings-approvals-empty">No tool is set to always allow.</div>'; return; }
  list.innerHTML = tools.map((tool) =>
    '<div class="settings-approval"><span class="satool">' + esc(tool) + '</span><button class="btn sm saforget" type="button" data-tool="' + esc(tool) + '">Forget</button></div>').join("");
  list.querySelectorAll<HTMLButtonElement>(".saforget").forEach((button) => { button.onclick = () => onForget(button.dataset.tool || ""); });
}

function initCodingToolsToggle(): void {
  const box = $("settings-coding-tools") as HTMLInputElement | null;
  if (!box) return;
  box.checked = storedCodingToolsPreference();
  box.onchange = () => {
    localStorage.setItem(CODING_TOOLS_KEY, box.checked ? "1" : "0");
    chatPanel()?.setCodingTools(box.checked);
  };
}

/** Wires the dialog once at boot. */
export function initSettings(): void {
  trap = trapFocus($("settings-overlay"), isSettingsOpen);
  $("nav-settings").onclick = openSettings;
  $("settings-close").onclick = closeSettings;
  $("hf-save").onclick = () => { void saveHfToken(); };
  $("settings-overlay").addEventListener("click", (event) => { if (event.target === $("settings-overlay")) closeSettings(); });
  $("hf-token-input").addEventListener("keydown", (event) => { if ((event as KeyboardEvent).key === "Enter") void saveHfToken(); });
  initCodingToolsToggle();
}
