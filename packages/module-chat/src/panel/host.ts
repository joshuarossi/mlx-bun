// What the panel takes from the page that hosts it, beyond its connection. Everything is optional: a host
// with none gets a chat that stands alone (no memory chips, no settings section). The shell sets it as the
// element's `host` property before the panel attaches.

/** A tool card a host draws in place of the default one (memory's provenance chip). */
export interface ToolCardHandle {
  /** The card's element, already appended to the bubble it was given. */
  readonly wrap: HTMLElement;
  /** Called with the tool's streamed and final results. */
  setResult(result: unknown): void;
}

export interface ChatHost {
  /** Called once the panel's markup exists and its controls are wired: the host attaches what lives beside the chat (the
   * memory entry in the sidebar, the first-run consent card) and keeps the element for its own calls. */
  mounted?(panel: HTMLElement): void;
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
}
