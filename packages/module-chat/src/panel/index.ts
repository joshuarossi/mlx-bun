// `<mlx-chat-panel>`: the chat as a workspace panel. It is the product's own page, so the shell gives it the whole
// page, keeps it attached while another page shows (a turn in flight and the socket survive a visit elsewhere) and
// tells it when its page is shown (`enter`) and hidden (`leave`). It renders into the light DOM with its own markup
// and stylesheet over the web kit's tokens and base vocabulary, which the host page links; what lives beside it on
// the host page (memory's sidebar entry, the settings dialog's agent-tools section, the host's toasts and pages) is
// wired through the `host` property (`ChatHost`), and `companionSlots()` says where a companion attaches in its markup.
// It talks to the module's socket (`/ws/chat`) and routes (`/api/sessions/*`, `/api/settings/tool-approvals`), which
// keep their shipped root paths on the connection's origin.
import { $, createApi, injectStyles, trapFocus, type FocusTrap } from "@mlx-bun/web-kit";
import { createChatController, type ChatController } from "./chat";
import type { ChatHost, CompanionSlots } from "./host";
import { closeTopPopover, hasOpenPopover } from "./popovers";
import { STYLE } from "./style";
import { MARKUP } from "./template";

export type { ChatHost, ChatHostApp, ChatPanelElement, CompanionSlots, ToolCardHandle } from "./host";

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const Base: typeof HTMLElement = (globalThis as { HTMLElement?: typeof HTMLElement }).HTMLElement ?? (class {} as unknown as typeof HTMLElement);

class ChatPanel extends Base {
  /** Set by the shell before the panel attaches: the module's API base, whose origin the panel's routes resolve on. */
  connection: { readonly apiBase?: string } | undefined;
  host: ChatHost | undefined;
  #controller: ChatController | undefined;
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
      api: createApi(this.connection?.apiBase ?? "/api/chat"),
      isActive: () => !!this.closest("section")?.classList.contains("active"),
      closeDrawer: () => this.closeDrawer(),
    });
    this.#controller.init();
  }

  /** The shell never detaches a workspace panel; one that leaves the document for good (not a move within one task)
   * closes its socket and drops its page-level listeners. */
  disconnectedCallback() {
    queueMicrotask(() => {
      if (this.isConnected || !this.#controller) return;
      this.#controller.dispose();
      this.#controller = undefined;
      this.#drawer = undefined;
    });
  }

  /** The chat page is shown: connect if the socket is down, focus the composer, refresh the adapter list. */
  enter() { this.#controller?.enter(); }
  /** The chat page is hidden: the socket stays up, since closing it would drop a turn in flight. */
  leave() { this.#controller?.leave(); }

  /** Start a fresh chat (the old one stays on disk). */
  newChat() { this.#controller?.newChat(); }
  /** Copy the last reply, as its own Copy button does. */
  copyLastResponse() { this.#controller?.copyLastResponse(); }
  /** Ask for (or stop asking for) file-changing tools; applies from the next new, opened or forked chat. */
  setCodingTools(enabled: boolean) { this.#controller?.setCodingTools(enabled); }
  /** Reload the adapter list (a training job finished). */
  refreshAdapters() { this.#controller?.refreshAdapters(); }
  focusComposer() { $("chat-box")?.focus(); }
  /** Toggle the model's reasoning, as its button does. */
  toggleThinking() { $("chat-think")?.click(); }

  /** The recent chats the sidebar lists, for the host's palette. */
  recentChats(): { title: string; path: string }[] { return this.#controller?.recentChats() ?? []; }
  /** Open a recent chat by its file path, as clicking its row does; false when the sidebar does not list it. */
  openSession(path: string): boolean { return this.#controller?.openSession(path) ?? false; }
  /** Download the chat the sidebar marks active (Markdown by default); nothing when there is none. */
  async exportActiveChat(format: "md" | "json" = "md"): Promise<void> { await this.#controller?.exportActiveChat(format); }

  /** The narrow-screen drawer: the recent-chats sidebar as a slide-over with a focus trap. */
  toggleDrawer() { if (this.drawerOpen()) this.closeDrawer(); else this.openDrawer(); }
  openDrawer() {
    if (!this.#drawer) return;
    this.#drawer.capture();
    $("chat-sidebar").classList.add("drawer-open");
    $("chat-drawer-backdrop").classList.add("open");
    this.#drawerTrigger()?.setAttribute("aria-expanded", "true");
    setTimeout(() => { $("chat-sess-search")?.focus(); }, 30);
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

  /** Where a companion attaches in the chat's markup: the sidebar entry and its count, the first-run consent card and
   * its two actions, and the greeting's suggestion chips. The chat keeps their ids; the elements exist once attached. */
  companionSlots(): CompanionSlots {
    return {
      entry: $("chat-memory-entry") as HTMLButtonElement,
      count: $("chat-memory-count"),
      consent: $("chat-consent"),
      consentYes: $("chat-consent-yes") as HTMLButtonElement,
      consentSkip: $("chat-consent-skip") as HTMLButtonElement,
      chips: $("chat-hello-chips"),
    };
  }

  /** The popovers (sampling, system prompt, adapter table) for the host's Escape sweep. */
  popoverOpen(): boolean { return hasOpenPopover(); }
  closePopover(): boolean { return closeTopPopover(); }
}

if (typeof customElements !== "undefined" && !customElements.get("mlx-chat-panel")) customElements.define("mlx-chat-panel", ChatPanel);
