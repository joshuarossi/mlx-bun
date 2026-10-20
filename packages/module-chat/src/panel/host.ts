// What the panel takes from the page that hosts it, beyond its connection. Everything is optional: a host with none
// gets a chat that stands alone (no memory chips, no settings section, its notices in its own live region, and an
// assistant that knows only the chat's own page). The shell sets it as the element's `host` property before the panel
// attaches. The panel reads nothing else of the host page: its routes, overlays and wizards reach it through `app`.
import { $ } from "@mlx-bun/web-kit";
import type { WizardStep } from "../protocol";

/** A tool card a host draws in place of the default one (memory's provenance chip). */
export interface ToolCardHandle {
  /** The card's element, already appended to the bubble it was given. */
  readonly wrap: HTMLElement;
  /** Called with the tool's streamed and final results. */
  setResult(result: unknown): void;
}

/** Where a companion (memory) attaches in the chat's markup. The chat owns these elements and their ids; a companion
 * adds its own classes and wiring to them. */
export interface CompanionSlots {
  /** The sidebar's entry button (hidden until a companion shows it). */
  entry: HTMLButtonElement;
  /** The count inside the entry. */
  count: HTMLElement;
  /** The first-run consent card in the greeting (shown by adding `.show`), with its two actions. */
  consent: HTMLElement;
  consentYes: HTMLButtonElement;
  consentSkip: HTMLButtonElement;
  /** The greeting's suggestion chips: a `.chip[data-q]` inserted here sends its question when clicked. */
  chips: HTMLElement;
}

/** The panel element as the host sees it once it is mounted. */
export interface ChatPanelElement extends HTMLElement {
  companionSlots(): CompanionSlots;
}

/** The host's knowledge of its own pages, for the app-aware assistant. */
export interface ChatHostApp {
  /** The page showing, by route id (`chat` for the chat's own page). */
  currentRoute(): string;
  /** Shows a page, as the host's own navigation does. */
  navigate(route: string): void;
  /** The host's overlay open on top of the page (`memory-panel`), or null. */
  currentView(): string | null;
  /** The showing page's wizard step, or null when it shows none. */
  wizardStep(): WizardStep | null;
  /** Calls `listener` after the route, the view or the wizard step changed; returns the remover. */
  onChange(listener: () => void): () => void;
}

export interface ChatHost {
  /** Called once the panel's markup exists and its controls are wired: the host attaches what lives beside the chat
   * (the memory entry in the sidebar, the first-run consent card) through `panel.companionSlots()` and keeps the
   * element for its own calls. */
  mounted?(panel: ChatPanelElement): void;
  /** Draws a tool call in place of the default card; null leaves it to the panel. */
  toolCard?(parent: HTMLElement, tool: string, args: unknown): ToolCardHandle | null;
  /** The agent-tools section of the host's settings dialog. */
  settings?: {
    /** The browser's saved wish for file-changing tools (re-asserted on every connection). */
    codingToolsPreference(): boolean;
    /** The server's report: `active` is what this chat was built with, `pending` the request that applies to the next one. */
    codingTools(active: boolean, pending: boolean): void;
    /** The always-allow list, with the action that forgets one entry. */
    approvals(tools: readonly string[], forget: (tool: string) => void): void;
  };
  /** The host's notifications (its toasts); without it the chat shows its notices in its own live region. */
  notify?(message: string, kind?: "ok" | "err"): void;
  /** The host's pages: without it the chat is the only page, its own adapters sheet the only view, and the assistant
   * cannot navigate. */
  app?: ChatHostApp;
}

// One chat panel per document (its ids are the page's), so its notices have one destination.
let notifyHost: ((message: string, kind?: "ok" | "err") => void) | undefined;
let noticeTimer: ReturnType<typeof setTimeout> | undefined;

/** Routes the panel's notices to `host.notify` (or, without one, to the chat's own live region) until the returned
 * remover runs. */
export function bindNotices(host: ChatHost | undefined): () => void {
  const bound = host?.notify ? (message: string, kind?: "ok" | "err") => host.notify!(message, kind) : undefined;
  notifyHost = bound;
  return () => { if (notifyHost === bound) notifyHost = undefined; };
}

/** A notice: the host's toast, or for about four seconds the chat's own `#chat-notice` live region beside the composer. */
export function toast(message: string, kind: "" | "ok" | "err" = "", ms = 4200): void {
  if (notifyHost) { notifyHost(message, kind || undefined); return; }
  const notice = $("chat-notice");
  if (!notice) return;
  clearTimeout(noticeTimer);
  notice.textContent = message;
  notice.dataset.kind = kind;
  notice.hidden = false;
  noticeTimer = setTimeout(() => { notice.hidden = true; notice.textContent = ""; }, ms);
}
