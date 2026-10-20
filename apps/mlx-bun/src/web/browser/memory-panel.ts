// App host adapter for the installed memory panel. Its controller, markup and article renderer belong to the module.
import type { ChatSlots } from "./app-shell/chat-panel";
import { setMemPanelClose } from "./app-shell/shell";
type MemChipHandle = { wrap: HTMLElement; setResult(result: unknown): void };
type MemoryPanel = HTMLElement & { attachChat(slots: ChatSlots): void; open(article?: string): Promise<void>; close(): void; isOpen(): boolean; toolCard(parent: HTMLElement, tool: string, args: unknown): MemChipHandle | null };
const panel = () => document.querySelector<MemoryPanel>("mlx-memory-panel");
export function registerMemoryOverlay(): void { setMemPanelClose(() => panel()?.close()); }
/** Hands memory the chat's slots (its sidebar entry, consent card and greeting chips) once the chat's markup exists. */
export function initMemoryPanel(slots: ChatSlots): void { panel()?.attachChat(slots); registerMemoryOverlay(); }
export function openMemPanel(article?: string): Promise<void> { return panel()?.open(article) ?? Promise.resolve(); }
export function isMemoryOpen(): boolean { return !!panel()?.isOpen(); }
/** Calls `listener` whenever the memory drawer opens or closes, however it was opened (its entry, a chip, the palette,
 * Escape, its scrim); returns the remover. It watches the drawer's `open` class, since memory raises no event of its own. */
export function onMemoryToggle(listener: () => void): () => void {
  const overlay = panel()?.querySelector("#mem-overlay");
  if (!overlay) return () => {};
  let open = isMemoryOpen();
  const observer = new MutationObserver(() => { if (isMemoryOpen() !== open) { open = !open; listener(); } });
  observer.observe(overlay, { attributes: true, attributeFilter: ["class"] });
  return () => observer.disconnect();
}
export function memoryToolChip(parent: HTMLElement, tool: string, args: unknown): MemChipHandle | null { return panel()?.toolCard(parent, tool, args) ?? null; }
