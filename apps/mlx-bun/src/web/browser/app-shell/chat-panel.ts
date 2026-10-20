// The chat panel as the app reaches it: `@mlx-bun/module-chat`'s `<mlx-chat-panel>` is mounted by the shell as the
// first page, and the app calls it through the element, never through an import.
export interface ChatPanelApi extends HTMLElement {
  newChat(): void;
  copyLastResponse(): void;
  setCodingTools(enabled: boolean): void;
  refreshAdapters(): void;
  focusComposer(): void;
  toggleThinking(): void;
  recentChats(): { title: string; path: string }[];
  openSession(path: string): boolean;
  exportActiveChat(format?: "md" | "json"): Promise<void>;
  toggleDrawer(): void;
  closeDrawer(): void;
  drawerOpen(): boolean;
  popoverOpen(): boolean;
  closePopover(): boolean;
}

/** The mounted chat panel, once the shell has created it (it does on the first visit, which is the home page's). */
export const chatPanel = (): ChatPanelApi | null => document.querySelector<ChatPanelApi>("mlx-chat-panel");
