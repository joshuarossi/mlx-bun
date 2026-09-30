// `<mlx-chat-panel>`: the chat as a workspace panel. It is the product's own page, so the shell gives it the whole
// page, keeps it attached while another page shows (a turn in flight and the socket survive a visit elsewhere) and
// tells it when its page is shown (`enter`) and hidden (`leave`). It renders into the light DOM, with its own
// markup and stylesheet, and takes only its host's design tokens; what lives beside it on the host page (memory's
// sidebar entry, the settings dialog's agent-tools section) is wired through the `host` property (`ChatHost`).
// The panel talks to the module's socket (`/ws/chat`) and routes (`/api/sessions/*`, `/api/settings/tool-approvals`),
// which keep their shipped paths.
import { createChatController } from "./chat";
import { exportSession, openSessionRowByPath } from "./sessions";
import { $, injectStyles, trapFocus, type FocusTrap } from "./dom";
import type { ChatHost } from "./host";
import { closeTopPopover, hasOpenPopover } from "./popovers";
import { STYLE } from "./style";
import { MARKUP } from "./template";

export type { ChatHost, ToolCardHandle } from "./host";

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const Base: typeof HTMLElement = (globalThis as { HTMLElement?: typeof HTMLElement }).HTMLElement ?? (class {} as unknown as typeof HTMLElement);

class ChatPanel extends Base {
  /** Set by the shell before the panel attaches; unused (the module's routes keep their shipped paths). */
  connection: unknown;
  host: ChatHost | undefined;
  #controller: ReturnType<typeof createChatController> | undefined;
  #drawer: FocusTrap | undefined;

  connectedCallback() {
    if (this.#controller) return;
    injectStyles("mlx-chat-panel-style", STYLE);
    this.innerHTML = MARKUP;
    const sidebar = $("chat-sidebar");
    this.#drawer = trapFocus(sidebar, () => sidebar.classList.contains("drawer-open"));
    $("chat-drawer-backdrop").addEventListener("click", () => this.closeDrawer());
    this.#controller = createChatController({
      host: this.host, element: this,
      isActive: () => !!this.closest("section")?.classList.contains("active"),
      closeDrawer: () => this.closeDrawer(),
    });
    this.#controller.init();
  }

  /** The chat page is shown: connect if the socket is down, focus the composer, refresh the adapter list. */
  enter() { this.#controller?.enter(); }
  /** The chat page is hidden: the socket stays up, since closing it would drop a turn in flight. */
  leave() { this.#controller?.leave(); }

  /** Start a fresh chat (the old one stays on disk). */
  newChat() { (this.#controller?.newChat as (() => void) | undefined)?.(); }
  /** Copy the last assistant response, as its own Copy button does. */
  copyLastResponse() { (this.#controller?.copyLastResponse as (() => void) | undefined)?.(); }
  /** Ask for (or stop asking for) file-changing tools; applies from the next new, opened or forked chat. */
  setCodingTools(enabled: boolean) { this.#controller?.setCodingTools(enabled); }
  /** Reload the adapter list (a training job finished). */
  refreshAdapters() { this.#controller?.refreshAdapters(); }
  focusComposer() { $("chat-box")?.focus(); }
  /** Toggle the model's reasoning, as its pill does. */
  toggleThinking() { $("chat-think")?.click(); }

  /** The recent chats the sidebar lists (or filters), for the host's palette. */
  recentChats(): { title: string; path: string }[] {
    return [...document.querySelectorAll<HTMLElement>("#chat-sessions .sess")].flatMap(row =>
      row.dataset.path ? [{ title: row.querySelector(".stitle")?.textContent || "New chat", path: row.dataset.path }] : []);
  }
  /** Open a recent chat by its file path, as clicking its row does; false when the sidebar does not list it. */
  openSession(path: string): boolean { return openSessionRowByPath(path); }
  /** Download the chat the sidebar marks active (Markdown by default); nothing when there is none. */
  async exportActiveChat(format: "md" | "json" = "md"): Promise<void> {
    const row = document.querySelector<HTMLElement>("#chat-sessions .sess.active");
    if (!row || !row.dataset.path) return;
    await exportSession(row.dataset.path, row.querySelector(".stitle")?.textContent || "chat", format);
  }

  /** The mobile drawer: the recent-chats sidebar as a slide-over. */
  toggleDrawer() { $("chat-sidebar").classList.contains("drawer-open") ? this.closeDrawer() : this.openDrawer(); }
  openDrawer() {
    if (!this.#drawer) return;
    this.#drawer.capture();
    $("chat-sidebar").classList.add("drawer-open");
    $("chat-drawer-backdrop").classList.add("open");
    this.#drawerTrigger()?.setAttribute("aria-expanded", "true");
    setTimeout(() => { const search = $("chat-sess-search"); if (search) search.focus(); }, 30);
  }
  closeDrawer() {
    if (!this.#drawer) return;
    $("chat-sidebar").classList.remove("drawer-open");
    $("chat-drawer-backdrop").classList.remove("open");
    this.#drawerTrigger()?.setAttribute("aria-expanded", "false");
    this.#drawer.restore();
  }
  drawerOpen(): boolean { return !!this.#drawer && $("chat-sidebar").classList.contains("drawer-open"); }
  /** The host's control that opens the drawer, if it has one (it names the sidebar in `aria-controls`). */
  #drawerTrigger(): Element | null { return document.querySelector('[aria-controls="chat-sidebar"]'); }

  /** The popovers (sampling, system prompt, adapter table) for the host's Escape sweep. */
  popoverOpen(): boolean { return hasOpenPopover(); }
  closePopover(): boolean { return closeTopPopover(); }
}

if (typeof customElements !== "undefined" && !customElements.get("mlx-chat-panel")) customElements.define("mlx-chat-panel", ChatPanel);
