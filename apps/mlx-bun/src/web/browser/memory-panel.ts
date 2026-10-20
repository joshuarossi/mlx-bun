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
export function memoryToolChip(parent: HTMLElement, tool: string, args: unknown): MemChipHandle | null { return panel()?.toolCard(parent, tool, args) ?? null; }
